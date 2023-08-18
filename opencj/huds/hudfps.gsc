#include openCJ\util;

onInit()
{
    // TODO: expand command so each HUD can be enabled/disabled
    underlyingCmd = openCJ\settings::addSettingBool("fpshud", false, "Turn on/off FPS hud. Usage: !fpshud [on/off]", ::_onFPSHudSetting);
    openCJ\huds\infiniteHuds::initInfiniteHud("fps");
}

onPlayerConnect()
{
    self.fpsHudName = "fps";
    //                                     name             x        y    alignX         alignY    hAlign        vAlign
    self openCJ\huds\base::initInfiniteHUD(self.fpsHudName, -5,     0,    "right",    "top",    "right",    "top",
    //    foreground    font        hideInMenu   color            glowColor                        glowAlpha  fontScale  archived alpha
        undefined,    "default",    true,        (1.0, 1.0, 1.0), ((20/255), (33/255), (125/255)), 0.1,       1.4,       false,   0);
}

onFPSChanged(newFPS)
{
    newFPSText = "" + newFPS;
    if (self.sessionState == "playing")
    {
        specsAndSelf = self getSpectatorList(true);
        for(i = 0; i < specsAndSelf.size; i++)
        {
            specsAndSelf[i].hud[specsAndSelf[i].fpsHudName] openCJ\huds\infiniteHuds::setInfiniteHudText(newFPSText, specsAndSelf[i], false);
        }
    }
    else if (self.classname == "player") // Gets called early, need to check before setting the text otherwise it won't show by the time you spawn in
    {
        self.hud[self.fpsHudName] openCJ\huds\infiniteHuds::setInfiniteHudText(newFPSText, self, false);
    }
}

onSpectatorClientChanged(newClient)
{
    if(isDefined(newClient))
    {
        currentFPSText = "" + newClient openCJ\fps::getCurrentFPS();
    }
    else //free spec
    {
        currentFPSText = "" + self openCJ\fps::getCurrentFPS();
    }
    self.hud[self.fpsHudName] openCJ\huds\infiniteHuds::setInfiniteHudText(currentFPSText, self, false);
}

onSpawnPlayer()
{
    currentFPSText = "" + self openCJ\fps::getCurrentFPS();
    self.hud[self.fpsHudName] openCJ\huds\infiniteHuds::setInfiniteHudText(currentFPSText, self, false);
}

_onFPSHudSetting(newVal)
{
    shouldEnable = (newVal > 0);

    if(shouldEnable)
    {
        self setClientCvar("cg_drawfps", 0);
        currentFPSText = "" + self openCJ\fps::getCurrentFPS();
        self.hud[self.fpsHudName] openCJ\huds\infiniteHuds::setInfiniteHudText(currentFPSText, self, false);
        self openCJ\huds\base::enableHUD(self.fpsHudName);
    }
    else
    {
        self setClientCvar("cg_drawfps", 1);
        self openCJ\huds\base::disableHUD(self.fpsHudName);
    }
}
