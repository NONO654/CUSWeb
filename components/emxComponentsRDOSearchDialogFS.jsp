<%--  emxpartRDOSearchDialogFS.jsp  -  Search dialog frameset

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../components/emxComponentsFramesetUtil.inc"%>

<%
  // Search message - Internationalized
  String searchMessage = "emxComponents.Common.Find";
  // create a search frameset object
  searchFramesetObject fs = new searchFramesetObject();

  // Search Heading - Internationalized
  String searchHeading = "emxFramework.Suites.Display.Common";

  String parentForm  = emxGetParameter(request,"form");
  String parentField = emxGetParameter(request,"field");
  String parentFieldId = emxGetParameter(request,"fieldId");
  String parentFieldRev = emxGetParameter(request,"fieldRev");
  String isEdit     = emxGetParameter(request,"isEdit");
  String objectId       = emxGetParameter(request,"objectId");
  
  // parameter to dispay checkbox (value:multiple) or radio (value=single) in the search results
  String selection       = emxGetParameter(request,"selection");

  String role = emxGetParameter(request,"role");

  // Name the property to get the links to be displayed.
  String searchLinkProp = emxGetParameter(request,"searchLinkProp");

  // Parameter passed from the find results page has the corresponding search link
  // to display as default
  String pageValue = emxGetParameter(request,"pageFlag");

  fs.setDirectory(appDirectory);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setHelpMarker("emxhelpselectorganization");

  // Setup query limit
  String sQueryLimit = JSPUtil.getCentralProperty(application,
                                                  session,
                                                  "eServiceComponents",
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
  StringList searchLinks = JSPUtil.getCentralProperties(application, session, "eServiceComponents", searchLinkProp);

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
    contentURL = contentURL+"?field="+parentField+"&form="+parentForm+"&fieldId="+parentFieldId+"&fieldRev="+parentFieldRev+"&isEdit="+isEdit+"&objectId="+objectId+"&role="+role+"&selection="+selection;
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
      contentURL = contentURL+"?field="+parentField+"&form="+parentForm+"&fieldId="+parentFieldId+"&fieldRev="+parentFieldRev+"&isEdit="+isEdit+"&objectId="+objectId+"&role="+role+"&selection="+selection;
      // Get string resource entry
      linkText = JSPUtil.getCentralProperty(application, session, linkEntry, "LinkText");

      // first pass is default content page
      if(linkText.indexOf("Project")>=1){
      if (FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMEngineering",false,null,null)){
          fs.createSearchLink(linkText, com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL), roleList);
      }
     
    }else{
        if (i == 0 &&flag==true){
            fs.initFrameset(searchMessage,contentURL,searchHeading,false);
          }
          fs.createSearchLink(linkText, com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL), roleList);
    }
    }
  }

  fs.writePage(out);

%>

