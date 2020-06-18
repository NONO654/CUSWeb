<%--  emxEngrFindRelatedQueryFS.jsp  -  Search summary frameset
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<jsp:useBean id="emxEngrFindRelatedQueryFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String tableBeanName = "emxEngrFindRelatedQueryFS";

  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);
  fs.removeDialogWarning();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");


  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  String contentURL = "emxEngrFindRelatedQuery.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&beanName=" + tableBeanName;

    String filterValue = emxGetParameter(request,"mx.page.filter");
  if(filterValue != null && !"".equals(filterValue))
  {
    contentURL += "&mx.page.filter=" + filterValue;
    fs.setFilterValue(filterValue);
  }

  fs.setBeanName(tableBeanName);
  String fromDelete = emxGetParameter(request,"fromDelete");

  if(fromDelete == null || "".equals(fromDelete) || "null".equals(fromDelete)) {
    // Loop through parameters and pass on to summary page
    String constructUrl ="";
    for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
    {
        String name = (String) names.nextElement();
        String value = emxGetParameter(request, name);

        String param = "";
        if (value != null){
          param = "&" + name + "=" + value;
        }

        constructUrl += param;
    }
    session.setAttribute("findLikeUrl", constructUrl);
    contentURL += constructUrl;
  } else {
    if(session.getAttribute("findLikeUrl")!= null){
      contentURL += (String)session.getAttribute("findLikeUrl");
    }
  }

  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.Common.Search";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpsearch";

  /*
  /*
  String    pageHeading,
  String    helpMarker,
  String    middleFrameURL,
  boolean   UsePrinterFriendly,
  boolean   IsDialogPage,
  boolean   ShowPagination,
  boolean   ShowConversion
  int       MaxTopLinks (Optional)
  */
  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,true,true,false);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  /*
  String    displayString,
  String    href,
  String    roleList,
  boolean   popup,
  boolean   isJavascript,
  String    iconImage,
  int       WindowSize
  */


  // TODO!
  // Narrow this list and add access checking
  //
  
/*  String roleList = "role_DesignEngineer,role_ECRChairman,role_ECRCoordinator,role_ECREvaluator," +
                    "role_ManufacturingEngineer,role_OrganizationManager,role_PartFamilyCoordinator," +
                    "role_ProductObsolescenceManager,role_SeniorDesignEngineer,role_SeniorManufacturingEngineer,role_ComponentEngineer";

  fs.createHeaderLink("emxFramework.Command.NewSearch",
                      "newSearch()",
                      roleList,
                      false,
                      true,
                      "default",
                      0);

  fs.createHeaderLink("emxFramework.Command.SaveQuery",
                      "saveQuery()",
                      roleList,
                      false,
                      true,
                      "default",
                      0);

  fs.createFooterLink("emxFramework.Command.AddToCollection",
                      "createSelectCollection()",
                      roleList.toString(),
                      false,
                      true,
                      "default",
                      0);

  fs.createFooterLink("emxFramework.Command.DeleteSelected",
                      "deleteSelected()",
                      roleList,
                      false,
                      true,
                      "default",
                      0);

  fs.createFooterLink("emxEngineeringCentral.Common.Close",
                      "parent.window.close()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);*/

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>
