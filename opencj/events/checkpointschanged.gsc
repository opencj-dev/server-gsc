#include openCJ\util;

main()
{
	self openCJ\checkpointPointers::onCheckpointsChanged();
	self openCJ\showRecords::onCheckpointsChanged();
	self openCJ\huds\hudProgressBar::onCheckpointsChanged();
	self openCJ\elevate::onCheckpointsChanged();
    self openCJ\statistics::onCheckpointsChanged();


    // Debug
	checkpoints = self openCJ\checkpoints::getCurrentChildCheckpoints();
	for(i = 0; i < checkpoints.size; i++)
	{
		str = "";
		ends = openCJ\checkpoints::getEndCheckpoints(checkpoints[i]);
        isFirstCp = true;
		for(j = 0; j < ends.size; j++)
		{
            cpID = openCJ\checkpoints::getCheckpointID(ends[j]);
            if (isDefined(cpID))
            {
                if (!isFirstCp)
                {
                    str += ", ";
                }

			    str += cpID;
                isFirstCp = false;
            }
		}
		printf("DEBUG: checkpoint " + openCJ\checkpoints::getCheckpointID(checkpoints[i]) + " has end checkpoints: " + str + "\n");
		printf("DEBUG: route completion: " + openCJ\checkpoints::getPassedCheckpointCount(self.checkpoints_checkpoint) + " to go: " + openCJ\checkpoints::getRemainingCheckpointCount(self.checkpoints_checkpoint) + "\n");
	}
}