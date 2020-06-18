<%-- ief.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@ page import="com.matrixone.apps.framework.ui.*, com.matrixone.MCADIntegration.server.cache.*,com.matrixone.MCADIntegration.utils.*, com.matrixone.apps.domain.util.*" %>
<%@ page import="com.matrixone.apps.domain.util.PropertyUtil,com.matrixone.apps.framework.ui.UIMenu,com.matrixone.apps.framework.ui.UIComponent,com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@ include file="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>

<html>

<head>

<script language="JavaScript">

function callJSMethodFromApplet()
{
	var retVal = "";
	try
	{
		var integFrame = getIntegrationFrame(this);
		var mxmcadApplet = integFrame.getAppletObject();
		var jsMethodName = mxmcadApplet.getJSMethodName();
		if(jsMethodName != "")
		{
			retVal = eval( jsMethodName + "();" );
			try
			{
				if(retVal == "")
					retVal = "true";
				mxmcadApplet.setJSMethodRetVal(retVal);
			}
			catch(errorObject)
			{
				alert("Error from callJSMethodFromApplet - can not set retVal ::" + errorObject.description);
			}
		}
	}
	catch(error)
	{
		alert("Error from callJSMethodFromApplet ::" + error.description);
	}

	window.setTimeout("callJSMethodFromApplet()", 200);
}

</script>

</head>

<body>

<%
	//IR-502293-3DEXPERIENCER2016x: As BPS introduced new filters in emxSystem.properties, the below code changes were made
	String sProtocol, sPort, sHost, refServer;

	//check for forwarded first
	sProtocol = request.getHeader("X-Forwarded-Proto");
	sPort     = request.getHeader("X-Forwarded-Port");
	sHost     = request.getHeader("X-Forwarded-Host");
	
	//if not forwarded use regular
	if (sProtocol == null) {
		sProtocol = request.getScheme();
	}
	if (sPort == null) {
		sPort = "" + request.getLocalPort();
	}
	if (sHost == null) {
		sHost = request.getServerName();
	} else { //port sometimes comes thru in the X-Forwarded-Host, so clean up
		int portIndex = sHost.indexOf(':');
		if (portIndex != -1) {
			 sPort = sHost.substring(portIndex + 1);
			 sHost = sHost.substring(0, portIndex);
		}
	}
	
	refServer = sProtocol + "://" + sHost;
	if (sPort.length() > 0) {
		refServer += ":"+ sPort;
	}
		
	String requestURI   = request.getRequestURI();

    String pathWithIntegrationsDir	= requestURI.substring(0, requestURI.lastIndexOf('/'));
    String pathWithAppName			= pathWithIntegrationsDir.substring(0, pathWithIntegrationsDir.lastIndexOf('/'));

	//referer value was incorrect due to these filters, "//" was missing from the url
    //String referer		= request.getHeader("referer");
    //String refServer	= referer.substring( 0, referer.indexOf(Framework.getPagePathURL("")));

    String appName = application.getInitParameter("ematrix.page.path");
    if(appName == null)
		appName = "";

    String virtualPath								= refServer + appName;

    Context context									= Framework.getFrameContext(session);

    ResourceBundle mcadIntegrationBundle			= ResourceBundle.getBundle("ief");
    String acceptLanguage							= request.getHeader("Accept-Language");
    MCADServerResourceBundle serverResourceBundle	= new MCADServerResourceBundle(acceptLanguage);
	String supportFamilyInStartDesign				= "false";
	try
	{
	if(mcadIntegrationBundle.getString("mcadIntegration.SupportFamilyInStartDesign") != null)
	{
		supportFamilyInStartDesign = mcadIntegrationBundle.getString("mcadIntegration.SupportFamilyInStartDesign");
	}
	}
	catch(Exception ex)
	{
		supportFamilyInStartDesign				= "false";
	}

    session.setAttribute("MCADIntegration-CurrentApplicationName", "verdi");

	//Find whether IntegrationApplet can be loaded for this user
	IEFIntegAccessUtil mcadUtil = new IEFIntegAccessUtil(context, (MCADServerResourceBundle)null, new IEFGlobalCache());
	boolean isMCADIntegActive	= false;
	
	try
	{
		isMCADIntegActive = mcadUtil.isIEFEnabledForUser(context, acceptLanguage);
	}
	catch(Exception exception)
	{
		String errorMessage	= MCADServerException.getErrorMessage(serverResourceBundle.getString("mcadIntegration.Server.Message.IEF0012200040"), exception);
		String errorCode	= MCADServerException.getErrorCode("IEF0012200040", exception);
		//errorMessage		= errorCode + ": " + errorMessage;

		emxNavErrorObject.addMessage(errorMessage);
	}


	//Find whether the user is admin
	Vector userRoles = UICache.getUserRoles(context);
    if(isMCADIntegActive == false)
    {
		String adminRole = mcadUtil.getActualNameForAEFData(context, "role_IEFAdmin");
		String vplmAdminRole = mcadUtil.getActualNameForAEFData(context, "role_VPLMAdmin");
		
		if(userRoles.contains(adminRole))
			isMCADIntegActive = true;
		
    	else if(MCADMxUtil.isRoleAssignedToUser(context, vplmAdminRole) && MCADMxUtil.isSolutionBasedEnvironment(context))
    		isMCADIntegActive = true;
    }

	String mcadPortNumber			= null;
	String isMultiPortRangeEnabled	= null;
	String multiPortRangeMax		= null;
	String multiPortRangeMin		= null;
	String mcadCharset				= null;

    boolean isIEFDebugEnabled = false;
    if(isMCADIntegActive)
    {
	    isIEFDebugEnabled = mcadUtil.isIEFDebugEnabledForUser(context, acceptLanguage);
        try
        {
            //If user has access to MCAD Integration, try to get the port number to use.
            mcadPortNumber = mcadIntegrationBundle.getString("mcadIntegration.MCADPortNumber");
        }
        catch(MissingResourceException _ex)
        {
            isMCADIntegActive = false;
            String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.mcadPortNumberNotFound");
            emxNavErrorObject.addMessage(errorMessage);
        }

		try
        {
            isMultiPortRangeEnabled = mcadIntegrationBundle.getString("mcadIntegration.EnableMultiPortRange");
        }
        catch(MissingResourceException excepton)
        {
			System.out.println("EnableMultiPortRange property missing");
		}

		try
        {
            multiPortRangeMax = mcadIntegrationBundle.getString("mcadIntegration.MultiPortRangeMax");
        }
        catch(MissingResourceException excepton)
        {
			System.out.println("MultiPortRangeMax property missing");
		}

		try
        {
            multiPortRangeMin = mcadIntegrationBundle.getString("mcadIntegration.MultiPortRangeMin");
        }
        catch(MissingResourceException excepton)
        {
			System.out.println("MultiPortRangeMin property missing");
		}

		try
        {
			mcadCharset	= mcadIntegrationBundle.getString("mcadIntegration.MCADCharset");
        }
        catch(MissingResourceException _ex)
        {
            System.out.println("Charset not set for IEF");
        }
    }

	/* SSO code start*/
	String ticket			= null;
	String ssoServerUrl		= null;
	String ssoHttpsUrl		= null;
    String isExtAuth		= FrameworkProperties.getProperty("emxFramework.External.Authentication");
	String ssocookie		= request.getHeader("Cookie");

	String sessionId = "JSESSIONID=" + session.getId();
	
	boolean isPropertyAvailable = false;
	boolean isSafari = false;
	boolean isMSIE = false;
	String javaVersionFx = "";
	String jreVersionClassid = "";
	String user_agent = null;		

	try{
		user_agent = request.getHeader( "User-Agent" ).toLowerCase();		
		isSafari = ( user_agent != null && user_agent.indexOf( "safari" ) != -1 );
		isMSIE = ( user_agent != null && user_agent.indexOf( "msie" ) != -1 );	
		javaVersionFx = FrameworkProperties.getProperty(context,"emxFramework.Applet.Firefox.JREVersion");	
		if(null != javaVersionFx && !"null".equals(javaVersionFx) && !javaVersionFx.equals("") && isMSIE != true && isSafari != true)
			isPropertyAvailable = true;
	}catch(Exception excepton){
		isPropertyAvailable = false;
	}

	if(isPropertyAvailable == false)
	{
		try{
			jreVersionClassid = FrameworkProperties.getProperty(context,"emxFramework.Applet.JREVersion");		
			if((null != jreVersionClassid && !"null".equals(jreVersionClassid) && !jreVersionClassid.equals("")) && (isMSIE == true ))
				isPropertyAvailable = true;
		}catch(Exception excepton){
			isPropertyAvailable = false;
		}
	}

	if(isSafari == true)
		isPropertyAvailable = false;	

	if(ssocookie != null && !ssocookie.equals(""))
	{
		sessionId = ssocookie;		
	}

	if(isExtAuth != null && "true".equalsIgnoreCase(isExtAuth))
	{
		ticket	= (String)session.getAttribute("ticket") ;
		session.removeAttribute("ticket");

		//Read the SSO server url from properties file.
		java.util.ResourceBundle iefProperties = java.util.PropertyResourceBundle.getBundle("ief",java.util.Locale.getDefault());
		ssoServerUrl = (String)iefProperties.getString("mcadIntegration.Server.SSOServerUrl");
		ssoHttpsUrl = (String)iefProperties.getString("mcadIntegration.Server.SSOHttpsUrl");

		if(ssoServerUrl !=null)
		ssoServerUrl 	 = MCADUrlUtil.hexEncode(ssoServerUrl);
		if(ssoHttpsUrl !=null)
		ssoHttpsUrl = MCADUrlUtil.hexEncode(ssoHttpsUrl);
	}
	/* SSO code End*/
	
	/*WSM code START*/
		String forwardToWSM = (String) session.getAttribute("forwardToLWSM");
		if(forwardToWSM != null && forwardToWSM.equals("true"))
		{
			session.removeAttribute("forwardToLWSM");
		}
		String lwsmCommandName 	= PropertyUtil.getSchemaProperty(context, "command_DSCMyViewMyDesk");
		String lwmUrl = "";
		HashMap lwsmCommandMap 	= (HashMap) UIMenu.getCommand(context, lwsmCommandName);
		if(lwsmCommandMap != null)
		{
		String lwsmCommandHref = UIComponent.getHRef(lwsmCommandMap);
		String commonDIR = FrameworkProperties.getProperty("eServiceSuiteFramework.CommonDirectory");
		lwmUrl = "/"+ commonDIR+ "/" + lwsmCommandHref;
		}
	/*WSM code END*/

%>

<script language="JavaScript" src="scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">
var sForwardURL = "";

var windowWidth  = 850;
var windowHeight = 600;
var isCustomLiveConnect = <%=isCustomLiveConnect%>;

var activeDirectoryChooserControl;
var directoryChooserStatus = "closed";
var activeBrowserCommandOpener;
var progressWindowObject;
var activeRefreshFrame;
var footerOptions = new Array();

//file overwrite Confirmation dialog content page for checkout operation
var fileOverwriteConfirmWindowContent;

var confirmMessage;

function showObjectTree(busId, suiteDirectoryName, treeMenuName)
{
	var url = "../common/emxTree.jsp?emxSuiteDirectory="+suiteDirectoryName+"&treeMenu="+treeMenuName+"&relId=&parentOID=&jsTreeID=root&suiteKey=Framework&objectId=" + busId;
	emxTableColumnLinkClick(url, windowWidth, windowHeight, 'false', 'popup', 'Show Content');
}

function launchActionURL(url, _windowHeight, _windowWidth)
{
	showIEFModalDialog(url, _windowWidth, _windowHeight, 'true', 'popup', '');
}

function emxTableColumnLinkClick(href, width, height, modal, target)
{
	var url = href;
	var windowObject;
	var targetFrame;

	if (target == "popup")
	{
		if (modal == "true")
			windowObject = showIEFModalDialog(url, width, height,false);
		else
		{
			windowObject = showIEFNonModalDialog(url, width, height);
		}
	}
	else
	{
		targetFrame = findFrame(top, target);

		//if there is a target, assign the form's target to it
		if (targetFrame)
		{
			 targetFrame.location = href;
		}
		else
		{
			windowObject = showIEFNonModalDialog(url, '750', '600');
		}
	}
}

function getAppletObject()
{
	if (document.applets.length > 0) 
	{
		// IE keeps it here
        var app = document.applets.MxMCADApplet;
		return app;
    } else if (document.embeds.length > 0) 
	{	
        // firefox keeps it here		
			return document.embeds.MxMCADApplet;	
	} else {		
   		return "";
	}
}

function releaseCADTool()
{
	var integFrame		= getIntegrationFrame(this);
	var mxmcadApplet	= integFrame.getAppletObject();
	var isAppletInited	= mxmcadApplet && mxmcadApplet.getIsAppletInited();

	if(isAppletInited == true)
	{
		mxmcadApplet.callCommandHandler('', 'releaseCADTool', true);
	}
	else
	{
		showIEFModalDialog("<%=pathWithIntegrationsDir%>/emxAppletTimeOutErrorFS.jsp", 400, 300);
	}

}

function getConfirmMessage()
{
	return confirmMessage;
}

function writeCheckinFrame(queryString)
{
	writeOperationFrame("<%=pathWithIntegrationsDir%>/MCADCheckinFS.jsp", queryString)
}

function writeCheckoutFrame(queryString)
{
	var parametersArray = queryString.split("&");

	for(var i=0 ; i<parametersArray.length ; i++)
	{
		var param	= parametersArray[i].split("=");
		if(param[0] == "confirmMessage")
			confirmMessage = param[1];
	}

	if(queryString.indexOf("confirmMessage") > -1)
	{
		queryString = queryString.substring(0, queryString.lastIndexOf("confirmMessage="));
		queryString = queryString + "confirmMessage=true";
	}

	writeOperationFrame("<%=pathWithIntegrationsDir%>/MCADCheckoutFS.jsp", queryString)
}

function writeLockUnlockFrame(queryString)
{
	writeOperationFrame("<%=pathWithIntegrationsDir%>/MCADLockUnlockFS.jsp", queryString)
}

function writeFinalizationFrame(queryString)
{
	writeOperationFrame("<%=pathWithIntegrationsDir%>/MCADFinalizationFS.jsp", queryString)
}

function writeSaveAsFrame(queryString)
{
	writeOperationFrame("<%=pathWithIntegrationsDir%>/MCADSaveAsFS.jsp", queryString)
}

function writeEBOMSynchFrame(queryString)
{
	writeOperationFrame("<%=pathWithIntegrationsDir%>/MCADEBOMSynchFS.jsp", queryString)
}

function writeRefreshFrame(queryString)
{
	writeOperationFrame("<%=pathWithIntegrationsDir%>/IEFRefreshFS.jsp", queryString)
}

function writeRecognizeVersionFrame(queryString)
{
	writeOperationFrame("<%=pathWithIntegrationsDir%>/IEFRecognizeVersionFS.jsp", queryString)
}

function writeOperationFrame(jspPath, queryString)
{
	if(isCustomLiveConnect)
	{
		queryString = getAppletObject().getJSArgs(0);
	}

	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed && top.modalDialog.contentWindow != progressWindowObject)
	{
		top.modalDialog.contentWindow.cancelOperation = false;
		top.modalDialog.contentWindow.location.href = jspPath + "?" + queryString;
	}
	else
	{
		showIEFModalDialog(jspPath + "?" + queryString, windowWidth, windowHeight);
	}
}

function writePreferencesFrame(queryString)
{
	var integFrame = getIntegrationFrame(this);
	//check whether Applet is loaded.
	var mxmcadApplet = integFrame.getAppletObject();
	var isAppletInited = mxmcadApplet && mxmcadApplet.getIsAppletInited();

	if(isAppletInited == true)
	{
		if(isCustomLiveConnect)
		{
			queryString = getAppletObject().getJSArgs(0);
		}

		showIEFModalDialog("<%=pathWithIntegrationsDir%>/IEFPreferencesFS.jsp?" + queryString, windowWidth, windowHeight);
	}
	else
	{
		showIEFModalDialog("<%=pathWithIntegrationsDir%>/emxAppletTimeOutErrorFS.jsp?featureName=Preferences", 400, 300);
	}
}
function isDSCCommandActive()
{
	var isCommandActive = false;

	var integrationFrame 	= getIntegrationFrame(this);
	var appletObject		= integrationFrame.getAppletObject();	
	if(appletObject)
	{
		isCommandActive = appletObject.callCommandHandlerSynchronously("", "isCommandActive", "");
	}

	return isCommandActive;
}

function openOperationFrame(queryString)
{
	if(isCustomLiveConnect)
	{
		queryString = getAppletObject().getJSArgs(0);
	}

	var	windowDetails	= getWindowDetails(queryString);

	showIEFModalDialog("<%=pathWithIntegrationsDir%>/IEFOperationFS.jsp?" + windowDetails[0], windowDetails[1], windowDetails[2]);
}

function showCheckinObjectDetailsPopup(busID, busName, defaultApplication)
{
	if(isCustomLiveConnect)
	{
		busID = getAppletObject().getJSArgs(0);
		busName = getAppletObject().getJSArgs(1);
		defaultApplication = getAppletObject().getJSArgs(2);
	}

	var strURL = "";

	var queryString = "AppendParameters=true&mode=insert&objectId=" + busID + "&objectName=" + busName;
	if(defaultApplication != null && defaultApplication.indexOf("infocentral") > -1)
		strURL = "<%=pathWithAppName%>/infocentral/emxInfoManagedMenuEmxTree.jsp?" + queryString;
	else if(defaultApplication != null && defaultApplication.indexOf("iefdesigncenter") > -1)
		strURL = "<%=pathWithAppName%>/common/emxTree.jsp?" + queryString;
	else
		strURL = "<%=pathWithAppName%>/common/emxTree.jsp?" + queryString;

	top.showDetailsPopup(strURL);
}

function setURL(url)
{
	if(isCustomLiveConnect)
	{
		url = getAppletObject().getJSArgs(0);
	}

	if(url.indexOf("SearchDialog") > -1 || (url.indexOf("SearchConsolidated") > -1) || (url.indexOf("FullSearch") > -1))
	{
		url		  = "<%=pathWithAppName%>/" + url;
		showIEFNonModalDialog(url, 850, 630);
	}
	else if((url.indexOf("RecentlyAccessedParts") > -1)||(url.indexOf("WorkspaceManager") > -1))
	{
		url = "<%=pathWithIntegrationsDir%>/" + url;
		showIEFNonModalDialog(url, windowWidth, windowHeight);
	}
	else
	{
		url = "<%=pathWithIntegrationsDir%>/" + url;
		showIEFModalDialog(url, windowWidth, windowHeight);
	}
}
function showMyViewInContentFrame()
{
	var wsmURL = "<%=pathWithAppName%><%=lwmUrl%>";
	var contentframe = findFrame(top, "content");
	contentframe.location.href=wsmURL;
}
function setURLSized(url, width, height)
{
	if(isCustomLiveConnect)
	{
		url = getAppletObject().getJSArgs(0);
		width = getAppletObject().getJSArgs(1);
		height = getAppletObject().getJSArgs(2);
	}

	if(url.indexOf("SearchDialog") > -1)
	{
		url = "<%=pathWithAppName%>/" + url;
		top.showSearch(url);
	}
	else
	{
		url = "<%=pathWithIntegrationsDir%>/" + url;
		showIEFModalDialog(url, width, height);
	}
}

function gotoNextPage(root, messageHeader, message)
{
	if(isCustomLiveConnect)
	{
		root = getAppletObject().getJSArgs(0);
		messageHeader = getAppletObject().getJSArgs(1);
		message = getAppletObject().getJSArgs(2);
	}

	//Encode messageHeader and message as they go on the URL.
	messageHeader = escape(messageHeader);
	message = escape(message);

	message			= MCADUrlUtil.hexEncode(message);
	messageHeader	= MCADUrlUtil.hexEncode(messageHeader);

	var url= "<%=pathWithIntegrationsDir%>/MCADMessageFS.jsp?messageHeader=" + messageHeader + "&message=" + message;
	showIEFModalDialog(url, windowWidth, windowHeight);
}

function bringForward(arg)
{
	window.focus();

	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		top.modalDialog.contentWindow.focus();
	}
}
var derivedOutputWindow;

function showAlert(message, closeWindow)
{
	if(isCustomLiveConnect)
	{
		message = getAppletObject().getJSArgs(0);
		closeWindow = getAppletObject().getJSArgs(1);
	}

    if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		if(progressWindowObject && progressWindowObject == top.modalDialog.contentWindow)
		{
			if(closeWindow == "true")
				closeProgressBar();

			alert(message);
		}
		else
		{
		if(eval("typeof " + top.modalDialog.contentWindow.showAlert + " == 'function'")) {
				
			top.modalDialog.contentWindow.showAlert(message, closeWindow);
			}else
			{
				top.modalDialog.contentWindow.alert(message);
			}


		}
	}
	else
	{
		alert(message);
		if(derivedOutputWindow!=null)
		{
    		derivedOutputWindow.close();
		}
	}
}

function closeModalDialog(arg)
{
	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		if(progressWindowObject && progressWindowObject == top.modalDialog.contentWindow)
		{
			closeProgressBar();
		}
		else if(top.modalDialog && top.modalDialog.contentWindow && typeof top.modalDialog.contentWindow.closeModalDialog != "undefined")
		{
			top.modalDialog.contentWindow.closeModalDialog();
		}
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

function startCheckoutProgressBar(arg)
{
	top.modalDialog.contentWindow.startProgressBar();
}

function isPoppedUpWindowOpened()
{
	if (top.modalDialog && top.modalDialog.contentWindow && !(top.modalDialog.contentWindow.closed))
		return "true";
	else
		return "false";
}

function getMessageByTokens(messageKey, tokensArray)
{
	var tokensString = "@";

	for(var tokenName in tokensArray)
	{
		var tokenValue   = tokensArray[tokenName];

		tokensString = tokensString + tokenName + "=" + tokenValue + "@";
	}

	var message = getAppletObject().getStringResourceByTokens(messageKey, tokensString);

	return message;
}

//This is to show file overwrite confirmation dialog while checkout.
function showCheckoutConfirmDialog(integrationName, content)
{
	if(isCustomLiveConnect)
	{
		integrationName = getAppletObject().getJSArgs(0);
		content         = getAppletObject().getJSArgs(1);
	}

	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed && top.modalDialog.contentWindow.showCheckoutConfirmDialog)
	{
		top.modalDialog.contentWindow.showCheckoutConfirmDialog(integrationName, content);
	}
	else
	{
		fileOverwriteConfirmWindowContent = content;
		showIEFModalDialog('MCADOverWriteConfirmFS.jsp?integrationName=' + integrationName, 400, 400);
	}
}

function showCheckoutMessageForRevConf(message)
{
	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		top.modalDialog.contentWindow.showCheckoutMessageForRevConf(message);
	}
	else
	{
		alert(message);
	}
}

function getFamilyConflictWindowContent()
{
	return familyConflictWindowContent;
}

function getConfirmWindowContent()
{
	return fileOverwriteConfirmWindowContent;
}

function showRefreshLockItemsConfirmDialog(integrationName, pageContent)
{
	if(isCustomLiveConnect)
	{
		integrationName = getAppletObject().getJSArgs(0);
		content         = getAppletObject().getJSArgs(1);
	}

	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		top.modalDialog.contentWindow.lockeditemsPageContent = pageContent;
		top.modalDialog.contentWindow.showLockItemsConfirmDialog(integrationName);
	}
}

function showFamilyConflictConfirmDialog(integrationName, content)
{

	if(isCustomLiveConnect)
	{
		integrationName = getAppletObject().getJSArgs(0);
		content         = getAppletObject().getJSArgs(1);
	}

	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		top.modalDialog.contentWindow.showFamilyConflictConfirmDialog(integrationName, content);
	}
	else
	{
		familyConflictWindowContent = content;
		showIEFModalDialog('MCADFamilyConflictConfirmFS.jsp?integrationName=' + integrationName, 400, 400);
	}
}

function showLocalFilesDeleteConfirmationDialog(integrationName, content)
{
	if(isCustomLiveConnect)
	{
		integrationName = getAppletObject().getJSArgs(0);
		content         = getAppletObject().getJSArgs(1);
	}

	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		top.modalDialog.contentWindow.showLocalFilesDeleteConfirmationDialog(integrationName, content);
	}
	else
	{
		confirmDeleteWindowContent = content;
		showIEFModalDialog('MCADLocalFilesDeleteConfirmFS.jsp?integrationName=' + integrationName, 400, 400);
	}
}

function getConfirmDeleteWindowContent()
{
	return confirmDeleteWindowContent;
}

function setBrowserCommandOpener(openerFrame)
{
	activeBrowserCommandOpener = openerFrame;
}

function getBrowserCommandOpener()
{
	var winOpener = activeBrowserCommandOpener;
	activeBrowserCommandOpener = null;
	return winOpener;
}

function setFooterOptions(option)
{
	footerOptions = option;
}

function getFooterOptions()
{
	return footerOptions;
}

function removeFooterOptions()
{
	footerOptions = "" ;
}

function setActiveRefreshFrame(refreshFrame)
{
	activeRefreshFrame = refreshFrame;
}

function getActiveRefreshFrame()
{
	return activeRefreshFrame;
}

function showDirectoryChooser(integrationName, directoryChooserControl, eventHandlerArguments)
{
	activeDirectoryChooserControl = directoryChooserControl;

	getAppletObject().callCommandHandler(integrationName, "showDirectoryChooser", activeDirectoryChooserControl.value + "|" + eventHandlerArguments);

	setDirectoryChooserStatus("opened");
}

function setSelectedDirectory(selectedDirectory)
{
	if(isCustomLiveConnect)
	{
		selectedDirectory = getAppletObject().getJSArgs(0);
	}

	if (activeDirectoryChooserControl)
	{
		activeDirectoryChooserControl.value = selectedDirectory;
		activeDirectoryChooserControl = null;
		setDirectoryChooserStatus("closed");
	}

	var isRefreshRequired = getAppletObject().callTreeTableUIObject("isRefreshRequiredAfterDirectoryChooser", "");
	if("true" == isRefreshRequired && top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		top.modalDialog.contentWindow.refresh();
	}
}

function setDirectoryChooserStatus(status)
{
	directoryChooserStatus = status;
}

function startRefreshProcess()
{
	var integFrame = getIntegrationFrame(this);
	var mxmcadApplet	= integFrame.getAppletObject();	
	var isAppletInited = mxmcadApplet && mxmcadApplet.getIsAppletInited();
	if(isAppletInited == true)
	{
		var result = mxmcadApplet.callCommandHandlerSynchronously('', 'isNonIntegrationUser', 'true') + "";

		if(result == "false")
		{
		var singleIntegrationName = mxmcadApplet.callCommandHandlerSynchronously("", "getIntegrationNameIfSingle", "");

		if(singleIntegrationName == "")
		{
			var preferredIntegration	= mxmcadApplet.callCommandHandlerSynchronously("", "getPreferredIntegrationName", "");
			if(preferredIntegration == null || preferredIntegration == "")
			{
				showIEFModalDialog("<%=pathWithIntegrationsDir%>/IEFIntegrationChooserFS.jsp?keepOpen=true&eventHandler=createRefreshSelectionPage", "300", "325");
			}
			else
			{
				mxmcadApplet.callCommandHandler(preferredIntegration, "createRefreshSelectionPage", "");
			}
		}
		else
		{
			mxmcadApplet.callCommandHandler(singleIntegrationName, "createRefreshSelectionPage", "");
		}
	}
	else
			showIEFModalDialog("<%=pathWithIntegrationsDir%>/emxAppletTimeOutErrorFS.jsp?featureName=DesignChangeReport", 400, 300);
	}
	else
	{
		showIEFModalDialog("<%=pathWithIntegrationsDir%>/emxAppletTimeOutErrorFS.jsp?featureName=DesignChangeReport", 400, 300);
	}
}

function createRefreshSelectionPage(selectedIntegrationName)
{
	var integFrame = getIntegrationFrame(this);
	integFrame.getAppletObject().callCommandHandler(selectedIntegrationName, "createRefreshSelectionPage", "");
}

function createGlobalPreferencesPage()
{
	var integFrame = getIntegrationFrame(this);
	var mxmcadApplet	= integFrame.getAppletObject();
	//check whether applet is loaded
	var isAppletInited = mxmcadApplet && mxmcadApplet.getIsAppletInited();

	if(isAppletInited == true)
	{
		var chooserURL  = "<%=pathWithIntegrationsDir%>/IEFGCOChooserFS.jsp?integrationName=&gcoDefault=&closeWindow=FALSE";
		showIEFModalDialog(chooserURL, '300', '350');
	}
	else
	{
		showIEFModalDialog("<%=pathWithIntegrationsDir%>/emxAppletTimeOutErrorFS.jsp?featureName=Preferences", 400, 300);
	}
}

function abortOperation()
{
var mxmcadApplet = getAppletObject();
	var integrationName = mxmcadApplet.callTreeTableUIObject("getIntegrationName", "");
	mxmcadApplet.callCommandHandlerSynchronously(integrationName, 'abortOperation', true);
}

function setSelectedGCOName(fieldName, gcoName)
{
	if(gcoName != null && gcoName != "")
	{
		var integFrame = getIntegrationFrame(this);
		integFrame.getAppletObject().callCommandHandler("", "createGlobalPreferencesPage", gcoName);
	}
}

function writeGlobalPreferencesFrame(queryString)
{
	if(isCustomLiveConnect)
	{
		queryString = getAppletObject().getJSArgs(0);
	}

	var startDesignURL = "<%=pathWithIntegrationsDir%>/IEFGlobalPreferencesFS.jsp?" + queryString;

	showIEFModalDialog(startDesignURL, windowWidth, windowHeight);
}

function showUserChooser()
{
	var integFrame = getIntegrationFrame(this);
	var mxmcadApplet = integFrame.getAppletObject();
	var isAppletInited = mxmcadApplet && mxmcadApplet.getIsAppletInited();

	if(isAppletInited == true)
		showIEFModalDialog("<%=pathWithIntegrationsDir%>/IEFUserChooserFS.jsp", 400, 450);
	else
		showIEFModalDialog("<%=pathWithIntegrationsDir%>/emxAppletTimeOutErrorFS.jsp", 400, 300);
}

function setSelectedUserName(selectedUserName, selectedUserType)
{
	var unitSeparator	= "<%=MCADAppletServletProtocol.UNIT_SEPERATOR%>";
	var recordSeparator = "<%=MCADAppletServletProtocol.RECORD_SEPERATOR%>";

	var parametersArray = new Array;
	parametersArray["Command"]						= "updateAssignments";
	parametersArray["selectedUser"]					= selectedUserName;
	parametersArray["selectedUserType"]				= selectedUserType;

	var queryString = getQueryString(parametersArray, unitSeparator, recordSeparator);

	var integrationFrame = getIntegrationFrame(this);
		//cannot go ahead if unable to locate integration frame.
	if( integrationFrame != null )
	{
		var response = integrationFrame.getAppletObject().callCommandHandlerSynchronously("", "sendRequestToServerForIntegrationAssignment", queryString);	
		response = response +"";
		if(response.indexOf("true") < 0)
		{
			if(response.indexOf("false|") > -1)
			{
				showAlert(response.substring(6), "false");
			}
			else
			{
				showAlert(response, "false");
			}
		}
	}
}

function showIntegChooserForStartDesign()
{
	var integFrame = getIntegrationFrame(this);
	//check whether applet is loaded
	var mxmcadApplet	= integFrame.getAppletObject();
	var isAppletInited = mxmcadApplet && mxmcadApplet.getIsAppletInited();

	if(isAppletInited == true)
	{
		var result = mxmcadApplet.callCommandHandlerSynchronously('', 'isNonIntegrationUser', 'true') + "";

		if(result == "false")
		{
		var singleIntegrationName = mxmcadApplet.callCommandHandlerSynchronously("", "getIntegrationNameIfSingle", "");

		if(singleIntegrationName == "")
		{
				var allowedIntegrations = mxmcadApplet.callCommandHandlerSynchronously("", "getAllowedIntegrationsForStartDesign", "");

			var preferredIntegration	= mxmcadApplet.callCommandHandlerSynchronously("", "getPreferredIntegrationName", "");

				if(allowedIntegrations.indexOf("|") < 0)
					preferredIntegration = allowedIntegrations;
			var supportFamilyInStartDesign = '<%=supportFamilyInStartDesign%>';
			if(preferredIntegration == null || preferredIntegration == "" ||( preferredIntegration == "SolidWorks" && supportFamilyInStartDesign != "false"))
			{
					showIEFModalDialog("<%=pathWithIntegrationsDir%>/IEFIntegrationChooserFS.jsp?keepOpen=true&eventHandler=createStartDesignPage&allowedIntegrations=" + allowedIntegrations, "300", "325");
			}
			else
			{
				mxmcadApplet.callCommandHandler(preferredIntegration, "createStartDesignPage", "");
			}
		}
		else
		{
			mxmcadApplet.callCommandHandler(singleIntegrationName, "createStartDesignPage", "");
		}
	}
	else
			showIEFModalDialog("<%=pathWithIntegrationsDir%>/emxAppletTimeOutErrorFS.jsp?featureName=StartDesign", 400, 300);
	}
	else
	{
		showIEFModalDialog("<%=pathWithIntegrationsDir%>/emxAppletTimeOutErrorFS.jsp?featureName=StartDesign", 400, 300);
	}

}

function launchCADTool(integrationName)
{
	var integFrame = getIntegrationFrame(this);
	//check whether applet is loaded
	var mxmcadApplet   = integFrame.getAppletObject();
	var isAppletInited = mxmcadApplet && mxmcadApplet.getIsAppletInited();

	if(isAppletInited == true)
	{
		var CSELaunchBinaryDetails = mxmcadApplet.callCommandHandler(integrationName,"launchCADTool","-action:connect");
	}
}

function createStartDesignPage(selectedIntegrationName)
{
	var integFrame	= getIntegrationFrame(this);
	integFrame.getAppletObject().callCommandHandler(selectedIntegrationName, "createStartDesignPage", "");
}

function showIntegChooserForMyLockedObjects()
{
	var integFrame = getIntegrationFrame(this);
	var singleIntegrationName = integFrame.getAppletObject().callCommandHandler("", "getIntegrationNameIfSingle", "");	

	if(singleIntegrationName == "")
	{
		showIEFModalDialog("<%=pathWithIntegrationsDir%>/IEFIntegrationChooserFS.jsp?keepOpen=false&eventHandler=showMyLockedObjectsPage", "300", "325");
	}
	else
	{
		showMyLockedObjectsPage(singleIntegrationName);
	}
}

function showMyLockedObjectsPage(selectedIntegrationName)
{
	top.content.location = "<%=pathWithIntegrationsDir%>/IEFObjectsLockedBy.jsp?HelpMarker=emxhelplockedobjects&integrationName="+selectedIntegrationName;
}

function writeStartDesignFrame(queryString)
{
	if(isCustomLiveConnect)
	{
		queryString = getAppletObject().getJSArgs(0);
	}

	var startDesignURL = "<%=pathWithIntegrationsDir%>/IEFStartDesignFS.jsp?" + queryString;

	showIEFModalDialog(startDesignURL, windowWidth, windowHeight);
}

function showStartDesignCreateObjectPage(startDesignForm, queryString)
{
	if(isCustomLiveConnect)
	{
		startDesignForm = getAppletObject().getJSArgs(0);
		queryString = getAppletObject().getJSArgs(1);
	}

	var startDesignCreateObjectURL = "<%=pathWithIntegrationsDir%>/" + startDesignForm + "?" + queryString;

	showIEFModalDialog(startDesignCreateObjectURL, 700, 600);
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

function executeFromTreeTableWindow(arguments)
{
	if(isCustomLiveConnect)
	{
		arguments = getAppletObject().getJSArgs(0);
	}

	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		arguments = arguments + "";
		var functionDetails	= arguments.split('|');
		var functionName = functionDetails[0];
		var functionArgs = functionDetails[1];

		var functionRetValue = top.modalDialog.contentWindow.eval(functionName + "('" + functionArgs + "');" );
		return functionRetValue;
	}

	return "false";
}

function updateTreeTableWindow(arguments)
{
	if(isCustomLiveConnect)
	{
		arguments = getAppletObject().getJSArgs(0);
	}

	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		top.modalDialog.contentWindow.updateTreeTableWindow(arguments);
	}
}

function showProgressBar(queryString)
{
	try
	{
	if(isCustomLiveConnect)
	{
		queryString = getAppletObject().getJSArgs(0);
	}

	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed && progressWindowObject != top.modalDialog.contentWindow)
	{
		if(isCustomLiveConnect)
		{
			top.modalDialog.contentWindow.startTimerIcon();
		}
		else
		{
			progressWindowObject = top.modalDialog.contentWindow.showProgressBar(queryString);
		}
	}
	else
	{
		if(!isCustomLiveConnect)
		{
			showIEFModalDialog("IEFProgressBar.jsp?" + queryString, 410, 120);
			progressWindowObject = top.modalDialog.contentWindow;
		}
	}
}
	catch (error)
	{
	}
}

function updateProgressBar(metaCurrentCount, fileCurrentCount)
{
	try
	{
	if(isCustomLiveConnect)
	{
		metaCurrentCount	= getAppletObject().getJSArgs(0);
		fileCurrentCount	= getAppletObject().getJSArgs(1);
	}

	if(progressWindowObject && !progressWindowObject.closed)
	{
			
			if(!isCustomLiveConnect)
			{
				progressWindowObject.updateProgressBar(parseInt(metaCurrentCount), parseInt(fileCurrentCount));
			}
			
		}
		}
		catch(error)
		{
	}
}

function closeProgressBar()
{
	try
	{
	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		if(isCustomLiveConnect)
			top.modalDialog.contentWindow.stopTimerIcon();
		else
		{
			if(progressWindowObject && progressWindowObject == top.modalDialog.contentWindow)
			{
				progressWindowObject.close();
					progressWindowObject = null;
			}
            else
			{
					progressWindowObject = null;
				top.modalDialog.contentWindow.closeProgressBar();
			}
		}
	}
}
	catch (error)
	{
	}
}

function openCheckoutPage(integrationName, checkoutDetails)
{
	if(isCustomLiveConnect)
	{
		integrationName	= getAppletObject().getJSArgs(0);
		checkoutDetails	= getAppletObject().getJSArgs(1);
	}

	checkout(integrationName, true, checkoutDetails, "", 'interactive','false');
}

function applyRegularExpression(oldName, regularExpression, replaceString)
{
	oldName = oldName + "";

	var newName	= oldName.replace(new RegExp(regularExpression), replaceString);
	return newName;
}

function writeWSMPage(integrationName)
{
	if(isCustomLiveConnect)
	{
		integrationName	= getAppletObject().getJSArgs(0);
	}

	var wsmURL = "<%=pathWithAppName%>/iefdesigncenter/emxDSCWorkspaceMgmtFS.jsp?" + integrationName + "&isCSECommand=true";

	showIEFModalDialog(wsmURL, windowWidth, windowHeight);
}


function showWSMOperationfailureMsg(message,closeWindow)
{

	if(isCustomLiveConnect)
	{
		message		= getAppletObject().getJSArgs(0);
		closeWindow = getAppletObject().getJSArgs(1);
	}

	alert(message);
}

function showConfirm(message, closeWindow)
{
	if(isCustomLiveConnect)
	{
		message		= getAppletObject().getJSArgs(0);
		closeWindow = getAppletObject().getJSArgs(1);
	}

	if (top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		if (top.modalDialog.contentWindow.confirm(message))
		{
		   return "ok"
		}
		else
		{
		   return "cancel"
		}
	}
	else
	{
		if (confirm(message))
		{
		   return "ok"
		}
		else
		{
		   return "cancel"
		}
	}
}

function findListDisplayFrame(objWindow)
{
	var objFrame = null;
	for (var i = 0; i < objWindow.frames.length && !objFrame; i++)
	{
		if (objWindow.frames[i].name == "listDisplay")
		{
			objFrame = objWindow.frames[i];
		}
	}
	if (!objFrame) {
		for (var i=0; i < objWindow.frames.length && !objFrame; i++)
		{
			objFrame = findListDisplayFrame(objWindow.frames[i]);
		}
	}
	return objFrame;
}

// Reloads the WSM details frame.  This is a bit tricky because the frame may
// be displayed in the IEF modal window, a power view channel, or both (e.g.
// in the browser the user has WSM displayed in a channel then uses that same
// session from a CSE and does Manage Workspace from the CSE).
function refreshWSMDetailsFrame(result, channelMode, intialDirectory)
{
        if(isCustomLiveConnect)
	     {
                result = getAppletObject().getJSArgs(0);
	 	          channelMode = getAppletObject().getJSArgs(1);
 	     }

        var tabFrame = null;
         // First try the modal dialog if it is up and open
        if (top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
                tabFrame = findListDisplayFrame(top.modalDialog.contentWindow);
        // Try to locate in a channel page if it was not found in a modal dialog
        if (tabFrame == null)
                tabFrame = findListDisplayFrame(top)

        if(tabFrame != 'undefined' && tabFrame != null)
        {
			if(intialDirectory != 'undefined' && intialDirectory != 'null' &&  intialDirectory != '')
			{
				//Refresh completly
				tabFrame.parent.parent.document.location.href = "../iefdesigncenter/emxDSCWorkspaceMgmtFS.jsp?initialDirectory=" + encodeURI(intialDirectory);
			}
			else
			{
				//Refresh only the table
                var newHref = tabFrame.parent.document.location.href.replace('common/emxTable', 'iefdesigncenter/emxDSCWorkspaceMgmtDetails');
                tabFrame.parent.document.location.href = newHref;
             }
        }
}

function createPreferencesPage()
{
	var integFrame = getIntegrationFrame(this);
	var mxmcadApplet	= integFrame.getAppletObject();
	var isAppletInited = mxmcadApplet && mxmcadApplet.getIsAppletInited();
	var showErrorPage = false;

	if(isAppletInited == true)
	{
		var result = mxmcadApplet.callCommandHandlerSynchronously('', 'isNonIntegrationUser', 'true') + "";
		if(result == "false")
		mxmcadApplet.callCommandHandler('', 'createPreferencesPage', 'Global');
	else
			showErrorPage = true;
	}
	else
		showErrorPage = true;

	if(showErrorPage == true)
		showIEFModalDialog("<%=pathWithIntegrationsDir%>/emxAppletTimeOutErrorFS.jsp?featureName=Preferences", 400, 300);

}

function createAssignmentsPage()
{
	var integFrame = getIntegrationFrame(this);
	var mxmcadApplet	= integFrame.getAppletObject();
	var isAppletInited = mxmcadApplet && mxmcadApplet.getIsAppletInited();

	if(isAppletInited == true)
		showIEFModalDialog("<%=pathWithIntegrationsDir%>/IEFIntegrationAssignmentFS.jsp", 560, 530);
	else
		showIEFModalDialog("<%=pathWithIntegrationsDir%>/emxAppletTimeOutErrorFS.jsp", 400, 300);

}

function showDependentDocs(queryString)
{
	if(isCustomLiveConnect)
	{
		queryString = getAppletObject().getJSArgs(1);
	}

	var derivedOutputPage = "MCADDependentDocsFS.jsp?" + queryString;

	showIEFModalDialog(derivedOutputPage, 350, 350);
}

function getDependentDocsContent()
{
	var dependentDocsContent = getAppletObject().callTreeTableUIObject("getDependentDocsContent", "");	
	return dependentDocsContent;
}

function changeNodeDependentDocSelection(selectionDetails)
{
	var response = getAppletObject().callTreeTableUIObject("changeNodeDependentDocSelection", selectionDetails);

	if(response != "true")
		alert(response);

	return response;
}

function getWindowDetails(queryString)
{
	var detailsArray	= new Array();

	detailsArray[0]		= queryString;
	detailsArray[1]		= windowWidth;
	detailsArray[2]		= windowHeight;

	if(queryString.indexOf("pageTitle") != -1)
	{
		var pageTitle	= queryString.substring(queryString.indexOf("pageTitle"), queryString.indexOf("&"));

		/* To generate a window with customized size, if pageTitle  contains window width and height
			else generate default window */

		if(pageTitle != null && pageTitle.indexOf("|") != -1)
		{
			var fIndex			= pageTitle.indexOf("|");
			var widthAndHeight	= pageTitle.slice(fIndex);

			if(widthAndHeight != null)
			{
				var startQueryString	= queryString.substring(0 ,queryString.indexOf("|"));
				var endQueryString		= queryString.slice(queryString.lastIndexOf("&"));
				queryString				= startQueryString.concat(endQueryString);

				detailsArray[0]		=  queryString;
				detailsArray[1]		=  widthAndHeight.substring(widthAndHeight.indexOf("|")+1, widthAndHeight.lastIndexOf("|"));
				detailsArray[2]		=  widthAndHeight.substring(widthAndHeight.lastIndexOf("|")+1, widthAndHeight.length);
			}
		}
	}

	return detailsArray;
}

/*
function updateTreeTableWindow(args)
{
	if(top.modalDialog && !top.modalDialog.contentWindow.closed)
	{
		progressWindowObject = top.modalDialog.contentWindow.treeControlObject.refresh();
	}
}*/

var getJavaState = function () {
    var maxJavaMajorVersion = 0, maxJavaMinorVersion = 0,
        updates = {},
        pluginName = 'Java(TM)',
        name,
        i, l,
        plugin, pluginTag, jvms,
        saveVersion = function (major, minor) {
            if (major >= maxJavaMajorVersion) {
                maxJavaMajorVersion = major;
                if (!updates[major]) {
                    updates[major] = [];
                }
                updates[major].push(parseInt(minor, 10));
            }
        };

    if (navigator.plugins && navigator.plugins.length) {
        for (i = 0, l = navigator.plugins.length; i < l; i++) {
            name = navigator.plugins[i].name;
            //The version of the plugin is only contained in the name with the following format "Java(TM) Platform SE 6 U20"
            if (name.indexOf(pluginName) !== -1) {
                saveVersion(parseInt(name[21], 10), parseInt(name.substring(24), 10));
            }else if (name.indexOf('Java Plug-in') !== -1) {
                saveVersion(parseInt(name.substring(15), 10), parseInt(name.substring(19), 10));
            }
        }
    } else {
        // No plugins, we are very probably in IE
        pluginTag = '<' +
                'object classid="clsid:CAFEEFAC-DEC7-0000-0001-ABCDEFFEDCBA" ' +
                'id="deployJavaPlugin" width="0" height="0">' +
                '<' + '/' + 'object' + '>';
        document.write(pluginTag);
        plugin = document.getElementById('deployJavaPlugin');
        jvms = plugin.jvms;
        if (jvms) {
            for (i = 0, l = jvms.getLength(); i < l; i++) {
                name = jvms.get(i).version;
                saveVersion(parseInt(name[2], 10), parseInt(name.substring(6), 10) || 0);
            }
        }
    }
    maxJavaMinorVersion = Math.max(Math.max.apply(Math, updates[maxJavaMajorVersion] || [0]), 0);
    
    //case where no java plugin has been found
    if (0 === maxJavaMajorVersion && 0 === maxJavaMinorVersion) {
        return {state: 'nojava'};
    }
    // Min Java version is V7 U17
    if (maxJavaMajorVersion < 7) {
        return {state: 'outdated'};
    }

    if ((maxJavaMajorVersion === 7) && (maxJavaMinorVersion < 11)) {
        return {state: 'outdated'};
    }
    return {
        state: 'ok',
        version: maxJavaMajorVersion,
        update: maxJavaMinorVersion
    };
};

function getJreSpecificJars()
{
	var statestatus = getJavaState();
	var status = statestatus.state; 	
	if(status.indexOf('ok') !== -1)
	{
		var version = statestatus.version + '_' + statestatus.update;	
		if(version.indexOf('7_45') !== -1 || version.indexOf('6_65') !== -1){
			return "../WebClient/iefApplet_j7u45.jar, ../WebClient/FcsClient_j7u45.jar";		
		}else{
			return "../WebClient/iefApplet.jar, ../WebClient/FcsClient.jar";		
		}
	}

	return "../WebClient/iefApplet.jar, ../WebClient/FcsClient.jar";			
}

</script>


<%
    if(isMCADIntegActive)
    {
        session.setAttribute("mcadintegration.applet.loaded", "true");
		//Applet archives			
		String appletForNS = "../WebClient/iefApplet.jar, ../WebClient/FcsClient.jar";		
		String appletForNSSpecific = "../WebClient/iefApplet_j7u45.jar, ../WebClient/FcsClient.jar";		
		String debugFlag	= "FALSE";
	    if(isIEFDebugEnabled)
	    {
			debugFlag = "TRUE";
	    }
		
	if(isPropertyAvailable == false)
	{		
%>
<SCRIPT LANGUAGE="JavaScript">		
	function writeAppletTag() 
	{
		var jarstoload = getJreSpecificJars();
		document.writeln('<applet name="MxMCADApplet" ARCHIVE='+jarstoload+' align=middle code="com.matrixone.MCADIntegration.client.applet.DSCApplet.class" codebase = "./" WIDTH=1 HEIGHT=1 MAYSCRIPT >');
		//XSSOK
        document.writeln(buildParamTag('VIRTUALPATH','<%=virtualPath%>'));
		document.writeln(buildParamTag('codebase_lookup','FALSE')); 
        //XSSOK
        document.writeln(buildParamTag('ROOT','<%=refServer%>'));                
        //XSSOK		
		document.writeln(buildParamTag('DEBUG','<%=debugFlag%>')); 
		document.writeln(buildParamTag('DEBUGFILEPATH','')); 
		//XSSOK
		document.writeln(buildParamTag('PORT','<%=mcadPortNumber%>')); 
		document.writeln(buildParamTag('MULTIPORTRANGEENABLED','<%=XSSUtil.encodeForHTML(context,isMultiPortRangeEnabled)%>'));
        //XSSOK		
		document.writeln(buildParamTag('MULTIPORTRANGEMAX','<%=multiPortRangeMax%>')); 
		//XSSOK
		document.writeln(buildParamTag('MULTIPORTRANGEMIN','<%=multiPortRangeMin%>')); 
		//XSSOK
		document.writeln(buildParamTag('MCADCHARSET','<%=mcadCharset%>')); 
		//XSSOK
		document.writeln(buildParamTag('ACCEPTLANGUAGE','<%=acceptLanguage%>')); 
		document.writeln(buildParamTag('USERLOGGEDIN','TRUE')); 
		document.writeln(buildParamTag('CUSTOMLIVECONNECT','<%=isCustomLiveConnect%>')); 
		document.writeln(buildParamTag('cache_option','Plugin')); 
		document.writeln(buildParamTag('cache_archive',jarstoload)); 
		document.writeln(buildParamTag('cache_version','A.0.0.417, B.0.0.417')); 
		document.writeln(buildParamTag('ssoticket','<%=ticket%>')); 
		document.writeln(buildParamTag('ssocookie','<%=ssocookie%>')); 
		document.writeln(buildParamTag('ssoserverurl','<%=ssoServerUrl%>')); 
		document.writeln(buildParamTag('ssohttpsurl','<%=ssoHttpsUrl%>')); 
		document.writeln(buildParamTag('externalAuthentication','<%=isExtAuth%>')); 
		document.writeln(buildParamTag('sessionId','<%=sessionId%>')); 
		document.writeln(buildParamTag('forwardToWSM','<%=XSSUtil.encodeForHTML(context,forwardToWSM)%>')); 
        document.writeln('</applet>');                
	}

	function buildParamTag(name, value) 
	{
		return '<PARAM NAME="' + name + '" VALUE="' + value + '">';
    }
	
	writeAppletTag();
	
</SCRIPT>

<%
	}else
	{
		String name = "MxMCADApplet"; 	
		out.println("<script src=../common/scripts/emxUIEmbeddedObjects.js type=\"text/javascript\"></script>");
		out.println("<script type=\"text/javascript\">");   
		out.println("var objEmb = new ObjectEmbedder();");
		out.println("objEmb.setType(OBJECT_TAG);");		

		out.println("objEmb.addAttribute(\"classid\",\"clsid:" + jreVersionClassid + "\");");
		out.println("objEmb.addAttribute(\"name\",\"" + name + "\");");

		out.println("objEmb.addAttribute(\"WIDTH\",\"1\");"); 
		out.println("objEmb.addAttribute(\"HEIGHT\",\"1\");");				
		out.println("objEmb.addAttribute(\"align\",\"middle\");"); 

		out.println("objEmb.addParameter(\"java_code\",\"com.matrixone.MCADIntegration.client.applet.DSCApplet.class\");");
		out.println("objEmb.addParameter(\"java_codebase\",\"" + "./" + "\");");
		out.println("objEmb.addParameter(\"java_archive\",getJreSpecificJars());");
		
		out.println("objEmb.addParameter(\"mayscript\",\"true\");");

		out.println("objEmb.addParameter(\"VIRTUALPATH\",\"" + virtualPath + "\");");
		out.println("objEmb.addParameter(\"codebase_lookup\",\"FALSE\");");
		out.println("objEmb.addParameter(\"ROOT\",\"" + refServer + "\");");
		out.println("objEmb.addParameter(\"DEBUG\",\"" + debugFlag + "\");");
		out.println("objEmb.addParameter(\"DEBUGFILEPATH\",\"\");");
		out.println("objEmb.addParameter(\"PORT\",\"" + mcadPortNumber + "\");");
		out.println("objEmb.addParameter(\"MULTIPORTRANGEENABLED\",\"" + isMultiPortRangeEnabled + "\");");
		out.println("objEmb.addParameter(\"MULTIPORTRANGEMAX\",\"" + multiPortRangeMax + "\");");
		out.println("objEmb.addParameter(\"MULTIPORTRANGEMIN\",\"" + multiPortRangeMin + "\");");
		out.println("objEmb.addParameter(\"MCADCHARSET\",\"" + mcadCharset + "\");");
		out.println("objEmb.addParameter(\"ACCEPTLANGUAGE\",\"" + acceptLanguage + "\");");
		out.println("objEmb.addParameter(\"USERLOGGEDIN\",\"TRUE\");");
		out.println("objEmb.addParameter(\"CUSTOMLIVECONNECT\",\"" + isCustomLiveConnect + "\");");
		out.println("objEmb.addParameter(\"cache_option\",\"Plugin\");");
		out.println("objEmb.addParameter(\"cache_archive\",getJreSpecificJars());");
		out.println("objEmb.addParameter(\"cache_version\",\"A.0.0.1, A.0.0.2\");");
		out.println("objEmb.addParameter(\"ssoticket\",\"" + ticket + "\");");
		out.println("objEmb.addParameter(\"ssocookie\",\"" + ssocookie + "\");");
		out.println("objEmb.addParameter(\"ssoserverurl\",\"" + ssoServerUrl + "\");");
		out.println("objEmb.addParameter(\"ssohttpsurl\",\"" + ssoHttpsUrl + "\");");
		out.println("objEmb.addParameter(\"externalAuthentication\",\"" + isExtAuth + "\");");
		out.println("objEmb.addParameter(\"sessionId\",\"" + sessionId + "\");");
		out.println("objEmb.addParameter(\"forwardToWSM\",\"" + forwardToWSM + "\");");		
		
		String type = "application/x-java-applet";
		out.println("objEmb.addParameter(\"java_type\",\"" + type + "\");");
		out.println("objEmb.addParameter(\"scriptable\",\"true\");");		
						
		out.println("objEmb.addEmbedAttribute(\"type\",\"" + type + "\");");		
		out.println("objEmb.addEmbedAttribute(\"java_version\",\""+ javaVersionFx +"\");");				
		out.println("objEmb.addEmbedAttribute(\"name\",\"" + name + "\");");
		out.println("objEmb.addEmbedAttribute(\"align\",\"middle\");");			
        out.println("objEmb.addEmbedAttribute(\"codebase\",\"" + "./" + "\");"); 		
        out.println("objEmb.addEmbedAttribute(\"WIDTH\",\"1\");"); 
		out.println("objEmb.addEmbedAttribute(\"HEIGHT\",\"1\");");			
		out.println("objEmb.addEmbedAttribute(\"archive\",getJreSpecificJars());");		
        out.println("objEmb.addEmbedAttribute(\"code\",\"com.matrixone.MCADIntegration.client.applet.DSCApplet.class\");");	
		out.println("objEmb.addEmbedAttribute(\"scriptable\",\"true\");");		
        out.println("objEmb.addEmbedAttribute(\"mayscript\",\"true\");");			

		out.println("objEmb.addEmbedAttribute(\"VIRTUALPATH\",\"" + virtualPath + "\");");
		out.println("objEmb.addEmbedAttribute(\"codebase_lookup\",\"FALSE\");");
		out.println("objEmb.addEmbedAttribute(\"ROOT\",\"" + refServer + "\");");
		out.println("objEmb.addEmbedAttribute(\"DEBUG\",\"" + debugFlag + "\");");
		out.println("objEmb.addEmbedAttribute(\"DEBUGFILEPATH\",\"\");");
		out.println("objEmb.addEmbedAttribute(\"PORT\",\"" + mcadPortNumber + "\");");
		out.println("objEmb.addEmbedAttribute(\"MULTIPORTRANGEENABLED\",\"" + isMultiPortRangeEnabled + "\");");
		out.println("objEmb.addEmbedAttribute(\"MULTIPORTRANGEMAX\",\"" + multiPortRangeMax + "\");");
		out.println("objEmb.addEmbedAttribute(\"MULTIPORTRANGEMIN\",\"" + multiPortRangeMin + "\");");
		out.println("objEmb.addEmbedAttribute(\"MCADCHARSET\",\"" + mcadCharset + "\");");
		out.println("objEmb.addEmbedAttribute(\"ACCEPTLANGUAGE\",\"" + acceptLanguage + "\");");
		out.println("objEmb.addEmbedAttribute(\"USERLOGGEDIN\",\"TRUE\");");
		out.println("objEmb.addEmbedAttribute(\"CUSTOMLIVECONNECT\",\"" + isCustomLiveConnect + "\");");
		out.println("objEmb.addEmbedAttribute(\"cache_option\",\"Plugin\");");
		out.println("objEmb.addEmbedAttribute(\"cache_archive\",getJreSpecificJars());");
		out.println("objEmb.addEmbedAttribute(\"cache_version\",\"A.0.0.1, A.0.0.2\");");
		out.println("objEmb.addEmbedAttribute(\"ssoticket\",\"" + ticket + "\");");
		out.println("objEmb.addEmbedAttribute(\"ssocookie\",\"" + ssocookie + "\");");
		out.println("objEmb.addEmbedAttribute(\"ssoserverurl\",\"" + ssoServerUrl + "\");");
		out.println("objEmb.addEmbedAttribute(\"ssohttpsurl\",\"" + ssoHttpsUrl + "\");");
		out.println("objEmb.addEmbedAttribute(\"externalAuthentication\",\"" + isExtAuth + "\");");
		out.println("objEmb.addEmbedAttribute(\"sessionId\",\"" + sessionId + "\");");
		out.println("objEmb.addEmbedAttribute(\"forwardToWSM\",\"" + forwardToWSM + "\");");				
		out.println("objEmb.draw();\n</script>");
        }
	}
    else
    {
        session.setAttribute("mcadintegration.applet.loaded", "false");
		String commandServletPath = appName + MCADAppletServletProtocol.IEF_COMMANDS_SERVLET_NAME + "?isNonIntegUser=true";
%>
        <!--XSSOK-->
		<iframe src="<%=commandServletPath%>" width="0" height="0"></iframe>
<%
	}
%>
<%@include file = "MCADBottomErrorInclude.inc"%>
</body>
</html>

