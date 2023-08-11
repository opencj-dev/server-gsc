#include openCJ\util;

onInit()
{
    underlyingCmd = openCJ\settings::addSettingBool("speedometer", true, "Enable speedometer HUD", ::_onCommandSpeedometer);
    openCJ\commands_base::addAlias(underlyingCmd, "speedo");
}

_onCommandSpeedometer(newVal)
{
    self notify("disable_speedometer");
    if (newVal)
    {
        self.showSpeedometer = true;
        self thread _speedoMeter();
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
    self.maxSpeed = 0.0;
    self.currSpeed = 0.0;
    if (!isDefined(self.hudSpeed))
    {
        self.hudSpeed = [];
        self _initSpeedHud("curr", (1.0, 1.0, 1.0), -80);
        self _initSpeedHud("max", (1.0, 0.3, 0.3), -60); // Has to be above progress bar and time limit
    }
}

onStartDemo()
{
    self.hudSpeed["curr"].alpha = 0;
    self.hudSpeed["max"].alpha = 0;
}

onSpawnPlayer()
{
    self notify("disable_speedometer");
    self thread _speedoMeter();
}

onLoadPosition()
{
    self.maxSpeed = 0;
    self.currSpeed = 0;
}

onSavePosition()
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

_speedoMeter()
{
    level endon("map_ended");
    self endon("disconnect");
    self endon("disable_speedometer");

    if (!self.showSpeedometer)
    {
        return;
    }

    self.currSpeed = 0;
    self.maxSpeed = 0;
    self.hudSpeed["curr"] setValue(0);
    self.hudSpeed["max"] setValue(0);
    self _showSpeedometer();

    while(1)
    {
        if (!self isSpectator())
        {
            self.currSpeed = self _calc2DSpeed();
        }
        else
        {
            spectatorClient = self getSpectatorClient();
            if (isDefined(spectatorClient))
            {
                // Spectating someone (still calculate because they may have speedometer disabled and thus this thread won't run)
                self.currSpeed = spectatorClient _calc2DSpeed();
                self _showSpeedometer();
            }
            else
            {
                // Not spectating anyone
                self _hideSpeedometer();
            }
        }

        if (self.currSpeed > self.maxSpeed)
        {
            self.maxSpeed = self.currSpeed;
        }

        self.hudSpeed["curr"] setValue(self.currSpeed);
        self.hudSpeed["max"] setValue(self.maxSpeed);
        wait .05;
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
