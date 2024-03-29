#include openCJ\util;

onInit()
{
    level.settings = [];
}

areSettingsLoaded()
{
    return self.settingsLoaded;
}

onPlayerConnect()
{
    self.settingValues = [];
    self.settingsLoaded = false;
    self setDefaultSettings();
}

setDefaultSettings()
{
    keys = getArrayKeys(level.settings);
    for(i = 0; i < keys.size; i++)
    {
        name = keys[i];
        // Only fill in default value here, but don't apply it. Defaults may not be to the player's liking and should only be a last resort.
        self.settingValues[name] = level.settings[name].defaultVal;
    }
}

loadSettingsFromDatabase()
{
    self endon("disconnect");

    availableSettings = getArrayKeys(level.settings);
    query = "SELECT a.settingName, b.value FROM settings a INNER JOIN playerSettings b ON a.settingID = b.settingID WHERE b.playerID = " + self openCJ\login::getPlayerID();
    rows = self openCJ\mySQL::mysqlAsyncQuery(query);
    if(isDefined(rows) && (rows.size > 0) && isDefined(rows[0][0]))
    {
        for(i = 0; i < rows.size; i++)
        {
            name = tolower(rows[i][0]);
            if(isInArray(name, availableSettings))
            {
                value = parseSettingValue(level.settings[name], rows[i][1]);
                if(!isDefined(value))
                {
                    self iprintln("Not setting " + name + " because it has an invalid stored value");
                    self thread _clearSetting(name);
                }
                else
                {
                    // Update the setting, will be applied later together with remaining defaults
                    self.settingValues[name] = value;
                }
            }
        }
    }

    // Now that the player's custom settings were retrieved, apply all settings (including any remaining defaults)
    keys = getArrayKeys(self.settingValues);
    for (i = 0; i < keys.size; i++)
    {
        name = keys[i];

        // Call the update function to apply this change
        if(isDefined(level.settings[name].updateFunc))
        {
            self [[level.settings[name].updateFunc]](self.settingValues[name]);
        }
    }

    self.settingsLoaded = true;
    self openCJ\events\playerLogin::main();
}

onNewAccount()
{
    self.settingsLoaded = true;
    self openCJ\events\playerLogin::main();
}

_clearSetting(name)
{
    self thread openCJ\mySQL::mysqlAsyncQueryNosave("DELETE FROM playerSettings WHERE playerID = " + self openCJ\login::getPlayerID() + " AND settingID = (SELECT settingID FROM settings WHERE setting = " + openCJ\mySQL::escapeString(name) + ")");
}

setSetting(name, val)
{
    self _setSetting(name, val, false);
}

setSettingByScript(name, val)
{
    self _setSetting(name, val, true);
}

_setSetting(name, val, changedByScript)
{
    if(!isDefined(level.settings[name]))
    {
        return false;
    }

    args = [];
    args[0] = val;
    self onSetting(name, args, changedByScript);
    return true;
}

getSetting(name)
{
    return self.settingValues[name];
}

parseSettingValue(setting, value)
{
    if(!isDefined(value))
    {
        return undefined;
    }

    switch(setting.type)
    {
        case "string":
        {
            if((value.size < setting.minLen) || (value.size > setting.maxLen))
            {
                return undefined;
            }
            return value;
        }
        case "int":
        {
            if(!isValidInt(value))
            {
                return undefined;
            }

            value = int(value);
            if((value < setting.minVal) || (value > setting.maxVal))
            {
                return undefined;
            }
            return value;
        }
        case "bool":
        {
            if(!isValidBool(value))
            {
                return undefined;
            }
            return strToBool(value);
        }
        case "float":
        {
            if(!isValidFloat(value))
            {
                return undefined;
            }

            value = float(value);
            if((value < setting.minVal) || (value > setting.maxVal))
            {
                return undefined;
            }
            return value;
        }
    }
    return undefined;
}

onSetting(name, args, changedByScript)
{
    // For now we always have 0-1 arguments
    if(!isDefined(args) || (args.size > 1) || ((args.size == 0) && (level.settings[name].type != "bool")))
    {
        self sendLocalChatMessage("ERROR! Setting was called with unexpected args.size", true);
        return;
    }
    arg = args[0];

    setting = level.settings[name];

    update = false;
    newVal = undefined;
    switch(setting.type)
    {
        case "string":
        {
            if(arg.size < setting.minLen)
            {
                self sendLocalChatMessage("Length of argument " + arg + " is below minimum " + setting.minLen, true);
                return;
            }
            if(arg.size > setting.maxLen)
            {
                self sendLocalChatMessage("Length of argument " + arg + " is above maximum " + setting.minLen, true);
                return;
            }

            newVal = arg;
            update = true;
        } break;
        case "int":
        {
            if(!isValidInt(arg))
            {
                self sendLocalChatMessage("Argument " + arg + " is not a valid integer", true);
                return;
            }

            arg = int(arg);
            if(arg < setting.minVal)
            {
                self sendLocalChatMessage("Argument " + arg + " is below minimum " + setting.minVal, true);
                return;
            }
            if(arg > setting.maxVal)
            {
                self sendLocalChatMessage("Argument " + arg + " is above maximum " + setting.maxVal, true);
                return;
            }

            newVal = arg;
            update = true;
        } break;
        case "bool":
        {
            if(isDefined(arg))
            {
                if(!isValidBool(arg))
                {
                    self sendLocalChatMessage("Argument " + arg + " is not a valid bool", true);
                    return;
                }

                newVal = strToBool(arg);
            }
            else
            {
                newVal = !self.settingValues[name];
            }
            update = true;
        } break;
        case "float":
        {
            if(!isValidFloat(arg))
            {
                self sendLocalChatMessage("Argument " + arg + " is not a valid float", true);
                return;
            }

            arg = float(arg);
            if(arg < setting.minVal)
            {
                self sendLocalChatMessage("Argument " + arg + " is below minimum " + setting.minVal, true);
                return;
            }
            if(arg > setting.maxVal)
            {
                self sendLocalChatMessage("Argument " + arg + " is above maximum " + setting.maxVal, true);
                return;
            }

            newVal = arg;
            update = true;
        } break;
        default:
        {
            self sendLocalChatMessage("ERROR! Setting: " + name + " has invalid type: " + setting.type, true);
            return;
        }
    }

    if (!update)
    {
        // Some checks failed, not updating
        return;
    }

    // The setting may have an update func that can prevent the update (although it's typically used to update matching dvars or perform post-update actions)
    // This can be used, for example, to allow only certain values for a string setting.
    if (isDefined(setting.updateFunc))
    {
        result = self [[setting.updateFunc]](newVal);
        if (isDefined(result) && !result)
        {
            // Update func says no..
            return;
        }
    }

    // Update the setting!
    self.settingValues[name] = newVal;

    if (!isDefined(changedByScript) || !changedByScript)
    {
        self sendLocalChatMessage("Changed setting " + name + " to " + self.settingValues[name], false);
    }

    // Write updated setting to database
    self thread writePlayerSettingToDb(name, self.settingValues[name]);
}

addSettingString(name, minLen, maxLen, defaultVal, help, updateFunc)
{
    underlyingCmd = _createSetting(name, defaultVal, help, updateFunc, "string");
    if (isDefined(underlyingCmd))
    {
        level.settings[name].minLen = minLen;
        level.settings[name].maxLen = maxLen;
        return underlyingCmd;
    }

    return undefined;
}

addSettingInt(name, minVal, maxVal, defaultVal, help, updateFunc)
{
    underlyingCmd = _createSetting(name, defaultVal, help, updateFunc, "int");
    if (isDefined(underlyingCmd))
    {
        level.settings[name].minVal = minVal;
        level.settings[name].maxVal = maxVal;
        return underlyingCmd;
    }

    return undefined;
}

addSettingBool(name, defaultVal, help, updateFunc)
{
    underlyingCmd = _createSetting(name, defaultVal, help, updateFunc, "bool");
    if (isDefined(underlyingCmd))
    {
        return underlyingCmd;
    }

    return undefined;
}

addSettingFloat(name, minVal, maxVal, defaultVal, help, updateFunc)
{
    underlyingCmd = _createSetting(name, defaultVal, help, updateFunc, "float");
    if (isDefined(underlyingCmd))
    {
        level.settings[name].minVal = minVal;
        level.settings[name].maxVal = maxVal;
        return underlyingCmd;
    }

    return undefined;
}

_createSetting(name, defaultVal, help, updateFunc, typeStr)
{
    if(isDefined(level.settings[name]))
    {
        printf("WARN: Attempted to register the same setting twice: " + name + "\n");
        return undefined;
    }

    level.settings[name] = spawnStruct();
    level.settings[name].type = typeStr;
    level.settings[name].defaultVal = defaultVal;
    if(isDefined(updateFunc))
    {
        level.settings[name].updateFunc = updateFunc;
    }
    // For now these values are hardcoded
    // If we want to change this, just change the addSettingXXXX functions to accept the new parameters
    minAdminLevel = 0;
    maxArgs = 1;
    minArgs = 1;
    if(level.settings[name].type == "bool")
    {
        minArgs = 0;
    }
    cmd = openCJ\commands_base::registerCommand(name, help, undefined, minArgs, maxArgs, minAdminLevel, name);
    if(!isDefined(cmd))
    {
        level.settings[name] = undefined;
    }
    
    return cmd; // Return underlying command which contains the setting
}

writePlayerSettingToDb(setting, value)
{
    query = "CALL setPlayerSetting(" + self openCJ\login::getPlayerID() + ", '" + openCJ\mySQL::escapeString(setting) + "', '" + openCJ\mySQL::escapeString(value + "") + "')";
    printf("setPlayerSetting query:\n" + query + "\n"); // Debug
    self thread openCJ\mySQL::mysqlAsyncQueryNosave(query);
}
