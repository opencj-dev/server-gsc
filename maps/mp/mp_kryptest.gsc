main()  {
  	 maps\mp\_load::main(); 
         level._effect["fire"] = loadfx ("fx/fire/ground_fire_small_oneshot.efx");
         maps\mp\_fx::loopfx("fire", (-1984, -4688, 168), 3);
         maps\mp\_fx::loopfx("fire", (-1648, -4688, 168), 3);         
         doteleporter();
         thread move();

        }


move() 
{ 
board2 = getent("simpson","targetname");  
while (1) 
{ 
board2 moveX (-200, 3, 1, 1);
board2 waittill ("movedone");
wait 3; 
board2 moveX (200, 3, 1, 1);
board2 waittill ("movedone"); 
wait 5; 
} 
} 

doteleporter()
{
entTransporter = getentarray("enter","targetname");

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
user setorigin(entTarget.origin);
wait .1;
}
} 