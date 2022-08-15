#include openCJ\util;

main(cp, tOffset) //tOffset = -50 to 0, offset when cp was actually passed
{
	if(self openCJ\playerRuns::hasRunID() && self openCJ\checkpoints::checkpointHasID(cp))
	{
		runID = self openCJ\playerRuns::getRunID();
		cpID = self openCJ\checkpoints::getCheckpointID(cp);
		self openCJ\statistics::setTimePlayed(self openCJ\statistics::getTimePlayed() + tOffset);
		timePlayed = self openCJ\statistics::getTimePlayed();
		self thread openCJ\checkpoints::storeCheckpointPassed(runID, cpID, timePlayed);
		self thread _notifyFinishedMap(runID, cpID, timePlayed);
	}
	self thread openCJ\playerRuns::onRunFinished(cp);
	self openCJ\statistics::onRunFinished(cp);
	self openCJ\checkpointPointers::onRunFinished(cp);
	self openCJ\showRecords::onRunFinished(cp);
	self openCJ\progressBar::onRunFinished(cp);
	self openCJ\elevate::onRunFinished(cp);
}

_notifyFinishedMap(runID, cpID, timePlayed)
{
	self endon("disconnect");
	self notify("mapFinishNotify");
	self endon("mapFinishNotify");
	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT MIN(cs.timePlayed) FROM checkpointStatistics cs INNER JOIN playerRuns pr ON pr.runID = cs.runID WHERE cs.cpID = " + cpID + " AND pr.finishcpID IS NOT NULL AND pr.runID != " + runID);
	if(rows.size && isDefined(rows[0][0]))
	{
		diff = timePlayed - int(rows[0][0]);
		if(diff > 0)
			self iprintlnbold("You finished the map ^1+" + formatTimeString(diff, false));
		else if( diff < 0)
			self iprintlnbold("You finished the map ^2-" + formatTimeString(-1 * diff, false));
		else
			self iprintlnbold("You finished the map, no difference");
	}
	else
		self iprintlnbold("You finished the map");
}