/*	Town Registrar v.1, part of 
 *	WmDOT v.5  r.53a  [2011-04-08]
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/*	The Town Registrar
 *			Registrar - n. someone responsible for keeping records
 *		The Town Registrar keeps track of all things town related and is
 *		responsible to dividing the map into neighbourhoods, providing the town
 *		list to OpDOT, and recording connections make.
 *		No expenditures. No revenue stream.
 */
 
 class TownRegistrar {
	function GetVersion()       { return 1; }
	function GetRevision()		{ return "53a"; }
	function GetDate()          { return "2011-04-08"; }
	function GetName()          { return "Town Registrar"; }
	
	
	
	_NextRun = null;
	
	Log = null;
	
	constructor()
	{
//		this._MaxAtlasSize = 99;
		this._NextRun = 0;
		
		Log = OpLog();
		
		this.State = this.State(this);
	}
}

class TownRegistrar.State {

	_main = null;
	
	function _get(idx)
	{
		switch (idx) {
//			case "Mode":			return this._main._Mode; break;
			case "NextRun":			return this._main._NextRun; break;
//			case "ROI":				return this._main._ROI; break;
//			case "Cost":			return this._main._Cost; break;
			default: throw("The index '" + idx + "' does not exist");
		}
	}
	
	constructor(main)
	{
		this._main = main;
	}
}

function TownRegistrar::LinkUp() 
{
	this.Log = WmDOT.Log;
	Log.Note("Town Registrar Linked Up!",3);
}

function TownRegistrar::Run()
{
	return null;
}