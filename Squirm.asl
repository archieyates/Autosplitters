// Squirm Autosplitter
// version 1.1.1
// Author: Reicha7 (www.archieyates.co.uk)
// Supported features
//	- Split on each of the keys
//	- Split on each of the stars
//  - Split on available bosses
// 	- Split on finishing Mirror World
//  - Split on Finishing Any%
// IMPORTANT
//  - Only supports game version 3.0
//  - Requires Environment Variable set up called "squirm" that points at the SQUIRM steam folder (see README)
// Planned features
//  - Suprise Party

state("Squirm") 
{
}

startup 
{
    vars.delimiter = "\":";

    // save file keys
    vars.splits = new string[] 
    {
        "workStar",     // 0
        "beatLudo",     // 1
        "hasLudoKey",   // 2

        "spookStar",    // 3
        "beatSkele",    // 4
        "hasSkeleKey",  // 5

        "iceStar",      // 6
        "beatFatty",    // 7
        "hasFattyKey",  // 8

        "castleStar",   // 9
        "beatBlocka",   // 10
        "mouseKey",     // 11

        "towerStar",    // 12
        "towerKey",     // 13

        "spaceStar",    // 14
        "killedSun",    // 15
        "cloudKey"      // 16
    };

    // Categories
    settings.Add("main", true, "Main");
    settings.SetToolTip("main", "Splits for the Any% and 100% categories");

    settings.Add("keys", true, "Keys", "main");
    settings.SetToolTip("keys", "keys aquired for Any% and 100%");

    settings.Add("stars", false, "Stars", "main");
    settings.SetToolTip("stars", "Stars acquired for 100%");

    settings.Add("boss", false, "Bosses", "main");
    settings.SetToolTip("boss", "Bosses as a potential alternative to their keys");

    // Keys arranged to keep easier track of index
    settings.Add(vars.splits[0], false, "Split on Sirius B", "stars");
    settings.Add(vars.splits[1], false, "Split on killing Ludo", "boss");
    settings.Add(vars.splits[2], true, "Split on Ludo's Key", "keys");
    settings.Add(vars.splits[3], false, "Split on Kappa Ceti", "stars");
    settings.Add(vars.splits[4], false, "Split on killing Skelord", "boss");
    settings.Add(vars.splits[5], true, "Split on Skelord's Key", "keys");
    settings.Add(vars.splits[6], false, "Split on Cygnus X-1", "stars");
    settings.Add(vars.splits[7], false, "Split on killing Fatty", "boss");
    settings.Add(vars.splits[8], true, "Split on Fatty's Key", "keys");
    settings.Add(vars.splits[9], false, "Split on Beta Andromedae", "stars");
    settings.Add(vars.splits[10], false, "Split on killing Blocka", "boss");
    settings.Add(vars.splits[11], true, "Split on Castle Key", "keys");
    settings.Add(vars.splits[12], false, "Split on Antares B", "stars");
    settings.Add(vars.splits[13], true, "Split on Tower Key", "keys");
    settings.Add(vars.splits[14], false, "Split on VY Canis Majoris", "stars");
    settings.Add(vars.splits[15], false, "Split on killing Sun", "boss");
    settings.Add(vars.splits[16], true, "Split on Cotton's Key", "keys");

    // Special case we use for level-specific checks
    settings.Add("crackers", true, "Mirror World Split", "main");
    settings.SetToolTip("crackers", "Split upon reaching Crackers in the Mirror World");

    settings.Add("final", true, "Any% Final Split", "main");
    settings.SetToolTip("final", "Split after defeating Float and fading out (Any% timer end)");
}

init 
{
    // Need an environment variable set up to point at the SQUIRM folder
	string logPath = Environment.GetEnvironmentVariable("squirm")+"\\Save\\Read-Only Save Progress.txt";
	vars.line = "";
    vars.fileStream = new FileStream(logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
	vars.reader = new StreamReader(vars.fileStream); 
	print("[Squirm Autosplitter] Opened log " + logPath);

    vars.splitIndex = 0;
    vars.startTracking = false;
    vars.currentLevel = -1;
    vars.previousLevel = -1;
    vars.crackersSplit = false;
    vars.anySplit = false;
}
 
exit
{
	print("[Squirm Autosplitter] game closed");
	vars.reader = null;
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
        // 2 is the first level and 0 is the Loading Screen
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

        if(vars.splitIndex < vars.splits.Length)
        {
            if(settings[vars.splits[vars.splitIndex]])
            {
                print("[Squirm Autosplitter] Now tracking " + vars.splits[vars.splitIndex]);
            }
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
        if(settings["crackers"] && !vars.crackersSplit)
        {
            // 160 is the level we confront Crackers
            if(vars.currentLevel == 160 && vars.previousLevel == 159)
            {
                vars.crackersSplit = true;
                return true;
            }
        }
        else if(settings["final"] && !vars.anySplit)
        {
            // 162 is the post-Crackers boss fight level
            if(vars.currentLevel == 162 && vars.previousLevel == 161)
            {
                vars.anySplit = true;
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
            if(vars.splitIndex < vars.splits.Length)
            {
                if(settings[vars.splits[vars.splitIndex]])
                {
                    print("[Squirm Autosplitter] Now tracking " + vars.splits[vars.splitIndex]);
                }
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

        if(vars.splitIndex < vars.splits.Length)
        {
            if(settings[vars.splits[vars.splitIndex]])
            {
                print("[Squirm Autosplitter] Now tracking " + vars.splits[vars.splitIndex]);
            }
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
