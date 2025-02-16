// Squirm Autosplitter
// version 4.6
// Author: Reicha7 (www.archieyates.co.uk)
// Supported Categories
//	- Any% (RTA & IGT)
//  - 100% (RTA & IGT)
//  - Surprise Party (RTA only) [Start Support]
//  - DLC (RTA only)
// IMPORTANT
//  - Only confirmed to be supported in version 3.x
//  - Developed using asl-help (https://github.com/just-ero/asl-help/blob/main/lib/asl-help)

state("Squirm") 
{
}

startup 
{
    // Without this nothing will work
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Squirm";
	vars.Helper.LoadSceneManager = true;

    // We use a cached list of splits based on user settings and then only check against ones we haven't reached
    vars.Splits = new List<string>();

    // Any% and 100% share a lot of variables so grouping them up
    settings.Add("main", true, "Any% and 100%");
	settings.SetToolTip("main", "Any% and 100% share a lot of variables");

    settings.Add("any", true, "Shared", "main");
	settings.SetToolTip("any", "These variables can be used in both Any% and 100% speedruns");

    settings.Add("100", false, "100%", "main");
	settings.SetToolTip("100", "These variables will only be needed for 100% speedruns");

    // All any% and 100% variables in settings order (tracked, setting, category, default value)
    var sharedVariables = new Dictionary<string, Tuple<bool, string, string, bool>>
    {
        {"hasGun",Tuple.Create(true, "Gun", "any", false)},
        {"beatLudo",Tuple.Create(true, "Kill Ludo", "any", false)},
        {"hasLudoKey",Tuple.Create(true, "Ludo Key", "any", true)},
        {"hasDubJump",Tuple.Create(true, "Double Jump", "any", false)},
        {"reachedSkelord",Tuple.Create(false, "Reached Skelord", "any", false)},
        {"beatSkele",Tuple.Create(true, "Kill Skelord", "any", true)},
        {"hasSkeleKey",Tuple.Create(true, "Skelord Key", "any", false)},
        {"reachedFatty",Tuple.Create(false, "Reached Fatty", "any", false)},
        {"beatFatty",Tuple.Create(true, "Beat Fatty", "any", false)},
        {"hasFattyKey",Tuple.Create(true, "Fatty Key", "any", true)},
        {"lever1",Tuple.Create(true, "Left Lever", "any", false)},
        {"lever3",Tuple.Create(true, "Right Lever", "any", false)},
        {"lever2",Tuple.Create(true, "Upper Lever", "any", false)},
        {"reachedBlocka",Tuple.Create(false, "Reached Blocka", "any", false)},
        {"mouseKey",Tuple.Create(true, "Castle Key", "any", true)},
        {"reachedJetpack",Tuple.Create(false, "Reached Tower Jetpack", "any", false)},
        {"towerKey",Tuple.Create(true, "Tower Key", "any", true)},
        {"killedSun",Tuple.Create(true, "Killed Sun", "any", false)},
        {"reachedCotton",Tuple.Create(false, "Reached Cotton", "any", false)},
        {"cloudKey",Tuple.Create(true, "Cotton Key", "any", true)},
        {"openedChest",Tuple.Create(true, "Inverse World Chest", "any", false)},
        {"inverseWorld",Tuple.Create(false, "Reached Float", "any", true)},
        {"float",Tuple.Create(false, "Fade out after Float Kill", "any", true)},
        {"workStar",Tuple.Create(true, "Hub Star", "100", false)},
        {"spookStar",Tuple.Create(true, "Spook Star", "100", false)},
        {"iceStar",Tuple.Create(true, "Ice Star", "100", false)},
        {"castleStar",Tuple.Create(true, "Castle Star", "100", false)},
        {"towerStar",Tuple.Create(true, "Tower Star", "100", false)},
        {"spaceStar",Tuple.Create(true, "Space Star", "100", false)},
        {"heart",Tuple.Create(false, "Talk to Heart", "100", false)},
    };

    // Go through settings and cached tracked and untracked variables separately
    vars.TrackedSplitVariables = new Dictionary<string, Tuple<string, string, bool>>{};
    vars.UntrackedSplitVariables = new Dictionary<string, Tuple<string, string, bool>>{};
    foreach (var sv in sharedVariables)
    {
        settings.Add(sv.Key, sv.Value.Item4, sv.Value.Item2, sv.Value.Item3);

        if(sv.Value.Item1 == true)
        {
            vars.TrackedSplitVariables.Add(sv.Key, Tuple.Create(sv.Value.Item2, sv.Value.Item3, sv.Value.Item4));     
        }
        else
        {
            vars.UntrackedSplitVariables.Add(sv.Key, Tuple.Create(sv.Value.Item2, sv.Value.Item3, sv.Value.Item4));
        }
    };

    // Party
    settings.Add("party", false, "Surprise Party");
	settings.SetToolTip("party", "Surprise Party Mode with support for each individual level");

    // Interacting with the present
    settings.Add("present", true, "Present", "party");
	settings.SetToolTip("present", "Split when interacting with the present at the end of the party");

    // Level IDs for each of the Surprise Party Levels
    for (int i = 179; i < 192; i++) 
    {
        string ID = "lv" + i;
        string display = "Level " + i;

        settings.Add(ID, false, display, "party");
        settings.SetToolTip(ID, "Split when finishing the screen for level " + i);
    }

    // DLC
    settings.Add("dlc", false, "DLC");
	settings.SetToolTip("dlc", "DLC mode with support for key points");
    
    // None of the DLC splits are things we can directly track in memory
    vars.DLCSplitVariables = new Dictionary<string, Tuple<string, string, bool>> 
	{
        {"nexus",Tuple.Create("Reach Nexus", "dlc", true)},
        {"rainbowSun",Tuple.Create("Reach Rainbow Sun", "dlc", false)},
        {"trueNexus",Tuple.Create("Reach True Nexus", "dlc", true)},
        {"trueNexusBoss",Tuple.Create("Reach God of Light", "dlc", true)},
        {"dlcStar",Tuple.Create("Nexus Star", "dlc", true)}
    };

    foreach (var sv in vars.DLCSplitVariables)
    {
        settings.Add(sv.Key, sv.Value.Item3, sv.Value.Item1, sv.Value.Item2);
    };
}

init 
{
    // Search the game for the memory addresses
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
        // Tracking level
        vars.Helper["Level"] = mono.Make<int>("Game", "currentLevel");

        // All the main game variables
        foreach (var sv in vars.TrackedSplitVariables)
        {
            vars.Helper[sv.Key] = mono.Make<bool>("Game", sv.Key);
        }

        // Cutscene used for interacting with objects
        vars.Helper["Cutscene"] = mono.Make<bool>("Game", "inCutscene");

        // Used to grab the accurate in-game time
        vars.Helper["IGT"] = mono.Make<float>("Game", "timePlayed");

		return true;
	});
}

update
{
    if(settings["dlc"])
    {
        current.activeScene = vars.Helper.Scenes.Active.Name == null ? current.activeScene : vars.Helper.Scenes.Active.Name;
    }

    // Debugging
    // if(current.Level != old.Level)
    // {
    //     print("[Squirm Autosplitter] New Level: "+current.Level);
    // }

    // if(old.Cutscene != current.Cutscene)
    // {
    //     print("[Squirm Autosplitter] Cutscene: "+current.Cutscene);
    // }

	// if(current.activeScene != old.activeScene) 
    // {
    //     print("[Squirm Autosplitter] Scene change Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
    // }
}

start
{
    // Start when selecting the present (Surprise Party Only!)
    if(settings["party"] && timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
     if(current.Cutscene && old.Cutscene != current.Cutscene && current.Level == 16)
     {
        return true;
     }
    }
}

onStart
{
    if(settings["main"])
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

        foreach (var split in vars.UntrackedSplitVariables)
        {
            if(settings[split.Key])
            {
                vars.Splits.Add(split.Key);
            }
        }
    }

    // 179 is first level of surprise party
    if(settings["party"])
    {
        vars.FurthestPartyLevel = 179;
    }

    if(settings["dlc"])
    {
        foreach (var split in vars.DLCSplitVariables)
        {
            if(settings[split.Key])
            {
                vars.Splits.Add(split.Key);
            }
        }
    }
}

gameTime
{
    // When running Game Time use the game's recorded settings
    return TimeSpan.FromSeconds(current.IGT);
}

split
{   
    // Any% and 100%
    if(settings["main"])
    {
        int index = 0;
        bool splitThisFrame = false;

        // Go through all the currently cached splits. If we meet the criteria for that split then remove it from the
        // list and trigger the split
        foreach (string split in vars.Splits)
        {
            switch(split) 
            {
            case "reachedSkelord":
                if(old.Level == 34 && current.Level == 35)
                {
                    splitThisFrame = true;
                }
                break;
            case "reachedFatty":
                if(old.Level == 53 && current.Level == 57)
                {
                    splitThisFrame = true;
                }
                break;
            case "reachedBlocka":
                if(old.Level == 75 && current.Level == 76)
                {
                    splitThisFrame = true;
                }
                break;
            case "reachedJetpack":
                if(old.Level == 88 && current.Level == 92)
                {
                    splitThisFrame = true;
                }
                break;
            case "reachedCotton":
                if(old.Level == 113 && current.Level == 114)
                {
                    splitThisFrame = true;
                }
                break;
            case "inverseWorld":
                if(old.Level == 159 && current.Level == 160)
                {
                    splitThisFrame = true;
                }
                break;
            case "float":
                if(old.Level == 161 && current.Level == 162)
                {
                    splitThisFrame = true;
                }
                break;
            case "heart":
                if(current.Cutscene && old.Cutscene != current.Cutscene && current.Level == 177)
                {
                    splitThisFrame = true;
                }
                break;
            default:
                // All other splits are just bools in the game memory
                if(vars.Helper[split].Current && vars.Helper[split].Old != vars.Helper[split].Current)
                {
                    splitThisFrame = true;
                }
                break;
            }

            if(splitThisFrame)
            {
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

    // Surprise Party
    if(settings["party"])
    {
        if(settings["present"])
        {
            if(current.Cutscene && old.Cutscene != current.Cutscene && current.Level == 192)
            {
                return true;
            }
        }

        // Check if we have gone beyond a level and split if we care about that level
        for (int i = vars.FurthestPartyLevel; i < 192; i++) 
        {
            if(current.Level > vars.FurthestPartyLevel && current.Level != old.Level)
            {
                 string ID = "lv" + i;

                vars.FurthestPartyLevel = current.Level;
                if(settings[ID])
                {   
                    return true;
                }
            }
        }

    }

    if(settings["dlc"])
    {
        int index = 0;
        bool splitThisFrame = false;

        // Go through all the currently cached splits. If we meet the criteria for that split then remove it from the
        // list and trigger the split
        foreach (string split in vars.Splits)
        {
            switch(split) 
            {
            case "nexus":
            if(current.activeScene != old.activeScene && current.activeScene == "Rainbow Nexus 0")
            {
                splitThisFrame = true;
            }
                break;
            case "rainbowSun":
                if(current.activeScene != old.activeScene && current.activeScene == "Rainbow Nexus BOSS")
                {
                    splitThisFrame = true;
                }
                break;
            case "trueNexus":
                if(current.activeScene != old.activeScene && current.activeScene == "Nexus Core 0")
                {
                    splitThisFrame = true;
                }
                break;
            case "trueNexusBoss":
                if(current.activeScene != old.activeScene && current.activeScene == "Rainbow Nexus ACTUAL BOSS")
                {
                    splitThisFrame = true;
                }
                break;
            case "dlcStar":
                if(current.Cutscene && old.Cutscene != current.Cutscene && current.activeScene == "Rainbow Nexus END")
                {
                    splitThisFrame = true;
                }
                break;
            }

            if(splitThisFrame)
            {
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

    return false;
}

isLoading
{
    // Failsafe to make sure that Real Time is enforced for Surprise Party and DLC
    if(settings["party"] || settings["dlc"])
    {
        return false;
    }

    // Since we read from the game time directly we always want to pause the LiveSplit timer
    return true;
}
