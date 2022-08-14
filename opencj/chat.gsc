#include openCJ\util;

onInit()
{
	thread _getMessages();
	openCJ\commands::registerCommand("pm", "Send a pm to a player\nUsage: !pm [player] [message]", ::sendPM);
}

onPlayerLogin()
{
	self thread _getIgnores();
}

_getIgnores()
{
	self.ignoreList = [];
	self endon("disconnect");
	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT ignoreID FROM playerIgnore WHERE playerID = " + self openCJ\login::getPlayerID());
	for(i = 0; i < rows.size; i++)
		self.ignoreList[self.ignoreList.size] = int(rows[i][0]);
}

_getMessages(previousMessageID)
{
	if(!isDefined(previousMessageID))
	{
		rows = openCJ\mySQL::mysqlAsyncQuery("SELECT MAX(messageID) FROM messages");
		if(isDefined(rows[0][0]))
			previousMessageID = rows[0][0];
	}
	else
	{
		players = getEntArray("player", "classname");
		rows = openCJ\mySQL::mysqlAsyncQuery("SELECT a.messageID, b.playerName, a.message, a.ignoredBy, a.server FROM (SELECT messageID, playerID, message, getIgnoredBy(playerID) ignoredBy, server FROM messages WHERE SERVER != '" + openCJ\mySQL::escapeString(getServerName()) + "' AND messageID > " + previousMessageID + ") a INNER JOIN playerInformation b ON a.playerID = b.playerID");
		for(i = 0; i < rows.size; i++)
		{
			name = rows[i][1];
			msg = rows[i][2];
			ignoredBy = rows[i][3];
			server = rows[i][4];
			if(isDefined(ignoredBy))
				ignoreList = strtok(ignoredBy, ",");
			else
				ignoreList = [];
			for(j = 0; j < players.size; j++)
			{
				ignored = false;
				for(k = 0; k < ignoreList.size; k++)
				{
					if(players[j] openCJ\login::getPlayerID() == int(ignoreList[k]))
					{
						ignored = true;
						break;
					}
				}
				if(!ignored)
					players[j] SV_GameSendServerCommand("h \"[" + server + "]" + name + ":^7 " +  msg + "\"", true);
			}
		}
		if(rows.size)
			previousMessageID = rows[rows.size - 1][0];
	}
	wait 0.5;
	thread _getMessages(previousMessageID);
}

onChatMessage(args)
{
	//say and say_team have identical behavior
	if(!self openCJ\login::isLoggedIn())
		return;
	msg = "";
	for(i = 1; i < args.size; i++)
		msg += args[i] + " ";
	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(!players[i] openCJ\login::isLoggedIn())
			continue;
		if(players[i] isIgnoring(self))
			continue;
		players[i] SV_GameSendServerCommand("h \"" + self.name + ":^7 " +  msg + "\"", true); //last arg is reliablemsg yes/no
		thread openCJ\mySQL::mysqlAsyncQueryNosave("INSERT INTO messages (playerID, message, server) VALUES (" + self openCJ\login::getPlayerID() + ", '" + openCJ\mySQL::escapeString(msg) + "', '" + openCJ\mySQL::escapeString(getServerName()) + "')");
	}	
}

isIgnoring(player)
{
	playerID = player openCJ\login::getPlayerID();
	for(i = 0; i < self.ignoreList.size; i++)
	{
		if(self.ignoreList == playerID)
			return true;
	}
	return false;
}

getServerName()
{
	return "cod" + getCvarInt("codversion") + " " + getCvarInt("net_port"); //placeholder
}

sendPM(args)
{
	if(args.size > 3 && isDefined(args[2]))
	{
		player = findPlayerByArg(args[2]);
		if(!isDefined(player) || player isIgnoring(self))
			return;
		if(player == self)
		{
			self iprintln("Cannot pm self");
			return;
		}
		message = args[3];
		for(i = 4; i < args.size; i++)
			message += " " + args[i];
		player SV_GameSendServerCommand("h \"[pm]" + self.name + ":^7 " + message + "\"", true);
	}

}