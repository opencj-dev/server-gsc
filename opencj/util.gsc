execClientCmd(cmd)
{
	self setClientCvar("openCJ_clientcmd", cmd);
	self openMenu(level.menu["clientcmd"]);
	self closeMenu();
}

getSpectatorList(includeSelf)
{
	players = getEntArray("player", "classname");
	ret = [];
	if(includeSelf)
		ret[ret.size] = self;
	for(i = 0; i < players.size; i++)
	{
		if(!isDefined(players[i] getSpectatorClient()))
			continue;
		if(players[i] getSpectatorClient() == self)
			ret[ret.size] = players[i];
	}
	return ret;
}

intOrUndefined(value)
{
	if(!isDefined(value))
		return undefined;
	return int(value);
}

stopFollowingMe()
{
	//stub for cod4 related stuff
}

formatTimeString(timems, roundSeconds)
{
	hours = int(timems / 1000 /3600);
	timems -= hours * 1000 * 3600;
	minutes = int(timems / 1000 / 60);
	timems -= minutes * 1000 * 60;
	seconds = int(timems / 1000);
	timems -= seconds * 1000;
	timestring = "";
	if(hours)
	{
		timestring += hours + ":";
		if(minutes < 10)
			timestring += "0";
	}
	timestring += minutes + ":";
	if(seconds < 10)
		timestring += "0";
	timestring += seconds;
	if(!roundSeconds)
	{
		if(timems < 10)
			timeString += ".00" + timems;
		else if(timems < 100)
			timeString += ".0" + timems;
		else
			timeString += "." + timems;
	}
	return timestring;
}

deleteOnEvent(event, entity)
{
	entity waittill(event);
	if(isDefined(self))
		self delete();
}