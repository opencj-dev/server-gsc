main()
{

	level._effect[ "furi_effect2" ] = loadfx( "customfx/furi_effect2");
	level._effect[ "furi_effect2_purple" ] = loadfx( "customfx/furi_effect2_purple");
	level._effect[ "furi_effect2_orange" ] = loadfx( "customfx/furi_effect2_orange");
	level._effect[ "furi_effect" ] = loadfx( "customfx/furi_effect");
	level._effect[ "dotted_lazer" ] = loadfx( "customfx/dotted_lazer");
	level._effect[ "dotted_lazer2" ] = loadfx( "customfx/dotted_lazer2");
	level._effect[ "dotted_lazer2_purple" ] = loadfx( "customfx/dotted_lazer2_purple");
	level._effect[ "dotted_lazer2_orange" ] = loadfx( "customfx/dotted_lazer2_orange");
	level._effect[ "dotted_lazer_purple" ] = loadfx( "customfx/dotted_lazer_purple");
	level._effect[ "dotted_lazer_orange" ] = loadfx( "customfx/dotted_lazer_orange");
	level._effect[ "race2_pilar" ] = loadfx( "customfx/race2_pilar");
	level._effect[ "race2_pilar_purple" ] = loadfx( "customfx/race2_pilar_purple");
	level._effect[ "race2_pilar_orange" ] = loadfx( "customfx/race2_pilar_orange");
	level._effect[ "phoenix_finish" ] = loadfx( "customfx/phoenix_finish");
	level._effect[ "furi_effect3" ] = loadfx( "customfx/furi_effect3");
	
	thread advEffects();
	thread interEffects();
	thread hardEffects();
    thread spawnEffects();
	thread discoEffects();
}

interEffects()
{
	dest1 = getEnt("spotlightorange", "targetname");
	dest2 = getEnt("spotlightorange2", "targetname");
	dest3 = getEnt("spotlightorange3", "targetname");
	dest4 = getEnt("lazercutterorange1", "targetname");
	dest5 = getEnt("lazercutterorange2", "targetname");
	dest6 = getEnt("lazercutterorange3", "targetname");
	dest7 = getEnt("lazercutterorange4", "targetname");
	dest8 = getEnt("lazercutterorange5", "targetname");
	dest9 = getEnt("lazercutterorange6", "targetname");
	dest10 = getEnt("pilarorange", "targetname");
	dest11 = getEnt("pilarorange2", "targetname");
	
	wait 0.5;
	
	fx1 = SpawnFX( level._effect[ "furi_effect2_orange" ], dest1.origin);
	TriggerFX(fx1);
	fx2 = SpawnFX( level._effect[ "furi_effect2_orange" ], dest2.origin);
	TriggerFX(fx2);
	fx3 = SpawnFX( level._effect[ "furi_effect2_orange" ], dest3.origin);
	TriggerFX(fx3);
	fx4 = SpawnFX( level._effect[ "dotted_lazer2_orange" ], dest4.origin);
	TriggerFX(fx4);
	fx5 = SpawnFX( level._effect[ "dotted_lazer2_orange" ], dest5.origin);
	TriggerFX(fx5);
	fx6 = SpawnFX( level._effect[ "dotted_lazer2_orange" ], dest6.origin);
	TriggerFX(fx6);
	fx7 = SpawnFX( level._effect[ "dotted_lazer_orange" ], dest7.origin);
	TriggerFX(fx7);
	fx8 = SpawnFX( level._effect[ "dotted_lazer_orange" ], dest8.origin);
	TriggerFX(fx8);
	fx9 = SpawnFX( level._effect[ "dotted_lazer_orange" ], dest9.origin);
	TriggerFX(fx9);
	fx10 = SpawnFX( level._effect[ "race2_pilar_orange" ], dest10.origin);
	TriggerFX(fx10);
	fx11 = SpawnFX( level._effect[ "race2_pilar_orange" ], dest11.origin);
	TriggerFX(fx11);
	
	interFX = [];
	interFX[0] = fx1;
	interFX[1] = fx2;
	interFX[2] = fx3;
	interFX[3] = fx4;
	interFX[4] = fx5;
	interFX[5] = fx6;
	interFX[6] = fx7;
	interFX[7] = fx8;
	interFX[8] = fx9;
	interFX[9] = fx10;
	interFX[10] = fx11;
	
	for(i = 0; i < interFX.size; i++)
        interFX[i] hide();
	
	inter_trigger = getEnt("inter_trigger", "targetname");
	
	while(1) 
	{
		inter_trigger waittill ("trigger", player);
		
		if(!isDefined(player.touching) || player.touching == false)
			player thread outsideInter(inter_trigger, interFX);
	}
}

outsideInter(inter_trigger, interFX)
{
    self endon("disconnect");
	self.touching = true;
	while(isDefined(self) && isDefined(inter_trigger) && self isTouching(inter_trigger)) {
		for(i = 0; i < interFX.size; i++)
			interFX[i] showtoplayer(self);
		wait 1;
	}
	
    if(isDefined(self))
    {
        self.touching = false;
        for(i = 0; i < interFX.size; i++)
            interFX[i] hide();
    }
}

hardEffects()
{
	dest1 = getEnt("spotlightpurple", "targetname");
	dest2 = getEnt("spotlightpurple2", "targetname");
	dest3 = getEnt("spotlightpurple3", "targetname");
	dest4 = getEnt("lazercutterpurple1", "targetname");
	dest5 = getEnt("lazercutterpurple2", "targetname");
	dest6 = getEnt("lazercutterpurple3", "targetname");
	dest7 = getEnt("lazercutterpurple4", "targetname");
	dest8 = getEnt("lazercutterpurple5", "targetname");
	dest9 = getEnt("lazercutterpurple6", "targetname");
	dest10 = getEnt("pilarpurple", "targetname");
	dest11 = getEnt("pilarpurple2", "targetname");
	
	wait 0.5;
	
	fx1 = SpawnFX( level._effect[ "furi_effect2_purple" ], dest1.origin);
	TriggerFX(fx1);
	fx2 = SpawnFX( level._effect[ "furi_effect2_purple" ], dest2.origin);
	TriggerFX(fx2);
	fx3 = SpawnFX( level._effect[ "furi_effect2_purple" ], dest3.origin);
	TriggerFX(fx3);
	fx4 = SpawnFX( level._effect[ "dotted_lazer2_purple" ], dest4.origin);
	TriggerFX(fx4);
	fx5 = SpawnFX( level._effect[ "dotted_lazer2_purple" ], dest5.origin);
	TriggerFX(fx5);
	fx6 = SpawnFX( level._effect[ "dotted_lazer2_purple" ], dest6.origin);
	TriggerFX(fx6);
	fx7 = SpawnFX( level._effect[ "dotted_lazer_purple" ], dest7.origin);
	TriggerFX(fx7);
	fx8 = SpawnFX( level._effect[ "dotted_lazer_purple" ], dest8.origin);
	TriggerFX(fx8);
	fx9 = SpawnFX( level._effect[ "dotted_lazer_purple" ], dest9.origin);
	TriggerFX(fx9);
	fx10 = SpawnFX( level._effect[ "race2_pilar_purple" ], dest10.origin);
	TriggerFX(fx10);
	fx11 = SpawnFX( level._effect[ "race2_pilar_purple" ], dest11.origin);
	TriggerFX(fx11);
	
	hardFX = [];
	hardFX[0] = fx1;
	hardFX[1] = fx2;
	hardFX[2] = fx3;
	hardFX[3] = fx4;
	hardFX[4] = fx5;
	hardFX[5] = fx6;
	hardFX[6] = fx7;
	hardFX[7] = fx8;
	hardFX[8] = fx9;
	hardFX[9] = fx10;
	hardFX[10] = fx11;
	
	for(i = 0; i < hardFX.size; i++)
        hardFX[i] hide();
	
	hard_trigger = getEnt("hard_trigger", "targetname");
	
	while(1) 
	{
		hard_trigger waittill ("trigger", player);
		
		if(!isDefined(player.touching) || player.touching == false)
			player thread outsideHard(hard_trigger, hardFX);
	}
}

outsideHard(hard_trigger, hardFX)
{
    self endon("disconnect");
	self.touching = true;
	while(isDefined(self) && isDefined(hard_trigger) && self isTouching(hard_trigger)) {
		for(i = 0; i < hardFX.size; i++)
			hardFX[i] showtoplayer(self);
		wait 1;
	}
	
    if (isDefined(self))
    {
        self.touching = false;
        for(i = 0; i < hardFX.size; i++)
            hardFX[i] hide();
    }
}

advEffects()
{
	dest1 = getEnt("spotlight", "targetname");
	dest2 = getEnt("spotlight2", "targetname");
	dest3 = getEnt("spotlight3", "targetname");
	dest4 = getEnt("lazercutter4", "targetname");
	dest5 = getEnt("lazercutter5", "targetname");
	dest6 = getEnt("lazercutter6", "targetname");
	dest7 = getEnt("lazercutter", "targetname");
	dest8 = getEnt("lazercutter2", "targetname");
	dest9 = getEnt("lazercutter3", "targetname");
	dest10 = getEnt("pilar", "targetname");
	dest11 = getEnt("pilar2", "targetname");

	wait 0.5;
	
	fx1 = SpawnFX( level._effect[ "furi_effect2" ], dest1.origin);
	TriggerFX(fx1);
	fx2 = SpawnFX( level._effect[ "furi_effect2" ], dest2.origin);
	TriggerFX(fx2);
	fx3 = SpawnFX( level._effect[ "furi_effect2" ], dest3.origin);
	TriggerFX(fx3);
	fx4 = SpawnFX( level._effect[ "dotted_lazer2" ], dest4.origin);
	TriggerFX(fx4);
	fx5 = SpawnFX( level._effect[ "dotted_lazer2" ], dest5.origin);
	TriggerFX(fx5);
	fx6 = SpawnFX( level._effect[ "dotted_lazer2" ], dest6.origin);
	TriggerFX(fx6);
	fx7 = SpawnFX( level._effect[ "dotted_lazer" ], dest7.origin);
	TriggerFX(fx7);
	fx8 = SpawnFX( level._effect[ "dotted_lazer" ], dest8.origin);
	TriggerFX(fx8);
	fx9 = SpawnFX( level._effect[ "dotted_lazer" ], dest9.origin);
	TriggerFX(fx9);
	fx10 = SpawnFX( level._effect[ "race2_pilar" ], dest10.origin);
	TriggerFX(fx10);
	fx11 = SpawnFX( level._effect[ "race2_pilar" ], dest11.origin);
	TriggerFX(fx11);
	
	advFX = [];
	advFX[0] = fx1;
	advFX[1] = fx2;
	advFX[2] = fx3;
	advFX[3] = fx4;
	advFX[4] = fx5;
	advFX[5] = fx6;
	advFX[6] = fx7;
	advFX[7] = fx8;
	advFX[8] = fx9;
	advFX[9] = fx10;
	advFX[10] = fx11;
	
	for(i = 0; i < advFX.size; i++)
        advFX[i] hide();
	
	adv_trigger = getEnt("adv_trigger", "targetname");
	
	while(1) 
	{
		adv_trigger waittill ("trigger", player);
		
		if(!isDefined(player.touching) || player.touching == false)
			player thread outsideAdv(adv_trigger, advFX);
	}
}

outsideAdv(adv_trigger, advFX)
{
    self endon("disconnect");
	self.touching = true;
	while(isDefined(self) && isDefined(adv_trigger) && self isTouching(adv_trigger)) {
		for(i = 0; i < advFX.size; i++)
			advFX[i] showtoplayer(self);
		wait 1;
	}
	
    if (isDefined(self))
    {
        self.touching = false;
        for(i = 0; i <advFX.size; i++)
            advFX[i] hide();
    }
}

spawnEffects()
{
	dest1 = getEnt("spotlightspawn", "targetname");
	dest2 = getEnt("spotlightspawn2", "targetname");
	dest3 = getEnt("spotlightspawn3", "targetname");
	dest4 = getEnt("spotlightspawn4", "targetname");
	dest5 = getEnt("fire", "targetname");
	dest6 = getEnt("endlight1", "targetname");
	dest7 = getEnt("endlight2", "targetname");
	dest8 = getEnt("endlight3", "targetname");
	dest9 = getEnt("endlight4", "targetname");
	dest10 = getEnt("endlight5", "targetname");
	dest11 = getEnt("endlight6", "targetname");
	
	
	wait 0.5;
	
	fx1 = SpawnFX( level._effect[ "furi_effect2" ], dest1.origin);
	TriggerFX(fx1);
	fx2 = SpawnFX( level._effect[ "furi_effect2" ], dest2.origin);
	TriggerFX(fx2);
	fx3 = SpawnFX( level._effect[ "furi_effect2" ], dest3.origin);
	TriggerFX(fx3);
	fx4 = SpawnFX( level._effect[ "furi_effect2" ], dest4.origin);
	TriggerFX(fx4);
	fx5 = SpawnFX( level._effect[ "furi_effect" ], dest5.origin);
	TriggerFX(fx5);
	fx6 = SpawnFX( level._effect[ "phoenix_finish" ], dest6.origin);
	TriggerFX(fx6);
	fx7 = SpawnFX( level._effect[ "phoenix_finish" ], dest7.origin);
	TriggerFX(fx7);
	fx8 = SpawnFX( level._effect[ "phoenix_finish" ], dest8.origin);
	TriggerFX(fx8);
	fx9 = SpawnFX( level._effect[ "phoenix_finish" ], dest9.origin);
	TriggerFX(fx9);
	fx10 = SpawnFX( level._effect[ "phoenix_finish" ], dest10.origin);
	TriggerFX(fx10);
	fx11 = SpawnFX( level._effect[ "phoenix_finish" ], dest11.origin);
	TriggerFX(fx11);
	
	spotlightFX = [];
	spotlightFX[0] = fx1;
	spotlightFX[1] = fx2;
	spotlightFX[2] = fx3;
	spotlightFX[3] = fx4;
	spotlightFX[4] = fx5;
	spotlightFX[5] = fx6;
	spotlightFX[6] = fx7;
	spotlightFX[7] = fx8;
	spotlightFX[8] = fx9;
	spotlightFX[9] = fx10;
	spotlightFX[10] = fx11;
	
	for(i = 0; i < spotlightFX.size; i++)
        spotlightFX[i] hide();
	
	spotlight_trigger = getEnt("spotlight_trigger", "targetname");
	
	while(1) 
	{
		spotlight_trigger waittill ("trigger", player);
		
		if(!isDefined(player.touching) || player.touching == false)
			player thread outsideSpawn(spotlight_trigger, spotlightFX);
	}
}

outsideSpawn(spotlight_trigger, spotlightFX)
{
    self endon("disconnect");

	self.touching = true;
	while(isDefined(self) && isDefined(spotlight_trigger) && self isTouching(spotlight_trigger)) {
		for(i = 0; i < spotlightFX.size; i++)
			spotlightFX[i] showtoplayer(self);
		wait 1;
	}

    if (isDefined(self))
    {
        self.touching = false;
        for(i = 0; i < spotlightFX.size; i++)
            spotlightFX[i] hide();
    }
}

discoEffects()
{
	dest1 = getEnt("discoeffect", "targetname");
	dest2 = getEnt("discoeffect2", "targetname");
		
	wait 0.5;
	
	fx1 = SpawnFX( level._effect[ "furi_effect3" ], dest1.origin);
	TriggerFX(fx1);
	fx2 = SpawnFX( level._effect[ "furi_effect3" ], dest2.origin);
	TriggerFX(fx2);

	discoFX = [];
	discoFX[0] = fx1;
	discoFX[1] = fx2;

	for(i = 0; i < discoFX.size; i++)
        discoFX[i] hide();
	
	discoroom_trigger = getEnt("discoroom_trigger", "targetname");
	
	while(1) 
	{
		discoroom_trigger waittill ("trigger", player);
		
		if(!isDefined(player.touching) || player.touching == false)
			player thread outsideDisco(discoroom_trigger, discoFX);
	}
}


outsideDisco(discoroom_trigger, discoFX)
{
    self endon("disconnect");

	self.touching = true;
	while(isDefined(self) && isDefined(discoroom_trigger) && self isTouching(discoroom_trigger)) {
		for(i = 0; i < discoFX.size; i++)
			discoFX[i] showtoplayer(self);
		wait 1;
	}

    if(isDefined(self))
    {
        self.touching = false;
        for(i = 0; i < discoFX.size; i++)
            discoFX[i] hide();
    }
}
