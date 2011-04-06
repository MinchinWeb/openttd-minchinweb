class WmBasic extends AIInfo 
{
	function GetAuthor()        { return "William Minchin"; }
	function GetName()          { return "WmBasic"; }
	function GetDescription()   { return "An AI that doesn't do anything. r.1"; }
	function GetVersion()       { return 1; }
	function MinVersionToLoad() { return 1; }
	function GetDate()          { return "2011-02-09"; }
	function GetShortName()     { return "BASC"; }
	function CreateInstance()   { return "WmBasic"; }
	function GetAPIVersion()    { return "1.0"; }

}

/* Tell the core we are an AI */
RegisterAI(WmBasic());