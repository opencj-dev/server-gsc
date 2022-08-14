#include openCJ\util;

main()
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
	self openCJ\speedMode::onRunIDCreated();
	self openCJ\noclip::onRunIDCreated();
	self openCJ\demos::onRunIDCreated();

	self openCJ\events\spawnPlayer::main();
}