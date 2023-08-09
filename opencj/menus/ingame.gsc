onInit()
{
    level.motd_title = "Alpha";
    level.motd_content = "OpenCJ is a work-in-progress open-source CoDJumper mod for\nCoD4 and CoD2." + 
                         " Anyone can contribute via Pull Requests on\nGithub (opencj-dev)." +
                         " Alpha version is meant to stress test the server for\nany crashes or game breaking bugs." +
                         " Please join our Discord for\nmore information or go to opencj.org.";
    level.motd_date = "August 9th, 2023";
}

onPlayerConnect()
{
    prefix = "opencj_ui_ig_motd_";
    self setClientCvar(prefix + "title", level.motd_title);
    self setClientCvar(prefix + "content", level.motd_content);
    self setClientCvar(prefix + "date", level.motd_date);
}