// For each player, we remember the FPS they have used this jump.
// When a spectator starts spectating the player, they will see this FPS (history).

#include openCJ\util;

onInit()
{
    openCJ\infiniteHuds::initInfiniteHud("fpshistory");
}

// The following functions are for the spectator who is spectating a player

onPlayerConnect()
{
    if (!isDefined(self.fpshistory))
    {
        self.fpshistory = [];
        self.fpshistory["text"] = "";
        self.fpshistory["shortfps"] = "?";
    }

    if (!isDefined(self.fpshistory["hud"]))
    {
        self.fpshistory["hud"] = self openCJ\infiniteHuds::createInfiniteStringHud("fpshistory");
        self.fpshistory["hud"].alpha = 0;
        self.fpshistory["hud"].foreground = true;
        self.fpshistory["hud"].alignx = "center";
        self.fpshistory["hud"].aligny = "top";
        self.fpshistory["hud"].x = 0;
        self.fpshistory["hud"].y = 0;
        self.fpshistory["hud"].horzalign = "center_safearea";
        self.fpshistory["hud"].vertalign = "center_safearea";
        self.fpshistory["hud"].color = (0.8, 0.8, 0.8);
        self.fpshistory["hud"].fontscale = 1.5;
    }
}

onSpectatorClientChanged(newClient)
{
    if (!isDefined(newClient))
    {
        // Not spectating anyone anymore
        self.fpshistory["hud"].alpha = 0;
    }
    else
    {
        self _setFPSHistory(newClient.fpshistory["text"]);
        self.fpshistory["hud"].alpha = 1;
    }
}

onSpawnSpectator()
{
    self.fpshistory["hud"].alpha = 0; // Not spectating anyone by default
    self _clearFPSHistory();
}

hideAndClearFPSHistory()
{
    self.fpshistory["hud"].alpha = 0;
    self _clearFPSHistory();
}

// The following functions are for the player performing the jump

onFPSChanged(newFPS)
{
    self notify("fpshistory_fpschanged");
    shortFPS = undefined;
    switch (newFPS)
    {
        case 125:  shortFPS = "1"; break;
        case 142:  shortFPS = "4"; break;
        case 167:  shortFPS = "6"; break;
        case 200:  shortFPS = "0"; break;
        case 250:  shortFPS = "2"; break;
        case 333:  shortFPS = "3"; break;
        case 500:  shortFPS = "5"; break;
        case 1000: shortFPS = "K"; break;
        default:   shortFPS = "?"; break;

    }

    if (!self isOnGround())
    {
        self _addFPSHistory(shortFPS);
    }

    self.fpshistory["shortfps"] = shortFPS;
}

onBounced() // threaded
{
    if (self.fpshistory["text"] != "")
    {
        self _addFPSHistory("-");
        self endon("fpshistory_fpschanged");
        self endon("fpshistory_clear");
        self notify("fpshistory_updated");
        wait .15;
        self _addFPSHistory(self.fpshistory["shortfps"]);
    }
}

onLoaded()
{
    self _clearFPSHistory();
}

onOnGround(isOnGround) // threaded
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
        // No longer onGround, so show the initial FPS
        self _setFPSHistory(self.fpshistory["shortfps"]);
    }
}

_clearFPSHistory()
{
    self notify("fpshistory_clear");
    self.fpshistory["text"] = "";

    spectators = self getSpectatorList(false);
    for (i = 0; i < spectators.size; i++)
    {
        printf("Hiding FPS history for spec: " + spectators[i].name + "\n");
        spectators[i].fpshistory["hud"].alpha = 0;
    }
}

_addFPSHistory(text)
{
    _setFPSHistory(self.fpshistory["text"] + text);
}

_setFPSHistory(text)
{
    self notify("fpshistory_updated");

    if (self.fpshistory["text"] == text) return; // Already set

    self.fpshistory["text"] = text;
    spectators = self getSpectatorList(false);
    for (i = 0; i < spectators.size; i++)
    {
        spectators[i].fpshistory["hud"] openCJ\infiniteHuds::setInfiniteHudText(text, spectators[i], false);
        spectators[i].fpshistory["hud"].alpha = 1;
    }

    //self iprintln("Setting fps history to: " + text + " for " + self getEntityNumber());
}