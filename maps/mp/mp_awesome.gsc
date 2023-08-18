main()
{

	maps\mp\_load::main();
	maps\mp\_teleport::main(); //todo: fix tele

	bounce = getEntArray("bounce", "targetname");
	for(i = 0; i < bounce.size; i++)
	{
		bounce[i] thread bounce();
	}
	setdvar("r_specularcolorscale", "1");
 }
 
bounce()
{
	while(true)
	{
		self waittill("trigger", player);
		if(!isDefined(player.bouncing))
		{
			player.bouncing = true;
			player thread player_bounce(self);
		}
	}
}

player_bounce(trigger)
{
	self endon("disconnect");
	vel = self getVelocity();

	if(abs(vel[0]) >= 350 && abs(vel[1]) >= 350 || vel[2] > -350)
	{
		//dont bounce
		wait 1;
		self.bouncing = undefined;
		return;
	}

	kb_val = (vel[2]*-9) - 500;
	dmg_val = 1000;
	kb_dir = (0, 0, 1);
	emulateKnockback(dmg_val, kb_dir, kb_val);

	wait 1;

	while(self isTouching(trigger))
	{
		wait 0.05;
	}

	self.bouncing = undefined;
}

emulateKnockback(dmg, dir, g_knockback_val)
{
    //not taking stance into account
    //adjust dmg if player is always crouching
    dmg *= 0.3;
    if(dmg > 60)
        dmg = 60;
    knockback = dmg * g_knockback_val / 250;
    self addVelocity(vectorscale(dir, knockback));

	//for reference, this should also be executed according to cod2rev_server code
	//pm_time might be nonzero due to jump though
	// if ( !ent->client->ps.pm_time )
	// {
	// 	maxDmg = 2 * minDmg;

	// 	if ( 2 * minDmg <= 49 )
	// 		maxDmg = 50;

	// 	if ( maxDmg > 200 )
	// 		maxDmg = 200;

	// 	ent->client->ps.pm_time = maxDmg;
	// 	ent->client->ps.pm_flags |= 0x400u;
	// }
}

	