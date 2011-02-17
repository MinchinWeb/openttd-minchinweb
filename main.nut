/*	WmDOT v.1  r.9
 *	Copyright © 2011 by William Minchin. For more info,
 *		please visit http://code.google.com/p/openttd-noai-wmdot/
 */

import("pathfinder.road", "RoadPathFinder", 3);
	//	Road pathfinder as provided by the NoAI team
 
 class WmDOT extends AIController 
{
	//	SETTINGS
	WmDOTv = 1;
	/*	Version number of AI
	 */	
	WmDOTr = 9;
	/*	Reversion number of AI
	 */
	 
	SingleLetterOdds = 7;
	/*	Control on single letter companies.  Set this value higher to increase
	 *	the chances of a single letter DOT name (eg. 'CDOT').		
	 */
	 
	MaxAtlasSize = 99;		//  UNUSED
	/*	This sets the maximum number of towns that will printed to the debug
	 *	screen.
	 */
	 
	SleepLength = 50;
	/*	Controls how many ticks the AI sleeps between iterations.
	 */
	 
	FloatOffset = 0.001;
	/*	Offset used to convert numbers from intregers to floating point
	 */
	 
	PathFinderCycles = 100;
	/*	Set the number of tries the pathfinders should run for
	 */
	 
	WmMaxBridge = 10;
	WmMaxTunnel = 10;
	/*	Max tunnel and bridge length it will build
	 */
	//	END SETTINGS
  
  function Start();
}

/*	TO DO
	- figure out how to get the version number to show up in Start()
	- somehow include towns that are connected but would benefit from a shorter connection
 */

function WmDOT::Start()
{
//	AILog.Info("Welcome to WmDOT, version " + GetVersion() + ", revision " + WmDOTr + " by " + GetAuthor() + ".");
	AILog.Info("Welcome to WmDOT, version " + WmDOTv + ", revision " + WmDOTr + " by William Minchin.");
	AILog.Info("Copyright © 2011 by William Minchin. For more info, please visit http://blog.minchin.ca")
	AILog.Info(" ");
	
	AILog.Info("Loading Libraries...");		// Actually, by this point it's already happened
	AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);
		//	Build normal road (no tram tracks)
	
	NameWmDOT();
	BuildWmHQ();
	local WmAtlas=[];
	local WmTownArray = [];
	local ConnectPairs = [];
	
	// Keep us going forever
	while (true) {
		WmTownArray = GenerateTownList();
		WmAtlas = GenerateAtlas(WmTownArray);
		WmAtlas = RemoveExistingConnections(WmAtlas);
		ConnectPairs = PickTowns(WmAtlas);
		if (ConnectPairs == null) {
			AILog.Info("It's tick " + this.GetTick() + " and apparently I've done everything! I'm taking a nap...");
			local i = this.GetTick();
			i = i % SleepLength;
			i = 10 * SleepLength - i;
			this.Sleep(i);		}
		else {
			BuildRoad(ConnectPairs);		
//			ManageLoans...
			
			AILog.Info("Help! I haven't done anything yet and I'm already at tick " + this.GetTick() + ".");
			local i = this.GetTick();
			i = i % SleepLength;
			this.Sleep(50 - i);
		}
		AILog.Info("----------------------------------------------------------------");
		AILog.Info(" ");
	}
}


function WmDOT::NameWmDOT()
{
	/*	This function names the company based on the AI settings.  If the names
	 *	given by the settings is already taken, a default ('WmDOT', for
	 *	'William Department of Transportation') is used.  Failing that, a
	 *	second default ('ZxDOT', chosed becuase I thought it looked cool) is
	 *	tried.  Failing that, a random one or two letter prefix is chosen and
	 *	added to DOT until and unused name is found.
	 */
		
	AILog.Info("Naming Company...");
	
	local tick;
	tick = this.GetTick();
	
	// Get Name Settings and Build Name String
	local Name2 = WmDOT.GetSetting("DOT_name2");
	local NewName = "";
	AILog.Info("     Name settings are " + WmDOT.GetSetting("DOT_name1") + " " + WmDOT.GetSetting("DOT_name2") + ".");
	switch (WmDOT.GetSetting("DOT_name1"))
	{
		case 0: 
			NewName = "Wm";
			break;
		case 1: 
			NewName = "A";
			break;
		case 2: 
			NewName = "B";
			break;
		case 3: 
			NewName = "C";
			break;
		case 4: 
			NewName = "D";
			break;
		case 5: 
			NewName = "E";
			break;
		case 6: 
			NewName = "F";
			break;
		case 7: 
			NewName = "G";
			break;
		case 8: 
			NewName = "H";
			break;
		case 9: 
			NewName = "I";
			break;
		case 10: 
			NewName = "J";
			break;
		case 11: 
			NewName = "K";
			break;
		case 12: 
			NewName = "L";
			break;
		case 13: 
			NewName = "M";
			break;
		case 14: 
			NewName = "N";
			break;
		case 15: 
			NewName = "O";
			break;
		case 16: 
			NewName = "P";
			break;
		case 17: 
			NewName = "Q";
			break;
		case 18: 
			NewName = "R";
			break;
		case 19: 
			NewName = "S";
			break;
		case 20: 
			NewName = "T";
			break;
		case 21: 
			NewName = "U";
			break;
		case 22: 
			NewName = "V";
			break;
		case 23: 
			NewName = "W";
			break;
		case 24: 
			NewName = "X";
			break;
		case 25: 
			NewName = "Y";
			break;
		case 26: 
			NewName = "Z";
			break;
		default:
			AILog.Warning("          Unexpected DOT_name1 parameter");
			break;
	}
	switch (WmDOT.GetSetting("DOT_name2"))
	{
		case 0: 
			break;
		case 1: 
			NewName = NewName + "a";
			break;
		case 2: 
			NewName = NewName + "b";
			break;
		case 3: 
			NewName = NewName + "c";
			break;
		case 4: 
			NewName = NewName + "d";
			break;
		case 5: 
			NewName = NewName + "e";
			break;
		case 6: 
			NewName = NewName + "f";
			break;
		case 7: 
			NewName = NewName + "g";
			break;
		case 8: 
			NewName = NewName + "h";
			break;
		case 9: 
			NewName = NewName + "i";
			break;
		case 10: 
			NewName = NewName + "j";
			break;
		case 11: 
			NewName = NewName + "k";
			break;
		case 12: 
			NewName = NewName + "l";
			break;
		case 13: 
			NewName = NewName + "m";
			break;
		case 14: 
			NewName = NewName + "n";
			break;
		case 15: 
			NewName = NewName + "o";
			break;
		case 16: 
			NewName = NewName + "p";
			break;
		case 17: 
			NewName = NewName + "q";
			break;
		case 18: 
			NewName = NewName + "r";
			break;
		case 19: 
			NewName = NewName + "s";
			break;
		case 20: 
			NewName = NewName + "t";
			break;
		case 21: 
			NewName = NewName + "u";
			break;
		case 22: 
			NewName = NewName + "v";
			break;
		case 23: 
			NewName = NewName + "w";
			break;
		case 24: 
			NewName = NewName + "x";
			break;
		case 25: 
			NewName = NewName + "y";
			break;
		case 26: 
			NewName = NewName + "z";
			break;
		default:
			AILog.Warning("          Unexpected DOT_name2 parameter");
			break;
	}
	NewName = NewName + "DOT"
	if (!AICompany.SetName(NewName))
	{
		AILog.Info("     Setting Company Name failed. Trying default...");
		if (!AICompany.SetName("WmDOT"))
		{
			AILog.Info("     Default failed. Trying backup...")
			if (!AICompany.SetName("ZxDOT"))
			{
				AILog.Info("     Backup failed. Trying random...")
				do
				{
					local c;
					c = AIBase.RandRange(26) + 65;
					NewName = c.tochar();
					c = AIBase.RandRange(26 + SingleLetterOdds) + 97;
					if (c <= 122)
					{
						NewName = NewName + c.tochar();
					}
					NewName = NewName + "DOT";					
				} while (!AICompany.SetName(NewName))
			}
		}
	}
	
	//	Add 'P.Eng' to the end of the founder's name
	NewName = AICompany.GetPresidentName(AICompany.COMPANY_SELF);
	NewName += ", P.Eng"
	AICompany.SetPresidentName(NewName);
	
	tick = this.GetTick() - tick;
	AILog.Info("     Company named " + AICompany.GetName(AICompany.COMPANY_SELF) + ". " + AICompany.GetPresidentName(AICompany.COMPANY_SELF) + " is in charge. Took " + tick + " tick(s).");
}

function WmDOT::GenerateAtlas(WmTownArray)
{
   /*	Everyone loves the Atlas, right?  Well, the guys at the local DOT
	*	figure it's pretty much essential for their work, so it's one of the
	*	first things they do when they set up shop.
	*
	*	The Atlas is generated in several steps:
	*	  - a list of towns is pulled from the server
	*     - the list is sorted by population
	*     - the location of each town is pulled from the sever
	*     - an array is generated with all of the Manhattan distance pairs
	*     - an array is generated with the existing links
	*	  - an array is generated with the real travel distances along
	*			existing routes
	*	  - an array is generated with the differences between real travel
	*			distances and Manhattan distances
	*	  - the atlas is printed (to the Debug screen)
	*/
	 

	 
	AILog.Info("     Generating distance matrix.");
	AILog.Info("          TOWN NAME - POPULATION - LOCATION");

	// Generate Distance Matrix
	local iTown;
	local WmAtlas=[];
	WmAtlas.resize(WmTownArray.len());
	
	for(local i=0; i < WmTownArray.len(); i++) {
		iTown = WmTownArray[i];
		AILog.Info("          " + iTown + ". " + AITown.GetName(iTown) + " - " + AITown.GetPopulation(iTown) + " - " + AIMap.GetTileX(AITown.GetLocation(iTown)) + ", " + AIMap.GetTileY(AITown.GetLocation(iTown)));
		local TempArray = [];		// Generate the Array one 'line' at a time
		TempArray.resize(WmTownArray.len()+1);
		TempArray[0]=iTown;
		local jTown = AITown();
//		local TempDist = "";
		for (local j = 0; j < WmTownArray.len(); j++) {
			if (i >= j) {
				TempArray[j+1] = 0;		// Make it so it only generates half the array.
			}
			else {
				jTown = WmTownArray[j];
//				AILog.Info("                    " + AIMap.DistanceManhattan(AITown.GetLocation(iTown),AITown.GetLocation(jTown)) + "from town " + iTown + " to " + jTown);
//				TempDist = TempDist + AIMap.DistanceManhattan(AITown.GetLocation(kTown),AITown.GetLocation(jTown)) + " ";
				TempArray[j+1] = AIMap.DistanceManhattan(AITown.GetLocation(iTown),AITown.GetLocation(jTown));
			}
		}

//		Print1DArray(TempArray);
		WmAtlas[i]=TempArray;
	}

	Print2DArray(WmAtlas);
/*	tick = this.GetTick() - tick;
	AILog.Info("     Atlas complete. Took " + tick + "tick(s).");
*/
	return WmAtlas;
}

function WmDOT::GenerateTownList()
{
	AILog.Info("Generating Atlas...");
	// Generate TownList
	local WmTownList = AITownList();
	WmTownList.Valuate(AITown.GetPopulation);
	local PopLimit = WmDOT.GetSetting("MinTownSize");
	WmTownList.KeepAboveValue(PopLimit);				// cuts under the pop limit
	AILog.Info("     Ignoring towns with population under " + PopLimit + ". " + WmTownList.Count() + " of " + AITown.GetTownCount() + " towns left.");

	local WmTownArray = [];
	WmTownArray.resize(WmTownList.Count());
	local iTown = WmTownList.Begin();
	for(local i=0; i < WmTownList.Count(); i++) {
//		AILog.Info("          " + iTown + ". " + AITown.GetName(iTown) + " - " + AITown.GetPopulation(iTown) + " - " + AIMap.GetTileX(AITown.GetLocation(iTown)) + ", " + AIMap.GetTileY(AITown.GetLocation(iTown)));
		WmTownArray[i]=iTown;
		iTown = WmTownList.Next();
	}
	

	return WmTownArray;
}

function WmDOT::Print1DArray(InArray)
{
	//	Move to Library
	//	Add error check that an array is provided
	
	local Length = InArray.len();
//	AILog.Info("The array is " + Length + " long.");
	local i = 0;
	local Temp = "";
	while (i < InArray.len() ) {
		Temp = Temp + "  " + InArray[i];
		i++;
	}
	AILog.Info("The array is " + Length + " long.  " + Temp + " ");
}

function WmDOT::Print2DArray(InArray)
{
	//	Move to Library
	//	Add error check that a 2D array is provided
	
	local Length = InArray.len();
//	AILog.Info("The array is " + Length + " long.");
	local i = 0;
	local Temp = "";
	while (i < InArray.len() ) {
		local InnerArray = [];
		InnerArray = InArray[i];
		local InnerLength = InnerArray.len();
//		AILog.Info("     The inner array is " + InnerLength + " long.");
		local j = 0;
		while (j < InnerArray.len() ) {
			Temp = Temp + "  " + InnerArray[j];
			j++;
		}
		Temp = Temp + "  /  ";
		i++;
	}
	AILog.Info("The array is " + Length + " long." + Temp + " ");
}

function WmDOT::BuildWmHQ()
{
	//  TO-DO
	//	- create other options for where to build HQ (random, setting?)
	//	- check for other DOT HQ's
	
	//	There is no check to keep the map co-ordinates from wrapping around the edge of the map
	//	There is a safety in place that if it tries twenty squares in a line in one step, it exits
	
	AILog.Info("Building Headquarters...")
	
	local tick;
	tick = this.GetTick();
	
//	AICompany.BuildCompanyHQ(0xA284);
	
	local HQBuilt = false;
	// Check for exisiting HQ
	if (AICompany.GetCompanyHQ(AICompany.ResolveCompanyID(AICompany.COMPANY_SELF)) != -1) {
		HQBuilt = true;
		AILog.Info("     What are you trying to pull on me?!? HQ are already established at " + AIMap.GetTileX(AICompany.GetCompanyHQ(AICompany.COMPANY_SELF)) + ", " +  AIMap.GetTileY(AICompany.GetCompanyHQ(AICompany.COMPANY_SELF)) + ".");
	}
	
	if (HQBuilt == false) {
		// Gets a list of the towns and picks the one with the highest populaiton	
		local WmTownList = AITownList();
		WmTownList.Valuate(AITown.GetPopulation);
		local HQTown = AITown();
		HQTown = WmTownList.Begin();
		
		// Get tile index of the centre of town
		local HQx;
		local HQy;
		HQx = AIMap.GetTileX(AITown.GetLocation(HQTown));
		HQy = AIMap.GetTileY(AITown.GetLocation(HQTown));
		AILog.Info("     HQ will be build in " + AITown.GetName(HQTown) + " at " + HQx + ", " + HQy + ".");
		
		// Starts a spiral out from the centre of town, trying to build the HQ until it works!
		local dx = -1;
		local dy =  0;
		local Steps = 0;
		local Stage = 1;
		local StageMax = 1;
		local StageSteps = 0;
		
		while (HQBuilt == false) {
			HQx += dx;
			HQy += dy;
			HQBuilt = AICompany.BuildCompanyHQ(AIMap.GetTileIndex(HQx,HQy));
			Steps ++;
			StageSteps ++;
//			AILog.Info("          Step " + Steps + ". dx=" + dx + " dy=" + dy + ". Trying at "+ HQx + ", " + HQy + ". Stage: " + Stage + ". StageMax: " + StageMax + ". StageSteps: " + StageSteps + ".")

			// Check if it's time to turn
			if (StageSteps == StageMax) {
				StageSteps = 0;
				if (Stage % 2 == 0) {
					StageMax++;
				}
				Stage ++;
				
				// Turn Clockwise
				switch (dx) {
					case 0:
						switch (dy) {
							case -1:
								dx = -1;
								dy =  0;
								break;
							case 1:
								dx = 1;
								dy = 0;
								break;
						}
						break;
					case -1:
						dx = 0;
						dy = 1;
						break;
					case 1:
						dx =  0;
						dy = -1;
						break;
				}
			}

			// Safety: Break if it tries for 20 times and still doesn't work!
			if (Stage == 20) {HQBuilt = true;}			
		}
		AILog.Info("          HQ built at "+ HQx + ", " + HQy + ". Took " + Steps + " tries.");
	}
		
	tick = this.GetTick() - tick;
	AILog.Info("     HQ built. Took " + tick + " tick(s).");
}

function WmDOT::PickTowns(WmAtlas)
{
	//	Picks to towns to connect, returns an array with the two of them
	//	A zero entry in the matrix is used to ignore the possibily of connecting
	//		the two (eg. same town, connection already exists)
	//	Assumes WmAtlas comes in the form of a 2D matrix with the first
	//		column being the TownID and the rest being the distance between
	//		each town pair
	//
	//	Trip Generation, Trip Distribution
	//	A[i,j] = (P[i] + P[j]) / T[i,j]^2		A - 'Attration' - trips from i to j
	//											P - Populaiton of i
	//											T - distance (in time) from i to j
	//	T is calculated by assuming each tile is 1 mile square = (d/v)

	local tick;
	tick = this.GetTick();
	
	local Speed = GetSpeed();
	
	AILog.Info("     Applying traffic model. Speed (v) is " + Speed + "...");
	
	//  Applys equation to matrix
	local ZeroCheck = 0;				//	Uses this to check that the distance matrix is not all zeroes
	for (local i = 0; i < WmAtlas.len(); i++ ) {
		for (local j=1; j < WmAtlas[i].len(); j++ ) {
			local dtemp = WmAtlas[i][j];
			local FactorTemp = 0.0;
			if (dtemp != 0) {					// avoid divide by zero
				ZeroCheck++;
				dtemp = WmAtlas[i][j] + FloatOffset;	//	small offset to make it a floating point number
				local Ttemp = (dtemp / Speed);
				local TPop = (AITown.GetPopulation(WmAtlas[i][0]) + AITown.GetPopulation(WmAtlas[j-1][0]) + FloatOffset);
														// j-1 offset needed to get town
				FactorTemp = (TPop / (Ttemp * Ttemp));		// doesn't recognize exponents
//				AILog.Info("          Pop(" + i + ") " + AITown.GetPopulation(WmAtlas[i][0]) + " Pop(" + (j-1) + ") " +AITown.GetPopulation(WmAtlas[j-1][0]) + " :" + TPop + " d " + dtemp + " d/v " + Ttemp + " Result " + FactorTemp);
			}
			else {
//				AILog.Info("          Skipped " + dtemp);
				FactorTemp = dtemp;
			}
			WmAtlas[i][j] = FactorTemp;
		}
	}
	Print2DArray(WmAtlas);
	
	if (ZeroCheck > 0) {
		//	Ok, next step: find the highest rated pair
		local Maxi;
		local Maxj;
		local MaxLink = 0.0;
		for (local i = 0; i < WmAtlas.len(); i++ ) {
			for (local j=1; j < WmAtlas[i].len(); j++ ) {
				if (WmAtlas[i][j] > MaxLink) {
					MaxLink = WmAtlas[i][j];
					Maxi = i;
					Maxj = j - 1;	// j-1 offset needed to get town
				}
			}
		}
		
		//	Convert from matrix index to TownID
		Maxi = WmAtlas[Maxi][0];
		Maxj = WmAtlas[Maxj][0];
		
		AILog.Info("          The best rated pair is " + AITown.GetName(Maxi) + " and " + AITown.GetName(Maxj) + ". Took " + (this.GetTick() - tick) + " ticks.")
		
		return [Maxi, Maxj];
	}
	else {
		AILog.Info("          No remaining town pairs to join!");
		return null;
	}
}

function WmDOT::GetSpeed()
{
	//	Gets max travel speed, given the game year
	//	Based on original game buses in temporate
	//		http://wiki.openttd.org/Buses
	
	//	TO-DO
	//	- get speeds from vehicles acually introduced in the game
	
	local GameYear = 0;
	GameYear = AIDate.GetYear(AIDate.GetCurrentDate());
	
	local GameYearCase = 4;		// Convert to case numbers here because 
								//		Squirrel's switch statement doesn't
								//		seem to play nice with inline evaluations
	if (GameYear < 2008) {
		GameYearCase = 3;
	}
	if (GameYear < 1986) {
		GameYearCase = 2;
	}
	if (GameYear < 1964)
		GameYearCase = 1;
		
	local ReturnSpeed;
	switch (GameYearCase)
	{
		case 4:
			ReturnSpeed = 79;	// mph, only because they're nicer numbers
			break;
		case 3:
			ReturnSpeed = 70;
			break;
		case 2:
			ReturnSpeed = 55;
			break;
		case 1:
			ReturnSpeed = 35;
			break;
		default:
			ReturnSpeed = 1;
			break;
	}
	
//	AILog.Info("     Before Return " + ReturnSpeed + " GameYear " + GameYear);
	return ReturnSpeed;
}

function WmDOT::RemoveExistingConnections(WmAtlas)
{
	//	Zeros out distances in the Atlas of existing connections
	//	Required as a precondition to PickTowns() to get anything useful out of it
	//	Note that a connection could be around the far end of the map and back...
	//	Assumes the centre of town is a road tile and that you can follow a road
	//		'out of town'
	//
	//	TO-DO
	//	- check that the centre of town is a road tile
	//	- check to see if you can get out of town and then do something when you can't
	//	- make it only set one check one set of routes (half the matrix)
	
	AILog.Info("     Removing already joined towns. This can take a while...")
	
	local tick;
	tick = this.GetTick();
	
	//	create instance of road pathfinder
	local pathfinder = RoadPathFinder();
	//	pathfinder settings
	pathfinder.cost.max_bridge_length = WmMaxBridge;
	pathfinder.cost.max_tunnel_length = WmMaxTunnel;
	pathfinder.cost.no_existing_road = pathfinder.cost.max_cost;	// only use exisiting roads
	
	local iTown = AITile();
	local jTown = AITile();
	local RemovedCount = 0;
	local ExaminedCount = 0;
	
	for (local i = 0; i < WmAtlas.len(); i++ ) {
		for (local j=1; j < WmAtlas[i].len(); j++ ) {
			if (WmAtlas[i][j] > 0) {		// Ignore already zeroed entries
				iTown = AITown.GetLocation(WmAtlas[i][0]);
				jTown = AITown.GetLocation(WmAtlas[j-1][0]);	// j-1 needed to get town index
				pathfinder.InitializePath([iTown], [jTown]);
				
				local path = false;
				while (path == false) {
				  path = pathfinder.FindPath(PathFinderCycles);
//				  AIController.Sleep(1);
				}
				
//				AILog.Info("          Was trying to find path from " + iTown + " to " + jTown + ": " + path)
				
				if (path != null) {
					WmAtlas[i][j] = 0;
//					AILog.Info("          Path found from " + AITown.GetName(WmAtlas[i][0]) + " to " + AITown.GetName(WmAtlas[j-1][0]) + ".");
					RemovedCount++;
				}
				ExaminedCount++;
			}
		}
	}
	
	Print2DArray (WmAtlas);
	
	tick = this.GetTick() - tick;
	AILog.Info("          " + RemovedCount + " of " + ExaminedCount + " routes removed. Took " + tick + " tick(s).");
	
	return WmAtlas;
}

function WmDOT::BuildRoad(ConnectPairs)
{
	//	Move to Library (seperate from my stuff)
	//	builds a road, given the path
	//	copied from	http://wiki.openttd.org/AI:RoadPathfinder on 2010-02-10
	//		under GNU Free Documentation License.

	AILog.Info("     Connecting " + AITown.GetName(ConnectPairs[0]) + " and " + AITown.GetName(ConnectPairs[1]) + "...");
	
	local tick;
	tick = this.GetTick();	
	
	/* Tell OpenTTD we want to build normal road (no tram tracks). */
  AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);
  
  /* Create an instance of the pathfinder. */
  local pathfinder = RoadPathFinder();
  
	//	Set Parameters
	pathfinder.cost.max_bridge_length = WmMaxBridge;
	pathfinder.cost.max_tunnel_length = WmMaxTunnel;
	pathfinder.cost.no_existing_road = 100;		//	default = 40
	pathfinder.cost.slope = 400;				//	default = 200
	pathfinder.cost.bridge_per_tile = 250;		//	default = 150
												//	the hope is that random bridges on flat ground won't
												//		show up, but they will for the little dips  \_/
	pathfinder.cost.turn = 50;					//	default = 100
	
  /* Give the source and goal tiles to the pathfinder. */
  pathfinder.InitializePath([AITown.GetLocation(ConnectPairs[0])], [AITown.GetLocation(ConnectPairs[1])]);

  /* Try to find a path. */
	AILog.Info("          Pathfinding...");
  local path = false;
  while (path == false) {
    path = pathfinder.FindPath(100);
 //   this.Sleep(1);
  }

  if (path == null) {
    /* No path was found. */
    AILog.Error("pathfinder.FindPath return null");
  }
  
	/* If a path was found, build a road over it. */
	AILog.Info("          Path found. Took " + (this.GetTick() - tick) + " ticks. Building route...");
	tick = this.GetTick();
	
  while (path != null) {
    local par = path.GetParent();
    if (par != null) {
      local last_node = path.GetTile();
      if (AIMap.DistanceManhattan(path.GetTile(), par.GetTile()) == 1 ) {
        if (!AIRoad.BuildRoad(path.GetTile(), par.GetTile())) {
          /* An error occured while building a piece of road. TODO: handle it. 
           * Note that is can also be the case that the road was already build. */
        }
      } else {
        /* Build a bridge or tunnel. */
        if (!AIBridge.IsBridgeTile(path.GetTile()) && !AITunnel.IsTunnelTile(path.GetTile())) {
          /* If it was a road tile, demolish it first. Do this to work around expended roadbits. */
          if (AIRoad.IsRoadTile(path.GetTile())) AITile.DemolishTile(path.GetTile());
          if (AITunnel.GetOtherTunnelEnd(path.GetTile()) == par.GetTile()) {
            if (!AITunnel.BuildTunnel(AIVehicle.VT_ROAD, path.GetTile())) {
              /* An error occured while building a tunnel. TODO: handle it. */
            }
          } else {
            local bridge_list = AIBridgeList_Length(AIMap.DistanceManhattan(path.GetTile(), par.GetTile()) + 1);
            bridge_list.Valuate(AIBridge.GetMaxSpeed);
            bridge_list.Sort(AIAbstractList.SORT_BY_VALUE, false);
            if (!AIBridge.BuildBridge(AIVehicle.VT_ROAD, bridge_list.Begin(), path.GetTile(), par.GetTile())) {
              /* An error occured while building a bridge. TODO: handle it. */
            }
          }
        }
      }
    }
    path = par;
  }
  
	AILog.Info("          Route complete. (MD = " + AIMap.DistanceManhattan(AITown.GetLocation(ConnectPairs[0]), AITown.GetLocation(ConnectPairs[1])) + ") Took " + (this.GetTick() - tick) + " tick(s)."); 
 }
 


 
 
