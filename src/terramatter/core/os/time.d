module terramatter.core.os.time;

import std.datetime;
import std.conv;

class Time {
	public static const double SECOND = 10_000_000L;

	public static double getTime()	{
		return Clock.currStdTime().to!double / SECOND;
	}
}
