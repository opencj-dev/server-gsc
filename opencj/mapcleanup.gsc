#include openCJ\util;

onInit()
{
	if(getCvarInt("codversion") == 4)
	{
		_removePickups();
		_removeTurrets();
		setCvar("clientSideEffects", 0);
	}
	else
	{
		_removeTurrets();
		//_showClassnames();
	}
}

_removePickups()
{
	pickups = getentarray("oldschool_pickup", "targetname");

	for(i = 0; i < pickups.size; i++)
	{
		if(isdefined(pickups[i].target))
			getent(pickups[i].target, "targetname") delete();

		pickups[i] delete();
	}
}

_removeTurrets()
{
	turrets = getentarray("misc_turret", "classname");
	mg42s = getentarray("misc_mg42", "classname");
	for(i = 0; i < turrets.size; i++)
	{
		turrets[i] delete();
	}
	for(i = 0; i < mg42s.size; i++)
	{
		mg42s[i] delete();
	}
}

_showClassnames()
{
	ents = getEntArray();
	for(i = 0; i < ents.size; i++)
	{
		if(isDefined(ents[i].className))
			printf(ents[i].className + "\n");
	}
}