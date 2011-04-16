/*	WmArray v.1  r.1
 *	Copyright © 2011 by William Minchin. For more info,
 *		please visit http://code.google.com/p/openttd-noai-wmdot/
 */

class WmArray extends AILibrary {
	function GetAuthor()      { return "William Minchin"; }
	function GetName()        { return "William's Array Library"; }
	function GetShortName()   { return "WMAR"; }
	function GetDescription() { return "A library containing basic functions for 1-, 2-, and 3-D arrays. r.1"; }
	function GetVersion()     { return 1; }
	function GetDate()        { return "2011-02-13"; }
	function CreateInstance() { return "WmArray"; }
//	function GetCategory()    { return "Pathfinder"; }
}

RegisterLibrary(WmArray());
