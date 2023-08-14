// For each player, we remember the FPS they have used this jump.
// When a spectator starts spectating the player, they will see this FPS (history).

#include openCJ\util;

onInit()
{
    level.fpsHistoryHudName = "fpshistory";
    openCJ\huds\infiniteHuds::initInfiniteHud(level.fpsHistoryHudName);
}

onPlayerConnect()
{
    self.fpshistory = [];
    self.fpsHistoryText = "";

    //                                        name                     x  y   alignX   alignY hAlign     vAlign
    self openCJ\huds\base::initInfiniteHUD(level.fpsHistoryHudName,    0, -85, "center", "middle", "center_safearea", "center_safearea",
    //  foreground  font        hideInMenu    color                glowColor    glowAlpha    fontScale    archived    alpha
        true,        "default",    undefined,    (0.8, 0.8, 0.8),    undefined,    undefined,    1.5,        false,    0);
}

onSpectatorClientChanged(newClient)
{
    if (!isDefined(newClient) || (newClient openCJ\demos::isPlayingDemo()))
    {
        // Not spectating anyone anymore
        self hideAndClearFPSHistory();
        //todo: show demo also to this client? So, show demo fpshistory also to this client?
    }
    else
    {
        self.hud[level.fpsHistoryHudName] openCJ\huds\infiniteHuds::setInfiniteHudText(newclient.fpsHistoryText, self, false);
        self openCJ\huds\base::enableHUD(level.fpsHistoryHudName);
    }
}

onSpawnSpectator()
{
    self hideAndClearFPSHistory();
}

onSpawnPlayer()
{
    self hideAndClearFPSHistory();
}

hideAndClearFPSHistory()
{
    self openCJ\huds\base::disableHUD(level.fpsHistoryHudName);
    self _clearFPSHistory();
}

// The following functions are for the player performing the jump

onFPSChanged(newFPS)
{
    if(self openCJ\demos::isPlayingDemo())
    {
        return;
    }

    self notify("fpshistory_fpschanged");
    shortFPS = openCJ\fps::getShortFPS(newFPS);

    if (!self isOnGround())
    {
        self _addFPSHistory(shortFPS);
    }

    self.fpshistory["shortfps"] = shortFPS;
}

onBounced()
{
    if(self openCJ\demos::isPlayingDemo())
    {
        return;
    }
    self thread _onBouncedThread();
}

_onBouncedThread()
{
    self endon("disconnect");
    if (self.fpsHistoryText != "")
    {
        self _addFPSHistory("-");
        self endon("fpshistory_fpschanged");
        self endon("fpshistory_clear");
        wait 0.15;
        self _addFPSHistory(openCJ\fps::getShortFPS(self openCJ\fps::getCurrentFPS()));
    }
}

onStartDemo()
{
    self _clearFPSHistory();
}

onLoaded()
{
    if(self openCJ\demos::isPlayingDemo())
    {
        return;
    }

    self _clearFPSHistory();
}

onOnGround(isOnGround)
{
    if(self openCJ\demos::isPlayingDemo())
    {
        return;
    }
    self thread _onOnGroundThread(isOnGround);
}

_onOnGroundThread(isOnGround)
{
    self endon("disconnect");
    self notify("fpshistory_ongroundchange");
    self endon("fpshistory_ongroundchange");

    if (isOnGround)
    {
        wait 2; // Keep specFPS HUD for 2 seconds after landing
        self _clearFPSHistory();
    }
    else
    {
        if(self openCJ\events\onGroundChanged::getLastGroundEnterTime() < getTime() - 250)
        {
            // No longer onGround, so show the initial FPS
            self _setFPSHistory(openCJ\fps::getShortFPS(self openCJ\fps::getCurrentFPS()));
        }
        else
        {
            self _onBhopThread();
        }
    }
}

_onBhopThread()
{
    if (self.fpsHistoryText != "")
    {
        self _addFPSHistory("/");
        self endon("fpshistory_fpschanged");
        self endon("fpshistory_clear");
        wait 0.15;
        self _addFPSHistory(openCJ\fps::getShortFPS(self openCJ\fps::getCurrentFPS()));
    }
}

_clearFPSHistory()
{
    self notify("fpshistory_clear");
    self.fpsHistoryText = "";

    spectators = self getSpectatorList(false);
    for (i = 0; i < spectators.size; i++)
    {
        spectators[i].fpsHistoryText = "";
        spectators[i] openCJ\huds\base::disableHUD(level.fpsHistoryHudName);
    }
}

_addFPSHistory(text)
{
    self _setFPSHistory(self.fpsHistoryText + text);
}

_setFPSHistory(text)
{
    if(self openCJ\demos::isPlayingDemo())
    {
        return;
    }

    if (self.fpsHistoryText == text)
    {
        return; // Already set
    }

    if((text.size <= 1) && (self.fpsHistoryText != ""))
    {
        return;
    }
    self.fpsHistoryText = text;

    if (self.sessionState == "playing")
    {
        spectators = self getSpectatorList(false);
        for (i = 0; i < spectators.size; i++)
        {
            spectators[i].hud[level.fpsHistoryHudName] openCJ\huds\infiniteHuds::setInfiniteHudText(text, spectators[i], false);
            spectators[i] openCJ\huds\base::enableHUD(level.fpsHistoryHudName);
        }
    }
}

_setDemoFPSHistory(text)
{
    if (self.fpsHistoryText == text)
    {
        return; // Already set
    }

    self.fpsHistoryText = text;
    if(text.size <= 1)
    {
        return;
    }
    self.hud[level.fpsHistoryHudName] openCJ\huds\infiniteHuds::setInfiniteHudText(text, self, false);
    self openCJ\huds\base::enableHUD(level.fpsHistoryHudName);
}

_clearDemoFPSHistory()
{
    self notify("fpshistory_clear");
    self.fpsHistoryText = "";
    self.fpsHistoryText = "";
    self openCJ\huds\base::disableHUD(level.fpsHistoryHudName);
}

onDemoBounce(text)
{
    self thread _onDemoBounceThread(text);
}

_onDemoBounceThread(text)
{
    self endon("disconnect");
    if (self.fpsHistoryText != "")
    {
        self addDemoFPSHistory("-");
        self endon("fpshistory_fpschanged");
        self endon("fpshistory_clear");
        wait 0.15;
        self addDemoFPSHistory(text);
    }
}

onDemoLand()
{
    self thread _onDemoLandThread();
}

_onDemoLandThread()
{
    self endon("disconnect");
    self notify("fpshistory_ongroundchange");
    self endon("fpshistory_ongroundchange");
    wait 2; // Keep specFPS HUD for 2 seconds after landing
    self _clearDemoFPSHistory();
}

onDemoLeaveGround(text)
{
    self notify("fpshistory_ongroundchange");
    clearAndSetDemoFPS(text);
}

clearAndSetDemoFPS(text)
{
    self _clearDemoFPSHistory();
    self _setDemoFPSHistory(text);
}

addDemoFPSHistory(text)
{
    if(self.fpsHistoryText.size > 0 && self.fpsHistoryText[self.fpsHistoryText.size - 1] == text)
    {
        return;
    }
    self _setDemoFPSHistory(self.fpsHistoryText + text);
}
