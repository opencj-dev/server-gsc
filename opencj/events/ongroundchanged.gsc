#include openCJ\util;

onPlayerConnect()
{
    self.isOnGround = false;
    self.lastGroundEnterTime = 0;
    self.lastGroundLeaveTime = 0;
    self.onGroundFilterTime = 50; // In ms
}

main(isOnGround, time, origin)
{
    // Filter events as this can be spammed on clients' FPS!
    if (isOnGround)
    {
        if ((time - self.lastGroundEnterTime) < self.onGroundFilterTime)
        {
            // Not long enough, no event!
            self.lastGroundEnterTime = time;
            return;
        }
        self.lastGroundEnterTime = time;
    }
    else
    {
        if ((time - self.lastGroundLeaveTime) < self.onGroundFilterTime)
        {
            // Not long enough, no event!
            self.lastGroundLeaveTime = time;
            return;
        }
        self.lastGroundLeaveTime = time;
    }

    // OK, we didn't return so we truly changed the state
    self.isOnGround = isOnGround;

    // Callbacks for events start here
    self openCJ\FPSHistory::onOnGround(isOnGround);
}