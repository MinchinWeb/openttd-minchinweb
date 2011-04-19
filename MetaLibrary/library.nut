/*	Minchinweb's MetaLibrary v.1 r.104 [2011-04-19],  
 *	originally part of, WmDOT v.6
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */

class MetaLib extends AILibrary {
	function GetAuthor()      { return "W. Minchin"; }
	function GetName()        { return "MetaLib"; }
	function GetShortName()   { return "LMmW"; }	//	William's MetaLibrary
	function GetDescription() { return "Minchinweb's MetaLibrary containing a Road Pathfinder, a Ship Pathfinder, Array functions, an A* implimentation, and a Fibonacci Heap implementation. (v1, r104)"; }
	function GetVersion()     { return 1; }
	function GetDate()        { return "2011-04-19"; }
	function CreateInstance() { return "MetaLib"; }
	function GetCategory()    { return "Util"; }
//	function GetURL()		  { return "http://www.tt-forums.net/viewtopic.php?f=65&t=53698"; }
	function GetAPIVersion()  { return "1.1"; }
	function MinVersionToLoad() { return 1; }
}

RegisterLibrary(MetaLib());

//	requires AyStar v6
//	requires Fibonacci Heap v2
