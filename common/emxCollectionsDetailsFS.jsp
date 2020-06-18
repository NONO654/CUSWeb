<%--  emxCollectionsDetailsFS.jsp   - FS Detail page for Collections.
   Copyright (c) 2005-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsDetailsFS.jsp.rca 1.18 Wed Oct 22 15:48:50 2008 przemek Experimental przemek $
--%>
<%@page import="com.matrixone.apps.domain.util.SetUtil"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
   
<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.setSubmitMethod(request.getMethod());

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String sCharSet               = Framework.getCharacterEncoding(request);
  String jsTreeID               = emxGetParameter(request,"jsTreeID");
  String suiteKey               = emxGetParameter(request,"suiteKey");
  String strSetId               = emxGetParameter(request, "relId");
  String categoryTreeName       = emxGetParameter(request, "categoryTreeName");
  String treeLabel              = emxGetParameter(request, "treeLabel");
  String objectName             = SetUtil.getCollectionName(context, strSetId);
  String objectNameLabel        = objectName;
  String strSysCollectionName   = EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");
  String language               = request.getHeader("Accept-Language");
  
  if(objectName.equalsIgnoreCase(strSysCollectionName)) {
      objectNameLabel   = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", 
                            new Locale(language), "emxFramework.ClipBoardCollection.NameLabel");
  }
  
  String tmpHeading             = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.CollectionsPropertiesPageHeading", new Locale(language));  
  String objectNameForHeading   = objectNameLabel;
  String PageHeading            = objectNameForHeading + tmpHeading;

  PageHeading = XSSUtil.encodeForURL(context, PageHeading);
  StringBuffer contentURL = new StringBuffer("emxCollectionsDetails.jsp");
  //Added for BUG : 346390  
  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectName=");
  contentURL.append(XSSUtil.encodeForURL(context, objectName));
  contentURL.append("&relId=");
  contentURL.append(strSetId);

  String finalURL       = contentURL.toString();
  String sHeaderLink    = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Command.EditDetails", new Locale(language));  // Marker to pass into Help Pages
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker     = "emxhelpcollectionproperties";

  fs.useCache(false);
  fs.setOtherParams(UINavigatorUtil.getRequestParameterMap(request));
  fs.setCategoryTree(categoryTreeName);
  fs.setTreeLabel(treeLabel);
  fs.setRelId(strSetId);
  fs.initFrameset(PageHeading,HelpMarker,finalURL,true,false,false,false);
  fs.setStringResourceFile("emxFrameworkStringResource");

  /* if the collection is System Generated Collection then editDetails toolbar should not be displayed*/
  if(!objectName.equals(strSysCollectionName))
  {
      fs.setToolbar("AEFCollectionsPropertiesToolBar");
  }
  fs.writePage(out);

%>
