#include openCJ\util;

onInit()
{
	openCJ\commands::registerCommand("speedmode", "Used to enable/disable speed mode\nUsage: !speedmode [on/off]", ::speedMode);
	level.speedMode["normal"] = 190;
	level.speedMode["speed"] = 210;
}

onRunIDCreated()
{
	self.speedMode = false;
	self.speedModeEver = false;
}

speedMode(args)
{
	value = args[2];
	if(value == "on" || value == "off")
	{
		self _setSpeedMode(value == "on");
	}
	else
		self iprintln(level.commands_commands[args[1]].help);
}

setSpeedMode(value)
{
	if(value == self.speedMode)
		return;
	self.speedMode = value;
	if(self.speedMode)
	{
		self.speedModeEver = true;
		self setClientCvar("g_speed", level.speedMode["normal"]);
		self set_g_speed(level.speedMode["normal"]);
	}
	else
	{
		self setClientCvar("g_speed", level.speedMode["speed"]);
		self set_g_speed(level.speedMode["speed"]);
	}
}

hasSpeedMode()
{
	return self.speedMode;
}

hasSpeedModeEver()
{
	return self.speedModeEver;
}