main()
{
	maps\mp\_load::main();
	teleport();

	trigwords("map", "^5Map by 3xP' Noob");
	trigwords("thankstest", "^5Thanks to all testers who gave feedback and made this map possible, you know who you are! \n ^5Big thanks to ^2Funk^5, ^2Leejey ^5and  ^2Gheetah ^5for constant testing!");
	trigwords("thanks3xp", "^5Thanks to all members of the ^63xP' Clan ^5for support and bug finding! \n ^2mp_bouncebuilder ^5is the fucking best");
	trigwords("thankshelp", "^7Massive thanks to: \n  ^3Sheep Wizard^5 (speedrun script creator), \n ^3BUSH1DO^5, ^3ZeeZ^5, ^3Viruz^5, ^3Mirko^5, ^3IzNoGod^5, ^5and ^3Skazy \n ^5for scripting, debugging, and  mapping help!");
	trigwords("congrats", "^3Congratulations, you have finished the map! \n ^5Now go and beat the best times! \n ^2Leaderboard is at spawn!");
	trigwords("roofland", "^5oooh look at mr.pro landing on the roof!");
	trigwords("gg", "gg wp");
	trigwords("bhoppro", "^5Damn, bunnyhop pro!");
	
	thread onPlayerConnect();
	
	thread door_slider();
	thread keydoor();
	thread rotate();
	thread secret();
	
	thread key("key1");
	thread key("key2");
	thread key("key3");
	thread key("key4");
	thread key("key5");

	thread keyroom();
}

teleport()
{
	entTransporter = getentarray( "enter", "targetname" );
	if(isdefined(entTransporter))
		for( i = 0; i < entTransporter.size; i++ )
			entTransporter[i] thread transporter();
}

transporter()
{
	for(;;)
	{
		self waittill( "trigger", player );
		entTarget = getEnt( self.target, "targetname" );
		player setOrigin( entTarget.origin );        
		wait 0.1;
	}
}

onPlayerConnect()
{
	while(true)
	{
		level waittill("connecting", player);
		player thread onConnected();
		player.keys = [];
		player.keys["key1"] = 0;
		player.keys["key2"] = 0;
		player.keys["key3"] = 0;
		player.keys["key4"] = 0;
		player.keys["key5"] = 0;
	}
}

onConnected()
{
	self endon("disconnect");
	self waittill("connected");
	self setclientdvar("r_specular", "1");
}

countkeys()
{
	return self.keys["key1"] + self.keys["key2"] + self.keys["key3"] + self.keys["key4"] + self.keys["key5"];
}

key(name)
{
	trig = getEnt(name, "targetname");
	while(true)
	{
		trig waittill ("trigger", player);
		player.keys[name] = 1;
		keys = player countkeys();
		if(keys < 5)
			player iprintln("^7You have found ^2" + keys + " ^7of ^25 ^7keys!");
		else
			player iprintln("^7You have found all 5 keys!");
	}
}

keyroom()
{
	trig = getEnt ("keyroom", "targetname");
	while(true)
	{
		trig waittill ("trigger", player);
		if(player countkeys() == 5)
			continue;
		else
		{
			player iprintlnbold ("^5To enter this room you must first find the ^25 ^5hidden keys!");
			player suicide();
			player iprintlnbold("^1Access Denied motherfucker!");
		}
	}
}

trigwords(trigname, message)
{
	trigs = getentarray(trigname, "targetname");
	for(i = 0; i < trigs.size; i++)
		trigs[i] thread showwords(message);
}

showwords(message)
{
	while(true)
	{
		self waittill("trigger", player);
		player iprintlnbold(message);
		wait 5;
	}
}

door_slider() 
{ 
	door = getent( "door", "targetname" ); 
	trig = getent( "doortrig", "targetname" ); 
	while(true) 
	{ 
		trig waittill ( "trigger" ); 
		door movez ( 170, 2, 0, 0.6 ); 
		door waittill ( "movedone" ); 
		wait 15;
		door movez( -170, 2, 0, 0.6 ); 
		door waittill ( "movedone" ); 
	} 
}

rotate()
{
	brush = getEnt("rotate", "targetname");
	while(1)
	{
		brush rotateyaw (360, 10);
		wait 9;
	}
}

secret()
{
	trig = getEnt("secret", "targetname");
	while(true)
	{
		trig waittill("trigger", player);
		if(player countkeys() == 5)
		{
			iprintln("^2" + player.name + "^5 got to the secret first!");
			trig delete();
		}
	}
}

keydoor() 
{ 
	keydoor = getent( "keydoor", "targetname" ); 
	trig = getent( "keydoortrig", "targetname" );
	while(true)
	{
		trig waittill("trigger", player);
		keys = player countkeys();
		if(keys == 0)
			player iprintln ("^7You need to find ^25 ^7keys to open the door!");
		else if(keys < 5)
			player iprintln("^7You need to find ^2" + (5 - keys) + " ^7more key to open the door!");
		else
		{
			player iprintln ("^5Welcome, ^7" + player.name);
			keydoor movez ( -180, 2, 0, 0.6 ); 
			keydoor waittill ( "movedone" ); 
			wait 2;
			keydoor movez( 180, 2, 0, 0.6 ); 
			keydoor waittill ( "movedone" ); 
		}
	}
}