#include openCJ\util;

main(args)
{
	if(isDefined(args[0]))
	{
		if(self openCJ\savePosition::onPlayerCommand(args))
			return;

		if(self openCJ\login::onPlayerCommand(args))
			return;

		if(self openCJ\commands::onPlayerCommand(args))
			return;

		if(args[0] == "spawn")
			self thread _doNextFrame(openCJ\events\spawnPlayer::main);
		else if(args[0] == "spectate")
			self thread _doNextFrame(openCJ\events\spawnSpectator::main);
		else if(args[0] == "kill")
			self _killNextFrame();
		else if(args[0] == "elevate")
		{
			if(isDefined(args[1]) && (args[1] == "on" || args[1] == "off"))
				self allowElevate(args[1] == "on");
		}
		else if(args[0] == "resetrun")
		{
			self openCJ\playerRuns::resetRunId();
		}
		else if(args[0] == "say" || args[0] == "say_team")
			self openCJ\chat::onChatMessage(args);
		else
			self clientCommand();
	}
}

_doNextFrame(func)
{
	waittillframeend;

	if(isDefined(self))
		self [[func]]();
}

_killNextFrame()
{
	waittillframeend;
	if(isDefined(self))
		self suicide();
}