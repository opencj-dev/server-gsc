main()
{
    legacyTeleporter("");
    for (i = 1; i < 25; i++)
    {
        legacyTeleporter(i);
    }
}

legacyTeleporter(extra)
{
    ts = getentarray("enter"+extra, "targetname");
    if (isDefined(ts))
    {
        for(i = 0; i < ts.size; i++)
        {
            ts[i] thread transport();
        }
    }
}
 
transport()
{
    for(;;)
    {
        self waittill( "trigger", player );
        entTarget = getEnt( self.target, "targetname" );
        wait 0.1;
        player setOrigin( entTarget.origin );
        player setplayerangles( entTarget.angles );
        wait 0.1;
    }
}