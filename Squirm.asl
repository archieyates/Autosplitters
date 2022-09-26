// Squirm Autosplitter
// version 2.2
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
    vars.delimiter = "\":";

    settings.Add("extendedParty", false, "Use Extended Surprise Party Splits");
	settings.SetToolTip("extendedParty", "Enable the autosplitter for each level of surprise party from 180-192. You still need to manually split for start and finish.");
}

init 
{
    // Need an environment variable set up to point at the SQUIRM folder
	string logPath = Environment.GetEnvironmentVariable("squirm")+"\\Save\\Read-Only Save Progress.txt";
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

    // Get the correct split array
    string[] anySplits = {"hasLudoKey", "beatSkele", "hasFattyKey", "mouseKey", "towerKey", "cloudKey"};
    string[] hundredSplits = {"workStar", "hasLudoKey", "spookStar", "hasSkeleKey", "iceStar", "hasFattyKey", "castleStar", "mouseKey", "towerStar", "towerKey", "spaceStar", "cloudKey"};
    if(vars.any)
    {
        vars.splitVariables = anySplits;
        print("[Squirm Autosplitter] Any%");
    }
    else if (vars.hundred)
    {
        vars.splitVariables = hundredSplits;
        print("[Squirm Autosplitter] 100%");
    }
    else if (vars.party)
    {
        if (settings["extendedParty"])
        {
            print("[Squirm Autosplitter] Extended Party");
        }
        else
        {
            print("[Squirm Autosplitter] Surprise Party");
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

        // Split on finishing Inverse World
        if(vars.changedLevel && vars.currentLevel == 160 && vars.previousLevel == 159)
        {
            return true;
        }
        
        // Split on fading to black on Any%
        if(vars.changedLevel && vars.any && vars.currentLevel == 162 && vars.previousLevel == 161)
        {
            return true;
        }

        // Don't parse the save file if there we have gone beyond the array
        if(segment >= vars.splitVariables.Length)
        {
            return false;
        }
 
        // Get the string we will search the save file for based on our segment
        targetString = vars.splitVariables[segment] + vars.delimiter;

        // We have our target string so find what its value is set to and use this to split
        int start = vars.line.IndexOf(targetString, 0) + targetString.Length;
        int end = vars.line.IndexOf(",", start);
        string result = vars.line.Substring(start, end - start);

        if(result == "true")
        {
            return true;
        }
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
