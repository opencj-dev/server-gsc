#include openCJ\util;

onInit()
{
	printf("preparing inf huds\n");
	level.infiniteHudStrings = [];
	for(i = 0; i < 10; i++)
	{
		level.infiniteHudStrings[i] = spawnStruct();
		level.infiniteHudStrings[i].localizedString = findLocalizedString(i);
		level.infiniteHudStrings[i].string = findString(i);
		precacheString(level.infiniteHudStrings[i].localizedString);
		level.infiniteHudStrings[i].configstringIndex = G_FindConfigstringIndex(level.infiniteHudStrings[i].string, 1310, 256);
	}
}

onPlayerConnect()
{
	for(i = 0; i < level.infiniteHudStrings.size; i++)
	{
		self SV_GameSendServerCommand("d " + level.infiniteHudStrings[i].configstringIndex + " ", true);
		printf("sending command " + "d " + level.infiniteHudStrings[i].configstringIndex + " \n");
	}
	
	self.infhud = createInfiniteHud(0);
	self.infhud.horzAlign = "center_safearea";
	self.infhud.vertAlign = "center_safearea";
	self.infhud.alignX = "center";
	self.infhud.alignY = "middle";
	self.infhud.x = 0;
	self.infhud.y = -30;
	self.infhud.fontscale = 1.5;
	self.infhud.alpha = 1;
	self setInfiniteHudText(self.infhud, "This is just a test, don't panic2");
}

createInfiniteHud(num)
{
	hud = newClientHudElem(self);
	hud.configstringIndex = level.infiniteHudStrings[num].configstringIndex;
	hud setText(level.infiniteHudStrings[num].localizedString);
	hud.lastText = "";
	self SV_GameSendServerCommand("d " + hud.configstringIndex + " ", true);
	hud.archived = false;
	return hud;
}

setInfiniteHudText(hud, text, reliable)
{
	if(!isDefined(reliable))
		reliable = false;
	if(text == hud.lastText)
		return;
	hud.lastText = text;
	self SV_GameSendServerCommand("d " + hud.configstringIndex + " " + text, reliable);
}

findString(num)
{
	if(num >= 0 && num < 32)
		return "openCJPlaceHolderString" + num;
	return undefined;
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
		case 17: return &"openCJPlaceHolderString17";
		case 18: return &"openCJPlaceHolderString18";
		case 19: return &"openCJPlaceHolderString19";
		case 20: return &"openCJPlaceHolderString20";
		case 21: return &"openCJPlaceHolderString21";
		case 22: return &"openCJPlaceHolderString22";
		case 23: return &"openCJPlaceHolderString23";
		case 24: return &"openCJPlaceHolderString24";
		case 25: return &"openCJPlaceHolderString25";
		case 26: return &"openCJPlaceHolderString26";
		case 27: return &"openCJPlaceHolderString27";
		case 28: return &"openCJPlaceHolderString28";
		case 29: return &"openCJPlaceHolderString29";
		case 30: return &"openCJPlaceHolderString30";
		case 31: return &"openCJPlaceHolderString31";
	}
}