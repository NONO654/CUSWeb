<%--  
  (c) Dassault Systemes, 1993 - 2018.  All rights reserved.
--%>
<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers, com.matrixone.enovia.bps.search.SearchNextGen"%>
<%
  response.addHeader("Cache-Control", "no-cache");
// Check if external authentication is turned on
String sExtAuth = FrameworkProperties.getProperty("emxFramework.External.Authentication");
if (sExtAuth == null || sExtAuth.length() == 0)
{
    sExtAuth = "false";
}
if ("TRUE".equalsIgnoreCase(sExtAuth))
{
    session.setAttribute("emxSessionExist", Boolean.valueOf(true));
}
//Variable to track the whether this page is reached from emxLogin.jsp.
String isOpened = (String)session.getAttribute("isOpened") ;
//Reading the property set by emxLogin.jsp from the session.
if (isOpened != null){
    //Removing from the session after reading.
    session.removeAttribute("isOpened");
}
%>
<%@include file = "emxNavigatorSideDoorInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>

<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxCommonAppInitializationInclude.inc"%>
<%@include file = "emxAppInitializationInclude.inc"%>
<%@include file = "emxLoadNavigatorProperties.inc"%>
<%@include file = "../emxUILoadPropertyFiles.inc"%>
<!--
 This include inc line is added to to get the security context switching data available. The data is
 constructed with the html elements and governed by the div tag. Please do not remove this
 -->


<head>
<meta name="apple-mobile-web-app-capable" content="yes" />

<%
String securityContext = PersonUtil.getActiveSecurityContext(context);
if(UIUtil.isNullOrEmpty(securityContext)) {
	securityContext = PersonUtil.getDefaultSecurityContext(context);
	PersonUtil.setSecurityContext(session, securityContext);
}
String isFromIFWE=emxGetParameter(request, "fromIFWE");
session.setAttribute("isFromIFWE", isFromIFWE);
String collabSpace = emxGetParameter(request,"collabSpace");
boolean ismob = UINavigatorUtil.isMobile(context, request);
boolean isPCTouch = UINavigatorUtil.isPCTouch(context, request);
boolean iscloud = false;

String strCloud= context.getCustomData("isCloud");
if(UIUtil.isNullOrEmpty(strCloud)){
	matrix.db.Context mnCtx = Framework.getMainContext(request);
	mnCtx.setCustomData("isMobile", String.valueOf(ismob));
	mnCtx.setCustomData("isPCTouch", String.valueOf(isPCTouch));
	iscloud = UINavigatorUtil.isCloud(context);
	mnCtx.setCustomData("isCloud", String.valueOf(iscloud));
}else{
	iscloud = UINavigatorUtil.isCloud(context);
}

boolean isTopFrameEnabled = UINavigatorUtil.isTopFrameEnabled(context);
String strLicenseUsageWarning = FrameworkLicenseUtil.getConnectLicWarning(context);
/*
*	Check if user is having ENO_BPS_TP license and keep it in session for performace improvement,
*	Later checkLicenseReserved(Context,String [], String) should be modified to be able to cache the licenses checks for the session
*	This is a workaround, Since we donot have direct access to session in checkLicenseReserved. For IR-236057V6R2014	 
*/

boolean isCPFUser= false;
try{
	FrameworkLicenseUtil.checkLicenseReserved(context, "ENO_BPS_TP");
	isCPFUser = true;
	}catch(Exception e)	{
		isCPFUser = false;
	}

session.setAttribute("isCPFUser",isCPFUser);

String sProtocol, sPort, sHost, sCtxPath, sRealURL;

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
//standard context path and querystring
sCtxPath = request.getContextPath();
sRealURL = sProtocol + "://" + sHost;
if (sPort.length() > 0) {
    sRealURL += ":"+ sPort;
}
sRealURL += sCtxPath;



String INT_CACHE_CATEGORIES_COUNT = "";
if(UINavigatorUtil.isMobile(context)){
	INT_CACHE_CATEGORIES_COUNT = EnoviaResourceBundle.getProperty(context, "emxFramework.UI.Cache.NumberOfCategories.Mobile").trim();
} else {
	INT_CACHE_CATEGORIES_COUNT = EnoviaResourceBundle.getProperty(context, "emxFramework.UI.Cache.NumberOfCategories.Desktop").trim();
}
%>
<script>
function updateLangPref(selectedlang){
	UWA.Data.proxies.passport = crossproxy;
	UWA.Data.request(passportURL+"/my-profile/update/language/"+selectedlang, {									
	   	method:"POST",
	   	cache:-1,
		proxy: "passport",
		onComplete : function(data){
			console.log("Successfully updated..........");
		}
	});
}
<%
String isPopup = emxGetParameter(request, "isPopup");
if(isPopup == null || !"true".equalsIgnoreCase(isPopup)){%>
      //OPENEROK
      window.opener = null;
<%}%>
var topFrameTagger;
var isTopFrameEnabled = <%= isTopFrameEnabled %>
var targetOrigin='<%=XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "targetOrigin"))%>';
var defOptionsGlobal = {
 		  socketName : '<%=XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "widgetId"))%>',
 		  targetOrigin : targetOrigin
 	  };
var topMostEnoviaWindow=true;
var appNameForHomeTitle='';
var brandName='';
var applicationProductInfo='';
function setApplicationProductInfo (JSONObj) {
     applicationProductInfo = JSON.parse(JSON.stringify(JSONObj));
}

var isPanelOpen = true;
var curProd = '';
var collabSpace = '<%=XSSUtil.encodeForJavaScript(context,collabSpace)%>';
var isMobile = <%=ismob%>;
var isPCTouch = <%=isPCTouch%>;
var CACHE_CATEGORIES_COUNT = <%=INT_CACHE_CATEGORIES_COUNT%>;
if(isMobile && CACHE_CATEGORIES_COUNT > 3){
	CACHE_CATEGORIES_COUNT = 3;
} else if(CACHE_CATEGORIES_COUNT > 5){
	CACHE_CATEGORIES_COUNT = 5;
} 
//XSSOK
var crossproxy = "<%=sCtxPath%>/common/emxCrossDomainProxy.jsp";
//XSSOK
var donwloadpf = "<%=sCtxPath%>/common/emxDownloadPlatform.jsp";

//XSSOK
var clntbaseImgPath = "<%=sCtxPath%>/webapps/i3DXCompass/assets/images/";
//XSSOK
var clntbaseHtmlPath = "<%=sCtxPath%>/webapps/i3DXCompass/";
//XSSOK
var clntbaseNlsPath = "<%=sCtxPath%>/webapps/i3DXCompass/assets/lang/";
//XSSOK
var clntbaseAppletPath = "<%=sCtxPath%>/webapps/i3DXCompass/assets/applet/";
var isfromIFWE = false;
<%
if(isFromIFWE != null && "true".equalsIgnoreCase(isFromIFWE)){
%>
isfromIFWE = true;
<%
}
%>



// Start MSF
var serverUrl = '<%=sRealURL%>';
// End MSF
//XSSOK
var clntlang = "<%=XSSUtil.encodeForJavaScript(context, (String)request.getHeader("Accept-Language"))%>";
if(clntlang)clntlang = clntlang.substr(0,2);
//XSSOK
var myAppsURL = "<%=FrameworkUtil.getMyAppsURL(context, request, response)%>";
//XSSOK
// Start MSF
var proxyTicketURL = serverUrl + '/resources/bps/proxyticket';
// End MSF
<%
String casURL = "";
String searchURL = "";
try {
		casURL = PropertyUtil.getEnvironmentProperty(context, "PASSPORT_URL");	    	
		searchURL = PropertyUtil.getEnvironmentProperty(context, "SEARCH_URL");
}catch(Exception e){
	// do nothing
}
%>

//XSSOK
var passportURL = '<%=casURL%>';
var searchURL = '<%=searchURL%>';
var curUserId = "<%=XSSUtil.encodeForJavaScript(context,context.getUser())%>";
var curSecCtx = "<%=XSSUtil.encodeForJavaScript(context, securityContext)%>";
var curTenant = "";
var currentApp = "ENOBUPS_AP";
<%
if(!FrameworkUtil.isOnPremise(context)){
%>
	curTenant = "<%=XSSUtil.encodeForJavaScript(context, context.getTenant())%>";
<%
}
%>

//XSSOK
var licenseWarning = "<%=strLicenseUsageWarning%>";

</script>

<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script src="scripts/emxUICore.js" type="text/javascript"></script>
<script src="scripts/emxClientSideInfo.js" type="text/javascript"></script>
<script language="javascript" src="scripts/emxJSValidationUtil.js"></script>
<script src='scripts/emxExtendedPageHeaderFreezePaneValidation.js'></script>

<link rel="stylesheet" type="text/css" href="../common/styles/emxUIExtendedHeader.css">
<link rel="stylesheet" type="text/css" href="../common/styles/emxUINavigator.css">
<link rel="stylesheet" href="styles/emxUIFancyTree.css"/>
<script>
	//IR-459941-3DEXPERIENCER2017x - NLS
	var require = {
           config: {
                  i18n: {
                       locale: clntlang
                  }
           }
        };
</script>
	
	
	<script src="../webapps/AmdLoader/AmdLoader.js"></script>
    <script type="text/javascript">window.dsDefaultWebappsBaseUrl = "../webapps/";</script>
	<script src="../webapps/WebappsUtils/WebappsUtils.js"></script>
	<script>
	require(['DS/WebappsUtils/WebappsUtils'], function (WebappsUtils){WebappsUtils._setWebappsBaseUrl('../webapps/');});
	</script>
	<script src="../webapps/c/UWA/js/UWA_W3C_Alone.js"></script> 
	<script src="scripts/emxSnN.js"></script>
    <link rel="stylesheet" type="text/css" href="../webapps/UIKIT/UIKIT.css">
<!-- Coachmark Init -->
	<script type="text/javascript" src="../webapps/Coachmark/Coachmark.js"></script>	
	<script type="text/javascript" src="scripts/emxUICompass.js"></script>
	<%
	if((isFromIFWE == null || !"true".equalsIgnoreCase(isFromIFWE)))
	{%>
		<!-- Compass Component Style -->
		<link rel="stylesheet" type="text/css" href="../webapps/i3DXCompass/i3DXCompass.css">
	
		<!-- Compass Component -->
		<script type="text/javascript" src="../webapps/i3DXCompass/i3DXCompass.js"></script>
	
		<!-- Coachmark Component Style -->
		<link rel="stylesheet" type="text/css" href="../webapps/Coachmark/Coachmark.css">
		<%	if(isTopFrameEnabled){ %>
			<link rel="stylesheet" type="text/css" href="../webapps/TopFrame/TopFrame.css">	
		<%}%>
	<%}%>
	
	<%if(!isTopFrameEnabled){ %>
		<script type="text/javascript">
			window.addEventListener('load', function(){
				Compass.init("compassHoldout");
			});
		</script>
	<%} %>
<jsp:useBean id="shortcutInfo" class="com.matrixone.apps.framework.ui.UIShortcut" scope="session" />
<%

String strToolBarPref = "";
strToolBarPref = PersonUtil.getToolbarPreference(context);

if(strToolBarPref == null || "".equals(strToolBarPref.trim())){
    String strToolBarProp = EnoviaResourceBundle.getProperty(context, "emxFramework.Preferences.ToggleBrowserToolbar");
    if(strToolBarProp != null && "Yes".equalsIgnoreCase(strToolBarProp)){
        strToolBarPref = "true";
    }else if(strToolBarProp != null && "No".equalsIgnoreCase(strToolBarProp)){
        strToolBarPref = "false";
    }
}


String objectId =emxGetParameter(request, "objectId");
String physicalId =emxGetParameter(request, "physicalId");
String ContentPage =emxGetParameter(request, "ContentPage");
String MenuName =emxGetParameter(request, "MenuName");
String CommandName =emxGetParameter(request, "CommandName");
String Mode =emxGetParameter(request, "mode");
String treeMenu = emxGetParameter(request, "treeMenu");
String treeLabel = emxGetParameter(request, "treeLabel");
String emxSuiteDirectory = emxGetParameter(request, "emxSuiteDirectory");
String DefaultCategory = emxGetParameter(request, "DefaultCategory");
String TargetLocation = emxGetParameter(request, "TargetLocation");
String mxTree = emxGetParameter(request, "emxTree");

String ContentURL = (String)session.getAttribute("ContentURL");
if(!UIUtil.isNullOrEmpty(ContentURL)){
	ContentURL = Framework.getClientSideURL(response, ContentURL);
}
//Global toolbar back-forward button label
Locale locale = new Locale((String)request.getHeader("Accept-Language"));
String STR_FORWARD_BUTTON = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", locale, "emxFramework.ForwardToolbarMenu.label");
String STR_BACK_BUTTON = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", locale, "emxFramework.BackToolbarMenu.label");

boolean isTree=false;
String appendParams = "";

String windowWidth = emxGetParameter(request, "width");
String windowHeight = emxGetParameter(request, "height");
String PageQueryString =emxGetParameter(request, "pageURL");
String ShowNavigatorWindow = emxGetParameter(request, "isNavigator");



boolean isNavigator=false;
if(ShowNavigatorWindow !=null && ShowNavigatorWindow.equalsIgnoreCase("true"))
{
    isNavigator=true;
}

/*** Shortcut panel ***/

ArrayList[] contentMap = shortcutInfo.getShortcutMap("Shortcut_Content");
shortcutInfo.setShortcutMap("Shortcut_Content",contentMap);

/*** Shortcut panel ***/

try{
    ContextUtil.startTransaction(context, false);

    if(emxSuiteDirectory==null || emxSuiteDirectory.trim().length()==0){
        emxSuiteDirectory = emxGetParameter(request, "SuiteDirectory");
    }

    if(mxTree !=null && mxTree.equalsIgnoreCase("true")) {
        isTree=true;
    }

    if (objectId == null && physicalId != null && physicalId.trim().length() > 0 ) {
       // objectId = MqlUtil.mqlCommand(context,"print bus " + physicalId + " select id dump");
		  String sCmd = "print bus $1 select $2 dump";
		  objectId = MqlUtil.mqlCommand(context,sCmd,physicalId,"id");
    }

    if (objectId != null && objectId.trim().length() > 0 )
      appendParams = appendParams + "objectId=" + XSSUtil.encodeForURL(context, objectId);
    if (ContentPage != null && ContentPage.trim().length() > 0 )
      appendParams = appendParams + "&ContentPage=" + XSSUtil.encodeForURL(context, ContentPage);
    if (treeMenu != null && treeMenu.trim().length() > 0 )
      appendParams = appendParams + "&treeMenu=" + XSSUtil.encodeForURL(context, treeMenu);
    if (treeLabel != null && treeLabel.trim().length() > 0 )
      appendParams = appendParams + "&treeLabel=" + XSSUtil.encodeForURL(context, treeLabel);
    if (DefaultCategory != null && DefaultCategory.trim().length() > 0 )
      appendParams = appendParams + "&DefaultCategory=" + XSSUtil.encodeForURL(context, DefaultCategory);
    if (emxSuiteDirectory != null && emxSuiteDirectory.trim().length() > 0 )
      appendParams = appendParams + "&emxSuiteDirectory=" + XSSUtil.encodeForURL(context, emxSuiteDirectory);
    if (TargetLocation != null && TargetLocation.trim().length() > 0 )
      appendParams = appendParams + "&TargetLocation=" + XSSUtil.encodeForURL(context, TargetLocation);


    // If the side door - Forward flags are existing, clear them from session.
    // The session level attributes are set by "emxNavigatorSideDoorInclude.jsp" file

    if ( session.getAttribute("ForwardURL") != null );
      session.removeAttribute("ForwardURL");
    if ( session.getAttribute("portal") != null );
      session.removeAttribute("portal");


    if (appendParams != null && appendParams.trim().length() > 0 ) {
     appendParams = UINavigatorUtil.encodeURL(appendParams);
    }

    // Page History process
    if(isTree)
    {
    	StringBuffer qStringBuff = new StringBuffer();
        Enumeration eNumParameters = emxGetParameterNames(request);
        while( eNumParameters.hasMoreElements() ) {
            String parmName = (String)eNumParameters.nextElement();
            if("contentURL".equals(parmName)){
            	continue;
            }
            String parmValue = (String)emxGetParameter(request,parmName);
            qStringBuff.append(XSSUtil.encodeForURL(context,parmName));
            qStringBuff.append("=");
            qStringBuff.append(XSSUtil.encodeForURL(context,parmValue));

            if(eNumParameters.hasMoreElements()){
                qStringBuff.append("&");
            }
        }
        appendParams = qStringBuff.toString();
        if(appendParams != null ) {
            appendParams=com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(appendParams);
        }

        if (emxSuiteDirectory != null && emxSuiteDirectory.trim().length() > 0 &&
            appendParams.indexOf("emxSuiteDirectory=")==-1  )
        {
            appendParams = appendParams + "&emxSuiteDirectory=" + XSSUtil.encodeForURL(context, emxSuiteDirectory);
        }

        appendParams = UINavigatorUtil.encodeURL(appendParams);
    }

}catch (Exception ex){
    ContextUtil.abortTransaction(context);

    if(ex.toString() != null && (ex.toString().trim()).length()>0){
        emxNavErrorObject.addMessage("emxNavigator:" + ex.toString().trim());
    }
}
finally{
    ContextUtil.commitTransaction(context);
}

String enablePageHistory = "false";
try
{
	enablePageHistory = EnoviaResourceBundle.getProperty(context, "emxFramework.EnablePageHistory");
}catch(Exception ex)
{
	// Do nothing as default value is set in definetion of variable.
}
%>
<script>
var enablePageHistory = "<%=XSSUtil.encodeForJavaScript(context,enablePageHistory)%>";
//For platform data service
var x3DPlatformServices = "";
require(['DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices'] ,
	function (i3DXCompassPlatformServices) {
		i3DXCompassPlatformServices.getPlatformServices({
			onComplete: function(data){ 
				x3DPlatformServices = data;
			}
		})		
	});
</script>
<%
if( TargetLocation != null && TargetLocation.equalsIgnoreCase("popup") && !isNavigator)
{
     if (MenuName != null && MenuName.trim().length() > 0 ) {
         appendParams = appendParams + "&MenuName=" + XSSUtil.encodeForURL(context, MenuName);
     }
     if (CommandName != null && CommandName.trim().length() > 0 ) {
         appendParams = appendParams + "&CommandName=" + XSSUtil.encodeForURL(context, CommandName);
     }
%>
    <script>
    document.location.href="../common/emxPageHistoryShowPopup.jsp?<%=appendParams%>&pageURL=<%=XSSUtil.encodeForURL(context, PageQueryString)%>";
    </script>
<%
}else{
    if(TargetLocation != null && TargetLocation.equalsIgnoreCase("popup") && isNavigator)
    {

        if(windowWidth == null)
        {
            windowWidth="600";
        }
        if(windowHeight == null)
        {
            windowHeight="600";
        }

  // pass the menu name and command name only to the page history and not to navigator content
        String pageHistAppendParams = appendParams;
     if (MenuName != null && MenuName.trim().length() > 0 ) {
         pageHistAppendParams = pageHistAppendParams + "&MenuName=" + XSSUtil.encodeForURL(context, MenuName);
     }
     if (CommandName != null && CommandName.trim().length() > 0 ) {
         pageHistAppendParams = pageHistAppendParams + "&CommandName=" + XSSUtil.encodeForURL(context, CommandName);
     }

%>
        <script>
        var strFeatures = "width=<%=XSSUtil.encodeForJavaScript(context, windowWidth)%>,height=<%=XSSUtil.encodeForJavaScript(context, windowHeight)%>,dependent=yes,resizable=yes";
        getTopWindow().window.open("../common/emxPageHistoryShowPopup.jsp?<%=pageHistAppendParams%>&pageURL=<%=XSSUtil.encodeForURL(context, PageQueryString)%>", "NewWindow", strFeatures);
        </script>

<%
    } else {
     if (MenuName != null && MenuName.trim().length() > 0 ) {
         appendParams = appendParams + "&MenuName=" + XSSUtil.encodeForURL(context, MenuName);
     }
     if (CommandName != null && CommandName.trim().length() > 0 ) {
         appendParams = appendParams + "&CommandName=" + XSSUtil.encodeForURL(context, CommandName);
     }

    }
    
            // Added for Portlet Collections
            /*if(objectId == null || objectId.trim().length() == 0)
            {*/
            	StringBuffer qStringBuff = new StringBuffer();
                Enumeration eNumParameters = emxGetParameterNames(request);
                while( eNumParameters.hasMoreElements() ) {
                    String parmName = (String)eNumParameters.nextElement();
                    if("contentURL".equals(parmName)){
                    	continue;
                    }        
                    String parmValue = (String)emxGetParameter(request,parmName);
                    if("physicalId".equals(parmName)){
                    	parmName = "objectId";
                    	parmValue = objectId;
                    }
					if("objectId".equals(parmName) && qStringBuff.indexOf("objectId=") != -1){
                    	continue;
                    }
                    qStringBuff.append(XSSUtil.encodeForURL(context, parmName));
                    qStringBuff.append("=");
                    qStringBuff.append(XSSUtil.encodeForURL(context, parmValue));

                    if(eNumParameters.hasMoreElements()){
                        qStringBuff.append("&");
                    }
                }
                appendParams = qStringBuff.toString();
				 if(appendParams.endsWith("&")){
                	appendParams = appendParams.substring(0, appendParams.length() -1);
                }
				String apParam=appendParams;
				 if(apParam.contains("fromExt")){
					 apParam=apParam.replace("&fromExt=true", "");
				 }
            //}
%>


<link rel="shortcut icon" href="../favicon.ico" type="image/x-icon" />
 <title><emxUtil:i18n localize="i18nId">emxFramework.Login.Title</emxUtil:i18n></title>
 <%@include file = "emxUIConstantsInclude.inc"%>

        <script src="scripts/emxUIModal.js" type="text/javascript"></script>
        <script type="text/javascript" language="javascript">
        function redirectTheParent()
        {
        	if(isIE && !(isMinIE10 || isIE11))
            {
                setTimeout(function(){
                document.location.href="../emxLoginDisplay.jsp";
                //XSSOK
                var myWindow = showAndGetNonModalDialog("emxNavigator.jsp?<%=appendParams%>",1100,700,true);
                //OPENEROK
                myWindow.opener = null;
                myWindow.getTopWindow().moveTo(-4,-4);
                myWindow.getTopWindow().resizeTo(screen.availWidth+6,screen.availHeight+6);
                }, 1500);
            } else {
                //XSSOK
                var myWindow = showAndGetNonModalDialog("emxNavigator.jsp?<%=appendParams%>",1100,700,true);
                    //OPENEROK
                    myWindow.opener = null;
                    document.location.href="../emxLoginDisplay.jsp";
            }
        }

<%
if(isOpened != null  && "false".equalsIgnoreCase(isOpened) && "false".equalsIgnoreCase(strToolBarPref)){
%>
            redirectTheParent();
<%
}
%>
        addStyleSheet("emxUIMenu");
        // Javascript Object/variable to hold all the Child windows reference.
        if (!getTopWindow().childWindows) {
            if(isIE && getTopWindow().getWindowOpener()){
            	getTopWindow().childWindows = getTopWindow().getWindowOpener().getTopWindow().childWindows;
            }else{
            getTopWindow().childWindows = new Array;
            }
        }
    </script>

 <script src="scripts/emxUICoreTree.js" type="text/javascript"></script>
 <script src="scripts/emxUIUtility.js" type="text/javascript"></script>
 <script src="scripts/emxUIPopups.js" type="text/javascript"></script>
 <script src="scripts/emxUIToolbar.js" type="text/javascript"></script>
 <script src="scripts/emxUINavigator.js" type="text/javascript"></script>
 <script src="scripts/emxUIHistoryTree.js" type="text/javascript"></script>
 <script src="scripts/emxUIStructureTree.js" type="text/javascript"></script>
 <script src="scripts/emxUIDetailsTree.js" type="text/javascript"></script>
 <script src="scripts/emxUITreeUtil.js" type="text/javascript"></script>
 <script src="scripts/emxUISearch.js" type="text/javascript"></script>
 <script src="scripts/emxUIMetrics.js" type="text/javascript"></script>
 <script src="scripts/emxUISlideIn.js" type="text/javascript"></script>
 <script src="scripts/emxUICalendar.js" type="text/javascript"></script>
 <script src="scripts/emxUICategoryTab.js" type="text/javascript"></script>
 
 <script type="text/javascript" src="scripts/jquery-ui.custom.js"></script>
 <script type="text/javascript" src="../webapps/VENENOFrameworkPlugins/plugins/fancytree/latest/jquery.fancytree.js"></script>
 <script type="text/javascript" src="../webapps/VENENOFrameworkPlugins/plugins/fancytree/latest/jquery.fancytree.childcounter.js"></script>
 <script type="text/javascript" src="../webapps/VENENOFrameworkPlugins/plugins/fancytree/latest/jquery.fancytree.filter.js"></script>   
 <script src="scripts/emxUIStructureFancyTree.js" type="text/javascript"></script>
 <script type="text/javascript" src="scripts/jquery.fancytree.persist.js"></script>
 <script type="text/javascript" src="scripts/jquery.cookie.js"></script> 
 <script src="scripts/bpsUWAUtils.js" type="text/javascript"></script>
 <script src="scripts/emxNavigatorHelp.js" type="text/javascript"></script>
 <link rel="stylesheet" type="text/css" href="../plugins/libs/jqueryui/1.10.3/css/jquery-ui.css">
 <link rel="stylesheet" type="text/css" href="styles/emxUIImageManagerInPlace.css">
<%
if(isFromIFWE != null && "true".equalsIgnoreCase(isFromIFWE))
{

} else {
%> 
  <script type="text/javascript" src="../webapps/TagNavigator/TagNavigator.js"></script>
  <script type="text/javascript" src="scripts/bpsTagNavConnector.js"></script>
  <link rel="stylesheet" type="text/css" href="../webapps/TagNavigator/TagNavigator.css">
 
<%
}
%> 
<script type="text/javascript">

  var objDetailsTree = new emxUIDetailsTree;
  var objStructureTree = new emxUIStructureTree;

  var objStructureFancyTree;
  require(['emxUIStructureFancyTree',
           'bpsUWAInterCom'
          ],
  	  function (emxUIStructureFancyTree, bpsUWAInterCom){
	     objStructureFancyTree = emxUIStructureFancyTree;
	     
	     var defOptions = {
	   		  socketName : '<%=XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "widgetId"))%>',
	   		  eventName : 'uwaGlobalToolbarAddEvent',
	   		  targetOrigin : targetOrigin
	   	  };
	   	  bpsUWAInterCom.registerHandler(showGTBModalDialog, defOptions);
  	  }
  );
  function showGTBModalDialog(json, info) {
	  emxUICore.link(json.url);
	 }
  if(objStructureFancyTree){
	  objStructureFancyTree.destroy();
  }
  //objStructureFancyTree.init();
  
  function initStructureTree(){
      objStructureTree = new emxUIStructureTree;
      objDetailsTree = objStructureTree;
      return objStructureTree ;
  }

 emxUINavigator.setLayout(emxUINavigator.LAYOUT_SHRUNK);
 //XSSOK
 var contentURL =  "<%=ContentURL%>";
 if(contentURL != null && contentURL != "null" && contentURL != ""){
<%
String strAppName =  emxGetParameter(request, "appName");
String strSwitchContext =  emxGetParameter(request, "switchContext");
String strloadpage = "emxNavigatorContentLoad.jsp";
boolean isAppNamePresent = UIUtil.isNotNullAndNotEmpty(strAppName);
if(isAppNamePresent){
	strloadpage += "?fromIFWE=" +  XSSUtil.encodeForURL(context, isFromIFWE) + "&appName=" + XSSUtil.encodeForURL(context, strAppName);
}
if(UIUtil.isNotNullAndNotEmpty(strSwitchContext)){
	if(isAppNamePresent){
		strloadpage += "&switchContext=" +  XSSUtil.encodeForURL(context, strSwitchContext);
	}else{
		strloadpage += "?switchContext=" +  XSSUtil.encodeForURL(context, strSwitchContext);
	}
}

%>
	 //XSSOK
	 emxUINavigator.setContent("<%=strloadpage%>");
  }else{
	 //XSSOK
	 emxUINavigator.setContent("emxNavigatorContentLoad.jsp?<%=appendParams%>");
  }



 //emxUINavigator.toolbar.historyEnabled = true;
</script>
 <script type="text/javascript">
 function launchHomePage(){
	 
	 var homeurl = 'emxNavigator.jsp?appName=' + currentApp + "&<%=apParam%>";
	 if(homeurl.contains('objectId')){
	    var tempobj=homeurl.match("[&|?]objectId=");
        var idStartIndex = homeurl.indexOf(tempobj);
        var isLastIndex = homeurl.indexOf("&",idStartIndex+1);
        if(isLastIndex == -1){
        	isLastIndex = homeurl.length;
        }
		var objId= homeurl.slice(idStartIndex ,isLastIndex );
		homeurl=homeurl.replace(objId,'');
	}
	 if(getTopWindow().isfromIFWE){
		 homeurl += "&fromIFWE=true";
	 }
	 location.href = homeurl; 
   
	 if(isfromIFWE){
	     	setUWAPref('DefaultCategory','');
	     	setUWAPref('objectId','');
	       setUWAPref('DefaultLocation','');
	       setUWATitle('');
	     }

 }
 
var isInPopup = "<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "isPopup"))%>";
 </script>

<%
	if(isFromIFWE != null && "true".equalsIgnoreCase(isFromIFWE)){
%>
<script src="emxNavigatorToolbar.jsp?toolbar=AEFGlobalToolbarIFWE&widgetId=<%=XSSUtil.encodeForURL(context, emxGetParameter(request, "widgetId"))%>&isPopup=<%=XSSUtil.encodeForURL(context, emxGetParameter(request, "isPopup"))%>" type="text/javascript"></script>
<%
	} else {
%>
<script src="emxNavigatorToolbar.jsp?toolbar=AEFGlobalToolbar&isPopup=<%=XSSUtil.encodeForURL(context, emxGetParameter(request, "isPopup"))%>" type="text/javascript"></script>
<%
	}
%>
 <!-- <script src="scripts/emxUIHistoryController.js" type="text/javascript"></script>  -->
<%
//Start of Code for loading the back history items
MapList backHistoryList = (MapList)session.getAttribute("AEF.backHistory");
MapList forwardHistoryList = (MapList)session.getAttribute("AEF.forwardHistory");

if((backHistoryList != null && backHistoryList.size() >0) || (forwardHistoryList != null && forwardHistoryList.size() >0)){
%>
        <script type="text/javascript">
            forwardHistoryArr = new Array();
      backHistoryArr = new Array();
        </script>
<%
        String strURL = "";
        String strCommandTitle = "";
        String targetLocation = "";
        String width = "";
        String height = "";
        HashMap hp = null;
    if(forwardHistoryList != null && forwardHistoryList.size() >0){
            for (int i=0;i<forwardHistoryList.size();i++){
                hp = (HashMap) forwardHistoryList.get(i);
                if(hp != null){
                    strURL = (String) hp.get("backURL");
                    strCommandTitle = (String) hp.get("backCommandTitle");
                    targetLocation = (String) hp.get("TargetLocation");
                    width = (String) hp.get("width");
                    height = (String) hp.get("height");
%>
                    <script type="text/javascript">
                        //XSSOK
                        forwardHistoryArr.push(new emxUIHistoryItem('<%=strURL%>','<%=targetLocation%>','<%=width%>','<%=height%>',"<%=strCommandTitle%>"));
                    </script>
<%
                }
            }
    }
    if((backHistoryList != null && backHistoryList.size() >0) ) {
            for (int i=0;i<backHistoryList.size();i++){
                hp = (HashMap) backHistoryList.get(i);
                if(hp != null){
                    strURL = (String) hp.get("backURL");
                    strCommandTitle = (String) hp.get("backCommandTitle");
                    targetLocation = (String) hp.get("TargetLocation");
                    width = (String) hp.get("width");
                    height = (String) hp.get("height");
%>
                    <script type="text/javascript">
                        //XSSOK
                        backHistoryArr.push(new emxUIHistoryItem('<%=strURL%>','<%=targetLocation%>','<%=width%>','<%=height%>',"<%=strCommandTitle%>"));
                    </script>
<%
                }
            }
        }
}
//End of code for loading the back history items
String integrationsSource = "";
String prMQLString = "execute program $1 $2";
String appNames = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context,prMQLString,"eServiceHelpAbout.tcl" ,"TRUE");
StringList appTokens = (StringList)FrameworkUtil.splitString(appNames, "|");
String strFullName = PersonUtil.getFullName(context);
for(int appCnt = 0; appCnt < appTokens.size(); appCnt++){
    String appName = (String) appTokens.get(appCnt);
    if("DesignerCentral".equalsIgnoreCase(appName) || "IntegrationFramework".equalsIgnoreCase(appName) || "ProductLine".equalsIgnoreCase(appName)){
        integrationsSource = "../integrations/emxIntegrations.jsp";
        break;
    }
}
request.setAttribute("callerPage", "home");
request.setAttribute("integrationsSource", integrationsSource);
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

<%

boolean isIE = EnoviaBrowserUtility.is(request,Browsers.IE);
String onloadMethods = "initializeSlideIns();expandMenuData();setErrorHandlerWAFData();";
String serverExpiryTimeCookieName = EnoviaResourceBundle.getProperty(context, "emxFramework.SessionTimeout.AutoLogout.Cookie.ServerExpiryTime");
HashMap cookieMap = FrameworkUtil.getCookieMap(context,request);
String serverExpiryTimeCookieValue = (String)cookieMap.get(serverExpiryTimeCookieName);
boolean hasTimeoutCookie = UIUtil.isNotNullAndNotEmpty(serverExpiryTimeCookieValue);
if(UINavigatorUtil.isMobile(context)){
	onloadMethods = onloadMethods + "setScrollTopOnClose();";
}
if(hasTimeoutCookie){
	onloadMethods = onloadMethods + "calcTimeoutOffset();";
}
if(isTopFrameEnabled){%>
	<script type="text/javascript" src="scripts/emxUITopBar.js"></script>	
<%
	onloadMethods = onloadMethods + "BPSTopBar.loadTopBar();";
}%>
</head>
<%
if(isIE){%>
<body class="navigator no-footer" onload="<%=onloadMethods%>" onunload="if(isInPopup && isInPopup == 'true') {return;} closeAllChildWindows()">
<% }else{%>
<body class="navigator no-footer" onload="<%=onloadMethods%>" onBeforeunload="if(isInPopup && isInPopup == 'true') {return;} closeAllChildWindows()">
<%}
if(isFromIFWE != null && "true".equalsIgnoreCase(isFromIFWE))
{
%>
        <div class="toolbar-container" style="display:none;" id="globalToolbar">
				<div id="divToolbar" class="toolbar-frame"></div>
    </div>
<%	
} else {
%>
  <%if(!isTopFrameEnabled){ %>
	<div id="pageHeadDiv">
		<form name="navigatorForm">
	        <div class="toolbar-container" id="globalToolbar">
					<div id="divToolbar" class="toolbar-frame"></div>
	    	</div>
	    	
			<div id="navBar">
			</div>
			<div id="appsPanel"></div>
		</form>
 	</div>
<%}else{ %>
	<div id="navBar">
	</div>
	<div id="pageHeadDiv" style="display:none;">
		<form name="navigatorForm">
	        <div class="toolbar-container" id="globalToolbar">
					<div id="divToolbar" class="toolbar-frame"></div>
	    	</div>
	    	
			<div id="navBar">
			</div>
			<div id="appsPanel"></div>
		</form>
 	</div>

<%} %>
<%
}
%>
<div id="ExtpageHeadDiv" class="page-head" style="height:80px"></div>
<div id="panelToggle" class="panel-toggle open"></div>
<div id="leftPanelMenu" class="slide-in-panel menu categories" style="display:none">
	<div id="togglecat" class="toggle" style="display:none;">
		<a href="javascript:showCategoryTree()"><button id="catButton" class="toggle-inactive"><img src="images/iconActionSmallReturnToFacets.png"/></button></a> 
		<a href="javascript:showStructureTree()"><button id="strucButton" class="toggle-active"><img src="images/iconActionSmallReturnToTree.png"/></button></a>
	</div>
	<div id="catMenu" class="menu categories" style="display:none;top:0px;"></div>
	<div id="leftPanelTree" style="display:none;top:16px;"></div>
 </div>
	<div id="mx_divGrabber" style="bottom: 0px; z-index: 1; top: 159px; left: 212px;">
		<div id="mx_divGrabberHead"></div>
		<div id="mx_divGrabberBody" style="top: 126px;"></div>
 	
 </div>
<%	
if((isFromIFWE == null && !"true".equalsIgnoreCase(isFromIFWE)) && !isTopFrameEnabled)
{%>
	<div id="compassHoldout"></div>
<%}%>

 <%@include file = "emxNavigatorLayout.inc"%>
 <!--
 This div and Form are added to remove the checkout empty dilaog
 Do not remove this as AEF is not using this form or div.
 -->
 <div id="checkoutdiv">
  <form name="commonDocumentCheckout" id="commonDocumentCheckout" method="post" action="../components/emxCommonDocumentPreCheckout.jsp">
      <input type="hidden" name="objectId" />
      <input type="hidden" name="action" />
      <input type="hidden" name="format" />
      <input type="hidden" name="fileName" />
      <input type="hidden" name="appName" />
      <input type="hidden" name="appDir" />
      <input type="hidden" name="closeWindow" />
      <input type="hidden" name="refresh" />
      <input type="hidden" name="trackUsagePartId" />
      <input type="hidden" name="version" />
      <input type="hidden" name="customSortColumns" />
      <input type="hidden" name="customSortDirections" />
      <input type="hidden" name="uiType" />
      <input type="hidden" name="table" />
      <input type="hidden" name="getCheckoutMapFromSession" />
      <input type="hidden" name="fromDataSessionKey" />
      <input type="hidden" name="parentOID" />
      <input type="hidden" name="appProcessPage" />
      <input type="hidden" name="portalMode" />      
      <input type="hidden" name="frameName" />
      <input type="hidden" name="id" />
      <input type="hidden" name="fileAction" />
      <input type="hidden" name="file" />
      <input type="hidden" name="versionId" />
  </form>
</div>
<div id="switchContextDialog">
</div>
    <div id="tn-target" style="display: none"></div>
    <script type="text/javascript">
    emxUINavigator.myAppsURL = myAppsURL;
    emxUINavigator.tabCtx ='<%= XSSUtil.encodeForURL(request.getParameter("ctx")) %>';
    emxUINavigator.fromIFWE = '<%= XSSUtil.encodeForURL(request.getParameter("fromIFWE")) %>';
    if (emxUINavigator.fromIFWE === 'true') {
      showSlideInDialog.mode = "tag navigator";
    }
//UWA.InterCom
function initInterCom() {
  if (setUWAPref.widgetEventSocket == null) {
      var InterCom = UWA.Utils.InterCom; // Make an alias to API, it's not required, but help for compression and shortcut.
      setUWAPref.evtSocketName = 'bps_';// + Math.random();
      setUWAPref.widgetEventSocket = new InterCom.Socket(setUWAPref.evtSocketName); // Init "widgetNameEventSocket" into an iframe or main page
      setUWAPref.widgetEventSocket.subscribeServer('bps.intercom.server',parent,targetOrigin);
  }
};
function setUWAPref(name, val) {
  initInterCom();
  setUWAPref.widgetEventSocket.dispatchEvent('onAddPref', {name:'e6w-preference_'+name,value:val});
};
function setUWATitle(title) {
  initInterCom();
  setUWAPref.widgetEventSocket.dispatchEvent('onSetTitle', {title:title});
};

/**
 *method registerIdtoCompass
 *param {String} Id contains physicalId of the object
 *param {String} curSecCtx Security Context
**/

function registerIdtoCompass(Id,curSecCtx) {
  initInterCom();
  setUWAPref.widgetEventSocket.dispatchEvent('onRegisteredId', {physicalID:Id,currentSecurityCtx:curSecCtx});
};

function unregisterIdtoCompass() {
  initInterCom();
  setUWAPref.widgetEventSocket.dispatchEvent('onUnregisterId');
};

<%
    if(isFromIFWE != null && "true".equalsIgnoreCase(isFromIFWE))
    {
    	
    } else {
	if(!isTopFrameEnabled){
%> 
    jQuery(function() {// onload initialization
        bpsTagNavConnector.initTagNavigator();
    });
<%}else{%>
	require(['DS/TagNavigator/TagNavigator'], function(TagNavigator) {
		topFrameTagger = TagNavigator;
	});
  <%}
}
if(isOpened != null  && "false".equalsIgnoreCase(isOpened)){
%>
     emxUINavigator.loadCoachmark(false);

<%
}

%>

if(passportURL && passportURL!="" && !isfromIFWE ){
	var paramTenant = getTopWindow().location.search.match(/[?&]tenant=([^&]*)?/);
	paramTenant = (paramTenant == null ? undefined : paramTenant[1] || undefined);
	var tenantId =  paramTenant == "onpremise" ? undefined : paramTenant;
	
	require([
	         // Legal Module
	         'DS/W3DLegal/W3DLegal'
	
	         ], function (Legal) {
	                'use strict';
	
	                        // Called when About 3DEXPERIENCE Platform is clicked
	                        function aboutHandler () {
	                        	showAndGetNonModalDialog("../common/emx3DExperiencePlatformAbout.jsp?suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common","530","325",true);
	                        }
	
	                        // This function onAccept is called even if there are no terms to accept
	                        function onAccept (options) {
	                                console.log('Terms accepted !');
									if(options.isFooterRendered ){
										jQuery("div#panelToggle").addClass("footer-notice-yes");
										jQuery("div#mydeskpanel").addClass("footer-notice-yes");
										jQuery("div#pageContentDiv").addClass("footer-notice-yes");
										jQuery("div#leftPanelMenu").addClass("footer-notice-yes");
									}
	                        }
	                        UWA.Data.proxies.passport = crossproxy;
	                        Legal.init({
	                                myAppsBaseUrl: myAppsURL,
	                                footerContainer: document.body,
	                                onAccept: onAccept,
	                                onAboutClick: aboutHandler,
	                                tenantId: tenantId
	                        });
	 });
}

if(licenseWarning && licenseWarning.length > 0){
	showTransientMessage(licenseWarning, "warning");
}
require(["UWA/Utils/InterCom"], function(InterCom){
	"use strict";
	var busServer = new InterCom.Server('enovia.bus.server', {
	    isPublic: true 
	});
	var extendedHeadersocket = new InterCom.Socket(); 
	extendedHeadersocket.subscribeServer('enovia.bus.server', getTopWindow());   
	extendedHeadersocket.addListener('objectChanged', function (data) {
		var oid = data.oid;
		var el = jQuery("#divExtendedHeaderContent");
		var headerOID = el.attr("o");
		if(!oid || oid != headerOID){
			return;
		}
		refreshWholeTree("", oid, el.attr("dr"), el.attr("dc"), el.attr("showStates"), el.attr("mcs"), el.attr("idr"), true,  el.attr("showDescription"));
	});	
	if(emxUIConstants.USEMSF == "true") {
		require(['DS/MSFDocumentManagement/MSFDocumentClient'], function (MSFDocumentClient){
			MSFDocumentClient.onConnectWithMSF(curUserId, serverUrl, curTenant, passportURL, proxyTicketURL, myAppsURL);		
		});
	}
});
</script>
</body>
</html>

<%
}
%>

