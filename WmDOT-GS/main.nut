/*	WmDOT v.7-GS, r.148 [2011-12-03],
 *		adapted from WmDOT (the AI) v.6, r.118 [2011-04-28]
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */

 /*
import("util.MinchinWeb", "MetaLib", 2);
	RoadPathfinder <- MetaLib.RoadPathfinder;
	Array <- MetaLib.Array;
	Fibonacci_Heap <- MetaLib.Fibonacci_Heap;
 import("util.superlib", "SuperLib", 16);		//	For signs
//	SLMoney <- SuperLib.Money;
*/

require("library/SuperLib-GS/main.nut");
require("library/MetaLibrary-GS/main.nut");
//	Metalib <- MinchinWeb;
	RoadPathfinder <- MinchinWeb.RoadPathfinder;
	Array <- MinchinWeb.Array;
	Fibonacci_Heap <- MinchinWeb.Fibonacci_Heap;
	
require("OpDOT.nut");				//	OperationDOT
// require("OpMoney.nut");				//	Operation Money
require("OpLog.nut");				//	Operation Log
require("TownRegistrar.nut");		//	Town Registrar
require("Neighbourhood.nut");		//	Neighbourhood Class	
require("Cleanup.Crew.nut");		//	Cleanup Crew
		

 
 class WmDOT_GS extends GSController 
{
	//	SETTINGS
	WmDOTv = 7;
	/*	Version number of GS
	 */	
	WmDOTr = 142;
	/*	Reversion number of GS
	 */
	 
//	SingleLetterOdds = 7;
	/*	Control on single letter companies.  Set this value higher to increase
	 *	the chances of a single letter DOT name (eg. 'CDOT').		
	 */
	
	//	END SETTINGS
	
	Log = OpLog();
	Towns = TownRegistrar();
//	Money = OpMoney();
	DOT = OpDOT();
	CleanupCrew = OpCleanupCrew();
  
	function Start();
}

/*	TO DO
	- figure out how to get the version number to show up in Start()
 */

function WmDOT_GS::Start()
{
//	For debugging crashes...
	local Debug_2 = "/* Settings: " + GetSetting("DOT_name1") + "-" + GetSetting("DOT_name2") + " - dl" + GetSetting("Debug_Level") + " // OpDOT: " + GetSetting("OpDOT") + " - " + GetSetting("OpDOT_MinTownSize") + " - " + GetSetting("TownRegistrar_AtlasSize") + " - " + GetSetting("OpDOT_RebuildAttempts") + " */" ;
	local Debug_1 = "/* GS v." + WmDOTv + ", r." + WmDOTr + " // " + GSDate.GetYear(GSDate.GetCurrentDate()) + "-" + GSDate.GetMonth(GSDate.GetCurrentDate()) + "-" + GSDate.GetDayOfMonth(GSDate.GetCurrentDate()) + " start // " + GSMap.GetMapSizeX() + "x" + GSMap.GetMapSizeY() + " map - " + GSTown.GetTownCount() + " towns */";
	
//	GSLog.Info("Welcome to WmDOT, version " + GetVersion() + ", revision " + WmDOTr + " by " + GetAuthor() + ".");
	GSLog.Info("Welcome to WmDOT, GameScript Edition, version " + WmDOTv + ", revision " + WmDOTr + " by W. Minchin.");
	GSLog.Info("Copyright © 2011 by W. Minchin. For more info, please visit http://www.tt-forums.net/viewtopic.php?f=65&t=53698")
	GSLog.Info(" ");
	
	Log.Settings.DebugLevel = GetSetting("Debug_Level");
	Log.Note("Loading Libraries...",0);		// Actually, by this point it's already happened

	Log.Note("     " + Log.GetName() + ", v." + Log.GetVersion() + " r." + Log.GetRevision() + "  loaded!",0);
//	Log.Note("     " + Money.GetName() + ", v." + Money.GetVersion() + " r." + Money.GetRevision() + "  loaded!",0);
	Log.Note("     " + DOT.GetName() + ", v." + DOT.GetVersion() + " r." + DOT.GetRevision() + "  loaded!",0);
	Log.Note("     " + Towns.GetName() + ", v." + Towns.GetVersion() + " r." + Towns.GetRevision() + "  loaded!",0);
	Log.Note("     " + CleanupCrew.GetName() + ", v." + CleanupCrew.GetVersion() + " r." + CleanupCrew.GetRevision() + "  loaded!",0);
	StartInfo();		//	AyStarInfo()
						//	RoadPathfinder()
						//	NeighbourhoodInfo()
						//	Fibonacci_Heap_Info()
	Log.Note("",0);
	
	Log.Settings.DebugLevel = GetSetting("Debug_Level");
	TheGreatLinkUp();
		
	if (GetSetting("Debug_Level") == 0) {
		Log.Note("Increase Debug Level in GS settings to get more verbose output.",0);
		Log.Note("",0);
	}
	
	GSRoad.SetCurrentRoadType(GSRoad.ROADTYPE_ROAD);
		//	Build normal road (no tram tracks)
	
//	NameWmDOT();
//	local HQTown = BuildWmHQ();
	local Time;
//	DOT.Settings.HQTown = HQTown;
	DOT.Settings.HQTown = BuildWmHQ();
	
	/* Wait 60 seconds till game starts */
	local now = GSDate.GetSystemTime();

	local comp = GSCompanyMode(0);
	local exec = GSExecMode();
	GSLog.Info("Company " + comp);

	GSViewport.ScrollTo(GSMap.GetTileIndex(48,48));
	GSRoad.BuildRoadDepot(GSMap.GetTileIndex(48,48), GSMap.GetTileIndex(48,49));

	now = GSDate.GetSystemTime();
	while (GSDate.GetSystemTime() - now < 10) {
		this.Sleep(30);
	}

	
	
	while (true) {
		Time = this.GetTick();	
		Log.Settings.DebugLevel = GetSetting("Debug_Level");

//		if (Time > Money.State.NextRun)			{ Money.Run(); }
		if (Time > Towns.State.NextRun)			{ Towns.Run(); }
		if (Time > CleanupCrew.State.NextRun)	{ CleanupCrew.Run(); }
		if (Time > DOT.State.NextRun)			{ DOT.Run(); }

		this.Sleep(1);
		now = GSDate.GetSystemTime();
		while (GSDate.GetSystemTime() - now < 10) {
			this.Sleep(30);
		}
	}
}

function WmDOT_GS::StartInfo()
{
//	By placing classes here that need to be created to get their info, we
//		destroy them right away (which double to clean up the bug report
//		screens and to free up a little bit of memory)
//	local MyAyStar = AyStarInfo();
//	Log.Note("     " + MyAyStar.GetName() + ", v." + MyAyStar.GetVersion() + " r." + MyAyStar.GetRevision() + "  loaded!",0);
	local MyRoadPathfiner = RoadPathfinder();
	Log.Note("     " + MyRoadPathfiner.Info.GetName() + ", v." + MyRoadPathfiner.Info.GetVersion() + " r." + MyRoadPathfiner.Info.GetRevision() + "  loaded!",0);	
	local MyNeighbourhood = NeighbourhoodInfo();
	Log.Note("     " + MyNeighbourhood.GetName() + ", v." + MyNeighbourhood.GetVersion() + " r." + MyNeighbourhood.GetRevision() + "  loaded!",0);
//	local FHI = Fibonacci_Heap_Info();
//	Log.Note("     " + FHI.GetName() + ", v." + FHI.GetVersion() + " r." + FHI.GetRevision() + "  loaded!",0);
}

function WmDOT_GS::BuildWmHQ()
{
	//  TO-DO
	//	- create other options for where to build HQ (random, setting?)
	
	//	There is no check to keep the map co-ordinates from wrapping around the edge of the map
	//	There is a safety in place that if it tries twenty squares in a line in one step, it exits
	
	Log.Note("Building Headquarters...",1)
	
	local tick;
	tick = this.GetTick();
	
//	GSCompany.BuildCompanyHQ(0xA284);
	
	// Gets a list of the towns	
	local WmTownList = GSTownList();

	WmTownList.Valuate(GSTown.GetPopulation);	
	local HQTown = GSTown();	
	HQTown = WmTownList.Begin();
	
	tick = this.GetTick() - tick;
	Log.Note("HQ selected (" + GSTown.GetName(HQTown) + "). Took " + tick + " tick(s).",2);
	return HQTown;
}

function WmDOT_GS::TileIsWhatTown(TileIn)
{
//	Given a tile, returns the town whose influence it falls under
//	Else returns -1 (i.e. under no town's incfluence)
	
	local TestValue = false;
	
	for (local i = 0; i < GSTown.GetTownCount(); i++) {
		TestValue = GSTown.IsWithinTownInfluence(i, TileIn);
//		GSLog.Info("          " + i + ". Testing Town " + " and returns " + TestValue);
		if (TestValue == true) {
			return i;
		}
	}
	
	//	If it get this far, it's not in any town's influence
	return -1;
}

function WmDOT_GS::TheGreatLinkUp()
{
	DOT.LinkUp();
//	Money.LinkUp();
	Towns.LinkUp();
	CleanupCrew.LinkUp();
	Log.Note("The Great Link Up is Complete!",1);
	Log.Note("",1);
}


/*
function TestGS::Save()
 {
   local table = {};	
   //TODO: Add your save data to the table.
   return table;
 }
 
 function TestGS::Load(version, data)
 {
   GSLog.Info(" Loaded");
   //TODO: Add your loading routines.
 }
 */