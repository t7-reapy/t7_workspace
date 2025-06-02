#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm;
#using scripts\zm\_util;
#using scripts\shared\util_shared;

#namespace zm_name_checker;

function get_perk_name(perk_value){

    if(!isdefined(perk_value))
        return;

    switch(perk_value){
        case "specialty_armorvest":
        case "juggernog":
        case "jugg":
            return "specialty_armorvest";

        case "specialty_quickrevive":
        case "revive":
        case "quickrevive":
            return "specialty_quickrevive";

        case "specialty_fastreload":
        case "fastreload":
        case "reload":
        case "speedcola":
        case "speed":
            return "specialty_fastreload";

        case "specialty_doubletap2":
        case "doubletap":
        case "fastfire":
            return "specialty_doubletap2";

        case "specialty_staminup":
        case "staminup":
        case "marathon":
            return "specialty_staminup";

        case "specialty_phdflopper":
        case "phdflopper":
        case "phd":
        case "flopper":
            return "specialty_phdflopper";

        case "specialty_deadshot":
        case "deadshot":
        case "ads":
        case "daiquiri":
            return "specialty_deadshot";

        case "specialty_additionalprimaryweapon":
        case "additionalprimaryweapon":
        case "mulekick":
        case "mule":
            return "specialty_additionalprimaryweapon";

        case "specialty_electriccherry":
        case "electriccherry":
        case "electric_cherry":
        case "electric":
        case "cherry":
            return "specialty_electriccherry";

        case "specialty_tombstone":
        case "tombstone":
        case "tomb":
            return "specialty_tombstone";

        case "specialty_whoswho":
        case "whoswho":
        case "whos_who":
        case "whos":
            return "specialty_whoswho";

        case "specialty_vultureaid":
        case "vultureaid":
        case "vulture":
        case "aid":
            return "specialty_vultureaid";

        case "specialty_widowswine":
        case "widowswine":
        case "widows":
        case "wine":
            return "specialty_widowswine";

        case "specialty_flakjacket":
        case "moonshine":
        case "moon":
        case "shine":
        case "madgaz_moonshine":
            return "specialty_flakjacket";

        case "specialty_flashprotection":
        case "crusader":
        case "crusader_ale":
        case "ale":
        case "madgaz_crusader":
            return "specialty_flashprotection";

        case "specialty_proximityprotection":
        case "bull_ice_blast":
        case "iceblast":
        case "ice_blast":
        case "bull_ice":
        case "bullice":
        case "madgaz_bull":
        case "bull":
        case "bullsiceblast":
        case "bulliceblast":
            return "specialty_proximityprotection";

        case "specialty_immunecounteruav":
        case "bananacolada":
        case "banana":
        case "colada":
        case "banana_colada":
        case "madgaz_banana":
            return "specialty_immunecounteruav";

        case "specialty_directionalfire":
        case "vigorrush":
        case "vigor":
        case "rush":
        case "vigor_rush":
            return "specialty_directionalfire";

        case "madgaz":
            return "specialty_immunecounteruav specialty_proximityprotection specialty_flashprotection specialty_flakjacket ;";

        case "classic":
            return "specialty_armorvest specialty_fastreload specialty_doubletap2 specialty_quickrevive ;";

        default:
            return perk_value;

    }
}

function get_powerup_name(powerup_value){

    if(!isdefined(powerup_value))
        return;

    switch(powerup_value){
        case "full_ammo":
        case "max_ammo":
        case "maxammo":
        case "max":
        case "ammo":
            return "full_ammo";

        case "nuke":
        case "boom":
            return "nuke";

        case "insta_kill":
        case "instakill":
        case "insta":
        case "kill":
            return "insta_kill";

        case "double_points":
        case "doublepoints":
        case "dpoints":
        case "double":
            return "double_points";

        case "carpenter":
            return "carpenter";

        case "fire_sale":
        case "firesale":
        case "fire":
        case "sale":
            return "fire_sale";

        case "bonfire_sale":
        case "bonfire":
        case "bonfiresale":
            return "bonfire_sale";

        case "minigun":
            return "minigun";

        case "free_perk":
        case "freeperk":
        case "perk":
            return "free_perk";

        case "tesla":
            return "tesla";

        case "random_weapon":
        case "randomweapon":
        case "weapon":
            return "random_weapon";

        case "bonus_points_player":
        case "playerpoints":
        case "points_player":
        case "bonus_player":
        case "money_player":
            return "bonus_points_player";

        case "bonus_points_team":
        case "teampoints":
        case "points_team":
        case "bonus_team":
        case "money_team":
        case "points":
            return "bonus_points_team";

        case "lose_points_team":
        case "losepointsteam":
        case "teamlose":
        case "team_lose":
            return "lose_points_team";

        case "lose_perk":
        case "loseperk":
            return "lose_perk";

        case "empty_clip":
        case "emptyclip":
            return "empty_clip";

        case "zombie_blood":
        case "blood":
        case "zombie":
        case "zombieblood":
            return "zombie_blood";

        case "ww_grenade":
        case "ww":
        case "wwgrenade":
        case "widows":
        case "widowswine":
        case "widowswinegrenade":
            return "ww_grenade";

        case "shield_charge":
        case "shieldcharge":
        case "shield":
        case "charge":
            return "shield_charge";

        case "perk_slot":
        case "perkslot":
        case "slot":
            return "perk_slot";

        case "full_power":
        case "fullpower":
        case "power":
            return "full_power";

        case "blood_money":
        case "blood_points":
        case "bloodpoints":
        case "bloodmoney":
            return "blood_money";

        case "bottomless_clip":
        case "clip":
        case "bottomless":
        case "bottomlessclip":
        case "infiniteammo":
        case "infinite":
            return "bottomless_clip";

        case "fast_feet":
        case "fastfeet":
        case "feet":
        case "fast":
            return "fast_feet";

        default:
            return powerup_value;
    }
}

function spawn_powerup_player(str_powerup, v_origin)
{
    if(!isdefined(v_origin))
    {
        v_origin = self.origin + VectorScale(AnglesToForward((0, self getPlayerAngles()[1], 0)), 60) + VectorScale((0, 0, 1), 5);
    }
    var_93eb638b = zm_powerups::specific_powerup_drop(str_powerup, v_origin);
    wait(1);
    if(isdefined(var_93eb638b) && (!var_93eb638b zm::in_enabled_playable_area() && !var_93eb638b zm::in_life_brush()))
    {
        level thread function_434235f9(var_93eb638b);
    }
}

function powerup_placement(var_d858aeb5){
    var_7ec6c170 = self.origin + VectorScale(AnglesToForward((0, self getPlayerAngles()[1], 0)), 60) + VectorScale((0, 0, 1), 5);
    v_up = VectorScale((0, 0, 1), 5);
    var_8e2dcc47 = var_7ec6c170 + AnglesToForward(self.angles) * 60 + v_up;
    var_682b51de = var_8e2dcc47 + AnglesToForward(self.angles) * 60 + v_up;
    switch(var_d858aeb5)
    {
        case 1:
            v_origin = var_7ec6c170 + AnglesToRight(self.angles) * -60 + v_up;
            break;

        case 2:
            v_origin = var_7ec6c170;
            break;
        
        case 3:
            v_origin = var_7ec6c170 + AnglesToRight(self.angles) * 60 + v_up;
            break;
        
        case 4:
            v_origin = var_8e2dcc47 + AnglesToRight(self.angles) * -60 + v_up;
            break;
        
        case 5:
            v_origin = var_8e2dcc47;
            break;
        
        case 6:
            v_origin = var_8e2dcc47 + AnglesToRight(self.angles) * 60 + v_up;
            break;
        
        case 7:
            v_origin = var_682b51de + AnglesToRight(self.angles) * -60 + v_up;
            break;

        case 8:
            v_origin = var_682b51de;
            break;
        
        case 9:
            v_origin = var_682b51de + AnglesToRight(self.angles) * 60 + v_up;
            break;
        
        default:
            v_origin = var_7ec6c170;
            break;
    }
    return v_origin;
}

function function_434235f9(var_93eb638b)
{
    if(!isdefined(var_93eb638b))
    {
        return;
    }
    var_93eb638b ghost();
    var_93eb638b.clone_model = util::spawn_model(var_93eb638b.model, var_93eb638b.origin, var_93eb638b.angles);
    var_93eb638b.clone_model LinkTo(var_93eb638b);
    direction = var_93eb638b.origin;
    direction = (direction[1], direction[0], 0);
    if(direction[1] < 0 || (direction[0] > 0 && direction[1] > 0))
    {
        direction = (direction[0], direction[1] * -1, 0);
    }
    else if(direction[0] < 0)
    {
        direction = (direction[0] * -1, direction[1], 0);
    }
    if(!(isdefined(var_93eb638b.sndNoSamLaugh) && var_93eb638b.sndNoSamLaugh))
    {
        players = GetPlayers();
        for(i = 0; i < players.size; i++)
        {
            if(isalive(players[i]))
            {
                players[i] playlocalsound(level.zmb_laugh_alias);
            }
        }
    }
    PlayFXOnTag(level._effect["samantha_steal"], var_93eb638b, "tag_origin");
    var_93eb638b.clone_model Unlink();
    var_93eb638b.clone_model MoveZ(60, 1, 0.25, 0.25);
    var_93eb638b.clone_model vibrate(direction, 1.5, 2.5, 1);
    var_93eb638b.clone_model waittill("movedone");
    if(isdefined(self.damagearea))
    {
        self.damagearea delete();
    }
    var_93eb638b.clone_model delete();
    if(isdefined(var_93eb638b))
    {
        if(isdefined(var_93eb638b.damagearea))
        {
            var_93eb638b.damagearea delete();
        }
        var_93eb638b zm_powerups::powerup_delete();
    }
}