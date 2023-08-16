 main()
{


/////////////////////////////////////////////////

 	maps\mp\_load::main();
	//maps\mp\_farbssong::main();
	//maps\mp\_burnsong::main();
	//maps\mp\_nowsong::main();
        maps\mp\_teleport::main();

 game["allies"] = "marines";
 game["axis"] = "opfor";
 game["attackers"] = "axis";
 game["defenders"] = "allies";
 game["allies_soldiertype"] = "desert";
 game["axis_soldiertype"] = "desert";
 
 setdvar( "r_specularcolorscale", "9" );

 setdvar("r_glowbloomintensity0",".25");
 setdvar("r_glowbloomintensity1",".25");
 setdvar("r_glowskybleedintensity0",".3");
 setdvar("compassmaxrange","1800");
 setdvar("jump_slowdownEnable", "0" );
 setdvar("bg_falldamagemaxheight", "9999" );
 setdvar("bg_falldamageminheight", "9998" );
  
  thread getPlayer();
 thread msgwelcome();
 thread onPlayerConnect();
 thread msgpro();
 thread msgthanks();
 thread msghardfinish();
 thread msghardroof();
 thread msginter();
 thread msginterroof();
 thread msgeasyroof();
 thread msgfinishedeasy();
}
getPlayer()
{
	return getEntArray( "player", "classname" );
}
onPlayerConnect()
{
	level endon("game_ended");
	
	for(;;)
	{
		level waittill("connected", player);
		
		player thread credits();
	}
}
 
/////////////////////////////////////////////////////////
msgwelcome()
{
    trig = getent("msgwelcome","targetname");

    while (1)
    {
        trig waittill ("trigger", user );
        if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.welcome ) ))
        {
            wait 6;
            if (isDefined(user))
            {
                user iprintlnbold ("Welcome to ^5mp_palm_v2");
                user iprintlnbold ("Map created by ^1Furi"); 

                user.welcome = true;
            }
        }
        wait .05;
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////
credits()
{
	self waittill("spawned_player");

    self iprintln("Easy will require 250-125 FPS");
    self iprintln("Thanks to Wez, V!RuS, Sycotic, Thee and Bone");
}
//////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
msgpro()
{
trig = getent("msgpro","targetname");

 while (1)
 {
  trig waittill ("trigger", user );
  if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.pro ) ))
     {
   iprintlnbold ("" + user.name + " is ^4Pro^7!");
   user.pro = true;
     }
 
 wait .05;
 }
}
/////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
msgthanks()
{
trig = getent("msgthanks","targetname");

 while (1)
 {
  trig waittill ("trigger", user );
  if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.thanks ) ))
     {
   iprintlnbold ("Hope you ^1Enjoyed ^7mp_palm_v2!");
   user.thanks = true;
     }
 
 wait .05;
 }
}
/////////////////////////////////////////////////////////////////////////////////////////////
msghardfinish()
{
trig = getent("msghardfinish","targetname");

 while (1)
 {
  trig waittill ("trigger", user );
  if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.hard ) ))
     {
   iprintlnbold ("" + user.name + " has finished ^1Hard Way!");
user iprintlnbold ("Map created by ^1Furi");  
   user.hard = true;
     }
 
 wait .05;
 }
}
/////////////////////////////////////////////////////////////////////////////////////////////
msghardroof()
{
trig = getent("msghardroof","targetname");

 while (1)
 {
  trig waittill ("trigger", user );
  if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.hardroof ) ))
     {
   iprintlnbold ("" + user.name + " has landed on ^1Hard ^7roof!");
   user.hardroof = true;
     }
 
 wait .05;
 }
}
/////////////////////////////////////////////////////////////////////////////////////////////
msginter()
{
trig = getent("msginter","targetname");

 while (1)
 {
  trig waittill ("trigger", user );
  if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.interfinish ) ))
     {
   user iprintlnbold ("" + user.name + " you finished ^4Inter Way!");
user iprintlnbold ("Map created by ^1Furi");  
   user.interfinish = true;
     }
 
 wait .05;
 }
}
/////////////////////////////////////////////////////////////////////////////////////////////
msginterroof()
{
trig = getent("msginterroof","targetname");

 while (1)
 {
  trig waittill ("trigger", user );
  if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.interroof ) ))
     {
   user iprintlnbold ("" + user.name + " you landed on ^4Inter ^7roof!");
   user.interroof = true;
     }
 
 wait .05;
 }
}
/////////////////////////////////////////////////////////////////////////////////////////////
msgfinishedeasy()
{
trig = getent("msgfinishedeasy","targetname");

 while (1)
 {
  trig waittill ("trigger", user );
  if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.easyfinish ) ))
     {
   user iprintlnbold ("" + user.name + " you finished ^2Easy Way!");
user iprintlnbold ("Map created by ^1Furi");  
   user.easyfinish = true;
     }
 
 wait .05;
 }
}
/////////////////////////////////////////////////////////////////////////////////////////////
msgeasyroof()
{
trig = getent("msgeasyroof","targetname");

 while (1)
 {
  trig waittill ("trigger", user );
  if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.easyroof ) ))
     {
   user iprintlnbold ("" + user.name + " you landed on ^2Easy ^7roof!");
   user.easyroof = true;
     }
 
 wait .05;
 }
}
/////////////////////////////////////////////////////////////////////////////////////////////

