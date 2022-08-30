#include openCJ\util;

onInit()
{
	level.demosBeingLoaded = []; // Not yet ready to play
	level.readyDemos = []; // Loaded to enough frames

	clearAllDemos();
	cmd = openCJ\commands_base::registerCommand("playback", "Play back an existing recording", ::_onCommandPlayback, 0, 1, 0);
	openCJ\commands_base::addAlias(cmd, "demo");
}

_onCommandPlayback(args)
{
	if(isDefined(args[0]))
	{
		query = "SELECT x, y, z, a, b, c, isKeyFrame FROM playerRecordings WHERE runID = " + int(args[0]) + " ORDER BY frameNum ASC";
		self thread _doLoadRecordingQuery(query, int(args[0]));
	}
	else
	{
		self iprintln("^1Stopped ^7playback");
		self.playingDemo = false;
		if(isDefined(self.linker))
		{
			self.linker delete();
		}
		self unlink();
	}
}

_doLoadRecordingQuery(query, demoId)
{
	level endon("map_ended");
	self endon("disconnect");

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
	if(createDemoResult == -1)
	{
		// Already loaded, great. Don't have to let the player wait!
	}
	else if(createDemoResult == -2)
	{
		// Oh no, we ran out of free space.
		printf("Ran out of free demo space... oops\n");
		return;
	}
	else // createDemoResult will be demoId
	{
		self iprintln("Loading demo..");
		thread _loadDemo(demoId, result, rowcount); // TODO: load all demos at map start, or perhaps the map before?
		while (!isDefined(level.readyDemos[demoId]))
		{
			wait .05;
		}
	}

	self iprintln("^2Demo ready to play!");

	self selectPlaybackDemo(demoId);
	self.playingDemo = true;
}

_loadDemo(demoId, result, rowcount)
{
	level endon("map_ended");
	if(isDefined(level.demosBeingLoaded[demoId]) || isDefined(level.readyDemos[demoId]))
	{
		// Already (being) loaded
		return;
	}

	level.demosBeingLoaded[demoId] = 1;

	nrDemoFramesToLoad = 300;
	for(i = 0; i < rowcount; i++)
	{
		row = mysql_fetch_row(result);
		addFrameToDemo(demoId, (int(row[0]), int(row[1]), int(row[2])), (int(row[3]), int(row[4]), int(row[5])), int(row[6]));
		if(i == nrDemoFramesToLoad)
		{
			// Allow player's demo playback to start when we have sufficient frames preloaded, but keep loading
			level.readyDemos[demoId] = 1;
		}
		else if((i > nrDemoFramesToLoad) && ((i % nrDemoFramesToLoad) == 0))
		{
			// Every time we load another batch of frames, chill for a bit.
			wait 0.05;
		}
	}

	// At this point we've loaded all frames
	level.demosBeingLoaded[demoId] = undefined;
    
    mysql_free_result(result);
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

whileAlive()
{
	if(self openCJ\login::isLoggedIn() && self openCJ\playerRuns::hasRunID() && !self openCJ\playtime::isAFK() && !self openCJ\playerRuns::isRunFinished() && !self openCJ\cheating::isCheating() && !self isPlayingDemo())
	{
		if(!self _storeFrameToDB())
		{
			self iprintlnbold("Demo recording errror? Stopping..");
		}
	}
	else if(self.playingDemo)
	{
		// If the linker wasn't created yet or is somehow gone, then restore the link
		if(!isDefined(self.linker))
		{
			self.linker = spawn("script_origin", (0, 0, 0));
			self linkto(self.linker, "", (0, 0, 0), (0, 0, 0));
		}

		if (self.playbackPaused)
		{
			return;
		}

		newFrame = self.playbackFrame;
		appliedSlowMo = false;
		if(self leftButtonPressed()) // Reverse
		{
			newFrame = self skipPlaybackFrames(-2);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self rightButtonPressed()) // Forward
		{
			newFrame = self skipPlaybackFrames(2);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self leanLeftButtonPressed()) // TODO: key frame instead of 10 frames
		{
			newFrame = self skipPlaybackFrames(-10);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self leanRightButtonPressed()) // TODO: key frame instead of 10 frames
		{
			newFrame = self skipPlaybackFrames(10);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(!self jumpButtonPressed()) // Nothing interesting pressed
		{
			newFrame = self nextPlaybackFrame();
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else // Jump button: slow motion
		{
			// Grab info of previous frame
			oldOrigin = self readPlaybackFrame_origin();
			oldAngles = self readPlaybackFrame_angles();

			// Grab info of next frame
			nextFrame = self nextPlaybackFrame();
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();

			// Interpolate. Every 4 
			slowMoCount = 4; // 1 / 4 -> 0.25.
			newOrigin = vectorScale(newOrigin, self.slowmoCount / slowMoCount) + vectorScale(oldOrigin, 1 - (self.slowmoCount / slowMoCount));
			newAngles = vectorScale(newAngles, self.slowmoCount / slowMoCount) + vectorScale(oldAngles, 1 - (self.slowmoCount / slowMoCount));

			// If we reached slowMoCount, it means we are finished with the current frame.
			self.slowmoCount++;
			if(self.slowmoCount == slowMoCount)
			{
				// We actually went to new frame
				newFrame = nextFrame;
				self.slowmoCount = 0;
			}
			else
			{
				appliedSlowMo = true;
				self prevPlaybackFrame();
			}
		}

		// Player is linked, so update linker origin and player angles for this frame
		self.linker.origin = newOrigin;
		self setPlayerAngles(newAngles);

		// Check if demo ended. TODO: loop if player enabled it
		if ((newFrame != 0) && (newFrame == self.playbackFrame) && !appliedSlowMo)
		{
			self.playingDemo = false;
			self.linker delete();
			self unlink();
			self iprintln("Demo ended");
			return;
		}

		// Remember where we left off so we know if the demo is ended
		self.playbackFrame = newFrame;
	}
}

_storeFrameToDB()
{
	// We send every frame to the server..
	origin = self.origin;
	angles = self getPlayerAngles();
	/*result = addFrameToDemo(self openCJ\playerRuns::getRunID(), (int(origin[0]), int(origin[1]), int(origin[2])), (int(angles[0]), int(angles[1]), int(angles[2])), false); // TODO: isKeyFrame
	if(!isDefined(result))
	{
		printf("Demo for player %s doesn't exist, stopping adding frames!\n" + self.name);
		if(isDefined(self.recordLongQueryID))
		{
			self openCJ\mySQL::mySQLAsyncLongQueryFree(self.recordLongQueryID);
			self.recordLongQueryID = undefined;
		}
		return false;
	}*/

	// ..but we don't store to db every frame, that would overload db
	// We build a long query with multiple frames
	if(!isDefined(self.recordLongQueryID))
	{
		self.recordLongQueryID = self openCJ\mySQL::mysqlAsyncLongQuerySetup();
		self.recordLongQueryFrameCount = 1;
		self.recordLongQueryRemainingChars = 10240; // 10 kB allowed
		baseQuery = "SELECT ";
	}
	else
	{
		baseQuery =  ", ";
		self.recordLongQueryFrameCount++;
	}

	query = baseQuery + "storeDemoFrame(" + self openCJ\playerRuns::getRunID() + ", " + self openCJ\playerRuns::getRunInstanceNumber() + ", "
					+ openCJ\playTime::getFrameNumber() + ", " + origin[0] + ", " + origin[1] + ", " + origin[2] + ", "
					+ angles[0] + ", " + angles[1] + ", " + angles[2]
					+ ", 1)";
	
	// Let's append these frames to the query
	self openCJ\mySQL::mySQLAsyncLongQueryAppend(self.recordLongQueryID, query);
	self.recordLongQueryRemainingChars -= query.size;

	// Sync to db if there is not enough room left in the max allowed long query size, or if we reached 200 frames (10 seconds)
	if((self.recordLongQueryRemainingChars < 250) || (self.recordLongQueryFrameCount >= 200))
	{
		self thread _executeStoreQuery(self.recordLongQueryID);
		self.recordLongQueryID = undefined; // This will in turn reset the frame count
	}
	return true;
}

_executeStoreQuery(queryID)
{
	self endon("disconnect");
	rows = self openCJ\mySQL::mysqlAsyncLongQueryExecuteSave(queryID);
	if(isDefined(rows) && rows.size)
	{
		for(i = 0; i < rows[0].size; i++)
		{
			if(rows[0][i] != "0")
			{
				continue;
			}

			self iprintln("Storing failed because this run was loaded by another profile");
			break;
		}
	}
	
}