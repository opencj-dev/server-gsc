#include openCJ\util;

main()
{
	if(!self openCJ\login::isLoggedIn() || !self openCJ\playerRuns::hasRunID())
		return undefined;

	saveNum = self openCJ\savePosition::setSavedPosition();
	self openCJ\savePosition::printSaveSuccess();
	return saveNum;
}