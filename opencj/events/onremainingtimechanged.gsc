#include openCJ\util;

main()
{
    // No arguments as time variables are stored in:
    // level.timeLimit
    // level.startTime

    for(i = 0; i < players.size; i++)
    {
        players[i] thread openCJ\huds\hudTimeLimit::onRemainingTimeChanged(); // To update player timeLimit HUD
    }
}