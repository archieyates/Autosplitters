// Valkyria Chronicles Autosplitter
// version 1.1
// Author: Reicha7 (www.archieyates.co.uk)
// Supported versions:
//	- Steam
//	- Windows Store
// Supported features
//	- Split on "Operation Complete"
//	- Split on killing Maximillion

state("Valkyria", "Steam")
{
	// This is a static address that various values get set in depending on the mission and can be utilised for identifying key info
	int levelFlag : "Valkyria.exe", 0x16093CC;
	// Set to 1 when booting the game, 0 when entering first mission post-boot, and 4 when "Operation Complete" is displayed
	byte operationComplete : "Valkyria.exe", 0x177DA4A;
}

state("Valkyria", "Windows")
{
	// This is a static address that various values get set in depending on the mission and can be utilised for identifying key info
	int levelFlag : "Valkyria.exe", 0x15E2E0C;
	// Set to 1 when booting the game, 0 when entering first mission post-boot, and 4 when "Operation Complete" is displayed
	byte operationComplete : "Valkyria.exe", 0x175739A;
}

startup
{
	vars.maxActive = false;
	vars.inFouzen2 = false;
	vars.fouzenSplit = false;

	// Key values that the levelFlag can be set to
	vars.fouzen1 = 245;
	vars.fouzen2 = 280;
	vars.marberry = 360;
	vars.selvariaHealth = 1000;
	vars.maxillianHealth = 3000;
}

init
{
	var module = modules.Single(x => String.Equals(x.ModuleName, "Valkyria.exe", StringComparison.OrdinalIgnoreCase));
	var moduleSize = module.ModuleMemorySize;

	if(moduleSize == 27570176)
	{
		version = "Steam";
	}
	else if (moduleSize == 27410432)
	{
		version = "Windows";
	}

	print("[VC Autosplitter] Module Size: "+moduleSize+" "+module.ModuleName);
	print("[VC Autosplitter] Version: "+version);
}

start
{
	vars.maxActive = false;
	vars.inFouzen2 = false;
	vars.fouzenSplit = false;
}

update
{
	// If our level flag matches Max's hit point maximum then we are in 18-2
	if(current.levelFlag == vars.maxillianHealth && !vars.maxActive)
	{
		vars.maxActive = true;
		print("[VC Autosplitter] Maximillion Active");
	}

	// If the current level flag matches 10-2 and we are not currently there and have not already split there then set us there
	if(current.levelFlag == vars.fouzen2 && old.levelFlag == vars.fouzen1 && !vars.inFouzen2 && !vars.fouzenSplit)
	{
		vars.inFouzen2 = true;
		vars.fouzenSplit = false;
		print("[VC Autosplitter] In Fouzen 2");
	}

	// If our InFouzen2 flag is set but the current level flag doesn't match 10-2 then unset us as being in 10-2
	if(vars.inFouzen2 && current.levelFlag != vars.fouzen2)
	{
		vars.inFouzen2 = false;
		print("[VC Autosplitter] Not in Fouzen 2");
	}
}

split
{
	// If Max has died then split
	if(vars.maxActive && current.levelFlag == 0 && old.levelFlag != 0)
	{
		print("[VC Autosplitter] Split on Max");
		return true;
	}

	// "Operation Complete"
	if(current.operationComplete == 4 && old.operationComplete == 0)
	{
		// If we killed Max then don't try to split again
		if(vars.maxActive)
		{
			print("[VC Autosplitter] Deactivating Max");
			vars.maxActive = false;
			return false;
		}

		// There's a bug where on NG completing 10-2 will fire the operationComplete flag multiple times
		if(vars.inFouzen2)
		{
			if(vars.fouzenSplit)
			{
				print("[VC Autosplitter] Prevented extra Fouzen split");
				return false;
			}
			else
			{
				vars.fouzenSplit = true;
				print("[VC Autosplitter] Fouzen Split");
				return true;
			}
		}

		vars.maxActive = false;
		return true;
	}
}
