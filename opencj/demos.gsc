#include openCJ\util;

onInit()
{
	openCJ\commands::registerCommand("record", "starts/stops recording", ::record);
	openCJ\commands::registerCommand("play", "starts/stops playback", ::play);
}

record(args)
{
	if(self.recording)
	{
		self.recording = false;
		printf("angles end of recording: " + self getplayerangles() + "\n");
	}
	else
	{
		self.playing = false;
		self.recording = true;
		printf("angles start of recording: " + self getplayerangles() + "\n");
		self.demo = [];
	}
}

play(args)
{
	if(self.playing)
	{
		//self freezecontrols(false);
		self.playing = false;
	}
	else
	{
		//self freezecontrols(true);
		printf("angles start of playing: " + self getplayerangles() + "\n");
		self.recording = false;
		self.playing = true;
		self.framenumber = 0;
		self.play_linkto = spawn("script_origin", (0, 0, 0));
		self linkto(self.play_linkto, "", (0, 0, 0), (0, 0, 0));
	}
}

onRunIDCreated()
{
	self.recording = false;
	self.playing = false;
	self.framenumber = 0;
	self.demo = [];
}

whileAlive()
{
	if(self.recording)
	{
		frame = spawnStruct();
		frame.origin = self.origin;
		frame.speed = self getVelocity();
		frame.angles = self getPlayerAngles();
		self.demo[self.demo.size] = frame;
	}
	if(self.playing)
	{
		frame = self.demo[self.framenumber];
		if(!isDefined(frame))
		{
			self.playing = false;
			self.framenumber = 0;
			return;
		}
		self.play_linkto.origin = frame.origin;
		self setPlayerAngles(frame.angles);
		self.framenumber++;
	}
}