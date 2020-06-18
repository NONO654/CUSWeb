<%--  silentiefutils.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%!
  // Call this method to internationalize variables in java.
  static public String i18nStringNowUtil(String text,String Bundle, String languageStr) {
    i18nNow loc = new i18nNow();
    return (String)loc.GetString(Bundle, languageStr, text);
  }
%>

<%
   String userNameHeading = i18nStringNowUtil("emxNavigator.UIHeader.UserName","emxFrameworkStringResource",acceptLanguage);
	//Following code is for the silent applet page only. This code to for showing the full user name in case the user refres the browser page.
	String userNameFromContext = "";
	String userNameToDisplay = "";
	if(context != null)
	{
		userNameFromContext = context.getUser();

		MQLCommand mqlc = new MQLCommand();

		try
		{
			String mqlCommand = "print Person '" + userNameFromContext + "' select fullname dump";
			boolean status = mqlc.executeCommand(context, mqlCommand);
			if (status)
			{
			    userNameFromContext = mqlc.getResult();
			    userNameFromContext = userNameFromContext.replace('\n',' ');
			}
		}
		catch(MatrixException me)
		{
		}

		userNameToDisplay = userNameHeading + ": " + userNameFromContext;
	}
	//Above code is for the silent applet page only. This code to for showing the full user name in case the user refres the browser page.
%>
<script language="JavaScript" src="../scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="JavaScript" src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%@ include file="../common/emxUIConstantsInclude.inc" %>
<script language="JavaScript" src="../common/scripts/emxUITableUtil.js" type="text/javascript"></script>
<script language="JavaScript">
var windowWidth  = 850;
var windowHeight = 600;
var isCustomLiveConnect = <%=bCustomLiveConnect%>;
function bringForward(arg)
{
	window.focus();

	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		top.modalDialog.contentWindow.focus();
	}
}

function redirectToNewURL(arg)
{
	if(isCustomLiveConnect)
	{
		arg = getAppletObject().getJSArgs(0);
	}

	sForwardURL = arg;
	setTimeout('top.window.location = sForwardURL;',2500);
}

function showAlert(message, closeWindow)
{
	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		top.modalDialog.contentWindow.showAlert(message, closeWindow);
	}
	else
	{
		alert(message);
	}
}

function isBrowserIE()
{
	if(isIE)
		return "true";
	else
		return "false";
}

function getWindowTitle()
{
	return top.window.document.title;
}

function showLoggedinUser(userName)
{
	var objDiv = document.getElementById("loggedinUser");
	objDiv.innerHTML = "<%=userNameHeading%>: " + userName;
}

function showLoggedinUserAfterRefresh()
{
    //XSSOK
	if("<%=userNameToDisplay%>" != "")
	{
		var objDiv = document.getElementById("loggedinUser");
		//XSSOK
		objDiv.innerHTML = "<%=userNameToDisplay%>";
	}
}

function msoiShowObjectTree(busId, suiteDirectoryName, treeMenuName)
{
	var url = "../common/emxTree.jsp?emxSuiteDirectory="+suiteDirectoryName+"&treeMenu="+treeMenuName+"&relId=&parentOID=&jsTreeID=root&suiteKey=Framework&objectId=" + busId;
	emxTableColumnLinkClick(url, windowWidth, windowHeight, 'false', 'popup', 'Show Content');	
}

</script>
