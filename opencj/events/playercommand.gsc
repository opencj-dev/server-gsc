#include openCJ\util;

main(args)
{
	if(isDefined(args[0]))
	{
		// No messing around, filter out special characters
		fullMsg = args[0];
		for(i = 0; i < args.size; i++)
		{
			fullMsg += " " + args[i];
		}
		if(containsIllegalChars(fullMsg))
		{
			return;
		}

		// UID related things
		if(self openCJ\login::onPlayerCommand(args))
		{
			return;
		}

		// Non-chat commands
		if(self isPlayerReady())
		{
			// save, load ..
			if(self openCJ\savePosition::onPlayerCommand(args))
			{
				return;
			}
			// Chat command: commands (kick, ignore, mute ..), settings (fov, rpgputaway, timestring ..)
			if(self openCJ\commands_base::onPlayerCommand(args))
			{
				return;
			}
			if(args[0] == "spawn")
			{
				self thread doNextFrame(openCJ\events\spawnPlayer::main);
			}
			else if(args[0] == "spectate")
			{
				self thread doNextFrame(openCJ\events\spawnSpectator::main);
			}
			else if(args[0] == "kill")
			{
				self openCJ\events\eventHandler::onSuicideRequest();
			}
			else if((args[0] == "say") || (args[0] == "say_team")) // Wrap the chat commands for ignore, mute functionality
			{
				self openCJ\chat::onChatMessage(args);
			}
            else if(args[0] == "openleaderboard")
            {
                self openMenu("opencj_leaderboard");
            }
			else
			{
				self clientCommand();
			}
		}
		else
		{
			self clientCommand();
		}
	}
}
