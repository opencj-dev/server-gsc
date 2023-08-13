#include openCJ\util;

onPlayerConnected()
{
    self thread _tryLogin();
    if(getCodVersion() == 4)
    {
        self openCJ\menus::openFPSUserinfoMenu();
    }
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

    loginSuccess = self _getPlayerInformation(uid);
    if(loginSuccess)
    {
        self thread openCJ\mySQL::mysqlAsyncQueryNosave("CALL setName(" + self.login_playerID + ", '" + openCJ\mySQL::escapeString(self.name) + "')");
        self openCJ\settings::loadSettingsFromDatabase();
    }
    else
    {
        printf("Creating new account for '" + self.name + "'\n"); // Debug
        self createNewAccount();
    }
}

_getPlayerInformation(uid)
{
    self endon("disconnect");
    if(!isDefined(uid))
    {
        return false;
    }

    query = "SELECT playerID, adminLevel, IF(mutedUntil < NOW(), NULL, TIMESTAMPDIFF(SECOND, NOW(), mutedUntil)) FROM playerInformation WHERE playerID = (SELECT getPlayerID(" + int(uid[0]) + ", " + int(uid[1])  + ", " + int(uid[2]) + ", " + int(uid[3]) + "))";
    printf("playerInformation query:\n" + query + "\n"); // Debug
    rows = self openCJ\mySQL::mysqlAsyncQuery(query);
    if(hasResult(rows))
    {
        self.login_playerID = int(rows[0][0]);
        self openCJ\commands_base::setAdminLevel(int(rows[0][1]));
        if(isDefined(rows[0][2])) //muted until [seconds] into future
        {
            self openCJ\chat::applyMute(true);
            self openCJ\chat::unmuteAfterTime(int(rows[0][2]));
        }
        return true;
    }
    else
    {
        return false;
    }
}

createNewAccount()
{
    self endon("disconnect");

    for(i = 0; i < 10; i++)
    {
        uid = [];
        for(j = 0; j < 4; j++)
        {
            uid[j] = createRandomInt();
        }

        query = "SELECT createNewAccount(" + uid[0] + ", " + uid[1] + ", " + uid[2] + ", " + uid[3] + ", '" + openCJ\mySQL::escapeString(self.name) + "')";
        printf("createNewAccount query:\n" + query + "\n"); // Debug
        rows = self openCJ\mySQL::mysqlAsyncQuery(query);
        if(hasResult(rows))
        {
            loginSuccess = self _getPlayerInformation(uid);
            if(loginSuccess)
            {
                self openCJ\loginHelper::storeUID(uid);
                self openCJ\settings::onNewAccount();
                self iprintlnbold("Welcome to OpenCJ!");
            }
            else
            {
                //this should not happen unless mysql server dies during these queries.
                self iprintlnbold("Cannot create an account right now. Please try reconnecting");
            }
            return;
        }
        else
        {
            printf("ERROR: Failed to create account\n");
        }
    }
    self iprintlnbold("Cannot create an account right now. Please try reconnecting");
}
