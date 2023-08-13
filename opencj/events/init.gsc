#include openCJ\util;

main()
{
    openCJ\mySQL::onInit();
    openCJ\settings::onInit();

    openCJ\timeLimit::onInit();
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
    openCJ\elevate::onInit();
    openCJ\showRecords::onInit();
    openCJ\mapPatches::onInit();
    openCJ\statistics::onInit();
    openCJ\huds\infiniteHuds::onInit();
    openCJ\huds\hudFps::onInit();
    openCJ\huds\hudFpsHistory::onInit();
    openCJ\huds\hudStatistics::onInit();
    openCJ\huds\hudOnScreenKeyboard::onInit();
    openCJ\huds\hudProgressBar::onInit();
    openCJ\huds\hudRunInfo::onInit();
    openCJ\huds\hudSpeedometer::onInit();
    openCJ\fps::onInit();
    openCJ\vote::onInit();
    openCJ\graphics::onInit();
    openCJ\playerNames::onInit();
    openCJ\playerCollision::onInit();
    openCJ\menus\endMapVote::onInit();
    openCJ\menus\leaderBoard::onInit(); // To be safe, this one should always be called later than checkpoints::onInit
    openCJ\menus\runsBoard::onInit(); // ^ this one too.
    openCJ\menus\ingame::onInit();
    openCJ\tas::onInit();
    openCJ\playerRuns::onInit();

    openCJ\platformDetect::onInit(); //debug file

    thread _everyFrame();
}

_everyFrame()
{
    while(true)
    {
        openCJ\events\onFrame::main();
        wait 0.05;
    }
}
