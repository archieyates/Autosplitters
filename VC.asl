// Valkyria Chronicles Autosplitter
// version 1.3
// Author: Reicha7 (www.archieyates.co.uk)
// Supported versions:
//	- Steam
//	- Windows Store
// Supported features
//	- Split on "Operation Complete"
//	- Split on killing Maximillion
// 	- Load Removal

state("Valkyria", "Steam")
{
	// This is a static address that various values get set in depending on the mission and can be utilised for identifying key info
	int levelFlag : "Valkyria.exe", 0x16093CC;
	// Set to 1 when booting the game, 0 when entering first mission post-boot, and 4 when "Operation Complete" is displayed
	byte operationComplete : "Valkyria.exe", 0x177DA4A;
	// This boolean is set to true when the Loading Screen icon is being shown
	bool loading : "Valkyria.exe", 0x1783E9C;
}

state("Valkyria", "Windows")
{
	// This is a static address that various values get set in depending on the mission and can be utilised for identifying key info
	int levelFlag : "Valkyria.exe", 0x15E2E0C;
	// Set to 1 when booting the game, 0 when entering first mission post-boot, and 4 when "Operation Complete" is displayed
	byte operationComplete : "Valkyria.exe", 0x175739A;
	// This boolean is set to true when the Loading Screen icon is being shown
	bool loading : "Valkyria.exe", 0x175D8DC;
}

startup
{
	vars.maxActive = false;
	vars.allowSplit = true;
	vars.splitBlocker = 0;

	// Key values that the levelFlag can be set to
	//vars.fouzen1 = 245;
	//vars.fouzen2 = 280;
	//vars.marberry = 360;
	//vars.selvariaHealth = 1000;
	vars.maxillianHealth = 3000;

	settings.Add("splitOnMax", true, "Split on Killing Max");
	settings.SetToolTip("splitOnMax", "Split when killing Maximillian rather than on Operation Complete");
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
	vars.allowSplit = true;
	vars.splitBlocker = 0;
}

update
{
	// If our level flag matches Max's hit point maximum then we are in 18-2
	if(current.levelFlag == vars.maxillianHealth && !vars.maxActive)
	{
		if(settings["splitOnMax"])
		{
			vars.maxActive = true;
			print("[VC Autosplitter] Maximillion Active");
		}
	}

	// Check loading status
	if(current.loading && !old.loading)
	{
		print("[VC Autosplitter] Started Loading");
	}
	else if (old.loading && !current.loading)
	{
		print("[VC Autosplitter] Finished Loading");
	}

	// Force a minimum time to reset split allowance 
	if(!vars.allowSplit)
	{
		vars.splitBlocker = vars.splitBlocker+1;

		// 20 seconds at 60FPS
		if(vars.splitBlocker >= 1200)
		{
			vars.splitBlocker = 0;
			vars.allowSplit = true;
			print("[VC Autosplitter] Unblocking splits");
		}
	}
}

split
{
	if(!vars.allowSplit)
	{
		return false;
	}

	// If Max has died then split
	if(vars.maxActive && current.levelFlag == 0 && old.levelFlag != 0)
	{
		print("[VC Autosplitter] Split on Max");
		vars.allowSplit = false;
		return true;
	}

	// "Operation Complete"
	if(current.operationComplete == 4 && old.operationComplete == 0)
	{
		vars.maxActive = false;

		// If we killed Max then don't try to split again
		if(vars.maxActive)
		{
			print("[VC Autosplitter] Deactivating Max");
			return false;
		}

		vars.allowSplit = false;
		return true;
	}
}

isLoading
{
	return current.loading;
}
