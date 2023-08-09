/*
                                        ,   ,
                                        $,  $,     ,
                                        "ss.$ss. .s'
                                ,     .ss$$$$$$$$$$s,
                                $. s$$$$$$$$$$$$$$`$$Ss
                                "$$$$$$$$$$$$$$$$$$o$$$       ,
                               s$$$$$$$$$$$$$$$$$$$$$$$$s,  ,s
                              s$$$$$$$$$"$$$$$$""""$$$$$$"$$$$$,
                              s$$$$$$$$$$s""$$$$ssssss"$$$$$$$$"
                             s$$$$$$$$$$'         `"""ss"$"$s""
                             s$$$$$$$$$$,              `"""""$  .s$$s
                             s$$$$$$$$$$$$s,...               `s$$'  `
                         `ssss$$$$$$$$$$$$$$$$$$$$####s.     .$$"$.   , s-
                           `""""$$$$$$$$$$$$$$$$$$$$#####$$$$$$"     $.$'
                                 "$$$$$$$$$$$$$$$$$$$$$####s""     .$$$|
                                  "$$$$$$$$$$$$$$$$$$$$$$$$##s    .$$" $
                                   $$""$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"   `
                                  $$"  "$"$$$$$$$$$$$$$$$$$$$$S""""'
                             ,   ,"     '  $$$$$$$$$$$$$$$$####s
                             $.          .s$$$$$$$$$$$$$$$$$####"
                 ,           "$s.   ..ssS$$$$$$$$$$$$$$$$$$$####"
                 $           .$$$S$$$$$$$$$$$$$$$$$$$$$$$$#####"
                 Ss     ..sS$$$$$$$$$$$$$$$$$$$$$$$$$$$######""
                  "$$sS$$$$$$$$$$$$$$$$$$$$$$$$$$$########"
           ,      s$$$$$$$$$$$$$$$$$$$$$$$$#########""'
           $    s$$$$$$$$$$$$$$$$$$$$$#######""'      s'         ,
           $$..$$$$$$$$$$$$$$$$$$######"'       ....,$$....    ,$
            "$$$$$$$$$$$$$$$######"' ,     .sS$$$$$$$$$$$$$$$$s$$
              $$$$$$$$$$$$#####"     $, .s$$$$$$$$$$$$$$$$$$$$$$$$s.
   )          $$$$$$$$$$$#####'      `$$$$$$$$$###########$$$$$$$$$$$.
  ((          $$$$$$$$$$$#####       $$$$$$$$###"       "####$$$$$$$$$$
  ) \         $$$$$$$$$$$$####.     $$$$$$###"             "###$$$$$$$$$   s'
 (   )        $$$$$$$$$$$$$####.   $$$$$###" Map By Ultimate ####$$$$$$$$s$$'
 )  ( (       $$"$$$$$$$$$$$#####.$$$$$###'       XF:      .###$$$$$$$$$$"
 (  )  )   _,$"   $$$$$$$$$$$$######.$$##'  Ultimater95  .###$$$$$$$$$$
 ) (  ( \.         "$$$$$$$$$$$$$#######,,,.          ..####$$$$$$$$$$$"
(   )$ )  )        ,$$$$$$$$$$$$$$$$$$####################$$$$$$$$$$$"
(   ($$  ( \     _sS"  `"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$S$$,
 )  )$$$s ) )  .      .   `$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"'  `$$
  (   $$$Ss/  .$,    .$,,s$$$$$$##S$$$$$$$$$$$$$$$$$$$$$$$$S""        '
    \)_$$$$$$$$$$$$$$$$$$$$$$$##"  $$        `$$.        `$$.
        `"S$$$$$$$$$$$$$$$$$#"      $          `$          `$
            `"""""""""""""'         '           '           '
			
			PS. do the scripts yourself *FUCKER!*
*/
main()
{
    //precacheModel("Elysium_SC5");
	//precacheModel("playermodel_dnf_duke");
	//precacheModel("playermodel_aot_rosco_00_light");
	
	maps\mp\_load::main();
	maps\mp\mp_the_extreme_text::main();
	maps\mp\extremeteleport::main();
	maps\mp\mp_the_extreme_bounce::main();
	maps\mp\doorslide::main();
	maps\mp\key::main();
	maps\mp\music::main();
	maps\mp\mp_the_extreme_killtriggers::main();
	maps\mp\mp_the_extreme_hardfinish::main();
	maps\mp\telerotate::main();
	
	level.knockback = getDvarInt("g_knockback");

	game["allies"] = "sas";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "woodland";
	game["axis_soldiertype"] = "woodland";
	
	setdvar( "r_specularcolorscale", "1" );
	
	setdvar("r_glowbloomintensity0",".25");
	setdvar("r_glowbloomintensity1",".25");
	setdvar("r_glowskybleedintensity0",".3");
	setdvar("compassmaxrange","1800");
	setdvar("jump_slowdownenable","0");
	setDvar("bg_fallDamageMaxHeight", 9999);
	setDvar("bg_fallDamageMinHeight", 9998);
	
	thread skin1();
	//thread vips();
	thread skin2();
	thread skin3();
	
}

skin1()
{
    trigger = getent ("skin1","targetname");
    
	for(;;)
    {
        trigger waittill ("trigger", player);     
		player iprintlnbold("Sorry, this script is not available");
		wait 5;
    }
}

vips()
{
	level endon("game_ended");
	
	while(1)
	{
		level waittill("connected", player);
		
		guid = getSubStr(player getGuid(), 24);
		
		switch(guid)
		{
			case "97149715": player.vip = true; break;
			case "3b31043d": player.vip = true; break;
			default:
				player.vip = false; break;
		}
	}
}

skin2()
{
    trigger = getent ("skin2","targetname");
    
	for(;;)
    {
        trigger waittill ("trigger", player);     
		player iprintlnbold("Sorry, this script is not available");
		wait 5;
    }
}


skin3()
{
    trigger = getent ("skin3","targetname");
    
	for(;;)
    {
        trigger waittill ("trigger", player);     
		player iprintlnbold("Sorry, this script is not available");
		wait 5;
    }
}