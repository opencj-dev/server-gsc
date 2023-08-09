main()
{
    for (i = 1; i < 12; i++)
    {
        legacyRotate(i);
    }
}

legacyRotate(num)
{
    fan = getEntArray("rot"+num, "targetname");
    for (i = 0; i < fan.size; i++)
    {
        fan[i] thread startRotating();
    }
}

startRotating()
{
    while(true)
    {
        self rotateYaw(360, 3);
        wait (0.9);
    }
}