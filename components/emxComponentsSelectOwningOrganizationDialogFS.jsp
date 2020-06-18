<%--
  emxComponentsSelectOwningOrganizationDialogFS.jsp -

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsSelectOwningOrganizationDialogFS.jsp.rca 1.9.2.1 Fri Nov 28 05:19:33 2008 ds-bbalaji Experimental $
  --%>
<%@include file="emxComponentsCommonUtilAppInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@ page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%
	String fieldNameDisplay = emxGetParameter(request,"fieldName");
	String fieldNameOID = emxGetParameter(request,"fieldId");
	String formPopUp = emxGetParameter(request,"formPopup");
	String selectParent = emxGetParameter(request,"selectParent");
	
	String objectId = emxGetParameter(request,"objectId");
	
	//	Whether a checkbox or radiobutton is displayed ( true / false )
	String strSelect = emxGetParameter(request,"select");
	String multiSelect = emxGetParameter(request,"multiSelect");
	
	String selection = !("true".equalsIgnoreCase(multiSelect) || "multiple".equalsIgnoreCase(strSelect)) ? "single" : "multiple";
	String SUBMIT_URL = "../components/emxComponentsSelectOrganizationProcess.jsp";
	
	StringBuffer buffer = new StringBuffer();
	buffer.append("../common/emxIndentedTable.jsp?");
	buffer.append("objectId=").append(XSSUtil.encodeForURL(context, objectId)).append('&');
	buffer.append("selection=").append(XSSUtil.encodeForURL(context, selection)).append('&');
	buffer.append("submitLabel=emxFramework.Common.Done").append('&');
	buffer.append("cancelLabel=emxFramework.Common.Cancel").append('&');
	buffer.append("cancelButton=true").append('&');
	buffer.append("HelpMarker=emxhelpselectorganization").append('&');
	buffer.append("header=emxComponents.Common.SelectOwningOrganization").append('&');
	buffer.append("suiteKey=Components").append('&');
	buffer.append("table=APPOrganizationSummary").append('&');
	buffer.append("program=emxOrganization:getRootObjectForSelectOrganization").append('&');
	buffer.append("expandProgram=emxOrganization:selectionOwningOrganizationExpandProgram").append('&');
	buffer.append("sortColumnName=Type,Name").append('&');
	
	if(!UIUtil.isNullOrEmpty(fieldNameDisplay))
	    buffer.append("fieldNameDisplay=").append(XSSUtil.encodeForURL(context, fieldNameDisplay)).append('&');
	
	if(!UIUtil.isNullOrEmpty(fieldNameOID))
	    buffer.append("fieldNameOID=").append(XSSUtil.encodeForURL(context, fieldNameOID)).append('&');
	
	if(!UIUtil.isNullOrEmpty(formPopUp))
	    buffer.append("formPopUp=").append(XSSUtil.encodeForURL(context, formPopUp)).append('&');
	
	if(!UIUtil.isNullOrEmpty(selectParent))
	    buffer.append("canSelectRootCompany=").append(XSSUtil.encodeForURL(context, selectParent)).append('&');
	
	
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
