#include openCJ\util;

main(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, hitLoc, psOffsetTime)
{
	if(self openCJ\demos::isPlayingDemo())
	{
		return;
	}
	if(!self isPlayerReady())
	{
		return;
	}
	if(self.sessionState != "playing")
		return;
	if(self openCJ\noclip::hasNoclip())
		return;

	if(!isdefined(vDir))
		flags |= 4; //iDFLAGS_NO_KNOCKBACK;

	if(isDefined(attacker) && isPlayer(attacker) && self != attacker)
		return;

	if(damage < 1)
		damage = 1;

	if(self openCJ\weapons::isRPG(weapon))
		return;

	if(damage >= self.health)
	{
		if(self openCJ\events\loadPosition::main(0))
		{
			if (getCodVersion() == 2)
			{
				self openCJ\playTime::addTimeUntil(getTime() + 5000);
			}
			return;
		}
	}

	self finishPlayerDamage(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, hitLoc, psOffsetTime);

	self openCJ\shellShock::onPlayerDamage(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, hitLoc, psOffsetTime);
	self openCJ\healthRegen::onPlayerDamage(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, hitLoc, psOffsetTime);
	self openCJ\statistics::onPlayerDamage(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, hitLoc, psOffsetTime);
}