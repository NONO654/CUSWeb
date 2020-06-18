<%--
  DesignVariantContextSearchProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
     String strFormName = emxGetParameter(request,"formName");
     String fieldAct = emxGetParameter(request, "fieldNameActual");
     String fieldDisp = emxGetParameter(request,"fieldNameDisplay");
     String strMode = emxGetParameter(request,"mode");
     String strType = emxGetParameter(request,"type");
     if(strMode==null){
         StringBuffer strURL = new StringBuffer();
         strURL.append("../common/emxFullSearch.jsp?");
         strURL.append("field=TYPES="+strType+"&table=PLCSearchProductLinesTable&HelpMarker=emxhelpfullsearch&showSavedQuery=true&hideHeader=true");        
         strURL.append("&formName="+strFormName);
         strURL.append("&fieldNameActual="+fieldAct);
         strURL.append("&fieldNameDisplay="+fieldDisp);
         strURL.append("&selection=multiple");
         strURL.append("&submitURL=../configuration/DesignVariantContextSearchProcess.jsp?mode=submit");
         strURL.append("&fieldNameActual="+fieldAct);
         strURL.append("&fieldNameDisplay="+fieldDisp);
    %>
    <SCRIPT language="javascript" type="text/javaScript">
    var actCFFiled = getTopWindow().getWindowOpener().document.getElementById("<%=XSSUtil.encodeForJavaScript(context,fieldAct)%>");
    var dispCFFiled = getTopWindow().getWindowOpener().document.getElementById("<%=XSSUtil.encodeForJavaScript(context,fieldDisp)%>");
    getTopWindow().location.href = "<%=XSSUtil.encodeURLwithParsing(context,strURL.toString())%>&delimiter="+dispCFFiled.getAttribute("delimiter");
    </SCRIPT>
    <%
     }else if(strMode.equalsIgnoreCase("submit")){
    	 String strCFObjectId[] = emxGetParameterValues(request, "emxTableRowId");
    	 StringBuffer strVal = new StringBuffer();
    	 for(int i=0; i< strCFObjectId.length;i++){
    		 StringTokenizer strTokenizer = new StringTokenizer(strCFObjectId[i] ,"|");
    		 strCFObjectId[i] = strTokenizer.nextToken();
    	 }
    	 MapList cfData = DomainObject.getInfo(context,strCFObjectId,new StringList(ConfigurationConstants.SELECT_NAME));
    	 for(int i=0; i< cfData.size();i++){
    		 Map dataMap = (Map) cfData.get(i);
             strVal.append((String) dataMap.get(ConfigurationConstants.SELECT_NAME));
             if(i< cfData.size()-1){
            	 strVal.append(",");
             }    		 
         }
    	%>
    	<SCRIPT language="javascript" type="text/javaScript">
    	var actCFFiled = getTopWindow().getWindowOpener().document.getElementById("<%=XSSUtil.encodeForJavaScript(context,fieldAct)%>");
    	var dispCFFiled = getTopWindow().getWindowOpener().document.getElementById("<%=XSSUtil.encodeForJavaScript(context,fieldDisp)%>");
    	dispCFFiled.value = "<%=XSSUtil.encodeForURL(context,strVal.toString())%>";
    	actCFFiled.value = "<%=XSSUtil.encodeForURL(context,strVal.toString())%>";
    	//getTopWindow().location.href = "../common/emxCloseWindow.jsp";
    	getTopWindow().closeWindow();
    	</SCRIPT>
    	<%
     }
     %>
     

