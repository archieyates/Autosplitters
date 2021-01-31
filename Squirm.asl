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

    settings.Add("autostart", false, "Start Timer Automatically");

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
}

init 
{
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
    if(vars.currentLevel == 0 && settings["autostart"])
    {
        vars.splitIndex = 0;
        vars.startTracking = true;
        return true;
    }
}

update
{	
	if (vars.reader == null) return false;

    vars.fileStream.Seek(0, SeekOrigin.Begin);
    vars.reader.DiscardBufferedData();
    vars.line = vars.reader.ReadLine();


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

    if(vars.splitIndex >= vars.splits.Length)
    {
        return true;
    }

    if(settings[vars.splits[vars.splitIndex]])
    {
        return true;
    }
    else
    {
        vars.splitIndex++;

        if(vars.splitIndex < vars.splits.Length && settings[vars.splits[vars.splitIndex]])
        {
            print("Now tracking " + vars.splits[vars.splitIndex]);
        }
    }

}

split
{
    if(!vars.startTracking)
    {
        return false;
    }

    if(vars.splitIndex >= vars.splits.Length)
    {
        return false;
    }

    if(settings[vars.splits[vars.splitIndex]])
    {
        string targetString = vars.splits[vars.splitIndex] + vars.delimiter;
        int start = vars.line.IndexOf(targetString, 0) + targetString.Length;
        int end = vars.line.IndexOf(",", start);
        
        string result = vars.line.Substring(start, end - start);

        if(result == "true")
        {
            vars.splitIndex++;

            if(vars.splitIndex < vars.splits.Length && settings[vars.splits[vars.splitIndex]])
            {
                print("Now tracking " + vars.splits[vars.splitIndex]);
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
        vars.splitIndex++;

        if(vars.splitIndex < vars.splits.Length && settings[vars.splits[vars.splitIndex]])
        {
            print("Now tracking " + vars.splits[vars.splitIndex]);
        }

         return false;
    }
}
