<%--  emxRouteRolesSearchFS.jsp -  Search dialog frameset

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsBusinessSkillSearchFS.jsp.rca 1.6 Wed Oct 22 16:18:49 2008 przemek Experimental przemek $
--%>

<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>

<%
  com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PERSON);
  
  String restrictMembers = emxGetParameter(request,"restrictMembers");
  String objectId = emxGetParameter(request,"objectId");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  String multiSelect = emxGetParameter(request,"multiSelect");
  String parentForm  = emxGetParameter(request,"form");
  String parentField = emxGetParameter(request,"field");
  String idField = emxGetParameter(request,"idfield");
  String mainSearchPage = emxGetParameter(request,"mainSearchPage");
  String fieldName = emxGetParameter(request,"fieldName");
  String mode = emxGetParameter(request,"mode");
  String companyId = "";
  String personId = "";
  if (mode!= null && !"".equals(mode) && !"null".equals(mode))  
  {
      if("ResourcePool".equals(mode))
      {
      	personId = emxGetParameter(request,"personId");
      	String strLoggedInUser = com.matrixone.apps.domain.util.PersonUtil.getPersonObjectID(context);
      	person.setId(strLoggedInUser);
        person.open(context);
        companyId = person.getCompanyId(context);
        person.close(context);
      }
  }
  else
  {
 		person.setId(objectId);
		person.open(context);
  
		if(person.getType(context).equals("Company"))
		{
    		companyId = objectId;
		}
		else
  		{
		    companyId = person.getCompanyId(context);
  		}
  		person.close(context);
  		personId = objectId;
  }
  	
  if(multiSelect == null)
  {
    multiSelect = "true";
  }
  // add these parameters to each content URL, and any others the App needs
  String params = "?objectId=" + objectId +  "&targetSearchPage=" + targetSearchPage;
  params += "&topId=" + companyId + "&personId=" + personId+ "&idfield=" + idField;
  params += "&multiSelect=" + multiSelect+"&mainSearchPage="+mainSearchPage + "&fieldName=" + fieldName+"&mode=" + mode;

  // Specify URL to come in middle of frameset

  String contentURL = "emxComponentsBusinessSkillSearch.jsp" + params;

  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);

  // Search Heading - Internationalized
  String PageHeading = "emxComponents.AddSkills.SearchBusinessSkills";
  String HelpMarker = "emxhelpskillssearch";
  String commandImage = "common/images/buttonDialogNext.gif";

  fs.setStringResourceFile("emxComponentsStringResource");

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);

  // ----------------- Do Not Edit Below ------------------------------
  String commandButton = "emxComponents.Button.Next";
  if(mode !=null && mode.equalsIgnoreCase("businessSkillSearch")){
    commandButton = "emxComponents.Button.Done";
    commandImage = "common/images/buttonDialogDone.gif";
  }
  
    
    

   fs.createCommonLink(commandButton,
                      "doNext()",
                      "role_GlobalUser",
                      false,
                      true,
                      commandImage,
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
  // ----------------- Do Not Edit Below ------------------------------

  fs.writeSelectPage(out);

%>
