// Author: Reicha7 (www.archieyates.co.uk)
// This autosplitter is currently WIP

state("Valkyria", "Gamepass")
{
	// This seems to be set the moment we enter the level
	int maximillionHealth : "Valkyria.exe", 0x175CF14, 0x94, 0x294, 0xFC, 0x4, 0x50;
	// Does not cover the momentary fade (at the moment)
	int pause : "Valkyria.exe", 0x00C6ED0, 0x4;
}

state("Valkyria", "Steam")
{
	// This seems to be set the moment we enter the level
	int maximillionHealth : "Valkyria.exe", 0x1783510, 0xD8, 0x4, 0xFC, 0x4, 0x50;
	// Does not cover the momentary fade (at the moment)
	int pause : "Valkyria.exe", 0x00C6ED0, 0x4;
}

startup
{
	vars.maxActive = false;
}

update
{
	if(current.maximillionHealth == 3000)
	{
		vars.maxActive = true;
	}
}

split
{
	if(current.pause == 0)
	{
		if(current.maximillionHealth == 0 && vars.maxActive)
		{
			vars.maxActive = false;
			return true;
		}
	}
}

isLoading
{
	if(current.pause == 1)
	{
		return true;
	}
	else
	{
		return false;
	}
}