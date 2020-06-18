<%--  emxNavigatorDialog.jsp
  (c) Dassault Systemes, 1993 - 2018.  All rights reserved.
--%>
<%
  response.addHeader("Cache-Control", "no-cache");
%>

<%@include file = "emxNavigatorSideDoorInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>

<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<head>
<script src="../common/scripts/jquery-latest.js" type="text/javascript"></script>
<script src="scripts/emxUICore.js" type="text/javascript"></script>
<script src="scripts/emxJSValidationUtil.js" type="text/javascript"></script>
<script src='scripts/emxExtendedPageHeaderFreezePaneValidation.js'></script>

<link rel="stylesheet" type="text/css" href="../common/styles/emxUIExtendedHeader.css">
<link rel="stylesheet" type="text/css" href="../common/styles/emxUINavigator.css">
<link rel="stylesheet" href="styles/emxUIFancyTree.css"/>

<script src="../webapps/AmdLoader/AmdLoader.js" type="text/javascript"></script>
 <script type="text/javascript">window.dsDefaultWebappsBaseUrl = "../webapps/";</script>
 <script src="../webapps/WebappsUtils/WebappsUtils.js" type="text/javascript"></script>
  <script>
	require(['DS/WebappsUtils/WebappsUtils'], function (WebappsUtils){WebappsUtils._setWebappsBaseUrl('../webapps/');});
</script>
<script src="../webapps/c/UWA/js/UWA_W3C_Alone.js"></script> 
 <link rel="stylesheet" type="text/css" href="../webapps/UIKIT/UIKIT.css">
<script src="scripts/emxClientSideInfo.js" type="text/javascript"></script>
<link rel="shortcut icon" href="../favicon.ico" type="image/x-icon" />
<title><%=sAppName%></title>
<%@include file = "emxUIConstantsInclude.inc"%>
<script src="scripts/emxUIModal.js" type="text/javascript"></script>
<script type="text/javascript" language="javascript">
        addStyleSheet("emxUIDefault");
        addStyleSheet("emxUINavigator");
        var clntlang = "<%=XSSUtil.encodeForJavaScript(context,(String)request.getHeader("Accept-Language"))%>";
        if(clntlang)clntlang = clntlang.substr(0,2);
      //XSSOK
        var myAppsURL = "<%=FrameworkUtil.getMyAppsURL(context, request, response)%>";
        var curUserId = "<%=XSSUtil.encodeForJavaScript(context,context.getUser())%>";
        var curSecCtx = "<%=XSSUtil.encodeForJavaScript(context, PersonUtil.getActiveSecurityContext(context))%>";
        var curTenant = "";
        <%
        if(!FrameworkUtil.isOnPremise(context)){
        %>
        	curTenant = "<%=XSSUtil.encodeForJavaScript(context, context.getTenant())%>";
        <%
        }
        %>
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
  <script src="scripts/jquery.fancytree.persist.js" type="text/javascript"></script>
 <script src="scripts/jquery.cookie.js" type="text/javascript"></script>
 <!-- ESAPI Start-->
 <script type="text/javascript" language="JavaScript" src="../plugins/esapi4js/esapi-min.js"></script>
 <script type="text/javascript" language="JavaScript" src="../plugins/esapi4js/resources/i18n/ESAPI_Standard_en_US.properties.js"></script>
 <script type="text/javascript" language="JavaScript" src="../plugins/esapi4js/resources/Base.esapi.properties.js"></script>
 <script type="text/javascript" language="JavaScript">
 	org.owasp.esapi.ESAPI.initialize(); 		
 </script>
<!-- ESAPI END-->
 <script type="text/javascript">
    
  var objDetailsTree = new emxUIDetailsTree;
  var objStructureTree = new emxUIStructureTree;
  var objStructureFancyTree;
  require(['emxUIStructureFancyTree'],
      function (emxUIStructureFancyTree){
       objStructureFancyTree = emxUIStructureFancyTree;
      }
  );
  function initStructureTree(){
      objStructureTree = new emxUIStructureTree;
      objDetailsTree = objStructureTree;
      return objStructureTree ;
  }
  var x3DPlatformServicesDialog = "";
  require(['DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices'] ,
	function (i3DXCompassPlatformServices) {
		i3DXCompassPlatformServices.getPlatformServices({
			onComplete: function(data){ 
				x3DPlatformServicesDialog = data;
			}
		})		
	});
</script>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
<%String INT_CACHE_CATEGORIES_COUNT = "";
if(UINavigatorUtil.isMobile(context)){
	INT_CACHE_CATEGORIES_COUNT = EnoviaResourceBundle.getProperty(context, "emxFramework.UI.Cache.NumberOfCategories.Mobile").trim();
} else {
	INT_CACHE_CATEGORIES_COUNT = EnoviaResourceBundle.getProperty(context, "emxFramework.UI.Cache.NumberOfCategories.Desktop").trim();
} %>
 <script type="text/javascript">
 jQuery(document).ready(function(){
	var openURLIdx = getTopWindow().name.indexOf("||");		
	if(openURLIdx >= 0){	    
		var openURL = getTopWindow().name.substring(openURLIdx+2);
     
  		emxUINavigator.setContent(openURL);
 	}
 });
 //XSSOK
 var isMobile = <%=UINavigatorUtil.isMobile(context)%>;
 var CACHE_CATEGORIES_COUNT = <%=INT_CACHE_CATEGORIES_COUNT%>;
 if(isMobile && CACHE_CATEGORIES_COUNT > 3){
 	CACHE_CATEGORIES_COUNT = 3;
 } else if(CACHE_CATEGORIES_COUNT > 5){
 	CACHE_CATEGORIES_COUNT = 5;
 }
 </script>
</head>
<%
request.setAttribute("callerPage", "popup");
%>

<body class="dialog navigator" onload="initializeSlideIns();expandMenuData();" >


<form name="navigatorForm">
</form>

<div id="ExtpageHeadDiv" class="page-head" style="height:80px;display:none"></div>
<div id="panelToggle" class="panel-toggle open" style="width:16px;display:none"></div>
<div id="leftPanelMenu" class="slide-in-panel menu categories" style="display:none">

	<div id="togglecat" class="toggle" style="display:none;">
		<a href="javascript:showCategoryTree()"><button id="catButton" class="toggle-inactive"><img src="images/iconActionSmallReturnToFacets.png"/></button></a> 
		<a href="javascript:showStructureTree()"><button id="strucButton" class="toggle-active"><img src="images/iconActionSmallReturnToTree.png"/></button></a>
	</div>
	<div id="catMenu" class="menu categories" style="display:none;top:0px;"></div>
	<div id="leftPanelTree" style="display:none;top:16px;"></div>
 </div>
	<div id="mx_divGrabber" style="bottom: 0px; z-index: 200; top: 80px;">
		<div id="mx_divGrabberHead"></div>
		<div id="mx_divGrabberBody" style="top: 126px;"></div>
</div>
 
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
      <input type="hidden" name="portalMode">      
      <input type="hidden" name="frameName">
      <input type="hidden" name="id" />
      <input type="hidden" name="fileAction" />
      <input type="hidden" name="file" /> 
      <input type="hidden" name="versionId" />  
  </form>
</div>
</body>
</html>
