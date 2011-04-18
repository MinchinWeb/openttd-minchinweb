/*	WmBasic v.1  r.100
 *	Created by W. Minchin
 */
 
import("util.MetaLib", "MetaLib", 1);
import("util.SuperLib", "SuperLib", 7);
 
class WmShipPFTest extends AIController 
{
	//	SETTINGS
	WmBasicv = 1;
	/*	Version number of AI
	 */	
	WmBasicr = 100;
	/*	Reversion number of AI
	 */
	 
	SleepLength = 5;
	/*	Controls how many ticks the AI sleeps between iterations.
	 */
	 
	//	END SETTINGS
  
  function Start();
}

function WmShipPFTest::Start()
{
	AILog.Info("Welcome to WmBasic, version " + WmBasicv + ", revision " + WmBasicr + " by W. Minchin.");
	AILog.Info("Copyright © 2011 by W. Minchin. For more info, please visit http://blog.minchin.ca")
	AILog.Info(" ");
	AILog.Info("This AI is to test the Ship Pathfinder in MinchinWeb's MetaLibrary. To perform the test,");
	AILog.Info("switch to the AI Company (use the cheat command) and place a 'Start' and 'End' sign. Place");
	AILog.Info("a sign 'Mode WBC' if you want to test Waterbody Check rather than the Ship Pathfinder.")
	AILog.Info(" ");
	
	// Keep us going forever
	local Start;
	local End;
	local Mode = 1;
	local tick;
	
	AISign.BuildSign(0x9D6E, "Start");
	AISign.BuildSign(0x9A6F, "End");
	
	
	while (true) {
		Start = MetaLib.Extras.SignLocation("Start");
		End = MetaLib.Extras.SignLocation("End");
		if (SuperLib.Helper.HasSign("Mode WBC")) {
			Mode = 2;
		}
		
		if ( (Start != null) && (End != null) ) {
			
			tick = AIController.GetTick();
			SuperLib.Helper.SetSign(Start, "Start!", true);	//	Remove signs so it doesn't run infinately
			SuperLib.Helper.SetSign(End, "End!", true);
			local PF;
			if (Mode == 1) {
				AILog.Info("Starting Ship Pathfinder...");
				PF = MetaLib.ShipPathfinder();	
			} else if (Mode == 2) {
				AILog.Info("Starting Waterbody Check...");
				PF = MetaLib.WaterbodyCheck();
				PF.PresetSafety(Start, End);
			}
			PF.InitializePath([Start], [End]);
			AILog.Info("     Max distance is " + PF.cost.max_cost );
			local Result = PF.FindPath(-1);
			AILog.Info("Path from " + AIMap.GetTileX(Start) + "," + AIMap.GetTileY(Start) + " to " + AIMap.GetTileX(End) + "," + AIMap.GetTileY(End) + ". Length " + (PF.GetPathLength()) + ". Took " + (AIController.GetTick() - tick) + " ticks." );
			AILog.Info(" ");
			Start = null;
			End = null;
			Mode = 1;
		}
		this.Sleep(SleepLength);
	}
}