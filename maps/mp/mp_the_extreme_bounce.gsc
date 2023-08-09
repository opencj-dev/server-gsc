main()
{
	bounce  = getEntArray("bounce", "targetname");
	
	for(i = 0;i < bounce.size;i++)
		bounce[i] thread bounce();
}

bounce()
{
	for(;;)
	{
		self waittill("trigger", player);
        player iprintln("Sorry, this script is disabled due to exploitability");
	}
}