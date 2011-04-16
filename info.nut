class WmShipPFTest extends AIInfo 
{
	function GetAuthor()        { return "William Minchin"; }
	function GetName()          { return "WmShipPFTest"; }
	function GetDescription()   { return "This AI is to test the Ship Pathfinder in MinchinWeb's MetaLibrary. r.94"; }
	function GetVersion()       { return 1; }
	function MinVersionToLoad() { return 1; }
	function GetDate()          { return "2011-02-09"; }
	function GetShortName()     { return "ZZZZ"; }
	function CreateInstance()   { return "WmShipPFTest"; }
	function GetAPIVersion()    { return "1.1"; }

}

/* Tell the core we are an AI */
RegisterAI(WmShipPFTest());