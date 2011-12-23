MinchinWeb's MetaLibrary Read-me
v.1, r.123, 2011-04-28
Copyright © 2011 by W. Minchin. For more info, please visit
    http://openttd-noai-wmdot.googlecode.com/

-- About MetaLibrary ----------------------------------------------------------
MetaLibrary started as a collection of functions from my AI, WmDOT. The hope is
    to provide a collection of classes and functions that will be useful to
    other AI writers. Your comments, suggestions, and bug reports are welcomed
    and encouraged!

-- Requirements ---------------------------------------------------------------
WmDOT requires OpenTTD version 1.1 or better. This is available as a free
    download from OpenTTD.org
As dependances, WmDOT also requires:
    - Binary Heap, v.1 ('Queue.BinaryHeap-1.tar')
    - Fibonacci Heap, v.2
    - Graph.AyStar, v.6

-- Installation ---------------------------------------------------------------
The easiest (and recommended) way to install MetaLibrary is use OpenTTD's
    'Check Online Content' inferface. Search for 'WmDOT.' If you have not
    already installed the required libraries, OpenTTD will prompt you to
    download them at the same time. This also makes it very easy for me to
    provide updates.
Manual installation can be accomplished by putting the
    'MinchinWebs_MetaLibrary-1.tar' file you downloaded in the
    '..\OpenTTD\ai\library'  folder. If you are manually installing,
    the libraries mentioned above need to be in the same folder.

To make use of the library in your AIs, add the line:
        import("util.MinchinWeb", "MetaLib", 1);
    which will make the library available as the "MetaLib" class (or whatever
    you change that to).
    
-- Included Functions ---------------------------------------------------------
Detailed descirptions of each of the function is given within the code files.
    See them for further details of each function.

[Arrays.nut] v.2
    Array.Create1D(length)
        .Create2D(length, width)
        .Create3D(length, width, height)
        .ToString2D(InArray)
            - this is useful to output an array to the debugging output
        .ContainedIn1D(InArray, SearchValue)
        .ContainedIn2D(InArray, SearchValue)
        .ContainedIn3D(InArray, SearchValue)
            - these return true or false, depending on if the value can be
                found
        .Find1D(InArray, SearchValue)
        .Find2D(InArray, SearchValue)
        .Find3D(InArray, SearchValue)
            - returns the location of the first time the SearchValue is found;
                the 1D version returns an interger, the 2D and 3D versions
                return an array with the indexes
        .RemoveValueAt(InArray, Index)
        .InsertValueAt(InArray, Index, Value)
        .ToStringTiles1D(InArrayOfTiles)
            - this is useful to output an tile array to the debugging output
        .FindPairs(InArray2D, SearchValue1, SearchValue2)
        .ContainedInPairs(InArray2D, SearchValue1, SearchValue2)
            - The idea is to povide an array of pairs, and find out if
                SearchValue1 and SearchValue2 is listed as one of the pairs
                
[Extras.nut] v.1
    Extras.DistanceShip(TileA, TileB)
            - Assuming open ocean, ship in OpenTTD will travel 45° angle where
                possible, and then finish up the trip by going along a cardinal
                direction
        .SignLocation(text)
            - Returns the tile of the first instance where the sign matches the
                given text
        .MidPoint(TileA, TileB)
        .Perpendicular(SlopeIn)
        .Slope(TileA, TileB)
        .Within(Bound1, Bound2, Value)
        .WithinFloat(Bound1, Bound2, Value)
        .MinAbsFloat(Value1, Value2)
        .MaxAbsFloat(Value1, Value2)
        .AbsFloat(Value)
            - Returns the absolute Value as a floating number if one is
                provided
        .Sign(Value)
            - Returns +1 if the Value >= 0, -1 Value < 0
        .MinFloat(Value1, Value2)
        .MaxFloat(Value1, Value2)
        .MinAbsFloatKeepSign(Value1, Value2)
        .MaxAbsFloatKeepSign(Value1, Value2)
        
[Pathfinder.Road.nut] v.7
This file is licenced under the originl licnese - LGPL v2.1
    and is based on the NoAI Team's Road Pathfinder v3
The pathfinder uses the A* search pattern and includes functions to find the
    path, determine its cost, and build it.
    
    RoadPathfinder.InitializePath(sources, goals)
            - Set up the pathfinder
        .FindPath(iterations)    
            - Run the pathfinder; returns false if it isn't finished the path
                if it has finished, and null if it can't find a path
        .cost.[xx]
            - Allows you to set or find out the pathfinder costs directly. See
                the function for valid entries
        .Info.GetVersion()
            .GetMinorVersion()
            .GetRevision()
            .GetDate()
            .GetName()
                - Useful for check provided version or debugging screen output
        .PresetOriginal()
        .PresetPerfectPath()
        .PresetQuickAndDirty()
        .PresetCheckExisting()
        .PresetMode6()
        .PresetStreetcar() 
            - Presets for the pathfinder parameters
        .GetBuildCost()
            - How much would it be to build the path?
        .BuildPath()
            - Build the path
        .GetPathLength()
            - How long is the path? (in tiles)
        .LoadPath(Path)
            - Provide your own path
        .InitializePathOnTowns(StartTown, EndTown)
            - Initializes the pathfinder using the seed tiles of the given towns    
        .PathToTilePairs()
            - Returns a 2D array that has each pair of tiles that path joins
        .TilesPairsToBuild()
            - Similar to PathToTilePairs(), but only returns those pairs where
                there isn't a current road connection
                
[Spiral.Walker.nut] v.2
The SpiralWalker class allows you to define a starting point, and then 'walk'
    all the tiles in a spiral outward. It was originally used to find a
    buildable spot for my HQ in WmDOT, but is useful for many other things as
    well.
    
    .SpiralWalker()
    .SpiralWalker.Start(Tile)
            - Sets the starting tile for SpiralWalker
        .Reset()
            - Clears all data within the SprialWalker
        .Restart()
            - Sends the SpiralWalker back to the starting tile
        .Walk()
            - Move out, one tile at a time. Returns the Tile the SpiralWalker
                is on
        .GetStart()
            - Returns the tile the SpiralWalker is starting on
        .GetStage()
            - Returns the Stage the SpiralWalker is on (basically, the line
                segments its completed plus one; it takes four to complete a revolution)
        .GetTile()
            - Returns the Tile the SpiralWalker is on
        .GetStep()
            - Returns the number of steps the SpiralWalker has done
        
[Waterbody.Check.nut] v.1
Waterbody check is in effect a specialized pathfinder. It serves to check
    whether two points are in the same waterbody (i.e. a ship could travel
    between them). It is optimized to run extremely fast (I hope!). It can be
    called separately, but was originally designed as a pre-run check for my
    Ship Pathfinder (not quite finished, but to also be included in this
    MetaLibrary).
        
    WaterbodyCheck.InitializePath(sources, goals)
            - Set up the pathfinder
        .FindPath(iterations)    
            - Run the pathfinder; returns false if it isn't finished the path
                if it has finished, and null if it can't find a path
        .cost.[xx]
            - Allows you to set or find out the pathfinder costs directly. See
                the function for valid entries        

-- Version History ------------------------------------------------------------
Version 1 [2011-04-28]
    Initial public release; released to coincide with the release of WmDOT v6
    Included Arrays v.2, Extras v.1, Road Pathfinder v.7, Spiral Walker v.2,
        and Waterbody Check v.1

-- Roadmap --------------------------------------------------------------------
These are features I hope to add to MetaLibrary shortly. However, this is 
    subject to change without notice. However,I am open to suggestions!
v.2     Ship Pathfinder
        Atlas Generator (input possible sources and destinations and get the
            best pair)
            
-- Known Issues ---------------------------------------------------------------
Pathfinding can take an exceptionally long time if there is no possible path.
    This is most often an issue when the two towns in question are on different
    islands.
SpiralWalker skips the tile [+1,0] relative to ths starting tile.

-- Help! It broke! (Bug Report) -----------------------------------------------
If MetaLibrary cause crashes, please help me fix it! Save a screenshot (under
    the ? on the far right of the in-game toolbar) and, if possible, the
    offending AI, and report the bug to either:
                            http://www.tt-forums.net/viewtopic.php?f=65&t=57903
                            http://code.google.com/p/openttd-noai-wmdot/issues/

-- Helpful Links --------------------------------------------------------------
Get OpenTTD!                                                    www.openttd.org
TT-Forums - all things Transport Tycoon related               www.tt-forums.net
MetaLibrary's thread on TT-Forums: release announcements, bug reports,
    suggetions, and general commentary
                            http://www.tt-forums.net/viewtopic.php?f=65&t=57903
WmDOT on Google Code: source code, and WmDOT: Bleeding Edge edition
                                    http://code.google.com/p/openttd-noai-wmdot
To report issues:            http://code.google.com/p/openttd-noai-wmdot/issues

My other projects (for OpenTTD):
    WmDOT (an AI)           http://www.tt-forums.net/viewtopic.php?f=65&t=53698
    Alberta Town Names      http://www.tt-forums.net/viewtopic.php?f=67&t=53313
    MinchinWeb's Random Town Name Generator
                            http://www.tt-forums.net/viewtopic.php?f=67&t=53579

-- Licence -------------------------------------------------------------------
MetaLibrary (unless otherwise noted) is licenced under a
    Creative Commons-Attribution 3.0 licence.