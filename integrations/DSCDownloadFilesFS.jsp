<%--  DSCDownloadFilesFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--   Perform refresh (i.e. checkout current) on selected files

--%>

<%@ include file="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ include file="../iefdesigncenter/emxInfoTableInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<html>
<%
	String requestURI		= request.getRequestURI();
	String acceptLanguage	= request.getHeader("Accept-Language");
	String featureName		= MCADGlobalConfigObject.FEATURE_CHECKOUT;

	// Retrieve the information about the selected objects

	Vector objs					= new Vector();
	String objIDs				=Request.getParameter(request,"objectIds");
	StringTokenizer objIDTokens = new StringTokenizer(objIDs,",");
	while(objIDTokens.hasMoreTokens())
	{
		objs.add(objIDTokens.nextToken());
	}

	// Retrieve the obtained command
    String integrationName		=Request.getParameter(request,"integName");

	String queryString			= "";
	String objNameStringList	= "";

	MCADIntegrationSessionData integSessionData		= (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");

	MCADSessionData sessionData = integSessionData.getSessionData();
	Context context				= integSessionData.getClonedContext(session);
	MCADMxUtil util				= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	Hashtable alreadyProcessedObjectIdDetails = new Hashtable();
	// Create the query string for all the objects that are selected for download
	for(int index=0; index < objs.size();index++)
	{
		String ids				= (String)objs.elementAt(index);
		StringTokenizer tokens	= new StringTokenizer(ids, "|");
		String sFileName		= tokens.nextToken();
        String sFileFormat		= tokens.nextToken();
		String busId			= tokens.nextToken();
		String objName			= "";
		String objType			= "";
		String objRev			= "";

		if(!alreadyProcessedObjectIdDetails.containsKey(busId))
		{
			BusinessObject busObject = new BusinessObject(busId);
			busObject.open(context);

			//get the object details  from this object
			objName = busObject.getName();
			objType = busObject.getTypeName();
			objRev  = busObject.getRevision();

			Vector objectDetails = new Vector(5);

			if(integrationName == null || integrationName.equals(""))
				integrationName			= util.getIntegrationName(context, busId);

			String isFeatureAllowed		= integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
			if(!isFeatureAllowed.startsWith("true"))
			{
				String errorMessage = isFeatureAllowed.substring(isFeatureAllowed.indexOf("|")+1, isFeatureAllowed.length());
%>
<SCRIPT LANGUAGE="JavaScript">
                //XSSOK
				alert("<%= errorMessage %>");
				window.close();
</SCRIPT>
<%
			}

			objectDetails.add(objName);
			objectDetails.add(objType);
			objectDetails.add(objRev);

			alreadyProcessedObjectIdDetails.put(busId,objectDetails);

			busObject.close(context);
		}
		else
		{
			// Get the information from the hashtable maintained
			Vector objectDetails = (Vector)alreadyProcessedObjectIdDetails.get(busId);
			objName = (String)objectDetails.get(0);
			objType = (String)objectDetails.get(1);
			objRev  = (String)objectDetails.get(2);
		}


		ids = ids + "|" + objName + "|" + objType + "|" + objRev;

		if(index == 0)
		{
			queryString = ids;
			objNameStringList =  sFileName;
		}
		else
		{
			queryString = queryString + ";" + ids ;
			objNameStringList =  objNameStringList + "|" +  sFileName;
		}
	}
	String contentURL = "DSCDownloadFilesContent.jsp?objectlist=" + objNameStringList;
%>

<head>

<script language="javascript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">
<%@include file = "IEFTreeTableInclude.inc"%>

var framebottomDisplay = null;


function loadFrame()
{
     framebottomDisplay = findFrame(this,"bottomDisplay");
}
function downloadSelected()
{
	var integFrame	= getIntegrationFrame(this);
    //XSSOK
	var queryString	= "<%= queryString %>";
	var pageOptions = getPageOptions();
	queryString = queryString + "," + pageOptions;
    var integFrame	= getIntegrationFrame(this);

	if(pageOptions != null && pageOptions !="" )
	{
		integFrame.getAppletObject().callCommandHandler('<%=XSSUtil.encodeForJavaScript(context, integrationName) %>',"downloadAttachmentFiles", queryString);

		if(!isAccessibleFromApplet(this))
			window.close();
    } else
	    //XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.ChooseCheckoutDirectory")%>");
}

function isAccessibleFromApplet(win)
{
	if(win.top.opener)
	{
		if(win.top.opener.top.modalDialog && win.top.opener.top.modalDialog.contentWindow && !win.top.opener.top.modalDialog.contentWindow.closed)
		{
			return isAccessibleFromApplet(win.top.opener);
		} else
			return false;
   }
	else
    {
		return true;
    }
}

function closeWindow()
{
   	var integrationName			= "<%=XSSUtil.encodeForJavaScript(context,integrationName) %>";
	var integFrame				= getIntegrationFrame(this);

	integFrame.activeDirectoryChooserControl = null;

	integFrame.getAppletObject().callCommandHandler(integrationName, "cancelOperation", true);

	window.close();
}

function downloadCancelled()
{
	closeWindow();
}

function showAlert(message, closeWindow)
{
	alert(message);
	if(closeWindow == "true")
	{
		window.close();
	}
}

function getQueryString()
{
    //XSSOK
	var queryString = "<%=objNameStringList%>";
	return queryString;
}



function showDirectoryChooser()
{
	var integrationName			= "<%=XSSUtil.encodeForJavaScript(context, integrationName) %>";
	var integFrame				= getIntegrationFrame(this);
        var checkoutDirectoryField = null;
        if(framebottomDisplay)
	          checkoutDirectoryField = framebottomDisplay.document.forms["directoryChooser"].workingDirectory;
        
	integFrame.showDirectoryChooser(integrationName, checkoutDirectoryField, "");
}

function getPageOptions()
{
	var workingDirectory       = framebottomDisplay.document.forms["directoryChooser"].workingDirectory.value;
	var pageOptions			   = workingDirectory;
    return pageOptions;
}
</script>
</head>

<frameset rows="80,*,110,0" frameborder="yes" framespacing="2" onLoad="javascript:loadFrame()">
<frame name="headerDisplay" src="DSCDownloadFilesHeader.jsp" scrolling=no>
<frame name="tableDisplay"  src="<%=contentURL%>" marginheight="3" scrolling=yes>
<frame name="bottomDisplay" src="DSCDownloadFilesFooter.jsp?integrationName=<%=XSSUtil.encodeForJavaScript(context,integrationName)%>" scrolling=no >
</frameset>

</html>

