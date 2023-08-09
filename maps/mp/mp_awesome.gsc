main()
{

 maps\mp\_load::main();
 maps\mp\_teleport::main();
 
 //threads
	 



	game["allies"] = "sas";
	game["axis"] = "russian";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["allies_soldiertype"] = "woodland";
	game["axis_soldiertype"] = "woodland";
 
 bounce   = getEntArray("bounce", "targetname");
	for(i = 0;i < bounce.size;i++)
	bounce[i] thread bounce();
 
 
 
 
 setdvar( "r_specularcolorscale", "1" );
 
 }
 
 bounce()
{
	for(;;)
	{
		self waittill("trigger", p);
		p iprintlnbold("Sorry, this script is not available");
        wait 5;
	}
}
