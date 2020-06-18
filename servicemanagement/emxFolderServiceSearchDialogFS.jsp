<%--  emxFolderServiceSearchDialogFS.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxServiceManagementAppInclude.inc"%>

<%
  // Prepare the proper contentUrl with all the required parameters
  String objectId       = emxGetParameter(request, "objectId");
  String searchType     = emxGetParameter(request, "searchType");
  String commandType	= emxGetParameter(request, "commandType");
  
  // WWI 071309: get help marker ID from schema definition
  String HelpMarker		= emxGetParameter(request, "HelpMarker");

  String searchURL		= "";
  String searchLabel 	= "";
  String PageHeading	= "emxWSManagement.FindContent.Heading";
  String relType 		= "";

  searchFramesetObject fs = new searchFramesetObject();

  // set default values
  if (searchType == null || searchType.equals("null") || searchType.equals("")) {
      searchType = "type_ServiceFolder";
  }
  HashMap hMap=(HashMap)session.getAttribute("hmapRequestParams");
  if (commandType == null ||  commandType.equals("null") || commandType.equals("")) {
      // HCG 1110: to handle "New Search from Search Results page" case
      if (hMap != null)
      	  commandType = (String)hMap.get("commandType");
      if (commandType == null || commandType.equals("null") || commandType.equals("")) {
      	  commandType = "AddServiceCategoryRel";
      }
  }

  //HCG 1110: to handle "New Search from Search Results page" case
  String formName = "";
  String fieldNameDisplay = "";
  String fieldNameActual = "";
  if (commandType.equals("AddServiceAccessText")) {
      formName = emxGetParameter(request, "formName");
      if (formName == null && hMap != null)
	  	formName = (String)hMap.get("formName");
      
      fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
      if (fieldNameDisplay == null && hMap != null)
	  fieldNameDisplay = (String)hMap.get("fieldNameDisplay");
      
      fieldNameActual = emxGetParameter(request, "fieldNameActual");
      if (fieldNameActual == null && hMap != null)
	  fieldNameActual = (String)hMap.get("fieldNameActual");
  }
      
  // Introduced a HashMap to hold the common values;this map is then uploaded to the session
  session.removeAttribute("hmapRequestParams");
  HashMap hmapRequestParams = new HashMap();
  hmapRequestParams.put("objectId",objectId);
  hmapRequestParams.put("searchType",searchType);
  hmapRequestParams.put("commandType", commandType);
  if (commandType.equals("AddServiceAccessText")) {
      hmapRequestParams.put("formName", formName);
      hmapRequestParams.put("fieldNameDisplay", fieldNameDisplay);
      hmapRequestParams.put("fieldNameActual", fieldNameActual);
  }
  session.setAttribute("hmapRequestParams", hmapRequestParams);

  if (commandType.equals("AddServiceAccessText") || commandType.equals("AddServiceAccessRel"))
  {
      relType = Framework.getPropertyValue(session, "relationship_ServiceAccess");
  } else if (commandType.equals("AddServiceCategoryRel"))
  {
      relType = Framework.getPropertyValue(session, "relationship_ServiceCategory");
  }
  searchURL = "emxFolderServiceSearchDialog.jsp?objectId="+objectId+"&searchType="+searchType+"&relType="+relType+"&HelpMarker="+HelpMarker;
  if(searchType.equals("type_ServiceFolder")) {
    searchLabel = "emxWSManagement.GenericSearch.FolderSearch";
    } else {
    searchLabel = "emxWSManagement.GenericSearch.ServiceSearch";
  }

  // Create search Link. One call of this method for one search link on the left side
  fs.initFrameset(PageHeading, searchURL, "emxWSManagement.FindContent.Basic.Heading", false);
  fs.setStringResourceFile("emxWSManagementStringResource");
  fs.setDirectory(appDirectory);
  fs.setHelpMarker(HelpMarker);
  
  fs.createSearchLink(searchLabel,
                      com.matrixone.apps.domain.util.XSSUtil.encodeForURL(searchURL),
                      "role_ServiceAdministrator"); 

  fs.writePage(out);
%>
