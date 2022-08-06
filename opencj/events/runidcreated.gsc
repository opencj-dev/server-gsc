#include openCJ\util;

main(spawn)
{
	self openCJ\saveposition::onRunIDCreated();
	self openCJ\weapons::onRunIDCreated();
	self openCJ\playerRuns::onRunIDCreated();
	self openCJ\statistics::onRunIDCreated();
	self openCJ\healthRegen::onRunIDCreated();
	self openCJ\shellShock::onRunIDCreated();
	self openCJ\checkpoints::onRunIDCreated();
	self openCJ\showRecords::onRunIDCreated();
	self openCJ\cheating::onRunIDCreated();
	self openCJ\checkpointPointers::onRunIDCreated();

	if(spawn)
		self openCJ\events\spawnPlayer::main();
}