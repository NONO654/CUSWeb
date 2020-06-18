<%--  emxCommonDocumentDetailsFS.jsp   - FS Detail page for Common Documents.
   **** Re-Directing to emxForm.jsp so that the webform will be displayed instead of the jsp page.
   Copyright (c) 2003-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDocumentDetailsFS.jsp.rca 1.8 Wed Oct 22 16:18:21 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%
String webFormName = emxGetParameter(request,"form");
webFormName = (webFormName == null) ? "type_DOCUMENTS" : webFormName;
String formHeader = emxGetParameter(request,"formHeader");
formHeader = (formHeader == null) ? "emxComponents.Common.PropertiesPageHeading" : formHeader;
String subHeader = emxGetParameter(request,"subHeader");
subHeader = (subHeader == null) ? "emxComponents.Menu.SubHeaderDocuments" : subHeader;
String helpMarker = emxGetParameter(request,"HelpMarker");
helpMarker = (helpMarker == null) ? "emxhelpdocumentproperties" : helpMarker;
  String objectId         = emxGetParameter(request,"objectId");
String toolbarName = emxGetParameter(request,"toolbar");
toolbarName = toolbarName == null ? "APPDocumentToolBar" :toolbarName;

StringBuffer contentURL = new StringBuffer();

contentURL.append("../common/emxForm.jsp?form=");
contentURL.append(XSSUtil.encodeForURL(context, webFormName));
contentURL.append("&toolbar=");
contentURL.append(XSSUtil.encodeForURL(context,toolbarName));
contentURL.append("&formHeader=");
contentURL.append(XSSUtil.encodeForURL(context,formHeader));
contentURL.append("&subHeader=");
contentURL.append(XSSUtil.encodeForURL(context,subHeader));
contentURL.append("&objectId=");
contentURL.append(XSSUtil.encodeForURL(context,objectId));
contentURL.append("&HelpMarker=");
contentURL.append(XSSUtil.encodeForURL(context,helpMarker));
contentURL.append("&targetLocation=");
contentURL.append(XSSUtil.encodeForURL(context, emxGetParameter(request,"targetLocation")));
contentURL.append("&suiteKey=");
contentURL.append(XSSUtil.encodeForURL(context,emxGetParameter(request,"suiteKey")));
contentURL.append("&StringResourceFileId=");
contentURL.append(XSSUtil.encodeForURL(context,emxGetParameter(request,"StringResourceFileId")));
contentURL.append("&SuiteDirectory=");
contentURL.append(XSSUtil.encodeForURL(context,emxGetParameter(request,"SuiteDirectory")));
contentURL.append("&Export=False");
contentURL.append("&displayCDMFileSummary=true");
%>

<script>
	//XSSOK
    document.location.href='<%=contentURL.toString()%>';
</script>
