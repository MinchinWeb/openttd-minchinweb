/*	Operation Hibernia v.1, r.178, [2011-12-31]
 *		part of WmDOT v.7
 *	Copyright © 2011-12 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/*	Operation Hibernia
 *		Hibernia refers to the oil field and production platform in the North
 *		Atlantic Ocean, about 300km ESE from St. John's, Newfoundland, Canada.
 *		Hibernia is the world's largest oil platform.
 *
 *		Operation Hibernia seeks out oil platforms, and then transports oil to
 *		Oil Refinaries.
 */
 
//	Requires MinchinWeb's MetaLibrary v.2

 class OpHibernia {
	function GetVersion()       { return 1; }
	function GetRevision()		{ return 178; }
	function GetDate()          { return "2011-12-31"; }
	function GetName()          { return "Operation Hibernia"; }
	
	
	_NextRun = null;
	_ROI = null;
	_Cost = null;
	
	Log = null;
	Money = null;
	Towns = null;
	CleanupCrew = null;
	
	constructor()
	{
		this._NextRun = 0;
		
		this.Settings = this.Settings(this);
		this.State = this.State(this);
		Log = OpLog();
		Money = OpMoney();
		Towns = TownRegistrar();
		CleanupCrew = OpCleanupCrew();
	}
}

class OpHibernia.Settings {

	_main = null;
	
	function _set(idx, val)
	{
		switch (idx) {
			case "SleepLength":			this._main._SleepLength = val; break;
			case "FloatOffset":			this._main._FloatOffset = val; break;
			case "PathFinderCycles":	this._main._PathFinderCycles = val; break;
			case "Mode":				this._main._Mode = val; break;
			case "HQTown":				this._main._HQTown = val; break;
			case "Atlas":				this._main._Atlas = val; break;
			case "TownArray":			this._main._TownArray = val; break;
			case "PairsToConnect":		this._main._PairsToConnect = val; break;
			case "ConnectedPairs":		this._main._ConnectedPairs = val; break;
			case "SomeoneElseConnected":	this._main._SomeoneElseConnected = val; break;
			case "DebugLevel":			this._main._DebugLevel = val; break;
			case "RoadType":			this._main._RoadType = val; break;
			default: throw("The index '" + idx + "' does not exist");
		}
		return val;
	}
		
	function _get(idx)
	{
		switch (idx) {
			case "SleepLength":			return this._main._SleepLength; break;
			case "FloatOffset":			return this._main._FloatOffset; break;
			case "PathFinderCycles":	return this._main._PathFinderCycles; break;
			case "Mode":				return this._main._Mode; break;
			case "HQTown":				return this._main._HQTown; break;
			case "Atlas":				return this._main._Atlas; break;
			case "TownArray":			return this._main._TownArray; break;
			case "PairsToConnect":		return this._main._PairsToConnect; break;
			case "ConnectedPairs":		return this._main._ConnectedPairs; break;
			case "SomeoneElseConnected":	return this._main._SomeoneElseConnected; break;
			case "DebugLevel":			return this._main._DebugLevel; break;
			case "RoadType":			return this._main._RoadType; break;
			default: throw("The index '" + idx + "' does not exist");
		}
	}
	
	constructor(main)
	{
		this._main = main;
	}
}
 
class OpHibernia.State {

	_main = null;
	
	function _get(idx)
	{
		switch (idx) {
			case "Mode":			return this._main._Mode; break;
			case "NextRun":			return this._main._NextRun; break;
			case "ROI":				return this._main._ROI; break;
			case "Cost":			return this._main._Cost; break;
			default: throw("The index '" + idx + "' does not exist");
		}
	}
	
	constructor(main)
	{
		this._main = main;
	}
}

function OpHibernia::LinkUp() 
{
	this.Log = WmDOT.Log;
	this.Money = WmDOT.Money;
//	ship manager...
	Log.Note(this.GetName() + " linked up!",3);
}
 
function OpHibernia::Run() {
//	Check that there is oil on the map; put to sleep if not

//	Sleep for three months after last OpHibernia run, or a month after the last
//		ship was added, or ignore if we have no debt

//	Get a list of Oil Rigs, and add those without our ships to the sources list;
//		Priority is the production level

//	Get a list of Oil Refinaries and add to the attraction list; Priority is
//		the goods production level

//	Apply Traffic Model, and select best pair

//	Get build location for dock at Oil Refinary

//	Run Waterbody Check to see if Oil Refinary dock and Oil Rig are connected

//	Run Ship Pathfinder, and build bouys

//	Build one ship on path, and turn over to Ship Route Manager




}