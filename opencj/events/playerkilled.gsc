#include openCJ\util;

main(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	if(self.sessionTeam == "spectator")
		return;
	if(self openCJ\noclip::hasNoclip())
		return;

	obituary(self, attacker, weapon, meansOfDeath);

	self.sessionState = "dead";

	self openCJ\playerModels::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\healthRegen::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\grenadeTimers::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\checkpointPointers::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\showRecords::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\onscreenKeyboard::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\huds::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
	self openCJ\progressBar::onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);

	if(getCvarInt("codversion") != 4)
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