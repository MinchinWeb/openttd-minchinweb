/*	OperationMoney v.1-GS, r.153 [2011-12-07], part of
 *		WmDOT-CS, v.7, r153 [2011-12-07], adapted from
 *		WmDOT v.5  r.53a  [2011-03-28]
 *	Copyright © 2011 by William Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
//	Requires SuperLib v6 or better


 class OpMoney {
	function GetVersion()       { return 1; }
	function GetRevision()		{ return 153; }
	function GetDate()          { return "2011-12-07"; }
	function GetName()          { return "Operation Money"; }
 
	_SleepLength = null;
	//	Controls how many ticks the GS sleeps between iterations.
	_MinBalance = null;
	//	Minimum Bank balance (in GBP - £) to have on hand 
	 
	_NextRun = null;
	
	Log = null;
	 
	constructor()
	{
		this._SleepLength = 50;
		this._MinBalance = 100;
	
		this.Settings = this.Settings(this);
		this.State = this.State(this);
		
		Log = OpLog;
	}
};

class OpMoney.Settings {

	_main = null;
	
	function _set(idx, val)
	{
		switch (idx) {
			case "SleepLength":			this._main._SleepLength = val; break;
			case "MinBalance":			this._main._MinBalance = val; break;
			default: throw("the index '" + idx + "' does not exist");
		}
		return val;
	}
		
	function _get(idx)
	{
		switch (idx) {
			case "SleepLength":			return this._main._SleepLength; break;
			case "MinBalance":			return this._main._MinBalance; break;
			default: throw("the index '" + idx + "' does not exist");
		}
	}
	
	constructor(main)
	{
		this._main = main;
	}
}
 
 class OpMoney.State {

	_main = null;
	
	function _get(idx)
	{
		switch (idx) {
			case "NextRun":			return this._main._NextRun; break;
			default: throw("the index '" + idx + "' does not exist");
		}
	}
	
	constructor(main)
	{
		this._main = main;
	}
}

function OpMoney::LinkUp() 
{
	this.Log = WmDOT_GS.Log;
	Log.Note(this.GetName() + " linked up!",3);
}
 
function OpMoney::Run() {
//	Repays the loan and keeps a small balance on hand
	this._NextRun = GSController.GetTick();
	Log.Note("OpMoney running at tick " + this._NextRun + ".",1);
	this._NextRun += this._SleepLength;
	
	SLMoney.MakeMaximumPayback();
	SLMoney.MakeSureToHaveAmount(this._MinBalance);
	Log.Note("Bank Balance: " + GSCompany.GetBankBalance(GSCompany.ResolveCompanyID(GSCompany.COMPANY_SELF)) + "£, Loan: " + GSCompany.GetLoanAmount() + "£, Keep Minimum Balance of " + this._MinBalance + "£.",2)
 }
 
 function OpMoney::FundsRequest(Amount) {
 //	Makes sure the requested amount is available, taking a loan if available
	Amount = Amount.tointeger();
	Log.Note("Funds Request for " + Amount + "£ received.",3);
	SLMoney.MakeSureToHaveAmount(Amount);
}

function OpMoney::GreaseMoney(Amount = 100) {
//	Designed to keep just enough money onhand to keep from being sold off
	SLMoney.MakeSureToHaveAmount(Amount);
}