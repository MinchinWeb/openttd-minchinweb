/*	ShipPathfinder v.1 r.90 [2011-04-16],
 *	part of Minchinweb's MetaLibrary v1, r90, [2011-04-16],
 *	originally part of WmDOT v.6
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/**
 * A Ship Pathfinder.
 */
 
class _MetaLib_ShipPathfinder_
{
	_heap_class = import("queue.fibonacci_heap", "", 2);
	_max_cost = null;              ///< The maximum cost for a route.
	_cost_tile = null;             ///< The cost for a single tile.
	_cost_turn = null;             ///< The cost that is added to _cost_tile if the direction changes.
	cost = null;                   ///< Used to change the costs.
	
	_first_run = null;
	_first_run2 = null;
	_waterbody_check = null;
	_points = null;					///< Used to store points considered by the pathfinder. Stored as TileIndexes
	_paths = null;					///< Used to store the paths the pathfinder is working with. Stored as indexes to _points
	_clearedpaths = null;			///< Used to store points pairs that have already been cleared (all water)
	_Hpaths = null;					///< Used to sort in-progess paths
	_Hfinishedpaths = null			///< Used to store finished paths
	_mypath = null;					///< Used to store the path after it's been found for Building functions
	_running = null;
	info = null;

	constructor()
	{
		this._max_cost = 10000000;
		this._cost_tile = 100;
		this._cost_turn = 100;
		
		this._points = [];
		this._paths = [];
		this._clearedpath = [];
		this._UnfinishedPaths = this._heap_class();
		this._FinishedPaths = this._heap_class();
		
		this._mypath = null;
		this._running = false;

		this.cost = this.Cost(this);
		this.info = this.Info(this);	
	}
	
	function InitializePath(source, goal) {
		this._points = [];
		this._paths = [];
		this._clearedpath = [];
		this._UnfinishedPaths = this._heap_class();
		this._FinishedPaths = this._heap_class();
		this._mypath = null;
		this._first_run = true;
		this._first_run2 = true;
		this._running = true;
		
		this._points.push(source);
		this._points.push(goal);
		this._paths.push([0,1]);
		this._UnfinishedPaths.Insert(0, _MetaLib_ShipPathfinder_._PathLength(0));
	}
	
	function FindPath(iterations);
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
	local j = 0;
	if (this._first_run == true) {
		if (this._first_run2 == true) {
			this.waterbody_check = 
			//	XX come back here!!
		}
		for (j; j < iterations; j++)
		
		if (SameWaterBody)
	
	}
	for (j; j < iterations; j++) {
		//	Pop the shortest path from the UnfinishedPath Heap
		local WorkingPath = this._UnfinishedPaths.Pop();	//	WorkingPath is the Index to the path in question
		//	Walk the path segment by segment until we hit land
		for (local i = 0; i < (this._paths[WorkingPath].len() - 1); i++) {
			if (Array.IsContained1D(this._clearedpath, [this._points[this._paths[WorkingPath][i]], this._points[this._paths[WorkingPath][i+1]]]) != true) {
				//	This means we haven't already cleared the path...
				local Land = LandHo(this._points[this._paths[WorkingPath][i]], this._points[this._paths[WorkingPath][i+1]]);
				if (Land[0] == -1) {
					//	All water
					this._clearedpath.push([this._points[this._paths[WorkingPath][i]], this._points[this._paths[WorkingPath][i+1]]]);
				} else {
				//	On hitting land, do the right angle split creating two copies
				//		of the path with a new midpoint
					local m = _MetaLib_Extras_.Perpendicular(_MetaLib_Extras_.Slope(this._points[this._paths[WorkingPath][i]], this._points[this._paths[WorkingPath][i+1]]));
					local MidPoint = _MetaLib_Extras_.MidPoint(Land[0], Land[1]);
					local NewPoint1 = WaterHo(MidPoint, m);
					local NewPoint2 = WaterHo(MidPoint, -m);
					local WPPoints = this._paths[WorkingPath];
					if (NewPoint1 != null) {
						WPPoints1 = _MetaLib_Extras_.Array.InsertValueAt(WPPoints, i+1, NewPoint1);
						//	With the new point, check both forward and back to see if the
						//		points both before and after the new midpoint to see if
						//		they can be removed from the path (iff the resulting
						//		segement would be only on the water)
						if ( ((i+3) < WPPoints1.len()) && (LandHo(this._points[WPPoints1[i+1]], this._points[WPPoints1[i+3]])[0] == -1) ) {
							WPPoints1 = _MetaLib_Extras_.Array.RemoveValueAt(WPPoints1, i+2);		
						}
						if ( ((i-1) > 0) && (LandHo(this._points[WPPoints1[i-1]], this._points[WPPoints1[i+1]])[0] == -1)) {
							WPPoints1 = _MetaLib_Extras_.Array.RemoveValueAt(WPPoints1, i);		
						}
						//	Put both paths back into the UnfinishedPath heap					
						this._paths[WorkingPath] = WPPoints1;
						this._UnfinishedPaths.Insert(WorkingPath, _MetaLib_ShipPathfinder_._PathLength(WorkingPath));
					}
					if (NewPoint2 != null) {
						local WPPoints2 = _MetaLib_Extras_.Array.InsertValueAt(WPPoints, i+1, NewPoint2);
						if ( ((i+3) < WPPoints2.len()) && (LandHo(this._points[WPPoints2[i+1]], this._points[WPPoints2[i+3]])[0] == -1) ) {
							WPPoints2 = _MetaLib_Extras_.Array.RemoveValueAt(WPPoints2, i+2);		
						}
						if ( ((i-1) > 0) && (LandHo(this._points[WPPoints1[i-1]], this._points[WPPoints1[i+1]])[0] == -1)) {
							WPPoints2 = _MetaLib_Extras_.Array.RemoveValueAt(WPPoints2, i);		
						}
						this._paths.push(WPPoints2);
						this._UnfinishedPaths.Insert(this._paths.len() - 1, _MetaLib_ShipPathfinder_._PathLength(this._paths.len() - 1));
					}
				i = this._paths[WorkingPath].len();	//	Exits us from the for... loop
				}
			} else if (i == (this._paths[WorkingPath].len() - 1)){
			//	If we don't hit land, add the path to the FinishedPaths heap
				this._FinishedPaths.Insert(WorkingPath, _MetaLib_ShipPathfinder_._PathLength(WorkingPath))
			}
		}		// END  for (local i = 0; i < (this._paths[WorkingPath].len() - 1); i++)
		
		if (this._UnfinishedPaths.Cout() == 0) {
			if (this._FinishedPaths.Count() !=0) {
				this._running = false;
				this._mypath = PathToTilesArray(this._FinishedPaths.Peek());
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
				if (_MetaLib_ShipPathfinder_._PathLength(this._FinishedPaths.Peek()) < _MetaLib_ShipPathfinder_._PathLength(this._UnfinishedPaths.Peek())) ) {
					this._running = false;
					this._mypath = PathToTilesArray(this._FinishedPaths.Peek());
					return this._mypath;
				}
			}
		}
	}
	return false;
}

function _MetaLib_ShipPathfinder_::_PathLength(PathIndex)
{
	local Length = 0;
	for (local i = 0; i < (this._paths[PathIndex].len() - 1); i++) {
		Length += _MetaLib_Extras_.DistanceShip(this._points[this.paths[PathIndex][i]], this._points[this.paths[PathIndex][i + 1]]);
	}
}

LandHo(this._points[this._paths[WorkingPath][i]], this._points[this._paths[WorkingPath][i+1]])

WaterHo(MidPoint, m)

PathToTilesArray