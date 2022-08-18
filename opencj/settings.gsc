#include openCJ\util;

onInit()
{
    level.settings = [];
}

onPlayerConnect()
{
    self setDefaultSettings();
}

getSetting(name)
{
    return self.settings[name];
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
    if(!isDefined(setting))
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

            self.settings[name] = arg;
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

            self.settings[name] = arg;
        } break;
        case "bool":
        {
            if(!isValidBool(arg))
            {
                self sendLocalChatMessage("Argument " + arg + " is not a valid bool", true);
                return;
            }

            self.settings[name] = strToBool(arg);
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

            self.settings[name] = arg;
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
        self [[setting.updateFunc]](self.settings[name]);
    }

    return;
}

setDefaultSettings()
{
    if(!isDefined(self.settings))
    {
        self.settings = [];
    }

	keys = getArrayKeys(level.settings);
	for(i = 0; i < keys.size; i++)
    {
		self.settings[keys[i]] = level.settings[keys[i]].defaultVal;
    }
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
        printf("Attempted to register the same setting twice: " + name + "\n");
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
    cmd = openCJ\commands_base::registerCommand(name, help, undefined, 1, 1, 0, level.settings[name]);
    
    return cmd; // Return underlying command which contains the setting
}