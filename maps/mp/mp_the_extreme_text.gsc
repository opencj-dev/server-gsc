main()
{
	thread give_deserteaglegold();
	thread secrettext1();
	thread secrettext2();
	thread elefin();
	thread eleroof();
	thread elecredit1();
	thread elecredit2();
	thread elecredit3();
	thread elecredit4();
	thread elegun1();
	thread elegun2();
	thread elegun3();
	thread elegun4();
	thread elegun5();
	thread elesecret();
	thread easycredit1();
	thread easycredit2();
	thread easycredit3();
	thread easycredit4();
	thread easycredit5();
	thread easyfin();
	thread easyroof();
	thread easygun1();
	thread easygun2();
	thread easygun3();
	thread easygun4();
	thread secretgun1();
	thread secretgun2();
	thread secretgun3();
	thread secretgun4();
	thread secretgun5();
	thread hardgun1();
	thread hardgun2();
	thread hardgun3();
	thread hardgun4();
	thread hardgun5();
	thread secretquake();
	thread hardcredit1();
	thread hardcredit2();
	thread hardcredit3();
	thread hardcredit4();
	thread hardcredit5();
	thread elesecretm40a3();
}

give_deserteaglegold()
{
	trigger = getent("give_deserteaglegold_trig", "targetname");
	
	while(1)
	{
		trigger waittill("trigger", user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
secrettext1()
{
 trigger = getent("secrettext1","targetname");

while (1)
{
trigger waittill ("trigger", user);
if (!isdefined(user.secrettext1))
{
 user iprintlnbold ("^6Domi ^7Married ^6Nutella^1<3");
wait 5;
}
}
}
//////////////////////////////////////////////////////////////////////
secrettext2()
{
 trigger = getent("secrettext2","targetname");

while (1)
{
trigger waittill ("trigger", user);
if (!isdefined(user.secrettext2))
{
 user iprintlnbold ("Gimme ^3Golden Globe^1?");
wait 5;
}
}
}
//////////////////////////////////////////////////////////////////////
elefin()
{
	trigger = getent("elefin","targetname");

	while (1)
	{
		trigger waittill ("trigger", user );
		
		if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.elefin ) ))
		{
			iprintln ("" + user.name + " ^7has Finished ^3ELEVATOR ^7Way^1!");
			user.elefin = true;
		}
	}
}
//////////////////////////////////////////////////////////////////////
eleroof()
{
	trigger = getent("eleroof","targetname");

	while (1)
	{
		trigger waittill ("trigger", user );
		
		if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.eleroof ) ))
		{
			iprintln ("" + user.name + " ^7has reached ^3ELEVATOR Roof^1!");
			user.eleroof = true;
		}
	}
}
//////////////////////////////////////////////////////////////////////
elecredit1()
{
	trigger = getent("elecredit1","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.elecredit1))
		{
			user iprintlnbold ("^3Thanks to ^7Player ^3for Testing^0:3");
			user.elecredit1 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
elecredit2()
{
	trigger = getent("elecredit2","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.elecredit2))
		{
			user iprintlnbold ("^3Thanks to ^7Slash ^3for Testing^0:3");
			user.elecredit2 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
elecredit3()
{
	trigger = getent("elecredit3","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.elecredit3))
		{
			user iprintlnbold("^3Map Created By ^7Ultimate, ^3Xfire: ^7Ultimater95");
			user.elecredit3 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
elecredit4()
{
	trigger = getent("elecredit4","targetname");

	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.elecredit4))
		{
			user iprintlnbold ("You Like to Pet ^3Pussies ^7at ^3Night^1!");
			user.elecredit4 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
elegun1()
{
	trigger = getent ("elegun1","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
elegun2()
{
	trigger = getent ("elegun2","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
elegun3()
{
	trigger = getent ("elegun3","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
elegun4()
{
	trigger = getent ("elegun4","targetname");
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
elegun5()
{
	trigger = getent ("elegun5","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
elesecret()
{
	trigger = getent("elesecret","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user );
		
		if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.hardcredit2 ) ))
		{
			user iprintlnbold("You found ^3Elevator Secret^6! ");
			user.hardcredit2 = true;
		}
	}
}
//////////////////////////////////////////////////////////////////////
easycredit1()
{
	trigger = getent("easycredit1","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if(!isdefined(user.easycredit1))
		{
			user iprintlnbold ("First Credit goes to ^6Nicki^7, ^1TrikX^7, ^5Energie ^7and ^2Tommy ^7For Helping ^2^^");
			user.easycredit1 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
easycredit2()
{
	trigger = getent("easycredit2","targetname");
	
	while(1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.easycredit2))
		{
			user iprintlnbold ("Second Credit goes to ^2Domi^7, ^2Tonzo, ^7and ^2DarkAngel ^7For Testing");
			user.easycredit2 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
easycredit3()
{
	trigger = getent("easycredit3","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.easycredit3))
		{
			user iprintlnbold ("Third Credit goes to You people, for Great Feedback. I ^2Salute ^7You. ");
			user.easycredit3 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
easycredit4()
{
	trigger = getent("easycredit4","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.easycredit4))
		{
			user iprintlnbold("^7Everybody Knows it, you ^2Suck Balls^0:3");
			user.easycredit1 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
easycredit5()
{
	trigger = getent("easycredit5","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.easycredit5))
		{
			user iprintlnbold ("So, ^2GravityGunning ^7makes you pro?^6- ^2Condescending Wonka");
			user.easycredit5 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
easyfin()
{
	trigger = getent("easyfin","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user );
		
		if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.easyfin ) ))
		{
			iprintln ("" + user.name + " ^7has Finished ^2EASY ^7Way^1!");
			user.easyfin = true;
		}
	}
}
//////////////////////////////////////////////////////////////////////
easyroof()
{
	trigger = getent("easyroof","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user );
		
		if ( isPlayer( user ) && isAlive( user ) && !(isdefined( user.easyroof ) ))
		{
			iprintln ("" + user.name + " ^7landed to ^2EASY ^7 Roof^1!");
			user.easyroof = true;
		}
	}
}
//////////////////////////////////////////////////////////////////////
easygun1()
{
	trigger = getent ("easygun1_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
easygun2()
{
	trigger = getent ("easygun2_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
easygun3()
{
	trigger = getent ("easygun3_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
easygun4()
{
	trigger = getent ("easygun4_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
secretgun1()
{
	trigger = getent ("secretgun1_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
secretgun2()
{
	trigger = getent ("secretgun2_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
secretgun3()
{
	trigger = getent ("secretgun3_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
secretgun4()
{
	trigger = getent ("secretgun4_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
secretgun5()
{
	trigger = getent ("secretgun5_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		
		wait 0.2;
		user iprintlnbold("Sorry, this weapon is not available");
	}
}
//////////////////////////////////////////////////////////////////////
hardgun1()
{
	trigger = getent ("hardgun1_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
hardgun2()
{
	trigger = getent ("hardgun2_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
hardgun3()
{
	trigger = getent ("hardgun3_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
hardgun4()
{
	trigger = getent ("hardgun4_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
hardgun5()
{
	trigger = getent ("hardgun5_trig","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
secretquake()
{
	trigger = getent("secretquake","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.secretquake))
		{
			user iprintlnbold ("^3EARTHQUAAAKEEEE!!!!!! ");
			wait 2;
			user iprintlnbold ("^3 Just messing with ya^^ ");
			wait 5;
			user.secretquake = true;
		}
	}
}
//////////////////////////////////////////////////////////////////////
hardcredit1()
{
	trigger = getent("hardcredit1","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.hardcredit1))
		{
			user iprintlnbold ("25.11.2013 - 13.3.2014^3*_*");
			user.hardcredit1 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
hardcredit2()
{
	trigger = getent("hardcredit2","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.hardcredit2))
		{
			user iprintlnbold ("eBc^9= ^1Explicit ^7Boobie ^1Club^9;)");
			user.hardcredit2 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
hardcredit3()
{
	trigger = getent("hardcredit3","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.hardcredit3))
		{
			user iprintlnbold ("^7Suomi on ^1Paras^7^1:D^7, ^7ja ^1Kalja^7:D");
			user.hardcredit3 = true;
		}
        wait  5;
	}
}
//////////////////////////////////////////////////////////////////////
hardcredit4()
{
	trigger = getent("hardcredit4","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.hardcredit4))
		{
			user iprintlnbold ("You Achieved the ^1LEGENDARY ^7Award!");
			user.hardcredit4 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
hardcredit5()
{
	trigger = getent("hardcredit5","targetname");
	
	while (1)
	{
		trigger waittill ("trigger", user);
		
		if (!isdefined(user.hardcredit5))
		{
            user iprintlnbold ("Find the ^1Artifacts ^7 to reach the prizes!");
			user.hardcredit5 = true;
		}
        wait 5;
	}
}
//////////////////////////////////////////////////////////////////////
elesecretm40a3()
{
	trigger = getent ("elesecretm40a3","targetname");
	
	while(1)
	{
		trigger waittill ("trigger",user);
		user iprintlnbold("Sorry, this weapon is not available");
        wait 5;
	}
}