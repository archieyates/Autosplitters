// Loop-Loop DX Autosplitter
// version 1.0
// Author: Reicha7 (www.archieyates.co.uk)
// Supported Categories
// - Adventure Mode
// IMPORTANT
//  - Developed using asl-help (https://github.com/just-ero/asl-help/blob/main/lib/asl-help)

state("Loop-Loop DX") 
{
}

startup 
{
    // Without this nothing will work
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Loop-Loop DX";

    // We use a cached list of splits based on user settings and then only check against ones we haven't reached
    vars.Splits = new List<string>();

    settings.Add("adventure", true, "Adventure");
	settings.SetToolTip("adventure", "Variables for Adventure Mode");

    // Splits that we can directly look up in memory
    vars.TrackedSplitVariables = new Dictionary<string, Tuple<string, string, bool>> 
	{
        {"beatFirstLevel",Tuple.Create("Beat Red Zone", "adventure", true)},
        {"beatYellow",Tuple.Create("Beat Yellow Zone", "adventure", true)},
        {"beatGreen",Tuple.Create("Beat Green Zone", "adventure", true)},
        {"beatBlue",Tuple.Create("Beat Blue Zone", "adventure", true)},
        {"beatPurple",Tuple.Create("Beat Purple Zone", "adventure", true)},
        {"beatWhite",Tuple.Create("Beat White Zone", "adventure", true)},
        {"beatFinalBoss",Tuple.Create("Defeated Warden", "adventure", true)},
    };

    foreach (var sv in vars.TrackedSplitVariables)
    {
        settings.Add(sv.Key, sv.Value.Item3, sv.Value.Item1, sv.Value.Item2);
    };
}

init 
{
    // Search the game for the memory addresses
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
        // All the main game variables
        foreach (var sv in vars.TrackedSplitVariables)
        {
            vars.Helper[sv.Key] = mono.Make<bool>("Game", sv.Key);
        }
		return true;
	});
}

update
{
    // Just for tracking
    // foreach (var sv in vars.TrackedSplitVariables)
    // {
    //      if(vars.Helper[sv.Key].Old != vars.Helper[sv.Key].Current)
    //      {
    //         print("[Loop Loop] Variable " + sv.Key + " changed to " + vars.Helper[sv.Key].Current);
    //      }
    // }
}

onStart
{
    // Go through all selected split settings and cache them
    vars.Splits.Clear();
    
    foreach (var split in vars.TrackedSplitVariables)
    {
        if(settings[split.Key])
        {
            vars.Splits.Add(split.Key);
        }
    }
}

split
{   
    int index = 0;
    bool splitThisFrame = false;

    // Go through all the currently cached splits
    // If we meet the criteria for that split then remove it from the list and trigger the split
    foreach (string split in vars.Splits)
    {
        if(vars.Helper[split].Current && vars.Helper[split].Old != vars.Helper[split].Current)
        {
            splitThisFrame = true;
            break;
        }

        index++;
    }

    // Once we've split for an event remove it from the list of splits we care about
    if(splitThisFrame)
    {
        vars.Splits.RemoveAt(index);
    }

    return splitThisFrame;
}
