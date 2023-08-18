#include openCJ\util;

onPlayerConnect()
{
    self.country_connectMessageShown = false;
}

onPlayerConnected()
{
    self thread _countryQuery();
}

_countryQuery()
{
    self endon("disconnect");

    query = "SELECT getCountry(INET_ATON('" + openCJ\mySQL::escapeString(self getIP()) + "'))";
    printf("Country query:\n" + query + "\n"); // Debug

    rows = self openCJ\mySQL::mysqlAsyncQuery(query);
    if(isDefined(rows) && isDefined(rows[0]) && isDefined(rows[0][0]))
    {
        self.country = getSubStr(rows[0][0], 0, 2);
        self.longCountry = getSubStr(rows[0][0], 2);
    }
    else
    {
        self.country = "??";
        self.longCountry = "Unknown";
    }
    if(self openCJ\login::isLoggedIn())
    {
        self _doConnectMessage();
    }
}

onPlayerLogin()
{
    self _doConnectMessage();
}

_doConnectMessage()
{
    if(self.country_connectMessageShown)
    {
        return;
    }

    iprintln(self.name + "^7 connected from " + self getLongCountry());
}

getCountry()
{
    if(!isDefined(self.country))
    {
        return "??";
    }
    else
    {
        return self.country;
    }
}

getLongCountry()
{
    if(!isDefined(self.longCountry))
    {
        return "Unknown";
    }
    else
    {
        return self.longCountry;
    }
}