#include openCJ\util;

onInit()
{
	//printf("preparing inf huds\n");
	level.infiniteHudStrings = [];
}

initInfiniteHud(name)
{
	level.infiniteHudStrings[name] = spawnStruct();
	level.infiniteHudStrings[name].num = level.infiniteHudStrings.size;
	level.infiniteHudStrings[name].localizedString = findLocalizedString(level.infiniteHudStrings[name].num);
	level.infiniteHudStrings[name].string = findString(level.infiniteHudStrings[name].num);
	precacheString(level.infiniteHudStrings[name].localizedString);
	level.infiniteHudStrings[name].configstringIndex = G_FindConfigstringIndex(level.infiniteHudStrings[name].string, 1310, 256);
	//printf("config string index is: " + level.infiniteHudStrings[name].configstringIndex + "\n");
}

onPlayerConnected()
{
	keys = getArrayKeys(level.infiniteHudStrings);
	for(i = 0; i < keys.size; i++)
	{
		self SV_GameSendServerCommand("d " + level.infiniteHudStrings[keys[i]].configstringIndex + " ", true);
		//printf("sending command " + "d " + level.infiniteHudStrings[keys[i]].configstringIndex + " \n");
	}
}

createInfiniteStringHud(name)
{
	hud = newClientHudElem(self);
	hud.configstringIndex = level.infiniteHudStrings[name].configstringIndex;
	hud setText(level.infiniteHudStrings[name].localizedString);
	hud.lastText = "";
	self SV_GameSendServerCommand("d " + hud.configstringIndex + " ", true);
	hud.archived = false;
	return hud;
}

setInfiniteHudText(text, player, reliable)
{
	if(!isDefined(reliable))
		reliable = false;
	if(text == self.lastText)
		return;
	self.lastText = text;
	player SV_GameSendServerCommand("d " + self.configstringIndex + " " + text, reliable);
}

findString(num)
{
	if (!isDefined(findLocalizedString(num))) return undefined;
	return "openCJPlaceHolderString" + num;
}

findLocalizedString(num)
{
	switch(num)
	{
		case 0: return &"openCJPlaceHolderString0";
		case 1: return &"openCJPlaceHolderString1";
		case 2: return &"openCJPlaceHolderString2";
		case 3: return &"openCJPlaceHolderString3";
		case 4: return &"openCJPlaceHolderString4";
		case 5: return &"openCJPlaceHolderString5";
		case 6: return &"openCJPlaceHolderString6";
		case 7: return &"openCJPlaceHolderString7";
		case 8: return &"openCJPlaceHolderString8";
		case 9: return &"openCJPlaceHolderString9";
		case 10: return &"openCJPlaceHolderString10";
		case 11: return &"openCJPlaceHolderString11";
		case 12: return &"openCJPlaceHolderString12";
		case 13: return &"openCJPlaceHolderString13";
		case 14: return &"openCJPlaceHolderString14";
		case 15: return &"openCJPlaceHolderString15";
		case 16: return &"openCJPlaceHolderString16";
		default: return undefined;
	}
}