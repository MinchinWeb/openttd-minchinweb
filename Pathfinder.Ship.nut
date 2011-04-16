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
	for (local i = 0; i < iterations; i++) {
		//	Pop the shortest path from the UnfinishedPath Heap
		local WorkingPath = this._paths[this._UnfinishedPaths.Pop()];
		//	Walk the path segment by segment until we hit land
		for (local i = 0; i < (this._paths[PathIndex].len() - 1); i++) {
			local Land = LandHo(this._points[WorkingPath[i]], this._points[WorkingPath[i+1]]);
			//	On hitting land, do the right angle split creating two copies
			//		of the path with a new midpoint
			if (Land[0] == -1) {
			
			//	With the new point, check both forward and back to see if the
			//		points both before and after the new midpoint to see if
			//		they can be removed from the path (iff the resulting
			//		segement would be only on the water)
			
			//	Put both paths back into the UnfinishedPath heap
			
			}
		}
		//	If we don't hit land, add the path to the FinishedPaths heap
	
		//	If the Finished heap contains a path that is shorter than any of
		//		the unfinished paths, return the finished path
		
		//	If the UnfinishedPath heap is empty, fail the pathfinder
	}
}

function _MetaLib_ShipPathfinder_::_PathLength(PathIndex)
{
	local Length = 0;
	for (local i = 0; i < (this._paths[PathIndex].len() - 1); i++) {
		Length += _MetaLib_Extras_.DistanceShip(this._points[this.paths[PathIndex][i]], this._points[this.paths[PathIndex][i + 1]]);
	}
}