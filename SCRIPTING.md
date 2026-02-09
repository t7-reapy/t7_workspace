# Script Investigations

In this document, there will be tips and stuff around my investigations and discoveries around treyarch scripts (... or community scripts). I think this effort is worth it considering me starting from scratch, for a later me or newcomer. I won't cover the very basics of programming of course, but I will cover specific stuff about the scripts I read and what is worth to note (to re-use, to overwrite, or to understand).

## Sound/Audio format

- Wav file
- 48000 Hz
- Signed 16-bit PCM
- Stereo or Mono channel

## Troubleshoot

If when playing MKV videos, the game crashes, then the version of the software use to make the MKV is too recent:
- Use handbrake 1.0.3
- Remove audio tracks
- Remove subtitle tracks

When booting game after a successful linking of the scripts in the tools, and having error: *`Error linking script: "blabla.gsc"`*, usually it means one script file is missing from zone file. It mostly does this because link step does the linkage with zoned files, not files from the folder AFAIK.

If the map includes weapons that are not linked (especially the ones buyable on the walls), the map doesn't run, and crashes instantly with error about zm_weapons or something.
There is also a wallbuy limit around 20 (depends of the guns used on the walls it seems), that makes the map crashes without errors when using PAP.

## Powerups

Enabling logic is at [`_zm_spawner.gsc`](.\share\raw\scripts\zm\_zm_spawner.gsc#L1545). Zombie's actor variable `zombie.no_powerups` can be configured for specific actor. `level.no_powerups` or flag `flag::set("zombie_drop_powerups", 1)` can be set to true for general decision.

## AI

### Basic AI

`level.zombie_spawn` is an array containing all spawn script_struct for zombie actor spawner, filled in `_zm_spawner.gsc` (or `zm_spawner::` namespace) and it is then spawned in `_zm.gsc` through a loop.

`zm_ai_dogs::special_dog_spawn` can spawn dogs whenever whished, and `dog_spawn_func` to override spawn location, but it takes care of ai limit.

### Apothicon Furies

It seems that original script can be overwritten/customized in some places. Examples:

0. `APOTHICAN_FURY_DEBUG` used to have fury every round after round 1 (note: seem to not work if `APOTHICAN_FURY_USE_SPECIAL_FURY_ROUNDS` is 0. Yeah, because if `APOTHICAN_FURY_USE_SPECIAL_FURY_ROUNDS` is false, then `enable_apothicon_fury_rounds()` is skipped, and therefore, no more round tracker is enabled, and therefore, the spawn interception and trigger stops.
1. by specifying `level.apothicon_fury_round_track_override`, we can define when to spawn furies, during custom rounds for example ... By default, by switching `APOTHICAN_FURY_USE_SPECIAL_FURY_ROUNDS` to 1 or 0, we can have dedicated round, like for dogs.
2. by specifying `level.apothicon_fury_spawn_func`, we can overwrite spawn mechanic to spawn furies differently than the default `function apothicon_fury_special_spawn()` that spawns furies randomly around the player. But that's only if line 386 is fixed to be something like this: `e_ai = [[ level.apothicon_fury_spawn_func ]]();`

## Tips

GDT modifications on weapons (and maybe other properties in GDT) can be live tested with `NevisX` tool.

Every script in `share/raw/scripts/zm` can be overwritten by alimenting scripts with the same name by putting it in the `usermaps/zm_ai_test/scripts/zm`.
> Note: if it's coming from folder `share/raw/scripts/shared`, it seems it's also better to overwrite in `usermaps/zm_ai_test/scripts/shared`, so I should respect relative pathing when overwriting script files...

> Note 2: to override certains basic scripts like _zm_ai_dogs.gsc, it needs to be commented with `//` in `zone_source\all\assetlist\zm_patch.csv`, otherwise, previous version is still linked into the map.

> Note 3: to override certains basic resource file like `zm_levelcommon_weapons.csv`, **you don't need to comment anything** in `zone_source\all\assetlist\zm_levelcommon.csv`.

---

`array::thread_all(array, &func);` array being something like players.
> Cool to call a thread func on each element of array instead of looping over it, can also provide parameters during call.

---

`<entity> delete()` to free entity

### Ambient stuff

The `ambient_mod.csv` or **any ambient mod csv file** needs to be configured according to ardivee's script `_ambient_room.cs`.
> [***not true, I've tested it multiple times, sometimes work, sometimes doesn't, but with current config field value needs to be specified***] => There is a specificity regarding the csv file now: never specify column value `EntityContextValue0` for the default ambient sound.

"Reverb" column config doesn't seem to impact gun sound effects, weirdly, but will affect every other sounds I've been testing.
At least the context ringoff_plr does affect gun sound. Important! context "water":"over" needs to specified, if not, no gun sounds.

### VS Code searching

CoD mod files extensions: `*.csc,*.gsc,*.gsh,*.szc,*.zpkg,*.zone,*.csv,*.gdt,*.map,*.str,*.lua,*.techsetdef`

## Clientfield

**DEBUG CLIENT FIELD WITH: `+set com_clientfieldsdebug 1`**

| Clientfield Type | CSC self          | Free Bits (Starter ZM Map) | Used in Zombies? (Base Game) | General Usage                                                                                                                              |
| :--------------: | :---------------- | -------------------------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
|      world       | level             | 1917                       | Yes                          | A huge pool of bits to manipulate almost any client-side entity. Can also be useful for toggling LUA UI elements.                          |
|      actor       | AI                | 59                         | Yes                          | Used widely to play CSC FX and sounds on a basic Zombie AI.                                                                                |
|     vehicle      | vehicle entity    | 76                         | Sometimes                    | Some AI such as GK drones and SOE wasps use this asset type, along with the Origins tank. Useful to play CSC FX and sounds.                |
|    allplayers    | player            | 107                        | Yes                          | Gets called on EVERY player. A lot of times this is used to play 3rd-person FX on a player while filtering them from seeing it themselves. |
|     toplayer     | player            | 79                         | Yes                          | Gets called on A SINGLE player. Can be used to show FX to a specific player(s).                                                            |
|   playercorpse   | dead player body  | 112                        | No                           | Generally used for playing FX on a player's dead body in Multiplayer.                                                                      |
|  clientuimodel   | N/A               | 79                         | Yes                          | Used to directly interface with a client's LUA UI Model. No CSC functions are needed, but still needs to be registered in CSC.             |
|   scriptmover    | basic entity      | 84                         | Yes                          | Can be used to play client-side FX on a server-side entity. This is especially used if the entity is moving.                               |
|    helicopter    | helicopter entity | 36                         | No                           | Used in BO3 for handling FX and sounds for helicopters and drones.                                                                         |
|      plane       | plane entity      | 63                         | No                           | Used for Plane assets which are not used much in BO3.                                                                                      |
|     missile      | missile entity    | 56                         | Sometimes                    | Can help play FX or sounds on a missile coming from things like a launcher, bow, or AI weapon.                                             |
|     zbarrier     | zbarrier entity   | 44                         | Yes                          | Used to handle FX and sounds for zbarrier assets such as Pack-A-Punch, GobbleGum machines, and zombie barricades.                          |
|       item       | item entity       | 64                         | No                           | Rarely used for specific scenarios in the Campaign.                                                                                        |

## Text colors

| Code | Color     |
| ---- | --------- |
| ^0   | Black     |
| ^1   | Red       |
| ^2   | Green     |
| ^3   | Yellow    |
| ^4   | Blue      |
| ^5   | Cyan      |
| ^6   | Pink      |
| ^7   | White     |
| ^8   | Grey      |
| ^9   | Light red |
