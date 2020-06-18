<%-- ProductFeatureDBChooser.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/configuration/ProductConfigurationUtil.jsp 1.70.2.7.1.2.1.1 Wed Dec 17 12:39:33 2008 GMT ds-dpathak Experimental$: ProductConfigurationUtil.jsp";
--%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import = "com.matrixone.apps.configuration.*"%>

<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../emxUIPageUtility.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT>

<%
String parentLFId = emxGetParameter(request, "parentFeatureId");
String relLFId = emxGetParameter(request, "parentFeatureListId");
String pflId = emxGetParameter(request, "parentPFLid");
String contextId = emxGetParameter(request, "contextBusId");
String level = emxGetParameter(request, "featureRowDispayLevel");
String strTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
String selection = emxGetParameter(request, "selection");
HashMap paramMap = new HashMap();
paramMap.put("emxTableRowId",strTableRowId);
paramMap.put("parentFeatureId",parentLFId);
paramMap.put("relId",relLFId);
paramMap.put("contextBusId",contextId);
paramMap.put("level",level);
String strHTML = LogicalFeature.getHTMLForDBSelections(context,paramMap);
%>
 <script language="javascript" type="text/javaScript">
 var tBody = getTopWindow().getWindowOpener().document.getElementById("featureOptionsBody");
 var parentInput = getTopWindow().getWindowOpener().document.getElementById("DIV<%=XSSUtil.encodeForJavaScript(context,pflId)%>");
 var parentRowId = "Rowid<%=XSSUtil.encodeForJavaScript(context,parentLFId)%>";
 if(tBody)
 {	 var index = 0;
	 for(var i=0; i<tBody.rows.length; i++) {
         var rows = tBody.rows[i];
         var rowId = rows.getAttribute("id");
         var rowParentId = rows.getAttribute("parentLFId");
         if(parentRowId == rowId){
        	 index = i;
         }
         if("<%=XSSUtil.encodeForJavaScript(context,selection)%>" == "single" && rowParentId != null && rowParentId == "<%=XSSUtil.encodeForJavaScript(context,parentLFId)%>"){
        	 var selId = rowId.replace("Rowid", "");
        	 var selffeature = getTopWindow().getWindowOpener().document.getElementById(selId);           
        	 getTopWindow().getWindowOpener().document.getElementById('hconnectedrels').value =getTopWindow().getWindowOpener().document.getElementById('hconnectedrels').value+","+selffeature.getAttribute("relid") ;
        	 getTopWindow().getWindowOpener().document.getElementById('hPFLIds').value =getTopWindow().getWindowOpener().document.getElementById('hPFLIds').value+","+selffeature.getAttribute("pflid");
        	 tBody.deleteRow(i);
         }
	 }
	 var newDiv = getTopWindow().getWindowOpener().document.createElement("div");
	 //XSSOK
	 newDiv.innerHTML = "<table><tbody><%=strHTML %></tbody></table>";
     var newRow = newDiv.firstChild.firstChild;
	 for(var i=0; i < newRow.childNodes.length; i++) {
		 var parentRow = tBody.rows[index];
         insertAfter(newRow.childNodes[i], parentRow);
         i--;
         index = index+1;
	 }	 
	 parentInput.childNodes[0].checked =true;
 }
   //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
   getTopWindow().closeWindow();
 </script>
  <%
  %>
