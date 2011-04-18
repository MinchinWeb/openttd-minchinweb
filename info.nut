class WmShipPFTest extends AIInfo 
{
	function GetAuthor()        { return "William Minchin"; }
	function GetName()          { return "WmShipPFTest"; }
	function GetDescription()   { return "This AI is to test the Ship Pathfinder in MinchinWeb's MetaLibrary. r.100"; }
	function GetVersion()       { return 1; }
	function MinVersionToLoad() { return 1; }
	function GetDate()          { return "2011-04-18"; }
	function GetShortName()     { return "0ZmW"; }
	function CreateInstance()   { return "WmShipPFTest"; }
	function GetAPIVersion()    { return "1.0"; }

}

/* Tell the core we are an AI */
RegisterAI(WmShipPFTest());