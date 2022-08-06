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

stopFollowingMe()
{
	//stub for cod4 related stuff
}