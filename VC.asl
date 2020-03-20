state("Valkyria", "Gamepass")
{
	// Original Test values but I don't think these pointers stick around as they seem to be set at the point max takes damage
	//int maximillionHealth : "Valkyria.exe", 0x175CE48, 0x80, 0x234, 0x50, 0x30, 0xBA0, 0x39C, 0x38;
	//int maximillionHealth : "Valkyria.exe", 0x1321070, 0x140, 0x140, 0x188, 0x14, 0x1A8, 0x34, 0x38;
	
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