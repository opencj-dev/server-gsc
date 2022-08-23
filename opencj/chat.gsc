#include openCJ\util;

onInit()
{
	thread _getMessages();
	cmd = openCJ\commands_base::registerCommand("pm", "Send a pm to a player\nUsage: !pm [player] [message]", ::sendPM);
	openCJ\commands_base::addAlias(cmd, "whisper");
	openCJ\commands_base::addAlias(cmd, "message");
}

onPlayerLogin()
{
	self.ignoreList = [];
	self thread _fetchIgnoreList();
}

_fetchIgnoreList()
{
	self endon("disconnect");

	// Retrieve the player's ignore list
	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT ignoreID FROM playerIgnore WHERE playerID = " + self openCJ\login::getPlayerID());
	for(i = 0; i < rows.size; i++)
	{
		self.ignoreList[self.ignoreList.size] = int(rows[i][0]);
	}
}

removeFromIgnoreList(playerID)
{
	for(i = 0; i < self.ignoreList.size; i++)
	{
		if(self.ignoreList[i] == playerID)
		{
			self.ignoreList[i] = self.ignoreList[self.ignoreList.size - 1];
			self.ignoreList[self.ignoreList.size - 1] = undefined;
			return true;
		}
	}
	return undefined;
}

addToIgnoreList(playerID)
{
	if(!isInArray(playerID, self.ignoreList))
	{
		self.ignoreList[self.ignoreList.size] = PlayerID;
		return true;
	}
	return false;
}

_getMessages(previousMessageID) // CSC: Get player messages from servers that are not the current server
{
	if(!isDefined(previousMessageID))
	{
		// Initially, function is called without argument, so obtain last messageID
		rows = openCJ\mySQL::mysqlAsyncQuery("SELECT MAX(messageID) FROM messages");
		if(isDefined(rows[0][0]))
		{
			previousMessageID = rows[0][0];
		}
	}
	else
	{
		// Every subsequent call to this function will only obtain any new messages (from other servers)
		players = getEntArray("player", "classname");
		rows = openCJ\mySQL::mysqlAsyncQuery("SELECT a.messageID, b.playerName, a.message, a.ignoredBy, a.server FROM (SELECT messageID, playerID, message, getIgnoredBy(playerID) ignoredBy, server FROM messages WHERE SERVER != '" + openCJ\mySQL::escapeString(getServerName()) + "' AND messageID > " + previousMessageID + ") a INNER JOIN playerInformation b ON a.playerID = b.playerID");
		for(i = 0; i < rows.size; i++)
		{
			name = rows[i][1];
			msg = rows[i][2];
			ignoredByCsv = rows[i][3];
			server = rows[i][4];
			ignoredByList = undefined;

			// The sender may or may not be ignored by anyone
			ignoredByListInt = [];
			if(isDefined(ignoredByCsv))
			{
				ignoredByListString = strtok(ignoredByCsv, ",");
				ignoredByListInt = StringArrayToIntArray(ignoredByListString);
			}

			// This message will have to be sent to all players in this server..
			for(j = 0; j < players.size; j++)
			{
				// ..unless the player is ignoring the sender
				playerId = players[j] openCJ\login::getPlayerID();
				if(!isInArray(ignoredByListInt, playerId))
				{
					players[i] sendChatMessage("[" + server + "]" + name + ":^7 " +  msg);
				}
			}
		}

		// If we got a result, set the message's id as the latest id that has been processed
		if(rows.size > 0)
		{
			previousMessageID = rows[rows.size - 1][0];
		}
	}

	// Throttle CSC polling to 0.5 seconds plus exec time of query
	wait 0.5;

	// And do the whole thing again!
	thread _getMessages(previousMessageID);
}

onChatMessage(args)
{
	//say and say_team have identical behavior
	if(!self openCJ\login::isLoggedIn())
	{
		// No chatting until logged in (automatic process)
		return;
	}

	// Build the message (without the 'say' / 'say_team')
	msg = "";
	for(i = 1; i < args.size; i++)
	{
		msg += args[i] + " ";
	}

	// Direct the message to other players, keeping  in mind ignore, mute ..
	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(!players[i] openCJ\login::isLoggedIn())
		{
			// Don't direct messages to any non-logged in players
			continue;
		}

		if(players[i] isIgnoring(self))
		{
			// Don't direct messages to any players who are ignoring this player
			continue;
		}

		// Send the message
		if(self.pers["team"] == "spectator")
		{
			players[i] sendChatMessage("(Spectator)" + self.name + "^7: " + msg);
		}
		else
		{
			players[i] sendChatMessage(self.name + "^7: " + msg);
		}
	}

	// Save into database for cross-server chat
	thread openCJ\mySQL::mysqlAsyncQueryNosave("INSERT INTO messages (playerID, message, server) VALUES (" + self openCJ\login::getPlayerID() + ", '" + openCJ\mySQL::escapeString(msg) + "', '" + openCJ\mySQL::escapeString(getServerName()) + "')");
}

isIgnoring(player)
{
	playerID = player openCJ\login::getPlayerID();
	for(i = 0; i < self.ignoreList.size; i++)
	{
		if(self.ignoreList[i] == playerID)
		{
			return true;
		}
	}
	return false;
}

getServerName()
{
	return "cod" + getCvarInt("codversion") + " " + getCvarInt("net_port"); //placeholder
}

sendPM(args)
{
	// !pm <playerName> <message> [message] [message] ..
	player = findPlayerByArg(args[0]);
	if(!isDefined(player) || player isIgnoring(self))
	{
		self sendLocalChatMessage("Player " + args[0] + " not found or they are ignoring you", true);
		return;
	}
	
	if(player == self)
	{
		self sendLocalChatMessage("Cannot pm self", true);
		return;
	}

	// Construct the entire message as it may have spaces
	message = args[1];
	for(i = 2; i < args.size; i++)
	{
		message += " " + args[i];
	}

	// Send the message to the player, but also let the sender view their message back
	self sendChatMessage("[you->^5" + stripcolors(player.name) + "^7]: " + message);
	player sendChatMessage("[^5" + stripcolors(self.name) + "^7->you]: ^5" + message);
}
