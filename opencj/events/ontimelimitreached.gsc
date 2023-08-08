main()
{
    // WARNING: this event is called multiple times due to end map vote
    // Instead, consider using onMapEnded!

    thread opencj\menus\endMapVote::onTimeLimitReached();
    thread opencj\huds\hudTimeLimit::onTimeLimitReached();
}