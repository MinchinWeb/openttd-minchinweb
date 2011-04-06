/*	WmTest v.1  r.1
 *	Copyright © 2011 by William Minchin. For more info, please visit
 * 		http://openttd-noai-wmdot.googlecode.com/
 */

//	SPEED TESTS ON THE ROAD PATHFINDER
//	Running just Test1 (straight line) or Test2 (right angle) on flat ground 
//		seems to suggest that most of the time is spent in overhead. Runs about
//		1000 cycles in 75 ticks.
//	Running alternating patterns of Test2 and then Test3 (build road - straight)
//		gives less steady results. The first run of Test2 is as fast as above,
//		but subsiquent runs can vary from 300 to 4500 ticks for 10 runs (most 
//		in the 350-450 range). Test3 runs at a more steady 130-150 ticks for 10
//		runs.
//	Need to test building angle roads...
 
 
 
//	Road pathfinder as provided by the NoAI team
		import("pathfinder.road", "RoadPathFinder", 3);
		
require("GNU_FDL.nut");
		
class WmTest extends AIController 
{
	//	SETTINGS
	WmTestv = 1;
	/*	Version number of AI
	 */	
	WmTestr = 1;
	/*	Reversion number of AI
	 */
	 
	SleepLength = 10;
	/*	Controls how many ticks the AI sleeps between iterations.
	 */
	 
	//	END SETTINGS
  
  function Start();
}

function WmTest::Start()
{
	AILog.Info("Welcome to WmTest, version " + WmTestv + ", revision " + WmTestr + " by William Minchin.");
	AILog.Info("Copyright © 2011 by William Minchin. For more info, please visit http://openttd-noai-wmdot.googlecode.com/")
	AILog.Info(" ");
	
	// Keep us going forever
	while (true) {
		local Cycles = WmTest.GetSetting("Test_Cycles");
		Cycles = Cycles;
		local GridSize = WmTest.GetSetting("Grid_Spacing");
		AILog.Info("-----------------------------------------------------");
		AILog.Info("Starting Pathfinder Test. " + Cycles + " cycles on a " + GridSize + " grid.");
		local tick = this.GetTick();
		for (local i = 0; i < Cycles; i++) {
//			TestLoop1();
			TestLoop2();
//			TestLoop3();
		}
		tick = this.GetTick() - tick;
		local Result;
		Result = (Cycles * GridSize + 0.001) / (tick + 0.001);
//		AILog.Info("Took " + tick + " ticks. That equals " + Result + " squares per tick.");
		AILog.Info("Test Loop 2 took " + tick + " ticks. That equals " + Result + " squares per tick.");
		
		tick = this.GetTick();
		for (local i = 0; i < Cycles; i++) {
			TestLoop3();
		}
		tick = this.GetTick() - tick;
		local Result;
		Result = (Cycles * GridSize + 0.001) / (tick + 0.001);
//		AILog.Info("Took " + tick + " ticks. That equals " + Result + " squares per tick.");
		AILog.Info("Test Loop 3 took " + tick + " ticks. That equals " + Result + " squares per tick.");
		AILog.Info("-----------------------------------------------------");
		AILog.Info(" ");

		this.Sleep(SleepLength);
	}
}

function WmTest::TestLoop1()
{
//	Runs in a straight line
//	The time this takes to run seems to be based mostly on the overhead of
//		setting up the pathfinder, etc.
//	Runs 1000 cycles in 75 ticks.

	local pathfinder = RoadPathFinder();
	local GridSize = WmTest.GetSetting("Grid_Spacing");
	local StartX = (AIBase.RandRange(AIMap.GetMapSizeX() - 6)) + 3;
	local StartY = (AIBase.RandRange(AIMap.GetMapSizeY() - 6)) + 3;
	local dx = 0;
	local dy = 0;
	local dxy = AIBase.RandRange(4);
	switch (dxy) {
		case 0:
			dx = 1;
			break;
		case 1:
			dy = 1;
			break;
		case 2:
			dx = -1;
			break;
		case 3:
			dy = -1;
			break;
	}
	if (((StartX + dx*GridSize) < 0) || ((StartX + dx*GridSize) > AIMap.GetMapSizeX()))  {
		dx = -dx;
	}
		if (((StartY + dy*GridSize) < 0) || ((StartY + dy*GridSize) > AIMap.GetMapSizeY()))  {
		dy = -dy;
	}
//	AILog.Info("     Going from " + StartX + "," + StartY + " to " + (StartX + dx*GridSize) + "," + ((StartY + dy*GridSize)) + ". At tick " + this.GetTick());
	local TileStart = AITile();
	local TileEnd = AITile();
	TileStart = AIMap.GetTileIndex(StartX, StartY);
	TileEnd = AIMap.GetTileIndex(StartX + dx*GridSize, StartY + dy*GridSize);

	pathfinder.InitializePath([TileStart], [TileEnd]);
	local path = false;
	while (path == false) {
		path = pathfinder.FindPath(1000);
//		AIController.Sleep(1);
		AILog.Info("     Pathfinding...");
	}
	
	return;
}

function WmTest::TestLoop2()
{
//	Runs in a right angle
//	Runs at the same speed as above

	local pathfinder = RoadPathFinder();
	local GridSize = WmTest.GetSetting("Grid_Spacing");
	local StartX = (AIBase.RandRange(AIMap.GetMapSizeX() - 6)) + 3;
	local StartY = (AIBase.RandRange(AIMap.GetMapSizeY() - 6)) + 3;
	local dx = 0;
	local dy = 0;
	local dxy = AIBase.RandRange(4);
	switch (dxy) {
		case 0:
			dx = 1;
			dy = 1;
			break;
		case 1:
			dx = -1;
			dy = 1;
			break;
		case 2:
			dx = 1;
			dy = -1;
			break;
		case 3:
			dx = -1;
			dy = -1;
			break;
	}
	if (((StartX + dx*GridSize) < 0) || ((StartX + dx*GridSize) > AIMap.GetMapSizeX()))  {
		dx = -dx;
	}
		if (((StartY + dy*GridSize) < 0) || ((StartY + dy*GridSize) > AIMap.GetMapSizeY()))  {
		dy = -dy;
	}
//	AILog.Info("     Going from " + StartX + "," + StartY + " to " + (StartX + dx*GridSize) + "," + ((StartY + dy*GridSize)) + ". At tick " + this.GetTick());
	local TileStart = AITile();
	local TileEnd = AITile();
	TileStart = AIMap.GetTileIndex(StartX, StartY);
	TileEnd = AIMap.GetTileIndex(StartX + dx*GridSize, StartY + dy*GridSize);

	pathfinder.InitializePath([TileStart], [TileEnd]);
	local path = false;
	while (path == false) {
		path = pathfinder.FindPath(1000);
//		AIController.Sleep(1);
//		AILog.Info("     Pathfinding...");
	}
	
	return;
}

function WmTest::TestLoop3()
{
//	Runs in a straight line and actaully builds the road

	local pathfinder = RoadPathFinder();
	local GridSize = WmTest.GetSetting("Grid_Spacing");
	local StartX = (AIBase.RandRange(AIMap.GetMapSizeX() - 6)) + 3;
	local StartY = (AIBase.RandRange(AIMap.GetMapSizeY() - 6)) + 3;
	local dx = 0;
	local dy = 0;
	local dxy = AIBase.RandRange(4);
	switch (dxy) {
		case 0:
			dx = 1;
			break;
		case 1:
			dy = 1;
			break;
		case 2:
			dx = -1;
			break;
		case 3:
			dy = -1;
			break;
	}
	if (((StartX + dx*GridSize) < 0) || ((StartX + dx*GridSize) > AIMap.GetMapSizeX()))  {
		dx = -dx;
	}
		if (((StartY + dy*GridSize) < 0) || ((StartY + dy*GridSize) > AIMap.GetMapSizeY()))  {
		dy = -dy;
	}
	AILog.Info("     Going from " + StartX + "," + StartY + " to " + (StartX + dx*GridSize) + "," + ((StartY + dy*GridSize)) + ". At tick " + this.GetTick());
	local TileStart = AITile();
	local TileEnd = AITile();
	TileStart = AIMap.GetTileIndex(StartX, StartY);
	TileEnd = AIMap.GetTileIndex(StartX + dx*GridSize, StartY + dy*GridSize);

	BuildRoad([TileStart, TileEnd]);
	
	return;
}


