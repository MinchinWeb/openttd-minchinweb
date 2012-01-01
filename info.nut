class WmBasic extends AIInfo 
{
	function GetAuthor()        { return "William Minchin"; }
	function GetName()          { return "WmBasic"; }
	function GetDescription()   { return "An AI to test MetaLib's Atlas. r.1"; }
	function GetVersion()       { return 2; }
	function MinVersionToLoad() { return 1; }
	function GetDate()          { return "2011-05-01"; }
	function GetShortName()     { return "BASC"; }
	function CreateInstance()   { return "WmBasic"; }
	function GetAPIVersion()    { return "1.1"; }

}

/* Tell the core we are an AI */
RegisterAI(WmBasic());