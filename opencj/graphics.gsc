#include openCJ\util;

_configureMinimap()
{
	level.minimapMaxRange = 2500;
	if(!isDefined(getConfigStringByIndex(823))) // 823 is minimap string
	{
		minimapTileCount = 2.5; // TODO: dynamically per map
		minimapTileSize = level.minimapMaxRange / minimapTileCount / 2;
		northvector = (cos(getnorthyaw()), sin(getnorthyaw()), 0);
		eastvector = (northvector[1], 0 - northvector[0], 0);
		northwest = VectorScale(northvector, minimapTileSize) + VectorScale(eastvector, -1 * minimapTileSize) + level.spawnpoints_player[0].origin;
		southeast = VectorScale(northvector, -1 * minimapTileSize) + VectorScale(eastvector, minimapTileSize) + level.spawnpoints_player[0].origin;

		setMiniMap("opencj_minimapbg", northwest[0], northwest[1], southeast[0], southeast[1]);
	}
}

onInit()
{
	// If map doesn't have a custom minimap, then we set a default
	if(getCvarInt("codversion") == 4)
	{
		_configureMinimap();
	}

	underlyingCmd = openCJ\settings::addSettingInt("fov", 13, 160, 90, "Set your field-of-view\nUsage: !fov [value between 13 and 160]", ::_onSettingFOV);
    underlyingCmd = openCJ\settings::addSettingInt("fullbright", 0, 1, 0, "Enable/disable fullbright\nUsage: !fullbright [on/off]", ::_onSettingFullbright);
	underlyingCmd = openCJ\settings::addSettingBool("hidecollidingplayers", 0, "Hide colliding players\nUsage: !hidecollidingplayers [on/off]");
	underlyingCmd = openCJ\settings::addSettingBool("viewbob", 0, "Change view bobbing\nUsage: !viewbob [on/off]", ::_onSettingViewBob);
}

onPlayerConnected()
{
	if(getCvarInt("codversion") == 4)
	{
		self setClientCvar("compassMaxRange", level.minimapMaxRange);
	}
}

_onSettingFOV(newVal)
{
	if(newVal > 80)
	{
		self setClientCvar("cg_fovscale", (newVal / 80));
		self setClientCvar("cg_fov", 80);
	}
	else if(newVal < 65)
	{
		self setClientCvar("cg_fovscale", (newVal / 65));
		self setClientCvar("cg_fov", 65);
	}
	else
	{
		self setClientCvar("cg_fovscale", 1);
		self setClientCvar("cg_fov", newVal);
	}
}

_onSettingFullbright(newVal)
{
	self setClientCvar("r_fullbright", newVal);
}

_onSettingViewBob(newVal)
{
	if(newVal > 0)
	{
		newVal = 8;
	}
	self setClientCvar("bg_bobmax", newVal);
}
