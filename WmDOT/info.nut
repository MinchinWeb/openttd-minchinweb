﻿/*	WmDOT v.5  r.53a  [2011-04-08]
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */

class WmDOT extends AIInfo 
{
	function GetAuthor()        { return "W. Minchin"; }
	function GetName()          { return "WmDOT"; }
	function GetDescription()   { return "An AI that doesn't compete with you but rather builds out the highway network. We're still looking for a revenue stream. v.4 (r.53a)"; }
	function GetVersion()       { return 5; }
	function MinVersionToLoad() { return 1; }
	function GetDate()          { return "2011-04-08"; }
	function GetShortName()     { return "}}mW"; }	//	0x576D7D7D
	function CreateInstance()   { return "WmDOT"; }
	function GetAPIVersion()    { return "1.0"; }
	function UseAsRandomAI()	{ return false; }
	function GetURL()			{ return "http://www.tt-forums.net/viewtopic.php?f=65&t=53698"; }
//	function GetURL()			{ return "http://code.google.com/p/openttd-noai-wmdot/issues/"; }
	function GetEmail()			{ return "w_minchin@hotmail.com"}

	function GetSettings() {
		AddSetting({name = "DOT_name1", description = "DOT State (first letter)      ", min_value = 0, max_value = 26, easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = 0});
		AddLabels("DOT_name1", {_0 = "Default", _1 = "A", _2 = "B", _3 = "C", _4 = "D", _5 = "E", _6 = "F", _7 = "G", _8 = "H", _9 = "I", _10 = "J", _11 = "K", _12 = "L", _13 = "M", _14 = "N", _15 = "O", _16 = "P", _17 = "Q", _18 = "R", _19 = "S", _20 = "T", _21 = "U", _22 = "V", _23 = "W", _24 = "X", _25 = "Y", _26 = "Z"});
		AddSetting({name = "DOT_name2", description = "DOT State (second letter) ", min_value = 0, max_value = 26, easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = 0});
		AddLabels("DOT_name2", {_0 = "none", _1 = "A", _2 = "B", _3 = "C", _4 = "D", _5 = "E", _6 = "F", _7 = "G", _8 = "H", _9 = "I", _10 = "J", _11 = "K", _12 = "L", _13 = "M", _14 = "N", _15 = "O", _16 = "P", _17 = "Q", _18 = "R", _19 = "S", _20 = "T", _21 = "U", _22 = "V", _23 = "W", _24 = "X", _25 = "Y", _26 = "Z"});
		AddSetting({name = "Debug_Level", description = "Debug Level ", min_value = 0, max_value = 4, easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = AICONFIG_INGAME});
		AddSetting({name = "OpDOT", description = "--  Operation DOT  --  is a ", easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1, min_value = 0, max_value = 1, flags = 0});
		AddLabels("OpDOT", {_0 = "no go ----------------------- :,-(", _1 = "GO!  ------------------------ :-)"});
		AddSetting({name = "OpDOT_MinTownSize", description = "     The minimal size of towns to connect", min_value = 0, max_value = 10000, easy_value = 100, medium_value = 500, hard_value = 1000, custom_value = 300, flags = AICONFIG_INGAME, step_size=50});
//		AddSetting({name = "Grid_Spacing", description = "Grid Spacing", min_value = 6, max_value = 30, easy_value = 14, medium_value = 14, hard_value = 14, custom_value = 12, step_size=2, flags = 0});
//		AddLabels("Grid_Spacing", {_12 = "12 (default)", _14 = "14 (min. for full-sized airports)"});
//		AddSetting({name = "Hwy_Prefix", description = "Highway Prefix", min_value = 0, max_value = 4, easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = 0});
//		AddLabels("Hwy_Prefix", {_0 = "Match DOT name", _1 = "Hwy", _2 = "I-", _3 = "US", _4 = "RN"});
		AddSetting({name = "info0", description = "----------------------------------------------------- ", min_value = 0, max_value = 1, easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = 0});
		AddLabels("info0", {_0 = "", _1 = ""});
		AddSetting({name = "info1", description = "     For more information on WmDOT and its settings, visit                ", min_value = 0, max_value = 1, easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = 0});
		AddLabels("info1", {_0 = "", _1 = ""});
		AddSetting({name = "info2", description = "                http://www.tt-forums.net/viewtopic.php?f=65&t=53698  ", min_value = 0, max_value = 1, easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0, flags = 0});
		AddLabels("info2", {_0 = "", _1 = ""});
	}
}

/* Tell the core we are an AI */
RegisterAI(WmDOT());