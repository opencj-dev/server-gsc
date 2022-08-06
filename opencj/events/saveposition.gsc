#include openCJ\util;

main()
{
	if(!self openCJ\login::isLoggedIn() || !self openCJ\playerRuns::hasRunID())
		return;

	error = self openCJ\savePosition::canSaveError();
	if(!error)
	{
		self openCJ\savePosition::setSavedPosition();
		self openCJ\savePosition::printSaveSuccess();
		self openCJ\statistics::onSavePosition();
	}
	else
		self openCJ\savePosition::printCanSaveError(error);
}