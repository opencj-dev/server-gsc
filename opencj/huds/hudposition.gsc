onPlayerConnect()
{
    if (!isDefined(self.hudPos))
    {
        self.hudPos = [];

        self _initPosHud("x", (0.1, 0.6, 1.0), 2);
		self _initPosHud("y", (0.1, 0.6, 1.0), 22);
		self _initPosHud("z", (0.1, 0.6, 1.0), 42);
    }
}

onStartDemo()
{
	self _setPosHudAlpha(0);
}

onSpawnPlayer()
{
    self thread _updatePos();
}

onSpawnSpectator()
{
	self _setPosHudAlpha(0);
}

_updatePos()
{
    level endon("map_ended");
    self endon("disconnect");
	self endon("joined_spectators");

    self _setPosHudAlpha(1);

    while(1)
    {
        self _updatePosHudValues();
        wait .05;
    }
}

_updatePosHudValues()
{
	org = self getOrigin();
	self.hudPos["x"] setValue(org[0]);
	self.hudPos["y"] setValue(org[1]);
	self.hudPos["z"] setValue(org[2]);
}

_setPosHudAlpha(val)
{
    self.hudPos["x"].alpha = val;
	self.hudPos["y"].alpha = val;
	self.hudPos["z"].alpha = val;
}

_initPosHud(name, colors, yOffset)
{
    if (!isDefined(self.hudPos[name]))
    {
        self.hudPos[name] = newClientHudElem(self);
        self.hudPos[name].alpha = 0;
        self.hudPos[name].foreground = true;
        self.hudPos[name].alignx = "left";
        self.hudPos[name].aligny = "top";
        self.hudPos[name].x = 115; // To the right of minimap
        self.hudPos[name].y = yOffset;
        self.hudPos[name].horzalign = "left";
        self.hudPos[name].vertalign = "top";
        self.hudPos[name].color = colors;
        self.hudPos[name].fontscale = 1.6;
        self.hudPos[name].archived = false;
    }
}
