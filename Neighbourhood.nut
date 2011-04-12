/*	Neighbourhood Class, v.1, part of
 *	Town Registrar v.1, part of 
 *	WmDOT v.5  r.53b  [2011-04-09]
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
class NeighbourhoodInfo {
	function GetVersion()       { return 1; }
	function GetRevision()		{ return "53b"; }
	function GetDate()          { return "2011-04-09"; }
	function GetName()          { return "Neighbourhood Library"; }
}

class Neighbourhood {
	_index = null;
	_townlist = null;	//	townlist needs to be an array
	_size = null;
	_FloatOffset = null;
	
	_Info = null;
	Log = null;
	
	constructor ()
	{
		this._size = 0;
		this._townlist = [];
		this._FloatOffset = 0.001;
		
		this._Info = NeighbourhoodInfo();
		this.Log = WmDOT.Log;
	}
	
	constructor (Index, Towns)
	{
		this._index = Index;
		this._townlist = Towns;
		this._size = this._townlist.len();
		this._FloatOffset = 0.001;
		
		this._Info = NeighbourhoodInfo();
		this.Log = WmDOT.Log;
	}
}

function Neighbourhood::GetSize()
{
	return this._size;
}

function Neighbourhood::SplitNeighbourhood()
{
	//	Spliting the Neighbourhood takes the exisitng neighbourhood, finds the
	//		two biggest towns, and then creates two neighbourhoods by spliting
	//		the old neighbourhood by drawing a line between the two capitals
	//	Returns 2 element array, containing to arrays of the town ID's that
	//		fall into the two neighbourhoods
	
	local CapitalA = this.GetHighestPopulation();
	local CapitalB = this.GetHighestPopulation([CapitalA]);
	Log.Note("New capitals are " + AITown.GetName(CapitalA) + " and " + AITown.GetName(CapitalB) + ".",4);
	local xA = AIMap.GetTileX(AITown.GetLocation(CapitalA));
	local yA = AIMap.GetTileY(AITown.GetLocation(CapitalA));
	local xB = AIMap.GetTileX(AITown.GetLocation(CapitalB));
	local yB = AIMap.GetTileY(AITown.GetLocation(CapitalB));
	local dx = xA - xB;
	local dy = yA - yB;
	local avex = (xA + xB) / 2;
	local avey = (yA + yB) / 2;
	
	//	Solve a linear system:  ƒ(x) = y = mx + b
	local m = (dx + this._FloatOffset) / (dy + this._FloatOffset);		// slope
		//	FloatOffset is to avoid divide by zero problems
//	local b = yA - m * xA;												// y-intercept
	
	//	But we actually want the line that is perpenticular to and bisects the
	//		line between the two towns
	m = -m;
	local b = avey - m * avex;
	
	local NA = [];
	local NB = [];
	
	local xtest, ytest, ydivide;
	
	for (local i = 0; i  < this._townlist.len(); i++) {
		xtest = AIMap.GetTileX(AITown.GetLocation(this._townlist[i]));
		ytest = AIMap.GetTileY(AITown.GetLocation(this._townlist[i]));
		ydivide = m * xtest + b;
		if (ytest < ydivide) {
			NA.push(this._townlist[i]);
		} else {
			NB.push(this._townlist[i]);
		}
	}
	
	Log.Note("NA is: " + ToSting1DArray(NA),4);
	Log.Note("NB is: " + ToSting1DArray(NB),4);
	
	
	return [NA,NB];
}



function Neighbourhood::GetHighestPopulation(IgnoreList = [-1])
{
//	Returns the town with the highest population
//	TownID's on the Ignore list will not be returned
	local HighPop = 0;
	local KeepIndex = -1;
	
	for (local i = 0; i  < this._townlist.len(); i++) {
		if ((ContainedIn1DArray(IgnoreList, this._townlist[i]) != true) && AITown.GetPopulation(this._townlist[i]) > HighPop) {
			KeepIndex = this._townlist[i];
			HighPop = AITown.GetPopulation(this._townlist[i]);
		}
	}
	
	return KeepIndex;
}


function Neighbourhood::UpdateTownList(NewTowns)
{
//	Bulk updates the town list (this completely replaces it! use with caution)
	this._townlist = NewTowns;
	this._size = this._townlist.len();
}