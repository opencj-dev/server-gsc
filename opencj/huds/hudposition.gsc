#include openCJ\util;

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
        self _initPosHud("angle", rgb, startX + (3 * spaceBetween));
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
    if (getCodVersion() == 4) // For CoD4 elevators we want a more accurate position
    {
        // Remove the actual coordinates, for elevating just need the decimals
        // If we don't do this, then the decimals don't always show up when calling setValue
        org = fixDecimals(org, 7, false);
    }
    else
    {
        org = (int(org[0]), int(org[1]), int(org[2]));
    }
    self.hudPos["x"] setValue(org[0]);
    self.hudPos["y"] setValue(org[1]);
    self.hudPos["z"] setValue(org[2]);
    self.hudPos["angle"] setValue(self getPlayerAngles()[1]);
}

_setPosHudAlpha(val)
{
    self.hudPos["x"].alpha = val;
    self.hudPos["y"].alpha = val;
    self.hudPos["z"].alpha = val;
    self.hudPos["angle"].alpha = val;
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
        self.hudPos[name].hideWhenInMenu = true;
    }
}
