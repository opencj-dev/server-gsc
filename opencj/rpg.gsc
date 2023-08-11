#include openCJ\util;

onInit()
{
    level.rpgSustain = "rpgsustain";
    rpgSustainCmd = openCJ\settings::addSettingBool(level.rpgSustain, false, "Automatically replace RPG rockets. Usage: !rpgsustain [on/off]");
    openCJ\commands_base::addAlias(rpgSustainCmd, "sustain");
}
