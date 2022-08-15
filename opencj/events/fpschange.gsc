#include openCJ\util;

onPlayerConnect()
{
    self.currFPS = undefined;
    self.prevFPS = undefined;
}

main(newFrameTime)
{
    self thread _fpsChange(newFrameTime);
}

_fpsChange(newFrameTime)
{
    self endon("disconnect");
	self notify("fpschange");
	self endon("fpschange");

	wait 0.2;
    newFPS = int(1000 / newFrameTime);

    // Did FPS actually change?
    wasDefined = isDefined(self.currFPS);
    if (!wasDefined || (newFPS != self.currFPS))
    {
        if (!wasDefined)
        {
            self.currFPS = newFPS;
            self.prevFPS = self.currFPS;
            //self iprintln("FPS ? -> " + self.currFPS);
        }
        else
        {
            self.prevFPS = self.currFPS;
            self.currFPS = newFPS;
	        //self iprintln("FPS " + self.prevFPS + " -> " + self.currFPS);
        }

        // Event callbacks start here
        self openCJ\FPSHistory::onFPSChanged(newFPS);
    }
}