<%--  emxProgramCentralCommonPersonSearchUtil.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  VM3:2011x PRG 8-05-2010

  static const char RCSID[] = $Id: emxProgramCentralAssigneeSummaryFS.jsp.rca 1.17 Wed Oct 22 15:49:13 2008 przemek Experimental przemek $
--%>

<%@ page import = "com.matrixone.apps.domain.*" %>
<%@ page import="matrix.util.StringList" %>
<%@ page import="com.matrixone.apps.domain.util.FrameworkUtil" %>
<%@ page import = "com.matrixone.apps.domain.util.MapList"%>
<%@ page import = "matrix.db.*"%>
<%@ page import = "java.util.*"%>
<%@ page import = "com.matrixone.apps.domain.util.PropertyUtil"%>
<%@ page import =  "com.matrixone.apps.program.ProgramCentralUtil,com.matrixone.apps.program.Task"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>

<%

    String sLanguage = request.getHeader("Accept-Language");
    String objectId = emxGetParameter(request, "objectId");
    String parentOID = emxGetParameter(request, "parentOID");
    String portalCommandName = emxGetParameter(request, "portalCmdName");
    String strSelectedIDs = "";
    if(null != objectId && objectId.contains(",")){
    	strSelectedIDs = objectId;
    }
    String[] strTableRowIds = emxGetParameterValues(request,"emxTableRowId");
    String strTableRowId = "";
    if(strTableRowIds.length==1){
        strTableRowId=strTableRowIds[0];
    }
    
    String strTimeStamp = emxGetParameter(request, "timeStamp");
    i18nNow i18nnow = new i18nNow();
    String strObjectId = "";
    if(strTableRowId != null){
    String[] strID =  strTableRowId.split("\\|");
    if(strID.length > 1)
        strObjectId = strID[1];
    else
    	strObjectId = strID[0];
    }
    //select multiple
                String strTempId = "";
                StringList strPersonIds = new StringList();
                if(null == strObjectId || "".equalsIgnoreCase(strObjectId)){
                for (int i = 0; i < strTableRowIds.length; i++) {
                    strTempId = strTableRowIds[i];
                    StringList strList = FrameworkUtil.split(strTempId,"|");
                    strTempId = (String) strList.get(0);
                    if(null != strTempId){
                        DomainObject dom = DomainObject.newInstance(context,strTempId);
                        if(dom.isKindOf(context, DomainConstants.TYPE_PERSON) == true){
                            strPersonIds.add(strTempId);
                        }
                    }
                 }   
                }
                else{
                    strPersonIds.add(strObjectId);
                }
    //select multiple
    String mode = emxGetParameter(request, "mode");
    String ParentId = "";
    if(mode.contains("|")){
    	StringList strList = FrameworkUtil.split(mode, "|");
    	ParentId = (String)strList.get(2);
    	mode = (String)strList.get(0);
      
    }

            if(null != mode &&mode.equalsIgnoreCase("addTaskAssignee")){
            try{
            	for(int itr = 0; itr < strPersonIds.size(); itr++){
                    strObjectId = (String) strPersonIds.get(itr);
            	DomainObject domObjPerson = DomainObject.newInstance(context, strObjectId);
                DomainObject domObjTask = DomainObject.newInstance(context, objectId);
                DomainRelationship dmoRel = new DomainRelationship();
                dmoRel.connect(context, domObjPerson, DomainConstants.RELATIONSHIP_ASSIGNED_TASKS, domObjTask);
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            %>
            
<%@page import="com.matrixone.apps.common.WorkspaceVault"%>
<%@page import="com.matrixone.apps.program.ProjectSpace"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.program.ProjectRoleVaultAccess"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.program.Risk"%>
<%@page import="matrix.util.MatrixException"%><script language="javascript">
            getTopWindow().window.closeWindow();
            getTopWindow().parent.getWindowOpener().location.href = getTopWindow().parent.getWindowOpener().location.href;
            </Script>
            <%
        }
           
            if(null != mode &&mode.equalsIgnoreCase("addRiskAssignee")){
                try{
                	final String SELECT_ASSIGNED_RISK_MEMBER_ID = "to[" + ProgramCentralConstants.RELATIONSHIP_ASSIGNED_RISK + "].from.id";
        			DomainObject.MULTI_VALUE_LIST.add(SELECT_ASSIGNED_RISK_MEMBER_ID);
                	
        			String[] selectedRiskIds = (String[])session.getAttribute("selectedRiskIds");
                	session.removeAttribute("selectedRiskIds");
                	
                	StringList busSelects = new StringList();
        			busSelects.addElement(SELECT_ASSIGNED_RISK_MEMBER_ID);
        			
        			if(selectedRiskIds != null){
	        			MapList mlAssigneeList = DomainObject.getInfo(context, selectedRiskIds, busSelects);
	        			for(int i=0;i<mlAssigneeList.size();i++){
	        				Map mpAssignee = (Map)mlAssigneeList.get(i);
	        				String strRiskId = selectedRiskIds[i];
	
	        				Object objectRiskAssigneeId = mpAssignee.get(SELECT_ASSIGNED_RISK_MEMBER_ID);
	        				Risk risk = new Risk(strRiskId);
	        				
	        				if(objectRiskAssigneeId != null){
		        				if(objectRiskAssigneeId instanceof StringList){
		        					StringList slAssigneeId = (StringList)objectRiskAssigneeId;
		        					for(int j=0;j<strPersonIds.size();j++){
		        						 String strPersonId = (String) strPersonIds.get(j);
		        						 if(!slAssigneeId.contains(strPersonId)){
		        		                     risk.addAssignees(context, strPersonId);
		        						 }
		        					}
		        				}else{
		        					String strRiskAssignee = (String)objectRiskAssigneeId;
		        					for(int j=0;j<strPersonIds.size();j++){
		       						 String strPersonId = (String) strPersonIds.get(j);
		       						 if(!strRiskAssignee.equals(strPersonId)){
		   		                     	risk.addAssignees(context, strPersonId);
		       						 }
		        					}
		        				}
	        				}else{
	        					for(int j=0;j<strPersonIds.size();j++){
		       						String strPersonId = (String) strPersonIds.get(j);
		   		                 	risk.addAssignees(context, strPersonId);
	        					}
	        				}
	        			}
        			}else{
        				Risk risk = new Risk(objectId);
						for(int itr = 0; itr < strPersonIds.size(); itr++){
							strObjectId = (String) strPersonIds.get(itr);
							DomainObject domObjPerson = DomainObject.newInstance(context, strObjectId);
							risk.addAssignees(context, strObjectId);
						}
                	}
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
        
            if(null != mode &&mode.equalsIgnoreCase("addMultipleTaskAssignee")){
               
                try{
                	//boolean isAsssinged = false;
                	strSelectedIDs = (String)session.getAttribute("selectedIds");
                	session.removeAttribute("selectedIds");
                    String [] strTaskIdArray = strSelectedIDs.split(",");
                    
                	// [ADDED::PRG:RG6:Jan 13, 2011:IR-075151V6R2012 :R211::start]
                	BusinessObjectWithSelectList taskWithSelectList = null;
                	BusinessObjectWithSelect bows = null;
                	
	                	if(null != strTaskIdArray && strTaskIdArray.length > 0){
	                		
	                		DomainObject dObjTask = DomainObject.newInstance(context);
                            DomainObject dObjPerson = DomainObject.newInstance(context);
                            
                            String strAssignStateName = PropertyUtil.getSchemaProperty(context,"policy",DomainConstants.POLICY_PROJECT_TASK,"state_Assign");
                            String strCreateStateName = PropertyUtil.getSchemaProperty(context,"policy",DomainConstants.POLICY_PROJECT_TASK,"state_Create");
                            final String  SELECT_ASSIGNED_PERSONS_ID = "to["+DomainConstants.RELATIONSHIP_ASSIGNED_TASKS+"].from.id";
                            MapList assigneesList = null;
	                		StringList slAssignOperationSelects = new StringList();
	                		slAssignOperationSelects.add(DomainConstants.SELECT_POLICY);
	                		slAssignOperationSelects.add(DomainConstants.SELECT_CURRENT);
	                		slAssignOperationSelects.add(DomainConstants.SELECT_ID);
	                		slAssignOperationSelects.add(SELECT_ASSIGNED_PERSONS_ID);
	                			                			                		
		                	taskWithSelectList = BusinessObject.getSelectBusinessObjectData(context,strTaskIdArray,slAssignOperationSelects);
	                        
		                	for(BusinessObjectWithSelectItr itr= new BusinessObjectWithSelectItr(taskWithSelectList); itr.next();)
		                    {
		                        bows = itr.obj();
		                        String policyName = bows.getSelectData(DomainConstants.SELECT_POLICY);
		                        String strTaskStateName = bows.getSelectData(DomainConstants.SELECT_CURRENT);
		                        String sTaskObjId = bows.getSelectData(DomainConstants.SELECT_ID);
		                        
		                        if(ProgramCentralUtil.isNotNullString(sTaskObjId)){
		                        	dObjTask.setId(sTaskObjId);
		                        	
		                        	StringList slAssingedPersonObjIds = new StringList();
		                            
		                            slAssingedPersonObjIds = bows.getSelectDataList(SELECT_ASSIGNED_PERSONS_ID);
		                            if(null != strPersonIds){
			                            for(int itr1 = 0; itr1 < strPersonIds.size(); itr1++){
			                               String strToAssignPersonObjectId = (String) strPersonIds.get(itr1);
			                               
			                               if(ProgramCentralUtil.isNotNullString(strToAssignPersonObjectId)){
			                            	   
			                          		   if(null == slAssingedPersonObjIds || !slAssingedPersonObjIds.contains(strToAssignPersonObjectId)){
			                          			    dObjPerson.setId(strToAssignPersonObjectId);
                                                                         DomainRelationship dmoRel = new DomainRelationship();
			                          		        dmoRel.connect(context, dObjPerson, DomainConstants.RELATIONSHIP_ASSIGNED_TASKS, dObjTask);
			                          		        
  					                          		        Map mapTaskParam = new HashMap();
				                          		        mapTaskParam.put("taskId",sTaskObjId);
				                          		        mapTaskParam.put("taskState",strTaskStateName);
				                          		        mapTaskParam.put("taskPolicy",policyName);
				                          		        
				                          		        if(Task.isToMoveTaskInToAssignState(context,mapTaskParam)){
				                          		          dObjTask.setState(context,strAssignStateName);  
				                          		      }
			                          		        }
			                          		   }
			                          	   }       
			                            }
		                            }
		                        }
               
	             }
	               // [ADDED::PRG:RG6:Jan 13, 2011:IR-075151V6R2012 :R211::end]
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
            
            if(null != mode &&mode.equalsIgnoreCase("addProjectTemplateOwnerAssignee")){
                %>
                <script language="javascript">
                getTopWindow().window.closeWindow();
                </Script>
                <%
                try{
                    Map mapValues = null;
                    Map methodMap = new HashMap(1);
                    methodMap.put("objectId",strObjectId);
                    methodMap.put("languageStr",sLanguage);
                    methodMap.put("templateId",objectId);
                    methodMap.put("timeStamp",strTimeStamp);
                    String[] methodArgs = JPO.packArgs(methodMap);
                    Boolean retVal  =  (Boolean)JPO.invoke(context,
                                                     "emxProjectTemplate", 
                                                     null,
                                                     "updateOwner",
                                                      methodArgs,
                                                      Boolean.class);
                    
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
            
            if(null != mode && mode.equalsIgnoreCase("addMember"))
            {
                //H1A
            	try
            	{        		
            	ContextUtil.startTransaction(context,true);
            	int personListSize = strPersonIds.size();
            	for(int itr = 0; itr < personListSize; itr++)
            	{
            	 strObjectId = (String) strPersonIds.get(itr);
            	
            	 String strAccess = emxGetParameter(request, strObjectId + "A");
            	 String strRole = emxGetParameter(request, strObjectId + "R");
            	
            	 DomainObject domPerson = DomainObject.newInstance(context,strObjectId);
                 DomainObject domProject = DomainObject.newInstance(context,parentOID);
                
                 DomainRelationship domRel = DomainRelationship.connect(context, domProject, DomainConstants.RELATIONSHIP_MEMBER, domPerson);
            	 domRel.setAttributeValue(context,DomainConstants.ATTRIBUTE_PROJECT_ACCESS,strAccess);
            	 domRel.setAttributeValue(context,DomainConstants.ATTRIBUTE_PROJECT_ROLE,strRole);
            		    }
            	      
                      com.matrixone.apps.program.ProjectSpace project = (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE, DomainConstants.PROGRAM);
                      com.matrixone.apps.common.WorkspaceVault workspaceVault = (com.matrixone.apps.common.WorkspaceVault) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);
                     
                      ProjectSpace projectSpace = new ProjectSpace(parentOID);
                      StringList busSelects = new StringList();
                      busSelects.add(WorkspaceVault.SELECT_NAME);
                      busSelects.add(WorkspaceVault.SELECT_ID);
                      busSelects.add(WorkspaceVault.SELECT_ACCESS_TYPE);
                      busSelects.add(ProgramCentralConstants.SELECT_ATTRIBUTE_PROJECT_ROLE_VAULT_ACCESS);
                      busSelects.add(ProgramCentralConstants.SELECT_ATTRIBUTE_DEFAULT_USER_ACCESS);
                      workspaceVault.setContentRelationshipType(WorkspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);
                      
                      String relationship = DomainConstants.RELATIONSHIP_WORKSPACE_VAULTS;
                      // multi-level expand requires 2 different relationships.
 					  relationship += "," + DomainConstants.RELATIONSHIP_SUB_VAULTS;
                      //Only the Folder objects with inherited access type will be searched down the hierarchy
					  String sWhereClause = "attribute["+DomainConstants.ATTRIBUTE_ACCESS_TYPE+"] == Inherited";
                      // expand from parent
                      MapList Vaultlist = projectSpace.getRelatedObjects(
                              context,        // context.
                              relationship,   // rel filter.
                              DomainConstants.TYPE_WORKSPACE_VAULT,            // type filter.
                              busSelects,  // business object selectables.
                              null,           // relationship selectables.
                              false,          // expand to direction.
                              true,           // expand from direction.
                              (short) 1,  // level
                              sWhereClause,           // object where clause
                              null);          // relationship where clause

                      WorkspaceVault vault = null;
                      String defaultAccess = null;
                      String strAccessXML = null;
                      ProjectRoleVaultAccess vaultAccess = null;
                      MapList inheritedVL = new MapList();
                      String strVaultId = null;
                      
                      for(int i=0; i < Vaultlist.size(); i++)
                         {    
                             Map vaultMap = (Map) Vaultlist.get(i);    
                             defaultAccess = (String) vaultMap.get(ProgramCentralConstants.SELECT_ATTRIBUTE_DEFAULT_USER_ACCESS);
                             strAccessXML = (String) vaultMap.get(ProgramCentralConstants.SELECT_ATTRIBUTE_PROJECT_ROLE_VAULT_ACCESS);
                             String strThisVaultId=(String)vaultMap.get(WorkspaceVault.SELECT_ID);
                             
                             workspaceVault.setId(strThisVaultId);
                             Map accessMap = new HashMap();
                       
                             for(int itr = 0; itr < personListSize; itr++)
                             { 
                            	  strObjectId = (String) strPersonIds.get(itr);
                            	  DomainObject domPerson = DomainObject.newInstance(context,strObjectId);
                            	  String strPerson= domPerson.getInfo(context,DomainConstants.SELECT_NAME);
                            	  String strAccess = emxGetParameter(request, strObjectId + "A");
                                  String strRole = emxGetParameter(request, strObjectId + "R");
                                  String roleVaultAccess = null;
                                  
                                  if(null!=strRole &&  !"".equals(strRole) && !"null".equals(strRole))
                                  {
                                      vaultAccess = new ProjectRoleVaultAccess(context,strAccessXML);
                                      roleVaultAccess = vaultAccess.getAccess(strRole);
                            	  if(null !=roleVaultAccess && !"".equals(roleVaultAccess) && !ProgramCentralConstants.VAULT_ACCESS_NONE.equals(roleVaultAccess))
                {
                            	      accessMap.put(strPerson, roleVaultAccess);
                }
                            	   else
                            		 {
                            		      accessMap.put(strPerson, defaultAccess);
                            	     }
                                  }
                            	   else
                {
                            	     accessMap.put(strPerson, defaultAccess);
                }
                             }
                             
                            MapList vaultList = new MapList();
                            HashMap vaultIDMap = new HashMap();
                            vaultIDMap.put(DomainConstants.SELECT_ID, strThisVaultId);
                            vaultList.add(vaultIDMap);
                             
                            workspaceVault.setUserPermissions(context, accessMap, vaultList);
                         }  
                      ContextUtil.commitTransaction(context);
                  }
           	catch(Exception e)  //[MODIFIED::PRG:RG6:Jan 19, 2011:IR-055750V6R2012:R211:]
           	{
	            ContextUtil.abortTransaction(context);
	            throw new MatrixException(e);
            }
            	   }            	
        %>            
            <script type="text/javascript" language="JavaScript">         
            <%
         // [ADDED::PRG:rg6:Dec 23, 2010:IR-081935V6R2012 :R211::Start]
         // added to remove the problem of search page getting opened again and again from assing selected command from WBS action toolbar    
            if(null != mode &&mode.equalsIgnoreCase("addMultipleTaskAssignee")){
            %>
            //getTopWindow().parent.opener.parent.document.location.href = getTopWindow().parent.opener.parent.document.location.href;
             getTopWindow().parent.opener.parent.refreshSBTable(getTopWindow().parent.opener.parent.configuredTableName);
             getTopWindow().window.close();
            <%	
            }else if("addRiskAssignee".equalsIgnoreCase(mode)){
            	
             	if(!ProgramCentralUtil.is3DSearchEnabled(context)){
            	%>
            	window.getTopWindow().getWindowOpener().parent.location = window.getTopWindow().getWindowOpener().parent.location.href;
             	getTopWindow().close();
             	<%}else{%>
             	var frame = "<%=portalCommandName%>";
	    	  	var topFrame = findFrame(getTopWindow(), frame);
	    	  	if(null == topFrame){
		    		  topFrame = findFrame(getTopWindow(),"PMCProjectRisk");
		    	  	}
	    	  	if(null == topFrame){
		    		  topFrame = findFrame(getTopWindow(),"PMCAssignee");
		    	  	}
	    	  	
	    	 	if(null == topFrame){
	    		  topFrame = findFrame(getTopWindow(),"detailsDisplay");
	    	  	}
			 	
				if (topFrame != null) {
					topFrame.location.href = topFrame.location.href;                        
				}else{
					parent.location.href = parent.location.href;
          		}
                <%}
            }else{
            
            %>	
            getTopWindow().getWindowOpener().refreshSBTable(getTopWindow().getWindowOpener().configuredTableName);
            getTopWindow().closeWindow();
            <%    
            }
         // [END::PRG:rg6:Dec 23, 2010:IR-081935V6R2012 :R211::Start]
            %>
            </script>            	
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%><jsp:include
    page="emxChartInclude.jsp" flush="true" />
