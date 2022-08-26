#include openCJ\util;

onFrame()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i] hide();

	for(i = 0; i < players.size; i++)
	{
		for(j = 1; j < players.size; j++)
		{
			if(players[j].sessionState != "playing" && players[i].sessionState == "playing")
				players[i] showToPlayer(players[j]);
			else if(players[j].sessionState == "playing" && players[i].sessionState != "playing")
				players[j] showToPlayer(players[i]);
			else if(players[j].sessionState != "playing" && players[j].sessionState != "playing")
				continue;
			else if(_arePlayersColliding(players[i], players[j]))
			{
				if(!players[i] openCJ\settings::getSetting("hidecollidingplayers"))
					players[j] showToPlayer(players[i]);
				if(!players[j] openCJ\settings::getSetting("hidecollidingplayers"))
					players[i] showToPlayer(players[j]);
			}
			else
			{
				players[i] showToPlayer(players[j]);
				players[j] showToPlayer(players[i]);
			}
		}
	}
}

_arePlayersColliding(p1, p2)
{
	if(distanceSquared(p1.origin, p2.origin) < 3600 && abs(p1.origin[2] - p2.origin[2]) < 120)
		return true;
	return false;
}