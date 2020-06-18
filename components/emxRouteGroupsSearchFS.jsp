<%--  emxRouteGroupsSearchFS.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc" %>

<%

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String organizationId = emxGetParameter(request,"objectId");
  String sGroupList     = emxGetParameter(request, "groupList");
  String scope     = emxGetParameter(request, "scope");
  String routeId = emxGetParameter(request,"routeId");
  String restrictMembers = emxGetParameter(request,"restrictMembers");


 if (sGroupList == null){
    sGroupList="";
  }

  String loginName        = emxGetParameter(request,"loginName");
  String password         = emxGetParameter(request,"password");
  String confirmpassword  = emxGetParameter(request,"confirmpassword");
  String firstName        = emxGetParameter(request,"firstName");
  String middleName       = emxGetParameter(request,"middleName");
  String lastName         = emxGetParameter(request,"lastName");
  String companyName      = emxGetParameter(request,"companyName");
  String location         = emxGetParameter(request,"location");
  String workPhoneNumber  = emxGetParameter(request,"workPhoneNumber");
  String homePhoneNumber  = emxGetParameter(request,"homePhoneNumber");
  String pagerNumber      = emxGetParameter(request,"pagerNumber");
  String emailAddress     = emxGetParameter(request,"emailAddress");
  String faxNumber        = emxGetParameter(request,"faxNumber");
  String webSite          = emxGetParameter(request,"webSite");
  String strBusinessUnit  = emxGetParameter(request, "businessUnit");
  String strCallpage      = emxGetParameter(request, "callPage");
  String keyValue      = emxGetParameter(request, "keyValue");
  /*Simple Route Creation */
  String fromPage = emxGetParameter(request,"fromPage");
  fromPage=(fromPage==null)?"":fromPage.trim();
  /*Simple Route Creation */

  // Specify URL to come in middle of frameset
  String contentURL = "emxRouteGroupsSearch.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&objectId=" + organizationId+ "&groupList=" + sGroupList;
  contentURL += "&loginName=" + loginName + "&password=" + password + "&confirmpassword=" + confirmpassword;
  contentURL += "&firstName=" + firstName + "&middleName=" + middleName +"&companyName=" + companyName;
  contentURL += "&location=" + location + "&workPhoneNumber=" + workPhoneNumber +"&homePhoneNumber=" + homePhoneNumber;
  contentURL += "&pagerNumber=" + pagerNumber +"&emailAddress="+ emailAddress + "&faxNumber=" +faxNumber;
  contentURL += "&webSite=" + webSite + "&lastName=" + lastName +"&businessUnit="+strBusinessUnit+"&callPage="+strCallpage;
  contentURL += "&scope="+scope+"&keyValue="+keyValue;
  contentURL += "&restrictMembers=" + restrictMembers+"&routeId=" + routeId+"&fromPage="+fromPage;


  String PageHeading = "emxComponents.AddGroups.SearchGroups";
  String HelpMarker = "emxhelpsearchgroups";
  framesetObject fs = new framesetObject();

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);

  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setDirectory(appDirectory);


  // Create search Link. One call of this method for one search link on the left side
  // Use com.matrixone.apps.domain.util.XSSUtil.encodeForURL method for encoding
  // fs.createSearchLink(String internationalizedlinkDasplayName, String encodedcontentURL, String groupList);
   fs.createCommonLink("emxComponents.Button.Search",
                      "doSearch()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      3);

   fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);

%>
