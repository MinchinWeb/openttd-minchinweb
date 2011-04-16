/*	Waterbody Check v.1 r.90 [2011-04-16],
 *	part of Minchinweb's MetaLibrary v1, r90, [2011-04-16],
 *	originally part of WmDOT v.6
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */

/*	Waterbody check is in effect a specialized pathfinder. It serves to check
 *		whether two points are in the same waterbody (i.e. a ship could travel
 *		between them). It is optimized to run extremely fast (I hope!). It can
 *		be called seperately, but was originally designed as a pre-run check
 *		for my Ship Pathfinder (also included in this MetaLibrary).
 *
 *	It is based on the NoAI Team's Road Pathfinder v3.
 */
 
class _MetaLib_WaterBody_Check_
{
	_aystar_class = import("graph.aystar", "", 6);
	_max_tiles = null;              ///< The maximum cost for a route.
	_distance_penalty = null;		///< Penalty to use to speed up pathfinder, 1 is no penalty
	cost = null;                   ///< Used to change the costs.
	_running = null;
	
	constructor()
	{
		this._max_tiles = 16000;
		this._distance_penalty = 5;
		
		this._pathfinder = this._aystar_class(this, this._Cost, this._Estimate, this._Neighbours, this._CheckDirection);
		this.cost = this.Cost(this);
		this._running = false;
	}

	/**
	 * Initialize a path search between sources and goals.
	 * @param sources The source tiles.
	 * @param goals The target tiles.
	 * @see AyStar::InitializePath()
	 */
	function InitializePath(sources, goals) {
		local nsources = [];

		foreach (node in sources) {
			nsources.push([node, 0xFF]);
		}
		this._pathfinder.InitializePath(nsources, goals);

	}

	/**
	 * Try to find the path as indicated with InitializePath with the lowest cost.
	 * @param iterations After how many iterations it should abort for a moment.
	 *  This value should either be -1 for infinite, or > 0. Any other value
	 *  aborts immediatly and will never find a path.
	 * @return A route if one was found, or false if the amount of iterations was
	 *  reached, or null if no path was found.
	 *  You can call this function over and over as long as it returns false,
	 *  which is an indication it is not yet done looking for a route.
	 * @see AyStar::FindPath()
	 */
	function FindPath(iterations);
};

class _MetaLib_WaterBody_Check_.Cost
{
	_main = null;

	function _set(idx, val)
	{
		if (this._main._running) throw("You are not allowed to change parameters of a running pathfinder.");

		switch (idx) {
			case "max_tiles":          this._main._max_tiles = val; break;
			case "distance_penalty":	this._main._distance_penalty = val; break;
			default: throw("the index '" + idx + "' does not exist");
		}

		return val;
	}

	function _get(idx)
	{
		switch (idx) {
			case "max_tiles":          return this._main._tiles_cost;
			case "distance_penalty":	return this._main._distance_penalty;
			default: throw("the index '" + idx + "' does not exist");
		}
	}

	constructor(main)
	{
		this._main = main;
	}
};

function _MetaLib_WaterBody_Check_::FindPath(iterations)
{
	local ret = this._pathfinder.FindPath(iterations);
	this._running = (ret == false) ? true : false;
	return ret;
}


function _MetaLib_WaterBody_Check_::_Cost(self, path, new_tile, new_direction)
{
	/* path == null means this is the first node of a path, so the cost is 0. */
	if (path == null) return 0;

	local prev_tile = path.GetTile();

	local cost = 1;
	
	if (AIMarine.AreWaterTilesConnected(new_tile, prev_tile) != true) {
		cost = this._max_tiles * 10;	//	Basically, way over the top
	}
	return path.GetCost() + cost;
}

function _MetaLib_WaterBody_Check_::_Estimate(self, cur_tile, cur_direction, goal_tiles)
{
	local min_cost = 1;
	/* As estimate we multiply the lowest possible cost for a single tile with
	 * with the minimum number of tiles we need to traverse. */
	foreach (tile in goal_tiles) {
		min_cost = min(AIMap.DistanceManhattan(cur_tile, tile) * self._distance_penalty, min_cost);
	}
	return min_cost;
}

function _MetaLib_WaterBody_Check_::_Neighbours(self, path, cur_node)
{
	/* self._max_cost is the maximum path cost, if we go over it, the path isn't valid. */
	if (path.GetCost() >= self._max_cost) return [];
	local tiles = [];

	local offsets = [AIMap.GetTileIndex(0, 1), AIMap.GetTileIndex(0, -1),
					 AIMap.GetTileIndex(1, 0), AIMap.GetTileIndex(-1, 0)];
	/* Check all tiles adjacent to the current tile. */
	foreach (offset in offsets) {
		local next_tile = cur_node + offset;
		if (AIMarine.AreWaterTilesConnected(cur_node, next_tile)) {
			tiles.push([next_tile, self._GetDirection(cur_node, next_tile)]);
		}
	}
	return tiles;
}

function _MetaLib_WaterBody_Check_::_CheckDirection(self, tile, existing_direction, new_direction)
{
	return false;
}

function _MetaLib_WaterBody_Check_::_GetDirection(from, to)
{
	if (AITile.GetSlope(to) == AITile.SLOPE_FLAT) return 0xFF;
	if (from - to == 1) return 1;
	if (from - to == -1) return 2;
	if (from - to == AIMap.GetMapSizeX()) return 4;
	if (from - to == -AIMap.GetMapSizeX()) return 8;
}

