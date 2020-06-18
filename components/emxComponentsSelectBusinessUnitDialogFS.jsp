<%--
  emxComponentsSelectBusinessUnitDialogFS.jsp -  This page is the Frame page to select BusinessUnit

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsSelectBusinessUnitDialogFS.jsp.rca 1.13 Wed Oct 22 16:17:49 2008 przemek Experimental przemek $
  --%>

<%@include file="emxComponentsCommonUtilAppInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@ page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%
	String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
	String fieldNameOID = emxGetParameter(request,"fieldNameOID");
	String formPopUp = emxGetParameter(request,"strFormPopUp");
	
	String objectId = emxGetParameter(request,"objectId");
	
	//	Whether a checkbox or radiobutton is displayed ( true / false )
	String strSelect = emxGetParameter(request,"select");
	String multiSelect = emxGetParameter(request,"multiSelect");
	
	//The URL of process page to which the form must be submitted
	String processURL = emxGetParameter(request,"processURL");
	String isFrom = emxGetParameter(request,"isFrom");
	String relationshipName = emxGetParameter(request,"relationshipName");
	
	String selection = !("true".equalsIgnoreCase(multiSelect) || "multiple".equalsIgnoreCase(strSelect)) ? "single" : "multiple";
	String SUBMIT_URL = "../components/emxComponentsSelectOrganizationProcess.jsp";
	boolean isAddExisting = !UIUtil.isNullOrEmpty(processURL) && !UIUtil.isNullOrEmpty(relationshipName);
	
	StringBuffer buffer = new StringBuffer();
	buffer.append("../common/emxIndentedTable.jsp?");
	buffer.append("objectId=").append(XSSUtil.encodeForURL(context, objectId)).append('&');
	buffer.append("selection=").append(XSSUtil.encodeForURL(context, selection)).append('&');
	buffer.append("isAddExisting=").append(isAddExisting).append('&');
	buffer.append("submitLabel=emxFramework.Common.Done").append('&');
	buffer.append("cancelLabel=emxFramework.Common.Cancel").append('&');
	buffer.append("cancelButton=true").append('&');
	buffer.append("HelpMarker=emxhelpselectorganization").append('&');
	buffer.append("header=emxComponents.Common.SelectBusinessUnit").append('&');
	buffer.append("suiteKey=Components").append('&');
	buffer.append("table=APPOrganizationSummary").append('&');
	buffer.append("program=emxOrganization:getRootObjectForSelectOrganization").append('&');
	buffer.append("expandProgram=emxBusinessUnit:selectionBusinessUnitExpandProgram").append('&');
	buffer.append("sortColumnName=Type,Name").append('&');
	
	if(!UIUtil.isNullOrEmpty(fieldNameDisplay))
	    buffer.append("fieldNameDisplay=").append(XSSUtil.encodeForURL(context, fieldNameDisplay)).append('&');
	
	if(!UIUtil.isNullOrEmpty(fieldNameOID))
	    buffer.append("fieldNameOID=").append(XSSUtil.encodeForURL(context, fieldNameOID)).append('&');
	
	if(!UIUtil.isNullOrEmpty(formPopUp))
	    buffer.append("formPopUp=").append(XSSUtil.encodeForURL(context, formPopUp)).append('&');
	
	if(!UIUtil.isNullOrEmpty(isFrom))
	    buffer.append("isFrom=").append(XSSUtil.encodeForURL(context, isFrom)).append('&');
	
	if(!UIUtil.isNullOrEmpty(relationshipName))
	    buffer.append("relationshipName=").append(XSSUtil.encodeForURL(context, relationshipName)).append('&');
	
	if(!UIUtil.isNullOrEmpty(processURL)) {
	    buffer.append("processURL=").append(XSSUtil.encodeForURL(context, processURL)).append('&');
	    buffer.append("mode=AddExisting").append('&');
	}

	buffer.append("submitURL=").append(XSSUtil.encodeForURL(context, SUBMIT_URL)).append('&');
	
	buffer.append("findMxLink=false").append('&');
	buffer.append("massPromoteDemote=false").append('&');
	buffer.append("customize=false").append('&');
	buffer.append("showRMB=false").append('&');
	buffer.append("showClipboard=false").append('&');
	buffer.append("objectCompare=false");

%>
<script>
	//XSSOK
	document.location.href = "<%=buffer.toString()%>";
</script>
