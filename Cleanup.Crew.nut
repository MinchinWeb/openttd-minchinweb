/*	Cleanup Crew v.1, part of 
 *	WmDOT v.6  r.116 [2011-04-28]
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/*	Cleanup Crew
 *		The Cleanup Crew is a sort of 'unbuilder.' Operation DOT, particularly
 *		in Mode 6, has a tendency to make a mess of the map by building roads
 *		every which way. Cleanup Crew fixes that being fed a list of tile pair
 *		connections that are built and being provided the 'Golden Path' (the
 *		last, and assumedly best, path built). Road tile pairs that were built
 *		but are not part of the 'Golden Path' are then 'unbuild' (deleted).
 */ 
 
//	Requires
//		Queue.Fibonacci_Heap v.2

class OpCleanupCrew {
	function GetVersion()       { return 1; }
	function GetRevision()		{ return 116; }
	function GetDate()          { return "2011-04-28"; }
	function GetName()          { return "Cleanup Crew"; }

	_heap_class = import("Queue.Fibonacci_Heap", "", 2);
	_built_tiles = null;
	_golden_path = null;
	_heap = null;
	_next_run = null;
	_road_type = null;
	
	Money = null;
	Log = null;
	
	State = null;
	
	constructor() {
		this._money = OpMoney();
		this.Log = OpLog();
		this.State = this.State(this);
		this._heap = this._heap_class();
		this._next_run = 10000;
		this._road_type = AIRoad.ROADTYPE_ROAD;
	}

}

class OpCleanupCrew.State {

	_main = null;
	
	function _get(idx)
	{
		switch (idx) {
//			case "Mode":			return this._main._Mode; break;
			case "NextRun":			return this._main._next_run; break;
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

function OpCleanupCrew::LinkUp() 
{
	this.Log = WmDOT.Log;
	this.Money = WmDOT.Money;
	Log.Note(this.GetName() + " linked up!",3);
}

function OpCleanupCrew::Reset()
{
//	Clears the internal heap and the Golden Path
//	Can be invoked externally, but is invoked internally at the end of Run()
	this._built_tiles = null;
	this._golden_path = null;
	this._heap = null;
	this._heap = this._heap_class();
	this._next_run = AIController.GetTick() + 10000;
}


function OpCleanupCrew::AcceptBuiltTiles(TilePairArray)
{
//	Takes in a Array of Tile Pairs and adds them to an internal heap to be
//		dealt with later
//	TO-DO: Add an error check on the supplied array
	
//	Note: Tiles are added with a random priority. This is so that they get
//		pulled off the map in a 'random' order, which I thought would look cool :)

	for (local i = 0; i < TilePairArray.len(); i++ ) {
		this._heap.Insert(TilePairArray[i], AIBase.Rand() );
	}
}

function OpCleanupCrew::AcceptGoldenPath(TilePairArray)
{
//	Takes in an Array of Tile Pairs that represents the 'Golden Path' or
//		perfect routing. Tile Pairs appearing on this list will not be un-built
//	TO-DO: Add an error check on the supplied array

	this._golden_path = TilePairArray();
	return this._golden_path;
}

function OpCleanupCrew::SetToRun()
{
//	Involved OpDOT to have Cleanup Crew run on the next pass in the main loop

//	Note:	This is set to run at the current moment. However, the main loop
//			compares run times to the time when the loop started. Therefore,
//			put CleanupCrew above OpDOT in the loop lists to be sure that
//			CleanupCrew runs before OpDOT does again.

	this._next_run = AIController.GetTick();
	return this._next_run();
}

function OpCleanupCrew::Run()
{
//	This is where the real action is!
	local tick = AIController.GetTick();
	if (this._golden_path == null) {
		Log.Note("Cleanup Crew: At tick " + ".",1);
		Log.Note("          There has been no 'Golden Path' set so, yum, yeah...we're still unemployed...", 1);
		return;
	}
	
	Log.Note("Cleanup Crew is employed at tick " + tick + ".",1);
	
	//	Funds Request
//	Money.FundsRequest()
	
	AIRoad.SetCurrentRoadType(this._road_type);
	local TestPair;
	local i = 0;
	while (this._heap.Count() > 0) {
		TestPair = this._heap.Pop();
		if (!Array.ContainedInPairs(this._golden_path, TestPair[0], TestPair[1])) {
			Money.GreaseMoney((AIRoad.GetBuildCost(this._road_type, BT_ROAD) * 2.5).tointeger() );
			AIRoad.RemoveRoad(TestPair[0], TestPair[1]);
			i++;			
		}
	}

	this.Reset();
	
	Log.Note("Cleanup Crew's work is complete at tick " + (AIController.GetTick() - tick) + ", " + i + " tiles removed.", 2);
}

function OpCleanupCrew::SetRoadType(ARoadType)
{
//	Changes the road type Cleanup Crew is operating in
//	TO-DO: Add an error check on the supplied value

	this._road_type = ARoadType;
	return this._road_type;
}