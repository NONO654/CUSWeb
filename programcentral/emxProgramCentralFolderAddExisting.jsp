<%--  emxProgramCentralFolderAddExisting.jsp  - This page displays choices for searching Persons

  Copyright (c) 1998-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program.
--%>

<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.common.UserTask"%>
<head>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
</head>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><html>
<head>
<title></title>
</head>
<body class="white">
<!-- content begins here -->
<%
            com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject
                    .newInstance(context, DomainConstants.TYPE_TASK,
                            DomainConstants.PROGRAM);

            com.matrixone.apps.common.WorkspaceVault workspaceVault = (com.matrixone.apps.common.WorkspaceVault) DomainObject
                    .newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);

            String expandType = EnoviaResourceBundle.getProperty(context, "eServiceProgramCentral.IndentedTable.DeliverableTypes");
            String expandRel  = EnoviaResourceBundle.getProperty(context, "eServiceProgramCentral.IndentedTable.DeliverableRelationships");
            String direction  = EnoviaResourceBundle.getProperty(context,"eServiceProgramCentral.IndentedTable.DeliverableDirection");
            String folderId = null;
            String strUIType = emxGetParameter(request, "uiType");
            String objectId = emxGetParameter(request, "objectId"); //Added 15-July-2010:rg6:IR-063840V6R2011x
            String[] emxTableRowId = emxGetParameterValues(request,"emxTableRowId");
			String mode =   emxGetParameter(request,"mode");
            String relName = workspaceVault.RELATIONSHIP_REFERENCE_DOCUMENT;
            DomainObject dmObj = DomainObject.newInstance(context,objectId);
            StringList list = new StringList();
            list.add(DomainConstants.TYPE_WORKSPACE_VAULT);
            list.add(ProgramCentralConstants.SELECT_KINDOF_TASKMANAGEMENT);
            list.add(DomainConstants.SELECT_TYPE);
            list.add(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);
            list.add("to[Project Access Key].from.from[Project Access List].to.type.kindof[" + DomainObject.TYPE_PROJECT_TEMPLATE+ "]");
            
                  Map<String,String> objectInfo = dmObj.getInfo(context,list);
            String isTaskType = objectInfo.get(ProgramCentralConstants.SELECT_KINDOF_TASKMANAGEMENT);
            String isFolderType  = objectInfo.get(DomainConstants.TYPE_WORKSPACE_VAULT);
            String selectedObjectType = objectInfo.get(DomainConstants.SELECT_TYPE);
            String isProjectTemplate = objectInfo.get(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);
            String isParentKindOFProjectTemplate = objectInfo.get("to[Project Access Key].from.from[Project Access List].to.type.kindof[" + DomainObject.TYPE_PROJECT_TEMPLATE+ "]");
            boolean isRootFolderOrTask = "true".equalsIgnoreCase(isFolderType) || "true".equalsIgnoreCase(isTaskType) || Assessment.TYPE_ASSESSMENT.equalsIgnoreCase(selectedObjectType) || ProgramCentralConstants.TYPE_RISK.equalsIgnoreCase(selectedObjectType) || RiskManagement.TYPE_OPPORTUNITY.equalsIgnoreCase(selectedObjectType) || DomainConstants.TYPE_BUSINESS_GOAL.equalsIgnoreCase(selectedObjectType); 
            if(DomainConstants.TYPE_WORKSPACE_VAULT.equalsIgnoreCase(selectedObjectType)){
    			String parentFolderId = UserTask.getProjectId(context, objectId);
    			DomainObject parentDomainObject = DomainObject.newInstance(context, parentFolderId);
    			StringList list1 = new StringList();
    			list1.add(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);

    			Map<String, String> parentObjectInfo = parentDomainObject.getInfo(context, list1);
    			 isProjectTemplate = parentObjectInfo.get(ProgramCentralConstants.SELECT_KINDOF_PROJECT_TEMPLATE);
            }
            
            //if(!"true".equalsIgnoreCase(strIsWkVault) || "table".equals(strUIType))
           	boolean isStructureBrowser = emxTableRowId != null && emxTableRowId.length > 0;
            if(!isStructureBrowser && isRootFolderOrTask)	
            {
            	 folderId = objectId;    //Modified 15-July-2010:rg6:IR-063840V6R2011x
            }
            else
            {
        	//Added 29-June-2010:rg6:IR-054194
            	if(emxTableRowId != null && emxTableRowId.length > 0) {   //End 29-June-2010:rg6:IR-054194     
            		//Added 6-July-2010:rg6:IR-058924
            		String strLanguage = context.getSession().getLanguage();
            		 Map map =request.getParameterMap();
            		    String [] selctedObjList = (String [])map.get("emxTableRowId");
            		    if(selctedObjList != null) {
            		        if(selctedObjList.length > 1){
            		            String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
            		      			  "emxProgramCentral.Common.CannotPerformAction", strLanguage);
            		               %>
            		             
            		         <script language="JavaScript" type="text/javascript">
            		                                               alert("<%=sErrMsg%>");
            		                                               window.closeWindow();
            		                                           </script>
            		               <%return;     
            		       }
            		   
            		    }
            		//End 6-July-2010:rg6:IR-058924
            	 for(int k=0; k<emxTableRowId.length; k++)
            	 {
            		 //Added:7-Apr-2011:NR2:IR-097451V6R2012
            		 String[] emxTableRowIdArr = emxTableRowId[k].split("\\|");
            		 folderId = emxTableRowIdArr[1];

            		 if(ProgramCentralUtil.isNotNullString(folderId) && !"TRUE".equalsIgnoreCase(isTaskType)){
            			 DomainObject dObj =  DomainObject.newInstance(context,folderId);
            			 if(!dObj.isKindOf(context,DomainConstants.TYPE_WORKSPACE_VAULT)){
                             String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                       			  "emxProgramCentral.Common.SelectFoldersOnly", strLanguage);
                             %>
                             <script language="JavaScript" type="text/javascript">
                                   alert("<%=sErrMsg%>");
                                    window.closeWindow();
                             </script>
                              <% return;
            			 }
            			//Added:PRG:I16:22-Aug-2011:R212:IR-090418V6R2012x Start
            			 else{
                             String sErrConMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                       			  "emxProgramCentral.Folder.NoFromConnectAccess", strLanguage);                            
                             String strUserName = context.getUser();
                             boolean bAddStatus = true;
                             boolean bAddRemoveStatus = true;
                             bAddStatus = PMCWorkspaceVault.hasAccessOnWorkspaceVault(context, folderId, ProgramCentralConstants.VAULT_ACCESS_ADD, strUserName);                             
                             if(!bAddStatus)
                            	   bAddRemoveStatus = PMCWorkspaceVault.hasAccessOnWorkspaceVault(context, folderId, ProgramCentralConstants.VAULT_ACCESS_ADD_REMOVE, strUserName);            				 
                             if(!(bAddStatus || bAddRemoveStatus)){
                                 %>
                                     <script language="JavaScript" type="text/javascript">
                                        alert("<%=sErrConMsg%>");
                                        window.closeWindow();
                                      </script>  <% 
                                      return;
                             }   
                         }
            			//Added:PRG:I16:22-Aug-2011:R212:IR-090418V6R2012x End
            		 }
            		//End:7-Apr-2011:NR2:IR-097451V6R2012
            	 }
            	}else{  //Added 29-June-2010:rg6:IR-054194
            		//Added 15-July-2010:rg6:IR-063840V6R2011x
            		  // As content page for folder click is changed from flat table to structure browser modified
                      // for passing the object id.
            		DomainObject dObjParent =  DomainObject.newInstance(context);
            		  if(objectId != null && ! "".equalsIgnoreCase(objectId)){
            		      dObjParent.setId(objectId);
            		      if(! dObjParent.isKindOf(context,DomainConstants.TYPE_WORKSPACE_VAULT) && !dObjParent.isKindOf(context,DomainConstants.TYPE_QUALITY)){
            		String strLanguage = context.getSession().getLanguage();
            	    //display error message if operation is create 
                    String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
              			  "emxProgramCentral.Common.SelectFoldersOnly", strLanguage);
    %>
                    <script language="JavaScript" type="text/javascript">
                         alert("<%=sErrMsg%>");
                         window.closeWindow();
                    </script>
     <%
                     return;     
            		      }else{
            		    	  folderId = objectId;
            		      } 
            		    //End Modification 15-July-2010:rg6:IR-063840V6R2011x
            		  }

            	}
            	//End 29-June-2010:rg6:IR-054194
            }

         //Added 29-June-2010:rg6:IR-054295   
                        
          if(folderId!=null && !"".equalsIgnoreCase(folderId)){
        	  dmObj = DomainObject.newInstance(context, folderId);
                // if controlled folder is in release state can't perform create new subfolder 
                // or delete the subfolder inside the controlled folder or parent folder itself  
                StringList selectableList = new StringList(2);
                selectableList.add(DomainConstants.SELECT_TYPE);
                selectableList.add(DomainConstants.SELECT_CURRENT);
                Map infoMap = dmObj.getInfo(context, selectableList);
                String type = (String)infoMap.get(DomainConstants.SELECT_TYPE);
                String current = (String)infoMap.get(DomainConstants.SELECT_CURRENT);
                
                if(type.equalsIgnoreCase(DomainConstants.TYPE_CONTROLLED_FOLDER)){
                   String strControlledFolderCurrState = current;
                   String strLanguage = context.getSession().getLanguage();
                   if("release".equalsIgnoreCase(strControlledFolderCurrState)){
                       //display error message if operation is create 
                       String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                 			  "emxProgramCentral.Common.InvalidOperation", strLanguage);
                                 %>
                           <script language="JavaScript" type="text/javascript">
                               alert("<%=sErrMsg%>");
                               window.closeWindow();
                           </script>
                                 <%return;     
                       
                   }
                }
               if(type.equalsIgnoreCase(DomainConstants.TYPE_PROJECT_SPACE)) {            	  
            	   		String strLanguage = context.getSession().getLanguage();
            	        String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                			 		 "emxProgramCentral.Common.SelectFoldersOnly", strLanguage);
                     	 %>
                      	<script language="JavaScript" type="text/javascript">
                            alert("<%=sErrMsg%>");
                             window.closeWindow();
                      	</script>
                        <%   
               }  			
          }
          //End 29-June-2010:rg6:IR-054295
            // Added:4-May-09:nzf:R207:PRG:Bug:373852
            boolean isKinfOfTypeTask = dmObj.isKindOf(context,DomainConstants.TYPE_TASK_MANAGEMENT);
            // End:R207:PRG:Bug:373852
            String objectType = dmObj.getType(context);
            String topParentHolderId = "";

            StringList busSelects = new StringList(1);
            busSelects.add(dmObj.SELECT_ID);
            //PRG:RG6:R213:Mql Injection:Static Mql:14-Oct-2011
            String subtypes = MqlUtil.mqlCommand(context, "print type \""
                    + dmObj.TYPE_TASK_MANAGEMENT
                    + "\" select derivative dump |");
            StringList taskTypesList = null;

            if (null != subtypes && !"null".equals(subtypes)) {
                taskTypesList = FrameworkUtil.split(subtypes, "|");
            }

            if (taskTypesList != null && taskTypesList.contains(objectType)) {
                task.setId(folderId);
                Map projectMap = task.getProject(context, busSelects);
                // get projectId
                topParentHolderId = (String) projectMap.get(task.SELECT_ID);
            }

            if (objectType.equals(workspaceVault.TYPE_WORKSPACE_VAULT)) {
                // Obtain projectId or projectTemplateId
                workspaceVault.setId(folderId);
                workspaceVault
                        .setContentRelationshipType(workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);
                Map topVaultMap = workspaceVault.getTopLevelVault(context,
                        busSelects);
                String topVaultId = (String) topVaultMap
                        .get(workspaceVault.SELECT_ID);
                // reset workspaceVault for top level vault
                workspaceVault.setId(topVaultId);
                topParentHolderId = workspaceVault.getInfo(context,
                        workspaceVault.SELECT_VAULT_HOLDER_ID);
            }

            String myParentId = "";
            String symbolicType = "";

            // Must set content relstionship to correct value
            
            // Modified:4-May-09:nzf:R207:PRG:Bug:373852
             if (isKinfOfTypeTask==true) {
            	if(!"referenceDocument".equalsIgnoreCase(mode)){
            		relName=workspaceVault.RELATIONSHIP_TASK_DELIVERABLE;
            	}
                workspaceVault.setContentRelationshipType(workspaceVault.RELATIONSHIP_TASK_DELIVERABLE);                
            }else{// End:R207:PRG:Bug:373852
            	relName=workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2;
                workspaceVault.setContentRelationshipType(workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);  
            }
            
            //used to find policies

            //StringList allDocTypes = new StringList();
            StringList docTypes = new StringList();
            //allDocTypes = workspaceVault.getContentBusinessTypes(context, true);
            docTypes = workspaceVault.getContentBusinessTypes(context, false);
            String docTypesStr = "";
            StringBuffer arrTypeArrayContent = new StringBuffer();
            StringList levelPattern = new StringList();
            Iterator documentListItr = docTypes.iterator();

            //Check for VPLM Tasks to remove unwanted types
            String vplmTask = PropertyUtil
                    .getSchemaProperty(
                            context,
                            com.matrixone.apps.domain.DomainSymbolicConstants.SYMBOLIC_type_VPLMTask);
            boolean isVPLMTask = false;

            if (myParentId != null && !"".equals(myParentId)) {
                DomainObject domnObj = new DomainObject(myParentId);
                String parentOjectType = domnObj.getInfo(context,
                        task.SELECT_TYPE);
                if (parentOjectType.equals(vplmTask))
                    isVPLMTask = true;
            }

            String excludeTypeList = "";
            if (isVPLMTask)
                excludeTypeList = EnoviaResourceBundle.getProperty(context, "emxProgramCentral.VPLMMapping.DeliverableExcludeTypes");
            excludeTypeList += ",";

            if("true".equalsIgnoreCase(isProjectTemplate) || "true".equalsIgnoreCase(isParentKindOFProjectTemplate)){
            	levelPattern.add(FrameworkUtil.getAliasForAdmin(context, "type",com.matrixone.apps.common.CommonDocument.TYPE_DOCUMENTS, true));
            } else {
            while (documentListItr.hasNext()) {
				String documentType = (String) documentListItr.next();
                BusinessType baseType = new BusinessType(documentType, context
                        .getVault());
                baseType.open(context);
                String sParentType = baseType.getParent(context);
                baseType.close(context);
                if (sParentType == null || "".equals(sParentType)
                        || !docTypes.contains(sParentType)) {
                    // **Start**
                    if (ProjectSpace.isEPMInstalled(context)) {
                        if (!(documentType
                                .equals(DomainConstants.TYPE_IC_DOCUMENT) || documentType
                                .equals(DomainConstants.TYPE_IC_FOLDER))) {
                            arrTypeArrayContent.append(FrameworkUtil
                                    .getAliasForAdmin(context, "type",
                                            documentType, true));
                            levelPattern.add(FrameworkUtil
                                    .getAliasForAdmin(context, "type",
                                            documentType, true));
                            docTypesStr += documentType;
                        }
                        if (documentListItr.hasNext()) {
                            if (!(documentType
                                    .equals(DomainConstants.TYPE_IC_DOCUMENT) || documentType
                                    .equals(DomainConstants.TYPE_IC_FOLDER))) {
                               // docTypesStr += ",";
                            }
                        }
                    }
                    // **End**
                    else {
                        String appendSymbolicType = FrameworkUtil
                                .getAliasForAdmin(context, "type",
                                        documentType, true);
                        String checkSymbolicType = appendSymbolicType;
                        // arrTypeArrayContent.append(FrameworkUtil.getAliasForAdmin(context,
                        // "type", documentType, true));
                        if (!isVPLMTask
                                || excludeTypeList.indexOf(appendSymbolicType) < 0) {
                            arrTypeArrayContent.append(checkSymbolicType);
                            levelPattern.add(checkSymbolicType);

                            docTypesStr += documentType;
                            if (documentListItr.hasNext()) {
                                docTypesStr += ",";
                            }
                        }
                    }
                }
            }
            }
            symbolicType = arrTypeArrayContent.toString();
            String strSymbolic = "";
            strSymbolic = com.matrixone.apps.domain.util.FrameworkUtil.join(levelPattern,",");
            
            //code added to solve refresh problem at Template task deliverable & assessment attachments page.
            if(ProgramCentralConstants.TYPE_QUALITY.equalsIgnoreCase(selectedObjectType)||"true".equalsIgnoreCase(isParentKindOFProjectTemplate) || "Assessment".equalsIgnoreCase((String)objectInfo.get(DomainConstants.SELECT_TYPE)) || DomainConstants.TYPE_BUSINESS_GOAL.equalsIgnoreCase(selectedObjectType) || ProgramCentralConstants.TYPE_RISK.equalsIgnoreCase(selectedObjectType) || RiskManagement.TYPE_OPPORTUNITY.equalsIgnoreCase(selectedObjectType)){
            	session.setAttribute("needFullPageRefresh", "true");
            }
            expandRel = XSSUtil.encodeForHTMLAttribute(context,expandRel);
            expandType = XSSUtil.encodeForHTMLAttribute(context,expandType);
            direction = XSSUtil.encodeForHTMLAttribute(context,direction);
            strSymbolic = XSSUtil.encodeForHTMLAttribute(context,strSymbolic);
            folderId = XSSUtil.encodeForHTMLAttribute(context,folderId);
            topParentHolderId = XSSUtil.encodeForHTMLAttribute(context,topParentHolderId);
            
            StringBuilder sbURL = new StringBuilder("../common/emxFullSearch.jsp?formInclusionList=PRG_FOLDER_NAME,PRG_FOLDER_PROJECTSPACE_NAME");
            sbURL.append("&table=PMCGeneralSearchResults&selection=multiple");
            sbURL.append("&relationship=");
            sbURL.append(expandRel);
            sbURL.append("&type=");
            sbURL.append(expandType);
            sbURL.append("&direction=");
            sbURL.append(direction);
            sbURL.append("&field=");
            sbURL.append("TYPES="+strSymbolic+":IS_VERSION_OBJECT!=True");
            sbURL.append("&cancelLabel=emxFramework.Common.Close");
            sbURL.append("&submitURL=../programcentral/emxProgramCentralAutonomySearchResult.jsp?appProcessPage=emxProgramCentraFolderUtil.jsp&actionMode=addExistingDocument&appDir=programcentral&relName="+relName);
            sbURL.append("&myParentId=");
            sbURL.append(folderId);
            sbURL.append("&topParentHolderId=");
            sbURL.append(topParentHolderId);
            
            String searchURL = sbURL.toString();
%>
        
</body>
<script language="javascript" type="text/javaScript">
var strUrl = "<%=searchURL%>";  
  showModalDialog(strUrl);
</script>

</html>
