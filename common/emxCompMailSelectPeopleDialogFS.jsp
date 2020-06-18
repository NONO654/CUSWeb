<%--  emxCompMailSelectPeopleDialogFS.jsp   - Display Frameset for Add Members
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
  String sLink   = emxGetParameter(request,"page");
  String sToAddress   = emxGetParameter(request,"toAddress");
  String sCCAddress   = emxGetParameter(request,"ccAddress");
 String toPeople           = emxGetParameter(request,"toPeople");
  String ccPeople           = emxGetParameter(request,"ccPeople");

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(150);
  contentURL.append("emxCompMailSelectPeopleDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&page=");
  contentURL.append(sLink);
  contentURL.append("&toAddress=");
  contentURL.append(sToAddress);
  contentURL.append("&ccAddress=");
  contentURL.append(sCCAddress);
  contentURL.append("&ccPeople=");
  contentURL.append(ccPeople);
  contentURL.append("&toPeople=");
  contentURL.append(toPeople);
  
  // Page Heading - Internationalized
 String PageHeading = "emxFramework.IconMail.Find.Find";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpselectuser";
    fs.setDirectory(appDirectory);

 // fs.initFrameset(String PageHeader,String contentURL, String searchHeading, boolean showPagination);
	String test = "emxFramework.IconMail.Common.General";
  fs.initFrameset(PageHeading,
                  contentURL.toString(),
                  test,
                  false
                 );
    fs.setHelpMarker(HelpMarker);
  fs.setStringResourceFile("emxFrameworkStringResource");

  // Create search Link. One call of this method for one search link on the left side
  // Use com.matrixone.apps.domain.util.XSSUtil.encodeForURL method for encoding

  // fs.createSearchLink(String internationalizedlinkDasplayName, String encodedcontentURL, String rolelist);
  fs.createSearchLink("emxFramework.IconMail.Common.SelectPerson",
                      java.net.URLEncoder.encode(contentURL.toString()),
                      "role_GlobalUser"
                     );


    // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
