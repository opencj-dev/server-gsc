#include openCJ\util;

onPlayerConnected()
{
	self thread _tryLogin();
}

onPlayerCommand(args)
{
	return self openCJ\loginHelper::onPlayerCommand(args);
}

isLoggedIn()
{
	return isDefined(self.login_playerID);
}

getPlayerID()
{
	return self.login_playerID;
}

_tryLogin()
{
	self endon("disconnect");

	uid = self openCJ\loginHelper::requestUID();
	successfulLogin = validateLogin(uid);
	if(successfulLogin)
	{
		return true;
	}

	printf("Creating new account for '" + self.name + "'\n");
	uid = self createNewAccount();
	return self validateLogin(uid);
}

validateLogin(uid)
{
	self endon("disconnect");

	if(!isDefined(uid) || (uid.size != 4))
	{
		printf("Player has no or invalid UID\n");
		return false;
	}

	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT getPlayerID(" + int(uid[0]) + ", " + int(uid[1])  + ", " + int(uid[2]) + ", " + int(uid[3]) + ", '" + openCJ\mySQL::escapeString(self.name) + "')");
	if(!hasResult(rows))
	{
		printf("No login found for player\n");
		return false;
	}
	else
	{
		self.login_playerID = int(rows[0][0]);
		self openCJ\events\playerLogin::main();
		//self openCJ\menus::openIngameMenu();
		return true;
	}
}

createNewAccount()
{
	self endon("disconnect");

	for(i = 0; i < 10; i++)
	{
		uid = [];
		for(j = 0; j < 4; j++)
			uid[j] = createRandomInt();

		rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT createNewAccount(" + uid[0] + ", " + uid[1] + ", " + uid[2] + ", " + uid[3] + ")");
		if(hasResult(rows))
		{
			self openCJ\loginHelper::storeUID(uid);
			self iprintlnbold("Welcome to OpenCJ!");
			return uid;
		}
		else
		{
			printf("Failed to create account\n");
		}
	}
	self iprintlnbold("Cannot create an account right now. Please try reconnecting");
	return undefined;
}
