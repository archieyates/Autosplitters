state("Valkyria4_x64")
{
	// Set to 1 when booting the game, 0 when entering first mission post-boot, and 4 when "Operation Complete" is displayed
	byte operationComplete : "Valkyria4_x64.exe", 0x13D5F8B;
}

update
{
    if(current.operationComplete != old.operationComplete)
    {
        print("[VC Autosplitter] Operation Complete changed to "+current.operationComplete);
    }
    
}


init
{
	var module = modules.Single(x => String.Equals(x.ModuleName, "Valkyria4_x64.exe", StringComparison.OrdinalIgnoreCase));
	var moduleSize = module.ModuleMemorySize;
    
	print("[VC Autosplitter] Module Size: "+moduleSize+" "+module.ModuleName);
}