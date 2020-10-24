// Author: Reicha7 (www.archieyates.co.uk)
// Supported versions:
//	- Steam
//	- Windows Store
// Supported features
//	- Split on "Operation Complete"
//	- Split on killing Maximillion

state("Valkyria", "Steam")
{
	// This seems to be set the moment we enter 18-2
	int maximillionHealth : "Valkyria.exe", 0x1783510, 0xD8, 0x4, 0xFC, 0x4, 0x50;
	// Set to 1 when booting the game, 0 when entering first mission post-boot, and 4 when "Operation Complete" is displayed
	byte operationComplete : "Valkyria.exe", 0x177D95A;
}

state("Valkyria", "Windows")
{
	// This seems to be set the moment we enter 18-2
	int maximillionHealth : "Valkyria.exe", 0x175CF14, 0x94, 0x294, 0xFC, 0x4, 0x50;
	// Set to 1 when booting the game, 0 when entering first mission post-boot, and 4 when "Operation Complete" is displayed
	byte operationComplete : "Valkyria.exe", 0x175739A;
}

startup
{
	vars.maxActive = false;
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

	print("Module Size: "+moduleSize+" "+module.ModuleName);
	print("Version: "+version);
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
	if(current.maximillionHealth == 0 && vars.maxActive)
	{
		vars.maxActive = false;
		return true;
	}
	else if(current.operationComplete == 4 && old.operationComplete == 0)
	{
		return true;
	}
}

isLoading
{
	return false;
}