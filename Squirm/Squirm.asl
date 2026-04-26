// Squirm Autosplitter
// version 4.7.0
// Author: Reicha7 (www.archieyates.co.uk)
// Link: https://github.com/archieyates/Autosplitters/tree/master/Squirm
// Supported Categories
//	- Any% (RTA & IGT) [Start|Split]
//  - 100% (RTA & IGT) [Start|Split]
//  - Surprise Party (RTA only) [Start|Split]
//  - DLC (RTA only) [Split]
// Notes:
//  - Only confirmed to be supported in Squirm version 3.x
//  - Developed using asl-help (https://github.com/just-ero/asl-help/blob/main/lib/asl-help)
//  - Credit to Medievil Autosplitter developers for inspiring some of the code layout for version 4.7 (https://github.com/SirDarcanos/MediEvil/tree/main/Auto-Splitters)

state("Squirm") 
{
}

startup 
{
  // Without this nothing will work
  Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
  vars.Helper.GameName = "Squirm";
  vars.Helper.LoadSceneManager = true;
  
  // Surprise party first and last levels
  vars.surprisePartyStart = 179;
  vars.surprisePartyEnd = 192;
 
  // Any% and 100% share a lot of variables so grouping them up
  settings.Add("main", true, "Any% and 100%");
  settings.SetToolTip("main", "Any% and 100% share a lot of variables");

  settings.Add("any", true, "Shared", "main");
  settings.SetToolTip("any", "These variables can be used in both Any% and 100% speedruns");

  settings.Add("100", false, "100%", "main");
  settings.SetToolTip("100", "These variables will only be needed for 100% speedruns");
  
  settings.Add("party", false, "Surprise Party");
  settings.SetToolTip("party", "Surprise Party Mode with support for each individual level");
  
  settings.Add("dlc", false, "DLC");
  settings.SetToolTip("dlc", "DLC mode with support for key points");

  // All the settings for the autosplitter
  vars.settingsData = new Dictionary<string, Tuple<string, string, bool>>
  {
    {"hasGun",Tuple.Create("Gun", "any", false)},
    {"beatLudo",Tuple.Create("Kill Ludo", "any", false)},
    {"hasLudoKey",Tuple.Create("Ludo Key", "any", true)},
    {"hasDubJump",Tuple.Create("Double Jump", "any", false)},
    {"reachedSkelord",Tuple.Create("Reached Skelord", "any", false)},
    {"beatSkele",Tuple.Create("Kill Skelord", "any", true)},
    {"hasSkeleKey",Tuple.Create("Skelord Key", "any", false)},
    {"reachedFatty",Tuple.Create("Reached Fatty", "any", false)},
    {"beatFatty",Tuple.Create("Beat Fatty", "any", false)},
    {"hasFattyKey",Tuple.Create("Fatty Key", "any", true)},
    {"lever1",Tuple.Create("Left Lever", "any", false)},
    {"lever3",Tuple.Create("Right Lever", "any", false)},
    {"lever2",Tuple.Create("Upper Lever", "any", false)},
    {"reachedBlocka",Tuple.Create("Reached Blocka", "any", false)},
    {"beatBlocka",Tuple.Create("Defeated Blocka", "any", false)},
    {"mouseKey",Tuple.Create("Castle Key", "any", true)},
    {"reachedJetpack",Tuple.Create("Reached Tower Jetpack", "any", false)},
    {"towerKey",Tuple.Create("Tower Key", "any", true)},
    {"killedSun",Tuple.Create("Killed Sun", "any", false)},
    {"reachedCotton",Tuple.Create("Reached Cotton", "any", false)},
    {"cloudKey",Tuple.Create("Cotton Key", "any", true)},
    {"openedChest",Tuple.Create("Inverse World Chest", "any", false)},
    {"inverseWorld",Tuple.Create("Reached Float", "any", true)},
    {"float",Tuple.Create("Fade out after Float Kill", "any", true)},
    {"workStar",Tuple.Create("Hub Star", "100", false)},
    {"spookStar",Tuple.Create("Spook Star", "100", false)},
    {"iceStar",Tuple.Create("Ice Star", "100", false)},
    {"castleStar",Tuple.Create("Castle Star", "100", false)},
    {"towerStar",Tuple.Create("Tower Star", "100", false)},
    {"spaceStar",Tuple.Create("Space Star", "100", false)},
    {"heart",Tuple.Create("Talk to Heart", "100", false)},
    {"nexus",Tuple.Create("Reach Nexus", "dlc", true)},
    {"rainbowSun",Tuple.Create("Reach Rainbow Sun", "dlc", false)},
    {"trueNexus",Tuple.Create("Reach True Nexus", "dlc", true)},
    {"trueNexusBoss",Tuple.Create("Reach God of Light", "dlc", true)},
    {"dlcStar",Tuple.Create("Nexus Star", "dlc", true)},
    {"present",Tuple.Create("Present", "party", true)}
  };
  
  // Level IDs for each of the Surprise Party Levels
  for (int i = vars.surprisePartyStart; i < vars.surprisePartyEnd; i++) 
  {
    string ID = "lv" + i;
    string display = "Level " + i;

    vars.settingsData.Add(ID,Tuple.Create(display, "party", false));
  }

  // Add all the settings data to the autosplitter settings
  foreach (var sv in vars.settingsData)
  {
    settings.Add(sv.Key, sv.Value.Item3, sv.Value.Item1, sv.Value.Item2);
  };
  
  settings.Add("debug", false, "Debug");
  settings.SetToolTip("debug", "Enable debug messages that be read with Windows DebugView");
}

init 
{
  // We use a cached list of splits based on user settings and then only check against ones we haven't reached
  vars.splits = new List<string>();
  vars.completedSplits = new HashSet<string>();
  
  // Scenes are the actual Unity Scenes which is a bit different from level Ids
  vars.activeScene = "None";
  vars.lastScene = "None";
  
  vars.checkScene = (Func<string, bool>)(scene =>
  {
    return vars.activeScene == scene && vars.lastScene != scene;
  });
  
  // Check if a split has already been completed and that we're tracking it (more for safety than need)  
  vars.checkSplit = (Func<string, bool>)(key => 
  {
    return ( vars.completedSplits.Add( key ) && settings[key] );
  });
  
  // Search the game for the memory addresses
  vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
    // Tracking level
    vars.Helper["Level"] = mono.Make<int>("Game", "currentLevel");
    vars.Helper["Level"].Current = -1;
    vars.Helper["Level"].Old = -1; 
    
    vars.checkLevel = (Func<int, bool>)(level =>
    {
      return vars.Helper["Level"].Current == level && vars.Helper["Level"].Old != level;
    });
    
    // Tracking Game Settings
    vars.Helper["hasGun"] = mono.Make<bool>("Game", "hasGun"); 
    vars.Helper["beatLudo"] = mono.Make<bool>("Game", "beatLudo");
    vars.Helper["hasLudoKey"] = mono.Make<bool>("Game", "hasLudoKey");
    vars.Helper["hasDubJump"] = mono.Make<bool>("Game", "hasDubJump");
    vars.Helper["beatSkele"] = mono.Make<bool>("Game", "beatSkele");
    vars.Helper["hasSkeleKey"] = mono.Make<bool>("Game", "hasSkeleKey");
    vars.Helper["beatFatty"] = mono.Make<bool>("Game", "beatFatty");
    vars.Helper["hasFattyKey"] = mono.Make<bool>("Game", "hasFattyKey");
    vars.Helper["lever1"] = mono.Make<bool>("Game", "lever1");
    vars.Helper["lever2"] = mono.Make<bool>("Game", "lever2");
    vars.Helper["lever3"] = mono.Make<bool>("Game", "lever3");
    vars.Helper["beatBlocka"] = mono.Make<bool>("Game", "beatBlocka");
    vars.Helper["mouseKey"] = mono.Make<bool>("Game", "mouseKey");
    vars.Helper["towerKey"] = mono.Make<bool>("Game", "towerKey");
    vars.Helper["killedSun"] = mono.Make<bool>("Game", "killedSun");
    vars.Helper["cloudKey"] = mono.Make<bool>("Game", "cloudKey");
    vars.Helper["openedChest"] = mono.Make<bool>("Game", "openedChest");
    vars.Helper["workStar"] = mono.Make<bool>("Game", "workStar");
    vars.Helper["spookStar"] = mono.Make<bool>("Game", "spookStar");
    vars.Helper["iceStar"] = mono.Make<bool>("Game", "iceStar");
    vars.Helper["castleStar"] = mono.Make<bool>("Game", "castleStar");
    vars.Helper["towerStar"] = mono.Make<bool>("Game", "towerStar");
    vars.Helper["spaceStar"] = mono.Make<bool>("Game", "spaceStar");
    vars.Helper["Cutscene"] = mono.Make<bool>("Game", "inCutscene");

    vars.checkFlag = (Func<string, bool>)(key =>
    {
      return vars.Helper[key].Current == true && vars.Helper[key].Old == false;
    });

    // Used to grab the accurate in-game time
    vars.Helper["IGT"] = mono.Make<float>("Game", "timePlayed");

    // All the unique split functions
    // Note: Surprise Party levels are not included here as they are handled a little differently in split
    vars.splitFuncs = new Dictionary<string, Func<bool>>
    {
      {"hasGun", new Func<bool>(() => vars.checkFlag("hasGun"))},
      {"beatLudo", new Func<bool>(() => vars.checkFlag("beatLudo"))}, 
      {"hasLudoKey", new Func<bool>(() => vars.checkFlag("hasLudoKey"))},
      {"hasDubJump", new Func<bool>(() => vars.checkFlag("hasDubJump"))},
      {"reachedSkelord", new Func<bool>(() => vars.checkLevel(35))},
      {"beatSkele", new Func<bool>(() => vars.checkFlag("beatSkele"))},
      {"hasSkeleKey", new Func<bool>(() => vars.checkFlag("hasSkeleKey"))},
      {"reachedFatty", new Func<bool>(() => vars.checkLevel(57))},
      {"beatFatty", new Func<bool>(() => vars.checkFlag("beatFatty"))},
      {"hasFattyKey", new Func<bool>(() => vars.checkFlag("hasFattyKey"))},
      {"lever1", new Func<bool>(() => vars.checkFlag("lever1"))},
      {"lever3", new Func<bool>(() => vars.checkFlag("lever3"))},
      {"lever2", new Func<bool>(() => vars.checkFlag("lever2"))},
      {"reachedBlocka", new Func<bool>(() => vars.checkLevel(76))},
      {"beatBlocka", new Func<bool>(() => vars.checkFlag("beatBlocka"))},
      {"mouseKey", new Func<bool>(() => vars.checkFlag("mouseKey"))},
      {"reachedJetpack", new Func<bool>(() => vars.checkLevel(92))},
      {"towerKey", new Func<bool>(() => vars.checkFlag("towerKey"))},
      {"killedSun", new Func<bool>(() => vars.checkFlag("killedSun"))},
      {"reachedCotton", new Func<bool>(() => vars.checkLevel(114))},
      {"cloudKey", new Func<bool>(() => vars.checkFlag("cloudKey"))},
      {"openedChest", new Func<bool>(() => vars.checkFlag("openedChest"))},
      {"inverseWorld", new Func<bool>(() => vars.checkLevel(160))},
      {"float", new Func<bool>(() => vars.checkLevel(162))},
      {"workStar", new Func<bool>(() => vars.checkFlag("workStar"))},
      {"spookStar", new Func<bool>(() => vars.checkFlag("spookStar"))},
      {"iceStar", new Func<bool>(() => vars.checkFlag("iceStar"))},
      {"castleStar", new Func<bool>(() => vars.checkFlag("castleStar"))},
      {"towerStar", new Func<bool>(() => vars.checkFlag("towerStar"))},
      {"spaceStar", new Func<bool>(() => vars.checkFlag("spaceStar"))},
      {"heart", new Func<bool>(() => vars.checkFlag("Cutscene") && vars.checkLevel(177))},
      {"nexus", new Func<bool>(() => vars.activeScene == "Rainbow Nexus 0")},
      {"rainbowSun", new Func<bool>(() => vars.activeScene == "Rainbow Nexus BOSS")},
      {"trueNexus", new Func<bool>(() => vars.activeScene == "Nexus Core 0")},
      {"trueNexusBoss", new Func<bool>(() => vars.activeScene == "Rainbow Nexus ACTUAL BOSS")},
      {"dlcStar", new Func<bool>(() => vars.checkFlag("Cutscene") && vars.activeScene == "Rainbow Nexus END")} ,
      {"present", new Func<bool>(() => vars.checkFlag("Cutscene") && vars.checkLevel(192))}  
   };

    return true;
	});
}

update
{
  vars.lastScene = vars.activeScene;
  vars.activeScene = vars.Helper.Scenes.Active.Name == null ? vars.activeScene : vars.Helper.Scenes.Active.Name;

  // Debugging
  if(settings["debug"])
  {
    if(vars.Helper["Level"].Current != vars.Helper["Level"].Old)
    {
      print("[Squirm Autosplitter] New Level: " + vars.Helper["Level"].Current + " Was: " + vars.Helper["Level"].Old);
    }

    if(vars.activeScene != vars.lastScene) 
    {
      print("[Squirm Autosplitter] New Scene: " + vars.activeScene + " Was: " + vars.lastScene);
    }
  }
}

start
{
  // Start when selecting the present (Surprise Party Only)
  if(settings["party"] && timer.CurrentTimingMethod == TimingMethod.RealTime) 
  {
   if(vars.Helper["Cutscene"].Current && vars.Helper["Cutscene"].Old != vars.Helper["Cutscene"].Current && vars.Helper["Level"].Current == 16)
   { 
      return true;
   }
  }
  
  // Start when the level and timer reset but also the previous level was valid (to prevent it triggering when booting the game)
  if(settings["main"])
  {
    if(vars.Helper["Level"].Current == 0 && vars.Helper["Level"].Old != -1 && vars.Helper["IGT"].Current == 0)
    { 
      return true;
    }
  }
}

onStart
{
  // Go through all selected split settings and cache them
  vars.splits.Clear();
  vars.completedSplits.Clear();
      
  foreach (var func in vars.splitFuncs)
  {
    if(settings[func.Key])
    {
      vars.splits.Add(func.Key);
      print("[Squirm Autosplitter] Added Split: " + func.Key);
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
  foreach (string split in vars.splits)
  {
    if( vars.splitFuncs[split]() && vars.checkSplit( split ) ) 
    {
      if(settings["debug"])
      {
        print("[Squirm Autosplitter] Split: " + split);
      }
      
      return true;
    }
  }

  // Surprise Party levels it made more sense to handle with a loop
  // than individual functions as it's all sequential level number checks
  if(settings["party"])
  {
    for (int i = vars.surprisePartyStart; i < vars.surprisePartyEnd; i++) 
    {
      string split = "lv" + i;
      if(vars.checkLevel(i+1) && vars.checkSplit( split ))
      {
        return true;
      }
    }
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
