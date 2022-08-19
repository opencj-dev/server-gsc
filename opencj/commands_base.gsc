#include openCJ\util;

onInit()
{
	level.commands = [];
	cmd = registerCommand("help", "Shows all available commands or help for a specific function.\nUsage: !help [command] [subcommand] ..", ::_showHelp, 0, 1, 0);
	addAlias(cmd, "commands");
}

registerCommand(name, help, func, minArgs, maxArgs, minAdminLevel, setting)
{
	cmd = spawnStruct();
	cmd.help = help;
	cmd.func = func;
	cmd.minArgs = minArgs;
	cmd.maxArgs = maxArgs;
	cmd.minAdminLevel = minAdminLevel;
	cmd.setting = setting;
	cmd.alias = false;
	level.commands[name] = cmd;

	return level.commands[name];
}

addAlias(cmd, alias) // If we want specific help functions per alias, just change that here: add param help, create new struct for alias as if it's a new command.
{
	// Just register a new command with the same variables. Can't re-use command, because any changes we do in here..
	// ..such as setting a flag that this is an alias, would apply to the original command as well
	aliasCmd = registerCommand(alias, cmd.help, cmd.func, cmd.minArgs, cmd.maxArgs, cmd.minAdminLevel, cmd.setting);
	aliasCmd.alias = true;
}

onPlayerCommand(fullArgs)
{
	// fullArgs will contain the player command, such as say or say_team as well
	// "say !command" is the minimum
	if(fullArgs.size < 2)
	{
		return false;
	}

	if((fullArgs[1][0] != "!") && (fullArgs[1][0] != "."))
	{
		return false;
	}
	fullArgs[1] = getsubstr(tolower(fullArgs[1]), 1);

	// If first argument is say or say_team, it means there is possibly a command afterwards
	if((fullArgs[0] != "say") && (fullArgs[0] != "say_team"))
	{
		return false;
	}

	fullMsg = fullArgs[1];
	for(i = 2; i < fullArgs.size; i++)
	{
		fullMsg += " " + fullArgs[i];
	}
	printf(self.name + " is trying to executing command: \"" + fullMsg + "\"\n");
	//self sendLocalChatMessage(fullMsg);

	// Is it even a command we support?
	cmd = level.commands[fullArgs[1]];
	if(!isDefined(cmd))
	{
		return false;
	}

	// Does the player have sufficient permissions?
	if(self.adminLevel < cmd.minAdminLevel)
	{
		self sendLocalChatMessage("You do not have sufficient permissions to execute this command", true);
		return true; // It was a command, but permissions were incorrect. Don't interpret this as a chat message anymore.
	}

	// Get rid of say/say_team and the command itself
	args = [];
	for(i = 0; i < fullArgs.size - 2; i++)
	{
		args[i] = fullArgs[i + 2];
	}

	// Check the number of arguments is correct for this command
	if (isDefined(cmd.minArgs) && (args.size < cmd.minArgs))
	{
		self sendLocalChatMessage(cmd.help);
		return true; // It was a command, but arguments were incorrect. Don't interpret this as a chat message anymore.
	}
	if (isDefined(cmd.maxArgs) && (args.size > cmd.maxArgs))
	{
		return true; // It was a command, but arguments were incorrect. Don't interpret this as a chat message anymore.
	}

	// Command might be a setting, if so, let the settings handler deal with it
	if(isDefined(cmd.setting))
	{
		self openCJ\settings::onSetting(fullArgs[1], args); // Name of setting and the arguments
	}
	else
	{
		// Execute the command with any arguments that may have been passed
		self [[cmd.func]](args);
	}

	return true;
}

_showHelp(args)
{
	if(isDefined(args) && (args.size > 0))
	{
		// Specific help: show help for command
		value = args[0];
		cmd = level.commands[value];
		if(isDefined(cmd))
		{
			self sendLocalChatMessage(cmd.help);
		}
		else
		{
			self sendLocalChatMessage("Command not found");
		}
	}
	else
	{
		// Full help: show all commands
		availableCommands = "";
		keys = getArrayKeys(level.commands);
		// Reverse order because earliest entries are at start
		for(i = keys.size - 1; i > 0; i--)
		{
			cmd = level.commands[keys[i]];
			if(cmd.alias)
			{
				// Don't list the aliases, that will take up too much text in the chat box
				continue;
			}

			// Don't start with a space
			tmpAvailableCommands = availableCommands;
			if (i < (keys.size - 1))
			{
				tmpAvailableCommands += " ";
			}
			tmpAvailableCommands += "!" + keys[i];

			// If the string becomes too long, then send before adding this command
			if (tmpAvailableCommands.size > 80)
			{
				self sendLocalChatMessage(availableCommands);
				availableCommands = "";
			}
			else
			{
				availableCommands = tmpAvailableCommands;
			}
		}

		// There may be some commands that have not been sent, so send them now
		if (availableCommands.size > 0)
		{
			self sendLocalChatMessage(availableCommands);
		}
	}
}