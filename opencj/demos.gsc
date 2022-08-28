#include openCJ\util;

onInit()
{
	clearAllDemos();
	cmd = openCJ\commands_base::registerCommand("record", "Start recording a demo", ::_onCommandRecord, 0, 0, 0);
	cmd = openCJ\commands_base::registerCommand("playback", "Play back an existing recording", ::_onCommandPlayback, 0, 1, 0);
	openCJ\commands_base::addAlias(cmd, "demo");
}

_onCommandRecord(args)
{
	if(self.recordingDemo)
	{
		self.recordingDemo = false;
		self iprintln("^1Stopped ^7recording");
	}
	else
	{
		self.recordingDemo = true;
		self iprintln("^2Started ^7recording");
	}
}

_onCommandPlayback(args)
{
	if(isDefined(args[0]))
	{
		self iprintln("^Starting ^7playback");
		self.recordingDemo = false;
		self.slowmoCount = 0;
		query = "SELECT x, y, z, a, b, c, isKeyFrame FROM playerRecordings WHERE runID = " + int(args[0]) + " ORDER BY frameNum ASC";
		self thread _doLoadRecordingQuery(query, int(args[0]) + "");
	}
	else
	{
		self iprintln("^1Stopped ^7playback");
		self.playingDemo = false;
		self unlink();
	}
}

_doLoadRecordingQuery(query, demoname)
{
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

	// Destroy any currently active demo and 
	self destroyDemo();
	self createDemo(demoname);

	nrDemoFramesToLoad = 300;
	for(i = 0; i < rowcount; i++)
	{
		row = mysql_fetch_row(result);
		self addFrameToDemo((int(row[0]), int(row[1]), int(row[2])), (int(row[3]), int(row[4]), int(row[5])), int(row[6]));
		if(i == nrDemoFramesToLoad)
		{
			// Start demo playback when we have enough frames preloaded, but keep loading
			self selectPlaybackDemo(demoname);
			self.playingDemo = true;
		}
		else if((i > nrDemoFramesToLoad) && ((i % nrDemoFramesToLoad) == 0))
		{
			// Every time we load another batch of frames, chill for a bit.
			wait 0.05;
		}
	}

	// At this point we've loaded all frames

	// If demo was shorter than number of frames we wanted to preload, then we still need to set playback
	if(i < nrDemoFramesToLoad)
	{
		self selectPlaybackDemo(demoname);
		self.playingDemo = true;
	}

	mysql_free_result(result);
}

onPlayerConnect()
{
	self.recordingDemo = false;
	self.playingDemo = false;
}

whileAlive()
{
	if(self.recordingDemo)
	{
		self _storeFrameToDB();
	}
	else if(self.playingDemo)
	{
		// If the linker wasn't created yet or is somehow gone, then restore the link
		if(!isDefined(self.linker))
		{
			self.linker = spawn("script_origin", (0, 0, 0));
			self linkto(self.linker, "", (0, 0, 0), (0, 0, 0));
		}

		if(self leftButtonPressed()) // Reverse
		{
			self skipPlaybackFrames(-2);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self rightButtonPressed()) // Forward
		{
			self skipPlaybackFrames(2);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self leanLeftButtonPressed()) // TODO: key frame instead of 10 frames
		{
			self skipPlaybackFrames(-10);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self leanRightButtonPressed()) // TODO: key frame instead of 10 frames
		{
			self skipPlaybackFrames(10);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self meleeButtonPressed()) 
		{
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(!self jumpButtonPressed()) // Nothing interesting pressed
		{
			self nextPlaybackFrame();
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else // Jump button: slow motion
		{
			// Grab info of previous frame
			oldOrigin = self readPlaybackFrame_origin();
			oldAngles = self readPlaybackFrame_angles();

			// Grab info of next frame
			self nextPlaybackFrame();
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
				self.slowmoCount = 0;
			}
			else
			{
				self prevPlaybackFrame();
			}
		}

		// Player is linked, so update linker origin and player angles for this frame
		self.linker.origin = newOrigin;
		self setPlayerAngles(newAngles);
	}
}

_storeFrameToDB()
{
	if(!isDefined(self.recordLongQueryID))
	{
		self.recordLongQueryID = self openCJ\mySQL::mysqlAsyncLongQuerySetup();
		self.recordLongQueryFrameCount = 1;
		self.recordLongQueryRemainingChars = 10239;
		query = "SELECT storeDemoFrame(" + self openCJ\playerRuns::getRunID() + ", " + self openCJ\playerRuns::getRunInstanceNumber() + ", " + openCJ\statistics::getFrameNumber() + ", " + self.origin[0] + ", " + self.origin[1] + ", " + self.origin[2] + ", " + self getPlayerAngles()[0] + ", " + self getPlayerAngles()[1] + ", " + self getPlayerAngles()[2] + ", 1)";
	}
	else
	{
		query =  ", storeDemoFrame(" + self openCJ\playerRuns::getRunID() + ", " + self openCJ\playerRuns::getRunInstanceNumber() + ", " + openCJ\statistics::getFrameNumber() + ", " + self.origin[0] + ", " + self.origin[1] + ", " + self.origin[2] + ", " + self getPlayerAngles()[0] + ", " + self getPlayerAngles()[1] + ", " + self getPlayerAngles()[2] + ", 1)";
		self.recordLongQueryFrameCount++;
	}
	//printf("query is: " + query + "\n");
	self openCJ\mySQL::mySQLAsyncLongQueryAppend(self.recordLongQueryID, query);
	self.recordLongQueryRemainingChars -= query.size;
	if(self.recordLongQueryRemainingChars < 250 || self.recordLongQueryFrameCount > 200)
	{
		self thread _executeStoreQuery(self.recordLongQueryID);
		self.recordLongQueryID = undefined;
	}
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
				continue;
			else
			{
				self iprintln("Storing failed because this run was loaded by another profile");
				break;
			}
		}
	}
	
}