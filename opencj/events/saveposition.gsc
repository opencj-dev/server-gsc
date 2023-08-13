#include openCJ\util;

main() // Not threaded as it returns a result
{
    if(!self openCJ\login::isLoggedIn())
    {
        return undefined;
    }

    saveNum = self openCJ\savePosition::setSavedPosition();
    self openCJ\savePosition::resetBackwardsCount();
    self openCJ\savePosition::printSaveSuccess();

    self thread openCJ\huds\hudSpeedometer::onSavePosition();

    return saveNum;
}