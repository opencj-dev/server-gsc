#include openCJ\util;

onInit()
{
    level.settings = [];
}

areSettingsLoaded()
{
	return self.settingsLoaded;
}

onCompletedInit() // Called after all onInit functions have been called
{
    // At this point all settings will have been added, and no precaches will be done anymore
    keys = getArrayKeys(level.settings);
    for(i = 0; i < keys.size; i++)
    {
        name = keys[i];
        id = writeGlobalSettingToDb(name);
        level.settings[name].id = id;
        //printf("Setting id for setting " + name + " to " + id + "\n");
    }
}

onPlayerConnect()
{
    self.settingValues = [];
    self.settingsLoaded = false;
    self setDefaultSettings();
}

onPlayerLogin()
{
    self restoreSettings();
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

restoreSettings()
{
    self endon("disconnect");

    keys = getArrayKeys(level.settings);
    for(i = 0; i < keys.size; i++)
    {
        name = keys[i];
        value = self getPlayerSettingFromDb(name);
        if(isDefined(value))
        {
            self.settingValues[name] = value;
            if(isDefined(level.settings[name].updateFunc))
            {
                self [[level.settings[name].updateFunc]](value);
            }
        }
        else
        {
            // Default value already filled in on connect
        }
    }
    self.settingsLoaded = true;
}

setSetting(name, val)
{
    if(!isDefined(level.settings[name]))
    {
        return false;
    }

    args = [];
    args[0] = val;
    onSetting(name, args);
    return true;
}

getSetting(name)
{
    return self.settingValues[name];
}

onSetting(name, args)
{
    // For now we always have 1 argument
    if(!isDefined(args) || (args.size != 1))
    {
        self sendLocalChatMessage("ERROR! Setting was called with args.size != 1", true);
        return;
    }
    arg = args[0];

    setting = level.settings[name];
    if(!isDefined(setting) || !isDefined(setting.id))
    {
        self sendLocalChatMessage("ERROR! Setting is not defined, but it is... how?", true);
        return;
    }

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

            self.settingValues[name] = arg;
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

            self.settingValues[name] = arg;
        } break;
        case "bool":
        {
            if(!isValidBool(arg))
            {
                self sendLocalChatMessage("Argument " + arg + " is not a valid bool", true);
                return;
            }

            self.settingValues[name] = strToBool(arg);
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

            self.settingValues[name] = arg;
        } break;
        default:
        {
            self sendLocalChatMessage("ERROR! Setting: " + name + " has invalid type: " + setting.type, true);
            return;
        }
    }

    // If a setting was changed, check if a dvar needs to be changed with it etc
    if(isDefined(setting.updateFunc))
    {
        self [[setting.updateFunc]](self.settingValues[name]);
    }

    // Update setting in database
    self thread writePlayerSettingToDb(level.settings[name], self.settingValues[name]);
    return;
}

addSettingString(name, minLen, maxLen, defaultVal, help, updateFunc)
{
    underlyingCmd = _createSetting(name, defaultVal, help, updateFunc);
    if (isDefined(underlyingCmd))
    {
        level.settings[name].type = "string";
        level.settings[name].minLen = minLen;
        level.settings[name].maxLen = maxLen;
        return underlyingCmd;
    }

    return undefined;
}

addSettingInt(name, minVal, maxVal, defaultVal, help, updateFunc)
{
    underlyingCmd = _createSetting(name, defaultVal, help, updateFunc);
    if (isDefined(underlyingCmd))
    {
        level.settings[name].type = "int";
        level.settings[name].minVal = minVal;
        level.settings[name].maxVal = maxVal;
        return underlyingCmd;
    }

    return undefined;
}

addSettingBool(name, defaultVal, help, updateFunc)
{
    underlyingCmd = _createSetting(name, defaultVal, help, updateFunc);
    if (isDefined(underlyingCmd))
    {
        level.settings[name].type = "bool";
        return underlyingCmd;
    }

    return undefined;
}

addSettingFloat(name, minVal, maxVal, defaultVal, help, updateFunc)
{
    underlyingCmd = _createSetting(name, defaultVal, help, updateFunc);
    if (isDefined(underlyingCmd))
    {
        level.settings[name].type = "float";
        level.settings[name].minVal = minVal;
        level.settings[name].maxVal = maxVal;
        return underlyingCmd;
    }

    return undefined;
}

_createSetting(name, defaultVal, help, updateFunc)
{
    if(isDefined(level.settings[name]))
    {
        printf("WARN: Attempted to register the same setting twice: " + name + "\n");
        return undefined;
    }

    level.settings[name] = spawnStruct();
    level.settings[name].defaultVal = defaultVal;
    if(isDefined(updateFunc))
    {
        level.settings[name].updateFunc = updateFunc;
    }
    // For now always minArgs=maxArgs=1
    // For now always minAdminLevel=0
    // If we want to change this, just change the addSettingXXXX functions to accept the new parameters
    cmd = openCJ\commands_base::registerCommand(name, help, undefined, 1, 1, 0, name);
    if(!isDefined(cmd))
    {
		level.settings[name] = undefined;
	}
    
    return cmd; // Return underlying command which contains the setting
}

getGlobalSettingIdFromDb(name)
{
    query = "SELECT settingID FROM settings WHERE settingName = '" + name + "'";
    rows = openCJ\mySQL::mysqlAsyncQuery(query);
    if(hasResult(rows) && isValidInt(rows[0][0]))
    {
        return int(rows[0][0]);
    }

    return undefined; // Setting not found
}

writeGlobalSettingToDb(name)
{
    // Check if this is a new setting that should be added to the database
    id = getGlobalSettingIdFromDb(name);
    if(!isDefined(id))
    {
        // Unknown setting, so insert it into the database
        query = "INSERT INTO settings (settingName) VALUES ('" + name + "')";
        openCJ\mySQL::mysqlAsyncQuery(query);

        // Now the settingId needs to be obtained, and since we use various threads for mySQL we shouldn't trust on last inserted id
        id = getGlobalSettingIdFromDb(name);
    }

    return id;
}

getPlayerSettingFromDb(name)
{
    if(!isDefined(name))
    {
        return undefined;
    }

    value = undefined;
    query = "SELECT " + level.settings[name].type + "Value FROM playerSettings WHERE playerID = " + self openCJ\login::getPlayerID() + " AND settingID = " + level.settings[name].id;
    switch(level.settings[name].type)
    {
        case "string":
        {
            rows = openCJ\mySQL::mysqlAsyncQuery(query);
            if(hasResult(rows))
            {
                value = rows[0][0];
            }
        } break;
        case "int":
        {
            rows = openCJ\mySQL::mysqlAsyncQuery(query);
            if(hasResult(rows))
            {
                if(isValidInt(rows[0][0]))
                {
                    value = int(rows[0][0]);
                }
                else
                {
                    printf("ERROR! Not a valid int: '" + rows[0][0] + "' for setting " + name + "\n");
                }
            }
        } break;
        case "bool":
        {
            rows = openCJ\mySQL::mysqlAsyncQuery(query);
            if(hasResult(rows))
            {
                if(isValidBool(rows[0][0]))
                {
                    value = strToBool(rows[0][0]);
                }
                else
                {
                    printf("ERROR! Not a valid bool: '" + rows[0][0] + "' for setting " + name + "\n");
                }
            }
        } break;
        case "float":
        {
            rows = openCJ\mySQL::mysqlAsyncQuery(query);
            if(hasResult(rows))
            {
                if(isValidFloat(rows[0][0]))
                {
                    value = float(rows[0][0]);
                }
                else
                {
                    printf("ERROR! Not a valid float: '" + rows[0][0] + "' for setting " + name + "\n");
                }
            }
        } break;
        default:
        {
            printf("ERROR! Unknown settings type: " + level.settings[name].type + "\n");
        }
    }

    return value;
}

writePlayerSettingToDb(setting, value)
{
    playerId = self openCJ\login::getPlayerID();

    valColumnName = setting.type + "Value"; // i.e. boolValue
    query = "INSERT INTO playerSettings (playerID, settingID, " + valColumnName + ") VALUES (" +
            playerId + ", " + setting.id + ", " + value + ") ON DUPLICATE KEY UPDATE " + valColumnName + " = " + value;
    //printf(query + "\n");
    rows = openCJ\mySQL::mysqlAsyncQuery(query);
}
