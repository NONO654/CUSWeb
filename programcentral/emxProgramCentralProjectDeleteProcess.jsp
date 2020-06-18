<%--  emxProgramCentralProjectDeleteProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralProjectDeleteProcess.jsp.rca 1.20 Wed Oct 22 15:50:29 2008 przemek Experimental przemek $";
--%>

<%@page import="com.dassault_systemes.enovia.tskv2.ProjectSequence"%>
<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%> 

<%
  com.matrixone.apps.program.ProjectSpace project =
    (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context,
    DomainConstants.TYPE_PROJECT_SPACE, DomainConstants.PROGRAM);
  com.matrixone.apps.program.ProjectConcept projectConcept =
    (com.matrixone.apps.program.ProjectConcept) DomainObject.newInstance(context,
    DomainConstants.TYPE_PROJECT_CONCEPT, DomainConstants.PROGRAM);
  com.matrixone.apps.program.Task task =
    (com.matrixone.apps.program.Task) DomainObject.newInstance(context,
    DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
  com.matrixone.apps.program.Quality quality =
      (com.matrixone.apps.program.Quality) DomainObject.newInstance(context,
      DomainConstants.TYPE_QUALITY, "PROGRAM");

   String relProj = emxGetParameter(request,"fromRelatedProjects");
  String msg = ProgramCentralConstants.EMPTY_STRING;;  
   String action = "remove";
   String language = context.getSession().getLanguage();
   String propertyFile = "emxProgramCentralStringResource"; 
  String i18nStr =ProgramCentralConstants.EMPTY_STRING;; 
   i18nNow i18nnow = new i18nNow();  
   String strInvokedFrom   = emxGetParameter(request,"invokedFrom");

  String[] allProjectsToDelete = emxGetParameterValues(request,"emxTableRowId");
 
  if(allProjectsToDelete != null){
  if(strInvokedFrom != null && "StructureBrowser".equals(strInvokedFrom)) {
	  for (int i=0;i<allProjectsToDelete.length;i++)
	  {
	      Map mpRow = ProgramCentralUtil.parseTableRowId(context,allProjectsToDelete[i]);
	      allProjectsToDelete[i] = (String) mpRow.get("objectId");
	  }
  }
  }else{
	  allProjectsToDelete = (String[])session.getAttribute("selectedProjectId");
	  session.removeAttribute("selectedProjectId");
  }

  if(allProjectsToDelete == null)
  {
	  allProjectsToDelete = emxGetParameterValues(request,"selectedIds");
  } 
  //bug 331975 - should not allow projects to be deleted
  //if their folders/subfolders are not tempy.
  //when merged into the mainstream code, this
  //should be placed in a method in a bean 
  //Added for the Bug No:331975 1 01/24/2008 Start
  ArrayList allProjectList = new ArrayList(Arrays.asList(allProjectsToDelete)); 
  String projectNames = ProgramCentralConstants.EMPTY_STRING;  
  boolean bCanDelete = true;
  String projectState = ProgramCentralConstants.EMPTY_STRING;
  StringList objectSelects = new StringList(2);
  objectSelects.add(DomainConstants.SELECT_ID);
  objectSelects.add(ProgramCentralConstants.SELECT_PHYSICALID);
  objectSelects.add(DomainConstants.SELECT_CURRENT);
  MapList infoList = DomainObject.getInfo(context, allProjectsToDelete, objectSelects);
  StringList cancelProjectList = new StringList();
  for(int i=0; i<infoList.size(); i++){
		Map projectInfo = (Map)infoList.get(i);
		String current = (String)projectInfo.get(DomainConstants.SELECT_CURRENT);
		if("Cancel".equalsIgnoreCase(current)){
			cancelProjectList.add((String)projectInfo.get(ProgramCentralConstants.SELECT_PHYSICALID));
			allProjectList.remove((String)projectInfo.get(DomainConstants.SELECT_ID));
		}
  }

  if(cancelProjectList.size() > 0){
		for(int i=0; i<cancelProjectList.size(); i++){
			try
			{
				project.setId((String)cancelProjectList.get(i));
				ContextUtil.startTransaction(context, true);
				ContextUtil.pushContext(context);
				task.setId(project.getId());
				
				
				StringList busSelect = new StringList();
				busSelect.add(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);
				busSelect.add(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_TASK);
				busSelect.add(DomainObject.SELECT_ID);
				
					
				MapList parentList = task.getParentInfo(context, 1, busSelect);

				((BusinessObject)project).remove(context);

				Map tmpMap;
				for(int parentIndex=0; parentIndex<parentList.size(); parentIndex++)
				{
					tmpMap = (Map) parentList.get(parentIndex);
					
					
					
					
					task.setId((String)tmpMap.get(DomainObject.SELECT_ID));
					
					StringList deletedObjIdList = new StringList();
					deletedObjIdList.add((String)cancelProjectList.get(i));
					
					String palId = (String)tmpMap.get(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_TASK);
       					if (palId == null || palId.isEmpty()) {
       						palId = (String)tmpMap.get(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);
       					}
					ProjectSequence ps = new ProjectSequence(context, palId);
        				ps.unAssignSequence(context, deletedObjIdList);				
       				
					
					task.rollupAndSave(context);

					com.matrixone.apps.common.Task.calculatePercentComplete(context, task.getId());
				}
				ContextUtil.commitTransaction(context);
				ContextUtil.popContext(context);
			}catch(Exception ex) {
				ex.printStackTrace();
				throw ex;
			}
		}
	}
  String[] projects = null;
  if(allProjectList.size() > 0){
  projects = new String[allProjectList.size()];
  allProjectList.toArray(projects);
  }
  if(projects != null && projects.length > 0)
  {
        String relProjectVault = PropertyUtil.getSchemaProperty(context,
                 DomainObject.SYMBOLIC_relationship_ProjectVaults);
        String relSubVault = PropertyUtil.getSchemaProperty(context,
                 DomainObject.SYMBOLIC_relationship_SubVaults);
        String relrelVaultedDocRev2 = PropertyUtil.getSchemaProperty(context,
                 DomainObject.SYMBOLIC_relationship_VaultedDocumentsRev2);
                 
        String typeProjectVault = PropertyUtil.getSchemaProperty(context,
                 DomainObject.SYMBOLIC_type_ProjectVault);
                 
        StringList typeFolderList = ProgramCentralUtil.getSubTypesList(context, DomainConstants.TYPE_WORKSPACE_VAULT);
                 
        String typeDocument = PropertyUtil.getSchemaProperty(context,
                 DomainObject.SYMBOLIC_type_Document);                 
  
        Pattern relPattern = new Pattern(relProjectVault);
        relPattern.addPattern(relSubVault);
        relPattern.addPattern(relrelVaultedDocRev2);
        
        Pattern typePattern = new Pattern(typeProjectVault);
        typePattern.addPattern(typeDocument);
        
        StringList busSels = new StringList(2);
        busSels.add(DomainObject.SELECT_ID);
        busSels.add(DomainObject.SELECT_TYPE);              

        for (int i=0; i < projects.length; i++) {
            String objectId = projects[i];
            DomainObject dmObj = DomainObject.newInstance(context, objectId);
            // check whether the project connected to any content
            MapList contentList= dmObj.getRelatedObjects(
                            context,        // matrix context
                            relPattern.getPattern(),   // relationship pattern
                            "*",//typePattern.getPattern(),            // object pattern
                            busSels,  // object selects
                            null,           // relationship selects
                            false,           // to direction
                            true,          // from direction
                            (short) 0,  // recursion level
                            null,           // object where clause
                            null);          // relationship where clause

            if(contentList != null && contentList.size() > 0)
            {
                for(int j=0; j < contentList.size(); j++)
                {
                    Map contentMap = (Map) contentList.get(j);
                    String contentType = (String) contentMap.get(DomainObject.SELECT_TYPE);
                    
                    //if it is not a folder, it is a content
                    //if(!contentType.equals(typeProjectVault))
                    if(!typeFolderList.contains(contentType))
                    {                    
                        bCanDelete = false;
                        projectNames += (String)dmObj.getInfo(context, DomainObject.SELECT_NAME) + ",";
                        break;
                    }
                }
            }        
        }        
   }

  if(!bCanDelete)
   {
     projectNames = projectNames.substring(0, projectNames.length()-1);   
%>  
    <script language="Javascript">
      alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Delete.ProjectWithFolderContents.ErrorMessage</framework:i18nScript>\n\n<%=XSSUtil.encodeForJavaScript(context,projectNames)%>");
      parent.document.location.href=parent.document.location.href;
      //parent.window.location.reload();
    </script>  
<% 
   }
   else
   {
  //Added for the Bug No:331975 1 01/24/2008 End
  String programID = emxGetParameter(request, "ProgramID");
  StringList projectList = new StringList();
  StringList projectIdList = new StringList();
  MapList taskList = new MapList();
  //get the risks
  MapList riskList = new MapList();
  //get the project quality factors
  MapList QualityList = new MapList();
  MapList relatedList = new MapList();

  String policyName          = PropertyUtil.getSchemaProperty(context,"policy_Quality");
  String controlledStateName = PropertyUtil.getSchemaProperty(context,"policy",policyName,"state_Controlled");

  boolean fromProgram = false;
  boolean projectAccess = true;
  if(programID != null && !"".equals(programID) && !"null".equals(programID)){
     fromProgram = true;
  }
  
  if ( projects != null && projects.length > 0) {
	  
  	StringList busSelects = new StringList(1);
  	busSelects.add(task.SELECT_CURRENT);
  	busSelects.add(task.SELECT_NAME);
  	//build the where clause to filter Quality factors
  	String busWhere = null;
  	busWhere = "current==\"" + controlledStateName + "\"";

  	policyName = project.getDefaultPolicy(context);
  	String createStateName = PropertyUtil.getSchemaProperty(context,"policy",policyName,"state_Create");
  	policyName = projectConcept.getDefaultPolicy(context);
  	String conceptStateName = PropertyUtil.getSchemaProperty(context, "policy", policyName, "state_Concept");

  	boolean deleteProj;
  	String typeName = null;
  	// get the number of project
  	int numProjects = projects.length;

  	// need to check it to avoid zero using JS.
  	for (int i=0; numProjects>i; i++) {
  		
		deleteProj = true;
		String strProjObjId = "";
		if(projects[i].indexOf("|") != -1 ){
			strProjObjId = projects[i].substring(projects[i].indexOf("|")+1);
		}
		else {
			strProjObjId = projects[i];
		}
		project.setId(strProjObjId);
		

		
		StringList selectableList = new StringList();
		selectableList.add(DomainObject.SELECT_TYPE);
		selectableList.add(DomainObject.SELECT_OWNER);
		selectableList.add(DomainObject.SELECT_CURRENT);
		selectableList.add(DomainObject.SELECT_NAME);
		selectableList.add(ProgramCentralConstants.SELECT_PHYSICALID);
		
		Map projectInfo = project.getInfo(context, selectableList);
		
		projectState = (String)projectInfo.get(DomainObject.SELECT_CURRENT);
		String projectOwner = (String)projectInfo.get(DomainObject.SELECT_OWNER);
		String projectName = (String)projectInfo.get(DomainObject.SELECT_NAME);
		String projectPhysicalId = (String)projectInfo.get(ProgramCentralConstants.SELECT_PHYSICALID);

		if(createStateName.equals(projectState) || conceptStateName.equals(projectState)) { 

			// Master Project Schedule
			//taskList = project.getTasks(context, 0, busSelects, null, false);
			taskList = com.matrixone.apps.common.Task.getTasks(context, project, 0, busSelects, null, false, false);
			// End - Master Project Schedule

			if(!taskList.isEmpty()) {  
				Iterator taskItr = taskList.iterator();
				while(taskItr.hasNext()) {
					Map theTask = (Map) taskItr.next();
					if(!createStateName.equals((String) theTask.get(task.SELECT_CURRENT))) {
						projectList.add(projectName);
						projectIdList.add(strProjObjId);
						deleteProj = false;
						break;
					}
				}
			}
			// check for the approved efforts against the project
			boolean isApprovedEffortExists = project.isApprovedEffortExistsForProject(context,strProjObjId);
			if(isApprovedEffortExists)
			{
				if(!projectList.contains(projectName))
				{
					projectList.add(projectName);
				}
				projectIdList.add(strProjObjId);
				deleteProj = false;
			}
			// check for Quality Items in controlled state
			QualityList = quality.getQualityItems(context, project, busSelects, busWhere);
			if (QualityList.size() > 0) { 
				if(!projectList.contains(projectName)){
					projectList.add(projectName);
				}
				projectIdList.add(strProjObjId);
				deleteProj = false;
				break;
			}
			// check for risks in complete state
			busWhere = Risk.SELECT_CURRENT + "==\"Complete\"";
			typeName = project.getInfo(context, project.SELECT_TYPE);
			riskList = Risk.getRisks(context, project, busSelects, null, busWhere);
			if (riskList.size() > 0) { 
				if(!projectList.contains(projectName)){
					projectList.add(projectName);
				}
				projectIdList.add(strProjObjId);
				deleteProj = false;
			}
			//check for related projects 
			project.setId(strProjObjId);
			String relRelatedProject = PropertyUtil.getSchemaProperty(context, DomainObject.SYMBOLIC_relationship_RelatedProjects);
			relatedList = project.getRelatedObjects(context,relRelatedProject,"*",busSelects,null,true,true,(short)1,null, null);

			if(relProj != null && !("".equals(relProj)) && !("null".equals(relProj))){
				if (relatedList.size() > 1){ 
					deleteProj = false;
					if(!projectList.contains(projectName)){
						projectList.add(projectName);
					}
					projectIdList.add(strProjObjId);
				}
			} else {
				if (relatedList.size() > 0){ 
					deleteProj = false;
					if(!projectList.contains(projectName)){
						projectList.add(projectName);
					}
					projectIdList.add(strProjObjId);
				}
			}
		} else { 
			deleteProj = false;
			if(!projectList.contains(projectName)){
				projectList.add(projectName);
			}
			projectIdList.add(strProjObjId);
		}

		if(deleteProj == true) { 

			// Master Project Schedule
			// End - Master Project Schedule
			try
			{
				ContextUtil.startTransaction(context, true);
				//End:22-Feb-2010:s2e:R209 PRG:IR-033479V6R2011
				// Master Project Schedule

				task.setId(project.getId());
				
				
				StringList busSelect = new StringList();
				busSelect.add(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);
				busSelect.add(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_TASK);
				busSelect.add(DomainObject.SELECT_ID);
				busSelect.add(ProgramCentralConstants.SELECT_PHYSICALID);
				
				
				MapList parentList = task.getParentInfo(context, 1, busSelect);

				//Modified:31-Aug-2010:s2e:R210 PRG: IR-057706V6R2011x
				// [modified::PRG:RG6:Jan 21, 2011:IR-089218V6R2012 :R211::]     ContextUtil.pushContext(context);    

				((BusinessObject)project).remove(context);

				// [ADDED::PRG:RG6:Jan 21, 2011:IR-089218V6R2012 :R211::]      ContextUtil.popContext(context);
				//End:22-Feb-2010:s2e:R209 PRG:IR-057706V6R2011x

				Map tmpMap;
				for(int parentIndex=0; parentIndex<parentList.size(); parentIndex++)
				{
					tmpMap = (Map) parentList.get(parentIndex);
							
					task.setId((String)tmpMap.get(DomainObject.SELECT_ID));
					
					StringList deletedObjIdList = new StringList();
					deletedObjIdList.add(projectPhysicalId);
					
					String palId = (String)tmpMap.get(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_TASK);
       					if (palId == null || palId.isEmpty()) {
       						palId = (String)tmpMap.get(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);
       					}
					ProjectSequence ps = new ProjectSequence(context, palId);
         				ps.unAssignSequence(context, deletedObjIdList);				
       			
					task.rollupAndSave(context);

					com.matrixone.apps.common.Task.calculatePercentComplete(context, task.getId());
				}

				ContextUtil.commitTransaction(context);
			} catch(Exception ex) {
				
				ContextUtil.abortTransaction(context);
				System.err.println(ex);
				// End - Master Project Schedule

				if(relProj != null && !("".equals(relProj)) && !("null".equals(relProj))){
					action = "error";
					i18nStr = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
							"emxProgramCentral.Common.NotAuthorizedToDelete", language);
					msg = i18nStr;
				} else {
					projectAccess = false;
				}
			}         
		}
  	}
  }

%>

<% 
if(relProj != null && !"null".equals(relProj) && !"".equals(relProj)) {

	if(!projectList.isEmpty()) {
		action = "error";    
		if (relatedList.isEmpty())
		{
			i18nStr = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
					"emxProgramCentral.Project.UnableToDeleteProjectsfromRelated", language);
		}
		else if(!relatedList.isEmpty())
		{
			i18nStr = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
					"emxProgramCentral.Project.UnableToDeleteRelatedProjects", language);
		}
		msg = i18nStr;
	} // end of if not projectList.isEmpty()

	//clear the output buffer
	out.clear(); 
	response.setContentType("text/xml");
	%>

	<mxRoot>
	<action><xss:encodeForHTML><![CDATA[<%= action %>]]></xss:encodeForHTML></action>
	<message><xss:encodeForHTML><![CDATA[<%= msg %>]]></xss:encodeForHTML></message>
	</mxRoot>

	<%	} // end of if loop for relproj not equal to null
		else { 
	%>
			<html>
			  <script language="javascript" type="text/javaScript">//<![CDATA[
				<!-- hide JavaScript from non-JavaScript browsers
			<%  
			  if(!projectList.isEmpty()) {
				if (relatedList.isEmpty())
				{
			%>
				  alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.UnableToDeleteProjects</framework:i18nScript>\n\n<%=XSSUtil.encodeForJavaScript(context,projectList.toString())%>");
			<%      
				} 
				else if(!relatedList.isEmpty())
				{
			%>    
				  alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.UnableToDeleteRelatedProjectsForTable</framework:i18nScript>\n\n<%=XSSUtil.encodeForJavaScript(context,projectList.toString())%>");
			<%      
				}
			 }    
			 if(!projectAccess){%>
				  alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.NotAuthorizedToDelete</framework:i18nScript>");
			 <%}
			   
			%>
		    // Deleted:PRG:RG6:R212:26-Aug-2011:IR-126505V6R2012x:object details tree is not generated from 2012 onwards
				   parent.document.location.href=parent.document.location.href;

				// Stop hiding here -->//]]>
			</script>
			</html>
	<% 
		} // end of else
   }	
 %>
