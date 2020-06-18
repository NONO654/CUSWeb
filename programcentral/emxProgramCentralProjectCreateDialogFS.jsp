<%--  emxProgramCentralProjectCreateDialogFS.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  Reviewed for Level III compliance by KIP 5/9/2002
  
  static const char RCSID[] = $Id: emxProgramCentralProjectCreateDialogFS.jsp.rca 1.23 Tue Oct 28 22:59:42 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<%
  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String suiteKey    = emxGetParameter(request,"suiteKey");
  String initSource  = emxGetParameter(request,"initSource");
  String objectId    = emxGetParameter(request,"objectId");
  String fromProgram = emxGetParameter(request, "fromProgram");
  String fromWBS     = emxGetParameter(request, "fromWBS");
  String fromAction  = emxGetParameter(request,"fromAction");
  String fromBG      = emxGetParameter(request,"fromBG");
  String portalMode  = emxGetParameter(request,"portalMode");
  String Directory   = appDirectory;
  String isChangeProject = emxGetParameter(request, "isChangeProject");
//<!--Modified for the Bug No:348092 Start --> 
  String HelpMarker = "emxhelpprojectselectsource";
  //<!--Modified for the Bug No:348092 End -->
   //Following condition is added for accessing project from program categories.
  if(null==fromProgram) {
	  	  fromProgram=objectId;
	    }
  if(null!=objectId && !"null".equalsIgnoreCase(objectId)&& !"".equalsIgnoreCase(objectId))
  {
      DomainObject dObj = DomainObject.newInstance(context,objectId);
      if(dObj.isKindOf(context,DomainConstants.TYPE_PROGRAM))
      {
    	  objectId=null;
      }
  }
  // Coming from Create New Related Project command ?
  // In this case, the objectId above is the parent project id 
  // to which the newly created project will be a related project
  String fromRelatedProjects = emxGetParameter(request,"fromRelatedProjects");
  String insertNewProject = emxGetParameter(request, "InsertNewProject");
  String insertExistingProject = emxGetParameter(request, "InsertExistingProject");
  
  // Master Project Schedule
  String fromSubProjects = emxGetParameter(request,"fromSubProjects");
  String addType = emxGetParameter(request,"addType");
  // End - Master Project Schedule 

  String wizardType = emxGetParameter(request,"wizardType");
  String wizardPage = emxGetParameter(request,"wizardPage");

  String[] arrTableRowIds = emxGetParameterValues(request,"emxTableRowId");
  StringBuffer sbObjectIds = new StringBuffer(64);
  int numProjects = 0;
  
String requiredTaskId = null;
  // If the user selects project(s) and clicks on 'Insert New', or 'Insert Existing'
  // pass all the selected project ids
  if("true".equals(fromRelatedProjects)){
      if("true".equalsIgnoreCase(insertNewProject) || "true".equalsIgnoreCase(insertExistingProject)){
          if(arrTableRowIds != null){
              numProjects = arrTableRowIds.length;
              for(int i=0; i<numProjects;i++){
                  String temp = arrTableRowIds[i];
                  String requiredObjectId = temp.substring(temp.indexOf("|")+1,temp.lastIndexOf("|"));
                  sbObjectIds.append(requiredObjectId);

                  if(i != numProjects-1){ // add seperator till the last element but not after it
                      sbObjectIds.append("|");
                  }    
              }
              objectId = sbObjectIds.toString();
          }      
      }
  }    
  
// Master Project Schedule
if("true".equals(fromSubProjects)){
    %>
    <script language="JavaScript">
        var confirmMsg = null
        
        // Modified for bug 358843
        //if(getWindowOpener().emxEditableTable.checkDataModified()){
        if (getWindowOpener().parent.emxEditableTable.checkDataModified()){
            confirmMsg = confirm("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.DiscardChanges</framework:i18nScript>");
            if(!confirmMsg){
                getTopWindow().window.closeWindow();
            }
        } 
    </script>
    <%
    if(arrTableRowIds != null){
        numProjects = arrTableRowIds.length;
        for(int i=0; i<numProjects;i++){
            String temp = arrTableRowIds[i];

            requiredTaskId = temp.substring(temp.indexOf("|")+1,temp.lastIndexOf("|"));
            sbObjectIds.append(requiredTaskId);
                  if(i != numProjects-1){ // add seperator till the last element but not after it
                      sbObjectIds.append("|");
                  }
          }
          requiredTaskId = sbObjectIds.toString();
          StringList values = FrameworkUtil.split(requiredTaskId, "|");
          for (int i=0;i<values.size();i++ ) {
              int strLength =  ((String) values.get(i)).trim().length();
              if (strLength == 0 && "Sibling".equals(addType)) {
                  %>
                <script language="JavaScript">
                alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.CannotInsertOnRoot</framework:i18nScript>");
                getTopWindow().window.closeWindow();
                </script>
<%
              }
          }
      }
  }

// End - Master Project Schedule 
  framesetObject fs = new framesetObject();
  fs.setDirectory(Directory);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if (initSource == null){
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

  if(null == fromAction || "".equals(fromAction)){
    fromAction = "false";
  }

  String businessGoalId    = emxGetParameter(request,"businessGoalId"); 

  // Specify URL to come in middle of frameset
  StringBuffer sbContentURL = new StringBuffer(100);
  sbContentURL.append("emxProgramCentralProjectCreateDialog.jsp");
  sbContentURL.append("?suiteKey=");
  sbContentURL.append(suiteKey);
  sbContentURL.append("&initSource=");
  sbContentURL.append(initSource);
  sbContentURL.append("&jsTreeID=");
  sbContentURL.append(jsTreeID);
  sbContentURL.append("&objectId=");
  sbContentURL.append(objectId);
  sbContentURL.append("&fromWBS=");
  sbContentURL.append(fromWBS);
  sbContentURL.append("&businessGoalId=");
  sbContentURL.append(businessGoalId);
  sbContentURL.append("&fromAction=");
  sbContentURL.append(fromAction);
  sbContentURL.append("&fromBG=");
  sbContentURL.append(fromBG);
  sbContentURL.append("&portalMode=");
  sbContentURL.append(portalMode);
  sbContentURL.append("&fromRelatedProjects=");
  sbContentURL.append(fromRelatedProjects);
  sbContentURL.append("&wizardType=");
  sbContentURL.append(wizardType);
  sbContentURL.append("&wizardPage=");
  sbContentURL.append(wizardPage);
  
// Master Project Schedule
  sbContentURL.append("&fromSubProjects=");
  sbContentURL.append(fromSubProjects);
  sbContentURL.append("&requiredTaskId=");
  sbContentURL.append(requiredTaskId);
  sbContentURL.append("&addType=");
  sbContentURL.append(addType);
  sbContentURL.append("&isChangeProject=");
  sbContentURL.append(isChangeProject);
// End - Master Project Schedule

  String contentURL = sbContentURL.toString();
  
  // Page Heading & Help Page
  String PageHeading = "emxProgramCentral.Common.CreateProjectWizard";
  if(objectId == null || objectId.equals("null") || objectId.equals("")) {
      contentURL += "&wbsForm=false&fromProgram=" + fromProgram;
  } else {
    if(!"true".equalsIgnoreCase(fromBG) && (!"true".equalsIgnoreCase(fromRelatedProjects) && !"true".equalsIgnoreCase(fromSubProjects))){
      PageHeading = "emxProgramCentral.Common.Import";
      contentURL += "&wbsForm=true";
    }else{
      contentURL += "&wbsForm=false";
    }
    if("true".equalsIgnoreCase(fromRelatedProjects) && "AddExistingRelatedProject".equalsIgnoreCase(wizardType))
    {
      PageHeading = "emxProgramCentral.Common.SelectProjects";
      HelpMarker = "emxhelpselectprojects";
    }    
  }

// Master Project Schedule
    if("true".equalsIgnoreCase(fromSubProjects) && "AddExistingSubProject".equalsIgnoreCase(wizardType))
    {
      PageHeading = "emxProgramCentral.Common.SelectProjects";
    }    
// End - Master Project Schedule
  
  if (fromWBS != null && fromWBS.trim().equals("true"))
    HelpMarker  = "emxhelpwbsaddcopy2";
  

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

/*
  3) vs: you might need contextual actions
  fs.createHeaderLink(String displayString, String href, String roleList,
                      boolean popup, boolean isJavascript, String iconImage, int WindowSize)
*/

  String nextStr   = "emxProgramCentral.Button.Next";
  String backStr   = "emxProgramCentral.Button.Back";
  String cancelStr = "emxProgramCentral.Button.Cancel";
  String doneStr = "emxProgramCentral.Button.Done";

//[MODIFIED::Jan 22, 2011:S4E:version:IR-055432V6R2012 ::Start] 
  if("AddExistingSubProject".equalsIgnoreCase(wizardType) && "fromAddExistingSubProject".equalsIgnoreCase(wizardPage))
  {
	  fs.createFooterLink(doneStr, "validateForm()", "role_GlobalUser",
              false, true, "common/images/buttonDialogDone.gif", 0);  
  }
  else{	  
  fs.createFooterLink(nextStr, "validateForm()", "role_GlobalUser",
                      false, true, "common/images/buttonDialogNext.gif", 0);
  }
//[MODIFIED::Jan 22, 2011:S4E:version:IR-055432V6R2012 ::End] 

  fs.createFooterLink(cancelStr, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "common/images/buttonDialogCancel.gif", 0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
%>
