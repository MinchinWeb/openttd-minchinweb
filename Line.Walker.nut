/*	LineWalker class v.1 r.109 [2011-04-23],
 *	part of Minchinweb's MetaLibrary v1, r109, [2011-04-23],
 *	originally part of WmDOT v.6
 *	Copyright � 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/*	The LineWalker class allows you to define a starting and endpoint, and then
 *		'walk' all the tiles between the two. It was originally part of my Ship
 *		Pathfinder, also part of Minchinweb's MetaLibrary.
 */
 
/*	Functions provided:
 *		MetaLib.LineWalker()
 *		MetaLib.LineWalker.Start(Tile)
 *						  .End(Tile)
 *						  .Slope(Slope)
 *						  .Reset()
 *						  .Restart()
 *						  .Walk()
 *						  .IsEnd()
 *						  .GetStart()
 *						  .GetEnd()
 */
 
//	Plane geometry gets funky things when you don't have an infinity, or by
//		extention, zero (the inverse of infinity) for slopes. To get by the
//		fact integer conversions drop everything past the decimal point
//		(effectively rounding down), slopes are set so that there is a slight
//		inflection point at the 'origin' so that as you move out from the start
//		point, so stay slightly above the 'unchanging' index...
 
class _MetaLib_LW_ {
	_start = null;
	_end = null;
	_slope = null;
	_startx = null;
	_starty = null;
	_endx = null;
	_endy = null;
	_past_end = null;
	_x = null;
	_y = null;
	_dirx = null;
	_current_tile = null;
	_infinity = null;			//	Seperate from Ship pathfinder
	
	constructor()
	{
		this._past_end = true;
//		this._infinity = 10000;	//	close enough to infinity :P
								//	Slopes are capped at 10,000 and 1/10,000
		this._infinity = 10;	//	For Testing
	}
}

function _MetaLib_LW_::Start(Tile)
{
//	Sets the starting tile for LineWalker
	this._start = Tile;
	this._startx = AIMap.GetTileX(Tile);
	this._starty = AIMap.GetTileY(Tile);
	this._x = this._startx;
	this._y = this._starty;	
	this._past_end = false;
	this._current_tile = AIMap.GetTileIndex(this._x, this._y);
	this._x = this._x.tofloat();
	this._y = this._y.tofloat();
	
	if (this._end != null) {
		if (this._slope == null) {
			this._slope = _MetaLib_Extras_.Slope(this._start, this._end, this._infinity);
		}
		
		if (this._startx < this._endx) {
			this._dirx = 1;
		} else if (this._startx > this._endx) {
			this._dirx = -1;
		} else {
		//	startX == EndX
			this._dirx = 1;
			this._endx = this._endx.tofloat() + (1.0 - (1.0 / this._infinity));	
		}
		
		if (this._starty == this._endy) {
			if (this._startx > this._endx) {
				this._dirx = 1;
			} else {
				this._dirx = -1;
			}
			this._endy = this._endy.tofloat() + (1.0 - (1.0 / this._infinity));
		}
	}
	
	AILog.Info("    LineWalker.Start out: " + this._startx + " " + this._starty + " m" + this._slope + " � " + this._dirx);
}

function _MetaLib_LW_::End(Tile)
{
//	Sets the ending tile for LineWalker
//	If the slope is also directly set, the start and end tiles define a bounding box
	this._end = Tile;
	this._endx = AIMap.GetTileX(Tile);
	this._endy = AIMap.GetTileY(Tile);
	
	if (this._start != null) {
		if (this._slope == null) {
			this._slope = _MetaLib_Extras_.Slope(this._start, this._end, this._infinity);
		}
		
		if (this._startx < this._endx) {
			this._dirx = 1;
		} else if (this._startx > this._endx) {
			this._dirx = -1;
		} else {
		//	startX == EndX
			this._dirx = 1;
			this._endx = this._endx.tofloat() + (1.0 - (1.0 / this._infinity));	
		}
		
		if (this._starty == this._endy) {
			this._endy = this._endy.tofloat() + (1.0 - (1.0 / this._infinity));
			this._slope *= -1.0;
		}
	}
	
	AILog.Info("    LineWalker.End out: " + this._endx + " " + this._endy + " m" + this._slope + " � " + this._dirx);
}

function _MetaLib_LW_::Slope(Slope, ThirdQuadrant = false)
{
//	Sets the slope for LineWalker
//	Assumes that the slope is in the first or second quadrant until ThirdQuadrant == true

	if (_MetaLib_Extras_.AbsFloat(Slope) > this._infinity) {
		AILog.Warning("Slope is capped at " + this._infinity + ", you provided " + Slope + ".");
		this._slope = this._infinity;
	} else if (_MetaLib_Extras_.AbsFloat(Slope) < (1.0 / this._infinity)) {
		AILog.Warning("Slope is capped at " + (1 / this._infinity) + ", you provided " + Slope + ".");
		this._slope = (1.0 / this._infinity);
	} else {
		this._slope = Slope;
	}
	
	if (this._slope > 0.0) {
//		this._endy = this._infinity;
		this._endy = AIMap.GetMapSizeY();
	} else {
//		this._endy = -1 * this._infinity;
		this._endy = 0;
	}
	
	if (ThirdQuadrant == false) {
		this._dirx = -1;		//	+1
//		this._endx = this._infinity;
		this._endx = AIMap.GetMapSizeX();
	} else {
		this._dirx = 1;	//	-1
		this._x += (1.0 - (1.0 / this._infinity));
//		this._endx = -1 * this._infinity;
//		this._endy = -1 * this._endy;
		this._endx = 0;
		if (this._endy == 0) {
			this._endy = AIMap.GetMapSizeY();
		} else {
			this._endy = 0;
		}
	}
	
	AILog.Info("   LineWalker.Slope out: " + Slope + " " + ThirdQuadrant + " : " + this._endx + " " + this._endy + " " + this._slope + " � " + this._dirx);
}

function _MetaLib_LW_::Reset()
{
//	resets the variables for the Linewalker
	this._start = null;
	this._end = null;
	this._slope = null;
	this._startx = null;
	this._starty = null;
	this._endx = null;
	this._endy = null;
	this._past_end = true;
	this._x = null;
	this._y = null;
	this._current_tile = null;
	this._dirx = null;
}

function _MetaLib_LW_::Restart()
{
//	Moves the LineWalker to the orginal starting position
	this._x = this._startx.tofloat();
	this._y = this._starty.tofloat();
	this._past_end = false;
	this._current_tile = AIMap.GetTileIndex(this._x.tointeger(), this._y.tointeger());
}

//	=== LineWalker Walk ===
//		This is where (most) of the action is!

function _MetaLib_LW_::Walk()
{
//	'Walks' the LineWalker one tile at a tile
	if (this._past_end == true) {
//		return false;
		return this._current_tile;
	}
	
	if ((AIMap.DistanceManhattan(this._current_tile, AIMap.GetTileIndex(this._x.tointeger(), this._y.tointeger())) == 1 ) && _MetaLib_Extras_.WithinFloat(this._startx.tofloat(), this._endx.tofloat(), this._x.tointeger()) &&_MetaLib_Extras_.WithinFloat(this._starty.tofloat(), this._endy.tofloat(), this._y.tointeger())) {
		this._current_tile = AIMap.GetTileIndex(this._x.tointeger(), this._y.tointeger());
		AILog.Info("Linewalker output " + AIMap.GetTileX(this._current_tile) + "," + AIMap.GetTileY(this._current_tile) + " from " + this._x + "," + this._y );
		return this._current_tile;
	}
	
	//	this._infinity assumed to be 10,000
	local multiplier = 0.0;
	
//	multiplier = _MetaLib_Extras_.MinAbsFloat(1.0, _MetaLib_Extras_.Perpendicular(this._slope));
	multiplier = _MetaLib_Extras_.MinAbsFloatKeepSign(this._dirx, _MetaLib_Extras_.Perpendicular(this._slope));
	
	local NewX = 0.0;
	local NewY = 0.0;
	NewX = this._x + multiplier;
	NewY = this._y + this._slope * multiplier;
//	AILog.Info("Linewalker new : " + NewX + "," + NewY);
	
	if (AIMap.DistanceManhattan(this._current_tile, AIMap.GetTileIndex(NewX.tointeger(), NewY.tointeger())) == 1 ) {
		this._current_tile = AIMap.GetTileIndex(NewX.tointeger(), NewY.tointeger());
	} else if (AIMap.DistanceManhattan(this._current_tile, AIMap.GetTileIndex(NewX.tointeger(), this._y.tointeger())) == 1 ) {
		this._current_tile = AIMap.GetTileIndex(NewX.tointeger(), this._y.tointeger());
	}
	
	this._x = NewX;
	this._y = NewY;
	
	//	Check that we're still within our bounding box
//	AILog.Info("    " + this._startx + " , " + this._endx + " , " + this._x.tointeger() + " , " + this._starty + " , " + this._endy + " , " + this._y.tointeger());
	
//	if ((_MetaLib_Extras_.WithinFloat(this._startx, this._endx, this._x.tointeger()) == false) || (_MetaLib_Extras_.WithinFloat(this._starty, this._endy, this._y.tointeger()) == false)) {
//		AILog.Info("Linewalker outside box " + this._startx + " " + this._endx + " " + this._x + " " + _MetaLib_Extras_.WithinFloat(this._startx, this._endx, this._x.tointeger()) + " : " + this._starty + " " + this._endy + " " + this._y + " " + (_MetaLib_Extras_.WithinFloat(this._starty, this._endy, this._y.tointeger())));
	if (!_MetaLib_Extras_.WithinFloat(this._startx.tofloat(), this._endx.tofloat(), this._x) || !_MetaLib_Extras_.WithinFloat(this._starty.tofloat(), this._endy.tofloat(), this._y)) {
		AILog.Info("Linewalker outside box " + this._startx + " " + this._endx + " " + this._x + " " + _MetaLib_Extras_.WithinFloat(this._startx.tofloat(), this._endx.tofloat(), this._x) + " : " + this._starty + " " + this._endy + " " + this._y + " " + (_MetaLib_Extras_.WithinFloat(this._starty.tofloat(), this._endy.tofloat(), this._y)));
		this._past_end = true;
		return this._current_tile;
	} else {
		AILog.Info("Linewalker output " + AIMap.GetTileX(this._current_tile) + "," + AIMap.GetTileY(this._current_tile) );
		return this._current_tile;
	}
}

function _MetaLib_LW_::IsEnd()
{
//	Returns true if we are at the edge of the bounding box defined by the Starting and Ending point
	return this._past_end;
}

function _MetaLib_LW_::GetStart()
{
//	Returns the tile the LineWalker is starting on
	return this._start;
}

function _MetaLib_LW_::GetEnd()
{
//	Returns the tile the LineWalker is starting on
	return this._end;
}