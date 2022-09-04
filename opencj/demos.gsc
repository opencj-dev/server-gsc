#include openCJ\util;

onInit()
{
	level.demosBeingLoaded = []; // Not yet ready to play
	level.readyDemos = []; // Loaded to enough frames

	clearAllDemos();
	cmd = openCJ\commands_base::registerCommand("playback", "Play back an existing recording", ::_onCommandPlayback, 0, 1, 0);
	openCJ\commands_base::addAlias(cmd, "demo");
	underlyingCmd = openCJ\settings::addSettingBool("loopdemo", false, "Loop demos");
    openCJ\commands_base::addAlias(underlyingCmd, "loop");

    thread _prepareAllDemos();
}

_prepareAllDemos()
{
	openCJ\mySQL::mysqlAsyncQuery("SELECT prepareAllDemos()");
}

_onCommandPlayback(args)
{
	if(isDefined(args[0]))
	{
        self thread _doLoadRecordingQuery(int(args[0]), int(args[0]));
	}
	else
	{
		self iprintln("^1Stopped ^7playback");
		self thread doNextFrame(::_stopDemo);
	}
}

_doLoadRecordingQuery(runID, demoID)
{
	level endon("map_ended");
	self endon("disconnect");

	query = "SELECT prepareDemo(" + runID + ")";
	openCJ\mySQL::mysqlAsyncQuery(query);
	query = "SELECT pr.x, pr.y, pr.z, pr.a, pr.b, pr.c, pr.isKeyFrame, pr.flags, ev.saveNum, ev.loadNum, ev.rpg, pr.frameTime FROM playerRecordings pr LEFT JOIN demoEvents ev ON pr.eventID = ev.eventID WHERE runID = " + runID + " ORDER BY frameNum ASC";

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
	self.playbackPaused = false;
	self.slowmoCount = 0;

	// Check if the demo was already previously loaded
	createDemoResult = createDemo(demoID);
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
	else // createDemoResult will be demoID
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
	self.demoPreviousFPS = undefined;
	self.demoPreviousOnGround = true;
	self startDemo(demoID);
}

startDemo(demoID)
{
	self openCJ\events\startDemo::main();
	self.demoID = demoID;
	self.playingDemo = true;
	self unlink();
	self linkto(self.demoLinker, "", (0, 0, 0), (0, 0, 0));
	self selectPlaybackDemo(demoID);
	self skipPlaybackFrames(-1 * numberOfDemoFrames(demoID));

}

_loadDemo(demoID, result, framecount, lazyLoad)
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
		addFrameToDemo(demoID, (float(row[0]), float(row[1]), float(row[2])), angles, int(row[6]), flags, saved, loaded, rpg, fps);
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

_getDemoFrame(nrFramesToSkip, shouldSkipFails)
{
	if(shouldSkipFails)
	{
		newFrame = self skipPlaybackKeyFrames(nrFramesToSkip);
	}
	else
	{
		newFrame = self skipPlaybackFrames(nrFramesToSkip);
	}

	frame = spawnStruct();
	frame.origin = self readPlaybackFrame_origin();
	frame.angles = self readPlaybackFrame_angles();
	frame.saveNow = self readPlaybackFrame_saveNow();
	frame.loadNow = self readPlaybackFrame_loadNow();
	frame.rpgNow = self readPlaybackFrame_rpgNow();
	flags = self readPlaybackFrame_flags();

	frame.left = (flags & 1) != 0;
	frame.right = (flags & 2) != 0;
	frame.forward = (flags & 4) != 0;
	frame.back = (flags & 8) != 0;
	frame.sprint = (flags & 16) != 0;
	frame.jump = (flags & 32) != 0;

	frame.state = "none";
	if((flags & 128) != 0)
	{
		frame.state = "mantling";
	}
	else if((flags & 256) != 0)
	{
		frame.state = "ladder";
	}
	else if((flags & 64) != 0)
	{
		frame.state = "sprinting";
	}

	frame.stance = "stand"; //512
	if((flags & 1024) != 0)
	{
		frame.stance = "crouch";
	}
	else if((flags & 2048) != 0)
	{
		frame.stance = "prone";
	}

	if((flags & 4096) != 0)
	{
		frame.weapon = "rpg";
	}
	else
	{
		frame.weapon = "default";
	}
	frame.onGround = (flags & 8192) != 0;
	frame.bounce = (flags & 16384) != 0;
	
	frame.FPS = self readPlaybackFrame_FPS();
	frame.number = newFrame;

	return frame;
}

whilePlayingDemo()
{
	skipFails = demoHasKeyFrames(self.demoID); // TODO: temp because we don't have specific keys for skipping key frames right now
	self linkTo(self.demoLinker, "", (0, 0, 0), (0, 0, 0));
	if (self.playbackPaused)
	{
		return;
	}

	isInterpolatedFrame = false;
	if(self leftButtonPressed()) // Reverse
	{
		currFrame = _getDemoFrame(-2, skipFails);
	}
	else if(self rightButtonPressed()) // Forward
	{
		currFrame = _getDemoFrame(2, skipFails);
	}
	else if(self leanLeftButtonPressed()) // Faster forward
	{
		currFrame = _getDemoFrame(-10, skipFails);
	}
	else if(self leanRightButtonPressed()) // Faster reverse
	{
		currFrame = _getDemoFrame(10, skipFails);
	}
	else if(self jumpButtonPressed()) // Slow motion
	{
		slowmoCount = 4; // 1 / 4 -> 0.25.

		self.slowmoCount++;
		currFrame = _getDemoFrame(1, skipFails);
		if(self.slowmoCount == slowmoCount)
		{
			self.slowmoCount = 0;
		}
		else
		{
			// Grab info of previous frame
			prevFrame = _getDemoFrame(-1, skipFails);
			isInterpolatedFrame = true;
			if(!currFrame.loadNow)
			{
				// Fix angles so we don't have strange behavior when slowing
				slowmoScale = (self.slowmoCount / slowmoCount);
				currFwd = anglesToForward(currFrame.angles);
				prevFwd = anglesToForward(prevFrame.angles);
				interpFwd = vectorScale(currFwd, slowmoScale) + vectorScale(prevFwd, (1 - slowmoScale));
				if(interpFwd != (0, 0, 0))
				{
					interpAngles = vectorToAngles(interpFwd); // This already normalizes the vector

					// CoD doesn't think (...that vectors are arrays)
					// Also, the calculation for [2] is so angle 'roll' can be left untouched (normal interpolation)
					interpAngles = (interpAngles[0], interpAngles[1], (currFrame.angles[2] * slowmoScale) + (prevFrame.angles[2] * (1 - slowmoScale)));
					currFrame.angles = interpAngles;
				}

				currFrame.origin = vectorScale(currFrame.origin, slowmoScale) + vectorScale(prevFrame.origin, (1 - slowmoScale));
			}
			else
			{
				currFrame = prevFrame;
			}
		}
	}
	else
	{
		currFrame = _getDemoFrame(1, skipFails);
	}

    // In perfect run (i.e. without fails) it doesn't load, so check for keyFrame as well
	if((!currFrame.loadNow || skipFails) && (currFrame.number > 1))
	{
		self.demoLinker.origin = currFrame.origin;
		self setPlayerAngles(currFrame.angles);
		self openCJ\weapons::switchToDemoWeapon(currFrame.weapon == "rpg");
	}
	else
	{
		self unlink();
		self spawn(currFrame.origin, currFrame.angles);
		self.demoLinker.origin = currFrame.origin;
		self linkto(self.demoLinker, "", (0, 0, 0), (0, 0, 0));
		self setPlayerAngles(currFrame.angles);
		self openCJ\events\spawnPlayer::setDemoSpawnVars(currFrame.weapon == "rpg");
		self openCJ\fpsHistory::clearAndSetDemoFPS(openCJ\fpsHistory::getShortFPS(currFrame.FPS));
	}
	self openCJ\onScreenKeyboard::showKeyboardDemo(currFrame.forward, currFrame.back, currFrame.left, currFrame.right, currFrame.jump, currFrame.sprint);
	if(currFrame.stance != self.demoPreviousStance)
	{
		//self iprintlnbold("stance changed to " + currFrame.stance);
		self.demoPreviousStance = currFrame.stance;
	}
	if(currFrame.state != self.demoPreviousState)
	{
		/*if((currFrame.state == "sprinting" && self.demoPreviousState == "none") || (currFrame.state == "none" && self.demoPreviousState == "sprinting"))
			self iprintln("state changed to " + currFrame.state);
		else
			self iprintlnbold("state changed to " + currFrame.state);*/
		self.demoPreviousState = currFrame.state;
	}

	if(self.demoPreviousOnGround != currFrame.onGround) //onground fps history hud should be called before fps changes
	{
		if(!currFrame.onGround)
		{
			self openCJ\fpsHistory::onDemoLeaveGround(openCJ\fpsHistory::getShortFPS(currFrame.FPS));
		}
		else
		{
			self openCJ\fpsHistory::onDemoLand();
		}
		self.demoPreviousOnGround = currFrame.onGround;
	}

	if(currFrame.bounce && !isInterpolatedFrame)
	{
		self openCJ\fpsHistory::onDemoBounce(openCJ\fpsHistory::getShortFPS(currFrame.FPS));
	}

	if(!isDefined(self.demoPreviousFPS) || self.demoPreviousFPS != currFrame.FPS)
	{
		if(currFrame.onGround)
		{
			self openCJ\fpsHistory::clearAndSetDemoFPS(openCJ\fpsHistory::getShortFPS(currFrame.FPS));
		}
		else
		{
			self openCJ\fpsHistory::addDemoFPSHistory(openCJ\fpsHistory::getShortFPS(currFrame.FPS));
		}
		self.demoPreviousFPS = currFrame.FPS;
	}
	
	// Check if demo ended.
	if(currFrame.number == (numberOfDemoFrames(self.demoID) - 1))
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
