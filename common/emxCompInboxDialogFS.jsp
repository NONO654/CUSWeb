<%-- emxCompInboxDialogFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCompInboxDialogFS.jsp.rca 1.17 Wed Oct 22 15:47:45 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@ include file  = "emxCompCommonUtilAppInclude.inc" %>
<%@ page import="com.matrixone.apps.framework.ui.*" %>

<%@include file = "emxUIConstantsInclude.inc"%>
<jsp:useBean id = "emxCompInboxDialogFS" class = "com.matrixone.apps.framework.ui.UITable" scope = "session" />
<script language="javascript" type="text/javascript" src="scripts/emxUIModal.js"></script>

<%
  framesetObject fs     = new framesetObject();
  String Directory      = appDirectory;
  fs.setDirectory(Directory);
  fs.setSubmitMethod(request.getMethod());
  String tableBeanName  = "emxCompInboxDialogFS";

  String initSource     = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID                   = emxGetParameter(request,"jsTreeID");
  String suiteKey                   = emxGetParameter(request,"suiteKey");
  String showPaginationMinimized    = emxGetParameter(request,"showPaginationMinimized");
  suiteKey                          = "eServiceFramework";

  // ----------------- Do Not Edit Above ------------------------------

  // Add Parameters Below
  String param = emxGetParameter(request,"param");

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(100);

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("emxCompInboxDialog.jsp");
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&beanName=");
  contentURL.append(tableBeanName);
  contentURL.append("&showPaginationMinimized=");
  contentURL.append(showPaginationMinimized);

  String filterValue = emxGetParameter(request,"mx.page.filter");
  if(filterValue != null && !"".equals(filterValue))
  {
    contentURL.append("&mx.page.filter=");
    contentURL.append(filterValue);
    fs.setFilterValue(filterValue);
  }

  // Define Top Include Params

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.PersonMenu.IconMail";

  String DeleteSelected   = "emxFramework.IconMail.Common.DeleteSelected";
  String sCreate    = "emxFramework.IconMail.Common.CreateMsg";
  String sCheck   = "emxFramework.IconMail.Inbox.TTCheckMails";

    // Marker to pass into Help Pages
    // icon launches new window with help frameset inside
    String HelpMarker = emxGetParameter(request,"HelpMarker");
    if (HelpMarker == null || HelpMarker.trim().length() == 0)
      HelpMarker = "emxhelpiconmail";

    //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
    fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,false,true,false);
    fs.setStringResourceFile("emxFrameworkStringResource");
    fs.setBeanName(tableBeanName);

    //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))

    fs.createCommonLink(sCreate,
                          "showEditDialogPopup('New')",
                          "role_GlobalUser",
                          false,
                          true,
                          "default",
                          true,
                          3);
    fs.createCommonLink(sCheck,
                            "filterMessages()",
                            "role_GlobalUser",
                            false,
                            true,
                            "default",
                            true,
                          3);
    fs.createCommonLink(DeleteSelected,
                      "deleteMail()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      false,
                      0);

    // ------------ Define any Filters to show in drop down-------------
    // Syntax: addFilterOption(Display String (Internationalized), parameter Value)\

  String sUnread ="emxFramework.IconMail.Inbox.UnRead";
    String sRead ="emxFramework.IconMail.Common.Read";
    String sAll ="emxFramework.IconMail.Common.All";

    fs.addFilterOption(sAll,"all");
    fs.addFilterOption(sRead,"read");
    fs.addFilterOption(sUnread,"unread");
    fs.setPageTitle(EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource",
                    new Locale(request.getHeader("Accept-Language")), PageHeading));

     // ----------------- Do Not Edit Below ------------------------------
    fs.writePage(out);

  %>











