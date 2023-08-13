onInit()
{
    level.motd_title = "Alpha";
    level.motd_content = "OpenCJ is a work-in-progress open-source CoDJumper mod for\nCoD4 and CoD2." + 
                         " Anyone can contribute via Pull Requests on\nGithub (opencj-dev)." +
                         " Alpha version is meant to stress test the server for\nany crashes or game breaking bugs." +
                         " Our website is opencj.org.\nJoin our Discord at discord.opencj.org for updates.\n";
    level.motd_date = "August 13th, 2023";
}

onPlayerConnect()
{
    prefix = "opencj_ui_ig_motd_";
    self setClientCvar(prefix + "title", level.motd_title);
    self setClientCvar(prefix + "content", level.motd_content);
    self setClientCvar(prefix + "date", level.motd_date);
}