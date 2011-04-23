/*	ShipPathfinder v.1 r.109 [2011-04-23],
 *	part of Minchinweb's MetaLibrary v1, r109, [2011-04-23],
 *	originally part of WmDOT v.6
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/**
 * A Ship Pathfinder.
 */
 
//	TO-DO
//		- Inflections Point Check:
//				Run the pathfinder without WBC as long as the length of the
//					paths keep going up. Once the length starts going down, if
//					the length goes back up, either fail the pathfinder or
//					invoke WBC
 
class _MetaLib_ShipPathfinder_
{
	_heap_class = import("queue.fibonacci_heap", "", 2);
	_WBC_class = _MetaLib_WBC_;		///< Class used to check if the two points are within the same waterbody
	_max_cost = null;              ///< The maximum cost for a route.
	_cost_tile = null;             ///< The cost for a single tile.
	_cost_turn = null;             ///< The cost that is added to _cost_tile if the direction changes.
	cost = null;                   ///< Used to change the costs.
	
	_infinity = null;
	_first_run = null;
	_first_run2 = null;
	_waterbody_check = null;
	_points = null;					///< Used to store points considered by the pathfinder. Stored as TileIndexes
	_paths = null;					///< Used to store the paths the pathfinder is working with. Stored as indexes to _points
	_clearedpaths = null;			///< Used to store points pairs that have already been cleared (all water)
	_UnfinishedPaths = null;		///< Used to sort in-progess paths
	_FinishedPaths = null			///< Used to store finished paths
	_mypath = null;					///< Used to store the path after it's been found for Building functions
	_running = null;
	info = null;

	constructor()
	{
		this._max_cost = 10000;
		this._cost_tile = 1;
		this._cost_turn = 1;
		
//		this._infinity = 10000;		//	Seperate from Line Walker
		this._infinity = 10;	//	For Testing
		this._points = [];
		this._paths = [];
		this._clearedpaths = [];
		this._UnfinishedPaths = this._heap_class();
		this._FinishedPaths = this._heap_class();
		
		this._mypath = null;
		this._running = false;

		this.cost = this.Cost(this);
		this.info = this.Info(this);	
	}
	
	function InitializePath(source, goal) {
	//	Assumes only one source and goal tile...
		this._points = [];
		this._paths = [];
		this._clearedpaths = [];
		this._UnfinishedPaths = this._heap_class();
		this._FinishedPaths = this._heap_class();
		this._mypath = null;
		this._first_run = true;
		this._first_run2 = true;
		this._running = true;
		
		this._points.push(source[0]);
		this._points.push(goal[0]);
		this._paths.push([0,1]);
		this._UnfinishedPaths.Insert(0, _MetaLib_ShipPathfinder_._PathLength(0));
	}
	
	function FindPath(iterations);
}

class _MetaLib_ShipPathfinder_.Info
{
	_main = null;
	
	function GetVersion()       { return 1; }
	function GetMinorVersion()	{ return 0; }
	function GetRevision()		{ return 100; }
	function GetDate()          { return "2011-04-18"; }
	function GetName()          { return "Ship Pathfinder (Wm)"; }
	
	constructor(main)
	{
		this._main = main;
	}
}

class _MetaLib_ShipPathfinder_.Cost
{
	_main = null;

	function _set(idx, val)
	{
		if (this._main._running) throw("You are not allowed to change parameters of a running pathfinder.");

		switch (idx) {
			case "max_cost":          this._main._max_cost = val; break;
			case "tile":              this._main._cost_tile = val; break;
			case "turn":              this._main._cost_turn = val; break;
			default: throw("the index '" + idx + "' does not exist");
		}
		return val;
	}

	function _get(idx)
	{
		switch (idx) {
			case "max_cost":          return this._main._max_cost;
			case "tile":              return this._main._cost_tile;
			case "turn":              return this._main._cost_turn;
			default: throw("the index '" + idx + "' does not exist");
		}
	}

	constructor(main)
	{
		this._main = main;
	}
};

function _MetaLib_ShipPathfinder_::FindPath(iterations)
{
	if (this._first_run == true) {
		local WBC;
		if (this._first_run2 == true) {
			WBC = this._WBC_class();
			WBC.InitializePath([this._points[this._paths[0][0]]], [this._points[this._paths[0][1]]]);
			this._first_run2 = false;
		}
		local SameWaterBody = WBC.FindPath(iterations);
		if ((SameWaterBody == false) || (SameWaterBody == null)) {
			return SameWaterBody;
		} else {
			this._first_run = false;
		}
		if (iterations != -1) { return false; }
	}
	
	if (iterations == -1) {iterations = 10000}	// close enough to infinity but able to avoid infinite loops?
	for (local j = 0; j < iterations; j++) {
		AILog.Info("UnfinishedPaths count " + this._UnfinishedPaths.Count() + " : " + j + " : " + iterations);
		//	Pop the shortest path from the UnfinishedPath Heap
		local WorkingPath = this._UnfinishedPaths.Pop();	//	WorkingPath is the Index to the path in question
		AILog.Info("     UnfinishedPath count after Pop... " + this._UnfinishedPaths.Count());
		local ReturnWP = false;
		//	Walk the path segment by segment until we hit land
		for (local i = 0; i < (this._paths[WorkingPath].len() - 1); i++) {
			AILog.Info("Contained in test... " + i + " : " + (this._paths[WorkingPath].len() - 2) + " : " + _MetaLib_Array_.ToSting2D(this._clearedpaths) + " " + this._points[this._paths[WorkingPath][i]] + " " + this._points[this._paths[WorkingPath][i+1]] + " : " + _MetaLib_Array_.ContainedInPairs(this._clearedpaths, this._points[this._paths[WorkingPath][i]], this._points[this._paths[WorkingPath][i+1]]));
		
			if (_MetaLib_Array_.ContainedInPairs(this._clearedpaths, this._points[this._paths[WorkingPath][i]], this._points[this._paths[WorkingPath][i+1]]) != true) {
				//	This means we haven't already cleared the path...
				local Land = LandHo(this._points[this._paths[WorkingPath][i]], this._points[this._paths[WorkingPath][i+1]]);
				AILog.Info("Land : " + _MetaLib_Array_.ToSting1D(Land) + " : "+ _MetaLib_Array_.ToStingTiles1D(Land));
				if (Land[0] == -1) {
					//	All water
					this._clearedpaths.push([this._points[this._paths[WorkingPath][i]], this._points[this._paths[WorkingPath][i+1]]]);
					ReturnWP = true;
				} else {
					ReturnWP = false;
				//	On hitting land, do the right angle split creating two copies
				//		of the path with a new midpoint
					local m = _MetaLib_Extras_.Perpendicular(_MetaLib_Extras_.Slope(this._points[this._paths[WorkingPath][i]], this._points[this._paths[WorkingPath][i+1]], this._infinity));
					local MidPoint = _MetaLib_Extras_.MidPoint(Land[0], Land[1]);
					local NewPoint1 = WaterHo(MidPoint, m, false);
					local NewPoint2 = WaterHo(MidPoint, m, true);
					local WPPoints = this._paths[WorkingPath];
					if (NewPoint1 != null) {
						this._points.push(NewPoint1);
						local NewPoint1Index = this._points.len() - 1;
						AISign.BuildSign(NewPoint1, NewPoint1Index + "");
						local WPPoints1 = _MetaLib_Array_.InsertValueAt(WPPoints, i+1, NewPoint1Index);
						//	With the new point, check both forward and back to see if the
						//		points both before and after the new midpoint to see if
						//		they can be removed from the path (iff the resulting
						//		segement would be only on the water)
						if ( ((i+3) < WPPoints1.len()) && (LandHo(this._points[WPPoints1[i+1]], this._points[WPPoints1[i+3]])[0] == -1) ) {
							WPPoints1 = _MetaLib_Array_.RemoveValueAt(WPPoints1, i+2);		
						}
						if ( ((i-1) > 0) && (LandHo(this._points[WPPoints1[i-1]], this._points[WPPoints1[i+1]])[0] == -1)) {
							WPPoints1 = _MetaLib_Array_.RemoveValueAt(WPPoints1, i);		
						}
						//	Put both paths back into the UnfinishedPath heap					
						this._paths[WorkingPath] = WPPoints1;
						AILog.Info("     Inserting Path #" + WorkingPath + " : " +  _MetaLib_Array_.ToSting1D(this._paths[WorkingPath]) + " l=" + _PathLength(WorkingPath));
						this._UnfinishedPaths.Insert(WorkingPath, _PathLength(WorkingPath));
					}
					if (NewPoint2 != null) {
						this._points.push(NewPoint2);
						local NewPoint2Index = this._points.len() - 1;
						AISign.BuildSign(NewPoint2, NewPoint2Index + "");
						local WPPoints2 = _MetaLib_Array_.InsertValueAt(WPPoints, i+1, NewPoint2Index);
						if ( ((i+3) < WPPoints2.len()) && (LandHo(this._points[WPPoints2[i+1]], this._points[WPPoints2[i+3]])[0] == -1) ) {
							WPPoints2 = _MetaLib_Array_.RemoveValueAt(WPPoints2, i+2);		
						}
						if ( ((i-1) > 0) && (LandHo(this._points[WPPoints2[i-1]], this._points[WPPoints2[i+1]])[0] == -1)) {
							WPPoints2 = _MetaLib_Array_.RemoveValueAt(WPPoints2, i);		
						}
						this._paths.push(WPPoints2);
						AILog.Info("     Inserting Path #" + (this._paths.len() - 1) + " : " +  _MetaLib_Array_.ToSting1D(WPPoints2) + " l=" + _PathLength(this._paths.len() - 1));
						this._UnfinishedPaths.Insert(this._paths.len() - 1, _PathLength(this._paths.len() - 1));
					}
				}
				i = this._paths[WorkingPath].len();	//	Exits us from the for... loop
			} else if (i == (this._paths[WorkingPath].len() - 2)){
			//	If we don't hit land, add the path to the FinishedPaths heap
				AILog.Info("Inserting Finished Path " + WorkingPath + " l=" + _PathLength(WorkingPath));
				this._FinishedPaths.Insert(WorkingPath, _PathLength(WorkingPath));
			}	
		}		// END  for (local i = 0; i < (this._paths[WorkingPath].len() - 1); i++)
		
		if (ReturnWP == true) {
		//	If everything was water...
			AILog.Info("     Inserting Path #" + WorkingPath + " on ReturnWP  l=" + _PathLength(WorkingPath));
			this._UnfinishedPaths.Insert(WorkingPath, _PathLength(WorkingPath));
		}
		
		if (this._UnfinishedPaths.Count() == 0) {
			AILog.Info("Unfinsihed count " + this._UnfinishedPaths.Count() + " finished " + this._FinishedPaths.Count());
			if (this._FinishedPaths.Count() !=0) {
				this._running = false;
				this._mypath = _PathToTilesArray(this._FinishedPaths.Peek());
				AILog.Info("My Path is " + _MetaLib_Array_.ToSting1D(this._mypath));
				return this._mypath;
			} else {
				//	If the UnfinishedPath heap is empty, fail the pathfinder
				this._running = false;
				return null;
			}
		} else {
			if (this._FinishedPaths.Count() !=0) {
				//	If the Finished heap contains a path that is shorter than any of
				//		the unfinished paths, return the finished path
				if (this._PathLength(this._FinishedPaths.Peek()) < this._PathLength(this._UnfinishedPaths.Peek()))  {
					this._running = false;
					this._mypath = _PathToTilesArray(this._FinishedPaths.Peek());
					AILog.Info("My Path is " + _MetaLib_Array_.ToSting1D(this._mypath));
					return this._mypath;
				}
			}
		}
	}
	return false;
}

function _MetaLib_ShipPathfinder_::_PathLength(PathIndex)
{
	local Length = 0.0;
	for (local i = 0; i < (this._paths[PathIndex].len() - 1); i++) {
		Length += _MetaLib_Extras_.DistanceShip(this._points[this._paths[PathIndex][i]], this._points[this._paths[PathIndex][i + 1]]);
	}
	return Length;
}

function _MetaLib_ShipPathfinder_::LandHo(TileA, TileB) {
	AILog.Info("Running LandHo...");
	local LandA = 0;
	local LandB = 0;
	
	local Walker = _MetaLib_LW_();
	Walker.Start(TileA);
	Walker.End(TileB);
	local PrevTile = Walker.GetStart();
	local CurTile = Walker.Walk();
	while (!Walker.IsEnd() && (LandA == 0)) {
		if (AIMarine.AreWaterTilesConnected(PrevTile, CurTile) != true) {
			LandA = PrevTile	
		}
		PrevTile = CurTile;
		CurTile = Walker.Walk();
	}
	if (Walker.IsEnd()) {
	//	We're all water!
		return [-1,-1];
	}
	
	Walker.Reset();
	Walker.Start(TileB);
	Walker.End(TileA);
	PrevTile = Walker.GetStart();
	CurTile = Walker.Walk();
	
	while (!Walker.IsEnd() && (LandB == 0)) {
		if (AIMarine.AreWaterTilesConnected(PrevTile, CurTile) != true) {
			LandB = PrevTile	
		}
		PrevTile = CurTile;
		CurTile = Walker.Walk();
	}

	return [LandA, LandB];
}

function _MetaLib_ShipPathfinder_::WaterHo(StartTile, Slope, ThirdQuadrant = false)
{
//	Starts at a given tile and then walks out at the given slope until it hits water
	local Walker = _MetaLib_LW_();
	Walker.Start(StartTile);
	Walker.Slope(Slope, ThirdQuadrant);
	AILog.Info("    WaterHo! " + StartTile + " , m=" + Slope  + " 3rdQ " + ThirdQuadrant);
	local PrevTile = Walker.GetStart();
	local CurTile = Walker.Walk();
	while ((AIMarine.AreWaterTilesConnected(PrevTile, CurTile) != true) && (AIMap.DistanceManhattan(PrevTile, CurTile) == 1)) {
		PrevTile = CurTile;
		CurTile = Walker.Walk();
	}
	
	if (AIMarine.AreWaterTilesConnected(PrevTile, CurTile) == true) {
		AILog.Info("     WaterHo returning " + _MetaLib_Array_.ToStingTiles1D([CurTile]) );
		return CurTile;
	} else {
		return null;
	}
}

function _MetaLib_ShipPathfinder_::_PathToTilesArray(PathIndex)
{
//	turns a path into an index to tiles (just the start, end, and turning points)
	local Tiles = [];
	for (local i = 0; i < (this._paths[PathIndex].len()); i++) {
			Tiles.push(this._points[this._paths[PathIndex][i]]);
	} 
	AILog.Info("PathToTilesArray input " + _MetaLib_Array_.ToSting1D(this._paths[PathIndex]) );
	AILog.Info("     and output " + _MetaLib_Array_.ToSting1D(Tiles) );
	return Tiles;
}

function _MetaLib_ShipPathfinder_::GetPathLength()
{
//	Runs over the path to determine its length
	if (this._running) {
		AILog.Warning("You can't get the path length while there's a running pathfinder.");
		return false;
	}
	if (this._mypath == null) {
		AILog.Warning("You have tried to get the length of a 'null' path.");
		return false;
	}
	
	local Length = 0;
	for (local i = 0; i < (this._mypath.len() - 1); i++) {
		Length += _MetaLib_Extras_.DistanceShip(this._mypath[i], this._mypath[i + 1]);
	}
	
	return Length;
}

