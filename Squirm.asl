// Squirm Autosplitter
// version 1.0
// Author: Reicha7 (www.archieyates.co.uk)
// Supported features
//	- Split on each of the keys
//	- Split on each of the stars
// 	- Split on reaching Crackers
// IMPORTANT
//  - Only supports game version 3.0
//  - Requires Environment Variable set up called "squirm" that points at the SQUIRM steam folder (see README)

state("Squirm") 
{
}

startup 
{
    vars.delimiter = "\":";
    vars.splitIndex = 0;
    vars.startTracking = false;
    vars.currentLevel = -1;
    vars.previousLevel = -1;
    vars.crackersSplit = false;

    // save file keys
    vars.splits = new string[] {
        "workStar",
        "hasLudoKey",

        "spookStar",
        "hasSkeleKey",

        "iceStar", 
        "hasFattyKey",

        "castleStar",
        "mouseKey",

        "towerStar",
        "towerKey",

        "spaceStar",
        "cloudKey"
        };

    // map settings to save file keys
    settings.Add("keys", true, "Keys");
    settings.Add(vars.splits[1], true, "Split on Ludo's Key", "keys");
    settings.Add(vars.splits[3], true, "Split on Skelord's Key", "keys");
    settings.Add(vars.splits[5], true, "Split on Fatty's Key", "keys");
    settings.Add(vars.splits[7], true, "Split on Castle Key", "keys");
    settings.Add(vars.splits[9], true, "Split on Tower Key", "keys");
    settings.Add(vars.splits[11], true, "Split on Cotton's Key", "keys");


    settings.Add("stars", false, "Stars");
    settings.Add(vars.splits[0], false, "Split on Sirius B", "stars");
    settings.Add(vars.splits[2], false, "Split on Kappa Ceti", "stars");
    settings.Add(vars.splits[4], false, "Split on Cygnus X-1", "stars");
    settings.Add(vars.splits[6], false, "Split on Beta Andromedae", "stars");
    settings.Add(vars.splits[8], false, "Split on Antares B", "stars");
    settings.Add(vars.splits[10], false, "Split on VY Canis Majoris", "stars");

    settings.Add("crackers", true, "Split on Reaching Crackers");
}

init 
{
    // Need an environment variable set up to point at the SQUIRM folder
	string logPath = Environment.GetEnvironmentVariable("squirm")+"\\Save\\Read-Only Save Progress.txt";
	vars.line = "";
    vars.fileStream = new FileStream(logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
	vars.reader = new StreamReader(vars.fileStream); 
	print("[Squirm Autosplitter] Opened log " + logPath);
}
 
exit
{
	print("[Squirm Autosplitter] game closed");
	vars.reader = null;
}

start
{
    vars.splitIndex = 0;
    vars.startTracking = false;
    vars.crackersSplit = false;
    vars.currentLevel = -1;
    vars.previousLevel = -1;
}

update
{	
	if (vars.reader == null) return false;

    vars.fileStream.Seek(0, SeekOrigin.Begin);
    vars.reader.DiscardBufferedData();
    vars.line = vars.reader.ReadLine();

    // Check level transitions
    string levelString = "currentLevel" + vars.delimiter;
    int start = vars.line.IndexOf(levelString, 0) + levelString.Length;
    int end = vars.line.IndexOf(",", start);
        
    string levelNumber = vars.line.Substring(start, end - start);
    int level = Int32.Parse(levelNumber);
    
    if(level != vars.currentLevel)
    {
        print("[Squirm Autosplitter] Entered Level " + levelNumber);
        vars.previousLevel = vars.currentLevel;
        vars.currentLevel = level;
    }

    // Don't start tracking unless we have entered the first level from the loading screen
    if(!vars.startTracking)
    {
        if(vars.currentLevel == 2 && vars.previousLevel == 0)
        {
            vars.startTracking = true;
        }
        else
        {
            return true;
        }
    }

    // If we have gone over the save keys array length
    if(vars.splitIndex >= vars.splits.Length)
    {
        return true;
    }

    // If we are interested in the current save key index then do nothing
    if(settings[vars.splits[vars.splitIndex]])
    {
        return true;
    }
    else
    {
        // Otherwise move on to next save key
        vars.splitIndex++;

        if(vars.splitIndex < vars.splits.Length && settings[vars.splits[vars.splitIndex]])
        {
            print("[Squirm Autosplitter] Now tracking " + vars.splits[vars.splitIndex]);
        }
        else if (settings["crackers"] && !vars.crackersSplit)
        {
            print("[Squirm Autosplitter] Now tracking Reached Crackers");
        }
        else if(vars.splitIndex >= vars.splits.Length)
        {
            print("[Squirm Autosplitter] Finished Tracking Variables");
        }
    }

}

split
{
    // Prevent early splits from old save files
    if(!vars.startTracking)
    {
        return false;
    }

    // If we have gone over the save keys array
    if(vars.splitIndex >= vars.splits.Length)
    {   
        // Special check for crackers split as its level based
        if(settings["crackers"] && !vars.crackersSplit)
        {
            if(vars.currentLevel == 160 && vars.previousLevel == 159)
            {
                vars.crackersSplit = true;
                return true;
            }
        }

        return false;
    }

    // If we care about this current save key
    if(settings[vars.splits[vars.splitIndex]])
    {
        // Get the save key's true/false value
        string targetString = vars.splits[vars.splitIndex] + vars.delimiter;
        int start = vars.line.IndexOf(targetString, 0) + targetString.Length;
        int end = vars.line.IndexOf(",", start);
        
        string result = vars.line.Substring(start, end - start);

        if(result == "true")
        {
            vars.splitIndex++;
            
            // Check what the next tracked setting is
            if(vars.splitIndex < vars.splits.Length && settings[vars.splits[vars.splitIndex]])
            {
                print("Now tracking " + vars.splits[vars.splitIndex]);
            }
            else if (settings["crackers"] && !vars.crackersSplit)
            {
                print("[Squirm Autosplitter] Now tracking Reached Crackers");
            }
            else if(vars.splitIndex >= vars.splits.Length)
            {
                print("[Squirm Autosplitter] Finished Tracking Variables");
            }

            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        // Repeat of the update method
        vars.splitIndex++;

        if(vars.splitIndex < vars.splits.Length && settings[vars.splits[vars.splitIndex]])
        {
            print("Now tracking " + vars.splits[vars.splitIndex]);
        }
        else if (settings["crackers"] && !vars.crackersSplit)
        {
            print("[Squirm Autosplitter] Now tracking Reached Crackers");
        }
        else if(vars.splitIndex >= vars.splits.Length)
        {
            print("[Squirm Autosplitter] Finished Tracking Variables");
        }

         return false;
    }
}
