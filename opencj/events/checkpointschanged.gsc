#include openCJ\util;

main()
{
	self openCJ\checkpointPointers::onCheckpointsChanged();
	self openCJ\showRecords::onCheckpointsChanged();
}