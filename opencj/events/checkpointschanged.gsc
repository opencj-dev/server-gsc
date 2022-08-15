#include openCJ\util;

main()
{
	self openCJ\checkpointPointers::onCheckpointsChanged();
	self openCJ\showRecords::onCheckpointsChanged();
	self openCJ\progressBar::onCheckpointsChanged();
	checkpoints = self openCJ\checkpoints::getCheckpoints();
	for(i = 0; i < checkpoints.size; i++)
	{
		str = "";
		ends = openCJ\checkpoints::getEndCheckpoints(checkpoints[i]);
		for(j = 0; j < ends.size; j++)
		{
			if(j != 0)
				str += ", ";
			str += openCJ\checkpoints::getCheckpointID(ends[j]);
		}
		printf("Checkpoint " + openCJ\checkpoints::getCheckpointID(checkpoints[i]) + " has end checkpoints: " + str + "\n");
		printf("Route completion: " + openCJ\checkpoints::getPassedCheckpointCount(self.checkpoints_checkpoint) + " to go: " + openCJ\checkpoints::getRemainingCheckpointCount(self.checkpoints_checkpoint) + "\n");
	}
}