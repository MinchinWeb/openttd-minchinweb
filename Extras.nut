/*	Extra functions v.1 r.97 [2011-04-16],
 *	part of Minchinweb's MetaLibrary v1, r97, [2011-04-16],
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

//	_MetaLib_Extras_.MidPoint(TileA, TileB)

//	_MetaLib_Extras_.Perpendicular(SlopeIn)

function _MetaLib_Extras_::SignLocation(text)
{
//	Returns the tile of the first instance where the sign matches the given text
    local sign_list = AISignList();
    for (local i = sign_list.Begin(); !sign_list.IsEnd(); i = sign_list.Next()) {
        if(AISign.GetName(i) == text)
        {
            return AISign.GetLocation(i);
        }
    }
    return null;
}

