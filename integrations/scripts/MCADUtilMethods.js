/*  MCADUtilMethods.js

   Copyright Dassault Systemes, 1992-2007. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
*/


//------------------------------------------------------------------------
// Method getIntegrationFrame(win)
// This function searches for the Integration frame and returns it, if it finds one.
//
// Parameters:
//   win - Window in which search should start.
// Returns:
//  Handle to the Integration frame.
//------------------------------------------------------------------------


function getIntegrationFrame(win)
{
		var hldrIntegrationFrame = null;
		var obj = win.getTopWindow();
		if(obj.integrationsFrame != null && obj.integrationsFrame.eiepIntegration != null)
		{
			//Current window has Integration frame.
			hldrIntegrationFrame = obj.integrationsFrame.eiepIntegration;
		}
		else if(obj.opener != null && !obj.opener.closed)
		{
			//Looking in opener...
			hldrIntegrationFrame = getIntegrationFrame(obj.opener);
		}

		return hldrIntegrationFrame;		
}

//------------------------------------------------------------------------
// Method getFrameObject(win, frameName)
// This function searches for the frame object from the window's frame hierarchy.
//
// Parameters:
//  win - Window in which search should start.
//  frameName - name of the frame object
// Returns:
//  Handle to the frame object.
//------------------------------------------------------------------------

function getFrameObject(objWindow, frameName) 
{
	var objFrame = null;

	for(var i=0; i<objWindow.frames.length && !objFrame; i++) 
	{
		if (objWindow.frames[i].name == frameName) 
		{
			objFrame = objWindow.frames[i];
		} 
	} 

	if(!objFrame) 
	{
		for (var i=0; i < objWindow.frames.length && !objFrame; i++) 
		{
			objFrame = getFrameObject(objWindow.frames[i], frameName);
		} 
	} 

	return objFrame;
} 

//------------------------------------------------------------------------
// Method getEncodededString(inputString, separator)
//
// Assumption: inputString will have three parts, after splitting by separator.
// This function splits the input string and escapes the second and third part 
// to make a new string and returns.
//
// Parameters:
//   inputString - String to operate on
//	 separator   -  delimiter to split the input string.
//	 
// Returns:
//  String with escaped strings.
//------------------------------------------------------------------------

function getEncodededString (inputString,separator) 
{
	//type casting trick.
	inputString = inputString + "";

	var arrayOfStrings = inputString.split(separator);
	return escape(arrayOfStrings[1])+separator+escape(arrayOfStrings[2])+separator+escape(arrayOfStrings[3]);
}

//------------------------------------------------------------------------
// Method checkout(objectCheckoutDetails, instanceName, representationName)
// This function searches for the Integration frame and returns it, if it finds one.
//
// Parameters:
//   integrationName - Name of the CSE
//	 checkoutStatus - true|false
//   objectsInfo - busID|instanceName|representationName|dmuSessionName|busID|instanceName|representationName|dmuSessionName
//   checkoutMessage - message1|message2.
// Returns:
//------------------------------------------------------------------------

function checkout(integrationName, checkoutStatus, objectsInfo, checkoutMessage, mode, launchCADTool)
{
	var integrationFrame = getIntegrationFrame(this);
	//cannot go ahead if unable to locate integration frame.
	if(integrationFrame == null)
	{
		alert("Integration Applet is not available. Please close the browser and login again.");
		return;
	}
	var mxmcadApplet = integrationFrame.getAppletObject();
	
	if(checkoutStatus == "false")
	{
		var parsedMessage = replaceAll(checkoutMessage, "|", "\n");
		alert(parsedMessage);
	}
	else if (checkoutMessage != null && trim(checkoutMessage) != "")
	{
		var parsedMessage = replaceAll(checkoutMessage, '|', '\n');
		var confirmStatus = confirm(parsedMessage);

		if(confirmStatus)
		{
			var checkoutDetails;		
			if(mode == "interactive")
			{
				checkoutDetails = integrationName + "|None|" + objectsInfo + "@" + launchCADTool;
			mxmcadApplet.callCommandHandler(integrationName, "createCheckoutPage", checkoutDetails);
			}
			else if(mode == "silent")
			{
				checkoutDetails = integrationName + "|None|" + objectsInfo + "@" + launchCADTool;	
				mxmcadApplet.callCommandHandler(integrationName, "doSilentCheckout", checkoutDetails);			
			}
		}
		
	}
	else
	{
		var checkoutDetails;		
		if(mode == "interactive")
		{
			checkoutDetails = integrationName + "|None|" + objectsInfo + "@" + launchCADTool;
		mxmcadApplet.callCommandHandler(integrationName, "createCheckoutPage", checkoutDetails);
	}
		else if(mode == "silent")
		{
			checkoutDetails = integrationName + "|None|" + objectsInfo + "@" + launchCADTool;
			mxmcadApplet.callCommandHandler(integrationName, "doSilentCheckout", checkoutDetails);
		}
		else
			alert("Undefined mode of checkout.");
	}
	
}

//------------------------------------------------------------------------
// Method checkoutWithValidation(objectID, instanceName, representationName)
// This function call applet and get the valid checkout object id.
//
// Parameters:
//   integrationName - name of the CSE
//	 objectID - business object id
//   instanceName - instance name for configurations
//   representationName - representation name ProE files.
//   dmuSessionName - DMUSession object name.
// Returns:
//------------------------------------------------------------------------

function checkoutWithValidation(integrationName, objectID, instanceName, representationName, dmuSessionName, mode, launchCADTool)
{
	var integrationFrame = getIntegrationFrame(this);
	//cannot go ahead if unable to locate integration frame.
	if(integrationFrame == null)
	{
		alert("Integration Applet is not available. Please close the browser and login again.");
		return;
	}

	var checkoutStatusDetails = integrationFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, "getValidCheckoutObjectID", objectID);

	//Type casting to String type
	checkoutStatusDetails = checkoutStatusDetails + "";

	var checkoutStatusElements	= checkoutStatusDetails.split('|');
	var checkoutDetails			= checkoutStatusElements[1] + "|" + instanceName + "|" + representationName + "|" + dmuSessionName;

	checkout(integrationName, checkoutStatusElements[0], checkoutDetails, checkoutStatusElements[2], mode, launchCADTool);
}

function displayLockUnLock(strURL)
{
   //alert(strURL);
   var targetFrame = findHiddenFrame(top, "hiddenTableFrame");	   	   
   if(targetFrame != null)
	targetFrame.location.href=strURL;
}

function findHiddenFrame(objWindow, strName) {

	if( ! objWindow.frames )
		return null;
	var objFrame = objWindow.frames[strName];
	if (!objFrame) {
		for (var i=0; i < objWindow.frames.length && !objFrame; i++)
		{
			objFrame = findFrame(objWindow.frames[i], strName);
		}
	}

	return objFrame;
}

//-----------------------------------------------------------------------
// Method callCommandHandler(integrationName, methodName, arguments)
// This function searches for the Integration frame and returns it, if it finds one.
//
// Parameters:
//   integrationName - Name of the CSE
//	 methodName - name of the method for the operation
//	 arguments - arguments for the method
//   Returns:
//------------------------------------------------------------------------

function callCommandHandler(integrationName, methodName, arguments)
{
	var integrationFrame = getIntegrationFrame(this);

	//cannot go ahead if unable to locate integration frame.
	if(integrationFrame == null)
	{
		alert("Integration Applet is not available. Please close the browser and login again.");
		return;
	}

	var msg = integrationFrame.getAppletObject().callCommandHandler(integrationName, methodName, arguments);
	return msg;
}

//------------------------------------------------------------------------
// Method getQueryString(parametersArray, valueSeperator, paramSeperator)
// This function prepares the queryString to send it to applet.
//
// Parameters:
//   parametersArray - parameters array
//	 valueSeperator - seperator to seperate param name-value pair
//	 paramSeperator - seperator to seperate different parameters
//   Returns: queryString
//------------------------------------------------------------------------

function getQueryString(parametersArray, valueSeperator, paramSeperator)
{
	var queryString = "";

	for(var parameterName in parametersArray)
    {
		var parameterValue	= parametersArray[parameterName];
        
		if(queryString == "")
			queryString = parameterName + valueSeperator +  parameterValue;
		else
			queryString = queryString + paramSeperator + parameterName + valueSeperator +  parameterValue;
	}
	return queryString;
}

function ltrim ( s )
{
	return s.replace( /^\s*/, "" );
}

function rtrim ( s )
{
	return s.replace( /\s*$/, "" );
}

function trim ( s )
{
	return rtrim(ltrim(s));
}

function replaceAll(str, find, repl) 
{
	 str = str + "";
	while(true) 
	{
		if(str.indexOf(find) == -1) 
			return str;

		str = str.replace(find, repl);
	}
	return str;
}

//------------------------------------------------------------------------
// Method validateForBadChars(badCharList, stringToValidate)
// This function validates input string for bad characters
//
// Parameters:
//   badCharList	  - List of invalid characters which are delimited by a space
//						For example, / | * ^ ( ) [ ] { } = < > $ % & ! ? \\ \" ; : , ' ?
//	 stringToValidate - String which is to be validated for bad characters
//
//   Returns: true, if no bad character found in the input string; false
//			  otherwise	
//------------------------------------------------------------------------

function validateForBadChars(badCharList, stringToValidate)
{
	for(var i=0; i< badCharList.length; ++i) 
	{
		var badChar = badCharList.charAt(i);
		if(badChar == " ")
		{
			continue;
		}

		if(stringToValidate.indexOf(badChar) >= 0)
		{
			return false;
		}
	}

	return true;
}

function hexEncode(integrationName, inputStr)
{ 	
	var encodedStr = "";
	if(integrationName != null && integrationName != "")
	{
		var integrationFrame = getIntegrationFrame(this);
		encodedStr = integrationFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, "hexEncode", inputStr);
	}
	else
		encodedStr = inputStr;	
	
	return encodedStr;
}

function hexEncodeWithoutIntegName(inputStr)
{ 	
	var integrationFrame = getIntegrationFrame(this);
	var encodedStr = integrationFrame.getAppletObject().callCommandHandlerSynchronously("", "hexEncode", inputStr);

	
	return encodedStr;
}

function hexDecode(integrationName, inputStr)
{ 	
	var decodedStr = "";
	if(integrationName != null)
	{
		var integrationFrame = getIntegrationFrame(this);
		decodedStr = integrationFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, "hexDecode", inputStr);

	}
	else
		decodedStr = inputStr;	
	
	return decodedStr;
}

function validateBusObject(integrationName,type,name,revision)
{
	var isExists = "false";
	if(integrationName != null && integrationName != "")
	{
		var integrationFrame = getIntegrationFrame(this);
		var inputBusDetails = integrationName + "|" + type + "|" + name + "|" + revision;
		isExists  = integrationFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, "validateBusObject", inputBusDetails);
	}
	
	return isExists;
}

function getBusIDFromTNR(integrationName,type,name,revision)
{
	var busID = "";
	if(integrationName != null && integrationName != "")
	{
		var integrationFrame	= getIntegrationFrame(this);
		var inputBusDetails		= integrationName + "|" + type + "|" + name + "|" + revision;
		busID					= integrationFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, "getBusIDFromTNR", inputBusDetails);
	}

	return busID;
}

function getTNRFromBusID(integrationName, busID)
{
	var tnrDetails ="";
	if(integrationName != null && integrationName != "")
	{
		var integrationFrame	= getIntegrationFrame(this);
		var inputBusDetails		= integrationName + "|"+ busID;
		tnrDetails				= integrationFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, "getTNRFromBusID", inputBusDetails);
	}

	return tnrDetails;
}

function checkIfLocked(integrationName,busID)
{
	var isLocked = "false";
	if(integrationName != null && integrationName != "")
	{
		var integrationFrame = getIntegrationFrame(this);
		var inputBusDetails = integrationName + "|"+ busID;
		isLocked  = integrationFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, "checkIfLocked", inputBusDetails);
	}
	return isLocked;
}

function showFinalizationPage(iefIntegrationName, finalizationDetails)
{
	var integrationFrame = getIntegrationFrame(this);
	integrationFrame.setBrowserCommandOpener(this);
	
	integrationFrame.getAppletObject().callCommandHandler(iefIntegrationName, "createFinalizationPage", finalizationDetails);

}

function showUndoFinalizationPage(iefIntegrationName, busID, pathWithAppName)
{
	var integrationFrame = getIntegrationFrame(this);
	integrationFrame.setBrowserCommandOpener(this);
	
	var undoFinalizedURL = pathWithAppName + "/integrations/MCADUndoFinalization.jsp?busDetails=" + iefIntegrationName + "|true|" + busID;
	integrationFrame.showIEFModalDialog(undoFinalizedURL, 400, 400);
}

function showSaveAsPage(iefIntegrationName, saveAsDetails)
{
	var integrationFrame = getIntegrationFrame(this);
	integrationFrame.setBrowserCommandOpener(this);
	
	integrationFrame.getAppletObject().callCommandHandler(iefIntegrationName, "createSaveAsPage", saveAsDetails);

}

function showEBOMSynchPage(iefIntegrationName, sEBOMSynchDetails)
{
	var integrationFrame = getIntegrationFrame(this);
	integrationFrame.setBrowserCommandOpener(this);
	
	integrationFrame.getAppletObject().callCommandHandler(iefIntegrationName, "createEBOMSynchPage", sEBOMSynchDetails);

}


function openWindow(strURL)
{
	window.open(strURL);
}

function validateExpandLevel(expansionLevel, defaultExpandLevel, formName, invalidLevelMessage) 
{
	var validArgs	= true;
	var filterLevel = frames['headerDisplay'].document.forms[formName].filterLevel.value;

	if(filterLevel != "All")
	{
		if (isNaN(expansionLevel) == true)
		{
			alert(invalidLevelMessage);
			frames['headerDisplay'].document.forms[formName].showLevel.value = defaultExpandLevel;
			frames['headerDisplay'].document.forms[formName].showLevel.focus();
			validArgs = false;
		}
		else
		{
			var isValid = isValidNumber(expansionLevel);
			if(isValid == false)
			{
				alert(invalidLevelMessage);
				frames['headerDisplay'].document.forms[formName].showLevel.value = defaultExpandLevel;
				frames['headerDisplay'].document.forms[formName].showLevel.focus();
				validArgs = false;
			}
		}
	}
	else
	{
		if(expansionLevel.toUpperCase() != "ALL")
		{
			alert(invalidLevelMessage);
			frames['headerDisplay'].document.forms[formName].showLevel.value = "ALL";
			frames['headerDisplay'].document.forms[formName].showLevel.focus();
			validArgs = false;
		}
	}
	return validArgs;
}

// Treats zero and decimal as invalid entries.
function isValidNumber(expansionLevel)
{
	var ValidChars		= "0123456789";
	var isValidNumber	= true;
	var Char;
	var level = parseInt(expansionLevel, 10);
	if(level > 0)
	{
		for (i = 0; i < expansionLevel.length && isValidNumber == true; i++) 
		{ 
			Char = expansionLevel.charAt(i); 
			if (ValidChars.indexOf(Char) == -1) 
			{
				isValidNumber = false;
			}
		}
	}
	else
	{
		isValidNumber = false;
	}

	return isValidNumber;
}

function openWindow(strURL)
{
	window.open(strURL);
}

function getHtmlSafeString(message)
{
	var messageString = message + "";

	messageString = messageString.replace(/&/g,"&amp;");
	messageString = messageString.replace(/\"/g,"&quot;");
	messageString = messageString.replace(/</g,"&lt;");
	messageString = messageString.replace(/>/g,"&gt;");
	messageString = messageString.replace(/\\\\/g,"\\\\");
	messageString = messageString.replace(/\n/g,"<br>");
	messageString = messageString.replace(/\t/g,"&nbsp&nbsp&nbsp");
	
	return messageString;
}

/**
 * Returns the value of a given parameter from the given url if parameter is present in url 
 * otherwise retirns null
 */
function getParameterFromURL(urlVal, parameterName)
{
	var paramValue = null;
	var tempParameterName   = parameterName+"=";
	if(urlVal != null && urlVal.indexOf("?") != -1 && urlVal.indexOf(tempParameterName) != -1)
	{
		var urlParameters       = urlVal.substring(urlVal.indexOf("?")+1);
	 	var urlParametersArray  = urlParameters.split("&");
	 	for(var i = 0 ; i < urlParametersArray.length ; i++)
	 	{
	 	    if(urlParametersArray[i].indexOf(tempParameterName) != -1)
	 		{
	 	    	paramValue = urlParametersArray[i].substring(tempParameterName.length);
	 		    break;
	 		}
	 	
	 	}
	}
	return paramValue;
}

/**
 * add or replace parameter to given url
 */
function addParameterToURL(urlVal, paramName, paramValue)
{
	var updatedURL = urlVal;
	if(updatedURL != null)
	{
		if(updatedURL.indexOf("?") == -1)// there is no query string
		{
			updatedURL = updatedURL + "?" + paramName + "=" + paramValue;
		}
		else if(urlVal.indexOf(paramName) == -1)//parameter is not there in url
		{
			updatedURL = updatedURL + "&" + paramName + "=" + paramValue;
		}	
		else
		{
			var uriOnly     =  urlVal.substring(0, urlVal.indexOf("?"));
		    var queryString =  urlVal.substring(urlVal.indexOf("?")+1);

		 	var urlParametersArray  = queryString.split("&");
			var updatedParametersArray = new Array;	

		 	for(var i = 0 ; i < urlParametersArray.length ; i++)
		 	{
				var parameterName  = urlParametersArray[i].substring(0,urlParametersArray[i].indexOf("="));
				var parameterValue = urlParametersArray[i].substring(urlParametersArray[i].indexOf("=")+1)

				if(parameterName == paramName)
				{
					parameterValue = paramValue;
				}
				updatedParametersArray[parameterName] = parameterValue;
		 	}
		 	var updatedQueryString = getQueryString(updatedParametersArray, "=", "&");
		 	updatedURL = uriOnly + "?" + updatedQueryString;
		 	
		}
	}
	return updatedURL;
}

