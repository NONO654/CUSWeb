<%--  emxCompMailAttachmentSearchDialogFS.jsp   - Display Frameset for Add Members
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>
<%
searchFramesetObject fs = new searchFramesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String projectId   = emxGetParameter(request,"objectId");

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(100);
  contentURL.append("emxCompMailAttachmentSearchDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(projectId);

  // Page Heading - Internationalized
 String PageHeading = "emxFramework.IconMail.Common.FindContent";
 
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpmailattachments";

 // fs.initFrameset(String PageHeader,String contentURL, String searchHeading, boolean showPagination);


  fs.initFrameset(PageHeading,
                  contentURL.toString(),
                  EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.IconMail.Common.SearchHeading", new Locale(sLanguage)),                  
                  false
                 );
  fs.setStringResourceFile("emxFrameworkStringResource");

  // Create search Link. One call of this method for one search link on the left side
  // Use com.matrixone.apps.domain.util.XSSUtil.encodeForURL method for encoding

  // fs.createSearchLink(String internationalizedlinkDasplayName, String encodedcontentURL, String rolelist);
  fs.createSearchLink(PageHeading,
                      com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL.toString()),
                      "role_GlobalUser"
                     );


    // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
