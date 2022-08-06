#include openCJ\util;

onPlayerConnect()
{
	self.country_country = undefined;
	self.country_connectMessageShown = false;
	self thread _countryQuery();
}

_countryQuery()
{
	self endon("disconnect");
	printf(self.name + " getting country\n");
	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT getCountry(INET_ATON('" + openCJ\mySQL::escapeString(self getIP()) + "'))");
	if(rows.size && isDefined(rows[0][0]))
		self.country_country = rows[0][0];
	else
		self.country_country = "??";
	if(self openCJ\login::isLoggedIn())
		self _doConnectMessage();
}

onPlayerLogin()
{
	self _doConnectMessage();
}

_doConnectMessage()
{
	if(self.country_connectMessageShown)
		return;

	iprintln(self.name + "^7 connected from " + getLongCountryName(self getCountry()));
}

getCountry()
{
	if(!isDefined(self.country_country))
		return "??";
	else
		return self.country_country;
}

getLongCountryName(shortCountryName)
{
	switch(shortCountryName)
	{
		case "NL":
			return "The Netherlands";
		default:
			return shortCountryName;
	}
}