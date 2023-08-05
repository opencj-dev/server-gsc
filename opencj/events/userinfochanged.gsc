#include openCJ\util;

main()
{
	self openCJ\playerNames::onUserInfoChanged();
	self openCJ\events\fpsChange::onUserInfoChanged();
	self clientUserInfoChanged();
}