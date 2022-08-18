#include openCJ\util;

onInit()
{
	underlyingCmd = openCJ\settings::addSettingInt("fov", 13, 160, 90, "Set your field-of-view\nUsage: !fov [value between 13 and 160]", ::_onSettingFOV);
    underlyingCmd = openCJ\settings::addSettingInt("fullbright", 0, 1, 0, "Enable/disable fullbright\nUsage: !fullbright [on/off]", ::_onSettingFullbright);

	underlyingCmd = openCJ\settings::addSettingBool("hidecollidingplayers", 0, "Hide colliding players\nUsage: !hidecollidingplayers [on/off]");
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
