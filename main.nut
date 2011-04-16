/*	WmBasic v.1  r.1
 *	Created by William Minchin		w_minchin@hotmail.com		http://blog.minchin.ca
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
	 
	SleepLength = 50;
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
	
	// Keep us going forever
	while (true) {
		AILog.Info("Help! I haven't done anything yet and I'm already at tick " + this.GetTick());
		AILog.Info("-----------------------------------------------------");
		AILog.Info(" ");

		this.Sleep(SleepLength);
	}
}