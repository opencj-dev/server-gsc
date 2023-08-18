execClientCmd(cmd)
{
    self setClientCvar("openCJ_clientcmd", cmd);
    self openMenu(level.menu["clientcmd"]);
    self closeMenu();
}

short2angle(vec)
{
    return ((vec[0] * 360 / 65536), (vec[1] * 360 / 65536), (vec[2] * 360 / 65536));
}

angle2short(vec)
{
    return (int((vec[0] * 65536 / 360)) & 65535, int((vec[1] * 65536 / 360)) & 65535, int((vec[2] * 65536 / 360)) & 65535);
}

isPlayerReady(requiresRunReady)
{
    ready = (self openCJ\login::isLoggedIn() && self openCJ\settings::areSettingsLoaded());

    if (isDefined(requiresRunReady) && requiresRunReady)
    {
        return ready && self openCJ\playerRuns::hasRunID();
    }

    return ready;
}

getEyePos()
{
    if(self getstance() == "stand")
        return self.origin + (0, 0, 40);
    else if(self getstance() == "duck")
        return self.origin + (0, 0, 20);
    else
        return self.origin + (0, 0, 5);
}

getPlayerByPlayerID(playerID) //gets a player that's logged in AND has a certain playerID. If player is not on server, returns undefined.
{
    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
        if(players[i] openCJ\login::isLoggedIn())
        {
            if(players[i] openCJ\login::getPlayerID() == playerID)
            {
                return players[i];
            }
        }
    }
    return players[i];
}

abs(value)
{
    if(value < 0)
    {
        return value * -1;
    }
    return value;
}

max(value1, value2)
{
    if (value1 > value2)
    {
        return value1;
    }

    return value2;
}

hasResult(rows)
{
    return (isDefined(rows) && isDefined(rows[0]) && isDefined(rows[0][0]));
}

sendChatMessage(msg)
{
    self SV_GameSendServerCommand("h \"" + msg + "\"", true); //last arg is reliable yes/no
}

arrayConcat(array, separator)
{
    if(!isDefined(separator))
    {
        separator = " ";
    }
    if(!array.size)
    {
        return "";
    }
    string = array[0];
    for(i = 1; i < array.size; i++)
    {
        string += separator + array[i];
    }
    return string;
}

sendLocalChatMessage(msg, isError)
{
    prefix = undefined;
    if (isDefined(isError) && isError)
    {
        prefix = "^1[^7local^1]:^7 ";
    }
    else
    {
        prefix = "^3[^7local^3]:^7 ";
    }
    self sendChatMessage(prefix + msg);
}

subArray(array, begin, end)
{
    if(!isDefined(begin))
    {
        if(!isDefined(end))
        {
            return array;
        }
        begin = 0;
    }
    if(!isDefined(end))
    {
        end = array.size;
    }
    if(begin < 0)
    {
        begin = 0;
    }
    if(end > array.size)
    {
        end = array.size;
    }
    newArray = [];
    for(i = begin; i < end; i++)
    {
        newArray[newArray.size] = array[i];
    }
    return newArray;
}

stringArrayToIntArray(array)
{
    newArray = [];
    for(i = 0; i < array.size; i++)
    {
        newArray[newArray.size] = int(array[i]);
    }
    return newArray;
}

isValidBool(str)
{
    if(!isDefined(str))
    {
        return false;
    }

    if (isStrBoolTrue(str) || isStrBoolFalse(str))
    {
        return true;
    }

    return false;
}

isStrBoolTrue(str)
{
    str = tolower("" + str);
    return (str == "on") || (str == "1") || (str == "true") || (str == "yes") || (str == "enable");
}

isStrBoolFalse(str)
{
    str = tolower("" + str);
    return (str == "off") || (str == "0") || (str == "false") || (str == "no") || (str == "disable");
}

strToBool(str)
{
    if(!isValidBool(str))
    {
        return undefined; // Sanity check
    }
    if(isStrBoolTrue(str))
    {
        return true;
    }

    return false;
}

doNextFrame(func)
{
    self endon("disconnect");
    waittillframeend;

    if(isDefined(self))
    {
        self [[func]]();
    }
}

isInArray(value, array)
{
    for(i = 0; i < array.size; i++)
    {
        if(array[i] == value) return true;
    }
    return false;
}

getSpectatorList(includeSelf)
{
    players = getEntArray("player", "classname");
    ret = [];
    if(includeSelf)
    {
        ret[ret.size] = self;
    }
    for(i = 0; i < players.size; i++)
    {
        if(!isDefined(players[i] getSpectatorClient()))
        {
            continue;
        }
        if(players[i] getSpectatorClient() == self)
        {
            ret[ret.size] = players[i];
        }
    }
    return ret;
}

isSpectator()
{
    return (self.sessionState == "spectator");
}

intOrUndefined(value)
{
    if(!isDefined(value))
    {
        return undefined;
    }
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
        {
            timestring += "0";
        }
    }
    timestring += minutes + ":";
    if(seconds < 10)
    {
        timestring += "0";
    }
    timestring += seconds;
    if(!roundSeconds)
    {
        if(timems < 10)
        {
            timeString += ".00" + timems;
        }
        else if(timems < 100)
        {
            timeString += ".0" + timems;
        }
        else
        {
            timeString += "." + timems;
        }
    }
    return timestring;
}

deleteOnEvent(event, entity)
{
    entity waittill(event);
    if(isDefined(self))
    {
        self delete();
    }
}

findPlayerByArg(string)
{
    //assumes you'd rather call a player by its name than by its entitynumber
    //doesnt check for entitynumber at all atm
    if(!isDefined(string))
    {
        return undefined;
    }
    string = stripcolors(tolower(string));

    BONUS_FOR_CHARS_IN_ORDER = 50;
    BONUS_CORRECT_CHAR = 25;
    BONUS_FOR_COMPLETE = 200;
    best_player = undefined;

    best_score = 0;
    players = getEntArray("player", "classname");
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

isDigit(c)
{
    str = "" + c; // Make sure we're dealing with a string
    return ((str.size == 1) && isValidInt(str));
}

stripColors(string)
{
    gotColors = true;
    while(gotColors)
    {
        gotColors = false;
        for(i = 0; i < string.size - 1; i++)
        {
            if(string[i] == "^" && isDigit(string[i + 1]))
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

cleanCharacters(str, allowedChars, maxSize)
{
    cleanStr = "";
    limitedMaxSize = str.size;
    if (limitedMaxSize > maxSize)
    {
        limitedMaxSize = maxSize;
    }
    for (i = 0; i < limitedMaxSize; i++)
    {
        if (isSubstr(allowedChars, str[i]))
        {
            cleanStr += str[i];
        }
        else
        {
            cleanStr += "?";
        }
    }

    return cleanStr;
}

xOrEmpty(val) // Useful for menus that want to show an empty cell instead of hiding it, when empty
{
    if (val > 0)
    {
        return "X";
    }

    return "^7";
}

dbStr(str)
{
    return "'" + str + "'";
}

removeIntegerPart(vec3) // Remove part before the dot
{
    modified3 = [];
    for(i = 0; i < 3; i++)
    {
        modified3[i] = abs(vec3[i] - int(vec3[i]));
    }

    return (modified3[0], modified3[1], modified3[2]);
}

fixDecimals(org, maxNrDecimals, withIntegerPart) // Float position to float with limited decimals
{
    fixedOrg = [];
    orgOnlyDecimals = removeIntegerPart(org); // Prevent overflows when multiplying
    scale = pow(10, maxNrDecimals);
    for(i = 0; i < 3; i++)
    {
        fixedOrg[i] = orgOnlyDecimals[i];
        // Round to n decimals
        tmp = int(fixedOrg[i] * scale);
        fixedOrg[i] = float(tmp) / scale;

        if (withIntegerPart)
        {
            fixedOrg[i] += int(org[i]);
        }
    }

    return (fixedOrg[0], fixedOrg[1], fixedOrg[2]);
}

preciseFloatToStr(val)
{
    // This function is needed because when converting floats to str and back, CoD will perform excessive rounding
    // More precision than that is needed to restore a player's position without putting them in the wall
    rounded = int(val);
    return rounded + getSubStr(abs(val - rounded), 1); // 1 -> skip the 0 before the dot
}

strToPreciseFloat(str)
{
    // This function is needed because when converting floats to str and back, CoD will perform excessive rounding
    // More precision than that is needed to restore a player's position without putting them in the wall
    if (isSubStr(str, "."))
    {
        twoParts = strTok(str, ".");
        intPart = float(twoParts[0]);
        floatPart = float("0." + twoParts[1]);

        if (intPart < 0)
        {
            return float(float(intPart) - float(floatPart));
        }
        else
        {
            return float(float(intPart) + float(floatPart));
        }
    }
    return float(str); // No decimals?
}