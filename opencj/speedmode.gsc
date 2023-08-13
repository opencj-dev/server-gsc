#include openCJ\util;

onInit()
{
    level.speedMode["normal"] = 190;
    level.speedMode["maxspeed"] = 500;
    level.speedMode["minspeed"] = 1;

    // Don't add alias speed because it can be confusing compared to speedometer
    cmd = openCJ\commands_base::registerCommand("speedmode", "Used to enable/disable speed mode. Usage: !speedmode [<value>|off]", ::speedMode, 0, 1, 0);
}

_runChanged()
{
    self.speedModeNow = undefined;
    self.speedModeEver = false;
    self setSpeedMode(false);
}

onRunCreated()
{
    _runChanged();
}

onRunRestored()
{
    _runChanged();
}

speedMode(args)
{
    if(self openCJ\demos::isPlayingDemo())
    {
        return;
    }
    wasEverEnabled = self getSpeedModeEver();
    wasEnabled = self getSpeedModeNow();
    shouldEnable = false;
    if(args.size == 0)
    {
        shouldEnable = !wasEnabled;
    }
    else
    {
        value = args[0];
        if(isValidBool(value))
        {
            shouldEnable = strToBool(value);
        }
        else if(isValidInt(value))
        {
            speed = int(value);
            if (speed > level.speedMode["maxspeed"])
            {
                speed = level.speedMode["maxspeed"];
            }
            else if (speed < level.speedMode["minspeed"])
            {
                speed = level.speedMode["minspeed"];
            }

            self.speedModeSpeed = speed;
            shouldEnable = true;
            wasEnabled = false; // We want to re-enable with higher speed
        }
        else
        {
            self sendLocalChatMessage("Argument " + value + " is not a bool or integer", true);
            return;
        }
    }

    if(shouldEnable && !wasEnabled)
    {
        if (getCodVersion() == 4)
        {
            // For CoD4, speed mode is not a separate category but is just cheating
            self openCJ\cheating::setCheating(true);
        }
        self setSpeedMode(true);
        self applySpeedMode();
        self sendLocalChatMessage("Speed mode on");
    }
    else if (!shouldEnable && wasEnabled)
    {
        self setSpeedMode(false);
        self applySpeedMode();
        self sendLocalChatMessage("Speed mode off");
        if (wasEverEnabled && (getCodVersion() == 4))
        {
            self sendLocalChatMessage("History load back until cheating flag is gone, or !reset");
        }
    }
}

setSpeedModeEver(value)
{
    self.speedModeEver = value;
}

setSpeedMode(value)
{
    if(isDefined(self.speedModeNow) && (value == self.speedModeNow))
    {
        return;
    }

    self.speedModeNow = value;
    if(self.speedModeNow)
    {
        self.speedModeEver = true;
    }
}

getSpeedModeNow()
{
    return self.speedModeNow;
}

getSpeedModeEver()
{
    return self.speedModeEver;
}

applySpeedMode()
{
    if(!isDefined(self.speedModeSpeed))
    {
        self.speedModeSpeed = level.speedMode["maxspeed"];
    }

    if(self.speedModeNow)
    {
        self setClientCvar("g_speed", self.speedModeSpeed);
        self setg_speed(self.speedModeSpeed);
    }
    else
    {
        self setClientCvar("g_speed", level.speedMode["normal"]);
        self setg_speed(level.speedMode["normal"]);
    }
}

hasSpeedMode()
{
    return self.speedModeNow;
}

hasSpeedModeEver()
{
    return self.speedModeEver;
}
