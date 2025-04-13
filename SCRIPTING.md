# Script Investigations

In this document, there will be tips and stuff around my investigations and discoveries around tryarch scripts (... or community scripts). I think this effort is worth it considering me starting from scratch, for a later me or newcomer. I won't cover the very basics of programming of course, but I will cover specific stuff about the scripts I read and what is worth to note (to re-use, to overwrite, or to understand).

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

Every script in `share/raw/scripts/zm` can be overwritten by alimenting scripts with the same name by putting it in the `usermaps/zm_ai_test/scripts/zm`. 
> Note: if it's coming from folder `share/raw/scripts/shared`, it seems it's also better to overwrite in `usermaps/zm_ai_test/scripts/sahred`, so I should respect relative pathing when overwriting script files...

> Note 2: to override certains basic scripts like _zm_ai_dogs.gsc, it needs to be commented with `//` in `zone_source\all\assetlist\zm_patch.csv`, otherwise, previous version is still linked into the map.

---

`array::thread_all(array, &func);` array being something like players.
> Cool to call a thread func on each element of array instead of looping over it, can also provide parameters during call.

---

`<entity> delete()` to free entity