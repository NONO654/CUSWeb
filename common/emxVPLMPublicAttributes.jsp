<%--  emxVPLMPublicAttributes.jsp   -   page for Public attributes of VPLMEntities
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxVPLMLogon.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $
   
   Wk45 2010 - RCI - RI 76513 - PageHeading to PLM_ExternalID Rev Properties instead of ${NAME} Rev ${REVISION}
   Wk50 2010 - RCI - RI 81835 - NextGenUI and Menu access thru Categories
   Wk10 2011 - RCI - RI 100857 - Manage case of emxTableRowId with relId | objId
--%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.HashMap"%>
<%@ page import = "java.util.Set" %>
<%@ page import = "matrix.db.*" %>
<%@include file = "../emxUIFramesetUtil.inc"%>


<%
    framesetObject fs = new framesetObject();
    // ----------------- Do Not Edit Above ------------------------------

 
    String objectId = emxGetParameter(request,"objectId");

  // Specify URL to come in middle of frameset
  // -----------------------------------------
  StringBuffer contentURL = new StringBuffer(100);
  contentURL.append("emxVPLMPublicAttributesSummary.jsp");
  //contentURL.append("emxDynamicAttributesSummary.jsp");
  
	
  // add these parameters to each content URL, and any others the App needs
  // ----------------------------------------------------------------------
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
  // --------------------------------
  //String PageHeading = "emxFramework.Common.PropertiesPageHeading";
  String PageHeading ="Properties";  // if dynamic naming needed, get PLM_ExternalId
    // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelptriggerparameterproperties";
  
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,false,false,false);
  //fs.setStringResourceFile("emxProductEditorStringResource");
  fs.setStringResourceFile("emxFrameworkStringResource");
  String tableRowId = emxGetParameter(request,"emxTableRowId");


  // RI 100857
  String rmbObj = tableRowId ;
	
  if ( null != tableRowId )
  {
    int indexRmb = tableRowId .lastIndexOf("|");
    if ( -1 != indexRmb)
	rmbObj = tableRowId .substring(indexRmb + 1);
    else
	rmbObj = tableRowId ;
  }
	


 // pb to get role from the context in emxVPLMPublicAttributesSummary due to setObjectId ...
 // ----------------------------------------------------------------------------------------
  if ( null == rmbObj )
  fs.setObjectId(objectId);
  else
	  fs.setObjectId(rmbObj);

  fs.setCategoryTree(emxGetParameter(request,"categoryTreeName"));
  fs.setOtherParams(UINavigatorUtil.getRequestParameterMap(request));


  // ----------------- Do Not Edit Below ------------------------------
 fs.writePage(out);

%>



