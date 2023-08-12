#include openCJ\util;

main(prevRemainingTime)
{
    // Always call this thread to update time limit colors and value
    thread openCJ\huds\hudTimeLimit::onRemainingTimeChanged();

    // Only call the following threads if time increased
    if (prevRemainingTime < level.remainingTimeSeconds)
    {
        thread openCJ\vote::onRemainingTimeIncreased();
    }
}