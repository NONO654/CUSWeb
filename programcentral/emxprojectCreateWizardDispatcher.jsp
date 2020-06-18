<%--
  emxprojectCreateWizardDispatcher.jsp

  Wizard dispatcher for events related to creating a project

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
--%>

<%@include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.common.VCDocument" %>

<script language="javascript" type="text/javascript" src="modal.js"></script>
<%
  String nextPage           = "emxProgramCentralProjectCreateDialog.jsp";
  String pageName           = emxGetParameter(request,"pageName");
  String suiteKey           = emxGetParameter(request,"suiteKey");
  String buttonAction       = emxGetParameter(request,"p_button");
  String wizType            = emxGetParameter(request,"wizType");
  String wbsForm            = emxGetParameter(request,"wbsForm");
  String objectId           = emxGetParameter(request,"objectId");
  String fromProgram        = emxGetParameter(request,"fromProgram");
  String templateId         = emxGetParameter(request, "TemplateId");
  String[] selectedIds      = emxGetParameterValues(request, "selectedObject");
  String WizardProjectId    = "";
  String defaultPolicyName  = PropertyUtil.getSchemaProperty(context,"policy_ICDocument");
  String cloneOnlyWBS = emxGetParameter(request, "cloneOnlyWBS");

  /// Added for bug 356387
  String copyExistingProjectType = emxGetParameter(request,"copyExistingProjectType");
  String copyExistingSearchShowSubTypes = emxGetParameter(request,"copyExistingSearchShowSubTypes");
  /// End
  
  if(null == selectedIds || "null".equals(selectedIds) || "".equals(selectedIds)){
    WizardProjectId    = emxGetParameter(request, "WizardProjectId");
  }
  else if(selectedIds.length==1){
    WizardProjectId    = selectedIds[0];
  }
  else{
    WizardProjectId = selectedIds.toString();
  }
  
  String CreateWizardBlank  = emxGetParameter(request, "CreateWizardBlank");
  String fromWBS            = emxGetParameter(request, "fromWBS");
  String businessGoalId     = emxGetParameter(request, "businessGoalId");
  String BusinessUnitId     = emxGetParameter(request, "BusinessUnitId");
  String fromAction         = emxGetParameter(request,"fromAction");
  String fromBG             = emxGetParameter(request, "fromBG");
  String portalMode         = emxGetParameter(request, "portalMode");
  String busId              = null;
  String fromClone          = emxGetParameter(request, "fromClone");
  String jsTreeID           = emxGetParameter(request,"jsTreeID");
  String fileOrFolder       = "File";

  if (fromClone==null || "".equals(fromClone)){
    fromClone = "false";
  }
  
  String copyOptions = "";
  String fromRelatedProjectsSurvey = emxGetParameter(request, "fromRelatedProjectsSurvey");
  String selectedProjectsRelPrjIds = emxGetParameter(request, "selectedProjectsRelPrjIds");
  
  String clonePage = emxGetParameter(request,"clonePage");
  
  String connectRelatedProjects = emxGetParameter(request, "connectRelatedProjects");
  
  String copyOption1  = emxGetParameter(request,"copyOption1");
  copyOptions = copyOption1;
  
  // added for Related Projects
  StringBuffer sbfNextPage = new StringBuffer(64);
  String fromRelatedProjects = emxGetParameter(request,"fromRelatedProjects");

// Master Project Schedule
  String fromSubProjects = emxGetParameter(request,"fromSubProjects");  
  String requiredTaskId = emxGetParameter(request,"requiredTaskId");
  String addType = emxGetParameter(request,"addType");
// End - Master Project Schedule


  if(ProjectSpace.isEPMInstalled(context))
{   
 sbfNextPage = new StringBuffer(256);
}

  if (!buttonAction.equals("Cancel")) {
    if (pageName.equals("StartPage")) {
      if (buttonAction.equals("Next")) {
        if (wizType.equals("Blank")) 
        {
			if(objectId!=null && !"".equals(objectId) && !"null".equals(objectId)) {
				if(objectId.indexOf("|") != -1) {
					objectId = objectId.substring(0,objectId.indexOf("|"));
				}
			}
			// 1st page to 2nd page
            // For the case of Related Projects, objectId will be the parentProjectId
            sbfNextPage.append("emxprojectCreateWizardBlank.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
			sbfNextPage.append("&objectId=");
            sbfNextPage.append(objectId);
            sbfNextPage.append("&fromRelatedProjects=");
            sbfNextPage.append(fromRelatedProjects);
    if(ProjectSpace.isEPMInstalled(context))
{  
            sbfNextPage.append("&objectAction=");
            sbfNextPage.append(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER);
            sbfNextPage.append("&defaultDocumentPolicyName=");
            sbfNextPage.append(com.matrixone.apps.domain.util.XSSUtil.encodeForURL(defaultPolicyName));
            sbfNextPage.append("&showFormat=false&createProjectSpace=true&createBlankProjectSpace=true&vcDocumentType=");
            sbfNextPage.append(fileOrFolder);
}

            nextPage = sbfNextPage.toString();
        } 
        else if (wizType.equals("Clone")) 
        {
            sbfNextPage.append("emxprojectCreateWizardClone.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&fromWBS=");
            sbfNextPage.append(fromWBS);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            sbfNextPage.append("&objectId=");
            sbfNextPage.append(objectId);
            sbfNextPage.append("&fromRelatedProjects=");
            sbfNextPage.append(fromRelatedProjects);
            sbfNextPage.append("&clonePage=true");
            sbfNextPage.append("&cloneOnlyWBS=");
            sbfNextPage.append(cloneOnlyWBS);
            nextPage = sbfNextPage.toString();
        } 
        else if (wizType.equals("Copy"))
        {
            sbfNextPage.append("emxprojectCreateWizardClone.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&fromWBS=");
            sbfNextPage.append(fromWBS);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
        } 
        else if (wizType.equals("Import"))
        {
            sbfNextPage.append("emxprojectCreateWizardImport.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            sbfNextPage.append("&objectId=");
            sbfNextPage.append(objectId);
            sbfNextPage.append("&fromRelatedProjects=");
            sbfNextPage.append(fromRelatedProjects);
            nextPage = sbfNextPage.toString();
        }
        else if (wizType.equals("Template"))
        {
            sbfNextPage.append("emxprojectCreateWizardTemplate.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            sbfNextPage.append("&objectId=");
            sbfNextPage.append(objectId);
            sbfNextPage.append("&fromRelatedProjects=");
            sbfNextPage.append(fromRelatedProjects);
            sbfNextPage.append("&cloneOnlyWBS=");
            sbfNextPage.append(cloneOnlyWBS);
            nextPage = sbfNextPage.toString();
        }
      }
    }
    if (buttonAction.equals("Cancel"))
    {
        sbfNextPage.append("emxProgramCentralProjectCreateDialog.jsp?fromProgram=");
        sbfNextPage.append(fromProgram);
        sbfNextPage.append("&businessGoalId=");
        sbfNextPage.append(businessGoalId);
        sbfNextPage.append("&fromAction=");
        sbfNextPage.append(fromAction);
        sbfNextPage.append("&fromBG=");
        sbfNextPage.append(fromBG);
        sbfNextPage.append("&BusinessUnitId=");
        sbfNextPage.append(BusinessUnitId);
        sbfNextPage.append("&portalMode=");
        sbfNextPage.append(portalMode);
        nextPage = sbfNextPage.toString();
    }
    
    if (pageName.equals("BlankPage"))
    {
      if (buttonAction.equals("Cancel"))
      {
           sbfNextPage.append("emxProgramCentralProjectCreateDialog.jsp?fromProgram=");
           sbfNextPage.append(fromProgram);
           sbfNextPage.append("&businessGoalId=");
           sbfNextPage.append(businessGoalId);
           sbfNextPage.append("&fromAction=");
           sbfNextPage.append(fromAction);
           sbfNextPage.append("&fromBG=");
           sbfNextPage.append(fromBG);
           sbfNextPage.append("&BusinessUnitId=");
           sbfNextPage.append(BusinessUnitId);
           sbfNextPage.append("&portalMode=");
           sbfNextPage.append(portalMode);
           nextPage = sbfNextPage.toString();
      }
      if (buttonAction.equals("Next"))
      {
		  // 2nd to 3rd page
           sbfNextPage.append("emxprojectCreateWizardSummary.jsp?fromProgram=");
           sbfNextPage.append(fromProgram);
           sbfNextPage.append("&CreateWizardBlank=");
           sbfNextPage.append(CreateWizardBlank);
           sbfNextPage.append("&businessGoalId=");
           sbfNextPage.append(businessGoalId);
           sbfNextPage.append("&fromAction=");
           sbfNextPage.append(fromAction);
           sbfNextPage.append("&fromBG=");
           sbfNextPage.append(fromBG);
           sbfNextPage.append("&BusinessUnitId=");
           sbfNextPage.append(BusinessUnitId);
           sbfNextPage.append("&portalMode=");
           sbfNextPage.append(portalMode);
		   sbfNextPage.append("&objectId=");
           sbfNextPage.append(objectId);
           sbfNextPage.append("&fromRelatedProjects=");
           sbfNextPage.append(fromRelatedProjects);
           sbfNextPage.append("&clonePage=");
           sbfNextPage.append(clonePage);
           sbfNextPage.append("&selectedProjectsRelPrjIds=");
           sbfNextPage.append(selectedProjectsRelPrjIds);
           sbfNextPage.append("&copyOptions=");
           sbfNextPage.append(copyOptions);
           sbfNextPage.append("&cloneOnlyWBS=");
           sbfNextPage.append(cloneOnlyWBS);
         if(ProjectSpace.isEPMInstalled(context))
{
           sbfNextPage.append("&objectAction=");
           sbfNextPage.append(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER);
           sbfNextPage.append("&defaultDocumentPolicyName=");
           sbfNextPage.append(com.matrixone.apps.domain.util.XSSUtil.encodeForURL(defaultPolicyName));
           sbfNextPage.append("&showFormat=false&viewOnly=true");
           sbfNextPage.append("&createProjectSpace=true");
           sbfNextPage.append("&vcDocumentType=");
           sbfNextPage.append(fileOrFolder);
}
           nextPage = sbfNextPage.toString();
      } 
      else
      {
        if (wizType.equals("Clone")) {
            sbfNextPage.append("emxprojectCreateWizardClone.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&fromWBS=");
            sbfNextPage.append(fromWBS);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
        }
        else if (wizType.equals("Import")) 
        {
            sbfNextPage.append("emxprojectCreateWizardImportPreProcess.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
        } 
        else if (wizType.equals("Template"))
        {
            sbfNextPage.append("emxprojectCreateWizardSurvey.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
        }
        else{
           sbfNextPage.append("emxProgramCentralProjectCreateDialog.jsp?fromProgram=");
           sbfNextPage.append(fromProgram);
           sbfNextPage.append("&businessGoalId=");
           sbfNextPage.append(businessGoalId);
           sbfNextPage.append("&fromAction=");
           sbfNextPage.append(fromAction);
           sbfNextPage.append("&fromBG=");
           sbfNextPage.append(fromBG);
           sbfNextPage.append("&BusinessUnitId=");
           sbfNextPage.append(BusinessUnitId);
           sbfNextPage.append("&portalMode=");
           sbfNextPage.append(portalMode);
           nextPage = sbfNextPage.toString();
        }   
      }
    }
   if (pageName.equals("WizardClone")) {
      if(buttonAction.equals("Next")){
        //add if to determine whether task or project clone.
        if (wizType.equalsIgnoreCase("Copy")){
              if(WizardProjectId==null||WizardProjectId.equals("")){
                    sbfNextPage.append("emxProgramCentralWBSSummary.jsp?mode=wizard&contentPageIsDialog=false&showWarning=true&objectId=");
                    sbfNextPage.append(templateId);
                    sbfNextPage.append("&businessGoalId=");
                    sbfNextPage.append(businessGoalId);
                    sbfNextPage.append("&fromAction=");
                    sbfNextPage.append(fromAction);
                    sbfNextPage.append("&fromBG=");
                    sbfNextPage.append(fromBG);
                    sbfNextPage.append("&BusinessUnitId=");
                    sbfNextPage.append(BusinessUnitId);
                    sbfNextPage.append("&portalMode=");
                    sbfNextPage.append(portalMode);
                    nextPage = sbfNextPage.toString();
              } else {
                    sbfNextPage.append("emxProgramCentralWBSSummary.jsp?mode=wizard&contentPageIsDialog=false&showWarning=true&objectId=");
                    sbfNextPage.append(WizardProjectId);
                    sbfNextPage.append("&businessGoalId=");
                    sbfNextPage.append(businessGoalId);
                    sbfNextPage.append("&fromAction=");
                    sbfNextPage.append(fromAction);
                    sbfNextPage.append("&fromBG=");
                    sbfNextPage.append(fromBG);
                    sbfNextPage.append("&BusinessUnitId=");
                    sbfNextPage.append(BusinessUnitId);
                    sbfNextPage.append("&portalMode=");
                    sbfNextPage.append(portalMode);
                    nextPage = sbfNextPage.toString();
              }
        }else if(wizType.equalsIgnoreCase("Clone")){
          if((WizardProjectId==null||WizardProjectId.equals("")) && (fromWBS==null || "".equals(fromWBS) || "false".equals(fromWBS)))
          {
               // coming from Related Project -> Clone/Copy
               sbfNextPage.append("emxprojectCreateWizardBlank.jsp?TemplateId=");
               sbfNextPage.append(templateId);
               sbfNextPage.append("&fromProgram=");
               sbfNextPage.append(fromProgram);
               sbfNextPage.append("&businessGoalId=");
               sbfNextPage.append(businessGoalId);
               sbfNextPage.append("&fromAction=");
               sbfNextPage.append(fromAction);
               sbfNextPage.append("&fromBG=");
               sbfNextPage.append(fromBG);
               sbfNextPage.append("&BusinessUnitId=");
               sbfNextPage.append(BusinessUnitId);
               sbfNextPage.append("&portalMode=");
               sbfNextPage.append(portalMode);
               sbfNextPage.append("&objectId=");
               sbfNextPage.append(objectId);
               sbfNextPage.append("&fromRelatedProjects=");
               sbfNextPage.append(fromRelatedProjects);
               sbfNextPage.append("&clonePage=true");
               sbfNextPage.append("&cloneOnlyWBS=");
               sbfNextPage.append(cloneOnlyWBS);
          if(ProjectSpace.isEPMInstalled(context))
{
               sbfNextPage.append("&objectAction=");
               sbfNextPage.append(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER);
               sbfNextPage.append("&defaultDocumentPolicyName=");
               sbfNextPage.append(com.matrixone.apps.domain.util.XSSUtil.encodeForURL(defaultPolicyName));
               sbfNextPage.append("&showFormat=false");
               sbfNextPage.append("&createProjectSpace=true");
               sbfNextPage.append("&vcDocumentType=");
               sbfNextPage.append(fileOrFolder);  
}
               nextPage = sbfNextPage.toString();
          }
          else if((WizardProjectId!=null || !"".equals(WizardProjectId)) && (fromWBS==null || "".equals(fromWBS) || "false".equals(fromWBS))) {
                sbfNextPage.append("emxprojectCreateWizardBlank.jsp?TemplateId=");
                sbfNextPage.append(WizardProjectId);
                sbfNextPage.append("&fromProgram=");
                sbfNextPage.append(fromProgram);
                sbfNextPage.append("&businessGoalId=");
                sbfNextPage.append(businessGoalId);
                sbfNextPage.append("&fromAction=");
                sbfNextPage.append(fromAction);
                sbfNextPage.append("&fromBG=");
                sbfNextPage.append(fromBG);
                sbfNextPage.append("&BusinessUnitId=");
                sbfNextPage.append(BusinessUnitId);
                sbfNextPage.append("&portalMode=");
                sbfNextPage.append(portalMode);
                sbfNextPage.append("&cloneOnlyWBS=");
                sbfNextPage.append(cloneOnlyWBS);
           if(ProjectSpace.isEPMInstalled(context))
{               
                sbfNextPage.append("&objectAction=");
                sbfNextPage.append(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER);
                sbfNextPage.append("&defaultDocumentPolicyName=");
                sbfNextPage.append(com.matrixone.apps.domain.util.XSSUtil.encodeForURL(defaultPolicyName));
                sbfNextPage.append("&showFormat=false");
                sbfNextPage.append("&createProjectSpace=true");
                sbfNextPage.append("&vcDocumentType=");
                sbfNextPage.append(fileOrFolder);  
}
                nextPage = sbfNextPage.toString();
          }
          else if(WizardProjectId==null||WizardProjectId.equals("")){      
                sbfNextPage.append("emxprojectCreateWizardAction.jsp?fromProgram=");
                sbfNextPage.append(fromProgram);
                sbfNextPage.append("&businessGoalId=");
                sbfNextPage.append(businessGoalId);
                sbfNextPage.append("&fromAction=");
                sbfNextPage.append(fromAction);
                sbfNextPage.append("&fromBG=");
                sbfNextPage.append(fromBG);
                sbfNextPage.append("&BusinessUnitId=");
                sbfNextPage.append(BusinessUnitId);
                sbfNextPage.append("&portalMode=");
                sbfNextPage.append(portalMode);
                sbfNextPage.append("&cloneOnlyWBS=");
                sbfNextPage.append(cloneOnlyWBS);
                nextPage = sbfNextPage.toString();
          }
          else
          {
                sbfNextPage.append("emxprojectCreateWizardAction.jsp?TemplateId=");
                sbfNextPage.append(WizardProjectId);
                sbfNextPage.append("&businessGoalId=");
                sbfNextPage.append(businessGoalId);
                sbfNextPage.append("&fromAction=");
                sbfNextPage.append(fromAction);
                sbfNextPage.append("&fromBG=");
                sbfNextPage.append(fromBG);
                sbfNextPage.append("&BusinessUnitId=");
                sbfNextPage.append(BusinessUnitId);
                sbfNextPage.append("&portalMode=");
                sbfNextPage.append(portalMode);          
                sbfNextPage.append("&cloneOnlyWBS=");
                sbfNextPage.append(cloneOnlyWBS);
                nextPage = sbfNextPage.toString();
          }
        }
        else if (wbsForm.equals("false")){
              sbfNextPage.append("emxprojectCreateWizardBlank.jsp?fromProgram=");
              sbfNextPage.append(fromProgram);
              sbfNextPage.append("&businessGoalId=");
              sbfNextPage.append(businessGoalId);
              sbfNextPage.append("&fromAction=");
              sbfNextPage.append(fromAction);
              sbfNextPage.append("&fromBG=");
              sbfNextPage.append(fromBG);
              sbfNextPage.append("&BusinessUnitId=");
              sbfNextPage.append(BusinessUnitId);
              sbfNextPage.append("&portalMode=");
              sbfNextPage.append(portalMode);
          if(ProjectSpace.isEPMInstalled(context))
{
              sbfNextPage.append("&objectAction=");
              sbfNextPage.append(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER);
              sbfNextPage.append("&defaultDocumentPolicyName=");
              sbfNextPage.append(com.matrixone.apps.domain.util.XSSUtil.encodeForURL(defaultPolicyName));
              sbfNextPage.append("&showFormat=false");
              sbfNextPage.append("&createProjectSpace=true");
              sbfNextPage.append("&vcDocumentType=");
              sbfNextPage.append(fileOrFolder);	  
}
              nextPage = sbfNextPage.toString();
        } else {
              sbfNextPage.append("emxprojectCreateWizardAction.jsp?fromProgram=");
              sbfNextPage.append(fromProgram);
              sbfNextPage.append("&businessGoalId=");
              sbfNextPage.append(businessGoalId);
              sbfNextPage.append("&fromAction=");
              sbfNextPage.append(fromAction);
              sbfNextPage.append("&fromBG=");
              sbfNextPage.append(fromBG);
              sbfNextPage.append("&BusinessUnitId=");
              sbfNextPage.append(BusinessUnitId);
              sbfNextPage.append("&portalMode=");
              sbfNextPage.append(portalMode);
              nextPage = sbfNextPage.toString();
        }
      }
      if (buttonAction.equals("Back"))  {
            sbfNextPage.append("emxProgramCentralProjectCreateDialog.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
      }
    }
    if (pageName.equals("WizardImport")) {
      if(buttonAction.equals("Next")) {
            sbfNextPage.append("emxprojectCreateWizardImportPreProcess.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
      }
      if (buttonAction.equals("Back"))  {
            sbfNextPage.append("emxProgramCentralProjectCreateDialog.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
      }
    }

    if (pageName.equals("WizardImportPreProcess")) {
      if(buttonAction.equals("Next")) {
            sbfNextPage.append("emxprojectCreateWizardBlank.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
        if(ProjectSpace.isEPMInstalled(context))
{       
            sbfNextPage.append("&objectAction=");
            sbfNextPage.append(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER);
            sbfNextPage.append("&defaultDocumentPolicyName=");
            sbfNextPage.append(com.matrixone.apps.domain.util.XSSUtil.encodeForURL(defaultPolicyName));
            sbfNextPage.append("&showFormat=false");
            sbfNextPage.append("&createProjectSpace=true");
            sbfNextPage.append("&vcDocumentType=");
            sbfNextPage.append(fileOrFolder);   
}
            nextPage = sbfNextPage.toString();
      }
      if (buttonAction.equals("Back"))  {
            sbfNextPage.append("emxprojectCreateWizardImport.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
      }
    }

    if (pageName.equals("WizardImportError")) {
      if(buttonAction.equals("Next")) {
            sbfNextPage.append("emxprojectCreateWizardImportPreProcess.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
      } else {
            sbfNextPage.append("emxprojectCreateWizardImport.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
      }
    }

    if (pageName.equals("WizardTemplate")) {
      if(buttonAction.equals("Next")) {
            sbfNextPage.append("emxprojectCreateWizardSurvey.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            sbfNextPage.append("&objectId=");
            sbfNextPage.append(objectId);
            sbfNextPage.append("&fromRelatedProjects=");
            sbfNextPage.append(fromRelatedProjects);
            nextPage = sbfNextPage.toString();
      }
    }
    if(pageName.equals("WizardWBS")){
      if(buttonAction.equals("Next")){
            sbfNextPage.append("emxprojectCreateWizardAction.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
      }
      if(buttonAction.equals("Back")){
    	  sbfNextPage.append("emxprojectCreateWizardClone.jsp?fromProgram=");
          sbfNextPage.append(fromProgram);
          sbfNextPage.append("&fromWBS=");
          sbfNextPage.append(fromWBS);
          sbfNextPage.append("&businessGoalId=");
          sbfNextPage.append(businessGoalId);
          sbfNextPage.append("&fromAction=");
          sbfNextPage.append(fromAction);
          sbfNextPage.append("&fromBG=");
          sbfNextPage.append(fromBG);
          sbfNextPage.append("&BusinessUnitId=");
          sbfNextPage.append(BusinessUnitId);
          sbfNextPage.append("&portalMode=");
          sbfNextPage.append(portalMode);
          nextPage = sbfNextPage.toString();
      }
    }
    if (pageName.equals("WizardSurvey")) {
      if(buttonAction.equals("Next")) {
        if("false".equals(wbsForm)) {
            sbfNextPage.append("emxprojectCreateWizardBlank.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            sbfNextPage.append("&objectId=");
            sbfNextPage.append(objectId);
            sbfNextPage.append("&fromRelatedProjects=");
            sbfNextPage.append(fromRelatedProjects);
      if(ProjectSpace.isEPMInstalled(context))
{          
            sbfNextPage.append("&objectAction=");
            sbfNextPage.append(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER);
            sbfNextPage.append("&defaultDocumentPolicyName=");
            sbfNextPage.append(com.matrixone.apps.domain.util.XSSUtil.encodeForURL(defaultPolicyName));
            sbfNextPage.append("&showFormat=false");
            sbfNextPage.append("&createProjectSpace=true");
            sbfNextPage.append("&vcDocumentType=");
            sbfNextPage.append(fileOrFolder);  
}
            nextPage = sbfNextPage.toString();
        }
        else {
            sbfNextPage.append("emxprojectCreateWizardAction.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            sbfNextPage.append("&parentProjectId=");
            sbfNextPage.append(objectId);
            sbfNextPage.append("&fromRelatedProjects=");
            sbfNextPage.append(fromRelatedProjects);
            sbfNextPage.append("&fromRelatedProjectsSurvey=");
            sbfNextPage.append(fromRelatedProjectsSurvey);
            sbfNextPage.append("&copyOptions=");
            sbfNextPage.append(copyOptions);
            nextPage = sbfNextPage.toString();
        }
      } else {
            sbfNextPage.append("emxprojectCreateWizardTemplate.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            nextPage = sbfNextPage.toString();
      }
    }
    if (pageName.equals("WizardSummary")) {
      if(buttonAction.equals("Next")) {
        if (wizType.equals("Import")){
            sbfNextPage.append("emxprojectCreateWizardImportAction.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&CreateWizardBlank=");
            sbfNextPage.append(CreateWizardBlank);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            sbfNextPage.append("&parentProjectId=");
            sbfNextPage.append(objectId);
            sbfNextPage.append("&fromRelatedProjects=");
            sbfNextPage.append(fromRelatedProjects);
            nextPage = sbfNextPage.toString();
        }
        else{
            sbfNextPage.append("emxprojectCreateWizardAction.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            sbfNextPage.append("&parentProjectId=");
            sbfNextPage.append(objectId);
            sbfNextPage.append("&fromRelatedProjects=");
            sbfNextPage.append(fromRelatedProjects);
            sbfNextPage.append("&selectedProjectsRelPrjIds=");
            sbfNextPage.append(selectedProjectsRelPrjIds);
            sbfNextPage.append("&connectRelatedProjects=");
            sbfNextPage.append(connectRelatedProjects);
            nextPage = sbfNextPage.toString();
        }    
      } else {
            sbfNextPage.append("emxprojectCreateWizardBlank.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&CreateWizardBlank=");
            sbfNextPage.append(CreateWizardBlank);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
      if(ProjectSpace.isEPMInstalled(context))
{
            sbfNextPage.append("&objectAction=");
            sbfNextPage.append(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER);
            sbfNextPage.append("&defaultDocumentPolicyName=");
            sbfNextPage.append(com.matrixone.apps.domain.util.XSSUtil.encodeForURL(defaultPolicyName));
            sbfNextPage.append("&showFormat=false");
            sbfNextPage.append("&createProjectSpace=true");
            sbfNextPage.append("&vcDocumentType=");
            sbfNextPage.append(fileOrFolder);   
}
            nextPage = sbfNextPage.toString();

      }
    }
   
// Master Project Schedule

   if (pageName.equals("fromAddExistingRelProject") || pageName.equals("fromAddExistingSubProject")) {
      if(wizType.equalsIgnoreCase("AddExistingRelProject") || wizType.equalsIgnoreCase("AddExistingSubtaskProject"))
      {
			if(objectId!=null && !"".equals(objectId) && !"null".equals(objectId)) {
				if(objectId.indexOf("|") != -1) {
					objectId = objectId.substring(0,objectId.indexOf("|"));
				}
			}  
            sbfNextPage.append("emxprojectCreateWizardAction.jsp?fromProgram=");
            sbfNextPage.append(fromProgram); 
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            sbfNextPage.append("&parentProjectId=");
            sbfNextPage.append(objectId);
            sbfNextPage.append("&fromRelatedProjects=");
            sbfNextPage.append(fromRelatedProjects);  

// Master Project Schedule
            sbfNextPage.append("&fromSubProjects=");
            sbfNextPage.append(fromSubProjects);  
            sbfNextPage.append("&requiredTaskId=");
            sbfNextPage.append(requiredTaskId);  
            sbfNextPage.append("&addType=");
            sbfNextPage.append(addType);  
// End - Master Project Schedule

            nextPage = sbfNextPage.toString();
      }
      else
      {
            sbfNextPage.append("emxprojectCreateWizardClone.jsp?fromProgram=");
            sbfNextPage.append(fromProgram);
            sbfNextPage.append("&fromWBS=");
            sbfNextPage.append(fromWBS);
            sbfNextPage.append("&businessGoalId=");
            sbfNextPage.append(businessGoalId);
            sbfNextPage.append("&fromAction=");
            sbfNextPage.append(fromAction);
            sbfNextPage.append("&fromBG=");
            sbfNextPage.append(fromBG);
            sbfNextPage.append("&BusinessUnitId=");
            sbfNextPage.append(BusinessUnitId);
            sbfNextPage.append("&portalMode=");
            sbfNextPage.append(portalMode);
            sbfNextPage.append("&objectId=");
            sbfNextPage.append(objectId);
            sbfNextPage.append("&fromRelatedProjects=");
            sbfNextPage.append(fromRelatedProjects);
            sbfNextPage.append("&pageName=");
            sbfNextPage.append(pageName);

// Master Project Schedule
            sbfNextPage.append("&fromSubProjects=");
            sbfNextPage.append(fromSubProjects);
            sbfNextPage.append("&requiredTaskId=");
            sbfNextPage.append(requiredTaskId);
            sbfNextPage.append("&addType=");
            sbfNextPage.append(addType);
// End - Master Project Schedule

      nextPage = sbfNextPage.toString();
      }
    }    
  }
  nextPage += "&suiteKey="+suiteKey;
  
	  ///ADDED for bug 356387
  	  nextPage += "&copyExistingProjectType="+XSSUtil.encodeForURL(context,copyExistingProjectType);
  	  nextPage += "&copyExistingSearchShowSubTypes="+XSSUtil.encodeForURL(context,copyExistingSearchShowSubTypes);
	  ///END

%>
<%--XSSOK--%> 
    <jsp:forward page="<%=nextPage%>" />   
