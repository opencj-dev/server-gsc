#include openCJ\util;

requestUID()
{
	self endon("disconnect");
	self openCJ\util::execClientCmd("writeconfig temp.cfg; exec accounts/openCJ.cfg; vstr openCJ_login; unbind all; exec temp; login failed");

	self waittill("UIDReceived", uidstring);

	if(!isDefined(uidstring))
		return undefined;

	uidparts = strTok(uidstring, "-");

	if(uidparts.size == 4)
	{
		uid = [];
		for(i = 0; i < 4; i++)
		{
			uid[i] = hexStringToInt(uidparts[i]);
			if(!isDefined(uid[i]))
			{
				return undefined;
			}
		}
		return uid;
	}
	return undefined;
}

storeUID(uid)
{
	self thread _storeUIDContinuous(uid);
}

_storeUIDContinuous(uid)
{
	self endon("UIDStored");
	self endon("disconnect");
	uidstring = intToHexString(uid[0]) + "-" + intToHexString(uid[1]) + "-" + intToHexString(uid[2]) + "-" + intToHexString(uid[3]);

	while(true)
	{
		self openCJ\util::execClientCmd("seta openCJ_login login uid " + uidstring + "; writeconfig accounts/openCJ.cfg; login stored");
		wait 0.5;
	}
}

onPlayerCommand(args)
{
	if(isDefined(args[0]) && args[0] == "login")
	{
		if(isDefined(args[1]))
		{
			if(args[1] == "uid")
			{
				self notify("UIDReceived", args[2]);
				return true;
			}
			else if(args[1] == "stored")
			{
				self notify("UIDStored");
				return true;
			}
			else if(args[1] == "failed")
			{
				self notify("UIDReceived");
				return true;
			}
		}
	}
	return false;
}