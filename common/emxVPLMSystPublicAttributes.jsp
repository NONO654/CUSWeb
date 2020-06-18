<%--  emxVPLMSystPublicAttributes.jsp   -   page for Public attributes of VPLMEntities
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxVPLMLogon.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $
--%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.HashMap"%>
<%@ page import = "java.util.Set" %>
<%@ page import = "matrix.db.*" %>

<%@ page import = "com.matrixone.apps.common.Person" %>
<%@ page import = "com.matrixone.apps.domain.util.MapList" %>


<%@include file="../emxUIFramesetUtil.inc"%>

<%
    
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  
  // ----------------- Do Not Edit Above ------------------------------

 
  String objectId = emxGetParameter(request,"objectId");

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(100);
  contentURL.append("emxVPLMSystPublicAttributesSummary.jsp");
  
  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?objectId=");
  contentURL.append(objectId);
  HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
  Iterator keyItr = requestMap.keySet().iterator();
  while (keyItr.hasNext()) {
		String key = (String) keyItr.next();
		contentURL.append("&");
		contentURL.append(key);
		contentURL.append("=");
		contentURL.append(requestMap.get(key)); 
  }

  // Page Heading - Internationalized
  String PageHeading = "emxVPLMSystemEditor.Header.Properties";
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelptriggerparameterproperties";
  
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,false,false,false);
  fs.setStringResourceFile("emxVPLMSystemEditorStringResource");

  String tableRowId = emxGetParameter(request,"emxTableRowId");

  // pb to get role from the context in emxVPLMPublicAttributesSummary due to setObjectId ...
  // ----------------------------------------------------------------------------------------
  if ( null == tableRowId)
  fs.setObjectId(objectId);
  else
	  fs.setObjectId(tableRowId);

  //for next gen ui
  fs.setCategoryTree(emxGetParameter(request,"categoryTreeName"));
  fs.setOtherParams(UINavigatorUtil.getRequestParameterMap(request)); //maybe not necessary...

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);

%>



