#include openCJ\util;

onInit()
{
    underlyingCmd = openCJ\settings::addSettingBool("speedometer", true, "Enable speedometer HUD", ::_onCommandSpeedometer);
    openCJ\commands_base::addAlias(underlyingCmd, "speedo");
}

_onCommandSpeedometer(newVal)
{
    if (newVal)
    {
        self.showSpeedometer = true;
    }
    else
    {
        self.showSpeedometer = false;
        self _hideSpeedometer();
    }
}

onPlayerConnect()
{
    self.showSpeedometer = false;
    self _resetSpeed();
    if (!isDefined(self.hudSpeed))
    {
        self.hudSpeed = [];
        self _initSpeedHud("curr", (1.0, 1.0, 1.0), -80);
        self _initSpeedHud("max", (1.0, 0.3, 0.3), -60); // Has to be above progress bar and time limit
    }
}

onStartDemo()
{
    self _hideSpeedometer();
}

onSpawnPlayer()
{
    self _resetSpeed();
}

onLoadPosition()
{
    self _resetSpeed();
}

onSavePosition()
{
    self _resetSpeed();
}

_resetSpeed()
{
    self.maxSpeed = 0.0;
    self.currSpeed = 0.0;
}

_hideSpeedometer()
{
    self.hudSpeed["curr"].alpha = 0;
    self.hudSpeed["max"].alpha = 0;
}

_showSpeedometer()
{
    self.hudSpeed["curr"].alpha = 1;
    self.hudSpeed["max"].alpha = 1;
}

whileAlive()
{
    // If player doesn't have speedometer enabled, don't show it to them *or* their spectators
    if (!self.showSpeedometer)
    {
        spectatorsAndSelf = getSpectatorList(true); //  true -> include self
        for (i = 0; i < spectatorsAndSelf.size; i++)
        {
            player = spectatorsAndSelf[i];
            player _hideSpeedometer();
        }

        return;
    }

    self.currSpeed = self _calc2DSpeed();
    if (self.currSpeed > self.maxSpeed)
    {
        self.maxSpeed = self.currSpeed;
    }

    spectatorsAndSelf = getSpectatorList(true); //  true -> include self
    for (i = 0; i < spectatorsAndSelf.size; i++)
    {
        player = spectatorsAndSelf[i];

        player.hudSpeed["curr"] setValue(self.currSpeed);
        player.hudSpeed["max"] setValue(self.maxSpeed);
        player _showSpeedometer();
    }
}

_calc2DSpeed()
{
    vel = self getVelocity();
    speed2d = sqrt((vel[0] * vel[0]) + (vel[1] * vel[1]));
    return int(speed2d);
}

_initSpeedHud(name, colors, yOffset)
{
    if (!isDefined(self.hudSpeed[name]))
    {
        self.hudSpeed[name] = newClientHudElem(self);
        self.hudSpeed[name].alpha = 0;
        self.hudSpeed[name].foreground = true;
        self.hudSpeed[name].alignx = "center";
        self.hudSpeed[name].aligny = "bottom";
        self.hudSpeed[name].x = 0;
        self.hudSpeed[name].y = yOffset;
        self.hudSpeed[name].horzalign = "center";
        self.hudSpeed[name].vertalign = "bottom";
        self.hudSpeed[name].color = colors;
        self.hudSpeed[name].fontscale = 1.8;
        self.hudSpeed[name].archived = false;
        self.hudSpeed[name].hideWhenInMenu = true;
    }
}
