/*	Extra functions v.1 r.103 [2011-04-19],
 *	part of Minchinweb's MetaLibrary v1, r103, [2011-04-19],
 *	originally part of WmDOT v.6
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/*	These are 'random' functions that didn't seem to fit well elsewhere.
 *
 *	Functions provided:
 *		MetaLib.Extras.DistanceShip(TileA, TileB)
 *					  .SignLocation(text)
 *					  .MidPoint(TileA, TileB)
 *					  .Perpendicular(SlopeIn)
 *					  .Slope(TileA, TileB)
 *					  .Within(Bound1, Bound2, Value)
 *					  .MinAbsFloat(Value1, Value2)
 *					  .MaxAbsFloat(Value1, Value2)
 *					  .AbsFloat(Value)
 *					  .Sign(Value)
 */
 
class _MetaLib_Extras_ {
	_infinity = null;
	
	constructor()
	{
		this._infinity = 10000;	//	close enough to infinity :P
								//	Slopes are capped at 10,000 and 1/10,000
	}
	
}

function _MetaLib_Extras_::DistanceShip(TileA, TileB)
{
//	Assuming open ocean, ship in OpenTTD will travel 45° angle where possible,
//		and then finish up the trip by going along a cardinal direction
	return ((AIMap.DistanceManhattan(TileA, TileB) - AIMap.DistanceMax(TileA, TileB)) * 0.4 + AIMap.DistanceMax(TileA, TileB))
}

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

function _MetaLib_Extras_::MidPoint(TileA, TileB)
{
//	Returns the tile that is halfway between the given tiles
	local X = (AIMap.GetTileX(TileA) + AIMap.GetTileX(TileB)) / 2 + 0.5;
	local Y = (AIMap.GetTileY(TileA) + AIMap.GetTileY(TileB)) / 2 + 0.5;
		//	the 0.5 is to make rounding work
	X = X.tointeger();
	Y = Y.tointeger();
	return AIMap.GetTileIndex(X, Y);
}

function _MetaLib_Extras_::Perpendicular(SlopeIn)
{
//	Returns the Perdicular slope, which is the inverse of the given slope
	if (SlopeIn == 0) {
		return this._infinity;
	} else {
		SlopeIn = SlopeIn.tofloat();
		return (-1 / SlopeIn);
	}
}

function _MetaLib_Extras_::Slope(TileA, TileB)
{
//	Returns the slope between two tiles
	local dx = AIMap.GetTileX(TileA) - AIMap.GetTileX(TileB);
	local dy = AIMap.GetTileY(TileA) - AIMap.GetTileY(TileB);
	
	//	Zero check
	if (dx == 0) {
		return this._infinity * _MetaLib_Extras_.Sign(dy);
	} else if (dy == 0) {
		return (1.0 / this._infinity) * _MetaLib_Extras_.Sign(dx);
	} else {
		dx = dx.tofloat();
		dy = dy.tofloat();

		return (dx / dy);	
	}
}


function _MetaLib_Extras_::Within(Bound1, Bound2, Value)
{
	local UpperBound = max(Bound1, Bound2);
	local LowerBound = min(Bound1, Bound2);

	return ((Value <= UpperBound) && (Value >= LowerBound));
}

function _MetaLib_Extras_::MinAbsFloat(Value1, Value2)
{
//	Takes the absolute value of both numbers and then returns the smaller of the two
	if (Value1 < 0) { Value1 = Value1 * -1.0; }
	if (Value2 < 0) { Value2 = Value2 * -1.0; }
	if (Value1 < Value2) {
		return Value1;
	} else {
		return Value2;
	}
}

function _MetaLib_Extras_::MaxAbsFloat(Value1, Value2)
{
//	Takes the absolute value of both numbers and then returns the larger of the two
	if (Value1 < 0) { Value1 = Value1 * -1.0; }
	if (Value2 < 0) { Value2 = Value2 * -1.0; }
	if (Value1 > Value2) {
		return Value1;
	} else {
		return Value2;
	}
}

function _MetaLib_Extras_::AbsFloat(Value)
{
//	Returns the absolute Value as a floating number if one is provided
	if (Value > 0) {
		return Value;
	} else {
		return (Value * (-1.0));
	}
}

function _MetaLib_Extras_::Sign(Value)
{
//	Returns +1 if the Value >= 0, -1 Value < 0
	if (Value >= 0) {
		return 1;
	} else {
		return -1;
	}
}