#include openCJ\util;

onInit()
{
    openCJ\commands_base::registerCommand("detectplat", "Tries to detect the platform you're on", ::_onPlatDetect, 0, 0, 60);
    openCj\commands_base::registerCommand("org", "Shows or", ::_org, 0, 0, 0);
}

_org(args)
{
    self iprintln("origin: " + self.origin);
}

_onPlatDetect(args)
{
    if(!self isOnGround())
    {
        self iprintln("need to be on ground to use this");
        return;
    }
    bt_down = bullettrace(self.origin, self.origin - (0, 0, 10), false, undefined);
    if(bt_down["fraction"] < 1)
    {
        //bt hit
        if(bt_down["normal"] == (0, 0, 1))
        {
            bt_fw_out_low = bullettrace(bt_down["position"] - (0, 0, 1), bt_down["position"] - (0, 0, 1) + vectorScale(anglesToForward((0, self getPlayerAngles()[1], 0)), 10000), false, undefined); //forward out low
            bt_fw_back_low = bullettrace(bt_fw_out_low["position"] + vectorScale(anglesToForward((0, self getPlayerAngles()[1], 0)), 1), bt_down["position"] - (0, 0, 1), false, undefined); //forward back low
            bt_fw_out_high = bullettrace(bt_down["position"] + (0, 0, 1), bt_down["position"] + (0, 0, 1) + vectorScale(anglesToForward((0, self getPlayerAngles()[1], 0)), 10000), false, undefined); //forward out high
            use_bt_fw = undefined;
            if(bt_fw_back_low["fraction"] < 1 && bt_fw_out_high["fraction"] < 1)
            {
                iprintln("both");
                //both traces hit, decide.
                if(distanceSquared(bt_down["position"], bt_fw_back_low["position"]) < distanceSquared(bt_down["position"], bt_fw_out_high["position"]))
                {
                    //bt_fw_back_low["normal"] = vectorScale(bt_fw_back_low["normal"], -1);
                    use_bt_fw = bt_fw_back_low;
                    iprintln("using low, pos: " + use_bt_fw["position"]);
                }
                else
                {
                    iprintln("using high");
                    bt_fw_out_high["normal"] = vectorScale(bt_fw_out_high["normal"], -1);
                    use_bt_fw = bt_fw_out_high;
                }
            }
            else if(bt_fw_back_low["fraction"] < 1)
            {
                iprintln("using low");
                //bt_fw_back_low["normal"] = vectorScale(bt_fw_back_low["normal"], -1);
                use_bt_fw = bt_fw_back_low;
            }
            else if(bt_fw_out_high["fraction"] < 1)
            {
                iprintln("using high");
                bt_fw_out_high["normal"] = vectorScale(bt_fw_out_high["normal"], -1);
                use_bt_fw = bt_fw_out_high;
            }
            if(isDefined(use_bt_fw))
            {
                use_bt_fw["normal"] = vectorNormalize((use_bt_fw["normal"][0], use_bt_fw["normal"][1], 0));
                forward = use_bt_fw["normal"];
                fw_vec = use_bt_fw["position"] - bt_down["position"]; //could adjust for the + 1 or -1 on z-axis earlier
                //fw_dist = vectordot(fw_vec, forward);
                bt_b_out_low = bullettrace(bt_down["position"] - (0, 0, 1), bt_down["position"] - (0, 0, 1) + vectorScale(forward, -10000), false, undefined);
                bt_b_back_low = bullettrace(bt_b_out_low["position"], bt_down["position"] - (0, 0, 1), false, undefined);
                bt_b_out_high = bullettrace(bt_down["position"] + (0, 0, 1), bt_down["position"] + (0, 0, 1) + vectorScale(forward, -10000), false, undefined);
                use_bt_b = undefined;
                if(bt_b_back_low["fraction"] < 1 && bt_b_out_high["fraction"] < 1)
                {
                    //both back traces hit, decide.
                    if(distanceSquared(bt_down["position"], bt_b_back_low["position"]) < distanceSquared(bt_down["position"], bt_b_out_high["position"]))
                    {
                        //bt_b_back_low["normal"] = vectorScale(bt_b_back_low["normal"], -1);
                        
                        use_bt_b = bt_b_back_low;
                        iprintln("using low, pos: " + use_bt_b["position"]);
                    }
                    else
                    {
                        bt_b_out_high["normal"] = vectorScale(bt_b_out_high["normal"], -1);
                        use_bt_b = bt_b_out_high;
                    }
                }
                else if(bt_b_back_low["fraction"] < 1)
                {
                    //bt_b_back_low["normal"] = vectorScale(bt_b_back_low["normal"], -1);
                    use_bt_b = bt_b_back_low;
                }
                else if(bt_b_out_high["fraction"] < 1)
                {
                    bt_b_out_high["normal"] = vectorScale(bt_b_out_high["normal"], -1);
                    use_bt_b = bt_b_out_high;
                }
                if(isDefined(use_bt_b))
                {
                    use_bt_b["normal"] = vectorNormalize((use_bt_b["normal"][0], use_bt_b["normal"][1], 0));
                    right = (forward[1], forward[0], 0);
                    bt_r_out_low = bullettrace(bt_down["position"] - (0, 0, 1), bt_down["position"] - (0, 0, 1) + vectorScale(right, 10000), false, undefined);
                    bt_r_back_low = bullettrace(bt_r_out_low["position"] - (0, 0, 1), bt_down["position"] - (0, 0, 1), false, undefined);
                    bt_r_out_high = bullettrace(bt_down["position"] + (0, 0, 1), bt_down["position"] + (0, 0, 1) + vectorScale(right, 10000), false, undefined);


                    use_bt_r = undefined;
                    if(bt_r_back_low["fraction"] < 1 && bt_r_out_high["fraction"] < 1)
                    {
                        //both back traces hit, decide.
                        if(distanceSquared(bt_down["position"], bt_r_back_low["position"]) < distanceSquared(bt_down["position"], bt_r_out_high["position"]))
                        {
                            //bt_r_back_low["normal"] = vectorScale(bt_r_back_low["normal"], -1);
                            
                            use_bt_r = bt_r_back_low;
                            iprintln("using low, pos: " + use_bt_r["position"]);
                        }
                        else
                        {
                            bt_r_out_high["normal"] = vectorScale(bt_r_out_high["normal"], -1);
                            use_bt_r = bt_r_out_high;
                        }
                    }
                    else if(bt_r_back_low["fraction"] < 1)
                    {
                        //bt_r_back_low["normal"] = vectorScale(bt_r_back_low["normal"], -1);
                        use_bt_r = bt_r_back_low;
                    }
                    else if(bt_r_out_high["fraction"] < 1)
                    {
                        bt_r_out_high["normal"] = vectorScale(bt_r_out_high["normal"], -1);
                        use_bt_r = bt_r_out_high;
                    }
                    if(isDefined(use_bt_r))
                    {
                        use_bt_r["normal"] = vectorNormalize((use_bt_r["normal"][0], use_bt_r["normal"][1], 0));
                        bt_l_out_low = bullettrace(bt_down["position"] - (0, 0, 1), bt_down["position"] - (0, 0, 1) + vectorScale(right, -10000), false, undefined);
                        bt_l_back_low = bullettrace(bt_l_out_low["position"] - (0, 0, 1), bt_down["position"] - (0, 0, 1), false, undefined);
                        bt_l_out_high = bullettrace(bt_down["position"] + (0, 0, 1), bt_down["position"] + (0, 0, 1) + vectorScale(right, -10000), false, undefined);
                        use_bt_l = undefined;
                        if(bt_l_back_low["fraction"] < 1 && bt_l_out_high["fraction"] < 1)
                        {
                            //both back traces hit, decide.
                            if(distanceSquared(bt_down["position"], bt_l_back_low["position"]) < distanceSquared(bt_down["position"], bt_l_out_high["position"]))
                            {
                                //bt_l_back_low["normal"] = vectorScale(bt_l_back_low["normal"], -1);
                                
                                use_bt_l = bt_l_back_low;
                                iprintln("using low, pos: " + use_bt_l["position"]);
                            }
                            else
                            {
                                bt_l_out_high["normal"] = vectorScale(bt_l_out_high["normal"], -1);
                                use_bt_l = bt_l_out_high;
                            }
                        }
                        else if(bt_l_back_low["fraction"] < 1)
                        {
                            //bt_l_back_low["normal"] = vectorScale(bt_l_back_low["normal"], -1);
                            use_bt_l = bt_l_back_low;
                        }
                        else if(bt_l_out_high["fraction"] < 1)
                        {
                            bt_l_out_high["normal"] = vectorScale(bt_l_out_high["normal"], -1);
                            use_bt_l = bt_l_out_high;
                        }
                        if(isDefined(use_bt_l))
                        {
                            use_bt_l["normal"] = vectorNormalize((use_bt_l["normal"][0], use_bt_l["normal"][1], 0));
                            self.plat = spawnStruct();
                            //self.plat.position = vectorScale(use_bt_fw["position"], 0.5) + vectorScale(use_bt_b["position"], 0.5);
                            self.plat.fw = forward;
                            self.plat.fw_dist = abs(vectorDot(use_bt_fw["position"] - use_bt_b["position"], forward));
                            self.plat.rg = right;
                            self.plat.rg_dist = abs(vectorDot(use_bt_r["position"] - use_bt_l["position"], right));
                            fw = vectorDot(forward, use_bt_fw["position"]);
                            b = vectorDot(forward, use_bt_b["position"]);
                            r = vectorDot(right, use_bt_r["position"]);
                            l = vectorDot(right, use_bt_l["position"]);
                            fwb = (fw + b) / 2;
                            lr = (l + r) / 2;
                            self.plat.position = vectorScale(forward, fwb) + vectorScale(right, lr) + (0, 0, bt_down["position"][2] - 1);
                            self.plat.height = bt_down["position"][2] + 10;
                            return;
                        }
                    }
                }
                else
                {
                    self iprintln("dunno 2");
                }
            }
            else
            {
                self iprintln("dunno 1");
            }
        }
        else
        {
            self iprintln("plat is not level");
            return;
        }
    }
}

whileAlive()
{
    if(isDefined(self.plat) && self isOnGround())
    {
        if(self.origin[2] > self.plat.position[2] && self.origin[2] < self.plat.position[2] + self.plat.height)
        {
            vec = self.origin - self.plat.position;
            fw_count = vectordot(vec, self.plat.fw);
            rg_count = vectorDot(vec, self.plat.rg);
            if(abs(fw_count) < self.plat.fw_dist && abs(rg_count) < self.plat.rg_dist)
            {
                if(!isDefined(self.onPlat))
                {
                    self.onPlat = true;
                    self iprintln("on plat");
                }
                return;
            }
        }
    }
    if(isDefined(self.onPlat))
    {
        self.onPlat = undefined;
        self iprintln("off plat");
    }
}