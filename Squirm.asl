// Squirm Autosplitter
// version 3.0
// Author: Reicha7 (www.archieyates.co.uk)
// Supported features
//	- Any%
//  - 100%
//  - Extended Surprise Party
//  - Autostart for Any% and 100%
// IMPORTANT
//  - Only supports game version 3.0
//  - Requires Environment Variable set up called "squirm" that points at the SQUIRM steam folder (see README)

state("Squirm") 
{
}

startup 
{
    // Check for the save file existing
    vars.filepath = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\SQUIRM\\Save\\";
    string enviro = "squirm";
    if (!string.IsNullOrEmpty(Environment.GetEnvironmentVariable(enviro))) 
    {
        vars.filepath = Environment.GetEnvironmentVariable(enviro) + "\\Save\\";
    }

    // Error message if file doesn't exist
    if (!File.Exists(vars.filepath + "Read-Only Save Progress.txt")) 
    {
        var timingMessage = MessageBox.Show (
        "Cannot find Squirm save file at location:\n" + 
        vars.filepath + 
        "\n\nEither install Squirm to this location or set up an Environment variable pointing to the Squirm folder" + 
        "\n\nDetails can be found in readme file.",
        "LiveSplit | Squirm" );
    }

    vars.delimiter = "\":";
    vars.splits = new List<string>();

    settings.Add("main", true, "Any% and 100%");

    vars.SplitVariables = new Dictionary<string, Tuple<string, bool>> 
	{
        {"workStar",Tuple.Create("Hub Star", true)},
    //    {"hasGun",Tuple.Create("Gun", false)},
        {"beatLudo",Tuple.Create("Kill Ludo", false)},
        {"hasLudoKey",Tuple.Create("Ludo Key", true)},
        {"spookStar",Tuple.Create("Spook Star", true)},
    //    {"hasDubJump",Tuple.Create("Double Jump", false)},
        {"beatSkele",Tuple.Create("Kill Skelord", true)},
        {"hasSkeleKey",Tuple.Create("Skelord Key", false)},
        {"iceStar",Tuple.Create("Ice Star", true)},
        {"beatFatty",Tuple.Create("Beat Fatty", false)},
        {"hasFattyKey",Tuple.Create("Fatty Key", true)},
        {"lever1",Tuple.Create("Castle Lever 1", false)},
        {"lever2",Tuple.Create("Castle Lever 2", false)},
        {"castleStar",Tuple.Create("Castle Star", false)},
        {"lever3",Tuple.Create("Castle Lever 3", false)},
        {"beatBlocka",Tuple.Create("Killed Blocka", false)},
        {"mouseKey",Tuple.Create("Castle Key", true)},
        {"towerKey",Tuple.Create("Tower Key", true)},
        {"killedSun",Tuple.Create("Killed Sun", false)},
        {"cloudKey",Tuple.Create("Cotton Key", true)},
    //    {"inverseGun",Tuple.Create("Inverse World Gun", false)},
    //   {"inverseJump",Tuple.Create("Inverse World Double Jump", false)},
        {"openedChest",Tuple.Create("Inverse World Chest", false)},
        {"inverseWorld",Tuple.Create("Reached Crackers", true)},
        {"float",Tuple.Create("Fade out after Float Kill", true)},
    };

    foreach (var tag in vars.SplitVariables)
    {
        settings.Add(tag.Key, tag.Value.Item2, tag.Value.Item1, "main");
    };

    settings.Add("party", true, "Surprise Party");
    settings.Add("extendedParty", false, "Use Extended Surprise Party Splits", "party");
	settings.SetToolTip("extendedParty", "Enable the autosplitter for each level of surprise party from 180-192. You still need to manually split for start and finish.");
}

init 
{
    // Need an environment variable set up to point at the SQUIRM folder
	string logPath = vars.filepath + "Read-Only Save Progress.txt";
	vars.line = "";
    vars.fileStream = new FileStream(logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
	vars.reader = new StreamReader(vars.fileStream); 
	print("[Squirm Autosplitter] Opened log " + logPath);

    vars.enableSplits = false;
    vars.currentLevel = -1;
    vars.previousLevel = -1;
    vars.partyHighestLevel = -1;
    vars.any = false;
    vars.hundred = false;
    vars.party = false;
}

exit
{
	print("[Squirm Autosplitter] Game Closed");
	vars.reader = null;
}

start
{
    // If we have just changed to level 0 then we are in the New Game loading screen
    if(vars.currentLevel == 0 && vars.changedLevel == true)
    {
        if(timer.Run.CategoryName == "Surprise Party")
        {
            return false;
        }

        return true; 
    }
}

onStart
{
    vars.enableSplits = false;
    vars.changedLevel = false;
    vars.partyHighestLevel = -1;

    vars.any = timer.Run.CategoryName == "Any%";
    vars.hundred = timer.Run.CategoryName == "100%";
    vars.party = timer.Run.CategoryName == "Surprise Party";

    // Determine all the splits
    vars.splits.Clear();
    foreach (var tag in vars.SplitVariables)
    {
        if(settings[tag.Key])
        {
            print("[Squirm Autosplitter] Added Split: " + tag.Key);
            vars.splits.Add(tag.Key);
        }
    }
}

onReset
{
    vars.enableSplits = false;
    vars.changedLevel = false;
    vars.currentLevel = -1;
    vars.previousLevel = -1;
    vars.partyHighestLevel = -1;
}

update
{	
	if (vars.reader == null) 
    {
        return false;
    }

    // Read the save data
    vars.fileStream.Seek(0, SeekOrigin.Begin);
    vars.reader.DiscardBufferedData();
    vars.line = vars.reader.ReadLine();

    // Check level transitions
    string levelString = "currentLevel" + vars.delimiter;
    int start = vars.line.IndexOf(levelString, 0) + levelString.Length;
    int end = vars.line.IndexOf(",", start);
    
    // Get current level
    string levelNumber = vars.line.Substring(start, end - start);
    int level = Int32.Parse(levelNumber);
    
    // Check for level change
    if(level != vars.currentLevel)
    {
        vars.previousLevel = vars.currentLevel;
        vars.currentLevel = level;
        vars.changedLevel = true;
        print("[Squirm Autosplitter] Changing from Level: " + vars.previousLevel + " to " + vars.currentLevel);
    }
    else
    {
        vars.changedLevel = false;
    }
}

split
{
	if (vars.reader == null) 
    {
        return false;
    }

    var segment = timer.CurrentSplitIndex;
    string targetString = "";

    if(vars.any || vars.hundred)
    {
        // To stop livesplit autosplitting every frame after a reset (because the save is still valid) 
        // we wait until the loading screen has transitioned into the first level before enabling splits
        if(!vars.enableSplits)
        {
            if(vars.changedLevel && vars.currentLevel == 2 && vars.previousLevel == 0)
            {
                vars.enableSplits = true;
                print("[Squirm Autosplitter] Splits Enabled");
            }
            else
            {
                return false;
            }
        }

        int index = 0;
        bool remove = false;
        bool splitThisFrame = false;
        foreach (string split in vars.splits)
        {
            if (split == "inverseWorld")
            {
                if(vars.changedLevel && vars.currentLevel == 160 && vars.previousLevel == 159)
                {
                    splitThisFrame = true;
                    break;
                }
            }
            else if (split == "float")
            {
                if(vars.changedLevel && vars.any && vars.currentLevel == 162 && vars.previousLevel == 161)
                {
                    splitThisFrame = true;
                    break;
                }
            }
            else
            {
                // Get the string we will search the save file for based on our segment
                targetString = split + vars.delimiter;

                // We have our target string so find what its value is set to and use this to split
                int start = vars.line.IndexOf(targetString, 0) + targetString.Length;
                int end = vars.line.IndexOf(",", start);
                string result = vars.line.Substring(start, end - start);

                if(result == "true")
                {
                    splitThisFrame = true;
                    break;
                }
            }

            index++;
        }

        // If the split was either not in the settings or we found a viable split then remove from the split array
        if(splitThisFrame)
        {
            vars.splits.RemoveAt(index);
        }

        return splitThisFrame;
    }
    else if (vars.party && settings["extendedParty"])
    {
        if(vars.changedLevel == true)
        {
            // Split each time we move to the next party level
            if(vars.currentLevel >= 180 && vars.currentLevel <= 192 && vars.currentLevel > vars.partyHighestLevel)
            {
                vars.partyHighestLevel = vars.currentLevel;
                return true;
            }
        }
    }
        
    return false;
}
