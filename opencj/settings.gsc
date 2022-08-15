#include openCJ\util;

onInit()
{
	level.settings = [];
}

onPlayerConnect()
{
	printf("Clearing settings\n\n\n\n");
	self.settings = [];
	settings = getArrayKeys(level.settings);
	for(i = 0; i < settings.size; i++)
		self.settings[settings[i]] = level.settings[settings[i]].defaultVal;
}

setting_createNewInt(name, min, max, defaultVal)
{
	setting = spawnStruct();
	setting.type = "int";
	setting.min = min;
	setting.max = max;
	setting.defaultVal = defaultVal;
	level.settings[name] = setting;
}

setting_createNewString(name, defaultVal)
{
	setting = spawnStruct();
	setting.type = "string";
	setting.defaultVal = defaultVal;
	level.settings[name] = setting;
}

setting_createNewFloat(name, min, max, defaultVal)
{
	setting = spawnStruct();
	setting.type = "float";
	setting.min = min;
	setting.max = max;
	setting.defaultVal = defaultVal;
	level.settings[name] = setting;
}

setting_set(name, value)
{
	if(!isDefined(level.settings[name]))
		return undefined;
	if(!isDefined(value))
		return undefined;
	if(level.settings[name].type == "string")
	{
		self.settings[name] = value;
		return value;
	}
	else if(level.settings[name].type == "int")
	{
		val = int(value);
		if(val == 0 && value + "" != "0")
			return undefined;
		self.settings[name] = val;
		return val;
	}
	else if(level.settings[name].type == "float")
	{
		val = float(value);
		if(val == 0 && value + "" != "0")
			return undefined;
		self.settings[name] = val;
		return val;
	}
	return undefined;
}

setting_get(name)
{
	if(!isDefined(level.settings[name]))
		return undefined;
	return self.settings[name];
}