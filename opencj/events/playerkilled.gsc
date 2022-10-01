#include openCJ\util;

main(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	if(self openCJ\demos::isPlayingDemo())
	{
		return;
	}
	
	if(self.sessionTeam == "spectator")
		return;
	if(self openCJ\noclip::hasNoclip())
		return;

	obituary(self, attacker, weapon, meansOfDeath);

	self.sessionState = "dead";

	self openCJ\playerModels::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\healthRegen::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\checkpointPointers::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\showRecords::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\huds\hudGrenadeTimers::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\huds\hudOnScreenKeyboard::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\huds\hudJumpSlowDown::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\huds\hudProgressBar::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\events\eventHandler::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);

	if(getCodVersion() != 4)
	{
		self openCJ\playTime::addTimeUntil(getTime() + 5000);
	}
	self openCJ\playTime::pauseTimer();

	self thread _respawn();
}

_respawn()
{
	wait 2;
	if(isDefined(self) && self.sessionState == "dead")
		self openCJ\events\spawnPlayer::main();
}