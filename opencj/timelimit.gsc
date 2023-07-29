#include openCJ\util;

onInit()
{
    level.timeLimit = getCvarInt("scr_cj_timelimit");
    if (!isDefined(level.timeLimit) || (level.timeLimit <= 0))
    {
        level.timeLimit = 60;
    }
    level.remainingTime = level.timeLimit * 60;
    level.gameEnded = false;
    level.clock = spawn("script_origin", (0, 0, 0)); // Will be used to play a sound

    thread loop();
}

loop()
{
    level endon("game_ended");

    while (1)
    {
        wait 1.0;
        if (level.gameEnded)
        {
            break;
        }

        level.remainingTime -= 1;
        if (level.remainingTime <= 0)
        {
            level.gameEnded = true;
            level notify("game_ended");
        }
        else if ((level.remainingTime <= 10) || ((level.remainingTime <= 30) && (level.remainingTime % 2) == 0)) // Every 2 seconds from 30 seconds, every second from 10 seconds
        {
            level.clock playSound("ui_mp_timer_countdown");
        }
    }
}

addTimeMinutes(val) // Not called yet until vote extend time is implemented
{
    if (!level.gameEnded) // Otherwise it's too late
    {
        level.remainingTime += (val * 60);
    }
}

setGameEnded() // Not called yet until vote extend time is implemented
{
    if (!level.gameEnded)
    {
        level.remainingTime = 1; // Will trigger end game next frame
    }
}