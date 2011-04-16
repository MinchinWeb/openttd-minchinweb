/*	WmBasic v.1  r.1
 *	Created by W. Minchin
 */
 
import("util.MetaLib", "MetaLib", 1);
 
class WmBasic extends AIController 
{
	//	SETTINGS
	WmBasicv = 1;
	/*	Version number of AI
	 */	
	WmBasicr = 94;
	/*	Reversion number of AI
	 */
	 
	SleepLength = 50;
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
	AILog.Info("switch to the AI Company (use the cheat command) and place a 'Start' and 'End' sign.")
	AILog.Info(" ");
	
	// Keep us going forever
	local Start;
	local End;
	while (true) {
		Start = MetaLib.Extras.SignLocation("Start");
		End = MetaLib.Extras.SignLocation("End");
		
		if ( (Start != null) && (End != null) ) {
			MetaLib.WaterbodyCheck.Initialize(Start, End);
			local Result = MetaLib.WaterbodyCheck.FindPath(-1);
			AILog.Info("Path from " + AIMap.GetTileX(Start) + "," + AIMap.GetTileY(Start) + " to " + AIMap.GetTileX(End) + "," + AIMap.GetTileY(End) + " returns " + Result + ". Took " (AIController.GetTick() - tick) + " ticks." )
			AILog.Info(" ");
			Start = null;
			End = null;
		}
		this.Sleep(SleepLength);
	}
}