main()
{
    if (getCvarInt("codversion") == 4)
    {
        level.script = toLower(getcvar("mapname"));
    }
}

onStartGameType()
{
	allowed[0] = "sd";
	allowed[1] = "bombzone";
	allowed[2] = "blocker";
	maps\mp\gametypes\_gameobjects::main(allowed);
}