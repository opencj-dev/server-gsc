onPlayerConnect()
{
    self.maxSpeed = 0.0;
    self.currSpeed = 0.0;
    if (!isDefined(self.hudSpeed))
    {
        self.hudSpeed = [];
        self _initSpeedHud("curr", (1.0, 1.0, 1.0), -30);
        self _initSpeedHud("max", (1.0, 0.3, 0.3), -10); // Has to be above progress bar
    }
}

onStartDemo()
{
    self.hudSpeed["curr"].alpha = 0;
    self.hudSpeed["max"].alpha = 0;
}

onSpawnPlayer()
{
    self thread _speedoMeter();
}

onSpawnSpectator()
{
    self.hudSpeed["curr"].alpha = 0;
    self.hudSpeed["max"].alpha = 0;
}

onLoadPosition()
{
    self.maxSpeed = 0;
    self.currSpeed = 0;
}

_speedoMeter()
{
    level endon("map_ended");
    self endon("disconnect");
    self endon("joined_spectators");

    self.currSpeed = 0;
    self.maxSpeed = 0;
    self.hudSpeed["curr"] setValue(0);
    self.hudSpeed["max"] setValue(0);
    self.hudSpeed["curr"].alpha = 1;
    self.hudSpeed["max"].alpha = 1;

    while(1)
    {
        self.currSpeed = self _calc2DSpeed();
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
    }
}
