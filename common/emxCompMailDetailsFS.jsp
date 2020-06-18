<%-- emxCompMailDetailsFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCompMailDetailsFS.jsp.rca 1.12 Wed Oct 22 15:48:15 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>

<%
  framesetObject fs = new framesetObject();
  String Directory = appDirectory;
  fs.setDirectory(Directory);
  fs.setSubmitMethod(request.getMethod());

  String initSource = emxGetParameter(request,"initSource");
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String objectName = emxGetParameter(request,"objectName");
  String sMailId    = emxGetParameter(request,"objId");
  String treeLabel  = emxGetParameter(request,"treeLabel");

  if (initSource == null){
      initSource = "";
  }
  // Add Parameters Below
    String param = emxGetParameter(request,"param");

    // Specify URL to come in middle of frameset
    StringBuffer contentURL = new StringBuffer(100);
    contentURL.append("emxCompMailDetails.jsp");


  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objId=");
  contentURL.append(sMailId);



  // Define Top Include Params

  // Page Heading - Internationalized

  String PageHeading = "emxFramework.IconMail.Common.MailProperties";

  // perform for all links, put in appropriate vector

  // ----------------- Top Include ------------------------------
  // 'display' Strings must be Internationalized

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = emxGetParameter(request,"HelpMarker");
  if (HelpMarker == null || HelpMarker.trim().length() == 0)
    HelpMarker = "emxhelpiconmailproperties";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,false,false,false);
  fs.setStringResourceFile("emxFrameworkStringResource");
  
    //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  String sReply     ="emxFramework.IconMail.Common.Reply";
  String sReplyAll  ="emxFramework.IconMail.Common.ReplyAll";
  String sForward   ="emxFramework.IconMail.Common.Forward";
  String sDelete    ="emxFramework.IconMail.Common.Delete";
  fs.setCategoryTree(emxGetParameter(request,"categoryTreeName"));
  fs.setOtherParams(UINavigatorUtil.getRequestParameterMap(request));
  fs.setTreeLabel(treeLabel);
  fs.createCommonLink(sReply,
                          "showEditDialogPopup('Reply')",
                          "role_GlobalUser",
                          false,
                          true,
                          "../common/images/iconActionReply.png",
                          true,
                          3);

  fs.createCommonLink(sReplyAll,
                            "showEditDialogPopup('ReplyAll')",
                            "role_GlobalUser",
                          false,
                          true,
                          "../common/images/iconActionReplyAll.png",
                          true,
                        3);
  fs.createCommonLink(sForward,
                            "showEditDialogPopup('Forward')",
                            "role_GlobalUser",
                          false,
                          true,
                          "../common/images/iconActionForward.png",
                          true,
                        3);


  // ------------ Define any Filters to show in drop down-------------
    // Syntax: addFilterOption(Display String (Internationalized), parameter Value)

    // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);

  %>





