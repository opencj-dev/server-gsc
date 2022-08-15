#include openCJ\util;

main()
{
	self openCJ\settings::onPlayerConnect();
	self openCJ\grenadeTimers::onPlayerConnect();
	self openCJ\statistics::onPlayerConnect();
	self openCJ\playerRuns::onPlayerConnect();
	self openCJ\checkpointPointers::onPlayerConnect();
	self openCJ\showRecords::onPlayerConnect();
	self openCJ\country::onPlayerConnect();
	self openCJ\events\WASDPressed::disableWASDCallback();
	self openCJ\noclip::onPlayerConnect();
	self openCJ\onscreenKeyboard::onPlayerConnect();
	self openCJ\huds::onPlayerConnect();
	self openCJ\progressBar::onPlayerConnect();
	self openCJ\infiniteHuds::onPlayerConnect();

	self thread _dummy();
	self waittill("begin");

	level notify("connected", self);

	self openCJ\events\playerConnected::main();
}

_dummy()
{
	waittillframeend;
	if(isDefined(self))
		level notify("connecting", self);
}