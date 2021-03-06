﻿/*	MinchinWeb's MetaLibary v.2-GS, r.140 [2011-12-03],
 *		adapted from Minchinweb's MetaLibrary v.2 r.129 [2011-04-29],  
 *		originally part of, WmDOT v.7
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
class MinchinWeb extends GSLibrary {
	function GetAuthor()      { return "W. Minchin"; }
	function GetName()        { return "MinchinWeb-GS"; }
	function GetShortName()   { return "SGmW"; }
	function GetDescription() { return "Minchinweb's MetaLibrary (GameScript Edition) containing a Road Pathfinder, a 'Spiral Walker,' a 'Waterbody Check,' Array functions and some other random functions. (v.2-GS, r.140)"; }
	function GetVersion()     { return 2; }
	function GetDate()        { return "2011-12-03"; }
	function CreateInstance() { return "MinchinWeb"; }
	function GetCategory()    { return "Util"; }
//	function GetURL()		  { return "http://www.tt-forums.net/viewtopic.php?f=65&t=53698"; }
	function GetAPIVersion()  { return "1.1"; }
	function MinVersionToLoad() { return 1; }
}

RegisterLibrary(MinchinWeb());

//	requires AyStar v6
//	requires Fibonacci Heap v2
