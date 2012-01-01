/*	WmBasic v.1  r.1
 *	Created by William Minchin		w_minchin@hotmail.com		http://blog.minchin.ca
 */
 
//	This is to test the Atlas in MinchinWeb's MetaLibrary v.2
//		This assumes there are at least 4 towns on the map
 
 
import("util.MinchinWeb", "MetaLib", 2);
//	RoadPathfinder <- MetaLib.RoadPathfinder;
	Array <- MetaLib.Array;
//	LineWalker <- MetaLib.LineWalker;
	Atlas <- MetaLib.Atlas;

/*
enum ModelType
{
	ONE_D,					// 0
	DISTANCE_MANHATTAN,		// 1
	DISTANCE_SHIP,			// 2
	DISTANCE_AIR,			// 3
	DISTANCE_NONE,			// 4
	ONE_OVER_T_SQUARED,		// 5
};
*/

class WmBasic extends AIController 
{
	//	SETTINGS
	WmBasicv = 1;
	/*	Version number of AI
	 */	
	WmBasicr = 4;
	/*	Reversion number of AI
	 */
	 
	SleepLength = 500;
	/*	Controls how many ticks the AI sleeps between iterations.
	 */
	 
	//	END SETTINGS
  
  function Start();
}

function WmBasic::Start()
{
	AILog.Info("Welcome to WmBasic, version " + WmBasicv + ", revision " + WmBasicr + " by William Minchin.");
	AILog.Info("Copyright © 2011 by William Minchin. For more info, please visit http://blog.minchin.ca")
	AILog.Info(" ");
	
	local towns = AITownList();
	towns.Valuate(AITown.GetPopulation);
//	towns.Sort(SORT_ASCENDING, true);
	
	local town1 = towns.Begin();
	local town2 = towns.Next();
	local town3 = towns.Next();
	local town4 = towns.Next();
	
	AILog.Info(town1 + " : " + town2 + " : " + town3 + " : " + town4);
	AILog.Info(AITown.GetName(town1) + " : " + AITown.GetName(town2) + " : " + AITown.GetName(town3) + " : " + AITown.GetName(town4));
	
	AILog.Info(AITown.TOWN_ACTION_ADVERTISE_SMALL);
//	AILog.Info(ONED);
//	AILog.Info(Atlas.PrintModelType(MetaLib.ONED));
	
	local MyAtlas = Atlas();
	MyAtlas.AddSource(AITown.GetLocation(town1),AITown.GetPopulation(town1));
	MyAtlas.AddSource(AITown.GetLocation(town2),AITown.GetPopulation(town2));
	MyAtlas.AddAttraction(AITown.GetLocation(town3),AITown.GetPopulation(town3));
	MyAtlas.AddAttraction(AITown.GetLocation(town4),AITown.GetPopulation(town4));
	
	local temp;
	
	for (local MyModel=0; MyModel<6; MyModel++) {
		MyAtlas.SetModel(MyModel);
		
		AILog.Info(" ");
	//	AILog.Info("     " + Atlas.PrintModel(MyModel));
		AILog.Info("     Model: " + MyModel); 
		MyAtlas.RunModel();
		
		while (MyAtlas.Count() > 0) {
			temp = MyAtlas.Pop();
			AILog.Info("     " + Array.ToStringTiles1D([temp[0]]) + " -> " + Array.ToStringTiles1D([temp[1]]) + " : " + Atlas.ApplyTrafficModel(AITown.GetLocation(temp[0]), AITown.GetPopulation(temp[0]), AITown.GetLocation(temp[1]), AITown.GetPopulation(temp[1]), MyModel));
			// The above fails, becuase GetPopulation is fed a TileIndex, rather than a TownID, and so returns -1
		}
	}
	
	
	
	
	
	// Keep us going forever
	while (true) {
		AILog.Info("Help! I haven't done anything yet and I'm already at tick " + this.GetTick());
		AILog.Info("-----------------------------------------------------");
		AILog.Info(" ");

		this.Sleep(SleepLength);
	}
}