<%--  IEFTableInclude.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ page import = "com.matrixone.MCADIntegration.server.*" %>
<%
	String matrixAppName = application.getInitParameter("ematrix.page.path");

	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(request.getHeader("Accept-Language"));
	String errorMessageForCues = serverResourceBundle.getString("mcadIntegration.Server.Message.CuesNotSupported");
%>

<Script language="javascript">

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

	function updateFrames(contentFrame, headerFrame, footerFrame, pageHeader, encodedDefaultContentURL, encodedDefaultFooterURL, timeStamp, tableName, isPopup, funcPageName, objectId, integrationName, headerToolbar, printerFriendly, helpMarker)
	{                
        //XSSOK	
		var matrixAppName = '<%=matrixAppName%>';	
		
		var pageUrl = matrixAppName + "/iefdesigncenter/IEFTableContent.jsp?tableName=" + hexEncode(integrationName, tableName) + "&timeStamp=" + timeStamp + "&encodedDefaultPageURL=" + encodedDefaultContentURL;
		contentFrame.document.location = pageUrl;

		var footerpageUrl = matrixAppName + "/iefdesigncenter/IEFTableFooter.jsp?encodedDefaultFooterPage=" + encodedDefaultFooterURL + "&tableName=" + hexEncode(integrationName, tableName) + "&isPopup=" + isPopup;
		footerFrame.document.location = footerpageUrl;

		var headerUrl = matrixAppName + "/iefdesigncenter/IEFTableHeader.jsp?header=" + pageHeader + "&topActionbar=" + headerToolbar + "&PrinterFriendly=" + printerFriendly + "&HelpMarker=" + helpMarker + "&timeStamp="+ timeStamp + "&encodedContentURL=" + encodedDefaultContentURL + "&tableName=" + hexEncode(integrationName, tableName) + "&encodedDefaultFooterPage=" + encodedDefaultFooterURL + "&isPopup=" + isPopup + "&pageHeader=" + pageHeader + "&funcPageName=" + funcPageName + "&objectId=" + objectId;
		headerFrame.document.location = headerUrl;		
		
		return;
	}

	function sessionCleanup(timeStamp, funcPageName)
	{
		//call the cleanup session page which deletes object list from the session
		//opening a hidden window to ensure that cleanup session will always gets called

		//XSSOK
		var appName     = '<%=matrixAppName%>';
		var url		=  appName + "/iefdesigncenter/emxInfoTableCleanupSession.jsp?timeStamp=" + timeStamp + "&funcPageName=" + funcPageName;
		var winParams	= "width=1,height=1,screenX=1500,screenY=1500,top=1500,left=1500,resizable=no";

		var win = window.open(url, "CleanUp", winParams);		
	}

 	// Function FUN080585 : Removal of Cue, Tips and Views

	function onWSTableOptionChange(contentFrame, headerFrame, footerFrame, pageHeader, encodedDefaultContentURL, encodedDefaultFooterURL, timeStamp, isPopup, funcPageName, objectId, integrationName, defaultTableName, headerToolbarName, printerFriendly, helpMarker)
	{	

		var tableName = document.tableHeaderForm.workSpaceTable.options[document.tableHeaderForm.workSpaceTable.selectedIndex].text;
		var tableValue = document.tableHeaderForm.workSpaceTable.options[document.tableHeaderForm.workSpaceTable.selectedIndex].value;
		if(tableName.indexOf(tableValue) == -1)
		{
			tableName = tableName.substring(0, tableName.indexOf(':') + 1) + tableValue;
		}

		if(defaultTableName == tableName)
			tableName = "Default";

		updateFrames(contentFrame, headerFrame, footerFrame, pageHeader, encodedDefaultContentURL, encodedDefaultFooterURL, timeStamp, tableName, isPopup, funcPageName, objectId, integrationName, headerToolbarName, printerFriendly, helpMarker);
	}

</Script>
