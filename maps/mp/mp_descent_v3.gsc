#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

main()
{

maps\mp\_load::main();


//-------------------------------------------------------------------------------------------
//---THREAD-FUNCTIONS------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

    thread initTriggers();
    thread onPlayerConnect();

    thread setupmsgTriggers();
    thread setupSpawnTeleports(6, (16410,4880,26696), (0,180,0));


//-------------------------------------------------------------------------------------------
//---SET-DVARS-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

    setdvar("r_specularcolorscale", "9" );
    setdvar("r_glowbloomintensity0",".25");
    setdvar("r_glowbloomintensity1",".25");
    setdvar("r_glowskybleedintensity0",".3");
    setdvar("compassmaxrange","2000");
    setdvar("sm_enable", "1");
    setdvar("sm_sunSampleSizeNear", "3");
    
//-------------------------------------------------------------------------------------------
//---PRECACHE-STUFF--------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
    
    //3xP Model FX
    level._effect[ "bolt_long" ]  = loadfx( "Viruzfx/lightning_bolt_long_runner" );
    level._effect[ "bolt" ]  = loadfx( "Viruzfx/lightning_bolt_runner" );
    level._effect[ "bolt_impact" ]  = loadfx( "Viruzfx/lightning_bolt_impact_runner" );
    level._effect[ "particle_bg" ]  = loadfx( "Viruzfx/particle_background" );
    level._effect[ "electrical_sparks" ]  = loadfx( "Viruzfx/electrical_sparks" );

//-------------------------------------------------------------------------------------------
//---SPAWN-EFFECTS---------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

    self.spawndelay = 8;
//electrical sparks links rechts
    thread triggerCustomFX("electrical_sparks", (12982,4166,26842), (270,0,0), self.spawndelay - 2);
    thread triggerCustomFX("electrical_sparks", (12983,5514,26842), (270,0,0), self.spawndelay - 2);
//bolt rechts oben
    thread triggerCustomFX("bolt_long", (12982,5506,27000), (285,90,0), self.spawndelay + 0.3);
    thread triggerCustomFX("bolt_impact", (12982,5093,27107), (270,0,0), self.spawndelay + 0.3);
//bolt rechts
    thread triggerCustomFX("bolt", (12982,5506,27000), (270,90,0), self.spawndelay + 0.15);
    thread triggerCustomFX("bolt_impact", (12982,5121,27000), (270,0,0), self.spawndelay + 0.15);
//bolt rechts unten
    thread triggerCustomFX("bolt_long", (12982,5506,27000), (255,90,0), self.spawndelay);
    thread triggerCustomFX("bolt_impact", (12982,5093,26896), (270,0,0), self.spawndelay);
//bolt links oben
    thread triggerCustomFX("bolt_long", (12983,4174,27000), (285,270,0), self.spawndelay + 0.3);
    thread triggerCustomFX("bolt_impact", (12982,4587,27107), (270,0,0), self.spawndelay + 0.3);
//bolt links
    thread triggerCustomFX("bolt", (12983,4174,27000), (270,270,0), self.spawndelay + 0.15);
    thread triggerCustomFX("bolt_impact", (12982,4559,27000), (270,0,0), self.spawndelay + 0.15);
//bolt links unten
    thread triggerCustomFX("bolt_long", (12983,4174,27000), (255,270,0), self.spawndelay);
    thread triggerCustomFX("bolt_impact", (12982,4578,26896), (270,0,0), self.spawndelay);
//Logo Background center
    thread triggerCustomFX("particle_bg", (12982,4839,27000), (270,180,0), self.spawndelay + 4);
}

//-------------------------------------------------------------------------------------------
//---SR-SYSTEM-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

onPlayerConnect() {
    level endon("game_ended");

    while (1) {
        level waittill("connecting", player);
        player initPlayerStuff();
    }
}

//Setup Triggers, Tps & Msgs
initPlayerStuff() {
    self initTriggerForPlayer();
    self thread testTouching();
}

//Resets Everything to 0
initTriggerForPlayer() {
    self.triggers = spawnStruct();
    self.triggers.hard = [];
    self.triggers.easy = [];
    self.triggers.combine = [];
    self.triggers.spawn = [];
    self.triggers.finish = [];
    self.triggers.mainhard = [];
}

//inits Trigger
initTriggers() {
    level.triggers = spawnStruct();

    level.triggers.spawn = [];
    for (i = 0; i < 1024; i++) {
        ent = getEnt("spawn" + i, "targetname");
        if (!isDefined(ent))continue;
        // iprintlnbold("^2[DEBUG] ^3 Found trigger spawn " + i);
        level.triggers.spawn[level.triggers.spawn.size] = ent;
    }

    level.triggers.easy = [];
    for (i = 0; i < 1024; i++) {
        ent = getEnt("easy" + i, "targetname");
        if (!isDefined(ent))continue;
        // iprintlnbold("^2[DEBUG] ^3 Found trigger easy " + i);
        level.triggers.easy[level.triggers.easy.size] = ent;
    }

    level.triggers.combine = [];
    for (i = 0; i < 1024; i++) {
        ent = getEnt("combine" + i, "targetname");
        if (!isDefined(ent))continue;
        // iprintlnbold("^2[DEBUG] ^3 Found trigger combine " + i);
        level.triggers.combine[level.triggers.combine.size] = ent;
    }

    level.triggers.hard = [];
    for (i = 0; i < 1024; i++) {
        ent = getEnt("hard" + i, "targetname");
        if (!isDefined(ent))continue;
        // iprintlnbold("^2[DEBUG] ^3 Found trigger hard " + i);
        level.triggers.hard[level.triggers.hard.size] = ent;
    }

    level.triggers.mainhard = [];
    for (i = 0; i < 1024; i++) {
        ent = getEnt("mainhard" + i, "targetname");
        if (!isDefined(ent))continue;
        // iprintlnbold("^2[DEBUG] ^3 Found trigger mainhard " + i);
        level.triggers.mainhard[level.triggers.mainhard.size] = ent;
    }

    level.triggers.finish = [];
    finishNames = [];
    finishNames[0] = "easyfin";
    finishNames[1] = "hardfin";
    finishNames[2] = "mainfin";
    for (j = 0; j < finishNames.size; j++) {
        ent = getEnt(finishNames[j], "targetname");
        if (!isDefined(ent))continue;
        //iprintlnbold("^2[DEBUG] ^3 Found trigger finish " + finishNames[j]);
        level.triggers.finish[level.triggers.finish.size] = ent;
    }
}

//is Touching
testTouching() {
    self endon("disconnect");

    while (1) {
        for (i = 0; i < level.triggers.spawn.size; i++) {
            if (isDefined(level.triggers.spawn[i]) && self isTouching(level.triggers.spawn[i]) && self IsOnGround() && self.sessionstate == "playing") {
                self initTriggerForPlayer();
                //self iprintln("^1[DEBUG] ^2Touching Spawn " + i);
                self.triggers.spawn[i] = 1;
            }
        }

        if (self.triggers.spawn.size == 0) {
            wait 0.05;
            continue;
        }

        for (i = 0; i < level.triggers.hard.size; i++) {
            if (isDefined(level.triggers.hard[i]) && self isTouching(level.triggers.hard[i]) && self.sessionstate == "playing") {
                self.triggers.hard[i] = 1;
                //self iprintln("^1[DEBUG] ^2Touching Hard " + i);
            }
        }
        for (i = 0; i < level.triggers.combine.size; i++) {
            if (isDefined(level.triggers.combine[i]) && self isTouching(level.triggers.combine[i]) && self.sessionstate == "playing") {
                //self iprintln("^1[DEBUG] ^2Touching Combine " + i);
                self.triggers.combine[i] = 1;
            }
        }
        for (i = 0; i < level.triggers.easy.size; i++) {
            if (isDefined(level.triggers.easy[i]) && self isTouching(level.triggers.easy[i]) && self.sessionstate == "playing") {
                //self iprintln("^1[DEBUG] ^2Touching Easy " + i);
                self.triggers.easy[i] = 1;
            }
        }

        for (i = 0; i < level.triggers.mainhard.size; i++) {
            if (isDefined(level.triggers.mainhard[i]) && self isTouching(level.triggers.mainhard[i]) && self.sessionstate == "playing") {
                //self iprintln("^1[DEBUG] ^2Touching mainhard " + i);
                self.triggers.mainhard[i] = 1;
            }
        }
        wait 0.05;
    }
}

//Check if finished
checkForFinish() {
    self endon("disconnect");

    finishway = "";

    if (self.triggers.mainhard.size == level.triggers.mainhard.size) {
       finishway = "mainhard";
    } else if (self.triggers.hard.size + self.triggers.combine.size == level.triggers.hard.size + level.triggers.combine.size && self.triggers.easy.size == 0) {
       finishway = "hard";
    } else if (self.triggers.easy.size + self.triggers.combine.size == level.triggers.easy.size + level.triggers.combine.size && self.triggers.hard.size == 0) {
       finishway = "easy";
    } else if (self.triggers.combine.size == level.triggers.combine.size && self.triggers.easy.size > 0 && self.triggers.hard.size > 0) {
        if (isDefined(self.triggers.hard[level.triggers.hard.size - 1]) && self.triggers.hard[level.triggers.hard.size - 1] == 1) {
           finishway = "combine_hard";
        } else if (isDefined(self.triggers.easy[level.triggers.easy.size - 1]) && self.triggers.easy[level.triggers.easy.size - 1] == 1) {
           finishway = "combine_easy";
        }
    }

    if (finishway == "")
        return false;

    self finishmsg(finishway);

    return true;
}

//Print out what time and way u did after finish speedrun
finishmsg(waymsg) {

    msg_way = "";
    msg_combine = "";

    switch (waymsg) {
        case "mainhard":
            msg_way = "^1Classic Hard^3";
            msg_combine = "";
            break;
        case "hard":
            msg_way = "^4Combine Hard^3";
            msg_combine = "^3He used ^2only Hard ^3jumps";
            break;
        case "easy":
            msg_way = "^5Easy/Inter^3";
            msg_combine = "^3He used ^2only Easy/Inter ^3jumps";
            break;
        case "combine_hard":
            msg_way = "^4Combine Hard^3";
            msg_combine = "^3He used ^1Hard & Easy/Inter ^3jumps";
            break;
        case "combine_easy":
            msg_way = "^5Easy/Inter^3";
            msg_combine = "^3He used ^1Hard & Easy/Inter ^3jumps";
            break;
    }

    iprintln("^2" + self.name + "^3 finished " + msg_way);
    iprintln(msg_combine);

}

//-------------------------------------------------------------------------------------------
//---TELEPORT--------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

setupSpawnTeleports(count, pos, angle) {
    for (i = 0; i < count; i++) {
        thread teleport("spawntp" + i, pos, angle);
    }
}

teleport(triggername, pos, angle) {
    ent = getent(triggername, "targetname");
    if (!isDefined(ent)) return;

    while (1) {
        ent waittill("trigger", player);

        if (player.sessionstate != "playing")
            continue;

        player SetOrigin(pos);
        player setPlayerAngles(angle);
    }
}

//-------------------------------------------------------------------------------------------
//---SPAWN-FX-WITH-ANGLES--------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

playCustomFX(fxid, origin, angle, delay)
{
    wait 0.05;
    if(delay > 0) wait delay;

    up = AnglesToUp(angle);
    forward = AnglesToForward(angle);

    PlayFX(level._effect[fxid], origin, forward, up);
}

triggerCustomFX(fxid, origin, angle, delay)
{
    wait 0.05;
    if(delay > 0) wait delay;

    up = AnglesToUp(angle);
    forward = AnglesToForward(angle);

    level.fx = SpawnFX(level._effect[fxid], origin, forward, up);
    TriggerFX(level.fx);
}

//-------------------------------------------------------------------------------------------
//---TEXT-MSG--------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------

setupMsg() {
    self.msg = [];
    self.msg[0] = "^2" + self.name + " ^7is so nice and good looking!";
    self.msg[1] = "Map by ^53xP' ^7Viruz!";
    self.msg[2] = "Thanks to ^2-.VaRtaZiaN.- ^7for letting me continue his great mapseries!";
    self.msg[3] = "Thanks to ^2Fr33g !t^7,^2 ZeeZ^7 & ^2Noob^7!";
    self.msg[4] = "u do ^2hax, ^7i got much proof, omgee!";
    self.msg[5] = "^2Drizzjeh ^7sucking much dickerinos!";
    self.msg[6] = "^2" + self.name + " ^7landed ^1Classic Hard ^7Roof";
    self.msg[7] = "^2" + self.name + " ^7landed ^4Combined Hard ^7Roof";
    self.msg[8] = "^2" + self.name + " ^7landed ^5Easy/Inter ^7Roof";
}

setupmsgTriggers()
{
    thread msg("mainhardroof", 6);
    thread msg("hardroof", 7);
    thread msg("easyroof", 8);

    for (i = 0; i < 9; i++) {
        thread msg("mainhardmsg" + (i+1), i);
        thread msg("hardmsg" + (i+1), i);
        thread msg("easymsg" + (i+1), i);
    }
}

msg(triggername, msgnumber) {
    ent = getent(triggername, "targetname");
    if (!isDefined(ent)) return;
    while (1) {
        ent waittill("trigger", player);
        if (player.sessionstate != "playing")
            continue;

        player setupMsg();
        player iPrintLnbold(player.msg[msgnumber]); //INSERT TEXT HERE
        wait 5;
    }
}
