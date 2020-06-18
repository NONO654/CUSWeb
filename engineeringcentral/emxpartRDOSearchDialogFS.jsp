<%--  emxpartRDOSearchDialogFS.jsp  -  Search dialog frameset
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>

<%
  // Search message - Internationalized
  String searchMessage = "emxEngineeringCentral.Common.Find";
  // create a search frameset object
  searchFramesetObject fs = new searchFramesetObject();

  // Search Heading - Internationalized
  String searchHeading = "emxFramework.Suites.Display.EngineeringCentral";

  String parentForm  = emxGetParameter(request,"form");
  String parentField = emxGetParameter(request,"field");
  String parentFieldId = emxGetParameter(request,"fieldId");
  String parentFieldRev = emxGetParameter(request,"fieldRev");
  String isPartEdit     = emxGetParameter(request,"isPartEdit");
  String objectId       = emxGetParameter(request,"objectId");
  String searchMode       = emxGetParameter(request,"searchMode");

  // Added for RCO 
  String sCreateECR = emxGetParameter(request,"CreateECR");
  session.setAttribute("CreateECR",sCreateECR);
  String sExcludePlant = emxGetParameter(request,"ExcludePlant");
  session.setAttribute("ExcludePlant",sExcludePlant);

  String role = emxGetParameter(request,"role");

  // Name the property to get the links to be displayed.
  String searchLinkProp = emxGetParameter(request,"searchLinkProp");

  // Parameter passed from the find results page has the corresponding search link
  // to display as default
  String pageValue = emxGetParameter(request,"pageFlag");

   // Added for MCC EC Interoperability Feature
   String sFieldManufacturerLocationIdDisplay = emxGetParameter(request,"fieldManufacturerLocation");
   String sFieldManufacturerLocationId = emxGetParameter(request,"fieldManufacturerLocationId");
   //end
  fs.setSuiteKey("ManufacturerEquivalentPart");
  fs.setDirectory(appDirectory);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");
  fs.setHelpMarker("emxhelpselectorganization");

  // Setup query limit
  String sQueryLimit = JSPUtil.getCentralProperty(application,
                                                  session,
                                                  "eServiceEngineeringCentral",
                                                  "QueryLimit");

// Check if the value of Revision is null
  if (sQueryLimit == null || sQueryLimit.equals("null") || sQueryLimit.equals("")){
    sQueryLimit = "";
  } else {
    Integer integerLimit = new Integer(sQueryLimit);
    int intLimit = integerLimit.intValue();
    fs.setQueryLimit(intLimit);
  }

  // Narrow this list and add access checking
  String roleList = "role_GlobalUser";

  // Get list of searchLinks from properties
  StringList searchLinks = JSPUtil.getCentralProperties(application, session, "eServiceEngineeringCentral", searchLinkProp);

  if(searchLinks == null)
  {
    searchLinks  = new StringList();
  }
  String linkEntry;
  String linkText;
  String contentURL;

  boolean flag = true;
  pageValue = ((pageValue == null) || pageValue.equalsIgnoreCase("null")) ? "" : pageValue;

  if (pageValue != null && !("".equals(pageValue)) && !("null".equals(pageValue)) ){
    contentURL = JSPUtil.getCentralProperty(application, session, pageValue, "ContentPage");
    contentURL = contentURL+"?field="+parentField+"&form="+parentForm+"&fieldId="+parentFieldId+"&fieldRev="+parentFieldRev+"&isPartEdit="+isPartEdit+"&objectId="+objectId+"&role="+role+"&searchMode="+searchMode;
    
    // Added for MCC EC Interoperability Feature
    if(sFieldManufacturerLocationId != null &&  !"null".equalsIgnoreCase(sFieldManufacturerLocationId) && !"".equals(sFieldManufacturerLocationId)) 
    {
         contentURL +="&fieldManufacturerLocation="+sFieldManufacturerLocationIdDisplay+"&fieldManufacturerLocationId="+sFieldManufacturerLocationId+"&searchMode="+searchMode;
    }
    //end

    linkText = JSPUtil.getCentralProperty(application, session, pageValue, "LinkText");
    fs.initFrameset(searchMessage,contentURL,searchHeading,false);
    fs.createSearchLink(linkText, com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL), roleList);
    flag=false;
  }

  // Populate left side of search dialog from properties
  for (int i=0; i < searchLinks.size(); i++)
  {
    // Get the entry
    linkEntry = (String)searchLinks.get(i);
    if(!(linkEntry.equals(pageValue)))
    {
      contentURL = JSPUtil.getCentralProperty(application, session, linkEntry, "ContentPage");
      contentURL = contentURL+"?field="+parentField+"&form="+parentForm+"&fieldId="+parentFieldId+"&fieldRev="+parentFieldRev+"&isPartEdit="+isPartEdit+"&objectId="+objectId+"&role="+role+"&searchMode="+searchMode;

      // Added for MCC EC Interoperability Feature
      if(sFieldManufacturerLocationId != null &&  !"null".equalsIgnoreCase(sFieldManufacturerLocationId) && !"".equals(sFieldManufacturerLocationId)) 
      {
           contentURL +="&fieldManufacturerLocation="+sFieldManufacturerLocationIdDisplay+"&fieldManufacturerLocationId="+sFieldManufacturerLocationId+"&searchMode="+searchMode;
      }
      
      //end
      // Get string resource entry
      linkText = JSPUtil.getCentralProperty(application, session, linkEntry, "LinkText");

      // first pass is default content page
      if (i == 0 &&flag==true){
        fs.initFrameset(searchMessage,contentURL,searchHeading,false);
      }
      fs.createSearchLink(linkText, com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL), roleList);
    }
  }

  fs.writePage(out);

%>

