#include openCJ\util;

onInit()
{
	thread _getMessages();
	cmd = openCJ\commands_base::registerCommand("pm", "Send a pm to a player\nUsage: !pm [player] [message]", ::sendPM, 2, undefined, 0);
	openCJ\commands_base::addAlias(cmd, "whisper");
	openCJ\commands_base::addAlias(cmd, "message");
	openCJ\commands_base::registerCommand("mute", "Mute a player\nUsage: !mute [player] [time]\nTime is optional and formatted in either [m]inutes, [h]ours or [d]ays", ::mute, 1, 2, 0);
	openCJ\commands_base::registerCommand("unmute", "Unmute a player\nUsage: !unmute [player]", ::unmute, 1, 1, 0);
	cmd = openCJ\commands_base::registerCommand("ignore", "Temporarily ignore a specific player until map change. Usage: !ignore <playerName|playerId>", ::_onCommandIgnore, 1, 1, 0);
	openCJ\commands_base::addAlias(cmd, "tignore");
	cmd = openCJ\commands_base::registerCommand("pignore", "Permanently ignore a specific player. Usage: !pignore <playerName|playerId>", ::_onCommandPermIgnore, 1, 1, 0);
	openCJ\commands_base::addAlias(cmd, "pignore");

	cmd = openCJ\commands_base::registerCommand("unignore", "Unignore a player, regardless of whether the ignore was temporary or permanent. Usage: !unignore <playerName|playerId>", ::_onCommandUnIgnore, 1, 1, 0);
	openCJ\commands_base::addAlias(cmd, "tignore");
}


_onCommandIgnore(args)
{
	// !ignore <playerName>
	player = findPlayerByArg(args[0]);
	if(!isDefined(player))
	{
		self sendLocalChatMessage("Player " + args[0] + " not found", true);
		return;
	}
	
	if(player == self)
	{
		self sendLocalChatMessage("Cannot ignore self", true);
		return;
	}
	if(self isIgnoring(player))
	{
		self sendLocalChatMessage("Already ignoring " + player.name, true);
		return;
	}
	self addToIgnoreList(player openCJ\login::getPlayerID());
	self sendLocalChatMessage("Ignoring " + player.name, false);
}

_onCommandPermIgnore(args)
{
	// !pignore <playerName>
	player = findPlayerByArg(args[0]);
	if(!isDefined(player))
	{
		self sendLocalChatMessage("Player " + args[0] + " not found", true);
		return;
	}
	
	if(player == self)
	{
		self sendLocalChatMessage("Cannot ignore self", true);
		return;
	}
	ignoreID = player openCJ\login::getPlayerID();
	if(!self isIgnoring(player))
	{
		self addToIgnoreList(ignoreID);
	}
	self sendLocalChatMessage("Permanently ignoring " + player.name, false);
	self thread openCJ\mySQL::mysqlAsyncQueryNosave("INSERT IGNORE INTO playerIgnore (playerID, ignoreID) VALUES (" + self openCJ\login::getPlayerID() + ", " + ignoreID + ")");
}

_onCommandUnIgnore(args)
{
	// !pignore <playerName>
	player = findPlayerByArg(args[0]);
	if(!isDefined(player))
	{
		self sendLocalChatMessage("Player " + args[0] + " not found", true);
		return;
	}
	
	if(player == self)
	{
		self sendLocalChatMessage("Cannot unignore self", true);
		return;
	}
	ignoreID = player openCJ\login::getPlayerID();
	if(self isIgnoring(player))
	{
		self removeFromIgnoreList(ignoreID);
		self sendLocalChatMessage("Unignoring " + player.name, false);
		self thread openCJ\mySQL::mysqlAsyncQueryNosave("DELETE FROM playerIgnore WHERE playerID = " + self openCJ\login::getPlayerID() + " AND ignoreID = " + ignoreID);
	}
}

mute(args)
{
	// !mute <playerName> [time]
	player = findPlayerByArg(args[0]);
	if(!isDefined(player) || player isIgnoring(self))
	{
		self sendLocalChatMessage("Player " + args[0] + " not found", true);
		return;
	}
	
	if(player == self)
	{
		self sendLocalChatMessage("Cannot mute self", true);
		return;
	}
	time = undefined;
	if(isDefined(args[1]) && isValidInt(getsubstr(args[1], 0, args[1].size - 1)))
	{
		time = int(getsubstr(args[1], 0, args[1].size - 1));
		switch(args[1][args[1].size - 1])
		{
			case "d":
				time *= 24;
			case "h":
				time *= 60;
			case "m":
				time *= 60;
				break;
			default:
			{
				self sendLocalChatMessage("Incorrect time format given", true);
				return;
			}
		}
		if(time > 60 * 60 * 24 * 7)
		{
			self sendLocalChatMessage("Cannot mute for more than 7 days", true);
			return;
		}
		query = "UPDATE playerInformation SET mutedUntil = ADDTIME(NOW(), SEC_TO_TIME(" + time + ")) WHERE playerID = " + player openCJ\login::getPlayerID();
		printf(query + "\n");
		openCJ\mySQL::mysqlAsyncQueryNosave(query);
	}
	player setMuted(true);
	player unmuteAfterTime(time);
}

unmute(args)
{
	// !mute <playerName> [time]
	player = findPlayerByArg(args[0]);
	if(!isDefined(player) || player isIgnoring(self))
	{
		self sendLocalChatMessage("Player " + args[0] + " not found", true);
		return;
	}
	
	if(player == self)
	{
		self sendLocalChatMessage("Cannot unmute self", true);
		return;
	}
	query = "UPDATE playerInformation SET mutedUntil = NULL WHERE playerID = " + player openCJ\login::getPlayerID();
	printf(query + "\n");
	openCJ\mySQL::mysqlAsyncQueryNosave(query);
	player setMuted(false);
}

onPlayerConnect()
{
	self applyMute(false);
}

onPlayerLogin()
{
	self.ignoreList = [];
	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(players[i] openCJ\login::isLoggedIn())
		{
			if(players[i] isIgnoring(self))
			{
				players[i] openCJ\playerCollision::onIgnore(self);
			}
		}
	}
	self thread _fetchIgnoreList();
}

unmuteAfterTime(seconds)
{
	if(isDefined(seconds) && seconds > 0)
	{
		self thread _unmuteCountdown(seconds);
	}
}

applyMute(value)
{
	self openCJ\playerCollision::onMuteChanged(value);
	self.muted = value;
}

isMuted()
{
	return self.muted;
}

setMuted(value)
{

	if(value)
	{
		self iprintlnbold("You have been muted");
		self applyMute(value);
	}
	else
	{
		self notify("unmuteCountdown");
		self iprintlnbold("You have been unmuted");
		self applyMute(value);
	}
}

_unmuteCountdown(seconds)
{
	self endon("disconnect");
	self notify("unmuteCountdown");
	self endon("unmuteCountdown");
	wait seconds;
	self setMuted(false);
}

_fetchIgnoreList()
{
	self endon("disconnect");

	// Retrieve the player's ignore list
	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT ignoreID FROM playerIgnore WHERE playerID = " + self openCJ\login::getPlayerID());
	for(i = 0; i < rows.size; i++)
	{
		self addToIgnoreList(int(rows[i][0]));
	}
}

removeFromIgnoreList(playerID)
{
	for(i = 0; i < self.ignoreList.size; i++)
	{
		if(self.ignoreList[i] == playerID)
		{
			player = getPlayerByPlayerID(playerID);
			if(isDefined(player))
			{
				self openCJ\playerCollision::onUnIgnore(player);
			}
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
		player = getPlayerByPlayerID(playerID);
		if(isDefined(player))
		{
			self openCJ\playerCollision::onIgnore(player);
		}
		self.ignoreList[self.ignoreList.size] = playerID;
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
	if(self isMuted())
	{
		self sendLocalChatMessage("You are currently muted", true);
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
	if(self isMuted())
	{
		self sendLocalChatMessage("You are currently muted", true);
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
