/*#==================================================================###
###                                                                  ###
###                 Harry Bo21 & Madgazs Black Ops 3                 ###
###                        Compact Nuke Gun                          ###
###                                                                  ###
###==================================================================#*/

/*======================================================================
                                CREDITS
========================================================================
alexbgt
AllModz
AndyWhelen
Azsry
BluntStuffy
Collie
DTZxPorter
Easyskanka
Erthrock
Frost Iceforge
GerardS0406
Hubashuba
IperBreach
JAMAKINBACONMAN
JBird632
JiffyNoodles
Lilrifa
MadGaz
MZSlayer
NoobForLunch
PCModder
ProGamerzFTW
ProRevenge
Raptroes
RedSpace200
Scobalula
Sethnorris
Smasher248
StevieWonder87
Symbo
TheIronicTruth
TheSkyeLord
thezombieproject
TomBMX
Treyarch and Activision
Will Luffey
WillJones1989
Yen466
Zeroy
=====================================================================*/

#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_madgaz_zm_weap_cng.gsh;

#namespace hb21_madgaz_zm_weap_cng; 

#precache("client_fx", CNG_RED_MUZZLE_FLASH);
#precache("client_fx", CNG_BLUE_MUZZLE_FLASH);
#precache("client_fx", CNG_MUZZLE_BLAST);
#precache("client_fx", CNG_BARREL_SMOKE);
#precache("client_fx", CNG_CHARGING);

REGISTER_SYSTEM("hb21_madgaz_zm_weap_cng", &__init__, undefined)

function __init__()
{
    level.sndChargeShot_Func = &cng_notify_charging;
    callback::on_localplayer_spawned(&on_player_spawned);
}

function cng_notify_charging(local_client_num, w_weapon, charge_shot_level)
{
    if (is_cng_weapon(w_weapon))
        level notify("cng_charge", local_client_num, charge_shot_level);
    
}

function on_player_spawned(local_client_num) 
{
    self thread cng_wait_for_fired(local_client_num);
    self thread monitor_cng_charge_level(local_client_num);
    self thread watch_fire(local_client_num);
    self thread cng_watch_weapon_change(local_client_num);
}

function cng_watch_weapon_change(local_client_num)
{
    self endon("death_or_disconnect");
    self notify("cng_watch_weapon_change");
    self endon("cng_watch_weapon_change");

    while (isDefined(self))
    {
        self waittill("weapon_change", w_new_weapon, w_old_weapon); 
        if (is_cng_weapon(w_new_weapon))
            self thread cng_watch_charge(local_client_num);
        
    }
}

function cng_watch_charge(local_client_num)
{
    self endon("death_or_disconnect");
    self notify("cng_watch_charge");
    self endon("cng_watch_charge");
    
    for (i = 0; i < 0.5; i += 0.01)
    {
        self mapShaderConstant(local_client_num, 0, "scriptVector2", 0, 1, 0, 0);
        wait 0.01;
    }
    while (isDefined(self))
    {
        level waittill("cng_charge", n_local_client_num, charge_shot_level);
        
        if (local_client_num != n_local_client_num)
            continue;
    
        self mapShaderConstant(local_client_num, 0, "scriptVector2", 0, 1, self.cng_charge_level, 0);
    }
}

function watch_fire(local_client_num)
{
    self endon("death_or_disconnect");
    self notify("watch_fire");
    self endon("watch_fire");
    
    while (isDefined(self))
    {
        w_weapon = getCurrentWeapon(local_client_num);
        ammo = int(getWeaponAmmoClip(local_client_num, w_weapon));
        
        while (isDefined(self))
        {
            w_weapon_n = getCurrentWeapon(local_client_num);
            
            if (w_weapon_n != w_weapon)
                break;
            
            ammo_n = int(getWeaponAmmoClip(local_client_num, w_weapon));
            if (ammo_n != ammo)
            {
                if (ammo_n < ammo)
                    self notify("weapon_fired", w_weapon);
                else
                    self notify("weapon_reload", w_weapon);
                
                ammo = ammo_n;
            }
            wait .01;
        }
        
    }
}

function cng_wait_for_fired(local_client_num)
{
    self endon("death_or_disconnect");
    self notify("cng_wait_for_fired");
    self endon("cng_wait_for_fired");
    
    while (isDefined(self))
    {
        self waittill("weapon_fired", w_weapon);
        
        if (!is_cng_weapon(w_weapon))
            continue;
        
        self mapShaderConstant(local_client_num, 0, "scriptVector2", 0, 1, 0, 0);
        
        playViewmodelFX(local_client_num, CNG_RED_MUZZLE_FLASH, "tag_flash");
        playViewmodelFX(local_client_num, CNG_MUZZLE_BLAST, "tag_flash");
        
        if (self.cng_charge_level > 1)
        {
            playViewmodelFX(local_client_num, CNG_BLUE_MUZZLE_FLASH, "tag_flash1");
            playViewmodelFX(local_client_num, CNG_BARREL_SMOKE, "tag_flash1");
        }
        if (self.cng_charge_level > 2)
        {
            playViewmodelFX(local_client_num, CNG_BLUE_MUZZLE_FLASH, "tag_flash2");
            playViewmodelFX(local_client_num, CNG_BARREL_SMOKE, "tag_flash2");
        }
        
    }
}

function monitor_cng_charge_level(local_client_num) 
{
    self endon("disconnect");
    self notify("monitor_cng_charge_level");
    self endon("monitor_cng_charge_level");
    
    self.cng_charge_level = 1;
    while (isDefined(self))
    {
        w_weapon = getCurrentWeapon(local_client_num);
        
        if (is_cng_weapon(w_weapon))
        {
            cng_charge_level = get_current_cng_charge_level(local_client_num, w_weapon);
            if (!isDefined(self.cng_charge_level) || self.cng_charge_level != cng_charge_level)
            {
                self.cng_charge_level = cng_charge_level;
            }

            if (cng_charge_level > 0)
            {
                self thread play_cng_charging_fx(local_client_num);
                self thread play_cng_charging_sfx(local_client_num);
            }
            else
            {
                self thread stop_cng_charging_fx(local_client_num);
                self thread stop_cng_charging_sfx(local_client_num);
            }
        }
        wait .01;
    }
}


function is_cng_weapon(w_weapon)
{
    if (!isDefined(w_weapon))
        return 0;
    if (w_weapon.name != CNG_WEAPONFILE 
        && w_weapon.name != CNG_2_WEAPONFILE 
        && w_weapon.name != CNG_3_WEAPONFILE 
        && w_weapon.name != CNG_UPGRADED_WEAPONFILE 
        && w_weapon.name != CNG_2_UPGRADED_WEAPONFILE 
        && w_weapon.name != CNG_3_UPGRADED_WEAPONFILE)
        return 0;
    
    return 1;
}

function get_current_cng_charge_level(local_client_num, w_weapon) 
{
    array = [];
    array[0] = 1;
    array[1] = 2;
    array[2] = 3;
    
    charge_shot_level = getWeaponChargeLevel(local_client_num);
    remaining_in_clip = int(getWeaponAmmoClip(local_client_num, w_weapon));
    
    cng_charge_level = 0;
    for (i = 0; i < charge_shot_level; i++)
    {
        if (remaining_in_clip < array[i])
            break;
        
        cng_charge_level++;
    }
    
    return cng_charge_level;
}

function private play_cng_charging_fx(local_client_num) // self == player
{
    if (!isdefined(self) || isdefined(self.cng_charging_fx))
        return;

    self.cng_charging_fx = PlayViewmodelFX(local_client_num, CNG_CHARGING, "tag_moonstone");
}

function private stop_cng_charging_fx(local_client_num) // self == player
{
    if (!isdefined(self) || !isdefined(self.cng_charging_fx))
        return;

    StopFX(local_client_num, self.cng_charging_fx);
    wait 0.05;
    self.cng_charging_fx = undefined;
}

function private play_cng_charging_sfx(local_client_num) // self == player
{
    if (!isdefined(self) || isdefined(self.cng_charging_sfx))
        return;

    self.cng_charging_sfx = self PlayLoopSound("wpn_cng_charge_loop", 0.44);
}

function private stop_cng_charging_sfx(local_client_num) // self == player
{
    if (!isdefined(self) || !isdefined(self.cng_charging_sfx))
        return;

    self StopLoopSound(self.cng_charging_sfx);
    wait 0.05;
    self.cng_charging_sfx = undefined;
}
