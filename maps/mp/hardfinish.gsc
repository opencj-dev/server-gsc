main()
{
	thread finish_hard();

}

finish_hard()
{
	
	trigger = getent("end_hard","targetname");
	
	
	while(1)
    {
		trigger waittill("trigger", player);
		
		if ( isPlayer( player ) && isAlive( player ) && isdefined( player.finish ) )
			wait 1;
		else 
		{
			player playSound("finishsong"); 
			player.blackscreen = newclienthudelem(player);
			player.blackscreen setshader("black",640,480);
			player.blackscreen.horzAlign = "fullscreen"; 
			player.blackscreen.vertAlign = "fullscreen";



			player.credits = newclienthudelem(player);
			player.credits.sort = 99999;
			player.credits.x = 325; 
			player.credits.y = 615;                       
			player.credits.alignX = "center";
			player.credits.horzAlign = "fullscreen";
			player.credits.alignY = "bottom";
			player.credits.font = "default";
			player.credits.fontScale = 1.5;   
			
			//player.credits.glowcolor = (0, 1, 0);
			//player.credits.glowalpha = 0.7;
		   // player.credits3.color = (1, 1, 1);
			player.credits.label = &"^1Congratulations &&1";
			player.credits setplayernamestring(player);
			player.credits FadeOverTime( 2 );  
			player.credits.alpha = 1;
			player.credits moveovertime(2);
			player.credits.x = 325; 
			player.credits.y = 90;   


			player.credits1 = newclienthudelem(player);
			player.credits1.sort = 99998;
			player.credits1.x = 325; 
			player.credits1.y = 650; 
			player.credits1.alignX = "center";
			player.credits1.horzAlign = "fullscreen";
			player.credits1.alignY = "bottom";
			player.credits1.font = "default";
			player.credits1.fontScale = 1.5;
			//player.credits1.glowcolor = (0, 1, 0);
			//player.credits1.glowalpha = 0.7;
		   // player.credits1.color = (1, 1, 1);
			player.credits1.label = &" You have completed the ^1Extreme Way!";
			player.credits1 FadeOverTime( 2 );  
			player.credits1.alpha = 1;
			player.credits1 moveovertime(2);
			player.credits1.x = 325; 
			player.credits1.y = 125;




			player.credits2 = newclienthudelem(player);
			player.credits2.sort = 99997;
			player.credits2.x = 325; 
			player.credits2.y = 720; 
			player.credits2.alignX = "center";
			player.credits2.horzAlign = "fullscreen";
			player.credits2.alignY = "bottom";
			player.credits2.font = "default";
			player.credits2.fontScale = 1.5;
			//player.credits2.glowcolor = (0, 1, 0);
			//player.credits2.glowalpha = 0.7;   
		   // player.credits2.color = (1, 1, 1);
			player.credits2.label = &"^1Map by ^5Ultimate ^7- ^1XF:^5Ultimater95";
		   
			player.credits2 FadeOverTime( 2 );  
			player.credits2.alpha = 1;
			player.credits2 moveovertime(2);
			player.credits2.x = 325; 
			player.credits2.y = 195;





			player.credits3 = newclienthudelem(player);
			player.credits3.sort = 99996;
			player.credits3.x = 325; 
			player.credits3.y = 790; 
			player.credits3.alignX = "center";
			player.credits3.horzAlign = "fullscreen";
			player.credits3.alignY = "bottom";
			player.credits3.font = "default";
			player.credits3.fontScale = 1.5;
			//player.credits3.glowcolor = (0,1,0);
			//player.credits3.glowalpha = 0.7;   
		   // player.credits3.color = (1, 1, 1);
			player.credits3.label = &"Go visit our website ^6http://forum.explicitbouncers.co.uk/";
			player.credits3 FadeOverTime( 2 );  
			player.credits3.alpha = 1;
			player.credits3 moveovertime(2);
			player.credits3.x = 325; 
			player.credits3.y = 265;


			player.credits4 = newclienthudelem(player);
			player.credits4.sort = 99996;
			player.credits4.x = 325; 
			player.credits4.y = 825; 
			player.credits4.alignX = "center";
			player.credits4.horzAlign = "fullscreen";
			player.credits4.alignY = "bottom";
			player.credits4.font = "default";
			player.credits4.fontScale = 1.5;
			//player.credits4.glowcolor = (0,1,0);
			//player.credits4.glowalpha = 0.7;   
			//player.credits4.color = (1, 1, 1);
			player.credits4.label = &"^1Thanks to ^5Nicki^1,^5Trikx^1,^5Tommy^1,^5Slash^1,^5Player^1,^5Tonzo^1,^5Kzr^1,^5Domi^1,^5Darkangel^1, ^5Woodz^1,^5Seven ^1and ^5Busta ^1For Helping/Testing";
			player.credits4 FadeOverTime( 2 );  
			player.credits4.alpha = 1;
			player.credits4 moveovertime(2);
			player.credits4.x = 325; 
			player.credits4.y = 300;








			player.credits5 = newclienthudelem(player);
			player.credits5.sort = 99996;
			player.credits5.x = 325; 
			player.credits5.y = 950; 
			player.credits5.alignX = "center";
			player.credits5.horzAlign = "fullscreen";
			player.credits5.alignY = "bottom";
			player.credits5.font = "default";
			player.credits5.fontScale = 1.5;
			//player.credits5.glowcolor = (0,1,0);
			//player.credits5.glowalpha = 0.7;   
			//player.credits5.color = (1, 1, 1);
			player.credits5.label = &"  ";
			player.credits5 FadeOverTime( 2 );  
			player.credits5.alpha = 1;
			player.credits5 moveovertime(2);
			player.credits5.x = 325; 
			player.credits5.y = 210;

			player.credits6 = newclienthudelem(player);
			player.credits6.sort = 99996;
			player.credits6.x = 325; 
			player.credits6.y = 930; 
			player.credits6.alignX = "center";
			player.credits6.horzAlign = "fullscreen";
			player.credits6.alignY = "bottom";
			player.credits6.font = "default";
			player.credits6.fontScale = 1.5;
			//player.credits6.glowcolor = (0.45,1,2);
			//player.credits6.glowalpha = 0.7;   
		   // player.credits6.color = (0.75, 0.4, 2);
			player.credits6.label = &"^7THE END";
			player.credits6 FadeOverTime( 2 );  
			player.credits6.alpha = 1;
			player.credits6 moveovertime(2);
			player.credits6.x = 325; 
			player.credits6.y = 370;




			wait 3;

			player.credits destroy();
			player.credits1 destroy();
			player.credits2 destroy();
			player.credits3 destroy();
			player.credits4 destroy();
			player.credits5 destroy(); 

			wait 1;

			
			player.credits6.alpha = 0.9;
			wait 0.1;
			player.credits6.alpha = 0.8;
			wait 0.1;
			player.credits6.alpha = 0.7;
			wait 0.1;
			player.credits6.alpha = 0.6;
			wait 0.1;
			player.credits6.alpha = 0.5;
			wait 0.1;
			player.credits6.alpha = 0.4;
			wait 0.1;
			player.credits6.alpha = 0.3;
			wait 0.1;
			player.credits6.alpha = 0.2;
			wait 0.1;
			player.credits6.alpha = 0.1;
			wait 0.1;
			player.credits6 destroy();
			wait 0.2 ;
			player.blackscreen.alpha=0.9;
			wait 0.05;
			player.blackscreen.alpha=0.8;
			wait 0.05;
			player.blackscreen.alpha=0.7;
			wait 0.05;
		   player.blackscreen.alpha=0.6;
			wait 0.05;
			player.blackscreen.alpha=0.5;
			wait 0.05;
			player.blackscreen.alpha=0.4;
			wait 0.05;
			player.blackscreen.alpha=0.3;
			wait 0.05;
			player.blackscreen.alpha=0.2;
			wait 0.05;
			player.blackscreen.alpha=0.1;
			wait 0.05;
			
			player.blackscreen destroy();
			
			player.finish= true;
			iprintln (player.name + " ^7has finished ^1Extreme Way^7!");
		}
	}
}