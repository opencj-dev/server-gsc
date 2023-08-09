#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
main()
{


	maps\mp\_load::main();

    maps\mp\_compass::setupMiniMap("compass_map_mp_atlantis2");
    setdvar("compassmaxrange","5500");

    preCacheShader("atlinfo");	
    preCacheShader("intropic");
    preCacheShader("atlend");
    preCacheShader("trident");
    preCacheShader("information");
    preCacheShader("music");
    preCacheShader("flight");
    preCacheShader("bushik2");

     preCacheShader("w1");  


      level._effect[ "portal2" ] = loadfx( "myfx/portal2" );
      myfx("portal2", (3728, 5348, -6850), (-90, 0, 0), 3 );

      
      level._effect[ "fountain" ] = loadfx( "myfx/fountain" );
      myfx("fountain", (-2035, -3201, 814), (0,90,0), 0.3 );

 
      level._effect[ "splash2" ] = loadfx( "myfx/splash2" );
      myfx("splash2", (-2038, -3408, 581), (-90,-90,0), 0.3 );



      level._effect[ "waterfall3" ] = loadfx( "myfx/waterfall3" );
      myfx("waterfall3", (-1410, 290, 1150), (-90, 0, -90), 0.3 );


      level._effect[ "waterfall3" ] = loadfx( "myfx/waterfall3" );
      myfx("waterfall3", (-1410, 490, 1150), (-90, 0, -90), 0.3 );



      level._effect[ "firefly" ] = loadfx( "myfx/firefly" );
      myfx("firefly", (2520, 6120, 2424), (0, 0, 0), 0.3 );

      level._effect[ "firefly" ] = loadfx( "myfx/firefly" );
      myfx("firefly", (372, -673, 504), (0, 0, 0), 0.3 );


      level._effect[ "firefly" ] = loadfx( "myfx/firefly" );
      myfx("firefly", (-360, 406, 432), (-90, 0, 0), 0.3 );


     //level._effect[ "firefly" ] = loadfx( "myfx/firefly" );
      //myfx("firefly", (424, -8, 430), (-90, 0, 0), 0.3 );


      level._effect[ "ring" ] = loadfx( "myfx/ring" );
      myfx("ring", (-360, 406, 432), (-90, 0, 0), 3 );


      //level._effect[ "ring" ] = loadfx( "myfx/ring" );
      //myfx("ring", (413, -8, 436), (0, 180, 0), 3 );


      level._effect[ "ring" ] = loadfx( "myfx/ring" );
      myfx("ring", (380, -627, 496), (0, 90, 0), 3 );



      level._effect[ "redlight" ] = loadfx( "myfx/redlight" );
      myfx("redlight", (3095.5, 210, -1000), (0, 0, 0), 3 );

      level._effect[ "yellowlight" ] = loadfx( "myfx/yellowlight" );
      myfx("yellowlight", (2624, -128, -2224), (0, 0, 0), 4);


      level._effect[ "yellowlight" ] = loadfx( "myfx/yellowlight" );
      myfx("yellowlight", (3264, 1136, -2256), (0, 0, 0), 3 );


      level._effect[ "yellowlight" ] = loadfx( "myfx/yellowlight" );
      myfx("yellowlight", (19312, -3232, -2368), (0, 0, 0), 4);

      level._effect[ "yellowlight" ] = loadfx( "myfx/yellowlight" );
      myfx("yellowlight", (18400, -3232, -2368), (0, 0, 0), 3);

      level._effect[ "yellowlight" ] = loadfx( "myfx/yellowlight" );
      myfx("yellowlight", (17760, -3232, -2368), (0, 0, 0), 4);

      level._effect[ "yellowlight" ] = loadfx( "myfx/yellowlight" );
      myfx("yellowlight", (17072, -3232, -2368), (0, 0, 0), 3);

      level._effect[ "yellowlight" ] = loadfx( "myfx/yellowlight" );
      myfx("yellowlight", (19312, -3760, -2368), (0, 0, 0), 4);

      level._effect[ "yellowlight" ] = loadfx( "myfx/yellowlight" );
      myfx("yellowlight", (18400, -3760, -2368), (0, 0, 0), 4);

      level._effect[ "yellowlight" ] = loadfx( "myfx/yellowlight" );
      myfx("yellowlight", (17760, -3760, -2368), (0, 0, 0), 4);

      level._effect[ "yellowlight" ] = loadfx( "myfx/yellowlight" );
      myfx("yellowlight", (17072, -3760, -2368), (0, 0, 0), 4);

    maps\mp\_killmusic::main();

    maps\mp\mp_atlantis_rotatemod::main();
    maps\mp\_teleport::main();
    maps\mp\_tele2::main();

    
    maps\mp\_kill::main();
    maps\mp\_shark::main();
    maps\mp\_nosave::main();
    maps\mp\no_rpg::main();
    maps\mp\_comblock::main();        


	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

        

	
	setdvar( "r_specularcolorscale", ".1" );
	setdvar("r_glowbloomintensity0",".1");
	setdvar("r_glowbloomintensity1",".1");
	setdvar("r_glowskybleedintensity0",".1");

    thread transporter();
    thread quake();
    thread trapdoor();
    thread trapdoor2();
    thread dveri15();
    thread slideladder();
    thread dveri2();
    thread trapdoor3();
    thread dveri3();
    thread dveri4();
    thread dveri5();
    thread lift();
    thread dveri6();
    thread dveri8();

    thread fountain();
    thread watercave();
    thread dolphin();
     

    thread dveri9();

    thread atlinfo(); 
    thread atlend();
     

    thread atlantisdoor();
    thread atlantisdoor2();
    thread atlantisdoor3();
    thread atlantisdoor4();
    thread atlantisdoor5();

    thread dveri10();
    thread dveri11();
    thread dveri12();
    thread dveri13();
    thread dveri14();
    thread dveri16();

    thread uspmp();

    thread onPlayerConnect();
    thread trident();
    thread musicpic();
    thread flightpic();
    thread informationpic();
    thread wormhole();
    thread jumper();

}
transporter()
{
	entTransporter = getentarray( "enter", "targetname" );
	if(isdefined(entTransporter))
		for( i = 0; i < entTransporter.size; i++ )
			entTransporter[i] thread transport();
}
 
transport()
{
    entTarget = getEnt( self.target, "targetname" );
	for(;;)
	{
		self waittill( "trigger", player );
      
		player setOrigin( entTarget.origin );
		player setplayerangles( entTarget.angles );
	}
}

onPlayerConnect()
{
	level endon("game_ended");
	
	for(;;)
	{
		level waittill("connected", player);
		
                player thread onPlayerSpawned();
             player thread the_bushik2();		
	}
}
onPlayerSpawned()   
{
    for(;;)
    {
        self waittill( "spawned_player" );
        self thread the_intropic();
    }

}
the_intropic()
{
                if(isDefined(self.the_intropic))
		self.the_intropic destroy();
                wait 7;

                self.the_intropic = newClientHudElem(self);
			self.the_intropic.alignX = "center";
			self.the_intropic.alignY = "top";
			self.the_intropic.horzAlign = "fullscreen";
			self.the_intropic.vertAlign = "fullscreen";
			self.the_intropic.x = 310;
			self.the_intropic.y = -450;
			self.the_intropic.alpha = 0;
			self.the_intropic.sort = 1;
			self.the_intropic.hideWhenInMenu = false;
			self.the_intropic setShader("intropic", 400, 450);
			self.the_intropic.alpha = 1;

                self.the_intropic moveOverTime(1);
                self.the_intropic.y = 20;
                wait (1.5);
                self.the_intropic moveOverTime(.5);
                self.the_intropic.x = 1000;
                wait (.5);
                self.the_intropic destroy();

                wait 0.05;
}
quake()
{
    trigger = getent("earthquake","targetname");
    while (1)
    {
        trigger waittill("trigger", user);
        user iprintlnbold("Sorry, this script is not available");
        wait 5;
    }
}
//////////////////////////////////////////////////////////////////
myfx( id, pos, angle, time )
{
	ent = createLoopEffect(Id);
	ent.v["origin"] = Pos;
	ent.v["angles"] = angle;
	ent.v["delay"] = time;

}
////////////////////////////////////////////////////////////////// 
trapdoor() 
{ 
	trapdoor = getent( "trapdoor", "targetname" ); 
	trig     = getent( "trapdoortrig", "targetname" ); 
 
	while(true) 
	{ 
		trig waittill ("trigger");
                trapdoor playsound("trapdoor"); 
		trapdoor rotateto( ( 0, 0, -90 ), 0.3); 
		trapdoor waittill ("rotatedone"); 
 
		wait 3; 
		trapdoor rotateto( ( 0, 0, 0 ), 1.7); 
		trapdoor waittill ("rotatedone"); 
	} 

}
//////////////////////////////////////////////////////////////////
trapdoor2() 
{ 
	trapdoor = getent( "trapdoor2", "targetname" ); 
	trig     = getent( "trapdoortrig2", "targetname" ); 
 
	while(true) 
	{ 
		trig waittill ("trigger"); 
                trapdoor playsound("trapdoor");
		trapdoor rotateto( ( 0, 0, -90 ), 0.3); 
		trapdoor waittill ("rotatedone"); 
 
		wait 3; 
		trapdoor rotateto( ( 0, 0, 0 ), 1.7); 
		trapdoor waittill ("rotatedone"); 
	} 
}
//////////////////////////////////////////////////////////////////
dveri15()
{
	doortrig = getEnt( "trigger_dveri15", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move15(other);
		}
	}

}

move15(other)
{

	dver1 = getEnt( "dver_l15", "targetname" );
	dver2 = getEnt( "dver_r15", "targetname" );

	self notify("doortrig_finish");
	self.doorclosed = false;
	dver1 playsound("slidedoor");
	dver1 movey(-91, 2, 0.5, 0.5);
	dver2 playsound("slidedoor");
	dver2 movey(92, 2, 0.5, 0.5);
	dver1 waittill ("movedone");
        wait 3;


	dver1 playsound("slidedoor");
	dver1 movey(91, 2, 0.5, 0.5);
	dver2 playsound("slidedoor");
	dver2 movey(-92, 2, 0.5, 0.5);
	dver1 waittill ("movedone");
	self.doorclosed = true;
}
/////////////////////////////////////////////////////////////////
slideladder()
{ 
	slideladder = getent( "slideladder", "targetname" ); 
	trig      = getent( "slideladdertrig", "targetname" ); 
 
	while(true) 
	{ 
		trig waittill ("trigger"); 
		slideladder playsound("slidedoor"); 
		slideladder movex ( -55, 2, 0.5, 0.5); 
		slideladder waittill ("movedone"); 
		wait 4; 
		slideladder playsound("slidedoor");
		slideladder movex( 55, 2, 0.5, 0.5); 
		slideladder waittill ("movedone"); 
	} 
}
//////////////////////////////////////////////////////////////////
dveri2()
{
	doortrig = getEnt( "trigger_dveri2", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move2(other);
		}
	}

}

move2(other)
{

	dver1 = getEnt( "dver_l2", "targetname" );
	dver2 = getEnt( "dver_r2", "targetname" );

	self notify("doortrig_finish");
	self.doorclosed = false;
	dver1 playsound("spikes");
	dver1 movez(82, 2, 0.5, 0.5);
	dver2 playsound("spikes");
	dver2 movez(-82, 2, 0.5, 0.5);
	dver1 waittill ("movedone");
        wait 2;


	dver1 playsound("spikes");
	dver1 movez(-82, 2, 0.5, 0.5);
	dver2 playsound("spikes");
	dver2 movez(82, 2, 0.5, 0.5);
	dver1 waittill ("movedone");
	self.doorclosed = true;
}
//////////////////////////////////////////////////////////////////
trapdoor3() 
{ 
	trapdoor = getent( "trapdoor3", "targetname" ); 
	trig     = getent( "trapdoortrig3", "targetname" ); 
 
	while(true) 
	{ 
		trig waittill ("trigger"); 
                trapdoor playsound("trapdoor");
		trapdoor rotateto( ( 0, 0, -90 ), 0.3); 
		trapdoor waittill ("rotatedone"); 
 
		wait 3; 
		trapdoor rotateto( ( 0, 0, 0 ), 1.7); 
		trapdoor waittill ("rotatedone"); 
	} 
}
//////////////////////////////////////////////////////////////////
dveri3()
{
	doortrig = getEnt( "trigger_dveri3", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move3(other);
		}
	}

}

move3(other)
{

	dver1 = getEnt( "dver_l3", "targetname" );
	dver2 = getEnt( "dver_r3", "targetname" );

	self notify("doortrig_finish");
	self.doorclosed = false;
	dver1 playsound("slidedoor2");
	dver1 movez(438, 2, 0.5, 0.5);
	dver2 playsound("slidedoor2");
	dver2 movez(-438, 2, 0.5, 0.5);
	dver1 waittill ("movedone");
        wait 2;


	dver1 playsound("slidedoor2");
	dver1 movez(-438, 2, 0.5, 0.5);
	dver2 playsound("slidedoor2");
	dver2 movez(438, 2, 0.5, 0.5);
	dver1 waittill ("movedone");
	self.doorclosed = true;
}
//////////////////////////////////////////////////////////////////
dveri4()
{
	doortrig = getEnt( "trigger_dveri4", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move4(other);
		}
	}

}

move4(other)
{

	dver1 = getEnt( "dver_l4", "targetname" );
	dver2 = getEnt( "dver_r4", "targetname" );

	self notify("doortrig_finish");
	self.doorclosed = false;
	dver1 playsound("bigdoor2");
	dver1 rotateto( (0,-70,0),6);
	dver2 playsound("bigdoor2");
	dver2 rotateto( (0,70,0),6);
	dver1 waittill ("rotatedone");
        wait 3;


	dver1 playsound("bigdoor2");
	dver1 rotateto( (0,0,0),6);
	dver2 playsound("bigdoor2");
	dver2 rotateto( (0,0,0),6);
	dver1 waittill ("rotatedone");
	self.doorclosed = true;
}
//////////////////////////////////////////////////////////////////
dveri5()
{
	doortrig = getEnt( "trigger_dveri5", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move5(other);
		}
	}

}

move5(other)
{

	dver1 = getEnt( "dver_l5", "targetname" );
	dver2 = getEnt( "dver_r5", "targetname" );

	self notify("doortrig_finish");
	self.doorclosed = false;
	dver1 playsound("slidedoor2");
	dver1 movex(79, 4, 0, 0);
	dver2 playsound("slidedoor2");
	dver2 movex(-79, 4, 0, 0);
	dver1 waittill ("movedone");
        wait 2;


	dver1 playsound("slidedoor2");
	dver1 movex(-79, 4, 0, 0);
	dver2 playsound("slidedoor2");
	dver2 movex(79, 4, 0, 0);
	dver1 waittill ("movedone");
	self.doorclosed = true;
}
/////////////////////////////////////////////////////////////////
lift()
{ 
	lift = getent( "liftgoesup", "targetname" ); 
	trig      = getent( "lifttrigger", "targetname" ); 
 
	while(true) 
	{ 
		trig waittill ("trigger"); 
		lift playsound("slidedoor2"); 
		lift movez ( 920, 4, 0.5, 0.5); 
		lift waittill ("movedone"); 
		wait 4; 
		lift playsound("slidedoor2");
		lift movez ( -920, 4, 0.5, 0.5); 
		lift waittill ("movedone"); 
	} 
}
//////////////////////////////////////////////////////////////////
dveri6()
{
	doortrig = getEnt( "trigger_dveri6", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move6(other);
		}
	}

}

move6(other)
{
        dver3 = getEnt( "dver_l63", "targetname" );
	dver1 = getEnt( "dver_l6", "targetname" );
	dver2 = getEnt( "dver_r6", "targetname" );

	self notify("doortrig_finish");
	self.doorclosed = false;
	

        dver3 playsound("spikes");
        dver3 rotateto( (0,0,-40),2);
	dver3 waittill ("rotatedone");
        

        dver1 playsound("spikes");
        dver1 movez(70, 2, 0.5, 0.5);
	dver2 playsound("spikes");
	dver2 movez(-105, 2, 0.5, 0.5);
	dver1 waittill ("movedone");
        wait 2;

        dver3 playsound("spikes");
        dver3 rotateto( (0,0,0),2);
	dver3 waittill ("rotatedone");


	dver1 playsound("spikes");
	dver1 movez(-70, 2, 0.5, 0.5);
	dver2 playsound("spikes");
	dver2 movez(105, 2, 0.5, 0.5);
	dver1 waittill ("movedone");
	self.doorclosed = true;





}
//////////////////////////////////////////////////////////////////
dveri8()
{
	doortrig = getEnt( "trigger_dveri8", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move8(other);
		}
	}

}

move8(other)
{

	dver1 = getEnt( "dver_l8", "targetname" );
	dver2 = getEnt( "dver_r8", "targetname" );
        dver3 = getEnt( "dver_r83", "targetname" );
        dver4 = getEnt( "dver_l83", "targetname" );
        

	self notify("doortrig_finish");
	self.doorclosed = false;
	dver1 playsound("slidedoor2");
	dver1 movex(480, 4, 0, 0);
	dver2 playsound("slidedoor2");
	dver2 movex(-480, 4, 0, 0);
	dver1 waittill ("movedone");
        wait 0.5;



	dver3 playsound("bigdoor");
	dver3 rotateto( (0,-70,0),5);
	dver4 playsound("bigdoor");
	dver4 rotateto( (0,70,0),5);

	dver3 waittill ("rotatedone");
        wait 4;
        dver3 playsound("bigdoor");
	dver3 rotateto( (0,0,0),5);
	dver4 playsound("bigdoor");
	dver4 rotateto( (0,0,0),5);
	dver3 waittill ("rotatedone");
	




	dver1 playsound("slidedoor2");
	dver1 movex(-480, 4, 0, 0);
	dver2 playsound("slidedoor2");
	dver2 movex(480, 4, 0, 0);
	dver1 waittill ("movedone");
	self.doorclosed = true;



}
//////////////////////////////////////////////////////////////////
dolphin()
{


   dolphin = getentarray("dolphin","targetname");


 


   for(i=0;i<dolphin.size;i++)


      dolphin[i] playLoopSound("dolphin"); 


}
//////////////////////////////////////////////////////////////////
fountain()
{


   fountain = getentarray("fountain","targetname");


 


   for(i=0;i<fountain.size;i++)


      fountain[i] playLoopSound("waterfountain"); 


}
//////////////////////////////////////////////////////////////////
watercave()
{


   watercave = getentarray("watercave","targetname");


 


   for(i=0;i<watercave.size;i++)


      watercave[i] playLoopSound("watercave"); 


}

//////////////////////////////////////////////////////////////////
dveri9()
{
	doortrig = getEnt( "trigger_dveri9", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move9(other);
		}
	}

}

move9(other)
{

	dver1 = getEnt( "dverleft", "targetname" );
	dver2 = getEnt( "dverright", "targetname" );
        dver3 = getEnt( "dverup", "targetname" );
        dver4 = getEnt( "dverdown", "targetname" );

        dver5 = getEnt( "base", "targetname" );

	self notify("doortrig_finish");
	self.doorclosed = false;
	dver1 playsound("bigdoor");
	dver1 rotateto( (0,-40,0),5);
	dver2 playsound("bigdoor");
	dver2 rotateto( (0,40,0),5);
	dver1 waittill ("rotatedone");
        wait 0.5;



	dver3 playsound("bigdoor");
	dver3 rotateto( (0,0,-70),5);
	dver4 playsound("bigdoor");
	dver4 rotateto( (0,0,55),5);

	dver3 waittill ("rotatedone");
        wait 4;
        dver3 playsound("bigdoor");
	dver3 rotateto( (0,0,0),5);
	dver4 playsound("bigdoor");
	dver4 rotateto( (0,0,0),5);
	dver3 waittill ("rotatedone");
	




	dver1 playsound("bigdoor");
	dver1 rotateto( (0,0,0),5);
	dver2 playsound("bigdoor");
	dver2 rotateto( (0,0,0),5);
	dver1 waittill ("rotatedone");
	//self.doorclosed = true;

        dver1 movez ( -332, 5, 0.5, 0.5);
        dver2 movez ( -332, 5, 0.5, 0.5);
        dver3 movez ( -332, 5, 0.5, 0.5);
        dver4 movez ( -332, 5, 0.5, 0.5);
        dver5 movez ( -332, 5, 0.5, 0.5);
dver5 waittill ("movedone");
        //wait 5;
        

        dver1 movex ( -2800, 15, 0.5, 0.5);
        dver2 movex ( -2800, 15, 0.5, 0.5);
        dver3 movex ( -2800, 15, 0.5, 0.5);
        dver4 movex ( -2800, 15, 0.5, 0.5);
        dver5 movex ( -2800, 15, 0.5, 0.5);
dver5 waittill ("movedone");
        //wait 15;

        dver1 movex ( 2800, 3, 0.5, 0.5);
        dver2 movex ( 2800, 3, 0.5, 0.5);
        dver3 movex ( 2800, 3, 0.5, 0.5);
        dver4 movex ( 2800, 3, 0.5, 0.5);
        dver5 movex ( 2800, 3, 0.5, 0.5);
dver5 waittill ("movedone");
        //wait 3;

        dver1 movez ( 332, 2, 0.5, 0.5);
        dver2 movez ( 332, 2, 0.5, 0.5);
        dver3 movez ( 332, 2, 0.5, 0.5);
        dver4 movez ( 332, 2, 0.5, 0.5);
        dver5 movez ( 332, 2, 0.5, 0.5);
dver5 waittill ("movedone");


        


      // dver1 waittill ("movedone");
      // dver2 waittill ("movedone");
      // dver3 waittill ("movedone");
      // dver4 waittill ("movedone");
      // dver5 waittill ("movedone");


       self.doorclosed = true;



}
jumper()
{
	jumpx = getent ("jump","targetname");

	while (1)
	{
		jumpx waittill ("trigger",user);
		if (user istouching(jumpx))
		{
            user thread floaty();
		}
	}
}

floaty()
{
    self endon("disconnect");
    self endon("spawned_player");
    self endon("joined_spectators");

    air1 = getent ("air1","targetname");
    air2 = getent ("air2","targetname");
    air3 = getent ("air3","targetname");
    air4 = getent ("air4","targetname");
    air5 = getent ("air5","targetname");
    air6 = getent ("air6","targetname");
    air7 = getent ("air7","targetname");
    air8 = getent ("air8","targetname");
    air9 = getent ("air9","targetname");
    air10 = getent ("air10","targetname");

    air11 = getent ("air11","targetname");
    air12 = getent ("air12","targetname");
    air13 = getent ("air13","targetname");
    air14 = getent ("air14","targetname");
    air15 = getent ("air15","targetname");
    air16 = getent ("air16","targetname");
    air17 = getent ("air17","targetname");
    air18 = getent ("air18","targetname");
    air19 = getent ("air19","targetname");
    air20 = getent ("air20","targetname");

    air21 = getent ("air21","targetname");
    air22 = getent ("air22","targetname");
    air23 = getent ("air23","targetname");
    air24 = getent ("air24","targetname");
    air25 = getent ("air25","targetname");
    air26 = getent ("air26","targetname");
    air27 = getent ("air27","targetname");
    air28 = getent ("air28","targetname");
    air29 = getent ("air29","targetname");
    air30 = getent ("air30","targetname");

    air31 = getent ("air31","targetname");
    air32 = getent ("air32","targetname");
    air33 = getent ("air33","targetname");
    air34 = getent ("air34","targetname");
    air35 = getent ("air35","targetname");
    air36 = getent ("air36","targetname");
    air37 = getent ("air37","targetname");
    air38 = getent ("air38","targetname");
    air39 = getent ("air39","targetname");
    air40 = getent ("air40","targetname");

    air41 = getent ("air41","targetname");
    air42 = getent ("air42","targetname");
    air43 = getent ("air43","targetname");
    air44 = getent ("air44","targetname");
    air45 = getent ("air45","targetname");
    air46 = getent ("air46","targetname");
    air47 = getent ("air47","targetname");
    air48 = getent ("air48","targetname");
    air49 = getent ("air49","targetname");
    air50 = getent ("air50","targetname");

    air51 = getent ("air51","targetname");
    air52 = getent ("air52","targetname");

    air = spawn ("script_model",(0,0,0));
    air.origin = self.origin;
    air.angles = self.angles;
    self linkto (air);
    self endon("disconnect");
    self endon("killed_player");
    self disableWeapons();
    self endon("joined_spectators");

    air moveto (air1.origin, 4);  
    wait 4;

    air moveto (air2.origin, 4); 
    wait 4;

    air moveto (air3.origin, 4);
    wait 4;

    air moveto (air4.origin, 4);
    wait 4;

    air moveto (air5.origin, 3);
    wait 3;

    air moveto (air6.origin, 2);
    wait 2;

    air moveto (air7.origin, 2);
    wait 2;

    air moveto (air8.origin, 2);
    wait 2;

    air moveto (air9.origin, 4);  
    wait 4;

    air moveto (air10.origin, 4); 
    wait 4;

    air moveto (air11.origin, 4);
    wait 4;

    air moveto (air12.origin, 4);
    wait 4;

    air moveto (air13.origin, 3);
    wait 3;

    air moveto (air14.origin, 3);
    wait 3;

    air moveto (air15.origin, 4);
    wait 4;

    air moveto (air16.origin, 4);
    wait 4;

    air moveto (air17.origin, 4);
    wait 4;

    air moveto (air18.origin, 4);
    wait 4;

    air moveto (air19.origin, 4);
    wait 4;

    air moveto (air20.origin, 4);
    wait 4;

    air moveto (air21.origin, 4);
    wait 4;

    air moveto (air22.origin, 4);
    wait 4;

    air moveto (air23.origin, 4);
    wait 4;

    air moveto (air24.origin, 4);
    wait 4;

    air moveto (air25.origin, 4);
    wait 4;

    air moveto (air26.origin, 4);
    wait 4;

    air moveto (air27.origin, 4);
    wait 4;

    air moveto (air28.origin, 8);
    wait 8;

    air moveto (air29.origin, 4);
    wait 4;

    air moveto (air30.origin, 4);
    wait 4;

    air moveto (air31.origin, 3);
    wait 3;

    air moveto (air32.origin, 3);
    wait 3;

    air moveto (air33.origin, 3);
    wait 3;

    air moveto (air34.origin, 3);
    wait 3;

    air moveto (air35.origin, 4);
    wait 4;

    air moveto (air36.origin, 4);
    wait 4;

    air moveto (air37.origin, 4);
    wait 4;

    air moveto (air38.origin, 8);
    wait 8;

    air moveto (air39.origin, 4);
    wait 4;

    air moveto (air40.origin, 4);
    wait 4;

    air moveto (air41.origin, 4);
    wait 4;

    air moveto (air42.origin, 4);
    wait 4;

    air moveto (air43.origin, 4);
    wait 4;

    air moveto (air44.origin, 4);
    wait 4;

    air moveto (air45.origin, 4);
    wait 4;

    air moveto (air46.origin, 4);
    wait 4;

    air moveto (air47.origin, 4);
    wait 4;

    air moveto (air48.origin, 8);
    wait 8;

    air moveto (air49.origin, 4);
    wait 4;

    air moveto (air50.origin, 4);
    wait 4;

    air moveto (air51.origin, 4);
    wait 4;

    air moveto (air52.origin, 4);
    wait 4;

    self unlink();
    self enableWeapons();
    wait 1;
}

//////////////////////////////////////////////////////////////////////////////
atlantisdoor()
{
	trigger = getent("atldoor_trigger", "targetname");
	door = getent("atldoor_platform", "targetname");
	
	     door show();
	     door solid();
	
	while(1)
	{
		trigger waittill("trigger", user);
		
		if(user getplayerangles()[0] < -80)
		{
			door hide();
			door notSolid();
		}
		else
		{
			door show();
	                door solid();
		}
		
		wait 0.05;
	}
}
//////////////////////////////////////////////////////////////////////////////
atlantisdoor2()
{
	trigger = getent("atldoor_trigger2", "targetname");
	door = getent("atldoor_platform2", "targetname");
	
	     door show();
	     door solid();
	
	while(1)
	{
		trigger waittill("trigger", user);
		
		if(user getplayerangles()[0] < -80)
		{
			door hide();
			door notSolid();
		}
		else
		{
			door show();
	                door solid();
		}
		
		wait 0.05;
	}
}
//////////////////////////////////////////////////////////////////
dveri10()
{
	doortrig = getEnt( "trigger_dveri10", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move10(other);
		}
	}

}

move10(other)
{

	dver1 = getEnt( "atl_u", "targetname" );
	dver2 = getEnt( "atl_d", "targetname" );
        dver3 = getEnt( "atl_r", "targetname" );
        dver4 = getEnt( "atl_l", "targetname" );
        dver5 = getEnt( "atl_c", "targetname" );
        dver6 = getEnt( "atl_c2", "targetname" );

	self notify("doortrig_finish");
	self.doorclosed = false;

        wait 2;
        
	dver5 playsound("bigdoor");
	dver5 rotateto( (-180,0,0),5);
        dver5 waittill ("rotatedone");

        dver5 hide();
	dver5 notSolid();
        dver6 hide();
	dver6 notSolid();


	dver1 playsound("slidedoor2");
	dver1 movez(145, 4, 0, 0);
	dver2 playsound("slidedoor2");
	dver2 movez(-145, 4, 0, 0);
	dver1 waittill ("movedone");
       


	dver3 playsound("bigdoor");
	dver3 movex(-65, 4, 0, 0);
	dver4 playsound("bigdoor");
	dver4 movex(65, 4, 0, 0);

	dver3 waittill ("movedone");


        wait 4;

        dver3 playsound("bigdoor");
	dver3 movex(65, 4, 0, 0);
	dver4 playsound("bigdoor");
	dver4 movex(-65, 4, 0, 0);

	dver3 waittill ("movedone");

       

	dver1 playsound("slidedoor2");
	dver1 movez(-145, 4, 0, 0);
	dver2 playsound("slidedoor2");
	dver2 movez(145, 4, 0, 0);
	dver1 waittill ("movedone");

        dver5 show();
	dver5 solid();
        dver6 show();
	dver6 solid();
        dver5 playsound("bigdoor");
	dver5 rotateto( (0,0,0),5);
        dver5 waittill ("rotatedone");

	self.doorclosed = true;


}
//////////////////////////////////////////////////////////////////
dveri11()
{
	doortrig = getEnt( "trigger_dveri11", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move11(other);
		}
	}

}

move11(other)
{

	dver1 = getEnt( "dver_l", "targetname" );
	dver2 = getEnt( "dver_r", "targetname" );

	self notify("doortrig_finish");
	self.doorclosed = false;

        wait 2; 
	dver1 playsound("slidedoor");
	dver1 movex(-129, 2, 0.5, 0.5);
	dver2 playsound("slidedoor");
	dver2 movex(129, 2, 0.5, 0.5);
	dver1 waittill ("movedone");
        wait 4;


	dver1 playsound("slidedoor");
	dver1 movex(129, 2, 0.5, 0.5);
	dver2 playsound("slidedoor");
	dver2 movex(-129, 2, 0.5, 0.5);
	dver1 waittill ("movedone");
	self.doorclosed = true;
}

//////////////////////////////////////////////////////////////////
dveri12()
{
	doortrig = getEnt( "dverup_trigger12", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move12(other);
		}
	}

}

move12(other)
{

	dver = getEnt( "dverup12", "targetname" );
	

	self notify("doortrig_finish");
	self.doorclosed = false;

        wait 2; 
	dver playsound("slidedoor");
	dver movex(-129, 2, 0.5, 0.5);
	dver waittill ("movedone");
        wait 4;


	dver playsound("slidedoor");
	dver movex(129, 2, 0.5, 0.5);
	dver waittill ("movedone");
	self.doorclosed = true;
}

//////////////////////////////////////////////////////////////////
dveri13()
{
	doortrig = getEnt( "rolldoor_trigger", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move13(other);
		}
	}

}

move13(other)
{

	dver = getEnt( "rolldoor", "targetname" );
	

	self notify("doortrig_finish");
	self.doorclosed = false;

        wait 2; 
	dver playsound("slidedoor");
	dver rotateto( (0,90,0),5);
	dver waittill ("rotatedone");
        wait 5;
	dver playsound("slidedoor");
	dver rotateto( (0,0,0),5);
	dver waittill ("rotatedone");

	self.doorclosed = true;
}
//////////////////////////////////////////////////////////////////
dveri14()
{
	doortrig = getEnt( "trigger_dveri14", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move14(other);
		}
	}

}

move14(other)
{

	dver1 = getEnt( "atl_b", "targetname" );

        dver2 = getEnt( "atl_t", "targetname" );
        

	self notify("doortrig_finish");
	self.doorclosed = false;

	
	dver1 movez(-15, 4, 0, 0);
        dver1 waittill ("movedone");

	dver1 playsound("turtle");
	dver2 movex(-2940, 10, 0, 0);
        dver2 waittill ("movedone");
 
	
	dver2 rotateto( (0,180,0),5);
        dver2 waittill ("rotatedone");

        wait 4;

	
	dver2 movex(2940, 10, 0, 0);
        dver2 waittill ("movedone");

	
	dver2 rotateto( (0,0,0),5);
        dver2 waittill ("rotatedone");

	
	dver1 movez(15, 4, 0, 0);
        dver1 waittill ("movedone");

      
	self.doorclosed = true;


}
atlinfo()
{ 
	atlinfo    = getent( "picture", "targetname" ); 
	
	while(true) 
	{ 
         atlinfo waittill("trigger",player);
     
      
          player.atlinfo = true;
          player thread the_atlinfo();
          wait (5);

       }

}
the_atlinfo()
{
if(isDefined(self.the_atlinfo))
		self.the_atlinfo destroy();

self.the_atlinfo = newClientHudElem(self);
			self.the_atlinfo.alignX = "center";
			self.the_atlinfo.alignY = "top";
			self.the_atlinfo.horzAlign = "fullscreen";
			self.the_atlinfo.vertAlign = "fullscreen";
			self.the_atlinfo.x = 310;
			self.the_atlinfo.y = -450;
			self.the_atlinfo.alpha = 0;
			self.the_atlinfo.sort = 1;
			self.the_atlinfo.hideWhenInMenu = false;
			self.the_atlinfo setShader("atlinfo", 400, 400);
			self.the_atlinfo.alpha = 1;
self.the_atlinfo moveOverTime(11);
self.the_atlinfo.y = 40;
wait (2);
self.the_atlinfo moveOverTime(.5);
self.the_atlinfo.x = 1000;
wait (.5);
self.the_atlinfo destroy();

wait 0.05;

}
//////////////////////////////////////////////////////////////////////////////
atlantisdoor3()
{
	trigger = getent("atldoor_trigger3", "targetname");
	door = getent("atldoor_platform3", "targetname");
	
	     door show();
	     door solid();
	
	while(1)
	{
		trigger waittill("trigger", user);
		
		if(user getplayerangles()[0] < -80)
		{
			door hide();
			door notSolid();
		}
		else
		{
			door show();
	                door solid();
		}
		
		wait 0.05;
	}
}
//////////////////////////////////////////////////////////////////////////////
atlantisdoor4()
{
	trigger = getent("atldoor_trigger4", "targetname");
	door = getent("atldoor_platform4", "targetname");
	
	     door hide();
	     door notSolid();
	
	while(1)
	{
		trigger waittill("trigger", user);
		
		if(user getplayerangles()[0] < -80)
		{
			door show();
	                door solid();
		}
		else
		{
			door hide();
	                door notSolid();
		}
		
		wait 0.05;
	}
}
//////////////////////////////TURTLE////FIN////////////////////////////////
dveri16()
{
	doortrig = getEnt( "trigger_dveri16", "targetname" );
	doortrig.doorclosed = true;

	while (1)
	{
		doortrig waittill("trigger", other);
		if(doortrig.doorclosed)
		{
			doortrig thread move16(other);
		}
	}

}

move16(other)
{

	dver1 = getEnt( "turtledoor", "targetname" );
	dver2 = getEnt( "gateway_l1", "targetname" );
        dver3 = getEnt( "gateway_r1", "targetname" );
        dver4 = getEnt( "turtlemove", "targetname" );

        dver5 = getEnt( "water_up", "targetname" );

         dver6 = getEnt( "gateway_l2", "targetname" );
         dver7 = getEnt( "gateway_r2", "targetname" );


	self notify("doortrig_finish");
	self.doorclosed = false;


        dver1 playsound("bigdoor");
	dver1 rotateto( (0,0,140),5);
        dver1 waittill ("rotatedone");
        wait 4;
        dver1 playsound("bigdoor");
	dver1 rotateto( (0,0,0),5);
	dver1 waittill ("rotatedone");
        wait 0.5;


        dver2 playsound("slidedoor2");
	dver2 movey(160, 4, 0, 0);
	dver3 playsound("slidedoor2");
	dver3 movey(-160, 4, 0, 0);
	dver2 waittill ("movedone");
        wait 0.5;

        
	dver4 movex(1950, 5, 0, 0);
        dver1 movex(1950, 5, 0, 0);
        dver4 waittill ("movedone");
        wait 0.5;

        dver2 playsound("slidedoor2");
	dver2 movey(-160, 4, 0, 0);
	dver3 playsound("slidedoor2");
	dver3 movey(160, 4, 0, 0);
	dver2 waittill ("movedone");
        wait 0.5;

        
	dver5 movez(415, 4, 0, 0);
        dver5 waittill ("movedone");
        wait 0.5;



        dver6 playsound("slidedoor2");
	dver6 movey(160, 4, 0, 0);
	dver7 playsound("slidedoor2");
	dver7 movey(-160, 4, 0, 0);
	dver6 waittill ("movedone");
        wait 0.5;

        
	dver4 movex(7500, 25, 0, 0);
        dver1 movex(7500, 25, 0, 0);
        dver4 waittill ("movedone");
        //wait 0.5;


        dver6 playsound("slidedoor2");
	dver6 movey(-160, 4, 0, 0);
	dver7 playsound("slidedoor2");
	dver7 movey(160, 4, 0, 0);
	dver6 waittill ("movedone");
        //wait 0.5;

        dver5 playsound("slidedoor2");
	dver5 movez(-415, 4, 0, 0);
        dver5 waittill ("movedone");
        //wait 0.5;


        
	dver4 movex(-9450, 4, 0, 0);
        dver1 movex(-9450, 4, 0, 0);
        dver4 waittill ("movedone");
  
        

	     
       self.doorclosed = true;



}

//////////////////////////////////////////////////////////////////////
atlend()
{ 
	atlend    = getent( "picture2", "targetname" ); 
	
	while(true) 
	{ 
         atlend waittill("trigger",player);
     
      
          player.atlend = true;
          player thread the_atlend();
          wait (2);

       }

}
the_atlend()
{
if(isDefined(self.the_atlend))
		self.the_atlend destroy();

self.the_atlend = newClientHudElem(self);
			self.the_atlend.alignX = "center";
			self.the_atlend.alignY = "top";
			self.the_atlend.horzAlign = "fullscreen";
			self.the_atlend.vertAlign = "fullscreen";
			self.the_atlend.x = 310;
			self.the_atlend.y = -700;
			self.the_atlend.alpha = 0;
			self.the_atlend.sort = 1;
			self.the_atlend.hideWhenInMenu = false;
			self.the_atlend setShader("atlend", 300, 400);
			self.the_atlend.alpha = 1;
self.the_atlend moveOverTime(3);
self.the_atlend.y = 40;
wait (4.5);
self.the_atlend moveOverTime(1);
self.the_atlend.y = 1000;
wait (1);
self.the_atlend destroy();

wait 0.05;

}
//////////////////////////////////////////////////////////////////
uspmp()
{
	end = getEnt("usp", "targetname");
	
	while(1)
	{
		end waittill("trigger", player);	
        player iprintlnbold("Sorry, this weapon is not available");
	}
}
//////////////////////////////////////////////////////////////////////////////
atlantisdoor5()
{
	trigger = getent("atldoor_trigger5", "targetname");
	door = getent("atldoor_platform5", "targetname");
	
	     door show();
	     door solid();
	
	while(1)
	{
		trigger waittill("trigger", user);
		
		if(user getplayerangles()[0] < -80)
		{
			door hide();
			door notSolid();
		}
		else
		{
			door show();
	                door solid();
		}
		
		wait 0.05;
	}
}
//////////////////////////////////////////////////////////////////////
trident()
{
    tridentTrigger("");
    for (i = 2; i < 18; i++)
    {
        tridentTrigger(i);
    }

}
tridentTrigger(val)
{
    trident = getent("hint_act" + val, "targetname"); 

    while(true) 
    { 
        trident waittill("trigger", player);

        player.trident = true;
        player thread the_trident();
        wait (1);
    }
}
the_trident()
{
    if(isDefined(self.the_trident))
        self.the_trident destroy();

    self.the_trident = newClientHudElem(self);
    self.the_trident.alignX = "centre";
    self.the_trident.alignY = "centre";

    self.the_trident.x = 275;
    self.the_trident.y = 270;
    self.the_trident.alpha = 0;
    self.the_trident.sort = 1;
    self.the_trident.hideWhenInMenu = false;
    self.the_trident setShader("trident", 60, 60);
    self.the_trident.alpha = 1;

    wait (1);
    self.the_trident destroy();

    wait 0.05;

}
musicpic()
{ 
	musicpic    = getent( "hint_act_18", "targetname" ); 
	
	while(true) 
	{ 
        musicpic waittill("trigger",player);


        player.musicpic = true;
        player thread the_musicpic();
        wait (1);
   }

}
the_musicpic()
{
    if(isDefined(self.the_musicpic))
        self.the_musicpic destroy();

    self.the_musicpic = newClientHudElem(self);
    self.the_musicpic.alignX = "centre";
    self.the_musicpic.alignY = "centre";

    self.the_musicpic.x = 275;
    self.the_musicpic.y = 270;
    self.the_musicpic.alpha = 0;
    self.the_musicpic.sort = 1;
    self.the_musicpic.hideWhenInMenu = false;
    self.the_musicpic setShader("music", 60, 60);
    self.the_musicpic.alpha = 1;

    wait (1);
    self.the_musicpic destroy();

    wait 0.05;

}
//////////////////////////////////////////////////////////////////////
flightpic()
{ 
	flightpic    = getent( "hint_act_19", "targetname" ); 
	
	while(true) 
	{ 
         flightpic waittill("trigger",player);
     
      
          player.flightpic = true;
          player thread the_flightpic();
          wait (1);

       }

}
the_flightpic()
{
if(isDefined(self.the_flightpic))
		self.the_flightpic destroy();

          self.the_flightpic = newClientHudElem(self);
			self.the_flightpic.alignX = "centre";
			self.the_flightpic.alignY = "centre";

			self.the_flightpic.x = 275;
			self.the_flightpic.y = 270;
			self.the_flightpic.alpha = 0;
			self.the_flightpic.sort = 1;
			self.the_flightpic.hideWhenInMenu = false;
			self.the_flightpic setShader("flight", 60, 60);
			self.the_flightpic.alpha = 1;

                    wait (1);
                    self.the_flightpic destroy();

                 wait 0.05;

}
//////////////////////////////////////////////////////////////////////
informationpic()
{ 
	informationpic    = getent( "hint_act_20", "targetname" ); 
	
	while(true) 
	{ 
         informationpic waittill("trigger",player);
     
      
          player.informationpic = true;
          player thread the_informationpic();
          wait (1);

       }

}
the_informationpic()
{
if(isDefined(self.the_informationpic))
		self.the_informationpic destroy();

          self.the_informationpic = newClientHudElem(self);
			self.the_informationpic.alignX = "centre";
			self.the_informationpic.alignY = "centre";

			self.the_informationpic.x = 275;
			self.the_informationpic.y = 270;
			self.the_informationpic.alpha = 0;
			self.the_informationpic.sort = 1;
			self.the_informationpic.hideWhenInMenu = false;
			self.the_informationpic setShader("information", 60, 60);
			self.the_informationpic.alpha = 1;

                    wait (1);
                    self.the_informationpic destroy();

                 wait 0.05;

}
//////////////////////////////////////////////////////////////////////
trident_10()
{ 
	trident    = getent( "hint_act_10", "targetname" ); 
	
	while(true) 
	{ 
         trident waittill("trigger",player);
     
      
          player.trident = true;
          player thread the_trident();
          wait (1);

       }

}
////////////////////////////////////////////////////////////
the_bushik2()
{
    self iprintln("Map by Bushido");
}
wormhole()
{ 
	wormhole    = getent( "picture3", "targetname" ); 
	
	while(true) 
	{ 
      wormhole waittill("trigger",player);
     
      
      player.wormhole = true;
      player thread the_wormhole();
      wait (1);

      }
}

addShaderHud( who, x, y, alignX, alignY, horiz, vert, sort ) 
{
    if (!isPlayer(who))
    {
        return;
    }

	hud = newClientHudElem( who );

	hud.x = x;
	hud.y = y;
	hud.alpha = 1;
	hud.sort = sort;
	hud.alignX = alignX;
	hud.alignY = alignY;
	if(isdefined(vert))
		hud.vertAlign = vert;
	if(isdefined(horiz))
		hud.horzAlign = horiz;		
	hud.foreground = 1;
	hud.archived = 0;
	return hud;
}

the_wormhole()
{
	if (isDefined( self.the_wormhole))
		self.the_wormhole destroy();

    self disableWeapons();
    self endon("joined_spectators");
         
	worm_shader1 = addShaderHud( self, 0, 0, "middle", "top", "fullscreen", "fullscreen", 9999999 );
	worm_shader1 setShader( "w1", 640, 480 );	
	wait 1;
	worm_shader1 destroy();
}