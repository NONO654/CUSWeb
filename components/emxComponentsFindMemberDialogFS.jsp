<%--  emxComponentsFindMemberDialogFS.jsp   - Display Frameset for Select Members
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsFindMemberDialogFS.jsp.rca 1.8 Wed Oct 22 16:18:48 2008 przemek Experimental przemek $
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%


  String Directory = appDirectory;
  //searchFramesetObject fs = new searchFramesetObject();
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String projectId   = emxGetParameter(request,"objectId");
  
  //used for absenceDelegate fields which require Person BO name instead of "lastname, firstname"
  String getValue   = emxGetParameter(request,"getValue");
  String formName   = emxGetParameter(request,"formName");
  String fieldNameDisplay  = emxGetParameter(request,"fieldNameDisplay");
  String fieldNameActual  = emxGetParameter(request,"fieldNameActual");  

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsFindMemberDialog.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+ "&objectId="+projectId;
  contentURL += "&getValue="+getValue ;
  contentURL += "&formName="+formName ;
  contentURL += "&fieldNameDisplay="+fieldNameDisplay ;
  contentURL += "&fieldNameActual="+fieldNameActual ;
  
  String PageHeading = "emxComponents.SelectPeople.SelectPerson";
  String HelpMarker = "emxhelpselectmembers";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);                 

  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setDirectory(Directory);
  
  String rolesList = "role_GlobalUser";

/*
  // Setup query limit
  
  String sQueryLimit = JSPUtil.getApplicationProperty(context
                                            ,application
                                            ,"eServiceSuiteComponents.QueryLimit"
                                            ,"emxComponentsProperties"
                                            );

  if (sQueryLimit == null || sQueryLimit.equals("null") || sQueryLimit.equals("")){
    sQueryLimit = "";
  }
  else {
    Integer integerLimit = new Integer(sQueryLimit);
    int intLimit = integerLimit.intValue();
    fs.setQueryLimit(intLimit);
  }
*/
  fs.createCommonLink("emxComponents.Button.Search",
                      "doSearch()",
                      rolesList,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      3);

 
  fs.createCommonLink("emxComponents.Button.Cancel",
                      "parent.window.close()",
                      rolesList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);
%>
