<%--
  emxComponentsSelectOrganizationProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
  --%>

  <%@include file="emxComponentsCommonUtilAppInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@ page import="com.matrixone.apps.framework.ui.UIUtil,
				 com.matrixone.apps.common.util.ComponentsUIUtil,
				 com.matrixone.apps.domain.util.MapList,
				 com.matrixone.apps.domain.DomainObject,
				 matrix.util.StringList,
				 com.matrixone.apps.domain.DomainConstants,
				 java.util.Map" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<html>
<body>
</body>		 
<%
	String[] newId = ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
	String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
	String fieldNameOID = emxGetParameter(request,"fieldNameOID");
	String formPopUp = emxGetParameter(request,"formPopUp");
	String objectId = emxGetParameter(request,"objectId");
	String processURL = emxGetParameter(request,"processURL");

	//setup the Done link based on parameters passed
	String fieldDisplayStr = null;
	String fieldIdStr = null;

	boolean showWarning = false;
	boolean hasProcessURL = !UIUtil.isNullOrEmpty(processURL);
	
	if(newId == null || newId.length == 0) {
	    showWarning = true;
	} else {
		if(hasProcessURL) {
		    StringBuffer buffer = new StringBuffer(200);
		    buffer.append(processURL);
		    buffer.append(processURL.indexOf('?') == -1 ? '?' : '&');

		    buffer.append("objectId=").append(XSSUtil.encodeForURL(context, objectId)).append('&');

		    if(!UIUtil.isNullOrEmpty(fieldNameDisplay))
			    buffer.append("fieldNameDisplay=").append(XSSUtil.encodeForURL(context, fieldNameDisplay)).append('&');

		    if(!UIUtil.isNullOrEmpty(fieldNameOID))
			    buffer.append("fieldNameOID=").append(XSSUtil.encodeForURL(context, fieldNameOID)).append('&');

		    String mode = emxGetParameter(request,"mode");
		    if(!UIUtil.isNullOrEmpty(mode))
			    buffer.append("mode=").append(XSSUtil.encodeForURL(context, mode)).append('&');
		    
		    buffer.append("newId=").append(ComponentsUIUtil.arrayToString(newId, "&newId="));
		    processURL = buffer.toString();
		} else {
		    String[] namesArr = new String[newId.length];
		    MapList fieldNameMap = DomainObject.getInfo(context, newId, new StringList(DomainConstants.SELECT_NAME));
		    for(int i = 0; i < newId.length; i++) {
		        Map objInfo = (Map)fieldNameMap.get(i);
		        namesArr[i] = (String)objInfo.get(DomainConstants.SELECT_NAME);
		    }

		    fieldIdStr = ComponentsUIUtil.arrayToString(newId, ";");
		    fieldDisplayStr = ComponentsUIUtil.arrayToString(namesArr, ";");
	  	}	
	}
%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script>
//XSSOK
	<framework:ifExpr expr="<%=showWarning%>">
	    alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.PleaseSelectAnItem</emxUtil:i18nScript>");
    </framework:ifExpr>
//XSSOK
	<framework:ifExpr expr="<%=!showWarning%>"><framework:ifExpr expr="<%=hasProcessURL%>">submitWithCSRF("<%=XSSUtil.encodeForJavaScript(context,processURL)%>", window);</framework:ifExpr><framework:ifExpr expr="<%=!hasProcessURL%>">doSubmitFromPop();</framework:ifExpr></framework:ifExpr>
    
	function doSubmitFromPop() {
	  
	  var fieldNameDisplay = "<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>";
	  var fieldNameOID = "<%=XSSUtil.encodeForJavaScript(context, fieldNameOID)%>";
	  var newSelName = "<%=XSSUtil.encodeForJavaScript(context, fieldDisplayStr)%>";
	  var newSelId = "<%=XSSUtil.encodeForJavaScript(context, fieldIdStr)%>";
	  
	  var vfieldNameDisplay = null;
	  var vfieldNameOID = null;

	  var targetWindow = getTopWindow().getWindowOpener();
	  var formObj = getTopWindow().getWindowOpener().document.forms["emxCreateForm"];
	  formObj = formObj == null ? getTopWindow().getWindowOpener().document.forms["editDataForm"] : formObj;
	  formObj = formObj == null ? getTopWindow().getWindowOpener().document.forms[0] : formObj;
	  
	  eval("vfieldNameDisplay = formObj." + fieldNameDisplay);
	  eval("vfieldNameOID = formObj." + fieldNameOID);
	  
      vfieldNameDisplay = vfieldNameDisplay == null ? formObj[fieldNameDisplay] : vfieldNameDisplay;
	  vfieldNameOID = vfieldNameOID == null ? formObj[fieldNameOID] : vfieldNameOID;
	  
	  vfieldNameDisplay = vfieldNameDisplay == null ? targetWindow.document.getElementsByName(fieldNameDisplay)[0] : vfieldNameDisplay;
	  vfieldNameOID = vfieldNameOID == null ? targetWindow.document.getElementsByName(vfieldNameOID)[0] : vfieldNameOID;
	  
  	  vfieldNameDisplay.value = newSelName;
	  vfieldNameOID.value = newSelId;

      getTopWindow().closeWindow();
    }
    
</script>
</html>	
