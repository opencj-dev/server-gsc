main()
{
	thread kill1();
	thread kill2();
	thread kill3();
}

kill1()
{
	trigger = getEnt("kill1", "targetname");
	
	while(1)
	{
		trigger waittill("trigger", player);
		
		if(player.keys == 0)
		{
            player iprintlnbold("You need a key to enter this room");
		}
		wait 5;
	}
}

kill2()
{
	trigger = getEnt("kill2", "targetname");
	
	while(1)
	{
		trigger waittill("trigger", player);
		
		if(player.keys < 2)
		{
			player iprintlnbold("You need at least 2 keys to enter this room");
		}
		wait 5;
	}
}

kill3()
{
	trigger = getEnt("kill3", "targetname");
	
	while(1)
	{
		trigger waittill("trigger", player);
		
		if(player.keys != 3)
		{
			player iprintlnbold("You need 3 keys to enter this room");
		}
		wait 5;
	}
}