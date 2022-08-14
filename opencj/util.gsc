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

findPlayerByArg(string)
{
	//assumes you'd rather call a player by its name than by its entitynumber
	//doesnt check for entitynumber at all atm
	if(!isDefined(string))
		return undefined;
	string = stripcolors(tolower(string));

	tmp = "";
	for(i = 0; i < string.size; i++)
	{
		if(isint(string[i]))
			tmp += string[i];
		else
		{
			if(string[i] != " ")
			tmp = "";
			break;
		}
	}
	players = getentarray("player", "classname");
	if(tmp != "")
	{
		for(i = 0; i < players.size; i++)
		{
			if(!isdefined(players[i].izno) || !isdefined(players[i].izno["login_completed"]))
				continue;
			if(players[i] getentitynumber() == int(tmp))
				return players[i];
		}
	}

	BONUS_FOR_CHARS_IN_ORDER = 50;
	BONUS_CORRECT_CHAR = 25;
	BONUS_FOR_COMPLETE = 200;
	best_player = undefined;

	best_score = 0;

	for(i = 0; i < players.size; i++)
	{
		score = 0;
		previous_correct_char = -1;
		name = stripcolors(tolower(players[i].name));
		found = false;
		for(j = 0; j < name.size - string.size + 1; j++)
		{
			tmp = getsubstr(name, j, j + string.size);
			if(tmp == string)
			{
				score += (BONUS_FOR_CHARS_IN_ORDER + BONUS_CORRECT_CHAR) * string.size + BONUS_FOR_COMPLETE;
				found = true;
				break;
			}
		}
		if(!found)
		{
			used = [];
			for(j = 0; j < name.size; j++)
			{
				for(k = 0; k < string.size; k++)
				{
					if(isdefined(used[k]))
						continue;
					if(name[j] == string[k])
					{
						used[k] = true;
						if(j == previous_correct_char + 1)
							score += BONUS_FOR_CHARS_IN_ORDER;
						previous_correct_char = j;
						score += BONUS_CORRECT_CHAR;
					}
				}
			}
		}
		if(score > best_score)
		{
			best_score = score;
			best_player = players[i];
		}
		else if(score == best_score)
			best_player = undefined;
	}
	if(isdefined(best_player))
	{
		if(best_score > BONUS_CORRECT_CHAR * string.size)
			return best_player;
	}
	return;
}

isInt(c)
{
	switch(c)
	{
		case "0":
		case "1":
		case "2":
		case "3":
		case "4":
		case "5":
		case "6":
		case "7":
		case "8":
		case "9":
			return true;
		default:
			return false;
	}
}

stripColors(string)
{
	gotColors = true;
	while(gotColors)
	{
		gotColors = false;
		for(i = 0; i < string.size - 1; i++)
		{
			if(string[i] == "^" && isInt(string[i + 1]))
			{
				newstring = "";
				if(i > 0)
					newstring += getsubstr(string, 0, i);
				newstring += getsubstr(string, i + 2);
				string = newstring;
				gotColors = true;
				break;
			}
		}
	}
	return string;
}