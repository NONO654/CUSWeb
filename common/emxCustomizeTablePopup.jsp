<%--  emxCustomizedTablePopup.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
  static const char RCSID[] = $Id: emxCustomizeTablePopup.jsp.rca 1.15.3.3 Tue Oct 28 22:59:39 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<html>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorTimerTop.inc"%>
<head>
<title><emxUtil:i18n localize="i18nId">emxFramework.Common.Heading</emxUtil:i18n></title>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />
<%
  	String strToolbar =  "ResetToDefaults";
  	String strHelpMarker = "emxhelptablecreate";
	String strTimeStamp = emxGetParameter(request,"timeStamp");
    String strUIType = emxGetParameter(request,"uiType");
    String strObjectId = emxGetParameter(request,"objectId");
    String strMultiColumnSort = "";
	String strMode = emxGetParameter(request,"mode");
	String strSortColumnName = "";
	String strSortColumnDirection = "";
	int iFreezePane = 0;
	HashMap hmpRequest = null;
	HashMap hmpTableData = null;
	String strCustomTable = "";
	String strCurrentTable ="";
	if(strMode==null)
	    strMode="New";

	if("table".equalsIgnoreCase(strUIType) && (!"".equalsIgnoreCase(strUIType)) && (strUIType!=null))
	{
		hmpTableData = tableBean.getTableData(strTimeStamp);
		hmpRequest   = tableBean.getRequestMap(hmpTableData);
		strCurrentTable     = (String)hmpRequest.get("table");
	}

	else
	{
		if("structureBrowser".equalsIgnoreCase(strUIType) && (!"".equalsIgnoreCase(strUIType)) && (strUIType!=null))
		{
			hmpTableData = indentedTableBean.getTableData(strTimeStamp);
			hmpRequest   = indentedTableBean.getRequestMap(hmpTableData);
			strCurrentTable     = (String)hmpRequest.get("selectedTable");
			iFreezePane  = Integer.parseInt(hmpRequest.get("split").toString());
		}
	}

	String suiteKey = (String)hmpRequest.get("suiteKey");
	strMultiColumnSort = (String)hmpRequest.get("multiColumnSort");
	if(!("false".equalsIgnoreCase(strMultiColumnSort)))
	{
		if("new".equalsIgnoreCase(strMode))
		{
		    strSortColumnName 	   = (String)hmpRequest.get("sortColumnName");
		    strSortColumnDirection = (String)hmpRequest.get("sortDirection");
		}
		else
		{
		    strSortColumnName      = (String)hmpRequest.get("customSortColumns");
		    strSortColumnDirection = (String)hmpRequest.get("customSortDirections");
		}
	}
	if("edit".equalsIgnoreCase(strMode) && strMode!=null)
	{
	    try
	    {
	        strCustomTable = strCurrentTable.substring(0,strCurrentTable.lastIndexOf("~"));
	    }
	    catch(Exception e)
	    {

	    }
	}
	String strPageHeading =(String)hmpRequest.get("header");
	String strLanguage = request.getHeader("Accept-Language");
	String strSubPageHeading="";
	if(UIUtil.isNotNullAndNotEmpty(strObjectId)){
		strSubPageHeading = UINavigatorUtil.parseHeader(context, pageContext,strPageHeading, strObjectId, suiteKey, strLanguage);
	}
	else if(UIUtil.isNotNullAndNotEmpty(strPageHeading)){
		HashMap controlRequestMap   = indentedTableBean.getControlMap(hmpTableData);
		strSubPageHeading     = (String)controlRequestMap.get("PageHeader");		
	}
	if(strSubPageHeading == null){
	    strSubPageHeading = "";
	}

	String strRegName = com.matrixone.apps.domain.util.FrameworkUtil.getAliasForAdmin(context,"Menu", strToolbar,true);
	String strHelpDone = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.Done", new Locale(strLanguage));
	String strHelpCancel = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.Cancel", new Locale(strLanguage));
	String strProgressImage = "images/utilProgressBlue.gif";
	String strProcessingText = UINavigatorUtil.getProcessingText(context, strLanguage);

%>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxNavigatorHelp.js"></script>



<script language="JavaScript" type="text/JavaScript">
	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIToolbar");
	addStyleSheet("emxUIMenu");
	addStyleSheet("emxUIDOMLayout");
	addStyleSheet("emxUIDialog");

</script>
<script language="JavaScript">
		function resetToDefault()
		{
			var iframeObj = document.getElementById('customTable');
			iframeObj.src = iframeObj.src;
		}
</script>

<script language="Javascript">
	var submitInProgress = false;

    function onSubmit() {
		if(submitInProgress) {
    		return false;
    	} else {
    		submitInProgress = true;
    		hiddenSubmit();
    		return true;
    	}
	}
	
    function hiddenSubmit() {
		var uiType = parent.frames.customTable.document.forms.customtable.uiType.value;
    	parent.frames.customTable.validateNameField(uiType);
    }
    
    function adjustBody(){
    	var phd = document.getElementById("pageHeadDiv");
    	var dpb = document.getElementById("divPageBody");
    	if(phd && dpb){
    		var ht = phd.clientHeight;
    		if(ht <= 0){
    			ht = phd.offsetHeight;
    		}
    		dpb.style.top = ht + "px";
    	}
    }
</script>


<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</head>

<body  onload="adjustBody();turnOffProgress()" >
<div id="pageHeadDiv" >
<form name="customTableForm">
   <table>
	<tr>
    <td class="page-title">
      <h2><emxUtil:i18nScript localize="i18nId">emxFramework.Common.Heading</emxUtil:i18nScript></h2>
<%
      if(strSubPageHeading != null && !"".equals(strSubPageHeading)) {
%>
        <h3><xss:encodeForHTML><%=strSubPageHeading%></xss:encodeForHTML></h3>
<%
        }
%>
	</td>
<%
       String processingText = UINavigatorUtil.getProcessingText(context, langStr);
%>
        <td class="functions">
            <table>
<tr>
                <!-- //XSSOK -->
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
</tr>
</table>
        </td>
        </tr>
        </table>
<!-- //XSSOK -->
<jsp:include page="emxToolbar.jsp" flush="true"> <jsp:param name="toolbar" value="<%=strToolbar%>"/> <jsp:param name="helpMarker" value="<%=strHelpMarker%>" />
	<jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, strObjectId)%>" />
	<jsp:param name="relId" value="" />
	<jsp:param name="parentOID" value="" />
	<jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, strTimeStamp)%>" />
    <jsp:param name="uiType" value="null"/>
	<jsp:param name="header" value="" />
	<jsp:param name="suiteDir" value="" />
	<jsp:param name="portalMode" value="" />
    <jsp:param name="PrinterFriendly" value="false"/>
    <jsp:param name="expandLevelFilter" value="false"/>
    <jsp:param name="export" value="false"/>
    <jsp:param name="editLink" value="false"/>
    <jsp:param name="customize" value="false"/>
    <jsp:param name="multiColumnSort" value="false"/>
    <jsp:param name="massPromoteDemote" value="false"/>
    <jsp:param name="showClipboard" value="false"/>
    <jsp:param name="triggerValidation" value="false"/>

</jsp:include>
</form>
</div>
<%
StringBuffer strbuffParams = new StringBuffer(64);
strbuffParams.append("timeStamp=");
strbuffParams.append(XSSUtil.encodeForURL(context, strTimeStamp));
strbuffParams.append("&uiType=");
strbuffParams.append(XSSUtil.encodeForURL(context, strUIType));
strbuffParams.append("&table=");
strbuffParams.append(XSSUtil.encodeForURL(context, strCurrentTable));
strbuffParams.append("&objectId=");
strbuffParams.append(XSSUtil.encodeForURL(context, strObjectId));
strbuffParams.append("&customTable=");
strbuffParams.append(XSSUtil.encodeForURL(context, strCustomTable));
strbuffParams.append("&sortColumnName=");
strbuffParams.append(XSSUtil.encodeForURL(context, strSortColumnName));
strbuffParams.append("&sortDirection=");
strbuffParams.append(XSSUtil.encodeForURL(context, strSortColumnDirection));
strbuffParams.append("&multiColumnSort=");
strbuffParams.append(XSSUtil.encodeForURL(context, strMultiColumnSort));
strbuffParams.append("&split=");
strbuffParams.append(iFreezePane);
strbuffParams.append("&mode=");
strbuffParams.append(XSSUtil.encodeForURL(context, strMode));
%>
  <!-- //XSSOK -->
  <div id="divPageBody" ><iframe name="customTable" id="customTable" src="emxCustomizedTable.jsp?<%=strbuffParams.toString()%>" width="100%" height="100%"  frameborder="0" border="0"></iframe>
  		<iframe class="hidden-frame" name="customTableHidden" HEIGHT="0" WIDTH="0"></iframe>
  </div>
<div id="divPageFoot">
<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
<tr>
<td class="buttons" align="right">
<table border="0" cellspacing="0">
<tr>
<!-- //XSSOK -->
<td><a class="footericon" href="javascript:;" onClick="onSubmit()"><img src="images/buttonDialogDone.gif" border="0" alt="<%=strHelpDone%>" /></a></td>
<!-- //XSSOK -->
<td><a onClick="return onSubmit();" class="button"><button class="btn-primary" type="button"><%=strHelpDone%></button></a></td>
<!-- //XSSOK -->
<td><a class="footericon" href="javascript:getTopWindow().closeWindow()"><img src="images/buttonDialogCancel.gif" border="0" alt="<%=strHelpCancel%>" /></a></td>
<!-- //XSSOK -->
<td><a onClick="javascript:getTopWindow().closeWindow()" class="button"><button class="btn-default" type="button"><%=strHelpCancel%></button></a></td>
</tr>
</table>
</td>
</tr>
</table>
</div>
</body>
</html>
