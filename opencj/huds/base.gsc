
onPlayerConnect()
{
    self.hud = [];
}

isHUDEnabled(name)
{
    return (isDefined(self.hud[name]) && isDefined(self.hud[name].alpha) && (self.hud[name].alpha > 0));
}

enableHUD(name)
{
	if(isDefined(self.hud[name]))
	{
		self.hud[name].alpha = 1;
	}
}

disableHUD(name)
{
	if(isDefined(self.hud[name]))
	{
		self.hud[name].alpha = 0;
	}
}

// Valid options
// alignX: left,   center, right
// alignY: bottom, middle, top
// hAlign: center_safearea
// vAlign: center_safearea

initInfiniteHUD(name, x, y, alignX, alignY, hAlign, vAlign, foreground, font, hideInMenu, color, glowColor, glowAlpha, fontScale, archived, alpha)
{
	if(isDefined(self.hud[name]))
	{
		return;
	}
	self.hud[name] = self openCJ\huds\infiniteHuds::createInfiniteStringHud(name);
	self _initHUDBase(name, x, y, alignX, alignY, hAlign, vAlign, foreground, font, hideInMenu, color, glowColor, glowAlpha, fontScale, archived, alpha);
}

initRegularHUD(name, x, y, alignX, alignY, hAlign, vAlign, foreground, font, hideInMenu, color, glowColor, glowAlpha, fontScale, archived, alpha)
{
	if(isDefined(self.hud[name]))
	{
		return;
	}

    self.hud[name] = newClientHudElem(self);
	self _initHUDBase(name, x, y, alignX, alignY, hAlign, vAlign, foreground, font, hideInMenu, color, glowColor, glowAlpha, fontScale, archived, alpha);
}

_initHUDBase(name, x, y, alignX, alignY, hAlign, vAlign, foreground, font, hideInMenu, color, glowColor, glowAlpha, fontScale, archived, alpha)
{
    self.hud[name].x = x;
    self.hud[name].y = y;
    if(isDefined(hAlign))
    {
        self.hud[name].horzAlign = hAlign;
    }
    if(isDefined(vAlign))
    {
        self.hud[name].vertAlign = vAlign;
    }
    if(isDefined(alignX))
    {
        self.hud[name].alignX = alignX;
    }
    if(isDefined(alignY))
    {
        self.hud[name].alignY = alignY;
    }
    if(isDefined(foreground))
    {
        self.hud[name].foreground = foreground;
    }
    if(isDefined(font))
    {
        self.hud[name].font = font;
    }
    if(isDefined(hideInMenu))
    {
        self.hud[name].hideWhenInMenu = hideInMenu;
    }
    if(isDefined(color))
    {
        self.hud[name].color = color;
    }
    if(isDefined(glowColor))
    {
        self.hud[name].glowColor = glowColor;
    }
    if(isDefined(glowAlpha))
    {
        self.hud[name].glowAlpha = glowAlpha;
    }
    if(isDefined(fontScale))
    {
        self.hud[name].fontScale = fontScale;
    }
    if(isDefined(archived))
    {
        self.hud[name].archived = archived;
    }
    if(isDefined(alpha))
    {
        self.hud[name].alpha = alpha;
    }
}