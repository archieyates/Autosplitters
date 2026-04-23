// Doriano Autosplitter
// version 0.1.0
// Author: Reicha7 (www.archieyates.co.uk)
// Supported Features
//  - Split on Item collected
// Notes:
//  - Developed using asl-help (https://github.com/just-ero/asl-help/blob/main/lib/asl-help)

state("Doriano") 
{
}

startup 
{
  // Without this nothing will work
  Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
  vars.Helper.GameName = "Doriano"; 
}

init 
{
  vars.Items = 0;
  
  // Search the game for the memory addresses
  vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
   vars.Helper["Items"] = mono.MakeList<IntPtr>("GameManager", "currentGameManager", "collectedItems"); 
    
    return true; 
  });
 
}

update
{
  // For easy debug display using ASL Var Viewer
  vars.Items = vars.Helper["Items"].Current.Count;
}

split
{
  if(vars.Helper["Items"].Current.Count > vars.Helper["Items"].Old.Count)
  {
    return true;
  } 
}