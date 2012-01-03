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
 
 
class _MinchinWeb_Ship_ {
	main = null;
}
 
function _MinchinWeb_Ship_::DistanceShip(TileA, TileB)
{
//	Assuming open ocean, ship in OpenTTD will travel 45° angle where possible,
//		and then finish up the trip by going along a cardinal direction
	return ((AIMap.DistanceManhattan(TileA, TileB) - AIMap.DistanceMax(TileA, TileB)) * 0.4 + AIMap.DistanceMax(TileA, TileB))
}