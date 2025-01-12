// Loop-Loop DX Autosplitter
// version 0.1
// Author: Reicha7 (www.archieyates.co.uk)
// Supported Categories
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
    vars.Helper.LoadSceneManager = true;

    // We use a cached list of splits based on user settings and then only check against ones we haven't reached
    vars.Splits = new List<string>();

    settings.Add("adventure", true, "Adventure");
	settings.SetToolTip("adventure", "Variables for Adventure Mode");

    // Any% and 100% splits that we can directly look up in memory
    vars.TrackedSplitVariables = new Dictionary<string, Tuple<string, string, bool>> 
	{
        {"beatFirstLevel",Tuple.Create("Beat Red Zone", "adventure", true)},
        {"beatYellow",Tuple.Create("Beat Yellow Zone", "adventure", true)},
        {"beatGreen",Tuple.Create("Beat Green Zone", "adventure", true)},
        {"beatBlue",Tuple.Create("Beat Blue Zone", "adventure", true)},
        {"beatPurple",Tuple.Create("Beat Purple Zone", "adventure", true)},
        {"beatWhite",Tuple.Create("Beat White Zone", "adventure", true)},
        {"beatFinalBoss",Tuple.Create("Defeated Warden", "adventure", true)},
        {"atWardenLevel",Tuple.Create("Defeated Warden", "adventure", true)},
        {"atFinalBossFinalForm",Tuple.Create("Defeated Warden", "adventure", true)},
        {"hitByFinalBoss",Tuple.Create("Defeated Warden", "adventure", true)},
        {"sawGoodEnding",Tuple.Create("Defeated Warden", "adventure", true)},
    };

    foreach (var sv in vars.TrackedSplitVariables)
    {
        settings.Add(sv.Key, sv.Value.Item3, sv.Value.Item1, sv.Value.Item2);
    };
}

init 
{
    // TODO: Get Game Manager from Game for lots more stuff
    // GameManager->level
    // GameManager->themeNum
    // GameManager->levelToLoadOnDie
    // GameManager->GameMode


    // Search the game for the memory addresses
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
        // Tracking game complete
        vars.Helper["BeatGame"] = mono.Make<bool>("Game", "beatGame");


        vars.Helper["level"] = mono.Make<int>("Game", "manager", "level");
        //vars.Helper["themeNum"] = mono.Make<int>("Game", "themeNum");
        //vars.Helper["levelToLoadOnDie"] = mono.Make<int>("Game", "levelToLoadOnDie");

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
    foreach (var sv in vars.TrackedSplitVariables)
    {
         if(vars.Helper[sv.Key].Old != vars.Helper[sv.Key].Current)
         {
            print("[Loop Loop] Variable " + sv.Key + " changed to " + vars.Helper[sv.Key].Current);
         }
    }

    if(current.level != old.level)
    {
         print("[Loop Loop] New Level: "+current.Level);
    }
    // if(current.themeNum != old.themeNum)
    // {
    //      print("[Loop Loop] New Theme: "+current.themeNum);
    // }
    // if(current.levelToLoadOnDie != old.levelToLoadOnDie)
    // {
    //      print("[Loop Loop] New Level to Load on Die: "+current.levelToLoadOnDie);
    // }

    current.activeScene = vars.Helper.Scenes.Active.Name == null ? current.activeScene : vars.Helper.Scenes.Active.Name;

    if(current.activeScene != old.activeScene) 
    {
        print("[Loop Loop] Scene change Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
    }
}