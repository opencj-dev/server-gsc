#include openCJ\util;

onInit()
{
	clearAllDemos();
	openCJ\commands_base::registerCommand("record", "Record a demo to the database", ::_onCommandRecord, 0, 0, 0);
	openCJ\commands_base::registerCommand("playback", "Play back a recording", ::_onCommandPlayback, 0, 1, 0);
}

_onCommandRecord(args)
{
	if(isDefined(self.recordingDemo))
	{
		self.recordingDemo = undefined;
	}
	else
	{
		self.recordingDemo = true;
	}
}

_onCommandPlayback(args)
{
	if(isDefined(args[0]))
	{
		self.recordingDemo = undefined;
		query = "SELECT x, y, z, a, b, c, isKeyFrame FROM playerRecordings WHERE runID = " + int(args[0]) + " ORDER BY frameNum ASC";
		self _doLoadRecordingQuery(query, int(args[0]) + "");
	}
	else
	{
		self.playback = undefined;
		self unlink();
	}
}

_doLoadRecordingQuery(query, demoname)
{
	self endon("disconnect");
	result = openCJ\mySQL::mysqlAsyncQueryNoRows(query);
	if(!isDefined(result) || result == 0)
	{
		iprintln("result bad");
		return;
	}
	//printf("getting rowcount for result " + result + " \n");
	rowcount = mysql_num_rows(result);
	if(!rowcount)
	{
		self iprintln("Demo not found, go away");
		return;
	}
	self destroyDemo();
	self createDemo(demoname);
	//printf("rowcount: " + rowcount + "\n");
	for(i = 0; i < rowcount; i++)
	{
		//printf("getting a row\n");
		row = mysql_fetch_row(result);
		self addFrameToDemo((int(row[0]), int(row[1]), int(row[2])), (int(row[3]), int(row[4]), int(row[5])), int(row[6]));
		if(i == 300)
		{
			self selectPlaybackDemo(demoname);
			self.playback = true;
		}
		else if(i > 300 && i % 300 == 0)
		{
			wait 0.05;
		}
	}
	if(i <= 300)
	{
		self selectPlaybackDemo(demoname);
		self.playback = true;
	}
	//printf("done getting rows, freeing now\n");
	mysql_free_result(result);

	//printf("freeing done\n");
}

whileAlive()
{
	if(isDefined(self.recordingDemo))
	{
		self _storeFrameToDB();
	}
	if(isDefined(self.playback))
	{
		if(!isDefined(self.linker))
		{
			self.linker = spawn("script_origin", (0, 0, 0));
			self linkto(self.linker, "", (0, 0, 0), (0, 0, 0));
		}

		if(self leftButtonPressed())
		{
			self skipPlaybackFrames(-2);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self rightButtonPressed())
		{
			self skipPlaybackFrames(2);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self leanLeftButtonPressed())
		{
			self skipPlaybackFrames(-10);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self leanRightButtonPressed())
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
		else if(!self jumpButtonPressed())
		{
			self nextPlaybackFrame();
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else
		{
			if(!isDefined(self.slomoCount))
			{
				self.slomoCount = 0;
			}
			oldOrigin = self readPlaybackFrame_origin();
			oldAngles = self readPlaybackFrame_angles();
			self nextPlaybackFrame();
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
			newOrigin = vectorScale(newOrigin, self.slomoCount / 4) + vectorScale(oldOrigin, 1 - (self.slomoCount / 4));
			newAngles = vectorScale(newAngles, self.slomoCount / 4) + vectorScale(oldAngles, 1 - (self.slomoCount / 4));
			self.slomoCount++;
			if(self.slomoCount == 4)
			{
				self.slomoCount = undefined;
			}
			else
			{
				self prevPlaybackFrame();
			}
		}
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