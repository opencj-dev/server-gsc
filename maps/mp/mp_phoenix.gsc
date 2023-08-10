main()
{
	maps\mp\mp_phoenix_effects::main();

	teles = GetEntArray("teleport", "targetname");
    for(i = 0; i < teles.size; i++)
        teles[i] thread teleporter();

	maps\mp\_load::main();
	
	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";
	game["menu_music"] = "musicmenu";
 
    precacheMenu(game["menu_music"]);
 
    precacheMenu( "musicmenu" );
	
	thread connectListener();
	level.welcomeduration = 3.5;
	thread advert();
	thread setupends();
	thread setupscreen();
	thread jumppad("pad1", 6, (-90,0,0), true);
	thread rotate();
	thread ThreadMenu();
	thread playerMessage("credit1", false, "^5Sycotic ^7is Gay!");
	thread playerMessage("credit2", false, "^2Trickshot ^7married an elevator!");
	thread playerMessage("credit3", false, "^6Toxic ^7is just Toxic!");
	thread playerMessage("credit4", false, "^3Funk's ^7mapping blows!");
	thread playerMessage("credit5", false, "^1Skazy ^7is a Toblerone");
	thread playerMessage("credit6", false, "^2Mapper ^7chases potatoes!");
}

playerMessage(entity, showAll, message)
{
     trigger = getEnt (entity, "targetname");
     while(1)
    {
        trigger waittill ("trigger", player);
        player iPrintlnBold(message);
        wait(5);
    }
}

rotate()
{
  _fan = getentarray("rotate","targetname");
 
   for(i=0; i < _fan.size; i++)
   {
    _fan[i] thread spin();
   }
}

spin()
{
    while(true)
    {
        self rotateYaw(360,5);
        wait (0.5);
    }
}


ThreadMenu()
{
	trig = getEnt("musictrigger", "targetname");
 
	while(1)
	{
		trig waittill ( "trigger", player );
 
		player thread MusicMenu(player);
	}
}
 
MusicMenu(player)
{    
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "spectator" );
 
    sound = getent("song", "targetname"); 
    player openMenu( "musicmenu" );   
    while(1)
    {
        self waittill( "menuresponse", menu, response );
            if( menu != "musicmenu" )
                continue;
            switch( response )
            {        
                case "song1":
                    self playLocalSound("song1");
                        break;
                case "song2":
                    self playLocalSound("song2");
                        break;
                case "song3":
                    self playLocalSound("song3");
                        break;
                case "song4":
                    self playLocalSound("song4");
                        break;
                case "song5":
                    self playLocalSound("song5");
                    
                        break;
                default:
                        break;
            }  
            self closeMenu();
    }        
}

setupscreen()
{
    thread setuparray("tv_trigger","rotate",10);
}

setuparray(trigname,tname,counts)
{
    i = 0;
    sarray = [];
    while(i!=counts)
    {
        numstr = i + 1;
        var_name = "";
        var_name = tname + numstr;
        sarray[i] = getent(var_name,"targetname");
        sarray[i] hide();
        i = i+1;
    }
    thread doscreen(trigname,sarray,counts);
}

doscreen(trigname,screenarray,counts)
{
    trig = getent(trigname,"targetname");
    n = 0;
    while(true)
    {
        trig waittill("trigger", player);
        if(n+1 == counts)
        {
            screenarray[n] hide();
            n = 0;
            screenarray[n] show();
            wait 2;

        }
        screenarray[n+1] show();
        screenarray[n] hide();
        n = n + 1;
        wait 2;
    }
}

teleporter()
{
    target = getent(self.target, "targetname");
    while(true)
    {
        self waittill("trigger", player);
        player setorigin(target.origin);
        player setplayerangles(target.angles);
 
    }
}

advert()
{
    while(1)
    {
        iprintln("Map created by ^1Furi");
        wait 15;
        iprintln("Special Thanks goes to:");
        wait 0.5;
        iprintln("^1Sycotic, Funk, Skazy, Toxic");
        wait 900 + randomint(30);
    }
}
setupends()
{
    getent("endeasy", "targetname") thread doend("finish_easy", "", " has finished ^2Easy ^7way!");
    getent("endinter", "targetname") thread doend("finish_inter", "", " has finished ^3Inter ^7way!");
    getent("endhard", "targetname") thread doend("finish_hard", "", " has finished ^6Hard ^7way!");
    getent("endadv", "targetname") thread doend("finish_adv", "", " has finished ^5Advanced ^7way!");
    getent("endbhop", "targetname") thread doend("finish_bhop", "", " has finished ^4Bhop ^7way!");
    getent("endfun", "targetname") thread doend("finish_fun", "", " has finished ^6Fun ^7way!");
    getent("endsecret", "targetname") thread doend("finish_secret", "", " has finished ^1Secret ^7way!");
}

addtrigger(trig)
{
	if(!isdefined(self.trigs))
		self.trigs = [];
	self.trigs[trig] = true;
	if(isdefined(level.trigitems))
	{
		players = getentarray("player", "classname");
		for(i = 0; i < level.trigitems.size; i++)
		{
			if(isdefined(level.trigitems[i].nottrigger) && level.trigitems[i].nottrigger == trig)
			{
				level.trigitems[i] hide();
				for(j = 0; j < players.size; j++)
				{
					if(!players[j] hastrigger(trig))
						level.trigitems[i] showtoplayer(players[j]);
				}
			}
			if(isdefined(level.trigitems[i].trigger) && level.trigitems[i].trigger == trig)
			{
				level.trigitems[i] showtoplayer(self);
			}
		}
	}
}

hastrigger(trig)
{
	if(!isdefined(self.trigs))
		return false;
	if(!isdefined(self.trigs[trig]))
		return false;
	return true;
}

doend(item, msg1, msg2)
{
    while(true)
    {
        self waittill("trigger", player);
        if(!player hastrigger(item))
        {
            player addtrigger(item);
            iprintln(msg1 + player.name + msg2);
        }
    }
}

jumppad(which, strength, vector, checkGround)
{
    trigger = getEnt (which, "targetname");
    trigger2 = getEnt ("bullseye", "targetname");

    trigger2 waittill ("trigger", player);

    trigger2 delete();

    while(1)
    {
        trigger waittill ("trigger", player);

        if(player IsOnGround() || !checkGround) {
            player.health    = 1000000;
            player.maxhealth = 1000000;

            for(i=0;i<strength;i++) {
                player.health += 1000000;
                player.maxhealth += 1000000;
                player finishPlayerDamage(player, player, 160, 0, "MOD_UNKNOWN", "bounce", player.origin, AnglesToForward(vector), "none", 0);
            }
        }
        wait .05;
    }
}

connectListener()
	{
	    level endon("game_ended");
	    while (1) {
	        level waittill("connected", player);
	        player thread onPlayerSpawned();
	    }
	}
	//called from connectListener
	onPlayerSpawned() {
	    self endon("disconnect");
	    while (1) {
	        self waittill("spawned_player");
	        self thread welc_issue( "Welcome to ^5mp_phoenix^7!", "Map created by ^1Furi^7!", "Special thanks to ^2Funk^7, ^2Sycotic^7, ^2Skazy^2 for all the help!", "Credit to ^3AlterEgo^7 for creating the custom sky!", "Have fun!" );
	    }
	}
	 
	//Welcome Message
	welc_issue( welc1, welc2, welc3, welc4, welc5 )
	{
	    self endon( "intermission" );
	    self endon( "disconnect" );
	    self endon( "killthreads" );
	    self endon( "game_ended" );
	   
	    if( isDefined( self.messageDone ) )
	        return;
	       
	    self.messageDone = true;
	   
	    wait 1;
	   
	    notifyData = spawnStruct();
	    notifyData.notifyText = welc1;
	    notifyData.glowColor = (0.0, 1.0, 1.0);
	    notifyData.duration = level.welcomeduration;
	 
	    notifyData.sort = 8;
	    notifyData.hideWhenInMenu = true;
	    self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	   
	    wait( 1 );
	   
	    notifyData = spawnStruct();
	    notifyData.notifyText = welc2;
	    notifyData.glowColor = (1.0, 0.0, 0.0);
	    notifyData.duration = level.welcomeduration;
	 
	    notifyData.sort = 8;
	    notifyData.hideWhenInMenu = true;
	    self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	 
	        wait( 1);
	 
	        notifyData = spawnStruct();
	    notifyData.notifyText = welc3;
	    notifyData.glowColor = (0.0, 1.0, 0.0);
	    notifyData.duration = level.welcomeduration;
	 
	    notifyData.sort = 8;
	    notifyData.hideWhenInMenu = true;
	    self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );

		wait( 1);
	 
	        notifyData = spawnStruct();
	    notifyData.notifyText = welc4;
	    notifyData.glowColor = (0.0, 1.0, 0.0);
	    notifyData.duration = level.welcomeduration;
	 
	    notifyData.sort = 8;
	    notifyData.hideWhenInMenu = true;
	    self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );	 
	 
	        wait( 1);
	 
	        notifyData = spawnStruct();
	    notifyData.notifyText = welc5;
	    notifyData.glowColor = (1.0, 1.0, 1.0);
	    notifyData.duration = level.welcomeduration;
	 
	    notifyData.sort = 8;
	    notifyData.hideWhenInMenu = true;
	    self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}
