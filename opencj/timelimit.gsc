#include openCJ\util;

onInit()
{
    timeLimitMinutes = getCvarInt("scr_cj_timelimit");
    if (isDefined(timeLimitMinutes) && (timeLimitMinutes > 0))
    {
        level.timeLimitSeconds = (timeLimitMinutes * 60);
    }
    else
    {
        level.timeLimitSeconds = (60 * 60);
    }
    level.startTimeMs = getTime();
    level.remainingTimeSeconds = level.timeLimitSeconds;

    level.clock = spawn("script_origin", (0, 0, 0)); // Will be used to play a sound

    thread loop();
}

addTimeSeconds(seconds)
{
    level.timeLimitSeconds += seconds;
    thread opencj\events\onRemainingTimeChanged::main();
}

muteTimerSound(mute)
{
    level.muteTimerSound = mute;
}

loop()
{
    hasTimeExpired = false;
    hasVotedAutoExtend = false;
    while (1)
    {
        remainingTimeMs = getRemainingTimeMs();
        level.remainingTimeSeconds = int(remainingTimeMs / 1000);
        if (remainingTimeMs <= 0)
        {
            // If no time left, inform other scripts
            if (!hasTimeExpired)
            {
                level thread opencj\events\onTimeLimitReached::main();
                hasTimeExpired = true;
            }
            wait .05;
            continue; // Refresh the variables
        }

        // Auto extend time vote
        if (!hasVotedAutoExtend && (level.remainingTimeSeconds < (5 * 60)))
        {
            self openCJ\vote::queueAutoExtendVote();
            hasVotedAutoExtend = true;
        }

        hasTimeExpired = false;

        timeLeftFloat = (remainingTimeMs / 1000);
        timeLeftRounded = int(timeLeftFloat + 0.5);

        level notify("second_passed", timeLeftRounded);

        if ((timeLeftRounded <= 10) || ((timeLeftRounded <= 30) && (timeLeftRounded % 2) == 0)) // Every 2 seconds from 30 seconds, every second from 10 seconds
        {
            // For map vote we change time limit but don't want to spam the sound
            if (!isDefined(level.muteTimerSound) || !level.muteTimerSound)
            {
                level.clock playSound("ui_mp_timer_countdown");
            }
        }

        // Remain synchronous with actual time
        syncTimeDiff = timeLeftFloat - int(timeLeftFloat);
        if (syncTimeDiff >= 0.5)
        {
            syncTimeDiff -= 1.0; // Don't want to wait 2 seconds, instead just wait less
        }
        wait 1.0 + synctimeDiff;
    }
}

getRemainingTimeMs()
{
    return (level.timeLimitSeconds * 1000) - getTimePassedMs();
}

getTimePassedMs()
{
    return (getTime() - level.startTimeMs);
}
