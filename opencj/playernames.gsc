#include openCJ\util;

onPlayerLogin()
{
	self.oldName = self.name;
	self.forcedName = undefined;
}

onUserInfoChanged()
{
	if(!self openCJ\login::isLoggedIn())
		return;
	newName = self getuserinfo("name");
	if(newName == self.oldName)
		return;
	if(isDefined(self getForcedName()) && newName != self getForcedName())
	{
		self renameClient(self getForcedName());
		self setClientCvar("name", self getForcedName());
		return;
	}
	self thread _storeNewName(newName);
}

_storeNewName(newName)
{
	self notify("storeNewName");
	self endon("storeNewName");
	self endon("disconnect");
	wait 5;
	self openCJ\mySQL::mysqlAsyncQueryNosave("CALL setName(" + self openCJ\login::getPlayerID() + ", '" + openCJ\mySQL::escapeString(newName) + "')");
}

getForcedName()
{
	return self.forcedName;
}

setForcedName(forcedName)
{
	if(!self openCJ\login::isLoggedIn())
		return;
	if(isDefined(forcedName))
	{
		self thread openCJ\mySQL::mysqlAsyncQueryNosave("CALL setName(" + self openCJ\login::getPlayerID() + ", '" + openCJ\mySQL::escapeString(forcedName) + "')");
		self renameClient(forcedName);
		self setClientCvar("name", forcedName);
	}
	self.forcedName = forcedName;
}