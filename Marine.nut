/*	Ship and Marine functions v.1 r.186 [2012-01-02],
 *		part of Minchinweb's MetaLibrary v.2,
 *		originally part of WmDOT v.7
 *	Copyright © 2011-12 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */

/* 
 *		MinchinWeb.Ship.DistanceShip(TileA, TileB)
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
	return ((AIMap.DistanceManhattan(TileA, TileB) - AIMap.DistanceMax(TileA, TileB)) * 0.4 + AIMap.DistanceMax(TileA, TileB))
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