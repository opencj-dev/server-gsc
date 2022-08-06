main()
{
level._effect["fire"] = loadfx ("fx/fire/ground_fire_small_oneshot.efx");
maps\mp\_fx::loopfx("fire", (346, 896, 2450), 3);

	maps\mp\_load::main();
    doteleporter();
	
thread toilet_door(); 
thread toilet_flush();
thread castle_fan();
thread plat1();
thread plat2();
thread plat3();
thread plat4();
thread endleft();
thread endright();
}
doteleporter()
{
entTransporter = getentarray("tele","targetname");

if(isdefined(entTransporter))
{
for(i=0;i<entTransporter.size;i++)
entTransporter[i] thread Transporter();
}
}

Transporter()
{
while(1)
{
self waittill("trigger",user);
entTarget = getent(self.target, "targetname");
if(isdefined(user))
user setorigin(entTarget.origin);
wait .1;
}
} 

toilet_door()
{
toilet_door = getent ("toilet_door","targetname");
toilet_doortrig = getent ("toilet_doortrig","targetname");
door_sound = getent ("door_sound","targetname");

while (1)
{
toilet_doortrig waittill ("trigger");
toilet_door rotateto ((0, 90,0), 1);
door_sound playsound("dooropen");
wait (5);
toilet_door rotateto ((0, 0,0), 1.7);
door_sound playsound("slamdoor");
wait 1;
}
}

toilet_flush()
{
lid = getent ("hole_lid","targetname");
toilet_trig = getent ("toilet_trig","targetname");
flush = getent ("flush","targetname");

while (1)
{
toilet_trig waittill ("trigger");
flush playsound("flush");
wait 4;
lid notsolid();
lid hide();
wait 5;
lid solid();
lid show();
}
}

castle_fan() 
{ 
castle_fan = getent("castle_fan","targetname");  
while (1) 
{ 

castle_fan rotateyaw(-360, 5);

castle_fan waittill("rotatedone");
} 
}

plat1() 
{ 
plat1 = getent("plat1","targetname");  
while (1) 
{ 
plat1 moveto ((290,0,0), 4,3,1); 
plat1 waittill ("movedone");
wait 1; 
plat1 moveto ((0,0,0), 4,3,1);
plat1 waittill ("movedone");
wait 1; 
} 
} 

plat2() 
{ 
plat2 = getent("plat2","targetname");  
while (1) 
{ 
plat2 moveto ((-290,0,0),4,3,1);
plat2 waittill ("movedone");
wait 1; 
plat2 moveto ((0,0,0),4,3,1);
plat2 waittill ("movedone"); 
wait 1; 
} 
} 

plat3() 
{ 
plat3 = getent("plat3","targetname");  
while (1) 
{ 
plat3 moveto ((290,0,0),4,3,1); 
plat3 waittill ("movedone");
wait 1; 
plat3 moveto ((0,0,0),4,3,1);
plat3 waittill ("movedone"); 
wait 1; 
} 
} 

plat4() 
{ 
plat4 = getent("plat4","targetname");  
while (1) 
{ 
plat4 moveto ((0,2,277),4,3,1);
plat4 waittill ("movedone");
wait 1; 
plat4 moveto ((0,0,0),4,3,1);
plat4 waittill ("movedone"); 
wait 1; 
} 
} 

endleft()
{
endleft = getent("endleft","targetname");  
while (1)
{
endleft waittill ("trigger",user); 
user iprintlnbold ("Well done " + user.name," ^7 you've finished!");
wait 2;
if(isdefined(user))
	user suicide();
wait 1;
}
}

endright()
{
endright = getent("endright","targetname");  
while (1)
{
endright waittill ("trigger",user); 
user iprintlnbold ("Well done " + user.name," ^7 you've finished!");
wait 2;
if(isdefined(user))
	user suicide();
wait 1;
}
}
