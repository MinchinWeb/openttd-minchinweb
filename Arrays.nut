/*	Array SubLibrary, v.2 r.86 [2011-04-16],
 *	part of Minchinweb's MetaLibrary v1, r86, [2011-04-16],
 *	originally part of WmDOT v.5  r.53d	[2011-04-09]
 *		and WmArray library v.1  r.1 [2011-02-13].
 *	Copyright © 2011 by W. Minchin. For more info,
 *		please visit http://openttd-noai-wmdot.googlecode.com/
 */

/*	Provided functions:
 *		MetaLib.Array.Create1D(length)
 *					 .Create2D(length, width)
 *					 .Create3D(length, width, height)
 *					 .ToSting1D(InArray)
 *					 .ToSting2D(InArray)
 *					 .ContainedIn1D(InArray, SearchValue)
 *					 .ContainedIn2D(InArray, SearchValue)
 */
 
 
 
function _MetaLib_Array_::Create1D(length)
{
    return array[length];
}

function _MetaLib_Array_::Create2D(length, width)
{
    local ReturnArray = [length];
    local tempArray = [width];
    for (local i=0; i < length; i++) {
        ReturnArray[i] = tempArray;
    }
    
    return ReturnArray;
}

function _MetaLib_Array_::Create3D(length, width, height)
{
    local ReturnArray = [length];
    local tempArray = [width];
    local tempArray2 = [height];
    
    for (local i=0; i < width; i++) {
        tempArray[i] = tempArray2;
    }
    
    for (local i=0; i < length; i++) {
        ReturnArray[i] = tempArray;
    }
    
    return ReturnArray;
}

function _MetaLib_Array_::ToSting1D(InArray)
{
	//	Add error check that an array is provided
	
	local Length = InArray.len();
	local i = 0;
	local Temp = "";
	while (i < InArray.len() ) {
		Temp = Temp + "  " + InArray[i];
		i++;
	}
	return ("The array is " + Length + " long.  " + Temp + " ");
}

function _MetaLib_Array_::ToSting2D(InArray)
{
	//	Add error check that a 2D array is provided
	
	local Length = InArray.len();
	local i = 0;
	local Temp = "";
	while (i < InArray.len() ) {
		local InnerArray = [];
		InnerArray = InArray[i];
		local InnerLength = InnerArray.len();
		local j = 0;
		while (j < InnerArray.len() ) {
			Temp = Temp + "  " + InnerArray[j];
			j++;
		}
		Temp = Temp + "  /  ";
		i++;
	}
	return ("The array is " + Length + " long." + Temp + " ");
}

function _MetaLib_Array_::ContainedIn1D(InArray, SearchValue)
{
//	Searches the array for the given value. Returns 'TRUE' if found and
//		'FALSE' if not.
//	Accepts 1D Arrays

	if (InArray == null) {
		return null;
	} else {
		for (local i = 0; i < InArray.len(); i++ ) {
				if (InArray[i] == SearchValue) {
					return true;
				}
		}

		return false;
	}
}

function _MetaLib_Array_::ContainedIn2D(InArray, SearchValue)
{
//	Searches the array for the given value. Returns 'TRUE' if found and
//		'FALSE' if not.
//	Accepts 2D Arrays

	if (InArray == null) {
		return null;
	} else {
		for (local i = 0; i < InArray.len(); i++ ) {
			for (local j=0; j < InArray[i].len(); j++ ) {
				if (InArray[i][j] == SearchValue) {
					return true;
				}
			}
		}

		return false;
	}
}

