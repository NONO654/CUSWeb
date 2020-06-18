<%--  emxParameterDialog.jsp
  (c) Dassault Systemes, 1993 - 2012.  All rights reserved.
--%>
<%
  response.addHeader("Cache-Control", "no-cache");
%>

<%@include file = "../common/emxNavigatorInclude.inc"%>

<html>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<head>
<script src="../common/scripts/jquery-latest.js" type="text/javascript"></script>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script src="../common/scripts/emxClientSideInfo.js" type="text/javascript"></script>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<link rel="shortcut icon" href="../favicon.ico" type="image/x-icon" />
<title><%=sAppName%></title>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script type="text/javascript" language="javascript">
        addStyleSheet("emxUIDefault");
        addStyleSheet("emxUINavigator");
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
 

<script type="text/javascript">
<%
if(false){
%>
    var objDetailsTree = new emxUIDetailsTree;
    var objStructureTree = new emxUIStructureTree;
<%
} else {
%>
  var objDetailsTree = new emxUIDetailsTree;
  var objStructureTree = new emxUIStructureTree;

  function initStructureTree(){
      objStructureTree = new emxUIStructureTree;
      objDetailsTree = objStructureTree;
      return objStructureTree ;
  }

  function initLegacyStructureTree(){
      objStructureTree = new emxUIStructureTree;
      objDetailsTree = new emxUIDetailsTree;
      return objStructureTree ;
  }
  
<%
}
// OB4: IR-330360-3DEXPERIENCER2016 - removed PopupLauncher.jsp/TimeZoneSetup.jsp
// added below code to redirect to emxTable.jsp and add emxTableRowId parameter
%>
var href = location.href;
href = href.replace("parameter/emxParameterDialog.jsp", "common/emxTable.jsp");
href += "<xss:encodeForJavaScript><%=emxGetParameter(request, "emxTableRowId") == null ? "" : "&emxTableRowId=" + emxGetParameter(request, "emxTableRowId")%></xss:encodeForJavaScript>";

emxUINavigator.setContent(href);
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

 <script type="text/javascript">
 var pctoppos = "0px";
 var isMobile = <%=UINavigatorUtil.isMobile(context)%>;
 function initializeSlideIns(){
	 var pcdtop = "0px";
		var bc = document.getElementById("breadcrumbs");
		var bcheight = bc.offsetHeight;
		if(bcheight <= 0){
			bcheight = bc.clientHeight;
		}

		pcdtop = bcheight + "px";

<%
	String legacyTree = (String)request.getParameter("legacyTree");
     if("true".equalsIgnoreCase(legacyTree)){
%>
      pcdtop = "0px";
<%
     }
%>
    document.getElementById("pageContentDiv").style.top = pcdtop;
    if(document.getElementById("panelSlideIn")) {
    document.getElementById("panelSlideIn").style.top = pcdtop;
     document.getElementById("panelSlideIn").style.display = "none";
    }
    pctoppos = pcdtop;
 }
 </script>
 <style>
    /* the following styles are inline in this HTML example, but should be moved to JS functions for the release app */
    div.mmenu {
        top: 35px;
        left: 20px;
    }

    div.breadcrumbs ul {
        right:15px;
    }

 </style>
</head>
<%
request.setAttribute("callerPage", "popup");
%>

<body class="dialog navigator" onload="initializeSlideIns()" >
<form name="navigatorForm">
<%
if(false){
%>
    <div id="pageHeadDiv">
        <div class="toolbar-container">
            <div class="toolbar-frame">
                <div class="toolbar group-left">
                  <table style="margin-left:25px;">
                      <tr>
                          <td><img src="../common/images/iconMedEnovia.png"/></td>
                          <td class="compass-placeholder"><span></span></td>
                      </tr>
                  </table>
                </div>
            </div>
        </div>
      </div>
<%
}
%>
<%@include file = "../common/emxNavigatorLayout.inc"%>
</form>
 <!--
 This div and Form are added to remove the checkout empty dilaog
 Do not remove this as AEF is not using this form or div.
 -->
 <div id="checkoutdiv">
  <form name="commonDocumentCheckout" id="commonDocumentCheckout" method="post" action="../components/emxCommonDocumentPreCheckout.jsp">
      <input type="hidden" name="objectId">
      <input type="hidden" name="action">
      <input type="hidden" name="format">
      <input type="hidden" name="fileName">
      <input type="hidden" name="appName">
      <input type="hidden" name="appDir">
      <input type="hidden" name="closeWindow">
      <input type="hidden" name="refresh">
      <input type="hidden" name="trackUsagePartId">
      <input type="hidden" name="version">
      <input type="hidden" name="customSortColumns">
      <input type="hidden" name="customSortDirections">
      <input type="hidden" name="uiType">
      <input type="hidden" name="table">
      <input type="hidden" name="getCheckoutMapFromSession">
      <input type="hidden" name="fromDataSessionKey">
      <input type="hidden" name="parentOID">
      <input type="hidden" name="appProcessPage">
 
  </form>
</div>
</body>
</html>


