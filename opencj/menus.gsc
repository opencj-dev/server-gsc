#include openCJ\util;

onInit()
{
	level.menu["ingame"] = "openCJ_ingame";
	level.menu["settings"] = "openCJ_settings";
	level.menu["clientcmd"] = "openCJ_clientcmd";
	precacheMenu(level.menu["ingame"]);
	precacheMenu(level.menu["settings"]);
	precacheMenu(level.menu["clientcmd"]);
	if(getCvarInt("codversion") == 2)
	{
		level.menu["login"] = "opencj_fps_userinfo";
		precacheMenu(level.menu["login"]);
	}
	else
	{
		level.menu["fpsuserinfo"] = "opencj_fps_userinfo";
		precacheMenu(level.menu["fpsuserinfo"]);
	}
}

openLoginmenu()
{
	self openMenu(level.menu["login"]);
	self closeMenu();
}

onPlayerLogin()
{
	self setClientCvar("g_scriptMainMenu", level.menu["ingame"]);
}

openFPSUserinfoMenu()
{
	self openMenu(level.menu["fpsuserinfo"]);
	self closeMenu();
}

onStartDemo()
{
	//placeholder, open demo menu here
}