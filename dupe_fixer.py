# dupe_fixer.py 
# by Shidouri [shid] modified by Reapy
# Used to purge duplicate assets from source GDTs for the Black Ops III Mod Tools.

import os
import re
import sys
import shutil
import datetime
from pathlib import Path
from typing import List, Optional, Set, DefaultDict, Dict, Any, Tuple
import threading
import tempfile
from collections import defaultdict
from tqdm import tqdm
from concurrent.futures import ThreadPoolExecutor, as_completed


class GdtAsset:
    asset: str
    type: str
    gdtpath: str
    gdtrelpath: str
    gdtname: str

    def __init__(self, assetname: str, assettype: str, gdtpath: str, gdtrelpath: str, gdtname: str) -> None:
        self.asset = assetname
        self.type = assettype
        self.gdtpath = gdtpath
        self.gdtrelpath = gdtrelpath
        self.gdtname = gdtname


class DupeFlags:
    should_print: bool
    should_bak: bool
    should_verbose: bool

    def __init__(self, should_print: bool = True, should_bak: bool = True, should_verbose: bool = False) -> None:
        self.should_print = should_print
        self.should_bak = should_bak
        self.should_verbose = should_verbose


class GDTDP:
    def _get_dupe_fixer_flags_from_args(self, args: List[str]) -> DupeFlags:
        flags = DupeFlags()
        if len(args) < 2:
            return flags
        
        for arg in args:
            arg = arg.replace('+', '').replace('-', '').replace('/', '')
            if arg in {'no_print', 'no_log', 'noshow', 'quiet', 'shh'}:
                flags.should_print = False
            elif arg in {'developer_no_backup_use_wisely', 'nobak'}:
                flags.should_bak = False
            elif arg in {'verbose', 'v', 'logs', 'log'}:
                flags.should_verbose = True

        return flags

    def _read_gdtdef_or_retrieve(self, outfile_name: str) -> List[str]:
        try:
            with open(outfile_name, 'r', encoding='utf-8') as stock_gdts:
                return [entry.strip() for entry in stock_gdts.readlines()]
        except FileNotFoundError:
            print(f'{outfile_name} not found.')
            return []

    def _get_midgetblaster_gdts(self) -> List[str]:
        return self._read_gdtdef_or_retrieve('midget.gdtdef')

    def _get_stock_gdts(self) -> List[str]:
        return self._read_gdtdef_or_retrieve('stock.gdtdef')

    def split_dupe_error_line_to_object(self, rex_pattern: str, error_line: str) -> Optional[GdtAsset]:
        match = re.findall(rex_pattern, error_line)
        if not match or len(match[0]) < 4:
            return None
        
        xtype, xasset, gdtpath, _gdtline = match[0]
        gdtpath = f"{gdtpath}.gdt".replace('\\', '/').strip()
        gdtname = gdtpath.split('/')[-1]
        gdtrelpath = gdtpath.split('call of duty black ops iii/')[-1]
        
        return GdtAsset(xasset, xtype, gdtpath, gdtrelpath, gdtname)

    def _load_gdt_lists(self) -> None:
        """Load stock and midgetblaster GDT lists; warn if missing."""
        self.stock_gdts = self._get_stock_gdts()
        if not self.stock_gdts:
            print("Warning: stock.gdtdef not found — continuing without stock list.")

        self.stock_midgetblaster_gdts = self._get_midgetblaster_gdts()
        if not self.stock_midgetblaster_gdts:
            print("Warning: midget.gdtdef not found — continuing without midget list.")

    def _build_midget_asset_lookup(self) -> Tuple[Set[str], Set[str]]:
        """Build asset lookup sets (midget_assets, non_midget_assets) in one pass."""
        midget_assets: Set[str] = set()
        non_midget_assets: Set[str] = set()

        for dupe_error_object in tqdm(self.dupe_object_list, desc="Analyzing duplicates", disable=not self.dupe_fixer_flags.should_print):
            asset = dupe_error_object.asset
            gdtrelpath = dupe_error_object.gdtrelpath

            if self._is_midget_gdt(gdtrelpath):
                midget_assets.add(asset)
            else:
                non_midget_assets.add(asset)

        return midget_assets, non_midget_assets

    def _should_purge_dupe(self, dupe_error_object: GdtAsset, midget_assets: Set[str], non_midget_assets: Set[str]) -> bool:
        """Return True if this dupe should be purged based on asset presence."""
        asset = dupe_error_object.asset
        gdtrelpath = dupe_error_object.gdtrelpath

        if self._is_midget_gdt(gdtrelpath):
            return asset in non_midget_assets
        else:
            return asset not in midget_assets

    def _determine_dupes_to_purge(self) -> None:
        """Populate `self.dupes_to_purge` and `self.dupe_assets_to_purge` from parsed errors.

        Builds lookup structures upfront to avoid O(n²) behavior.
        """
        self.dupes_to_purge = []
        self.dupe_assets_to_purge = set()

        # Build asset lookup sets for O(1) checks
        midget_assets, non_midget_assets = self._build_midget_asset_lookup()

        # Second pass: determine which dupes to purge using the precomputed sets
        for dupe_error_object in tqdm(self.dupe_object_list, desc="Determining purges", disable=not self.dupe_fixer_flags.should_print):
            asset = dupe_error_object.asset

            if asset not in self.dupe_assets_to_purge and self._should_purge_dupe(dupe_error_object, midget_assets, non_midget_assets):
                self.dupes_to_purge.append(dupe_error_object)
                self.dupe_assets_to_purge.add(asset)


    def _process_dupes(self) -> None:
        """Group dupes per GDT and process them in parallel (one task per GDT)."""
        if not self.dupes_to_purge:
            return

        # Group entries per GDT so each GDT is processed once (reduces I/O and lock contention)
        gdt_map: Dict[str, Dict[str, Any]] = {}
        for entry in self.dupes_to_purge:
            info = gdt_map.setdefault(entry.gdtpath, {'gdt_name': entry.gdtname, 'assets': set()})
            info['assets'].add(entry.asset)

        with ThreadPoolExecutor(max_workers=min(4, max(1, len(gdt_map)))) as executor:
            futures = [executor.submit(self._remove_dupes_for_gdt, gdtpath, info['gdt_name'], list(info['assets'])) for gdtpath, info in gdt_map.items()]
            for future in tqdm(as_completed(futures), total=len(futures), desc="Purging duplicates", disable=not self.dupe_fixer_flags.should_print):
                try:
                    # Propagate exceptions from worker tasks so failures are visible
                    future.result()
                except Exception as e:
                    tqdm.write(f"Error while purging duplicates: {e}")

        # Clear the dupe error log once after all purges complete (avoid races)
        try:
            open(self.error_log_path, 'w').close()
        except Exception:
            pass

    def _ensure_dupe_error_file_exists(self, dupe_error_txt_file_path: str) -> bool:
        """Ensure `dupe_error.txt` exists. Return True if the file was created.

        This isolates the file-creation branch so the reader logic is simpler.
        """
        if os.path.exists(dupe_error_txt_file_path):
            return False
        try:
            Path(dupe_error_txt_file_path).touch(exist_ok=False)
        except FileExistsError:
            return False
        print("dupe_error.txt was not found.\nIt has now been created for you.")
        return True

    def _parse_dupe_error_file(self, dupe_error_txt_file_path: str, use_progress: bool) -> List[GdtAsset]:
        """Parse `dupe_error.txt` and return list of `GdtAsset` objects.

        Separated from `_read_dupe_error_file` to reduce nested branching.
        """
        rex_pattern = r"ERROR: Duplicate '(.+?)' asset '(.+?)' found in (.+?)\.gdt:(.+?)\n"
        dupe_error_objects: List[GdtAsset] = []

        file_size = os.path.getsize(dupe_error_txt_file_path) if use_progress else 0
        pbar = tqdm(total=file_size, unit='B', unit_scale=True, desc='Reading dupe_error.txt', disable=not use_progress) if use_progress else None

        with open(dupe_error_txt_file_path, 'r', encoding='utf-8') as dupe_error_txt_file:
            for dupe_line in dupe_error_txt_file:
                obj = self.split_dupe_error_line_to_object(rex_pattern, dupe_line)
                if obj:
                    dupe_error_objects.append(obj)
                if pbar:
                    try:
                        pbar.update(len(dupe_line.encode('utf-8')))
                    except Exception:
                        pbar.update(len(dupe_line))

        if pbar:
            pbar.close()

        return dupe_error_objects

    def _read_dupe_error_file(self, dupe_error_txt_file_path: str) -> List[GdtAsset]:
        # Create file if missing and return empty list (avoids nested branches below)
        created = self._ensure_dupe_error_file_exists(dupe_error_txt_file_path)
        if created:
            return []

        file_size = os.path.getsize(dupe_error_txt_file_path)
        use_progress = self.dupe_fixer_flags.should_print and file_size > 0

        return self._parse_dupe_error_file(dupe_error_txt_file_path, use_progress)

    def _purge_asset_from_gdt_lines(self, asset: str, lines: List[str], out_path: str) -> None:
        purging_lines = False
        return_lines: List[str] = []

        for i, line in enumerate(lines):
            if line == "\t{\n" and asset in lines[i - 1] and not purging_lines:
                purging_lines = True
                return_lines.pop()  # Remove the asset line
            elif line == "\t}\n" and purging_lines:
                purging_lines = False
            elif not purging_lines:
                return_lines.append(line)
                
        if self.dupe_fixer_flags.should_verbose: tqdm.write(f"Purging {asset} from {out_path}...")
        # Write atomically to avoid partial/half-written files if interrupted
        out_dir = os.path.dirname(out_path) or '.'
        with tempfile.NamedTemporaryFile('w', delete=False, dir=out_dir, encoding='utf-8') as tf:
            tf.write(''.join(return_lines))
            temp_name = tf.name
        os.replace(temp_name, out_path)

    def _purge_assets_from_gdt_lines(self, assets_set: Set[str], lines: List[str], out_path: str) -> None:
        """Purge multiple assets from a GDT in a single pass and write atomically."""
        purging_lines = False
        return_lines: List[str] = []

        for i, line in enumerate(lines):
            if line == "\t{\n" and any(asset in lines[i - 1] for asset in assets_set) and not purging_lines:
                purging_lines = True
                return_lines.pop()
            elif line == "\t}\n" and purging_lines:
                purging_lines = False
            elif not purging_lines:
                return_lines.append(line)

        if self.dupe_fixer_flags.should_verbose: tqdm.write(f"Purging {assets_set} from {out_path}...")
        out_dir = os.path.dirname(out_path) or '.'
        with tempfile.NamedTemporaryFile('w', delete=False, dir=out_dir, encoding='utf-8') as tf:
            tf.write(''.join(return_lines))
            temp_name = tf.name
        os.replace(temp_name, out_path)

    def _backup_old_gdt(self, name: str, gdt: str) -> None:
        timestamp = datetime.datetime.now().isoformat().replace(':', '_')
        backup_path = Path('./backup')
        backup_path.mkdir(exist_ok=True)

        backup_file = backup_path / f"{timestamp}_{name}"
        shutil.copy2(gdt, backup_file)

    def _remove_dupes_for_gdt(self, gdt_path: str, gdt_name: str, assets: List[str]) -> None:
        """Worker that removes multiple assets from a single GDT in one read/write."""
        assets_set = set(assets)
        file_lock = self.file_locks[gdt_path]
        with file_lock:
            with self.backup_lock:
                if self.dupe_fixer_flags.should_bak and gdt_name not in self.already_backed_up:
                    self._backup_old_gdt(gdt_name, gdt_path)
                    self.already_backed_up.add(gdt_name)

            with open(gdt_path, 'r', encoding='utf-8') as old_gdt:
                old_lines = old_gdt.readlines()

            self._purge_assets_from_gdt_lines(assets_set, old_lines, gdt_path)

    def _is_midget_gdt(self, gdt_rel_path: str) -> bool:
        return gdt_rel_path in self.stock_midgetblaster_gdts

    def __init__(self, error_log: str = './dupe_error.txt', dupe_fixer_flags: Optional[List[str]] = None) -> None:
        self.dupe_fixer_flags = self._get_dupe_fixer_flags_from_args(dupe_fixer_flags or sys.argv)

        # Threading primitives for safe concurrent edits
        self.file_locks: DefaultDict[str, threading.Lock] = defaultdict(threading.Lock)
        self.backup_lock: threading.Lock = threading.Lock()

        # Load stock / midget lists used by decision helpers
        self._load_gdt_lists()

        # Read and parse the dupe error log
        self.error_log_path: str = error_log
        self.dupe_object_list: List[GdtAsset] = self._read_dupe_error_file(self.error_log_path)
        if not self.dupe_object_list:
            input("No GDTs to edit. Press Enter to exit.\n")
            sys.exit(0)

        # Tracking containers
        self.dupes_to_purge: List[GdtAsset] = []
        self.already_backed_up: Set[str] = set()
        self.dupe_assets_to_purge: Set[str] = set()

        # Delegate the decision-making and processing to helpers (reduces complexity)
        self._determine_dupes_to_purge()
        if self.dupes_to_purge:
            self._process_dupes()


if __name__ == "__main__":
    GDTDP()
