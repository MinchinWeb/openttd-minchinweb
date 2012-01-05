/*	Ship and Marine functions v.1 r.189 [2012-01-05],
 *		part of Minchinweb's MetaLibrary v.2,
 *		originally part of WmDOT v.7
 *	Copyright © 2011-12 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */

/* 
 *		MinchinWeb.Ship.DistanceShip(TileA, TileB)
 *						.GetPossibleDockTiles(IndustryID)
 *						.GetDockFrontTiles(Tile)
 *
 *		See also MinchinWeb.ShipPathfinder
 */
 
 
class _MinchinWeb_Marine_ {
	main = null;
}
 
function _MinchinWeb_Marine_::DistanceShip(TileA, TileB)
{
//	Assuming open ocean, ship in OpenTTD will travel 45° angle where possible,
//		and then finish up the trip by going along a cardinal direction
	return ((AIMap.DistanceManhattan(TileA, TileB) - AIMap.DistanceMax(TileA, TileB)) * 0.4 + AIMap.DistanceMax(TileA, TileB)).tointeger();
}

function _MinchinWeb_Marine_::GetPossibleDockTiles(IndustryID)
{
//	Given an industry (by IndustryID), searches for possible tiles to build a
//		dock and retruns the list as an array of TileIndexs

//	Tiles given should be checked to ensure that the desired cargo is still
//		accepted

//	Assumes that the industry location retruned is the NE corner of the
//		industry, and that industries fit within a 4x4 block
	local Tiles = [];
	if (AIIndustry.IsValidIndustry(IndustryID) == true) {
		//	Check if the industry already has a dock
		if (AIIndustry.HasDock(IndustryID) == true) {
			return [AIIndustry.GetDockLocation(IndustryID)];
		} else {
		//	If not, build a box and then test all the tiles to see if a dock can
		//		be built there
			local BaseLocation = AIIndustry.GetLocation(IndustryID);
			local StartX = AIMap.GetTileX(BaseLocation) - AIStation.GetCoverageRadius(AIStation.STATION_DOCK);
			local StartY = AIMap.GetTileY(BaseLocation) - AIStation.GetCoverageRadius(AIStation.STATION_DOCK);
			local EndX = AIMap.GetTileX(BaseLocation) + _MinchinWeb_C_.IndustrySize() + AIStation.GetCoverageRadius(AIStation.STATION_DOCK);
			local EndY = AIMap.GetTileY(BaseLocation) + _MinchinWeb_C_.IndustrySize() + AIStation.GetCoverageRadius(AIStation.STATION_DOCK);
			
			local Tiles = [];
			for (local i = StartX; i < EndX; i++) {
				for (local j = StartY; j < EndY; j++) {
					local ex = AITestMode();
					if (AIMarine.BuildDock(AIMap.GetTileIndex(i,j), AIStation.STATION_NEW) == true) {
						Tiles.push(AIMap.GetTileIndex(i,j));
						SuperLib.Helper.SetSign(AIMap.GetTileIndex(i,j),"Y");
					} else {
						SuperLib.Helper.SetSign(AIMap.GetTileIndex(i,j),"no");
					}
				}
			}		
		}
		return Tiles;
	} else {
		AILog.Warning("MinchinWeb.Marine.GetPossibleDockTiles() was supplied with an invalid IndustryID. Was supplied " + IndustryID + ".");
		return Tiles;
	}
}

function _MinchinWeb_Marine_::GetDockFrontTiles(Tile)
{
//	Given a tile, returns an array of possible 'front' tiles that a ship could
//		access the dock from
//	Can be either the land tile of a dock, or the water tile
//	Does not test if there is currently a dock at the tile

//	Tiles under Oil Rigs do not return  AITile.IsWaterTile(Tile) == true

	local ReturnTiles = [];
	local WaterTile = null;
	local offset = AIMap.GetTileIndex(0, 0);;
	local DockEnd;
	local offsets = [AIMap.GetTileIndex(0, 1), AIMap.GetTileIndex(0, -1),
					 AIMap.GetTileIndex(1, 0), AIMap.GetTileIndex(-1, 0)];
	local next_tile;
	
	if (AIMap.IsValidTile(Tile)) {		
		if (AITile.IsWaterTile(Tile)) {
			// water tile
			WaterTile = Tile;
		} else {
			//	land tile
			switch (AITile.GetSlope(Tile)) {
			//	see  http://vcs.openttd.org/svn/browser/trunk/docs/tileh.png
			//		for slopes
				case 3:
					offset = AIMap.GetTileIndex(-1, 0);
					break;	
				case 6:
					offset = AIMap.GetTileIndex(0, -1);
					break;
				case 9:
					offset = AIMap.GetTileIndex(0, 1);
					break;
				case 12:
					offset = AIMap.GetTileIndex(1, 0);
					break;
			}
			
			DockEnd = Tile + offset;
			
			if ((AITile.IsWaterTile(DockEnd)) || (offset == AIMap.GetTileIndex(0, 0))) {
				WaterTile = DockEnd;
			}
		}
		
		if (WaterTile != null) {
			/* Check all tiles adjacent to the current tile. */
			foreach (offset in offsets) {
				next_tile = WaterTile + offset;
				if (AITile.IsWaterTile(next_tile)) {
					ReturnTiles.push(next_tile);
				}
			}
		}
	} else {
		AILog.Warning("MinchinWeb.Marine.GetDockFrontTiles() was supplied with an invalid TileIndex. Was supplied " + Tile + ".");
	}
	
	return ReturnTiles;
}

