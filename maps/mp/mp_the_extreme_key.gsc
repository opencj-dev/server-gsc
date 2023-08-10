main()
{
	thread onPlayerConnect();
	thread key1();
	thread key2();
	thread key3();
	thread door1();
	thread door2();
	thread door3();
}

onPlayerConnect()
{
    while(1)
    {
		level waittill("connected", player);
		
		player.keys = 0;
		player.key1 = 0;
		player.key2 = 0;
		player.key3 = 0;
		player.key1found = false;
		player.key2found = false;
		player.key3found = false;
		player.door1 = false;
		player.door2 = false;
		player.door3 = false;
    }
}
/////////////////////////////////////////
key1()
{
	trig = getEnt("key_acti1", "targetname");
	key = getEnt("key1", "targetname");
	
	while(1)
	{
		trig waittill("trigger", player);
		
		if(!player.key1found)
		{
			player.key1 = 1;
			player.key1found = true;
			
			player iprintlnBold("^3Congratulations ^2" + player.name + " ^3you have found an ^5Artifact^1!");
			
			player.keys = player.key1 + player.key2 + player.key3;
			
			switch(player.keys)
			{
				case 1: player iprintlnBold("You have found ^51 ^7out of ^53 ^7Artifacts!"); break;
				case 2: player iprintlnBold("You have found ^52 ^7out of ^53 ^7Artifacts!"); break;
				case 3: player iprintlnBold("You have found ^53 ^7out of ^53 ^7Artifacts!"); break;
				default: break;
			}
		}
		else
			wait 0.05;
	}
}
/////////////////////////////////////////
key2()
{
	trig = getEnt("key_acti2", "targetname");
	key = getEnt("key2", "targetname");
	
	while(1)
	{
		trig waittill("trigger", player);
		
		if(!player.key2found)
		{
			player.key2 = 1;
			player.key2found = true;
			
			player iprintlnBold("^3Congratulations ^2" + player.name + " ^3you have found an ^5Artifact^1!");
			
			player.keys = player.key1 + player.key2 + player.key3;
			
			switch(player.keys)
			{
				case 1: player iprintlnBold("You have found ^51 ^7out of ^53 ^7Artifacts!"); break;
				case 2: player iprintlnBold("You have found ^52 ^7out of ^53 ^7Artifacts!"); break;
				case 3: player iprintlnBold("You have found ^53 ^7out of ^53 ^7Artifacts!"); break;
				default: break;
			}
		}
		else
			wait 0.05;
	}
}
/////////////////////////////////////////
key3()
{
	trig = getEnt("key_acti3", "targetname");
	key = getEnt("key3", "targetname");
	
	while(1)
	{
		trig waittill("trigger", player);
		
		if(!player.key3found)
		{
			player.key3 = 1;
			player.key3found = true;
			
			player iprintlnBold("^3Congratulations ^2" + player.name + " ^3you have found an ^5Artifact^1!");
			
			player.keys = player.key1 + player.key2 + player.key3;
			
			switch(player.keys)
			{
				case 1: player iprintlnBold("You have found ^51 ^7out of ^53 ^7Artifacts!"); break;
				case 2: player iprintlnBold("You have found ^52 ^7out of ^53 ^7Artifacts!"); break;
				case 3: player iprintlnBold("You have found ^53 ^7out of ^53 ^7Artifacts!"); break;
				default: break;
			}
		}
		else
			wait 0.05;
	}
}
/////////////////////////////////////////
door1()
{
	door = getent("secret_trig1", "targetname"); //value,targetname in radiant
	trig = getent("secret_tele1", "targetname"); //trigger (use use_touch trigger to make to press F)
	
	while(1)
	{
		trig waittill("trigger", player);
		
		if(player.keys >= 1)
		{
			if(!player.door1)
			{
				if(player.keys == 1)
					player iprintlnbold("You have found ^1" + player.keys + " ^7Artifact! Come on in!");
				else
					player iprintlnbold("You have found ^1" + player.keys + " ^7Artifacts! Come on in!");
				player.door1 = true;
			}
			
			door playSound("door1");
			door rotateyaw(90, 1.5, 0.7, 0.7);
			door waittill("rotatedone");
			wait 2; // Wait 3 seconds till door close (change value if u want to door close faster/slower)
			door rotateyaw(-90, 1.5, 0.7, 0.7);
			wait 1;
			door playSound("door1");
			door waittill("rotatedone");
		}
		else
		{
			player iprintlnbold("^7To open this door, you must find at least ^61 ^7hidden ^6Artifact!");
			wait 5;
		}
	}
}
/////////////////////////////////////////
door2()
{
	door = getent("secret_trig2", "targetname"); //value,targetname in radiant
	trig = getent("secret_tele2", "targetname"); //trigger (use use_touch trigger to make to press F)
	
	while(1)
	{
		trig waittill("trigger", player);
		
		if(player.keys >= 2)
		{
			if(!player.door2)
			{
				player iprintlnbold("You have found ^1" + player.keys + " ^7Artifacts! Come on in!");
				player.door2 = true;
			}
			
			door playSound("door2");
			door moveZ(248, 4, 0.7, 0.7);
			door waittill("movedone");
			wait 3; // Wait 3 seconds till door close (change value if u want to door close faster/slower)
			door playSound("door2");
			door moveZ(-248, 4, 0.7, 0.7);
			door waittill("movedone");
		}
		else
		{
			player iprintlnbold("^7To open this door, you must find at least ^62 ^7hidden ^6Artifacts!");
			wait 5;
		}
	}
}
/////////////////////////////////////////
door3()
{
	door = getent("secret_trig3", "targetname"); //value,targetname in radiant
	trig = getent("secret_tele3", "targetname"); //trigger (use use_touch trigger to make to press F)
	
	while(1)
	{
		trig waittill("trigger", player);
		
		if(player.keys == 3)
		{
			if(!player.door3)
			{
				player iprintlnbold("You have found ^1" + player.keys + " ^7Artifacts! Come on in!");
				player.door3 = true;
			}
			
			door playSound("door2");
			door moveZ(248, 4, 0.7, 0.7);
			door waittill("movedone");
			wait 3; // Wait 3 seconds till door close (change value if u want to door close faster/slower)
			door playSound("door2");
			door moveZ(-248, 4, 0.7, 0.7);
			door waittill("movedone");
		}
		else
		{
			player iprintlnbold("^7To open this door, you must find ^63 ^7hidden ^6Artifacts!");
			wait 5;
		}
	}
}