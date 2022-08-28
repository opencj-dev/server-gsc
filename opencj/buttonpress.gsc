#include openCJ\util;

onMeleeButton()
{
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
		self openCJ\saveposition::saveNormal();
	}
	else
	{
		self.buttons_lastMelee = getTime();
	}
}

onUseButton()
{
	if(self.sessionState != "playing")
		return;
	if(isDefined(self.buttons_lastUse) && getTime() - self.buttons_lastUse < 500)
	{
		//load
		self.buttons_lastUse = undefined;
		self.buttons_lastMelee = undefined;
		self openCJ\saveposition::loadNormal();
	}
	else
		self.buttons_lastUse = getTime();
}

onAttackButton()
{
	if(self.sessionState != "playing")
		return;

	if(self useButtonPressed())
	{
		//load secondary
		self openCJ\saveposition::loadSecondary();
	}
}

resetButtons()
{
	self.buttons_lastMelee = undefined;
	self.buttons_lastUse = undefined;
}

onJump(time)
{
	//printf("time: " + time + "\n");
	self openCJ\statistics::onJump();
}