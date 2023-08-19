#include openCJ\util;

onInit()
{
    level.weapons_loadouts = [];
    level.weapons_grenades = [];
    level.weapons_rpgs = [];

    if(getCodVersion() == 2)
    {
        _registerLoadout("default", "tt30_mp");
        _registerGrenade("default", "frag_grenade_american_mp");
    }
    else
    {
        underlyingCmd = openCJ\settings::addSettingBool("rpgonload", false, "Enable/disable rpg on load. Usage: !rpgonload [on/off]");
        underlyingCmd = openCJ\settings::addSettingBool("rpgputaway", false, "Enable/disable rpg putaway on fire. Usage: !rpgputaway [on/off]");
        openCJ\commands_base::addAlias(underlyingCmd, "rpgswitch");
        underlyingCmd = openCJ\settings::addSettingBool("rpgsustain", false, "Enable/disable rpg sustain on fire. Usage: !rpgsustain [on/off]");
        underlyingCmd = openCJ\settings::addSettingBool("slowreload", false, "Enable/disable slow reload animations. Usage: !slowreload [on/off]", ::_onSettingSlowReload);
        underlyingCmd = openCJ\settings::addSettingBool("smallcrosshair", false, "Enable/disable smaller crosshair. Usage: !smallcrosshair [on/off]", ::_onSettingSmallCrosshair);

        _registerLoadout("default", "deserteagle_mp");
        _registerRPG("default", "rpg_mp");
    }
}

giveWeapons(giveRPG, isSpawn)
{
    if(isSpawn)
        self _giveWeapons(giveRPG);
    self _deleteGrenades();
}

switchToDemoWeapon(isRPG)
{
    if(isRPG)
    {
        if(self hasWeapon(level.weapons_rpgs["default"]) && self getCurrentWeapon() != level.weapons_rpgs["default"])
        {
            self switchToWeapon(level.weapons_rpgs["default"]);
        }
    }
    else
    {
        if(self hasWeapon(level.weapons_loadouts["default"]) && self getCurrentWeapon() != level.weapons_loadouts["default"])
        {
            self switchToWeapon(level.weapons_loadouts["default"]);
        }
    }
}

onRunRestored()
{
    self _deleteGrenades();
}

onRunCreated()
{
    self _deleteGrenades();
}

_deleteGrenades()
{
    nade = self.weapons_prevNade;
    while(isDefined(nade))
    {
        tmp = nade.prevNade;
        if(!nade isThinking()) //todo: fix this func for cod4
            nade delete();
        nade = tmp;
    }
    self.weapons_prevNade = undefined;
}

_giveWeapons(rpgDefault)
{
    self takeAllWeapons();
    self _giveLoadout("default", !rpgDefault);
    self _giveGrenades("default", false);
    self _giveRPG("default", rpgDefault);
}

_registerLoadout(name, weapon)
{
    level.weapons_loadouts[name] = weapon;
    precacheItem(weapon);
}

_registerGrenade(name, weapon)
{
    level.weapons_grenades[name] = weapon;
    precacheItem(weapon);
}

_registerRPG(name, weapon)
{
    level.weapons_rpgs[name] = weapon;
    precacheItem(weapon);
}

_giveLoadout(name, spawnWeapon)
{
    if(!isDefined(level.weapons_loadouts[name]))
        return;

    self giveWeapon(level.weapons_loadouts[name]);
    self giveMaxAmmo(level.weapons_loadouts[name]);
    if(spawnWeapon)
        self setSpawnWeapon(level.weapons_loadouts[name]);
}

_giveGrenades(name, spawnWeapon)
{
    if(!isDefined(level.weapons_grenades[name]))
        return;

    self giveWeapon(level.weapons_grenades[name]);
    self giveMaxAmmo(level.weapons_grenades[name]);
}

_giveRPG(name, spawnWeapon)
{
    if(!isDefined(level.weapons_rpgs[name]))
        return;

    self giveWeapon(level.weapons_rpgs[name]);
    self giveMaxAmmo(level.weapons_rpgs[name]);
    self setactionslot(4, "weapon", level.weapons_rpgs[name]);
    if(spawnWeapon)
        self setSpawnWeapon(level.weapons_rpgs[name]);
}

onRPGFired(rpg, name)
{
    self giveMaxAmmo(name);
    if(self openCJ\settings::getSetting("rpgputaway"))
    {
        self setWeaponAmmoClip(name, 1);
        self switchToWeapon(level.weapons_loadouts["default"]);
    }
    if(self openCJ\settings::getSetting("rpgsustain"))
    {
        self thread _rpgSustain(name);
    }
}
_rpgSustain(name)
{
    self endon("disconnect");
    self endon("spawned");
    self endon("spawned_spectator");
    self SetWeaponAmmoStock(name, 0);
    wait 0.9;
    self SetWeaponAmmoClip(name, 1);
    self giveMaxAmmo(name);
}

onGrenadeThrow(nade, name)
{
    nade.prevNade = self.weapons_prevNade;
    self.weapons_prevNade = nade;
    self giveMaxAmmo(name);
}

isRPG(weapon)
{
    if(!isDefined(weapon))
        return false;

    if(level.weapons_rpgs.size)
    {
        keys = getArrayKeys(level.weapons_rpgs);
        for(i = 0; i < keys.size; i++)
        {
            if(level.weapons_rpgs[keys[i]] == weapon)
                return true;
        }
    }
    return false;
}

isGrenade(weapon)
{
    if(!isDefined(weapon))
        return false;

    if(level.weapons_grenades.size)
    {
        keys = getArrayKeys(level.weapons_grenades);
        for(i = 0; i < keys.size; i++)
        {
            if(level.weapons_grenades[keys[i]] == weapon)
                return true;
        }
    }
    return false;
}

_onSettingSlowReload(value)
{
    if(value)
    {
        self setClientCvar("perk_weapReloadMultiplier", 1);
    }
    else
    {
        self setClientCvar("perk_weapReloadMultiplier", 0.5);
    }
}

_onSettingSmallCrosshair(value)
{
    setWeaponSpread(value);
}

setWeaponSpread(value) 
{
    if(!isDefined(value))
    {
        value = self openCJ\settings::getSetting("smallcrosshair");
    }
    if(value)
    {
        self SetSpreadOverride(1);
    }
    else
    {
        self ResetSpreadOverride();
    }
}