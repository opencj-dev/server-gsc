#include openCJ\util;

onPlayerConnect()
{
    self.grenadeTimers = [];
}

onGrenadeThrow(nade, name)
{
    self thread _showNadeTimer();
}

onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
    self removeNadeTimers();
}

onSpawnPlayer()
{
    self removeNadeTimers();
}

_showNadeTimer()
{
    self endon("disconnect");
    self endon("stopNadeTimer");

    newIdx = self.grenadeTimers.size;
    name = "grenadeTimer" + newIdx;

    nadeTimer = newClientHudElem(self);
    nadeTimer.horzAlign = "left";
    nadeTimer.vertAlign = "top";
    nadeTimer.alignX = "left";
    nadeTimer.alignY = "top";
    nadeTimer.x = 20;
    nadeTimer.y = 40 + 10 * self.grenadeTimers.size;
    nadeTimer.fontScale = 1;
    nadeTimer.alpha = 1;
    nadeTimer.archived = true;
    nadeTimer setTenthsTimer(3.45);

    self.grenadeTimers[self.grenadeTimers.size] = nadeTimer;

    // Loop until the timer has expired
    for(t = 0; t < 70; t++) // 70 * 0.05 = 3.5
    {
        if(t < 35)
        {
            nadeTimer.color = (t / 35, 1, 0);
        }
        else
        {
            nadeTimer.color = (1, 1 - ((t - 35) / 35), 0);
        }
        wait 0.05;
    }

    // Now that the nade timer has expired, remove it from the list
    // Gotta re-find it though, since the list could have changed during the wait period
    ownNum = self.grenadeTimers.size - 1;
    for(i = 0; i < self.grenadeTimers.size; i++)
    {
        if(self.grenadeTimers[i] != nadeTimer)
        {
            // Since we're destroying a nade timer, let other nade timers fill in the space
            if(self.grenadeTimers[i].y > nadeTimer.y)
            {
                self.grenadeTimers[i].y -= 10;
            }
        }
        else
        {
            // Found the right nade timer in the potentially changed list
            ownNum = i;
        }
    }

    // Re-use the slot for the last nade timer so we don't have an ever-expanding array size
    self.grenadeTimers[ownNum] = self.grenadeTimers[self.grenadeTimers.size - 1];
    self.grenadeTimers[self.grenadeTimers.size - 1] = undefined;

    // Destroy the expired nade timer
    nadeTimer destroy();
}

removeNadeTimers()
{
    self notify("stopNadeTimer");
    for(i = 0; i < self.grenadeTimers.size; i++)
    {
        self.grenadeTimers[i] destroy();
    }
    for(i = i - 1; i >= 0; i--)
    {
        self.grenadeTimers[i] = undefined;
    }
}