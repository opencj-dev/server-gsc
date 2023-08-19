#include openCJ\util;

_configureMinimap()
{
		setMiniMap("opencj_minimapbg", -500, -500, 500, 500);
		setconfigstringbyindex(822, "90");
}

onInit()
{
    // If map doesn't have a custom minimap, then we set a default
    if(getCodVersion() == 4)
    {
        _configureMinimap();
    }

    underlyingCmd = openCJ\settings::addSettingInt("fov", 13, 160, 90, "Set your field-of-view. Usage: !fov [value between 13 and 160]", ::_onSettingFOV);
    underlyingCmd = openCJ\settings::addSettingBool("fullbright", false, "Enable/disable fullbright. Usage: !fullbright [on/off]", ::_onSettingFullbright);
    underlyingCmd = openCJ\settings::addSettingBool("hidecollidingplayers", false, "Hide colliding players. Usage: !hidecollidingplayers [on/off]");
    underlyingCmd = openCJ\settings::addSettingBool("viewbob", false, "Change view bobbing. Usage: !viewbob [on/off]", ::_onSettingViewBob);
    underlyingCmd = openCJ\settings::addSettingBool("fx", true, "fx_enable. Usage: !fx [on/off]", ::_onSettingFX);
}

onPlayerConnected()
{
    if(getCodVersion() == 4)
    {
        self setClientCvar("compassMaxRange", 2500);
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
    if(newVal > 0)
    {
        newVal = 1;
    }
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

_onSettingFX(newVal)
{
    if(newVal > 0)
    {
        newVal = 1;
    }
    self setClientCvar("fx_enable", newVal);
}
