main()
{
	
	level.welcomeduration = 8.0;
	
	level thread onPlayerConnect();

}

onPlayerConnect()
{
	for(;;) 
	{

		level waittill( "connected", player );
		
		player.messageDone = undefined;
		
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	for( ;; )
	{
		self waittill( "spawned_player" );
		
		self thread welc_issue( "Welcome on Legacy", "Have Fun !" );
	}
}

welc_issue( welc1, welc2 )
{
	if( isDefined( self.messageDone ) )
		return;
		
	self.messageDone = true;
	
	self endon( "intermission" );
	self endon( "disconnect" );
	self endon( "killthreads" );
	self endon( "game_ended" );

	notifyData = spawnStruct();
	notifyData.notifyText = welc1;
	notifyData.glowColor = (0.5, 0.0, 0.8);
	notifyData.duration = level.welcomeduration;

	notifyData.sort = 8;
	notifyData.hideWhenInMenu = true;
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	
	wait( 1 );
	
	notifyData = spawnStruct();
	notifyData.notifyText = welc2;
	notifyData.glowColor = (1.0, 0.5, 0.0);
	notifyData.duration = level.welcomeduration;

	notifyData.sort = 8;
	notifyData.hideWhenInMenu = true;
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}
// 0.5, 0.0, 0.8 - Sexxy purple
// 1.0, 0.0, 0.0 - Epic Red
// 1.0, 0.0, 0.4 - Preppy Pink
// 0.0, 0.8, 0.0 - Epic Green
// 0.9, 1.0, 0.0 - Banana Yellow
// 1.0, 0.5, 0.0 - Burnt Orange
// 0.0, 0.5, 1.0 - Turquoise
// 0.0, 0.0, 1.0 - Deep Blue
// 0.3, 0.0, 0.3 - Deep Purple
// 0.0, 1.0, 0.0 - Light Green
// 0.5, 0.0, 0.2 - Maroon
// 0.0, 0.0, 0.0 - Black
// 1.0, 1.0, 1.0 - White
// 0.0, 1.0, 1.0 - Cyan
