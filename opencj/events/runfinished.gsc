#include openCJ\util;

main(cp, tOffset) //tOffset = -50 to 0, offset when cp was actually passed
{
    cpID = openCJ\checkpoints::getCheckPointID(cp);
    if (isDefined(cpID))
    {
        if(self openCJ\playerRuns::hasRunID())
        {
            runID = self openCJ\playerRuns::getRunID();
            self iprintln("Finished run (" + runID + ")");

            if (self openCJ\checkpoints::checkpointHasID(cp))
            {
                self openCJ\playTime::setTimePlayed(self openCJ\playTime::getTimePlayed() + tOffset);
                timePlayed = self openCJ\playTime::getTimePlayed();
                self thread openCJ\checkpoints::storeCheckpointPassed(runID, cpID, timePlayed);
                self thread _notifyFinishedMap(runID, cpID, timePlayed);
            }
        }
    }
	self thread openCJ\playerRuns::onRunFinished(cp);
	self openCJ\checkpointPointers::onRunFinished(cp);
    self openCJ\tas::onRunFinished();
	self openCJ\showRecords::onRunFinished(cp);
	self openCJ\huds\hudProgressBar::onRunFinished(cp);
	self openCJ\elevate::onRunFinished(cp);
	self openCJ\playTime::onRunFinished(cp);
	self openCJ\events\eventHandler::onRunFinished(cp);
    self openCJ\statistics::onRunFinished();
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