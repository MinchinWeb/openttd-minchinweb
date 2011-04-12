﻿/*	Town Registrar v.1, part of 
 *	WmDOT v.5  r.53d  [2011-04-09]
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
	function GetRevision()		{ return "53d"; }
	function GetDate()          { return "2011-04-09"; }
	function GetName()          { return "Town Registrar"; }
		
	_MaxAtlasSize = null;
	_PopLimit = null;
	_WorldSize = null;
	_ListOfNeighbourhoods = null;
	_LookUpList = null;		//	An array, where the index corresponds to the
							//		TownID and the value is the neighbourhood
							//		the town is in
	_NeighbourhoodCapitalToHQ = null;
	_ConnectionsTT = null;	//	town<>town connections
	_ConnectionsTN = null;	//	town<>neighbourhood connections
	_ConnectionsNN = null;	//	neighbourhood<>neighbourhood connections
							//		2D arrays. The index corresponds to the
							//			town (or neighbourhood) in question,
							//			and the array at that index is the
							//			connections out.
	
	_NextRun = null;
	_UpdateInterval = null;
	
	Log = null;
	
	constructor()
	{
		this._MaxAtlasSize = 50;
		this._NextRun = 0;
		this._UpdateInterval = 65000;	//	6500 is about a year
		//	TO-DO:
		//		- Lower this to 6500, but then _ConnectionsTN & _ConnectionsNN
		//			need to be remapped based on _ConnectionsTT 
		this._ListOfNeighbourhoods = [];
		this._LookUpList = [];
		this._NeighbourhoodCapitalToHQ = [];
		this._ConnectionsTT = [];
		this._ConnectionsTN = [];
		this._ConnectionsNN = [];
		
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
	this._ConnectionsTT.resize(this._WorldSize);
	this._ConnectionsTN.resize(this._WorldSize);
	this._ConnectionsNN.resize(this._ListOfNeighbourhoods.len());
	
	for  (local i = 0; i < this._WorldSize; i++) {
		this._ConnectionsTT[i] = [];
		this._ConnectionsTN[i] = [];
	}
	for  (local i = 0; i < this._ConnectionsNN.len(); i++) {
		this._ConnectionsNN[i] = [];
	}
	
	Log.Note(this._ListOfNeighbourhoods.len() + " neighbourhoods generated. Took " + (AIController.GetTick() - tick) + " ticks.",3);
	
	if (Log.Settings.DebugLevel >= 3) {
		for (local i = 0; i < this._ListOfNeighbourhoods.len(); i++) {
			this._ListOfNeighbourhoods[i].MarkOut(Log.Settings.DebugLevel);
		}
	}
	
	this._NextRun += this._UpdateInterval;
//	return null;
}

//	this._TownArray = Towns.GenerateTownList(this._Mode);
function TownRegistrar::GenerateTownList(Mode, HQTown)
{
//	Generates the town list for OpDOT
//
//	Modes 1 and 3 won't connect beyond the lower of a quarter of the map or 'speed'
//	Modes 2 and 4 are bound to the higher one
//	Mode 5 is not bound by distance

	local TownArray = [];
	
	switch (Mode) {
		case 1:
		case 2:
		//	In Mode 1 and 2, the town list corresponds to the neighbourhood where the
		//		HQ is located
		//	Mode 1 and 2 just connect towns to the capital
			return this._ListOfNeighbourhoods[this._LookUpList[HQTown]].GetTowns();
			break;
		case 3:
		case 4:
			if (this._NeighbourhoodCapitalToHQ == null) {
				GenerateCapitalToHQArray(HQTown);
			}
//			TownArray.push(HQTown);
			//	First add the Neighbourhood capitals that are close enough
			//		This should include HQTown
			for (local i = 0; i < this._NeighbourhoodCapitalToHQ.len(); i++) {
				if (this._NeighbourhoodCapitalToHQ[i] <= OpDOT.GetMaxDistance(Mode) ) {
					TownArray.push(this._ListOfNeighbourhoods[i].GetHighestPopulation() );
				}
			}
			//	If a neighbourhood has been connected to the capital, add the
			//		next unconnected town
/* 			local AlreadyAdded = [];
			AlreadyAdded.push(this._ConnectedNeighbourhoods[HQTown]);
			for (local i = 0; i < this._ConnectedNeighbourhoods.len(); i++) {
				if (ContainedIn1DArray(AlreadyAdded, this._ConnectedNeighbourhoods[i][0]) != true) {
					TownArray.push();
					AlreadyAdded.push(this._ConnectedNeighbourhoods[i][0]);
				}
				if (ContainedIn1DArray(AlreadyAdded, this._ConnectedNeighbourhoods[i][1]) != true) {
					TownArray.push();
					AlreadyAdded.push(this._ConnectedNeighbourhoods[i][1]);
				}
			} */
			
			//	If there are spaces left, fill them up with highest population towns on the map, with triple points to towns in the capital region
			
			//	OR if we're over the Atlas size, drop random towns
			
		case 5:
		case 6:
		default:
			return this._ListOfNeighbourhoods[this._LookUpList[HQTown]].GetTowns();
			break;
	}
}

function TownRegistrar::GenerateCapitalToHQArray(HQTown)
{
//	Generates an array that lists the distance from the capital of each
//		neighbourhood to the HQTown
	this._NeighbourhoodCapitalToHQ.resize(this._ListOfNeighbourhoods.len());
	for (local i = 0; i < this._ListOfNeighbourhoods.len(); i++) {
		this._NeighbourhoodCapitalToHQ[i] = AIMap.DistanceManhattan(AITown.GetLocation(HQTown),AITown.GetLocation(this._ListOfNeighbourhoods[i].GetHighestPopulation() ) );
	}
}

function TownRegistrar::RegisterConnection(TownA, TownB)
{
//	After building or finding a connection, the Town Registrar records it as a
//		town<>town, a town<>neighbourhood, and a neighbourhood<>neighbourhood
//		connection
	if (ContainedIn1DArray(this._ConnectionsTT[TownA], TownB) != true) {
		this._ConnectionsTT[TownA].push(TownB);
		this._ConnectionsTT[TownB].push(TownA);
		if (ContainedIn1DArray(this._ConnectionsTN[TownA], this._LookUpList[TownB]) != true) {
			this._ConnectionsTN[TownA].push(this._LookUpList[TownB]);
			if (ContainedIn1DArray(this._ConnectionsNN[this._LookUpList[TownA]], this._LookUpList[TownB]) != true) {
				this._ConnectionsNN[this._LookUpList[TownA]].push(this._LookUpList[TownB]);
				this._ConnectionsNN[this._LookUpList[TownB]].push(this._LookUpList[TownA]);
			}
		}
		if (ContainedIn1DArray(this._ConnectionsTN[TownB], this._LookUpList[TownA]) != true) {
			this._ConnectionsTN[TownB].push(this._LookUpList[TownA]);
		}
	}
}