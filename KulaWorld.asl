// Author: Reicha7 (www.archieyates.co.uk)

// ePSXe version 2.0
state("ePSXe", "SLUS-00724")
{
	// End level screen bit set
	int end : "ePSXe.exe", 0x8BECBC;
}

init
{
	vars.levelCount = 0;
	vars.levelForWorldCount = 0;
}

startup
{
	// Setting to only split on world changes rather than every level
	settings.Add("splitOnWorld", false, "Split on World");
	settings.SetToolTip("splitOnWorld", "Only split when a world (15 levels) is finished");
}

split
{
	// Special condition for the final level
	if(current.end == 1 && old.end == 0)
	{
		vars.levelCount++;
		if(vars.levelCount == 150)
		{
			return true;
		}
	}

	// Split when exiting the post-level menu
	if(current.end == 0 && old.end == 1)
	{
		if (settings["splitOnWorld"]) 
		{  
			vars.levelForWorldCount++;

			if(vars.levelForWorldCount == 15)
			{
				vars.levelForWorldCount = 0;
				return true;
			}
		}
		else
		{
			return true;
		}	
	}
}