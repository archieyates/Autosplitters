// Squirm Autosplitter
// version 2.0
// Author: Reicha7 (www.archieyates.co.uk)
// Supported features
//	- Any%
//  - 100%
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

    settings.Add("ludo", false, "Split on Ludo kill");
    settings.SetToolTip("ludo", "Split on killing Ludo rather than on collecting their key (Any% only!)");

    settings.Add("skelord", false, "Split on Skelord Key");
    settings.SetToolTip("skelord", "Split on collecting Skelord's key rather than killing them (Any% only!)");

    settings.Add("fatty", false, "Split on Fatty kill");
    settings.SetToolTip("fatty", "Split on killing Fatty rather than on collecting his key (Any% only!)");
}

init 
{
    // Need an environment variable set up to point at the SQUIRM folder
	string logPath = Environment.GetEnvironmentVariable("squirm")+"\\Save\\Read-Only Save Progress.txt";
	vars.line = "";
    vars.fileStream = new FileStream(logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
	vars.reader = new StreamReader(vars.fileStream); 
	print("[Squirm Autosplitter] Opened log " + logPath);

    vars.startTracking = false;
    vars.currentLevel = -1;
    vars.previousLevel = -1;
}
 
exit
{
	print("[Squirm Autosplitter] game closed");
	vars.reader = null;
}

start
{
    vars.startTracking = false;
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

    var category = timer.Run.CategoryName.ToLower();
    bool any = category.Contains("any");
    bool hundred = category.Contains("100");

    // Don't start tracking unless we have entered the first level from the loading screen
    if(!vars.startTracking)
    {
        if(any || hundred)
        {
            // 2 is the first level and 0 is the Loading Screen
            if(vars.currentLevel == 2 && vars.previousLevel == 0)
            {
                print("[Squirm Autosplitter] " + vars.startTracking);
                vars.startTracking = true;
            }
            else
            {
                return true;
            }
        }
        else
        {
            print("[Squirm Autosplitter] " + vars.startTracking);
            vars.startTracking = true;
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

    var segment = timer.CurrentSplitIndex;
    var category = timer.Run.CategoryName.ToLower();

    bool any = category.Contains("any");
    bool hundred = category.Contains("100");
 
    string targetString = "";

    if(segment == 0)
    {
        if(any)
        {
            if (settings["ludo"])
            {
                targetString = "beatLudo" + vars.delimiter;
            }
            else
            {
                targetString = "hasLudoKey" + vars.delimiter;
            }   
        }
        else if (hundred)
        {
            targetString = "workStar" + vars.delimiter;
        }
        else
        {
            return false;
        }
    }
    else if(segment == 1)
    {
        if(any)
        {
            if(settings["skelord"])
            {
                targetString = "hasSkeleKey" + vars.delimiter;
            }
            else
            {
                targetString = "beatSkele" + vars.delimiter;
            }
        }
        else if (hundred)
        {
            targetString = "hasLudoKey" + vars.delimiter;
        }
        else
        {
            return false;
        }
    }
    else if (segment == 2)
    {
        if(any)
        {
            if(settings["skelord"])
            {
                targetString = "beatFatty" + vars.delimiter;
            }
            else
            {
                targetString = "hasFattyKey" + vars.delimiter;
            }
        }
        else if (hundred)
        {
            targetString = "spookStar" + vars.delimiter;
        }
        else
        {
            return false;
        }
    }
    else if(segment == 3)
    {
        if(any)
        {
            targetString = "mouseKey" + vars.delimiter;
        }
        else if (hundred)
        {
            targetString = "hasSkeleKey" + vars.delimiter;
        }
        else
        {
            return false;
        }
    }
    else if(segment == 4)
    {
        if(any)
        {
            targetString = "towerKey" + vars.delimiter;
        }
        else if (hundred)
        {
            targetString = "iceStar" + vars.delimiter;
        }
        else
        {
            return false;
        }
    }
    else if(segment == 5)
    {
        if(any)
        {
            targetString = "cloudKey" + vars.delimiter;
        }
        else if (hundred)
        {
            targetString = "hasFattyKey" + vars.delimiter;
        }
        else
        {
            return false;
        }
    }
    else if(segment == 6)
    {
        if(any)
        {
            if(vars.currentLevel == 160 && vars.previousLevel == 159)
            {
                return true;
            }
        }
        else if (hundred)
        {
            targetString = "castleStar" + vars.delimiter;
        }
        else
        {
           return false; 
        }
    }
    else if(segment == 7)
    {
        if(any)
        {
            if(vars.currentLevel == 162 && vars.previousLevel == 161)
            {
                return true;
            }
        }
        else if (hundred)
        {
            targetString = "mouseKey" + vars.delimiter;
        }
        else
        {
            return false;
        }
    }
    else if(segment == 8)
    {
        if (hundred)
        {
            targetString = "towerStar" + vars.delimiter;
        }
        else
        {
            return false;
        }
    }
    else if(segment == 9)
    {
        if (hundred)
        {
            targetString = "towerKey" + vars.delimiter;
        }
        else
        {
            return false;
        }
    }
    else if (segment == 10)
    {
       if (hundred)
        {
            targetString = "spaceStar" + vars.delimiter;
        }
        else
        {
            return false;
        }
    }
    else if(segment == 11)
    {
        if (hundred)
        {
            targetString = "cloudKey" + vars.delimiter;
        }
        else
        {
            return false;
        }
    }
    else if(segment == 12)
    {
        if (hundred)
        {
            if(vars.currentLevel == 160 && vars.previousLevel == 159)
            {
                return true;
            }
        }
        else
        {
            return false;
        }
    }

    int start = vars.line.IndexOf(targetString, 0) + targetString.Length;
    int end = vars.line.IndexOf(",", start);
    string result = vars.line.Substring(start, end - start);

    if(result == "true")
    {
        return true;
    }
        
    return false;
}
