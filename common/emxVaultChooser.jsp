<%--  emxVaultChooser.jsp  -  This page is frameset page which has create line item dialog in the conent frame.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxVaultChooser.jsp.rca 1.9 Wed Oct 22 15:48:58 2008 przemek Experimental przemek $"
--%>

<%@ include file="emxCompCommonUtilAppInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil" %>
<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory); 

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String fieldName = emxGetParameter(request,"fieldName");
  String fieldNameActual = emxGetParameter(request,"fieldNameActual");
  String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
  String action = emxGetParameter(request, "action");
  String multiSelect = emxGetParameter(request,"multiSelect");
  String fromSearch = emxGetParameter(request,"isFromSearchForm");
  String objectId = emxGetParameter(request,"objectId");
  String incCollPartners = emxGetParameter(request,"incCollPartners");
  String formName = emxGetParameter(request,"formName");
  String relId = emxGetParameter(request, "relId");
  String callbackFunction = emxGetParameter(request,"callbackFunction");
  String frameName = emxGetParameter(request,"frameName");
 
  //this parameter is used for forwarding from Common Component Vault Chooser
  String fromComComponent = emxGetParameter(request,"fromComComponent");
  
  // this parameter is used to allow vault chooser dialog to be submitted without any  vault selection 
  String allowNoSelection = emxGetParameter(request,"allowNoSelection");
  
  if(multiSelect == null || "null".equalsIgnoreCase(multiSelect) || "".equalsIgnoreCase(multiSelect))
  {
      multiSelect = "true";
  }

  if(fromSearch == null || "null".equalsIgnoreCase(fromSearch) || "".equalsIgnoreCase(fromSearch))
  {
      fromSearch = "false";
  }
  
  if(incCollPartners == null || "null".equalsIgnoreCase(incCollPartners) || "".equalsIgnoreCase(incCollPartners))
  {
        incCollPartners = "false";
  }   
  
  if(fromComComponent == null || "null".equalsIgnoreCase(fromComComponent) || "".equalsIgnoreCase(fromComComponent))
  {
      fromComComponent = "true";
  }  
  
  if(allowNoSelection == null || "null".equalsIgnoreCase(allowNoSelection) || "".equalsIgnoreCase(allowNoSelection))
  {
    allowNoSelection = "false";
  }
  
  String filePathNameStr = "emxVaultChooserDisplay.jsp";
  if(fromComComponent != null && "true".equals(fromComComponent))
  {
      filePathNameStr = "../common/emxVaultChooserDisplay.jsp";
  }  

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(300);
  contentURL.append(filePathNameStr);
 
  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&fieldName=");
  contentURL.append(fieldName);
  contentURL.append("&action=");
  contentURL.append(action);
  contentURL.append("&multiSelect=");
  contentURL.append(multiSelect);
  contentURL.append("&isFromSearchForm=");
  contentURL.append(fromSearch);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&fieldNameDisplay=");
  contentURL.append(fieldNameDisplay);
  contentURL.append("&incCollPartners=");
  contentURL.append(incCollPartners);
  contentURL.append("&fieldNameActual=");
  contentURL.append(fieldNameActual);
  contentURL.append("&formName=");
  contentURL.append(formName);
  contentURL.append("&frameName=");
  contentURL.append(frameName);
  contentURL.append("&callbackFunction=");
  contentURL.append(callbackFunction);
  contentURL.append("&allowNoSelection=");
  contentURL.append(allowNoSelection);

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.Preferences.SelectVaults";
  String HelpMarker = "emxhelpselectvault";
  String strTitle = null;
  strTitle= UINavigatorUtil.getI18nString(PageHeading, "emxFrameworkStringResource",context.getLocale().toString());
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);
  fs.setStringResourceFile("emxFrameworkStringResource");
  //String title = UIUtil.getWindowTitleName(context,relId,objectId,strTitle);
  fs.setPageTitle(context,relId,objectId,strTitle);
  fs.removeDialogWarning();
   

  String i18nDone = "emxFramework.Common.Done";
  String strJScript = "submitFn()";
  fs.createCommonLink(i18nDone,
                      strJScript,
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      4);
  String i18nCancel = "emxFramework.Common.Cancel";
  fs.createCommonLink(i18nCancel,
                      "windowClose()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

   // ----------------- Do Not Edit Below ------------------------------
 fs.writePage(out);

%>






