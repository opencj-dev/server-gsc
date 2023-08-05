#include openCJ\util;

main()
{
	self openCJ\checkpointPointers::onCheckpointsChanged();
	self openCJ\showRecords::onCheckpointsChanged();
	self openCJ\huds\hudProgressBar::onCheckpointsChanged();
	self openCJ\elevate::onCheckpointsChanged();
	checkpoints = self openCJ\checkpoints::getCheckpoints();
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

        // Debug
		printf("Checkpoint " + openCJ\checkpoints::getCheckpointID(checkpoints[i]) + " has end checkpoints: " + str + "\n");
		printf("Route completion: " + openCJ\checkpoints::getPassedCheckpointCount(self.checkpoints_checkpoint) + " to go: " + openCJ\checkpoints::getRemainingCheckpointCount(self.checkpoints_checkpoint) + "\n");
	}
}