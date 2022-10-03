state("Squirm") 
{
}

startup 
{
    vars.Unity = Assembly.Load(File.ReadAllBytes(@"Components\UnityASL.bin")).CreateInstance("UnityASL.Unity");
	vars.Unity.LoadSceneManager = true;
}

init 
{
    vars.Unity.TryOnLoad = (Func<dynamic, bool>)(helper =>
	{
		var srd = helper.GetClass("Assembly-CSharp", "Game");

		vars.Unity.Make<int>(srd.Static, srd["currentLevel"]).Name = "currentLevel";
		vars.Unity.Make<bool>(srd.Static, srd["beatLudo"]).Name = "beatLudo";
		vars.Unity.Make<bool>(srd.Static, srd["hasLudoKey"]).Name = "hasLudoKey";
		vars.Unity.Make<bool>(srd.Static, srd["hasGun"]).Name = "hasGun";

		return true;
	});

    vars.Unity.Load(game);
}

update
{	
    if (!vars.Unity.Loaded)
        return false;

    vars.Unity.Update();

    old.level = vars.Unity["currentLevel"].Old;
    current.level = vars.Unity["currentLevel"].Current;

    if(current.level != old.level)
    {
        print("CurrentLevel " + current.level);
    }

    old.gun = vars.Unity["hasGun"].Old;
    current.gun = vars.Unity["hasGun"].Current;
    
    if(current.gun != old.gun)
    {
        print("Has Gun " + current.gun);
    }

    old.ludo = vars.Unity["beatLudo"].Old;
    current.ludo = vars.Unity["beatLudo"].Current;
    
    if(current.ludo != old.ludo)
    {
        print("Beat Ludo " + current.ludo);
    }

    old.key = vars.Unity["hasLudoKey"].Old;
    current.key = vars.Unity["hasLudoKey"].Current;
    
    if(current.key != old.key)
    {
        print("Has Key " + current.key);
    }
}
