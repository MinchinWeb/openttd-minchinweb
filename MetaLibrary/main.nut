﻿/*	Minchinweb's MetaLibrary v.1 r.110 [2011-04-26],  
 *	originally part of, WmDOT v.6
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */
 
require("Pathfinder.Road.nut");
// require("AyStar.WM.nut");
require("Arrays.nut");
// require("Fibonacci.Heap.WM.nut");
require("Extras.nut");
require("Waterbody.Check.nut");
require("Pathfinder.Ship.nut");
require("Line.Walker.nut");
require("Spiral.Walker.nut");

class MinchinWeb {
	static RoadPathfinder = _MetaLib_RoadPathfinder_;
	static ShipPathfinder = _MetaLib_ShipPathfinder_;	
	static Array = _MetaLib_Array_;
	static Extras = _MetaLib_Extras_;
	static WaterbodyCheck = _MetaLib_WBC_;
	static LineWalker = _MetaLib_LW_;
	static SpiralWalker = _MetaLib_SW_;
}
 
/*	Q:	What is MinchinWeb's MetaLibrary?
 *	A:	MetaLib is the collection of code I've written for WmDOT, my AI for
 *			OpenTTD, that I felt should properly be in a library. I also hope
 *			will this code will help some aspiring AI writer get off the ground
 *			a little bit faster. ;)
 *
 *	Q:	How do I use the sublibraries directly?
 *	A:	Import the main library, and then create global points to the
 *			sublibaries you want to use. Eg:
 *		
 *			Import("util.MinchinWeb", "MinchinWeb", 1);
 *			Arrays <- MinchinWeb.Arrays;
 *
 *	Info:	See the sub-library files for the functions available and their
 *				implementation.
 *
 *	Q:	What is the _MetaLib_... all over the place?
 *	A:	I can't answer it better than Zuu when he put together his SuperLib, so
 *			I'll quote him.
 *
 *		  "	Unfortunately due to constraints in OpenTTD and Squirrel, only the
 *			main class of a library will be renamed at import. For [MetaLib]
 *			that is the [MetaLib] class in this file. Every other class in this
 *			file or other .nut files that the library is built up by will end
 *			up at the global scope at the AI that imports the library. The
 *			global scope of the library will get merged with the global scope
 *			of your AI.
 *
 *		  "	To reduce the risk of causing you conflict problems this library
 *			prefixes everything that ends up at the global scope of AIs with
 *			[ _MetaLib_ ]. That is also why the library is not named Utils or
 *			something with higher risk of you already having at your global
 *			scope.
 *
 *		  "	You should however never need to use any of the [ _MetaLib_... ]
 *			names as a user of this library. It is not even recommended to do
 *			so as it is part of the implementation and could change without
 *			notice. "
 *											- Zuu, SuperLib v7 documentation
 *
 *	A grand 'Thank You' to Zuu for his SuperLib that provided a very useful
 *		model, to all the NoAI team to their work on making the AI system work,
 *		and to everyone that has brought us the amazing game of OpenTTD.
 */