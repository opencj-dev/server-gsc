main()
{
level.allow_save = false;
maps\mp\_load::main();
thread door1();
thread door2();
thread platform_rotate();
level._effect["water_exp"] = loadfx ("fx/Explosions/mortarExp_water.efx");
thread finish();
thread cows();
} 

door1()
{
door1 = getent ("door1","targetname");
door1_trig = getent ("door1_trig","targetname");

while (1)
{
door1_trig waittill ("trigger",user);
door1 rotateto ((0, -90,0), 1);
door1 waittill("rotatedone");
wait 1;
door1 rotateto ((0, 0,0), 1);
door1 waittill("rotatedone");
}
}

door2()
{
door2 = getent ("door2","targetname");
door2_trig = getent ("door2_trig","targetname");

while (1)
{
door2_trig waittill ("trigger");
door2 rotateto ((0, 90,0), 1.5);
door2 waittill("rotatedone");
wait (1.5);
door2 rotateto ((0, 0,0), 1.5);
}
}

platform_rotate()
{
platform1 = getent ("platform_rotate","targetname");
platform2 = getent ("platform_rotate2","targetname");
platform_trig = getent ("platform_trig","targetname");

while (1)
{
platform_trig waittill ("trigger");
platform1 rotateto ((90, 0, 0), 2);
platform2 rotateto ((0, 90, 0), 2);
wait (8);
platform1 rotateto ((0, 0,0), 2);
platform2 rotateto ((0, 0,0), 2);
}
}

cows()
{
cow_trig = getent ("cows","targetname");
cow_org = getent ("cow_org","targetname");
while (1)
{
cow_trig waittill ("trigger");
cow_org playsound("cows");
wait 6;
}
}

finish()
{
end_trig = getent ("end_trig","targetname");
while (1)
{
end_trig waittill ("trigger",user);
user playsound("mortar_impact_water_layer");
user iprintlnbold ("Well done " + user.name," ^7 you've finished!");
playfx(level._effect["water_exp"], (-2944, -96, -160));
wait 3;
if(isdefined(user))
user suicide();
wait 1;
}
}