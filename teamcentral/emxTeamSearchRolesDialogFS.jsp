<%--  emxTeamSearchRolesDialogFS.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>

<%
  String Directory = appDirectory;
  searchFramesetObject fs = new searchFramesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String organizationId = emxGetParameter(request,"objectId");
  String sRoleList     = emxGetParameter(request, "roleList");

 if (sRoleList == null){
    sRoleList="";
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


  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamSearchRolesDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&objectId=" + organizationId+ "&roleList=" + sRoleList;
  contentURL += "&loginName=" + loginName + "&password=" + password + "&confirmpassword=" + confirmpassword;
  contentURL += "&firstName=" + firstName + "&middleName=" + middleName +"&companyName=" + companyName;
  contentURL += "&location=" + location + "&workPhoneNumber=" + workPhoneNumber +"&homePhoneNumber=" + homePhoneNumber;
  contentURL += "&pagerNumber=" + pagerNumber +"&emailAddress="+ emailAddress + "&faxNumber=" +faxNumber;
  contentURL += "&webSite=" + webSite + "&lastName=" + lastName +"&businessUnit="+strBusinessUnit+"&callPage="+strCallpage;

  String PageHeading = "emxTeamCentral.CreatePerson.AddRoles";
  String HelpMarker = "emxhelpselectmembers";

  fs.initFrameset(PageHeading,
                  contentURL,
                  "emxTeamCentral.CreatePerson.Basic",
                  false
                 );

  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.setDirectory(Directory);
  fs.setHelpMarker(HelpMarker);

  // Create search Link. One call of this method for one search link on the left side
  // Use com.matrixone.apps.domain.util.XSSUtil.encodeForURL method for encoding
  // fs.createSearchLink(String internationalizedlinkDasplayName, String encodedcontentURL, String rolelist);
  fs.createSearchLink("emxTeamCentral.CreatePerson.FindRoles",
                      com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL),
                      "role_CompanyRepresentative,role_ExchangeUser"
                     );
  fs.writePage(out);

%>
