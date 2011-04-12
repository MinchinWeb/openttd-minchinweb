/*	Town Registrar v.1, part of 
 *	WmDOT v.5  r.53c  [2011-04-09]
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/*	The Town Registrar
 *			Registrar - n. someone responsible for keeping records
 *		The Town Registrar keeps track of all things town related and is
 *		responsible to dividing the map into neighbourhoods, providing the town
 *		list to OpDOT, and recording connections make.
 *		No expenditures. No revenue stream.
 */
 
 class TownRegistrar {
	function GetVersion()       { return 1; }
	function GetRevision()		{ return "53c"; }
	function GetDate()          { return "2011-04-09"; }
	function GetName()          { return "Town Registrar"; }
		
	_MaxAtlasSize = null;
	_PopLimit = null;
	_WorldSize = null;
	_ListOfNeighbourhoods = null;
	_LookUpList = null;
	
	_NextRun = null;
	_UpdateInterval = null;
	
	Log = null;
	
	constructor()
	{
		this._MaxAtlasSize = 50;
		this._NextRun = 0;
		this._UpdateInterval = 6500;	//	6500 is about once a year
		this._ListOfNeighbourhoods = [];
		this._LookUpList = [];
		
		Log = OpLog();
		
		this.State = this.State(this);
	}
}

class TownRegistrar.State {

	_main = null;
	
	function _get(idx)
	{
		switch (idx) {
//			case "Mode":			return this._main._Mode; break;
			case "NextRun":			return this._main._NextRun; break;
//			case "ROI":				return this._main._ROI; break;
//			case "Cost":			return this._main._Cost; break;
			default: throw("The index '" + idx + "' does not exist");
		}
	}
	
	constructor(main)
	{
		this._main = main;
	}
}

function TownRegistrar::LinkUp() 
{
	this.Log = WmDOT.Log;
	this._PopLimit = WmDOT.GetSetting("OpDOT_MinTownSize");
	this._MaxAtlasSize = WmDOT.GetSetting("TownRegistrar_AtlasSize");
	Log.Note(this.GetName() + " linked up!",3);
}

function TownRegistrar::Run()
{
	local tick = AIController.GetTick();
	this._NextRun = tick;
	Log.Note("Town Registrar's office open at tick " + tick + " .",1);
	
	local ListOfTowns = AITownList();
	this._WorldSize = ListOfTowns.Count();
	ListOfTowns.Valuate(AITown.GetPopulation);
	ListOfTowns.KeepAboveValue(this._PopLimit);
	
	local WmTownArray = [];
	WmTownArray.resize(ListOfTowns.Count());
	local iTown = ListOfTowns.Begin();
	for(local i=0; i < ListOfTowns.Count(); i++) {
		WmTownArray[i]=iTown;
		iTown = ListOfTowns.Next();
	}
	
	_ListOfNeighbourhoods = [];
	_ListOfNeighbourhoods.push(Neighbourhood(0,WmTownArray));
	// If WorldSize < MaxAtlasSize, dump everyone in the same neighbourhood and be done with it
//	ListOfTowns.Valuate(AITown.GetTownID);
	local SplitMore = true;
	while (SplitMore == true) {
		SplitMore = false;
		for (local i = 0; i < this._ListOfNeighbourhoods.len(); i++) {
			if (this._ListOfNeighbourhoods[i].GetSize() > this._MaxAtlasSize) {
				Log.Note("Spliting neighbourhood " + i + "...",3);
				local Splinters = [2];
				Splinters = this._ListOfNeighbourhoods[i].SplitNeighbourhood();
				this._ListOfNeighbourhoods[i].UpdateTownList(Splinters[0]);
				this._ListOfNeighbourhoods.push(Neighbourhood(this._ListOfNeighbourhoods.len(), Splinters[1]));
				SplitMore = true;	//	Double check we've done everyone by taking another run
				i--;				//	Double check this neighbourhood
			}
		}
	}
	
	this._LookUpList = MapTownsToNeighbourhoods(this._WorldSize, this._ListOfNeighbourhoods);
	
	Log.Note(this._ListOfNeighbourhoods.len() + " neighbourhoods generated. Took " + (AIController.GetTick() - tick) + " ticks.",3);
	
	if (Log.Settings.DebugLevel >= 3) {
		for (local i = 0; i < this._ListOfNeighbourhoods.len(); i++) {
			this._ListOfNeighbourhoods[i].MarkOut(Log.Settings.DebugLevel);
		}
	}
	
	this._NextRun += this._UpdateInterval;
//	return null;
}
