state("Squirm") 
{
}

startup 
{
    vars.Unity = Assembly.Load(File.ReadAllBytes(@"Components\UnityASL.bin")).CreateInstance("UnityASL.Unity");
	vars.Unity.LoadSceneManager = true;

    vars.splits = new List<string>();

    settings.Add("main", true, "Any% and 100%");

    vars.SplitVariables = new Dictionary<string, Tuple<string, bool>> 
	{
        {"workStar",Tuple.Create("Hub Star", true)},
        {"beatLudo",Tuple.Create("Kill Ludo", false)},
        {"hasLudoKey",Tuple.Create("Ludo Key", true)},
        {"spookStar",Tuple.Create("Spook Star", true)},
        {"beatSkele",Tuple.Create("Kill Skelord", true)},
        {"hasSkeleKey",Tuple.Create("Skelord Key", false)},
        {"iceStar",Tuple.Create("Ice Star", true)},
        {"beatFatty",Tuple.Create("Beat Fatty", false)},
        {"hasFattyKey",Tuple.Create("Fatty Key", true)},
        {"castleStar",Tuple.Create("Castle Star", false)},
        {"mouseKey",Tuple.Create("Castle Key", true)},
        {"towerStar",Tuple.Create("Tower Star", true)},
        {"towerKey",Tuple.Create("Tower Key", true)},
        {"spaceStar",Tuple.Create("Space Star", true)},
        {"cloudKey",Tuple.Create("Cotton Key", true)},
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
    vars.Unity.TryOnLoad = (Func<dynamic, bool>)(helper =>
	{
		var srd = helper.GetClass("Assembly-CSharp", "Game");

		vars.Unity.Make<int>(srd.Static, srd["currentLevel"]).Name = "currentLevel";

		vars.Unity.Make<bool>(srd.Static, srd["workStar"]).Name = "workStar";
		vars.Unity.Make<bool>(srd.Static, srd["beatLudo"]).Name = "beatLudo";
		vars.Unity.Make<bool>(srd.Static, srd["hasLudoKey"]).Name = "hasLudoKey";
		vars.Unity.Make<bool>(srd.Static, srd["spookStar"]).Name = "spookStar";
		vars.Unity.Make<bool>(srd.Static, srd["beatSkele"]).Name = "beatSkele";
		vars.Unity.Make<bool>(srd.Static, srd["hasSkeleKey"]).Name = "hasSkeleKey";
		vars.Unity.Make<bool>(srd.Static, srd["iceStar"]).Name = "iceStar";
		vars.Unity.Make<bool>(srd.Static, srd["beatFatty"]).Name = "beatFatty";
		vars.Unity.Make<bool>(srd.Static, srd["hasFattyKey"]).Name = "hasFattyKey";
		vars.Unity.Make<bool>(srd.Static, srd["castleStar"]).Name = "castleStar";
		vars.Unity.Make<bool>(srd.Static, srd["mouseKey"]).Name = "mouseKey";
		vars.Unity.Make<bool>(srd.Static, srd["towerStar"]).Name = "towerStar";
		vars.Unity.Make<bool>(srd.Static, srd["towerKey"]).Name = "towerKey";
		vars.Unity.Make<bool>(srd.Static, srd["spaceStar"]).Name = "spaceStar";
		vars.Unity.Make<bool>(srd.Static, srd["cloudKey"]).Name = "cloudKey";

		return true;
	});

    vars.Unity.Load(game);
}

update
{	
    if (!vars.Unity.Loaded)
        return false;

    vars.Unity.Update();

    if(vars.Unity["currentLevel"].Current != vars.Unity["currentLevel"].Old)
    {
        print("CurrentLevel " + vars.Unity["currentLevel"].Current);
    }
}

start
{
     if(vars.Unity["currentLevel"].Current == 0 && vars.Unity["currentLevel"].Old != vars.Unity["currentLevel"].Current)
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

split
{
    int index = 0;
    bool splitThisFrame = false;
    foreach (string split in vars.splits)
    {
        switch(split) 
        {
        case "inverseWorld":
            // code block
            break;
        case "float":
            // code block
            break;
        default:
            if(vars.Unity[split].Current && vars.Unity[split].Current != vars.Unity[split].Old)
            {

            }
            break;
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
