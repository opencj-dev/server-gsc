#include openCJ\util;

onInit()
{
	thread _prepareAllDemos();
	
}

_prepareAllDemos()
{
	openCJ\mySQL::mysqlAsyncQuery("SELECT prepareAllDemos()");
}

onBounced()
{
	self.eventQueue["bounced"] = true;
}
onConnect()
{
	self.eventQueue = [];
}

onSpawnPlayer()
{
	self.eventQueue = [];
}

onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	self.eventQueue = [];
}

onSuicideRequest()
{
	self.eventQueue["suicide"] = true;
}

onRPGFired(rpg, name)
{
	self.eventQueue["rpg"] = true;
}

onSavePositionRequest()
{
	self.eventQueue["save"] = true;
}

onLoadPositionRequest(backwardsAmount)
{
	self.eventQueue["load"] = self openCJ\savePosition::incrementBackwardsCount(backwardsAmount);
}

whileSpectating()
{
	//todo: handle spec loads here
}

onPlayerDisconnect()
{
	self _flushLongDemoQuery();
}

onRunFinished(cp)
{
	self _flushLongDemoQuery();
}

onStartDemo()
{
	self _flushLongDemoQuery();
}

onMapChanging()
{
	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i] _flushLongDemoQuery();
	}
}

onSpawnSpectator()
{
	self _flushLongDemoQuery();
	self.eventQueue = [];
}

whileAlive()
{
	anyEvents = false;
	eventsCreateQuery = undefined;
	if(isDefined(self.eventQueue["suicide"]))
	{
		self suicide();
	}
	else
	{
		eventsCreateQuery = "(SELECT createEvent(";
		if(isDefined(self.eventQueue["rpg"]))
		{
			eventsCreateQuery += "1, ";
			anyEvents = true;
		}
		else
		{
			eventsCreateQuery += "NULL, ";
		}
		if(isDefined(self.eventQueue["save"]))
		{
			error = self openCJ\savePosition::canSaveError();
			if(error)
			{
				self openCJ\savePosition::printCanSaveError(error);
				eventsCreateQuery += "NULL, ";
			}
			else
			{
				saveNum = self openCJ\events\savePosition::main();
				eventsCreateQuery += saveNum + ", ";
				anyEvents = true;
			}
		}
		else
		{
			eventsCreateQuery += "NULL, ";
		}
		if(isDefined(self.eventQueue["load"]))
		{
			error = self openCJ\savePosition::canLoadError(self openCJ\savePosition::getBackwardsCount());
			if(error)
			{
				self openCJ\savePosition::printCanLoadError(error);
				eventsCreateQuery += "NULL";
			}
			else
			{
				saveNum = self openCJ\events\loadPosition::main(self openCJ\savePosition::getBackwardsCount());
				if(isDefined(saveNum))
				{
					eventsCreateQuery += saveNum;
					anyEvents = true;
				}
				else
				{
					eventsCreateQuery += "NULL";
				}
			}
		}
		else
		{
			eventsCreateQuery += "NULL";
		}
		
	}
	if(!anyEvents)
	{
		eventsCreateQuery =  "NULL";
	}
	else
	{
		eventsCreateQuery += "))";
	}
	if(self isPlayerReady() && !self openCJ\playTime::isAFK() && !self openCJ\playerRuns::isRunFinished() && !self openCJ\cheating::isCheating() && self openCJ\playerRuns::hasRunStarted())
	{
		self _storeFrameToDB(eventsCreateQuery);
	}
	self.eventQueue = [];
}

_flushLongDemoQuery()
{
	if(!isDefined(self.recordLongQueryID))
	{
		return; //nothing in buffer
	}
	self thread _executeStoreQuery(self.recordLongQueryID);
	self.recordLongQueryID = undefined; // This will in turn reset the frame count
}

_storeFrameToDB(eventsCreateQuery)
{

	origin = self.origin;
	angles = angle2short(self getPlayerAngles());

	if(!isDefined(self.recordLongQueryID))
	{
		self.recordLongQueryID = self openCJ\mySQL::mysqlAsyncLongQuerySetup();
		self.recordLongQueryFrameCount = 1;
		self.recordLongQueryRemainingChars = 10240; // 10 kB allowed
		baseQuery = "SELECT storeDemoFrame(";
		endQuery = ")";
	}
	else
	{
		baseQuery =  ", (SELECT storeDemoFrame(";
		endQuery = "))";
		self.recordLongQueryFrameCount++;
	}
	flags = 0;
	if(self leftButtonPressed())
	{
		flags |= 1;
	}
	if(self rightButtonPressed())
	{
		flags |= 2;
	}
	if(self forwardButtonPressed())
	{
		flags |= 4;
	}
	if(self backButtonPressed())
	{
		flags |= 8;
	}
	if(self sprintButtonPressed())
	{
		flags |= 16;
	}
	if(self jumpButtonPressed())
	{
		flags |= 32;
	}
	if(self isSprinting())
	{
		flags |= 64;
	}
	if(self isMantling())
	{
		flags |= 128;
	}
	if(self isOnLadder())
	{
		flags |= 256;
	}
	stance = self getStance();
	//printf(stance + "\n");
	if(stance == "stand")
	{
		flags |= 512;
	}
	else if(stance == "duck" || stance == "crouch")
	{
		flags |= 1024;
	}
	else if(stance == "lie" || stance == "prone")
	{
		flags |= 2048;
	}
	if(openCJ\weapons::isRPG(self getCurrentWeapon()))
	{
		flags |= 4096;
	}
	if(self isOnGround())
	{
		flags |= 8192;
	}
	if(isDefined(self.eventQueue["bounced"]))
	{
		flags |= 16384;
	}

	frameTime = int(1000 / self openCJ\fps::getCurrentFPS());

	query = baseQuery + self openCJ\playerRuns::getRunID() + ", "
					+ self openCJ\playerRuns::getRunInstanceNumber() + ", "
					+ openCJ\playTime::getFrameNumber() + ", "
					+ origin[0] + ", " + origin[1] + ", " + origin[2] + ", "
					+ angles[0] + ", " + angles[1] + ", " + angles[2] + ", "
					+ flags + ", "
					+ eventsCreateQuery + ", "
					+ frameTime
					+ endQuery;
	
	// Let's append these frames to the query
	self openCJ\mySQL::mySQLAsyncLongQueryAppend(self.recordLongQueryID, query);
	self.recordLongQueryRemainingChars -= query.size;
	//printf(query + "\n");

	// Sync to db if there is not enough room left in the max allowed long query size, or if we reached 200 frames (10 seconds)
	if((self.recordLongQueryRemainingChars < 250) || (self.recordLongQueryFrameCount >= 200))
	{
		self _flushLongDemoQuery();
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