/*	LineWalker class v.1 r.99 [2011-04-18],
 *	part of Minchinweb's MetaLibrary v1, r99, [2011-04-18],
 *	originally part of WmDOT v.6
 *	Copyright © 2011 by W. Minchin. For more info,
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
 */
 
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
	_current_tile = null;
	
	constructor()
	{
		this._past_end = true;
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
	if ((this._slope == null) && (this._end != null)) {
		this.Slope(_MetaLib_Extras_.Slope(this._start, this._end));
	}
}

function _MetaLib_LW_::End(Tile)
{
//	Sets the ending tile for LineWalker
//	If the slope is also directly set, the start and end tiles define a bounding box
	this._end = Tile;
	this._endx = AIMap.GetTileX(Tile);
	this._endy = AIMap.GetTileY(Tile);
	if ((this._slope == null) && (this._start != null)) {
		this.Slope(_MetaLib_Extras_.Slope(this._start, this._end));
	}
}

function _MetaLib_LW_::Slope(Slope)
{
//	Sets the slope for LineWalker
	if (Slope > _MetaLib_Extras_._infinity) {
		AILog.Warning("Slope is capped at " + _MetaLib_Extras_._infinity + ", you provided " + Slope + ".");
		Slope = _MetaLib_Extras_._infinity;
	}
	if (Slope < (1 / _MetaLib_Extras_._infinity)) {
		AILog.Warning("Slope is capped at " + (1 / _MetaLib_Extras_._infinity) + ", you provided " + Slope + ".");
		Slope = (1 / _MetaLib_Extras_._infinity);
	}
	
	this._slope = Slope;
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
}

function _MetaLib_LW_::Restart()
{
//	Moves the LineWalker to the orginal starting position
	this._x = this._startx;
	this._y = this._starty;
	this._past_end = false;
	this._current_tile = AIMap.GetTileIndex(this._x, this._y);
}

function _MetaLib_LW_::Walk()
{
//	'Walks' the LineWalker one tile at a tile
	if (this._past_end == true) {
		return false;
	}
	
	if (AIMap.DistanceManhattan(this._current_tile, AIMap.GetTileIndex(this._x.tointeger(), this._y.tointeger())) == 1 ) {
		this._current_tile = AIMap.GetTileIndex(this._x.tointeger(), this._y.tointeger());
		return this._current_tile;
	}
	
	//	_MetaLib_Extras_._infinity assumed to be 10,000
	local RightAngle = _MetaLib_Extras_.Perpendicular(this._slope);
	local multiplier = min(this._slope, RightAngle);
	
	local NewX = this._x + multiplier;
	local NewY = this._y + this._slope * multiplier;
	
	if (AIMap.DistanceManhattan(this._current_tile, AIMap.GetTileIndex(NewX.tointeger(), this._y.tointeger())) == 1 ) {
		this._current_tile = AIMap.GetTileIndex(NewX.tointeger(), this._y.tointeger());

	} else if (AIMap.DistanceManhattan(this._current_tile, AIMap.GetTileIndex(NewX.tointeger(), NewY.tointeger())) == 1 ) {
		this._current_tile = AIMap.GetTileIndex(NewX.tointeger(), NewY.tointeger());
	}
	
	this._x = NewX;
	this._y = NewY;
	
	//	Check that we're still within our bounding box
	if (_MetaLib_Extras_.Within(this._startx, this._endx, this._x) == false) || (_MetaLib_Extras_.Within(this._starty, this._endy, this._y) == false) {
		this._past_end = true;
		return false;
	} else {
		return this._current_tile;
	}
}

function _MetaLib_LW_::IsEnd()
{
//	Returns true if we are at the edge of the bounding box defined by the Starting and Ending point
	return this._past_end;
}

