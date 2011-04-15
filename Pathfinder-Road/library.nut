/*	RoadPathfinder v.6 r.79 [2011-04-15], originally part of 
 *	WmDOT v.4  r.50 [2011-04-06]
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/*	This file is licenced under the originl licnese - LGPL v2.1
 *		and is based on the NoAI Team's Road Pathfinder v3
 */
 
/* $Id: library.nut 15091 2009-01-15 15:56:10Z truebrain $ */

class Road extends AILibrary {
	function GetAuthor()      { return "W. Minchin"; }
	function GetName()        { return "Road - WM"; }
	function GetShortName()   { return "rPmW"; }	//	William's Road Pathfinder
	function GetDescription() { return "An implementation of a road pathfinder, edited by Minchinweb and based on the NoAI's Road Pathfinder v3. (v6 r79)"; }
	function GetVersion()     { return 6; }
	function GetDate()        { return "2011-04-15"; }
	function CreateInstance() { return "RoadWm"; }
	function GetCategory()    { return "Pathfinder"; }
//	function GetURL()		  { return "http://www.tt-forums.net/viewtopic.php?f=65&t=53698"; }
	function GetAPIVersion()  { return "1.0"; }
	function MinVersionToLoad() { return 6; }
}

RegisterLibrary(Road());
