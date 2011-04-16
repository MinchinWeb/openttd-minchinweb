/*	Extra functions v.1 r.90 [2011-04-16],
 *	part of Minchinweb's MetaLibrary v1, r90, [2011-04-16],
 *	originally part of WmDOT v.6
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/*	These are 'random' functions that didn't seem to fit well elsewhere.
 *
 *	Functions provided:
 *		MetaLib.Extras.DistanceShip(TileA, TileB)
 */
 
class _MetaLib_Extras_ {
	main = null;
}

function _MetaLib_Extras_::DistanceShip(TileA, TileB)
{
//	Assuming open ocean, ship in OpenTTD will travel 45° angle where possible,
//		and then finish up the trip by going along a cardinal direction
	return ((AIMap.GetDistanceManhattan(TileA, TileB) - AIMap.DistanceMax(TileA, TileB)) * 0.4 + AIMap.DistanceMax(TileA, TileB))
}