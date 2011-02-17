/*	WmArray v.1  r.1
 *	Copyright © 2011 by William Minchin. For more info,
 *		please visit http://code.google.com/p/openttd-noai-wmdot/
 */
 
/*	A Library that collects the various functions dealing with arrays that I
 *		found useful and wanted in one place.
 */
 
function WmArray::Create1DArray(length)
{
	return array[length];
}

function WmArray::Create2DArray(length, width)
{
	local ReturnArray = [length];
	local tempArray = [width];
	for (local i=0; i < length; i++) {
		ReturnArray[i] = tempArray;
	}
	
	return ReturnArray;
}

function WmArray::Create3DArray(length, width, height)
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

function WmDOT::Print1DArray(InArray)
{
	//	Returns a string with the contents of the array
	
	//	Add error check that an array is provided
	
	local Length = InArray.len();
	local i = 0;
	local Temp = "";
	while (i < InArray.len() ) {
		Temp = Temp + InArray[i] + "  ";
		i++;
	}
	return Temp;
}

function WmDOT::Print2DArray(InArray)
{
	//	Returns a string with the contents of the array (in one line)
	
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
			Temp = Temp + InnerArray[j] + "  ";
			j++;
		}
		Temp = Temp + " /  ";
		i++;
	}
	
	Return Temp;
}