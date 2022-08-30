#include openCJ\util;

onInit()
{
	level.demosBeingLoaded = []; // Not yet ready to play
	level.readyDemos = []; // Loaded to enough frames

	clearAllDemos();
	cmd = openCJ\commands_base::registerCommand("playback", "Play back an existing recording", ::_onCommandPlayback, 0, 1, 0);
	openCJ\commands_base::addAlias(cmd, "demo");
	openCJ\settings::addSettingBool("loopdemo", false, "Loop demos");
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
		self thread doNextFrame(::_stopDemo);
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
		addFrameToDemo(demoId, (int(row[0]), int(row[1]), int(row[2])), (int(row[3]), int(row[4]), int(row[5])), int(row[6]));
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

whileAlive()
{
	if(self isPlayerReady() && !self openCJ\statistics::isAFK() && !self openCJ\playerRuns::isRunFinished() && !self openCJ\cheating::isCheating())
	{
		if(!self _storeFrameToDB())
		{
			self iprintlnbold("Demo recording errror? Stopping..");
		}
	}
}

whilePlayingDemo()
{
	self linkTo(self.demoLinker, "", (0, 0, 0), (0, 0, 0));
	if (self.playbackPaused)
	{
		return;
	}

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
		newFrame = self skipPlaybackFrames(50);
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
		newFrame = self nextPlaybackFrame();
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
			self.slowmoCount = 0;
		}
		else
		{
			newFrame = self prevPlaybackFrame();
		}
	}
	self.playbackFrame = newFrame;

	// Player is linked, so update linker origin and player angles for this frame
	self.demoLinker.origin = newOrigin;
	self setPlayerAngles(newAngles);
	// Check if demo ended.
	printf("newframe: " + newframe + "\n");
	printf("compare: " + (numberOfDemoFrames(self.demoID) - 1) + "\n");
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
		printf("loading\n");
		self thread openCJ\events\loadPosition::main(0);
	}
	else
	{
		printf("spawning\n");
		self thread openCJ\events\spawnPlayer::main();
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

	query = baseQuery + "storeDemoFrame(" + self openCJ\playerRuns::getRunID() + ", "
					+ self openCJ\playerRuns::getRunInstanceNumber() + ", "
					+ openCJ\statistics::getFrameNumber() + ", "
					+ origin[0] + ", " + origin[1] + ", " + origin[2] + ", "
					+ angles[0] + ", " + angles[1] + ", " + angles[2] + ", "
					+ "1)";
	
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