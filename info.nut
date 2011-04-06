class WmTest extends AIInfo 
{
	function GetAuthor()        { return "William Minchin"; }
	function GetName()          { return "WmTest"; }
	function GetDescription()   { return "Test Wayfinding. r.1"; }
	function GetVersion()       { return 1; }
	function MinVersionToLoad() { return 1; }
	function GetDate()          { return "2011-02-18"; }
	function GetShortName()     { return "TEST"; }
	function CreateInstance()   { return "WmTest"; }
	function GetAPIVersion()    { return "1.0"; }

	function GetSettings() {
		AddSetting({name = "Grid_Spacing", description = "Grid Spacing", min_value = 2, max_value = 64, easy_value = 12, medium_value = 12, hard_value = 12, custom_value = 12, step_size=2, flags = AICONFIG_INGAME});
		AddSetting({name = "Test_Cycles", description = "Test Cycles", min_value = 1, max_value = 100, easy_value = 10, medium_value = 10, hard_value = 10, custom_value = 10, step_size=5, flags = AICONFIG_INGAME});
	}
	
}

/* Tell the core we are an AI */
RegisterAI(WmTest());