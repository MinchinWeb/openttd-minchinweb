﻿/*	Ship Manager v.1, r.238, [2012-06-21]
 *		part of WmDOT v.10
 *	Copyright © 2012 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
/*	Ship Manager takes existing ship routes and add and deletes ships as needed.
 */
 
class ManShips {
	function GetVersion()       { return 1; }
	function GetRevision()		{ return 238; }
	function GetDate()          { return "2012-06-21"; }
	function GetName()          { return "Ship Manager"; }
	
	
	_NextRun = null;
	_SleepLength = null;	//	as measured in days
	_AllRoutes = null;
	
	Log = null;
	Money = null;
	
	constructor()
	{
		this._NextRun = 0;
		this._SleepLength = 30;
		this._AllRoutes = [];
		
		this.Settings = this.Settings(this);
		this.State = this.State(this);
		Log = OpLog();
		Money = OpMoney();
	}
}

class Route {
	_EngineID = null;			// ID of Ship
	_Capacity = null;			// in tons
	_Cargo = null;				// what do we carry
	_SourceStation = null;		// StationID of where cargo is picked up
	_Depot = null;				// TileID of depot
	_LastUpdate = null;			// last time (in ticks) that the route was updated
}

class ManShips.Settings {

	_main = null;
	
	function _set(idx, val)
	{
		switch (idx) {
			case "SleepLength":			this._main._SleepLength = val; break;

			default: throw("The index '" + idx + "' does not exist");
		}
		return val;
	}
		
	function _get(idx)
	{
		switch (idx) {
			case "SleepLength":			return this._main._SleepLength; break;

			default: throw("The index '" + idx + "' does not exist");
		}
	}
	
	constructor(main)
	{
		this._main = main;
	}
}
 
class ManShips.State {

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

function ManShips::LinkUp() 
{
	this.Log = WmDOT.Log;
	this.Money = WmDOT.Money;

	Log.Note(this.GetName() + " linked up!",3);
}

 
function ManShips::Run() {
	Log.Note("Ship Manager running at tick " + WmDOT.GetTick() + ".",1);
	
	//	reset counter
	this._NextRun = WmDOT.GetTick() + this._SleepLength * 17;
	
	for (local i=0; i < this._AllRoutes.len(); i++) {
		//	Add Ships
		Log.Note("Considering Route #" + i + "... " + AIStation.GetCargoWaiting(this._AllRoutes[i]._SourceStation, this._AllRoutes[i]._Cargo) + " > " + this._AllRoutes[i]._Capacity + " ? " +(AIStation.GetCargoWaiting(this._AllRoutes[i]._SourceStation, this._AllRoutes[i]._Cargo) > this._AllRoutes[i]._Capacity),3);
		if (AIStation.GetCargoWaiting(this._AllRoutes[i]._SourceStation, this._AllRoutes[i]._Cargo) > this._AllRoutes[i]._Capacity) {
			Money.FundsRequest(AIEngine.GetPrice(AIVehicle.GetEngineType(this._AllRoutes[i]._EngineID)) * 1.1);
			local MyVehicle;
			MyVehicle = AIVehicle.CloneVehicle(this._AllRoutes[i]._Depot, this._AllRoutes[i]._EngineID, true);
			AIVehicle.StartStopVehicle(MyVehicle);
			Log.Note("New Vehicle Added: " + MyVehicle, 4);
			this._AllRoutes[i]._LastUpdate = WmDOT.GetTick();
//		} else {
			//  Delete extra ships
			//	if there are three ships waiting at to fill up, delete them
			
		}
	}
}

function ManShips::AddRoute (ShipID, CargoNo)
{
	local TempRoute = Route();
	TempRoute._EngineID = ShipID;
	TempRoute._Capacity = AIVehicle.GetCapacity(ShipID, CargoNo);
	TempRoute._Cargo = CargoNo;
	for (local i=0; i < AIOrder.GetOrderCount(ShipID); i++) {
		if (AIOrder.IsGotoStationOrder(ShipID, i) == true) {
			TempRoute._SourceStation = AIStation.GetStationID(AIOrder.GetOrderDestination(ShipID, i));
			TempRoute._Depot = Marine.NearestDepot(AIOrder.GetOrderDestination(ShipID, i));
			i = 1000;	//break
		}
	}
//	TempRoute._Depot = Marine.NearestDepot(TempRoute._SourceStation);
	TempRoute._LastUpdate = WmDOT.GetTick();
	
	this._AllRoutes.push(TempRoute);
	Log.Note("Route added! Ship " + TempRoute._EngineID + "; " + TempRoute._Capacity + " tons of " + AICargo.GetCargoLabel(TempRoute._Cargo) + "; starting at " + TempRoute._SourceStation + "; build at " + TempRoute._Depot + "; updated at tick " + TempRoute._LastUpdate + ".", 4);
}



