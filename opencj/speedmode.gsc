#include openCJ\util;

onInit()
{
	openCJ\commands::registerCommand("speedmode", "Used to enable/disable speed mode\nUsage: !speedmode [on/off]", ::speedMode);
	level.speedMode["normal"] = 190;
	level.speedMode["speed"] = 500;
}

onRunIDCreated()
{
	self.speedMode = undefined;
	self.speedModeEver = false;
	self setSpeedMode(false);
}

speedMode(args)
{
	value = args[2];
	if(value == "on" || value == "off")
	{
		self setSpeedMode(value == "on");
		self applySpeedMode();
	}
	else
		self iprintln(level.commands_commands[args[1]].help);
}

setSpeedModeEver(value)
{
	self.speedModeEver = value;
}

setSpeedMode(value)
{
	if(isDefined(self.speedMode) && value == self.speedMode)
		return;
	self.speedMode = value;
	if(self.speedMode)
		self.speedModeEver = true;
}

applySpeedMode()
{
	if(self.speedMode)
	{
		self setClientCvar("g_speed", level.speedMode["speed"]);
		self setg_speed(level.speedMode["speed"]);
	}
	else
	{
		self setClientCvar("g_speed", level.speedMode["normal"]);
		self setg_speed(level.speedMode["normal"]);
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
