#include openCJ\util;

main()
{
	printf("userinfo changed\n");
	self openCJ\playerNames::onUserInfoChanged();
	self openCJ\events\fpsChange::onUserInfoChanged();
	self clientUserInfoChanged();
}