main()
{
    if (getCvarInt("codversion") == 4)
    {
        level.script = toLower(getcvar("mapname"));
    }
}