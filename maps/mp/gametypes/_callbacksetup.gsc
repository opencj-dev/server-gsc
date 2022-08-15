CodeCallback_StartGameType()
{
	openCJ\events\init::main();
}

CodeCallback_PlayerConnect()
{
	self openCJ\events\playerConnect::main();
}

CodeCallback_PlayerDisconnect()
{
	self openCJ\events\playerDisconnect::main();
}

CodeCallback_PlayerDamage(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, hitLoc, psOffsetTime)
{
	self openCJ\events\playerDamage::main(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, hitLoc, psOffsetTime);
}

CodeCallback_PlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	self openCJ\events\playerKilled::main(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration);
}

CodeCallback_PlayerCommand(args)
{
	self openCJ\events\playerCommand::main(args);
}

CodeCallback_PlayerLastStand()
{
}

CodeCallback_RPGFired(rpg, name)
{
	self openCJ\events\rpgFired::main(rpg, name);
}

CodeCallback_FireGrenade(nade, name)
{
	self openCJ\events\grenadeThrow::main(nade, name);
}

CodeCallback_MeleeButton()
{
	self openCJ\buttonPress::onMeleeButton();
}

CodeCallback_UseButton()
{
	self openCJ\buttonPress::onUseButton();
}

CodeCallback_AttackButton()
{
	self openCJ\buttonPress::onAttackButton();
}

CodeCallback_UserInfoChanged(entNum) //entnum not required, legacy.
{
	self openCJ\events\userInfoChanged::main();
}

CodeCallback_StartJump(time)
{
	self openCJ\buttonPress::onJump(time);
}

CodeCallback_OnGroundChange(isOnGround, time)
{
	self openCJ\events\onGroundChanged::main(isOnGround, time);
}

CodeCallback_OnElevate(isAllowedToEle)
{
	self openCJ\events\elevate::main(isAllowedToEle);
}

CodeCallback_PlayerBounced(serverTime)
{
	self openCJ\events\playerBounced::main(serverTime);
}

CodeCallback_SpectatorClientChanged(newClient)
{
	self openCJ\events\spectatorClientChanged::main(newClient);
}

CodeCallback_MoveForward()
{
	self openCJ\events\WASDPressed::main();
}

CodeCallback_MoveRight()
{
	self openCJ\events\WASDPressed::main();
}

CodeCallback_MoveBackward()
{
	self openCJ\events\WASDPressed::main();
}

CodeCallback_MoveLeft()
{
	self openCJ\events\WASDPressed::main();
}

CodeCallback_FPSChange(newFrameTime)
{
	self openCJ\events\FPSChange::main(newFrameTime);
}

/*================
Called when a gametype is not supported.
================*/
AbortLevel()
{
	println("Aborting level - gametype is not supported");

	level.callbackStartGameType = ::callbackVoid;
	level.callbackPlayerConnect = ::callbackVoid;
	level.callbackPlayerDisconnect = ::callbackVoid;
	level.callbackPlayerDamage = ::callbackVoid;
	level.callbackPlayerKilled = ::callbackVoid;
	level.callbackPlayerLastStand = ::callbackVoid;
	
	setCvar("g_gametype", "cj");

	exitLevel(false);
}

/*================
================*/
callbackVoid()
{
}