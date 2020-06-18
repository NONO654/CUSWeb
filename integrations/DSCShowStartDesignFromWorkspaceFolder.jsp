<%--  DSCAppletUtils.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);

	//this is workspacefolder id
	String objectId  = emxGetParameter(request,"objectId");

	String integrationName		= "";
	Boolean showChooser			= false;
	MCADLocalConfigObject localConfigObject = integSessionData.getLocalConfigObject();

	Hashtable integrationNameGCONameMap = localConfigObject.getIntegrationNameGCONameMapping();	
	if(integrationNameGCONameMap.size() > 0)
	{
		if(integrationNameGCONameMap.containsKey(MCADAppletServletProtocol.CT5_INTEG_NAME))
			integrationName = MCADAppletServletProtocol.CT5_INTEG_NAME;
        
		if(integrationNameGCONameMap.containsKey(MCADAppletServletProtocol.CT4_INTEG_NAME))
			integrationName = MCADAppletServletProtocol.CT4_INTEG_NAME;	
	
		if(integrationNameGCONameMap.containsKey(MCADAppletServletProtocol.CT4_INTEG_NAME) &&	integrationNameGCONameMap.containsKey(MCADAppletServletProtocol.CT5_INTEG_NAME))
		{
				showChooser = true;
		}	
	}
	
%>
<script language="JavaScript" src="scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<html>

<head>
<script language="JavaScript">

var folderId		= '<%=XSSUtil.encodeForJavaScript(context,objectId)%>';
//XSSOK
var showChooser		= '<%=showChooser%>';
//XSSOK
var integrationName	= '<%=integrationName%>';

// to send the workspacefolder id to start design

function showIntegChooserForStartDesignFromWorkspace(workspaceFolderId)
{	
	var integFrame = getIntegrationFrame(this);
	var mxmcadApplet = integFrame.getAppletObject(); 

	var isCheckoutRequired		= "FALSE";
	var isFolderDisabled		= "TRUE";	

	var startDesignDetails = "none|"+ workspaceFolderId + "|" + isCheckoutRequired + "| none |" + isFolderDisabled;

	//check whether applet is loaded
	var isAppletInited = mxmcadApplet && mxmcadApplet.getIsAppletInited();

	var targetFrame		= top.findFrame(top, "detailsDisplay");

	integFrame.setActiveRefreshFrame(targetFrame);
	if(isAppletInited == true)
	{
		var preferredIntegration	= mxmcadApplet.callCommandHandlerSynchronously("", "getPreferredIntegrationName", "");
		if(preferredIntegration == "MxCATIAV5" || preferredIntegration == "MxCATIAV4")
			showChooser =false;

		if(showChooser == true)
		{
			showIEFModalDialog("./IEFIntegrationChooserFS.jsp?keepOpen=false&eventHandler=createStartDesignPage&allowedIntegrations=MxCATIAV5|MxCATIAV4&folderId="+folderId, "300", "325");
		}
		else
		{
			mxmcadApplet.callCommandHandler(integrationName, "createStartDesignPage", startDesignDetails);
		}
	}
	else
	{
		showIEFModalDialog("emxAppletTimeOutErrorFS.jsp", 400, 300);
	}
}


function createStartDesignPage(selectedIntegrationName,folderId)
{
	var isCheckoutRequired		= "FALSE";
	var isFolderDisabled	    = "TRUE";
	var integFrame	= getIntegrationFrame(this);
	var startDesignDetails = "none|"+ folderId + "|" + isCheckoutRequired + "| none |" + isFolderDisabled;
	integFrame.getAppletObject().callCommandHandler(selectedIntegrationName, "createStartDesignPage", startDesignDetails);
}
</script>

</head>

<body onload= showIntegChooserForStartDesignFromWorkspace("<%=objectId%>")>

</body>
</html>
