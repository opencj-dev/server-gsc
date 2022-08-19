#include openCJ\util;

main()
{
	openCJ\mySQL::onInit();
	openCJ\settings::onInit();

	openCJ\mapID::onInit();
	openCJ\checkpoints::onInit();
	openCJ\checkpointPointers::onInit();
	openCJ\savePosition::onInit();
	openCJ\commands_base::onInit();
	openCJ\commands::onInit();
	openCJ\settings::onInit();
	openCJ\shellShock::onInit();
	openCJ\spawnpoints::onInit();
	openCJ\playerModels::onInit();
	openCJ\weapons::onInit();
	openCJ\cvars::onInit();
	openCJ\menus::onInit();
	openCJ\mapCleanup::onInit();
	openCJ\speedMode::onInit();
	openCJ\noclip::onInit();
	openCJ\historySave::onInit();
	openCJ\demos::onInit();
	openCJ\chat::onInit();
	openCJ\onscreenKeyboard::onInit();
	openCJ\progressBar::onInit();
	openCJ\elevate::onInit();
	openCJ\infiniteHuds::onInit();
	openCJ\showRecords::onInit();
	openCJ\stockPatch::onInit();
	openCJ\fpsHistory::onInit();
	openCJ\vote::onInit();
	openCJ\graphics::onInit();
	openCJ\statistics::onInit();

	thread _everyFrame();

	// Do NOT call any onInit() functions after here.
	thread openCJ\settings::onCompletedInit(); // Executes queries
}

_everyFrame()
{
	while(true)
	{
		openCJ\events\onFrame::main();
		wait 0.05;
	}
}
