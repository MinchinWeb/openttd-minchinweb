/*	Logging Interface v.2, part of 
 *	WmDOT v.4  r.44  [2011-03-30]
 *	Copyright © 2011 by William Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
//	Requires SuperLib v6 or better


 class OpLog {
	function GetVersion()       { return 2; }
	function GetRevision()		{ return 44; }
	function GetDate()          { return "2011-03-30"; }
	function GetName()          { return "Logging Interface"; }
 
	_DebugLevel = null;
	//	How much is output to the AIDebug Screen
	//	0 - run silently
	//	1 - only that the mode is running and the town pair it tries to join
	//	2 - 'normal' debugging - each step
	//	3 - substep
	//	4 - most verbose (including arrays)
	 
	constructor()
	{
		this._DebugLevel = 1;
	
		this.Settings = this.Settings(this);
	}
};

class OpLog.Settings {

	_main = null;
	
	function _set(idx, val)
	{
		switch (idx) {
			case "DebugLevel":			this._main._DebugLevel = val; break;
			default: throw("the index '" + idx + "' does not exist");
		}
		return val;
	}
		
	function _get(idx)
	{
		switch (idx) {
			case "DebugLevel":			return this._main._DebugLevel; break;
			default: throw("the index '" + idx + "' does not exist");
		}
	}
	
	constructor(main)
	{
		this._main = main;
	}
 };
 
  
function OpLog::Note(Message, Level=3) {
//	Displays the message if the Debug level is set high enough
	if (Level <= this._DebugLevel) {
		AILog.Info(Message);
	}
 }
 
 function OpLog::Warning(Message) {
	AILog.Warning(Message);
 }
 
 function OpLog::Error(Message) {
	AILog.Error(Message);
 }