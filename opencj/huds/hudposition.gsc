onPlayerConnect()
{
    if (!isDefined(self.hudPos))
    {
        self.hudPos = [];

        rgb = (0.8, 0.8, 0.8);
        spaceBetween = 20;
        startX = 6;
        self _initPosHud("x", rgb, startX);
        self _initPosHud("y", rgb, startX + spaceBetween);
        self _initPosHud("z", rgb, startX + (2 * spaceBetween));
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

_fixDecimals(org)
{
    fixedOrg = [];
    scale = 10000;
    for(i = 0; i < 3; i++)
    {
        // Remove the actual coordinates, for elevating just need the decimals
        // If we don't do this, then the decimals don't always show up when calling setValue
        fixedOrg[i] = abs(org[i] - int(org[i]));

        // Round to 4 decimals
        tmp = int(fixedOrg[i] * scale);
        fixedOrg[i] = float(tmp) / scale;
    }

    return fixedOrg;
}

_updatePosHudValues()
{
    org = self getOrigin();
    if (getCodVersion() == 4) // For CoD4 elevators we want a more accurate position
    {
        org = _fixDecimals(org);
    }
    else
    {
        org = (int(org[0]), int(org[1]), int(org[2]));
    }
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
        self.hudPos[name].fontscale = 1.4;
        self.hudPos[name].archived = false;
    }
}
