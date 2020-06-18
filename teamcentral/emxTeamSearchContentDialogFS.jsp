<%--  emxTeamSearchContentDialogFS.jsp   -   Create Frameset for MyDesk Search
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file="emxTeamSearchInclude.inc"%>

<%
  // Prepare the proper contentUrl with all the required parameters
  String objectId       = emxGetParameter(request,"objectId");
  String sProjectId     = emxGetParameter(request,"projectId");
  String strRouteId     = emxGetParameter(request,"routeId");
  String sTemplateId    = emxGetParameter(request,"templateId");
  String sTemplateName  = emxGetParameter(request,"template");
  String workspaceName  = emxGetParameter(request,"workspaceName");
  String sContent       = emxGetParameter(request,"content");
  String searchType     = emxGetParameter(request,"searchType");
  String contentURL     = "";
  String searchMessage  = "emxTeamCentral.Button.Search";
  String searchHeading  = "emxTeamCentral.SearchCommon.SearchHeading";
  String HelpMarker     = "emxhelpsearch";

  boolean isFileFirst       = false;
  boolean isPackageFirst    = false;
  boolean isRFQFirst        = false;
  boolean isQuotationFirst  = false;
  boolean isUmgFileFirst    = false;
  boolean isPartsFirst      = false;

  //To check whether suppliercentral application is registered
  String suiteSourcingCentral  = EnoviaResourceBundle.getProperty(context,"emxFramework.UISuite.SourcingCentral");
  String suiteEngrCentral  = EnoviaResourceBundle.getProperty(context,"emxFramework.UISuite.EngineeringCentral");
  boolean engrRegistered   = FrameworkUtil.isThisSuiteRegistered(context,session,suiteEngrCentral);
  boolean sourcingRegistered   = FrameworkUtil.isThisSuiteRegistered(context,session,suiteSourcingCentral);
  searchFramesetObject fs = new searchFramesetObject();

  if (searchType == null) {
    searchType = "File";
  }

  // To set the Pageheading, Search heading and the contentURL to the frameset

  if (searchType!=null && searchType.equals("File")) {
    contentURL = "emxTeamSearchContentDialog.jsp";
    contentURL =   contentURL +"?objectId="+objectId+"&projectId="+sProjectId;
    contentURL += "&routeId=" + strRouteId + "&templateId=" + sTemplateId + "&template=" + sTemplateName;
    contentURL += "&workspaceName=" + workspaceName+"&content="+sContent;

    fs.createSearchLink("emxTeamCentral.FindFiles.FindFiles",
          com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL),
          "role_CompanyRepresentative,role_ExchangeUser"
    );
    isFileFirst = true;
  }

  if (sourcingRegistered) {
    if(searchType!=null && searchType.equals("RFQ"))  {
      contentURL = "emxTeamRFQSearchDialog.jsp";
      fs.createSearchLink("emxTeamCentral.FindFiles.FindRFQs",
            com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL),
            "role_Buyer"
      );
      isRFQFirst = true;
    } else if(searchType!=null && searchType.equals("Quotation"))  {
      contentURL = "emxTeamQuotationSearchDialog.jsp";
      fs.createSearchLink("emxTeamCentral.FindFiles.FindQuotations",
          com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL),
          "role_Supplier,role_SupplierRepresentative"
      );
      isQuotationFirst = true;
    } else if(searchType!=null && searchType.equals("Package"))  {
      contentURL = "emxTeamPackageSearchDialog.jsp";
      fs.createSearchLink("emxTeamCentral.FindFiles.FindPackages",
        com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL),
        "role_Buyer"
      );
      isPackageFirst = true;

    }
  }


  if (engrRegistered) {
    if(searchType!=null && searchType.equals("Parts"))  {
      contentURL = "emxTeamPartSearchDialog.jsp?mode=findPart";
      fs.createSearchLink("emxTeamCentral.FindFiles.FindParts",
            com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL),
            "role_GlobalUser"
      );
      isPartsFirst = true;
    }
  }
  

  if(searchType!=null && searchType.equals("UnmanageFile"))  {
        contentURL = "emxTeamUnmanagedDocumentSearchDialog.jsp";
        fs.createSearchLink("emxTeamCentral.GenericSearch.UnmanagedFileSearch",
          com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL),
          "role_CompanyRepresentative,role_ExchangeUser"
        );
        isUmgFileFirst = true;
  }



  fs.initFrameset(searchMessage,contentURL,searchHeading,false);
  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.setDirectory(appDirectory);
  fs.setHelpMarker(HelpMarker);

  if(!isFileFirst) {
    fs.createSearchLink("emxTeamCentral.FindFiles.FindFiles",
    com.matrixone.apps.domain.util.XSSUtil.encodeForURL("emxTeamSearchContentDialog.jsp"),
    "role_CompanyRepresentative,role_ExchangeUser"
    );
  }
  if (sourcingRegistered) {
    if(!isPackageFirst) {
      fs.createSearchLink("emxTeamCentral.FindFiles.FindPackages",
        com.matrixone.apps.domain.util.XSSUtil.encodeForURL("emxTeamPackageSearchDialog.jsp"),
        "role_Buyer"
      );
    }
    if(!isRFQFirst) {
      fs.createSearchLink("emxTeamCentral.FindFiles.FindRFQs",
        com.matrixone.apps.domain.util.XSSUtil.encodeForURL("emxTeamRFQSearchDialog.jsp"),
        "role_Buyer"
      );
    }
    if(!isQuotationFirst) {
      fs.createSearchLink("emxTeamCentral.FindFiles.FindQuotations",
        com.matrixone.apps.domain.util.XSSUtil.encodeForURL("emxTeamQuotationSearchDialog.jsp"),
        "role_Supplier,role_SupplierRepresentative"
      );
    }

  }
        
    if (engrRegistered) {
      if(!isPartsFirst)  {
        contentURL = "emxTeamPartSearchDialog.jsp?mode=findPart";
        fs.createSearchLink("emxTeamCentral.FindFiles.FindParts",
              com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL),
              "role_GlobalUser"
        );
    }
    
   }

  if(!isUmgFileFirst) {

    //Added Help Marker.
    HelpMarker     = "emxhelpselectpeople";

    fs.setHelpMarker(HelpMarker);
        fs.createSearchLink("emxTeamCentral.GenericSearch.UnmanagedFileSearch",
          com.matrixone.apps.domain.util.XSSUtil.encodeForURL("emxTeamUnmanagedDocumentSearchDialog.jsp"),
          "role_CompanyRepresentative,role_ExchangeUser"
        );
  }
  fs.writePage(out);
%>
