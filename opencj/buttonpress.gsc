#include openCJ\util;

onMeleeButton()
{
	if(!self isPlayerReady())
	{
		return;
	}
	if(self.sessionState != "playing")
	{
		return;
	}

	if (self openCJ\demos::isPlayingDemo())
	{
		self openCJ\demos::onPlayPauseDemo();
		return;
	}

	if(isDefined(self.buttons_lastMelee) && getTime() - self.buttons_lastMelee < 500)
	{
		//save
		self.buttons_lastUse = undefined;
		self.buttons_lastMelee = undefined;
		self openCJ\events\eventHandler::onSavePositionRequest();
	}
	else
	{
		self.buttons_lastMelee = getTime();
	}
}

onUseButton()
{
	if(!self isPlayerReady())
	{
		return;
	}
	if(self.sessionState != "playing")
	{
		return;
	}

	if (self openCJ\demos::isPlayingDemo())
	{
		return;
	}

	if(isDefined(self.buttons_lastUse) && getTime() - self.buttons_lastUse < 500)
	{
		//load
		self.buttons_lastUse = undefined;
		self.buttons_lastMelee = undefined;
		self openCJ\events\eventHandler::onLoadPositionRequest(0);
	}
	else
	{
		self.buttons_lastUse = getTime();
	}
}

onAttackButton()
{
	if(!self isPlayerReady())
	{
		return;
	}
	if(self.sessionState != "playing")
	{
		return;
	}

	if (self openCJ\demos::isPlayingDemo())
	{
		return;
	}

	if(self useButtonPressed())
	{
		//load secondary
		self openCJ\events\eventHandler::onLoadPositionRequest(1);
	}
}

resetButtons()
{
	self.buttons_lastMelee = undefined;
	self.buttons_lastUse = undefined;
}

onJump(time)
{
	if(!self isPlayerReady())
	{
		return;
	}
	if(self.sessionState != "playing")
	{
		return;
	}

	if (self openCJ\demos::isPlayingDemo())
	{
		return;
	}

	self openCJ\statistics::onJump();
}