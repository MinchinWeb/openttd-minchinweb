﻿/*	RoadPathfinder v.7-GS r.140 [2011-12-03],
 *		part of MinchinWeb's MetaLibrary v.2-GS, r.140 [2011-12-03],
 *		adapted from Minchinweb's MetaLibrary v.1, r.118, [2011-04-28],
 *		originally part of WmDOT v.4  r.50 [2011-04-06]
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/*	This file is licenced under the originl licnese - LGPL v2.1
 *		and is based on the NoAI Team's Road Pathfinder v3
 */

/* $Id: main.nut 15101 2009-01-16 00:05:26Z truebrain $ */

/**
 * A Road Pathfinder.
 *  This road pathfinder tries to find a buildable / existing route for
 *  road vehicles. You can changes the costs below using for example
 *  roadpf.cost.turn = 30. Note that it's not allowed to change the cost
 *  between consecutive calls to FindPath. You can change the cost before
 *  the first call to FindPath and after FindPath has returned an actual
 *  route. To use only existing roads, set cost.only_existing_road to
 *  'true'.
 */
 
//	Requires Graph.AyStar v6 library

//	This file provides functions:
//		MetaLib.RoadPathfinder.InitializePath(sources, goals)
			//	Set up the pathfinder
//		MetaLib.RoadPathfinder.FindPath(iterations)	
			//	Run the pathfinder; returns false if it isn't finished the path
			//		 if it has finished, and null if it can't find a path
//		MetaLib.RoadPathfinder.cost.[xx]
			//	Allows you to set or find out the pathfinder costs directly.
//			//		 See the function below for valid entries
//		MetaLib.RoadPathfinder.Info.GetVersion()
//									.GetMinorVersion()
//									.GetRevision()
//									.GetDate()
//									.GetName()
			//	Useful for check provided version or debugging screen output
//		MetaLib.RoadPathfinder.PresetOriginal()
//							  .PresetPerfectPath()
//							  .PresetQuickAndDirty()
//							  .PresetCheckExisting()
//							  .PresetMode6()
//							  .PresetStreetcar() 
			//	Presets for the pathfinder parameters
//		MetaLib.RoadPathfinder.GetBuildCost()					//	How much would it be to build the path?
//		MetaLib.RoadPathfinder.BuildPath()						//	Build the path
//		MetaLib.RoadPathfinder.GetPathLength()					//	How long is the path?
//		MetaLib.RoadPathfinder.LoadPath(Path)					//	Provide your own path
//		MetaLib.RoadPathfinder.InitializePathOnTowns(StartTown, EndTown)
//			//	Initializes the pathfinder using the seed tiles to the given towns	
//		MetaLib.RoadPathfinder.PathToTilePairs()
//			//	Returns a 2D array that has each pair of tiles that path joins
//		MetaLib.RoadPathfinder.TilesPairsToBuild()
//			//	Similiar to PathToTilePairs(), but only returns those pairs 
//			//	where there isn't a current road connection

class _MinchinWeb_RoadPathfinder_
{
//	_aystar_class = import("graph.aystar", "", 6);
	_aystar_class = _MinchinWeb_AyStar_;
	_max_cost = null;              ///< The maximum cost for a route.
	_cost_tile = null;             ///< The cost for a single tile.
	_cost_no_existing_road = null; ///< The cost that is added to _cost_tile if no road exists yet.
	_cost_turn = null;             ///< The cost that is added to _cost_tile if the direction changes.
	_cost_slope = null;            ///< The extra cost if a road tile is sloped.
	_cost_bridge_per_tile = null;  ///< The cost per tile of a new bridge, this is added to _cost_tile.
	_cost_tunnel_per_tile = null;  ///< The cost per tile of a new tunnel, this is added to _cost_tile.
	_cost_coast = null;            ///< The extra cost for a coast tile.
	_pathfinder = null;            ///< A reference to the used AyStar object.
	_max_bridge_length = null;     ///< The maximum length of a bridge that will be build.
	_max_tunnel_length = null;     ///< The maximum length of a tunnel that will be build.
	_cost_only_existing_roads = null;	   ///< Choose whether to only search through exisitng connected roads
	_distance_penalty = null;		///< Penalty to use to speed up pathfinder, 1 is no penalty
	_road_type = null;
	cost = null;                   ///< Used to change the costs.
	_mypath = null;					///< Used to store the path after it's been found for Building functions
	_running = null;
	info = null;
//	presets = null;

	constructor()
	{
		this._max_cost = 10000000;
		this._cost_tile = 100;
		this._cost_no_existing_road = 40;
		this._cost_turn = 100;
		this._cost_slope = 200;
		this._cost_bridge_per_tile = 150;
		this._cost_tunnel_per_tile = 120;
		this._cost_coast = 20;
		this._max_bridge_length = 10;
		this._max_tunnel_length = 20;
		this._cost_only_existing_roads = false;
//		this._pathfinder = this._aystar_class(this._Cost, this._Estimate, this._Neighbours, this._CheckDirection, this, this, this, this);
		this._pathfinder = this._aystar_class(this, this._Cost, this._Estimate, this._Neighbours, this._CheckDirection);
		this._distance_penalty = 1;
		this._road_type = GSRoad.ROADTYPE_ROAD;
		this._mypath = null;

		this.cost = this.Cost(this);
		this.info = this.Info(this);
//		this.presets = this.Presets(this);
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
		this._mypath = null;
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

class _MinchinWeb_RoadPathfinder_.Cost
{
	_main = null;

	function _set(idx, val)
	{
		if (this._main._running) throw("You are not allowed to change parameters of a running pathfinder.");

		switch (idx) {
			case "max_cost":          this._main._max_cost = val; break;
			case "tile":              this._main._cost_tile = val; break;
			case "no_existing_road":  this._main._cost_no_existing_road = val; break;
			case "turn":              this._main._cost_turn = val; break;
			case "slope":             this._main._cost_slope = val; break;
			case "bridge_per_tile":   this._main._cost_bridge_per_tile = val; break;
			case "tunnel_per_tile":   this._main._cost_tunnel_per_tile = val; break;
			case "coast":             this._main._cost_coast = val; break;
			case "max_bridge_length": this._main._max_bridge_length = val; break;
			case "max_tunnel_length": this._main._max_tunnel_length = val; break;
			case "only_existing_roads":	this._main._cost_only_existing_roads = val; break;
			case "distance_penalty":	this._main._distance_penalty = val; break;
			default: throw("the index '" + idx + "' does not exist");
		}

		return val;
	}

	function _get(idx)
	{
		switch (idx) {
			case "max_cost":          return this._main._max_cost;
			case "tile":              return this._main._cost_tile;
			case "no_existing_road":  return this._main._cost_no_existing_road;
			case "turn":              return this._main._cost_turn;
			case "slope":             return this._main._cost_slope;
			case "bridge_per_tile":   return this._main._cost_bridge_per_tile;
			case "tunnel_per_tile":   return this._main._cost_tunnel_per_tile;
			case "coast":             return this._main._cost_coast;
			case "max_bridge_length": return this._main._max_bridge_length;
			case "max_tunnel_length": return this._main._max_tunnel_length;
			case "only_existing_roads":	return this._main._cost_only_existing_roads;
			case "distance_penalty":	return this._main._distance_penalty;
			default: throw("the index '" + idx + "' does not exist");
		}
	}

	constructor(main)
	{
		this._main = main;
	}
};

function _MinchinWeb_RoadPathfinder_::FindPath(iterations)
{
	local test_mode = GSTestMode();
	local ret = this._pathfinder.FindPath(iterations);
	this._running = (ret == false) ? true : false;
	if (this._running == false) { this._mypath = ret; }
	return ret;
}

function _MinchinWeb_RoadPathfinder_::_GetBridgeNumSlopes(end_a, end_b)
{
	local slopes = 0;
	local direction = (end_b - end_a) / GSMap.DistanceManhattan(end_a, end_b);
	local slope = GSTile.GetSlope(end_a);
	if (!((slope == GSTile.SLOPE_NE && direction == 1) || (slope == GSTile.SLOPE_SE && direction == -GSMap.GetMapSizeX()) ||
		(slope == GSTile.SLOPE_SW && direction == -1) || (slope == GSTile.SLOPE_NW && direction == GSMap.GetMapSizeX()) ||
		 slope == GSTile.SLOPE_N || slope == GSTile.SLOPE_E || slope == GSTile.SLOPE_S || slope == GSTile.SLOPE_W)) {
		slopes++;
	}

	local slope = GSTile.GetSlope(end_b);
	direction = -direction;
	if (!((slope == GSTile.SLOPE_NE && direction == 1) || (slope == GSTile.SLOPE_SE && direction == -GSMap.GetMapSizeX()) ||
		(slope == GSTile.SLOPE_SW && direction == -1) || (slope == GSTile.SLOPE_NW && direction == GSMap.GetMapSizeX()) ||
		 slope == GSTile.SLOPE_N || slope == GSTile.SLOPE_E || slope == GSTile.SLOPE_S || slope == GSTile.SLOPE_W)) {
		slopes++;
	}
	return slopes;
}

function _MinchinWeb_RoadPathfinder_::_Cost(self, path, new_tile, new_direction)
{
	/* path == null means this is the first node of a path, so the cost is 0. */
	if (path == null) return 0;

	local prev_tile = path.GetTile();

	/* If the new tile is a bridge / tunnel tile, check whether we came from the other
	 * end of the bridge / tunnel or if we just entered the bridge / tunnel. */
	if (GSBridge.IsBridgeTile(new_tile)) {
		if (GSBridge.GetOtherBridgeEnd(new_tile) != prev_tile) return path.GetCost() + self._cost_tile;
		return path.GetCost() + GSMap.DistanceManhattan(new_tile, prev_tile) * self._cost_tile + self._GetBridgeNumSlopes(new_tile, prev_tile) * self._cost_slope;
	}
	if (GSTunnel.IsTunnelTile(new_tile)) {
		if (GSTunnel.GetOtherTunnelEnd(new_tile) != prev_tile) return path.GetCost() + self._cost_tile;
		return path.GetCost() + GSMap.DistanceManhattan(new_tile, prev_tile) * self._cost_tile;
	}

	/* If the two tiles are more then 1 tile apart, the pathfinder wants a bridge or tunnel
	 * to be build. It isn't an existing bridge / tunnel, as that case is already handled. */
	if (GSMap.DistanceManhattan(new_tile, prev_tile) > 1) {
		/* Check if we should build a bridge or a tunnel. */
		if (GSTunnel.GetOtherTunnelEnd(new_tile) == prev_tile) {
			return path.GetCost() + GSMap.DistanceManhattan(new_tile, prev_tile) * (self._cost_tile + self._cost_tunnel_per_tile);
		} else {
			return path.GetCost() + GSMap.DistanceManhattan(new_tile, prev_tile) * (self._cost_tile + self._cost_bridge_per_tile) + self._GetBridgeNumSlopes(new_tile, prev_tile) * self._cost_slope;
		}
	}

	/* Check for a turn. We do this by substracting the TileID of the current node from
	 * the TileID of the previous node and comparing that to the difference between the
	 * previous node and the node before that. */
	local cost = self._cost_tile;
	if (path.GetParent() != null && (prev_tile - path.GetParent().GetTile()) != (new_tile - prev_tile) &&
		GSMap.DistanceManhattan(path.GetParent().GetTile(), prev_tile) == 1) {
		cost += self._cost_turn;
	}

	/* Check if the new tile is a coast tile. */
	if (GSTile.IsCoastTile(new_tile)) {
		cost += self._cost_coast;
	}

	/* Check if the last tile was sloped. */
	if (path.GetParent() != null && !GSBridge.IsBridgeTile(prev_tile) && !GSTunnel.IsTunnelTile(prev_tile) &&
	    self._IsSlopedRoad(path.GetParent().GetTile(), prev_tile, new_tile)) {
		cost += self._cost_slope;
	}


	if (!GSRoad.AreRoadTilesConnected(prev_tile, new_tile)) {
		cost += self._cost_no_existing_road;
	}

	return path.GetCost() + cost;
}

function _MinchinWeb_RoadPathfinder_::_Estimate(self, cur_tile, cur_direction, goal_tiles)
{
	local min_cost = self._max_cost;
	/* As estimate we multiply the lowest possible cost for a single tile with
	 * with the minimum number of tiles we need to traverse. */
	foreach (tile in goal_tiles) {
		min_cost = min(GSMap.DistanceManhattan(cur_tile, tile) * self._cost_tile * self._distance_penalty, min_cost);
	}
	return min_cost;
}

function _MinchinWeb_RoadPathfinder_::_Neighbours(self, path, cur_node)
{
	/* self._max_cost is the maximum path cost, if we go over it, the path isn't valid. */
	if (path.GetCost() >= self._max_cost) return [];
	local tiles = [];

	/* Check if the current tile is part of a bridge or tunnel. */
	if ((GSBridge.IsBridgeTile(cur_node) || GSTunnel.IsTunnelTile(cur_node)) &&
	     GSTile.HasTransportType(cur_node, GSTile.TRANSPORT_ROAD)) {
		local other_end = GSBridge.IsBridgeTile(cur_node) ? GSBridge.GetOtherBridgeEnd(cur_node) : GSTunnel.GetOtherTunnelEnd(cur_node);
		local next_tile = cur_node + (cur_node - other_end) / GSMap.DistanceManhattan(cur_node, other_end);
		if (GSRoad.AreRoadTilesConnected(cur_node, next_tile) || GSTile.IsBuildable(next_tile) || GSRoad.IsRoadTile(next_tile)) {
			tiles.push([next_tile, self._GetDirection(cur_node, next_tile, false)]);
		}
		/* The other end of the bridge / tunnel is a neighbour. */
		tiles.push([other_end, self._GetDirection(next_tile, cur_node, true) << 4]);
	} else if (path.GetParent() != null && GSMap.DistanceManhattan(cur_node, path.GetParent().GetTile()) > 1) {
		local other_end = path.GetParent().GetTile();
		local next_tile = cur_node + (cur_node - other_end) / GSMap.DistanceManhattan(cur_node, other_end);
		if (GSRoad.AreRoadTilesConnected(cur_node, next_tile) || GSRoad.BuildRoad(cur_node, next_tile)) {
			tiles.push([next_tile, self._GetDirection(cur_node, next_tile, false)]);
		}
	} else {
		local offsets = [GSMap.GetTileIndex(0, 1), GSMap.GetTileIndex(0, -1),
		                 GSMap.GetTileIndex(1, 0), GSMap.GetTileIndex(-1, 0)];
		/* Check all tiles adjacent to the current tile. */
		foreach (offset in offsets) {
			local next_tile = cur_node + offset;
			/* We add them to the to the neighbours-list if one of the following applies:
			 * 1) There already is a connections between the current tile and the next tile.
			 * 2) We can build a road to the next tile.
			 * 3) The next tile is the entrance of a tunnel / bridge in the correct direction. */
			if (GSRoad.AreRoadTilesConnected(cur_node, next_tile)) {
				tiles.push([next_tile, self._GetDirection(cur_node, next_tile, false)]);
			} else if ((self._cost_only_existing_roads != true) && (GSTile.IsBuildable(next_tile) || GSRoad.IsRoadTile(next_tile)) &&
					(path.GetParent() == null || GSRoad.CanBuildConnectedRoadPartsHere(cur_node, path.GetParent().GetTile(), next_tile)) &&
					GSRoad.BuildRoad(cur_node, next_tile)) {
			//	WM - add '&& (only_existing_roads != true)' so that non-connected roads are ignored
				tiles.push([next_tile, self._GetDirection(cur_node, next_tile, false)]);
			} else if ((self._cost_only_existing_roads != true) && self._CheckTunnelBridge(cur_node, next_tile)) {
				tiles.push([next_tile, self._GetDirection(cur_node, next_tile, false)]);
			}
		}
		if (path.GetParent() != null) {
			local bridges = self._GetTunnelsBridges(path.GetParent().GetTile(), cur_node, self._GetDirection(path.GetParent().GetTile(), cur_node, true) << 4);
			foreach (tile in bridges) {
				tiles.push(tile);
			}
		}
	}
	return tiles;
}

function _MinchinWeb_RoadPathfinder_::_CheckDirection(self, tile, existing_direction, new_direction)
{
	return false;
}

function _MinchinWeb_RoadPathfinder_::_GetDirection(from, to, is_bridge)
{
	if (!is_bridge && GSTile.GetSlope(to) == GSTile.SLOPE_FLAT) return 0xFF;
	if (from - to == 1) return 1;
	if (from - to == -1) return 2;
	if (from - to == GSMap.GetMapSizeX()) return 4;
	if (from - to == -GSMap.GetMapSizeX()) return 8;
}

/**
 * Get a list of all bridges and tunnels that can be build from the
 * current tile. Bridges will only be build starting on non-flat tiles
 * for performance reasons. Tunnels will only be build if no terraforming
 * is needed on both ends.
 */
function _MinchinWeb_RoadPathfinder_::_GetTunnelsBridges(last_node, cur_node, bridge_dir)
{
	local slope = GSTile.GetSlope(cur_node);
	if (slope == GSTile.SLOPE_FLAT) return [];
	local tiles = [];

	for (local i = 2; i < this._max_bridge_length; i++) {
		local bridge_list = GSBridgeList_Length(i + 1);
		local target = cur_node + i * (cur_node - last_node);
		if (!bridge_list.IsEmpty() && GSBridge.BuildBridge(GSVehicle.VT_ROAD, bridge_list.Begin(), cur_node, target)) {
			tiles.push([target, bridge_dir]);
		}
	}

	if (slope != GSTile.SLOPE_SW && slope != GSTile.SLOPE_NW && slope != GSTile.SLOPE_SE && slope != GSTile.SLOPE_NE) return tiles;
	local other_tunnel_end = GSTunnel.GetOtherTunnelEnd(cur_node);
	if (!GSMap.IsValidTile(other_tunnel_end)) return tiles;

	local tunnel_length = GSMap.DistanceManhattan(cur_node, other_tunnel_end);
	local prev_tile = cur_node + (cur_node - other_tunnel_end) / tunnel_length;
	if (GSTunnel.GetOtherTunnelEnd(other_tunnel_end) == cur_node && tunnel_length >= 2 &&
			prev_tile == last_node && tunnel_length < _max_tunnel_length && GSTunnel.BuildTunnel(GSVehicle.VT_ROAD, cur_node)) {
		tiles.push([other_tunnel_end, bridge_dir]);
	}
	return tiles;
}

function _MinchinWeb_RoadPathfinder_::_IsSlopedRoad(start, middle, end)
{
	local NW = 0; //Set to true if we want to build a road to / from the north-west
	local NE = 0; //Set to true if we want to build a road to / from the north-east
	local SW = 0; //Set to true if we want to build a road to / from the south-west
	local SE = 0; //Set to true if we want to build a road to / from the south-east

	if (middle - GSMap.GetMapSizeX() == start || middle - GSMap.GetMapSizeX() == end) NW = 1;
	if (middle - 1 == start || middle - 1 == end) NE = 1;
	if (middle + GSMap.GetMapSizeX() == start || middle + GSMap.GetMapSizeX() == end) SE = 1;
	if (middle + 1 == start || middle + 1 == end) SW = 1;

	/* If there is a turn in the current tile, it can't be sloped. */
	if ((NW || SE) && (NE || SW)) return false;

	local slope = GSTile.GetSlope(middle);
	/* A road on a steep slope is always sloped. */
	if (GSTile.IsSteepSlope(slope)) return true;

	/* If only one corner is raised, the road is sloped. */
	if (slope == GSTile.SLOPE_N || slope == GSTile.SLOPE_W) return true;
	if (slope == GSTile.SLOPE_S || slope == GSTile.SLOPE_E) return true;

	if (NW && (slope == GSTile.SLOPE_NW || slope == GSTile.SLOPE_SE)) return true;
	if (NE && (slope == GSTile.SLOPE_NE || slope == GSTile.SLOPE_SW)) return true;

	return false;
}

function _MinchinWeb_RoadPathfinder_::_CheckTunnelBridge(current_tile, new_tile)
{
	if (!GSBridge.IsBridgeTile(new_tile) && !GSTunnel.IsTunnelTile(new_tile)) return false;
	local dir = new_tile - current_tile;
	local other_end = GSBridge.IsBridgeTile(new_tile) ? GSBridge.GetOtherBridgeEnd(new_tile) : GSTunnel.GetOtherTunnelEnd(new_tile);
	local dir2 = other_end - new_tile;
	if ((dir < 0 && dir2 > 0) || (dir > 0 && dir2 < 0)) return false;
	dir = abs(dir);
	dir2 = abs(dir2);
	if ((dir >= GSMap.GetMapSizeX() && dir2 < GSMap.GetMapSizeX()) ||
	    (dir < GSMap.GetMapSizeX() && dir2 >= GSMap.GetMapSizeX())) return false;

	return true;
}


/*	These are supplimentary to the Road Pathfinder itself, but will
 *		hopefully prove useful either directly or as a model for writing your
 *		own functions. They include:
 *	- Info class - useful for outputing the details fo the library to the debug
 *		screen
 *	- Build function - used to build the path generated by the pathfinder
 *	- Cost function - used to determine the cost of building the path generated
 *		by the pathfinder
 *	- Length - used to determine how long the generated path is
 *	- Presets - a combination of settings for the pathfinder for using it in
 *		different circumstances
 *		- Original - the settings in the original (v3) pathfinder by NoAI Team
 *		- PerfectPath - my slighlty updated version of Original. Good for
 *			reusing exisiting roads
 *		- Dirty - quick but messy preset. Runs in as little as 5% of the time
 *			of 'PerfectPath', but builds odd bridges and loops
 *		- ExistingCheck - based on PerfectPath, but uses only exising roads.
 *			Useful for checking if there an exisiting route and how long it is
 *		- Streetcar - reserved for future use for intraurban tram lines
 *		If you would like a preset added here, I would be happy to include it
 *			in future versions!
 */
 

class _MinchinWeb_RoadPathfinder_.Info
{
	_main = null;
	
	function GetVersion()       { return 6; }
	function GetMinorVersion()	{ return 0; }
	function GetRevision()		{ return 79; }
	function GetDate()          { return "2011-04-15"; }
	function GetName()          { return "Road Pathfinder (Wm)"; }
	
	constructor(main)
	{
		this._main = main;
	}
}

//	Presets
function _MinchinWeb_RoadPathfinder_::PresetOriginal() {
//	the settings in the original (v3) pathfinder by NoAI Team
	this._max_cost = 10000000;
	this._cost_tile = 100;
	this._cost_no_existing_road = 40;
	this._cost_turn = 100;
	this._cost_slope = 200;
	this._cost_bridge_per_tile = 150;
	this._cost_tunnel_per_tile = 120;
	this._cost_coast = 20;
	this._max_bridge_length = 10;
	this._max_tunnel_length = 20;
	this._cost_only_existing_roads = false;
	this._distance_penalty = 1;
	this._road_type = GSRoad.ROADTYPE_ROAD;
	return;
}

function _MinchinWeb_RoadPathfinder_::PresetPerfectPath() {
//	my slighlty updated version of Original. Good for reusing exisiting
//		roads
	this._max_cost = 100000;
	this._cost_tile = 30;
	this._cost_no_existing_road = 40;
	this._cost_turn = 100;
	this._cost_slope = 200;
	this._cost_bridge_per_tile = 150;
	this._cost_tunnel_per_tile = 120;
	this._cost_coast = 20;
	this._max_bridge_length = 10;
	this._max_tunnel_length = 20;
	this._cost_only_existing_roads = false;
	this._distance_penalty = 1;
	this._road_type = GSRoad.ROADTYPE_ROAD;
	return;
}

function _MinchinWeb_RoadPathfinder_::PresetQuickAndDirty() {
//	quick but messy preset. Runs in as little as 5% of the time of
//		'PerfectPath', but builds odd bridges and loops
/*	this._max_cost = 100000;
	this._cost_tile = 30;
	this._cost_no_existing_road = 301;
	this._cost_turn = 50;
	this._cost_slope = 150;
	this._cost_bridge_per_tile = 750;
	this._cost_tunnel_per_tile = 120;
	this._cost_coast = 20;
	this._max_bridge_length = 16;
	this._max_tunnel_length = 10;
	this._cost_only_existing_roads = false;
	this._distance_penalty = 5;
	this._road_type = GSRoad.ROADTYPE_ROAD;
	return;
	*/
	
// v4 DOT
	this._max_cost = 100000;
	this._cost_tile = 30;
	this._cost_no_existing_road = 120;
	this._cost_turn = 50;
	this._cost_slope = 300;
	this._cost_bridge_per_tile = 200;
	this._cost_tunnel_per_tile = 120;
	this._cost_coast = 20;
	this._max_bridge_length = 16;
	this._max_tunnel_length = 10;
	this._cost_only_existing_roads = false;
	this._distance_penalty = 5;
	this._road_type = GSRoad.ROADTYPE_ROAD;
	return;	
}

function _MinchinWeb_RoadPathfinder_::PresetCheckExisting() {
//	based on PerfectPath, but uses only exising roads. Useful for checking
//		if there an exisiting route and how long it is
	this._max_cost = 100000;
	this._cost_tile = 30;
	this._cost_no_existing_road = 40;
	this._cost_turn = 100;
	this._cost_slope = 200;
	this._cost_bridge_per_tile = 150;
	this._cost_tunnel_per_tile = 120;
	this._cost_coast = 20;
	this._max_bridge_length = 9999;
	this._max_tunnel_length = 9999;
	this._cost_only_existing_roads = true;
	this._distance_penalty = 3;
	this._road_type = GSRoad.ROADTYPE_ROAD;
	return;
}

function _MinchinWeb_RoadPathfinder_::PresetStreetcar () {
//	reserved for future use for intraurban tram lines
	return;
}

function _MinchinWeb_RoadPathfinder_::GetBuildCost()
{
//	Turns to 'test mode,' builds the route provided, and returns the cost (all
//		money for AI's is in British Pounds)
//	Note that due to inflation, this value can get stale
//	Returns false if the test build fails somewhere

	if (this._running) {
		GSLog.Warning("You can't find the build costs while there's a running pathfinder.");
		return false;
	}
	if (this._mypath == null) {
		GSLog.Warning("You have tried to get the build costs of a 'null' path.");
		return false;
	}
	
	local BeanCounter = GSAccounting();
	local TestMode = GSTestMode();
	local Path = this._mypath;

	GSRoad.SetCurrentRoadType(this._road_type);
	while (Path != null) {
		local SubPath = Path.GetParent();
		if (SubPath != null) {
			local Node = Path.GetTile();
			if (GSMap.DistanceManhattan(Path.GetTile(), SubPath.GetTile()) == 1) {
			//	MD == 1 == road joining the two tiles
				if (!GSRoad.BuildRoad(Path.GetTile(), SubPath.GetTile())) {
				//	If we get here, then the road building has failed
				//	Possible that the road already exists
				//	TO-DO
				//	- fail the road builder if the road cannot be built and
				//		does not already exist
				//	return null;
				}
			} else {
			//	Implies that we're building either a tunnel or a bridge
				if (!GSBridge.IsBridgeTile(Path.GetTile()) && !GSTunnel.IsTunnelTile(Path.GetTile())) {
					if (GSRoad.IsRoadTile(Path.GetTile())) {
					//	Original example demolishes tile if it's already a road
					//		tile to get around expanded roadbits.
					//	I don't like this approach as it could destroy Railway
					//		tracks/tram tracks/station
					//	TO-DO
					//	- figure out a way to do this while keeping the other
					//		things I've built on the tile
					//	(can I just remove the road?)
						GSTile.DemolishTile(Path.GetTile());
					}
					if (GSTunnel.GetOtherTunnelEnd(Path.GetTile()) == SubPath.GetTile()) {
						if (!GSTunnel.BuildTunnel(GSVehicle.VT_ROAD, Path.GetTile())) {
						//	At this point, an error has occured while building the tunnel.
						//	Fail the pathfiner
						//	return null;
						GSLog.Warning("MetaLib.RoadPathfinder.GetBuildCost can't build a tunnel from " + GSMap.GetTileX(Path.GetTile()) + "," + GSMap.GetTileY(Path.GetTile()) + " to " + GSMap.GetTileX(SubPath.GetTile()) + "," + GSMap.GetTileY(SubPath.GetTile()) + "!!" );
						}
					} else {
					//	if not a tunnel, we assume we're buildng a bridge
						local BridgeList = GSBridgeList_Length(GSMap.DistanceManhattan(Path.GetTile(), SubPath.GetTile() + 1));
						BridgeList.Valuate(GSBridge.GetMaxSpeed);
						BridgeList.Sort(GSAbstractList.SORT_BY_VALUE, false);
						if (!GSBridge.BuildBridge(GSVehicle.VT_ROAD, BridgeList.Begin(), Path.GetTile(), SubPath.GetTile())) {
						//	At this point, an error has occured while building the bridge.
						//	Fail the pathfiner
						//	return null;
						GSLog.Warning("MetaLib.RoadPathfinder.GetBuildCost can't build a bridge from " + GSMap.GetTileX(Path.GetTile()) + "," + GSMap.GetTileY(Path.GetTile()) + " to " + GSMap.GetTileX(SubPath.GetTile()) + "," + GSMap.GetTileY(SubPath.GetTile()) + "!!" );
						}
					}
				}
			}
		}
	Path = SubPath;
	}
	
	//	End build sequence
		return BeanCounter.GetCosts();
}

function _MinchinWeb_RoadPathfinder_::BuildPath()
{
	if (this._running) {
		GSLog.Warning("You can't build a path while there's a running pathfinder.");
		return false;
	}
	if (this._mypath == null) {
		GSLog.Warning("You have tried to build a 'null' path.");
		return false;
	}
	
	local TestMode = GSExecMode();	//	We're really doing this!
	local Path = this._mypath;

	GSRoad.SetCurrentRoadType(this._road_type);
	while (Path != null) {
		local SubPath = Path.GetParent();
		if (SubPath != null) {
			local Node = Path.GetTile();
			if (GSMap.DistanceManhattan(Path.GetTile(), SubPath.GetTile()) == 1) {
			//	MD == 1 == road joining the two tiles
				if (!GSRoad.BuildRoad(Path.GetTile(), SubPath.GetTile())) {
				//	If we get here, then the road building has failed
				//	Possible that the road already exists
				//	TO-DOz
				//	- fail the road builder if the road cannot be built and
				//		does not already exist
				//	return null;
				}
			} else {
			//	Implies that we're building either a tunnel or a bridge
				if (!GSBridge.IsBridgeTile(Path.GetTile()) && !GSTunnel.IsTunnelTile(Path.GetTile())) {
					if (GSRoad.IsRoadTile(Path.GetTile())) {
					//	Original example demolishes tile if it's already a road
					//		tile to get around expanded roadbits.
					//	I don't like this approach as it could destroy Railway
					//		tracks/tram tracks/station
					//	TO-DO
					//	- figure out a way to do this while keeping the other
					//		things I've built on the tile
					//	(can I just remove the road?)
						GSTile.DemolishTile(Path.GetTile());
					}
					if (GSTunnel.GetOtherTunnelEnd(Path.GetTile()) == SubPath.GetTile()) {
					//	The assumption here is that the land hasn't changed
					//		from when the pathfinder was run and when we try to
					//		build the path. If the tunnel building fails, we
					//		get the 'can't build tunnel' message, but if the
					//		land has changed such that the tunnel end is at a
					//		different spot than is was when the pathfinder ran,
					//		we skip tunnel building and try and build a bridge
					//		instead, which will fail because the slopes are wrong...
						if (!GSTunnel.BuildTunnel(GSVehicle.VT_ROAD, Path.GetTile())) {
						//	At this point, an error has occured while building the tunnel.
						//	Fail the pathfiner
						//	return null;
							GSLog.Warning("MetaLib.RoadPathfinder.BuildPath can't build a tunnel from " + GSMap.GetTileX(Path.GetTile()) + "," + GSMap.GetTileY(Path.GetTile()) + " to " + GSMap.GetTileX(SubPath.GetTile()) + "," + GSMap.GetTileY(SubPath.GetTile()) + "!!" );
						}
					} else {
					//	if not a tunnel, we assume we're buildng a bridge
						local BridgeList = GSBridgeList_Length(GSMap.DistanceManhattan(Path.GetTile(), SubPath.GetTile() + 1));
						BridgeList.Valuate(GSBridge.GetMaxSpeed);
						BridgeList.Sort(GSAbstractList.SORT_BY_VALUE, false);
						if (!GSBridge.BuildBridge(GSVehicle.VT_ROAD, BridgeList.Begin(), Path.GetTile(), SubPath.GetTile())) {
						//	At this point, an error has occured while building the bridge.
						//	Fail the pathfiner
						//	return null;
						GSLog.Warning("MetaLib.RoadPathfinder.BuildPath can't build a bridge from " + GSMap.GetTileX(Path.GetTile()) + "," + GSMap.GetTileY(Path.GetTile()) + " to " + GSMap.GetTileX(SubPath.GetTile()) + "," + GSMap.GetTileY(SubPath.GetTile()) + "!! (or the tunnel end moved...)" );
						}
					}
				}
			}
		}
	Path = SubPath;
	}
	
	//	End build sequence
	return true;
}

function _MinchinWeb_RoadPathfinder_::LoadPath (Path)
{
//	'Loads' a path to allow GetBuildCost(), BuildPath() and GetPathLength()
//		to be used
	if (this._running) {
		GSLog.Warning("You can't load a path while there's a running pathfinder.");
		return false;
	}
	this._mypath = Path;
}

function _MinchinWeb_RoadPathfinder_::GetPath()
{
//	Returns the path
	if (this._running) {
		GSLog.Warning("You can't get the path while there's a running pathfinder.");
		return false;
	}
	return this._mypath;
}

function _MinchinWeb_RoadPathfinder_::GetPathLength()
{
//	Runs over the path to determine its length
	if (this._running) {
		GSLog.Warning("You can't get the path length while there's a running pathfinder.");
		return false;
	}
	if (this._mypath == null) {
		GSLog.Warning("You have tried to get the length of a 'null' path.");
		return false;
	}
	
	return _mypath.GetLength();
}

function _MinchinWeb_RoadPathfinder_::InitializePathOnTowns(StartTown, EndTown)
{
//	Initializes the pathfinder using two towns
//	Assumes that the town centers are road tiles (if this is not the case, the
//		pathfinder will still run, but it will take a long time and eventually
//		fail to return a path)
	return this.InitializePath([GSTown.GetLocation(StartTown)], [GSTown.GetLocation(EndTown)]);
}

function _MinchinWeb_RoadPathfinder_::PathToTilePairs()
{
//	Returns a 2D array that has each pair of tiles that path joins
	if (this._running) {
		GSLog.Warning("You can't convert a path while there's a running pathfinder.");
		return false;
	}
	if (this._mypath == null) {
		GSLog.Warning("You have tried to convert a 'null' path.");
		return false;
	}
	
	local Path = this._mypath;
	local TilePairs = [];

	while (Path != null) {
		local SubPath = Path.GetParent();
		if (SubPath != null) {
			TilePairs.push([Path.GetTile(), SubPath.GetTile()]);	
		}
	Path = SubPath;
	}
	
	//	End build sequence
	return TilePairs;
}

function _MinchinWeb_RoadPathfinder_::TilesPairsToBuild()
{
//	Similiar to PathToTilePairs(), but only returns those pairs where there
//		isn't a current road connection

	if (this._running) {
		GSLog.Warning("You can't convert a (partial) path while there's a running pathfinder.");
		return false;
	}
	if (this._mypath == null) {
		GSLog.Warning("You have tried to convert a (partial) 'null' path.");
		return false;
	}
	
	local Path = this._mypath;
	local TilePairs = [];

	while (Path != null) {
		local SubPath = Path.GetParent();
		if (SubPath != null) {
			if (GSMap.DistanceManhattan(Path.GetTile(), SubPath.GetTile()) == 1) {
			//	Could join with a road
				if (GSRoad.AreRoadTilesConnected(Path.GetTile(), SubPath.GetTile()) != true) {
					TilePairs.push([Path.GetTile(), SubPath.GetTile()]);
				}
			} else {
			//	Implies that we're building either a tunnel or a bridge
				if (!GSBridge.IsBridgeTile(Path.GetTile()) && !GSTunnel.IsTunnelTile(Path.GetTile())) {
					TilePairs.push([Path.GetTile(), SubPath.GetTile()]);
				}
			}
		}
	Path = SubPath;
	}
	
	//	End build sequence
	return TilePairs;
}