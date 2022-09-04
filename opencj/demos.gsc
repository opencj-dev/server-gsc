#include openCJ\util;

onInit()
{
	level.demosBeingLoaded = []; // Not yet ready to play
	level.readyDemos = []; // Loaded to enough frames

	clearAllDemos();
	cmd = openCJ\commands_base::registerCommand("playback", "Play back an existing recording", ::_onCommandPlayback, 0, 2, 0);
	openCJ\commands_base::addAlias(cmd, "demo");
	openCJ\settings::addSettingBool("loopdemo", false, "Loop demos");
}

_onCommandPlayback(args)
{
	if(isDefined(args[0]))
	{
		if(isDefined(args[1]) && args[1] == "keyframes")
		{
			self thread _doLoadRecordingQuery(int(args[0]), int(args[0]) + 1073741824, true);
		}
		else
		{
			self thread _doLoadRecordingQuery(int(args[0]), int(args[0]), false);
		}
	}
	else
	{
		self iprintln("^1Stopped ^7playback");
		self thread doNextFrame(::_stopDemo);
	}
}

_doLoadRecordingQuery(runID, demoId, perfectRun)
{
	level endon("map_ended");
	self endon("disconnect");

	query = "SELECT prepareDemo(" + runID + ")";
	openCJ\mySQL::mysqlAsyncQuery(query);
	if(perfectRun)
	{
		keyFrames = "pr.isKeyFrame = 1 AND ";
	}
	else
	{
		keyFrames = "";
	}
	query = "SELECT pr.x, pr.y, pr.z, pr.a, pr.b, pr.c, pr.isKeyFrame, pr.flags, ev.saveNum, ev.loadNum, ev.rpg, pr.frameTime FROM playerRecordings pr LEFT JOIN demoEvents ev ON pr.eventID = ev.eventID WHERE " + keyFrames + "runID = " + runID + " ORDER BY frameNum ASC";

	//printf("query: " + query + "\n");
	result = openCJ\mySQL::mysqlAsyncQueryNoRows(query);
	if(!isDefined(result) || (result == 0))
	{
		iprintln("Bad result from demo query");
		return;
	}

	rowcount = mysql_num_rows(result);
	if(rowcount == 0)
	{
		self iprintln("Demo was not found!");
		return;
	}

	self iprintln("^2Starting ^7playback");
	self.playbackFrame = 0;
	self.playbackPaused = false;
	self.slowmoCount = 0;

	// Check if the demo was already previously loaded
	createDemoResult = createDemo(demoId);
	// -1 -> already loaded
	// -2 -> no free spots (if this happens we should just increase it, for now it's 512)
	if(createDemoResult == -2)
	{
		// Oh no, we ran out of free space.
		printf("Ran out of free demo space... oops\n");
		return;
	}
	else if(createDemoResult == -1)
	{
		// Already loaded, great. Don't have to let the player wait!
	}
	else // createDemoResult will be demoId
	{
		self iprintln("Loading demo..");
		if(rowcount > 300)
		{
			self _loadDemo(demoID, result, 300, false);
			self thread _loadDemo(demoID, result, rowcount - 300, true);
		}
		else
		{
			self _loadDemo(demoID, result, rowcount, false);
			mysql_free_result(result);
		}
	}
	self iprintln("^2Demo ready to play!");
	self.demoPreviousStance = "stand";
	self.demoPreviousState = "none";
	self.demoPreviousWeapon = "default";
	self.demoPreviousFPS = undefined;
	self.demoPreviousOnGround = true;
	self.demoPerfectRun = perfectRun;
	self startDemo(demoID);
}

startDemo(demoID)
{
	self openCJ\events\startDemo::main();
	self.demoID = demoID;
	self.playingDemo = true;
	self unlink();
	self linkto(self.demoLinker, "", (0, 0, 0), (0, 0, 0));
	self selectPlaybackDemo(demoId);
	self skipPlaybackFrames(-1 * numberOfDemoFrames(demoID));

}

_loadDemo(demoId, result, framecount, lazyLoad)
{
	level endon("map_ended");
	for(i = 0; i < framecount; i++)
	{
		row = mysql_fetch_row(result);
		saved = isDefined(row[8]);
		loaded = isDefined(row[9]);
		rpg = isDefined(row[10]);
		flags = int(row[7]);
		frameTime = int(row[11]);
		if(frameTime == 0)
			fps = 1000;
		else
			fps = int(1000 / frameTime);
		angles = short2angle((int(row[3]), int(row[4]), int(row[5])));
		addFrameToDemo(demoId, (float(row[0]), float(row[1]), float(row[2])), angles, int(row[6]), flags, saved, loaded, rpg, fps);
		if((i > 300) && ((i % 300) == 0) && lazyLoad)
		{
			// Every time we load another batch of frames, chill for a bit.
			wait 0.05;
		}
	}
	if(lazyLoad)
	{
		mysql_free_result(result);
	}
}

isPlayingDemo()
{
	return self.playingDemo;
}

onPlayerConnect()
{
	self.playingDemo = false;
	self.playbackFrame = 0;
	self.playbackPaused = false;
	self.demoLinker = spawn("script_origin", (0, 0, 0));
}

onPlayPauseDemo()
{
	self.playbackPaused = !self.playbackPaused;
	if(self.playbackPaused)
	{
		self iprintln("Playback paused");
	}
	else
	{
		self iprintln("Playback resumed");
	}
}

whilePlayingDemo()
{
	keyframes = false;
	self linkTo(self.demoLinker, "", (0, 0, 0), (0, 0, 0));
	if (self.playbackPaused)
	{
		return;
	}

	if(self leftButtonPressed()) // Reverse
	{
		if(keyframes)
		{
			newFrame = self skipPlaybackKeyFrames(-2);
		}
		else
		{
			newFrame = self skipPlaybackFrames(-2);
		}
		newOrigin = self readPlaybackFrame_origin();
		newAngles = self readPlaybackFrame_angles();
		saveNow = self readPlaybackFrame_saveNow();
		loadNow = self readPlaybackFrame_loadNow();
		rpgNow = self readPlaybackFrame_rpgNow();
		flags = self readPlaybackFrame_flags();
		FPS = self readPlaybackFrame_FPS();
		if(saveNow)
		{
			self iprintlnbold("saved");
		}
		if(loadNow)
		{
			self iprintlnbold("loaded");
		}
		if(rpgNow)
		{
			self iprintlnbold("rpg");
		}
	}
	else if(self rightButtonPressed()) // Forward
	{
		if(keyframes)
		{
			newFrame = self skipPlaybackKeyFrames(2);
		}
		else
		{
			newFrame = self skipPlaybackFrames(2);
		}
		newOrigin = self readPlaybackFrame_origin();
		newAngles = self readPlaybackFrame_angles();
		saveNow = self readPlaybackFrame_saveNow();
		loadNow = self readPlaybackFrame_loadNow();
		rpgNow = self readPlaybackFrame_rpgNow();
		flags = self readPlaybackFrame_flags();
		FPS = self readPlaybackFrame_FPS();
		if(saveNow)
		{
			self iprintlnbold("saved");
		}
		if(loadNow)
		{
			self iprintlnbold("loaded");
		}
		if(rpgNow)
		{
			self iprintlnbold("rpg");
		}
	}
	else if(self leanLeftButtonPressed()) // TODO: key frame instead of 10 frames
	{
		if(keyframes)
		{
			newFrame = self skipPlaybackKeyFrames(-10);
		}
		else
		{
			newFrame = self skipPlaybackFrames(-10);
		}
		newOrigin = self readPlaybackFrame_origin();
		newAngles = self readPlaybackFrame_angles();
		saveNow = self readPlaybackFrame_saveNow();
		loadNow = self readPlaybackFrame_loadNow();
		rpgNow = self readPlaybackFrame_rpgNow();
		flags = self readPlaybackFrame_flags();
		FPS = self readPlaybackFrame_FPS();
		if(saveNow)
		{
			self iprintlnbold("saved");
		}
		if(loadNow)
		{
			self iprintlnbold("loaded");
		}
		if(rpgNow)
		{
			self iprintlnbold("rpg");
		}
	}
	else if(self leanRightButtonPressed()) // TODO: key frame instead of 10 frames
	{
		if(keyframes)
		{
			newFrame = self skipPlaybackKeyFrames(10);
		}
		else
		{
			newFrame = self skipPlaybackFrames(10);
		}
		newOrigin = self readPlaybackFrame_origin();
		newAngles = self readPlaybackFrame_angles();
		saveNow = self readPlaybackFrame_saveNow();
		loadNow = self readPlaybackFrame_loadNow();
		rpgNow = self readPlaybackFrame_rpgNow();
		flags = self readPlaybackFrame_flags();
		FPS = self readPlaybackFrame_FPS();
		if(saveNow)
		{
			self iprintlnbold("saved");
		}
		if(loadNow)
		{
			self iprintlnbold("loaded");
		}
		if(rpgNow)
		{
			self iprintlnbold("rpg");
		}
	}
	else if(!self jumpButtonPressed()) // Nothing interesting pressed
	{
		if(keyframes)
		{
			newFrame = self nextPlaybackKeyFrame();
		}
		else
		{
			newFrame = self nextPlaybackFrame();
		}
		newOrigin = self readPlaybackFrame_origin();
		newAngles = self readPlaybackFrame_angles();
		saveNow = self readPlaybackFrame_saveNow();
		loadNow = self readPlaybackFrame_loadNow();
		rpgNow = self readPlaybackFrame_rpgNow();
		flags = self readPlaybackFrame_flags();
		FPS = self readPlaybackFrame_FPS();
		if(saveNow)
		{
			self iprintlnbold("saved");
		}
		if(loadNow)
		{
			self iprintlnbold("loaded");
		}
		if(rpgNow)
		{
			self iprintlnbold("rpg");
		}
	}
	else // Jump button: slow motion
	{
		// Grab info of previous frame
		oldOrigin = self readPlaybackFrame_origin();
		oldAngles = self readPlaybackFrame_angles();

		// Grab info of next frame
		if(keyframes)
		{
			newFrame = self nextPlaybackKeyFrame();
		}
		else
		{
			newFrame = self nextPlaybackFrame();
		}
		newOrigin = self readPlaybackFrame_origin();
		newAngles = self readPlaybackFrame_angles();

		// Interpolate. Every 4 
		slowMoCount = 4; // 1 / 4 -> 0.25.
		loadNow = self readPlaybackFrame_loadNow();
		if(!loadNow)
		{
			newOrigin = vectorScale(newOrigin, self.slowmoCount / slowMoCount) + vectorScale(oldOrigin, 1 - (self.slowmoCount / slowMoCount));
			newAngles = vectorScale(newAngles, self.slowmoCount / slowMoCount) + vectorScale(oldAngles, 1 - (self.slowmoCount / slowMoCount));
		}

		// If we reached slowMoCount, it means we are finished with the current frame.
		self.slowmoCount++;
		FPS = self readPlaybackFrame_FPS();
		flags = self readPlaybackFrame_flags();
		if(self.slowmoCount == slowMoCount)
		{
			// We actually went to new frame
			self.slowmoCount = 0;
			saveNow = self readPlaybackFrame_saveNow();
			rpgNow = self readPlaybackFrame_rpgNow();
			
			if(saveNow)
			{
				self iprintlnbold("saved");
			}
			if(loadNow)
			{
				self iprintlnbold("loaded");
			}
			if(rpgNow)
			{
				self iprintlnbold("rpg");
			}
		}
		else
		{
			loadNow = false;
			flags = flags & ~16384; //remove bounce flag of slowmo'd frames
			if(keyframes)
			{
				newFrame = self prevPlaybackKeyFrame();
			}
			else
			{
				newFrame = self prevPlaybackFrame();
			}
		}
	}
	self.playbackFrame = newFrame;
	//printf("flags:" + flags +"\n");
	// Player is linked, so update linker origin and player angles for this frame
	if((flags & 4096) != 0)
	{
		weapon = "rpg";
	}
	else
	{
		weapon = "default";
	}
	if(weapon != self.demoPreviousWeapon)
	{
		//self iprintlnbold("switched to " + weapon);
		self.demoPreviousWeapon = weapon;
	}


	if((!loadNow || self.demoPerfectRun) && newFrame != 1)
	{
		self.demoLinker.origin = newOrigin;
		self setPlayerAngles(newAngles);
		self openCJ\weapons::switchToDemoWeapon(weapon == "rpg");
	}
	else
	{
		self unlink();
		self spawn(newOrigin, newAngles);
		self.demoLinker.origin = newOrigin;
		self linkto(self.demoLinker, "", (0, 0, 0), (0, 0, 0));
		self setPlayerAngles(newAngles);
		self openCJ\events\spawnPlayer::setDemoSpawnVars(weapon == "rpg");
		self openCJ\fpsHistory::clearAndSetDemoFPS(openCJ\fpsHistory::getShortFPS(FPS));
	}
	forward = (flags & 4) != 0;
	back = (flags & 8) != 0;
	left = (flags & 1) != 0;
	right = (flags & 2) != 0;
	jump = (flags & 32) != 0;
	sprint = (flags & 16) != 0;
	self openCJ\onscreenKeyboard::showKeyboardDemo(forward, back, left, right, jump, sprint);

	if((flags & 1024) != 0)
	{
		stance = "duck";
	}
	else if((flags & 2048) != 0)
	{
		stance = "lie";
	}
	else
	{
		stance = "stand";
	}
	if(stance != self.demoPreviousStance)
	{
		self iprintlnbold("stance changed to " + stance);
		//self setDemoStance(stance); //func broken, crashes serv
		self.demoPreviousStance = stance;
	}
	if((flags & 128) != 0)
	{
		state = "mantling";
	}
	else if((flags & 256) != 0)
	{
		state = "ladder";
	}
	else if((flags & 64) != 0)
	{
		state = "sprinting";
	}
	else
	{
		state = "none";
	}
	if(self.demoPreviousState != state)
	{
		if((state == "sprinting" && self.demoPreviousState == "none") || (state == "none" && self.demoPreviousState == "sprinting"))
			self iprintln("state changed to " + state);
		else
			self iprintlnbold("state changed to " + state);
		self.demoPreviousState = state;
	}

	onGround = (flags & 8192) != 0;
	bounceThisFrame = (flags & 16384) != 0;

	if(self.demoPreviousOnGround != onGround) //onground fps history hud should be called before fps changes
	{
		if(!onGround)
		{
			self openCJ\fpsHistory::onDemoLeaveGround(openCJ\fpsHistory::getShortFPS(FPS));
		}
		else
		{
			self openCJ\fpsHistory::onDemoLand();
		}
		self.demoPreviousOnGround = onGround;
	}

	if(bounceThisFrame)
	{
		self openCJ\fpsHistory::onDemoBounce(openCJ\fpsHistory::getShortFPS(FPS));
	}

	if(!isDefined(self.demoPreviousFPS) || self.demoPreviousFPS != FPS)
	{
		if(onGround)
		{
			self openCJ\fpsHistory::clearAndSetDemoFPS(openCJ\fpsHistory::getShortFPS(FPS));
		}
		else
		{
			self openCJ\fpsHistory::addDemoFPSHistory(openCJ\fpsHistory::getShortFPS(FPS));
		}
		self.demoPreviousFPS = FPS;
	}
	
	// Check if demo ended.
	if(newFrame == numberOfDemoFrames(self.demoID) - 1)
	{
		self _endOfDemo();
	}
}

_endOfDemo()
{
	if(self openCJ\settings::getSetting("loopdemo"))
	{
		self skipPlaybackFrames(-1 * (numberOfDemoFrames(self.demoID) - 1));
		return;
	}
	self _stopDemo();
}

_stopDemo()
{
	self.playingDemo = false;
	self.demoID = undefined;
	self unlink();
	self iprintln("Demo ended");
	if(self openCJ\savePosition::canLoadError(0) == 0)
	{
		//printf("loading\n");
		self thread openCJ\events\loadPosition::main(0);
	}
	else
	{
		//printf("spawning\n");
		self thread openCJ\events\spawnPlayer::main();
	}
}