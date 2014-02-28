class WmShipPFTest extends AIInfo 
{
	function GetAuthor()        { return "William Minchin"; }
	function GetName()          { return "WmShipPFTest"; }
	function GetDescription()   { return "This AI is to test the Ship Pathfinder in MinchinWeb's MetaLibrary. 2014-02-14"; }
	function GetVersion()       { return 3; }
	function MinVersionToLoad() { return 1; }
	function GetDate()          { return "2014-02-14"; }
	function GetShortName()     { return "0ZmW"; }
	function CreateInstance()   { return "WmShipPFTest"; }
	function GetAPIVersion()    { return "1.3"; }
	
	function GetSettings() {
		AddSetting({name = "Debug_Level", description = "Debug Level ", min_value = 0, max_value = 8, easy_value = 7, medium_value = 7, hard_value = 7, custom_value = 7, flags = CONFIG_INGAME});
	}
}

/* Tell the core we are an AI */
RegisterAI(WmShipPFTest());

