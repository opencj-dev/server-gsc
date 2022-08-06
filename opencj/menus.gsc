#include openCJ\util;

onInit()
{
	level.menu["ingame"] = "openCJ_ingame";
	level.menu["settings"] = "openCJ_settings";
	level.menu["clientcmd"] = "openCJ_clientcmd";
	precacheMenu(level.menu["ingame"]);
	precacheMenu(level.menu["settings"]);
	precacheMenu(level.menu["clientcmd"]);
}

openIngameMenu()
{
	printf("opening menu...\n\n");
	self setClientCvar("g_scriptMainMenu", level.menu["ingame"]);
	self openMenu(level.menu["ingame"]);
}