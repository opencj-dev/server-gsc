#include openCJ\util;

onInit()
{
	openCJ\settings::addSettingBool("hideall", false, "Hide all players", ::_onSettingHideALl);
	openCJ\settings::addSettingBool("hidenear", true, "Hide near players", ::_onSettingHideNear);
	openCJ\settings::addSettingInt("hideradius", -1, 500, 60, "Sets your radius for hiding colliding players. Usage !hideradius [value]. Default 60", ::_onSettingHideRadius);
}

onStartDemo()
{
	//placeholder until demo mode is added in vis settings
}

_onSettingHideAll(newVal)
{
	if(newVal)
	{
		self setHideModeAll();
	}
	else
	{
		if(self openCJ\settings::getSetting("hidenear"))
		{
			self setHideModeNear();
		}
		else
		{
			self setHideModeNone();
		}
	}
}

_onSettingHideNear(newVal)
{
	if(self openCJ\settings::getSetting("hideall"))
	{
		self setHideModeAll();
	}
	else
	{
		if(newVal)
		{
			self setHideModeNear();
		}
		else
		{
			self setHideModeNone();
		}
	}
}

_onSettingHideRadius(newVal)
{
	self setHideRadius(newVal);
}

onFrame()
{
	updatePlayerVisibility();
}

onIgnore(player) //self onIgnore(player) when self ignores a player //also called when loading ignore list from db, and should be called onconnect if someone has the player ignored
{
	self addPlayerToHideList(player getEntityNumber());
}

onUnIgnore(player) //self onUnIgnore(player) when self unignores a player
{
	self removePlayerFromHideList(player getEntityNumber());
}

onMuteChanged(newVal)
{
	self hideForAll(newVal);
}

onPlayerConnect()
{
	self initVisibility();
}