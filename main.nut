/*	WmBasic v.3  r.140214
 *	Created by W. Minchin
 */
 
import("util.MinchinWeb", "MetaLib", 8);
import("util.SuperLib", "SuperLib", 26);
 
class WmShipPFTest extends AIController 
{
	//	SETTINGS
	WmBasicv = 3;
	/*	Version number of AI
	 */	
	WmBasicr = 140214;
	/*	Reversion number of AI
	 */
	 
	SleepLength = 5;
	/*	Controls how many ticks the AI sleeps between iterations.
	 */
	 
	//	END SETTINGS
  
  function Start();
}

function WmShipPFTest::Start() {
	AILog.Info("Welcome to WmBasic, version " + WmBasicv + ", revision " + WmBasicr + " by W. Minchin.");
	AILog.Info("Copyright © 2011-14 by W. Minchin. For more info, please visit http://minchin.ca/openttd-metalibrary")
	AILog.Info(" ");
	AILog.Info("This AI is to test the Ship Pathfinder in MinchinWeb's MetaLibrary. To perform the test,");
	AILog.Info("switch to the AI Company (use the cheat command) and place a 'Start' and 'End' sign. Place");
	AILog.Info("a sign 'Mode WBC' if you want to test Waterbody Check rather than the Ship Pathfinder; or")
	AILog.Info("a sign 'Mode Lakes' if you want to test Lakes (a replacement for Waterbody Check).")
	AILog.Info(" ");
	
	// Keep us going forever
	local Start;
	local End;
	local Mode = 1;
	local tick;
	local PF = MetaLib.ShipPathfinder();
	local WBC = MetaLib.WaterbodyCheck();
	local Lakes = PF._WBC;
	local Result;
	local Length;
	
	//	Tie ShipPathfinder's Lakes to our Lakes
	
	AISign.BuildSign(0x09A0, "Start");
	AISign.BuildSign(0x079F, "End");
	AISign.BuildSign(0x07D6, "Mode Lakes");
	//AISign.BuildSign(0x09A0, "Start");
	//AISign.BuildSign(0x0ABC, "End");
	//AISign.BuildSign(0x0744, "Start");
	//AISign.BuildSign(0x0ABC, "End");
	
	while (true) {
		Start = MetaLib.Extras.SignLocation("Start");
		End = MetaLib.Extras.SignLocation("End");
		if (SuperLib.Helper.HasSign("Mode WBC")) {
			Mode = 2;
		} else if (SuperLib.Helper.HasSign("Mode Lakes")) {
			Mode = 3;
		}
		
		if ( (Start != null) && (End != null) ) {
			
			tick = AIController.GetTick();
			SuperLib.Helper.SetSign(Start, "Start!", true);	//	Remove signs so it doesn't run infinitely
			SuperLib.Helper.SetSign(End, "End!", true);
			
			if (Mode == 1) {
				AILog.Info("Starting Ship Pathfinder...");
				PF.InitializePath([Start], [End]);
				AILog.Info("     Max distance is " + PF.cost.max_cost );
				Result = PF.FindPath(-1);
				Length = PF.GetPathLength();
			} else if (Mode == 2) {
				AILog.Info("Starting Waterbody Check...");
				WBC.PresetSafety(Start, End);
				WBC.InitializePath([Start], [End]);
				AILog.Info("     Max distance is " + WBC.cost.max_cost );
				Result = WBC.FindPath(-1);
				Length = PF.GetPathLength()
			} else if (Mode == 3) {
				AILog.Info("Starting Lakes...");
				Lakes.InitializePath([Start], [End]);
				Result = Lakes.FindPath(-1);
				Length = Lakes.GetPathLength();
			}

			AILog.Info("** Path from " + AIMap.GetTileX(Start) + "," + AIMap.GetTileY(Start) + " to " + AIMap.GetTileX(End) + "," + AIMap.GetTileY(End) + ". Length " + Length + ". Took " + (AIController.GetTick() - tick) + " ticks. **" );
			AILog.Info("     Result: " + Result);
			AILog.Info(" ");
			Start = null;
			End = null;
			Mode = 1;
		}
		this.Sleep(SleepLength);
	}
}