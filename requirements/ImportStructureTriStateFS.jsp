<%--  adapted from emxNavigatorDialog.jsp
  (c) Dassault Systemes, 1993 - 2018.  All rights reserved.
  1. fix all file path
  2. code at the bottom to load content frame with right URL.
--%>
<!-- 
     @quickreview HAT1 ZUD 20 Jul 2017  IR-512136-3DEXPERIENCER2018x: R419-FUN055837: In "Import from Existing" prefix field should not be mandatory.
 -->

<%
  response.addHeader("Cache-Control", "no-cache");
%>

<%@include file = "../common/emxNavigatorSideDoorInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>

<html>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<head>
<script src="../common/scripts/emxJSValidationUtil.js" type="text/javascript"></script>
<script src="../common/scripts/jquery-latest.js" type="text/javascript"></script>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script src='../common/scripts/emxExtendedPageHeaderFreezePaneValidation.js'></script>

<link rel="stylesheet" type="text/css" href="../common/styles/emxUIExtendedHeader.css">
<link rel="stylesheet" type="text/css" href="../common/styles/emxUINavigator.css">
<link rel="stylesheet" href="../common/styles/emxUIFancyTree.css"/>

<script src="../webapps/AmdLoader/AmdLoader.js" type="text/javascript"></script>
 <script src="../webapps/WebappsUtils/WebappsUtils.js" type="text/javascript"></script>
<script src="../common/scripts/emxClientSideInfo.js" type="text/javascript"></script>
<link rel="shortcut icon" href="../favicon.ico" type="image/x-icon" />
<title><%=sAppName%></title>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script type="text/javascript" language="javascript">
        addStyleSheet("emxUIDefault");
        addStyleSheet("emxUINavigator");
        var clntlang = "<%=XSSUtil.encodeForJavaScript(context,(String)request.getHeader("Accept-Language"))%>";
        if(clntlang)clntlang = clntlang.substr(0,2);
</script>
 <script src="../common/scripts/emxUICoreTree.js" type="text/javascript"></script>
 <script src="../common/scripts/emxUIUtility.js" type="text/javascript"></script>
 <script src="../common/scripts/emxUIPopups.js" type="text/javascript"></script>
 <script src="../common/scripts/emxUIToolbar.js" type="text/javascript"></script>
 <script src="../common/scripts/emxUINavigator.js" type="text/javascript"></script>
 <script src="../common/scripts/emxUIHistoryTree.js" type="text/javascript"></script>
 <script src="../common/scripts/emxUIStructureTree.js" type="text/javascript"></script>
 <script src="../common/scripts/emxUIDetailsTree.js" type="text/javascript"></script>
 <script src="../common/scripts/emxUITreeUtil.js" type="text/javascript"></script>
 <script src="../common/scripts/emxUISearch.js" type="text/javascript"></script>
 <script src="../common/scripts/emxUIMetrics.js" type="text/javascript"></script>
 <script src="../common/scripts/emxUISlideIn.js" type="text/javascript"></script>
  <script src="../common/scripts/emxUICalendar.js" type="text/javascript"></script>
   <script src="../common/scripts/emxUICategoryTab.js" type="text/javascript"></script>
  <script type="text/javascript" src="../common/scripts/jquery-ui.custom.js"></script>
  <script type="text/javascript" src="../webapps/VENENOFrameworkPlugins/plugins/fancytree/latest/jquery.fancytree.js"></script>
 <script type="text/javascript" src="../webapps/VENENOFrameworkPlugins/plugins/fancytree/latest/jquery.fancytree.childcounter.js"></script>
 <script type="text/javascript" src="../webapps/VENENOFrameworkPlugins/plugins/fancytree/latest/jquery.fancytree.filter.js"></script> 
 
 <script src="../common/scripts/emxUIStructureFancyTree.js" type="text/javascript"></script>
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

</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
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
		<a href="javascript:showCategoryTree()"><button id="catButton" class="toggle-inactive"><img src="../common/images/iconActionSmallReturnToFacets.png"/></button></a> 
		<a href="javascript:showStructureTree()"><button id="strucButton" class="toggle-active"><img src="../common/images/iconActionSmallReturnToTree.png"/></button></a>
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
<%
	Map params = new HashMap();
	String options = emxGetParameter(request,"options");
	if(options != null){
		String[] tokens = options.split("[;]");
		for(int i = 0; i < tokens.length; i++){
			String token = tokens[i];
			String[] items = token.split("[:]");
			if(items.length == 2){
				params.put(items[0], items[1]);
			}
		}
	}
	
  	String key = (String)params.get("key"); 
	if(key != null){ 
  		Map otherParams = (Map)session.getAttribute(key);
  		if(otherParams != null){
			params.putAll(otherParams);
	  		String prefix = emxGetParameter(request,"prefix"); 
	  		if(prefix != null){
	  			otherParams.put("prefix", prefix);
	  		}
		}
		
	}

	String objectId = emxGetParameter(request,"emxTableRowId");
    if(objectId != null && objectId.indexOf("|") >= 0)
    {
   	 objectId = objectId.split("[|]")[1];
    }
    //START : LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
    
    String isCopyReqSpec = (emxGetParameter(request,"copyReqSpec")==null)?"false":emxGetParameter(request,"copyReqSpec");
	String url = "../common/emxIndentedTable.jsp?expandProgramMenu=" + params.get("expandProgramMenu") + "&tableMenu=" + params.get("sbTableMenu") + 
						"&freezePane=" + params.get("freezePane") + "&sortColumnName=none";
	url += "&copyReqSpec="+isCopyReqSpec;
	//END : LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
	url += "&selectedTable=" + params.get("selectedTable") + "&selectedProgram=" + params.get("selectedProgram"); 
	url += "&selection=multiple&direction=from"; 
	url += "&editLink=false&showClipboard=false&multiColumnSort=false&objectCompare=false&Export=false&PrinterFriendly=false&customize=false";
	url += "&suiteKey=Requirements"; 
	if(isCopyReqSpec.equalsIgnoreCase("true")){
		url += "&header=emxRequirements.DuplicateReqSpec.Heading.Step2";
	}else{
		url += "&header=emxRequirements.ImportStructure.Heading.Step3";
	}
	url += "&submitLabel=emxFramework.Common.Done&cancelLabel=emxFramework.Common.Cancel";
	url += "&fromImportStructure=true&objectId=" + objectId;
	url += "&helpMarker=emxhelpspecimport3";
	url += "&submitURL=../requirements/ImportStructureProcess.jsp?";
	url += "options=" + emxGetParameter(request,"options");
 %>
<script type="text/javascript">
	$(function(){
	    $('#content').on('load', function(){
	    	if($('#content').attr('src') == 'about:blank'){ //needs to take care of Firefox
		    	 $(this).off('load');
		         $(this).attr('src', "<%= url %>");  
	    	}
	    });
	});	
</script>
</body>
</html>
