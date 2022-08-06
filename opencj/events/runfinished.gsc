#include openCJ\util;

main(cp)
{
	if(self openCJ\playerRuns::hasRunID() && self openCJ\checkpoints::checkpointHasID(cp))
	{
		runID = self openCJ\playerRuns::getRunID();
		cpID = self openCJ\checkpoints::getCheckpointID(cp);
		timePlayed = self openCJ\statistics::getTimePlayed();
		self openCJ\checkpoints::storeCheckpointPassed(runID, cpID, timePlayed);
		self thread _notifyFinishedMap(runID, cpID, timePlayed);
	}
	self openCJ\playerRuns::onRunFinished(cp);
	self openCJ\statistics::onRunFinished(cp);
	self openCJ\checkpointPointers::onRunFinished(cp);
	self openCJ\showRecords::onRunFinished(cp);
}

_notifyFinishedMap(runID, cpID, timePlayed)
{
	self endon("disconnect");
	self notify("mapFinishNotify");
	self endon("mapFinishNotify");
	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT MIN(timePlayed) FROM checkpointStatistics cs INNER JOIN playerRuns pr ON pr.runID = cs.runID WHERE cs.cpID = " + cpID + " AND pr.finishcpID IS NOT NULL AND pr.runID != " + runID + " AND finishcpID IS NOT NULL");
	if(rows.size && isDefined(rows[0][0]))
	{
		diff = timePlayed - int(rows[0][0]);
		if(diff > 0)
			self iprintlnbold("You finished the map ^1+" + diff);
		else if( diff < 0)
			self iprintlnbold("You finished the map ^2" + diff);
		else
			self iprintlnbold("You finished the map, no difference");
	}
	else
		self iprintlnbold("You finished the map");
}