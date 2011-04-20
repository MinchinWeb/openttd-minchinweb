/*	Minchinweb's MetaLibrary v.1 r.108 [2011-04-20],  
 *	originally part of, WmDOT v.6
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */

class MinchinWeb extends AILibrary {
	function GetAuthor()      { return "W. Minchin"; }
	function GetName()        { return "MinchinWeb"; }
	function GetShortName()   { return "LMmW"; }	//	William's MetaLibrary
	function GetDescription() { return "Minchinweb's MetaLibrary containing a Road Pathfinder, a Ship Pathfinder, a 'Line Walker,' a 'Waterbody Check,' Array functions, an A* implimentation, and a Fibonacci Heap implementation. (v1, r108)"; }
	function GetVersion()     { return 1; }
	function GetDate()        { return "2011-04-20"; }
	function CreateInstance() { return "MinchinWeb"; }
	function GetCategory()    { return "Util"; }
//	function GetURL()		  { return "http://www.tt-forums.net/viewtopic.php?f=65&t=53698"; }
	function GetAPIVersion()  { return "1.1"; }
	function MinVersionToLoad() { return 1; }
}

RegisterLibrary(MinchinWeb());

//	requires AyStar v6
//	requires Fibonacci Heap v2
