<%-- emxCompMailSelectPeopleResultsFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
--%>

<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file  = "emxCompCommonUtilAppInclude.inc"%>
<% 
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  String Directory = appDirectory;

  fs.setDirectory(Directory);
  fs.setSubmitMethod(request.getMethod());

  // ----------------- Do Not Edit Above ------------------------------


  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(100);
  contentURL.append("emxCompMailSelectPeopleResults.jsp");
  String toPeople           = emxGetParameter(request,"toPeople");
  String ccPeople           = emxGetParameter(request,"ccPeople");
  
  String sLink  = emxGetParameter(request,"page");
  String sUsername = emxGetParameter(request,"txtUsername");
  String sFirstName = emxGetParameter(request,"txtFirstName");
  String sLastName = emxGetParameter(request,"txtLastName");
  String sCompany = emxGetParameter(request,"txtCompany");
  String[] squeryfilter = emxGetParameterValues(request, "queryfilter");
  String sFilterOption=emxGetParameter(request, "FilterOption");
  String squeryoption   ="";
  if (sFilterOption!= null)
  {
   squeryoption   = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(sFilterOption);
  }
  StringBuffer selectedOption = new StringBuffer(50);
  String sSelect="";
  if(  squeryoption != null && squeryoption.length() >0)
  {
    for (int z=0;z<squeryfilter.length; z++)
    {
      if(z==0){
        sSelect=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(squeryfilter[z]);
      }else{
       sSelect="|"+com.matrixone.apps.domain.util.XSSUtil.encodeForURL(squeryfilter[z]);
      }
      selectedOption.append(sSelect);
    }
  }

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&FilterOption=");
  contentURL.append(squeryoption);
  contentURL.append("&queryfilter=");
  contentURL.append(selectedOption.toString());
  contentURL.append("&page=");
  contentURL.append(sLink);
  contentURL.append("&txtUsername=");
  contentURL.append(sUsername);
  contentURL.append("&txtFirstName=");
  contentURL.append(sFirstName);
  contentURL.append("&txtLastName=");
  contentURL.append(sLastName);
  contentURL.append("&txtCompany=");
  contentURL.append(sCompany);
   contentURL.append("&toPeople=");
   contentURL.append(toPeople);
   contentURL.append("&ccPeople=");
  contentURL.append(ccPeople);
  
//  contentURL.append("&sortImage=images/iconSortDown.gif");

  String cURL = Framework.encodeURL(response,contentURL.toString());

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.IconMail.Common.Select";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = emxGetParameter(request,"HelpMarker");
  if (HelpMarker == null || HelpMarker.trim().length() == 0)
    HelpMarker = "emxhelpselectperson";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,cURL.toString(),false,true,false,false);
  fs.setStringResourceFile("emxFrameworkStringResource");
  fs.removeDialogWarning();

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxFramework.IconMail.Common.Done",
                      "submitform()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);

  fs.createCommonLink("emxFramework.IconMail.Common.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);


  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
