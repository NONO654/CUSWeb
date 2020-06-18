<%--  emxComponentsAddExistingPersonSearchResultsFS.jsp  - Frameset page for search result

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsAddExistingPersonSearchResultsFS.jsp.rca 1.10 Wed Oct 22 16:18:02 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<jsp:useBean id="emxComponentsAddExistingPersonSearchResultsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<%
  String tableBeanName = "emxComponentsAddExistingPersonSearchResultsFS";

  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String suiteKey = emxGetParameter(request,"suiteKey");


  String strFirstName   = emxGetParameter(request,"firstName");
  String strLastName    = emxGetParameter(request,"lastName");
  String strUserName    = emxGetParameter(request,"userName");
  String strCompanyName = emxGetParameter(request,"companyName");
  String parentForm     = emxGetParameter(request,"form");
  String parentField    = emxGetParameter(request,"field");
  String typeAlias      = emxGetParameter(request,"typeAlias");
  String tempPersonList = emxGetParameter(request,"tempPersonList");
  String showCompanyAsLabel = emxGetParameter(request,"showCompanyAsLabel");
  String defaultCompany = emxGetParameter(request,"defaultCompany");
  String lbcAccess = emxGetParameter(request,"lbcAccess");

  // Only 2 lines added - Nishchal
  String keyValue = emxGetParameter(request,"keyValue");
  String callPage = emxGetParameter(request,"callPage");
  if(callPage == null || callPage.equals("null"))
  {
      callPage ="";
  }


  String AddPerson = emxGetParameter(request,"AddPerson");
  if (AddPerson == null || AddPerson.equals("null") || AddPerson.equals("")){
        AddPerson="false";
  }
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  String multiSelect = emxGetParameter(request,"multiSelect");
  String queryLimit = emxGetParameter(request,"queryLimit");

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsAddExistingPersonSearchResults.jsp";

  // Modified these parameters  Nishchal
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&form=" + parentForm + "&field=" + parentField;
  contentURL += "&objectId=" + objectId + "&userName=" + XSSUtil.encodeForURL(context,strUserName) + "&firstName=" + XSSUtil.encodeForURL(context,strFirstName) + "&lastName=" + XSSUtil.encodeForURL(context,strLastName);
  contentURL += "&companyName=" + XSSUtil.encodeForURL(context,strCompanyName) + "&targetSearchPage=" + targetSearchPage;
  contentURL += "&multiSelect=" + multiSelect;
  contentURL += "&queryLimit=" + queryLimit;
  contentURL += "&beanName=" + tableBeanName;
  contentURL += "&typeAlias=" + typeAlias;
  contentURL += "&tempPersonList=" + tempPersonList;
  contentURL += "&showCompanyAsLabel=" + showCompanyAsLabel;
  contentURL += "&defaultCompany=" + XSSUtil.encodeForURL(context, defaultCompany);
  contentURL += "&lbcAccess=" + XSSUtil.encodeForURL(context, lbcAccess);
  contentURL += "&keyValue=" + keyValue;
  contentURL += "&callPage=" + callPage;

  String filterValue = emxGetParameter(request,"mx.page.filter");
  if(filterValue != null && !"".equals(filterValue))
  {
    contentURL += "&mx.page.filter=" + filterValue;
    fs.setFilterValue(filterValue);
  }

  fs.setBeanName(tableBeanName);

  // Page Heading  - Internationalized
  String PageHeading = "";

  // Modified the page heading - Nishchal
  if("emxComponentsObjectAccessUsersDialog".equalsIgnoreCase(callPage))
  {
      PageHeading = "emxComponents.AddPeople.SelectPeople";
  }
  else
  {
      PageHeading = "emxComponents.People.SelectPeople";
  }

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelppeopleresults";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);
  fs.removeDialogWarning();
  fs.setStringResourceFile("emxComponentsStringResource");

  // TODO!
  // Narrow this list and add access checking
  
  String roleList = "role_GlobalUser";


  fs.createHeaderLink("emxComponents.Command.NewSearch",
                        "newSearch()",
                        roleList,
                        false,
                        true,
                        "../common/images/iconActionNewSearch.png",
                        0);


// Modified Nishchal
if("emxComponentsObjectAccessUsersDialog".equalsIgnoreCase(callPage))
{

  fs.createCommonLink("emxComponents.Button.Done",
                      "submitform()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);

}
else
{
  fs.createCommonLink("emxComponents.Command.Previous",
                      "selectPrevious()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      false,
                      3);
 
 
  fs.createCommonLink("emxComponents.Command.Next",
                      "selectNext()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      3);
}




  fs.createCommonLink("emxComponents.Command.Cancel",
                      "window.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);


  fs.writePage(out);

%>
