/*  IEFHelpInclude.js

   Copyright Dassault Systemes, 1992-2007. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

*/

/*------------------------------------------------------------------------
argument : pageTopic - should be helpMarkerMacro.
This will be passed to IEFHelp.jsp as a parameter.

childWindow is opened to show help page.
In case childwindow is still in opened state and help icon is pressed, help html should be displayed in opened child window.
------------------------------------------------------------------------*/
var childWindow=null;
function openIEFHelp(pageTopic) 
{
	var url = "IEFHelp.jsp?helpMarker=" + pageTopic;
	if ((childWindow == null) || (childWindow.closed))
	{
		childWindow = window.open(url,"","location=no,menubar=no,titlebar=no,width=700,height=700,resizable=yes,scrollbars=yes");
		childWindow.focus();
	} 
	else 
	{
		childWindow.location.replace(url);
		childWindow.focus();
	}
	return;
}

function openHelp(pageTopic, directory, lStr) 
{
	if(directory=="components")
		var url = "../../integrations/IEFHelp.jsp?helpMarker=" + pageTopic;
	else if(directory == "ief")
		var url = "./IEFHelp.jsp?helpMarker=" + pageTopic;
	else
		var url = "../integrations/IEFHelp.jsp?helpMarker=" + pageTopic;

	if ((childWindow == null) || (childWindow.closed))
	{
		childWindow = window.open(url,"","location=no,menubar=no,titlebar=no,width=700,height=700,resizable=yes,scrollbars=yes");
		childWindow.focus();
	} 
	else 
	{
		childWindow.location.replace(url);
		childWindow.focus();
	}
	return;
}


/*------------------------------------------------------------------------
	This method is similar to openIEFHelp, with difference that if help is available in 
	webworks format (rather than html), this is useful.
------------------------------------------------------------------------*/

function openIEFWebworksHelp(pageTopic, directory, langStr) 
{
	directory = directory.toLowerCase();

	if ((childWindow == null) || (childWindow.closed))
	{
		var url = "../doc/" +  directory + "/" + langStr + "/wwhelp/js/html/frames.htm?context=" + directory + "&topic=" + pageTopic;
		childWindow = window.open(url,"","location=no,menubar=no,titlebar=no,width=700,height=700,resizable=yes,scrollbars=yes");
		childWindow.focus();
	} 
	else 
	{
		var url = "../doc/" +  directory + "/" + langStr + "/wwhelp/js/html/frames.htm?context=" + directory + "&topic=" + pageTopic;
		childWindow.location.replace(url);
		childWindow.focus();
	}

	return;
}
