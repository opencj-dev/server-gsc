#include openCJ\util;

main()
{
	self openCJ\showRecords::onStartDemo();
	self openCJ\checkpoints::onStartDemo();
	self openCJ\checkpointPointers::onStartDemo();
	self openCJ\healthRegen::onStartDemo();
	self openCJ\menus::onStartDemo();
	self openCJ\playerCollision::onStartDemo();
	self openCJ\playerNames::onStartDemo();
	self openCJ\shellShock::onStartDemo();
	self openCJ\huds\hudStatistics::onStartDemo();
	self openCJ\huds\hudFpsHistory::onStartDemo();
	self openCJ\huds\hudJumpSlowdown::onStartDemo();
	self openCJ\huds\hudOnScreenKeyboard::onStartDemo();
	self openCJ\huds\hudProgressBar::onStartDemo();
	self openCJ\huds\hudSpeedometer::onStartDemo();
	self openCJ\huds\hudPosition::onStartDemo();
	self openCJ\playerRuns::onStartDemo();
	self openCJ\events\eventHandler::onStartDemo();
	//todo: kill nextframe threads
}