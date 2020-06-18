<%--  emxProgramCentralAssigneeSummary.jsp

  Views the assignees of the given task

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

--%>

<%@page import="com.dassault_systemes.enovia.tskv2.ProjectSequence"%>
<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxPaginationInclude.inc" %>
<%@include file="../emxJSValidation.inc"%>
<%@page import="com.dassault_systemes.enovia.e6wv2.foundation.jaxb.Dataobject"%>


<script language="javascript">
    function submitClose() {
        if(parent.window.getWindowOpener().parent.frames[1] != null){
          parent.window.getWindowOpener().parent.frames[1].location.href = parent.window.getWindowOpener().parent.frames[1].location;
        }
        parent.window.closeWindow();
    }

  function applyChanges() {
    var objForm = document.editForm;

    for (var i = 0; i < objForm.elements.length; i++) {
        if ( objForm.elements[i].name.substring(0,3) == "PA~")
        {
          if (((!isNumeric(objForm.elements[i].value))|| (objForm.elements[i].value < 1 ) || (objForm.elements[i].value > 100 )))
          {
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.PercentAllocationError</framework:i18nScript>");
            objForm.elements[i].focus();
            return;
          }
        }
    }

    objForm.submit();
  }

  function toggleBackground( checkboxElement, onColor, offColor ) {

    if ( checkboxElement.checked == true ) {
        checkboxElement.style.backgroundColor = onColor;
    } else {
        checkboxElement.style.backgroundColor = offColor;
    }
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%!
    private static final String BG_COLOR_BLUE = "#00CCCC";
    private static final String BG_COLOR_RED  = "#FF6666";
%>
<%
    com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, "PROGRAM");

    String objectId = emxGetParameter( request, "objectId" );
    String taskIds  = emxGetParameter( request, "taskIds" );
    String printerFriendly = emxGetParameter(request,"PrinterFriendly");
    if(printerFriendly == null || printerFriendly.equals("") || printerFriendly.equals("null"))
    {
        printerFriendly = "false";
    }

	String sLanguage = request.getHeader("Accept-Language");

    String sAttributeProjectRole      = PropertyUtil.getSchemaProperty( context, "attribute_ProjectRole" );
    String sAttributeTaskWBS          = PropertyUtil.getSchemaProperty( context, "attribute_TaskWBS" );
    String sRelationshipSubTask       = PropertyUtil.getSchemaProperty( context, "relationship_Subtask" );
    String sRelationshipAssignedTasks = PropertyUtil.getSchemaProperty( context, "relationship_AssignedTasks" );
    String sAttributePercentAllocation = PropertyUtil.getSchemaProperty( context, "attribute_PercentAllocation" );
    String sTypeTaskManagement        = PropertyUtil.getSchemaProperty( context, "type_TaskManagement");

    StringList sTaskAssigneesIds = new StringList();
    StringList sTaskAssigneesNames = new StringList();
    StringList sTaskAssigneesPercentCompletes = new StringList();
    StringList sTaskAssigneesAssignedTaskIds = new StringList();
    String sTaskStartDate;
    String sTaskEndDate;
    String sTaskRole;
    String sTaskOwner;
    String sTaskAssignees;
    String checked;
    String onColor;
    String offColor;
    String newURL;
    String sTempTaskAssigneesName = "";
    String sTempTaskAssigneesIds = "";
    String sTempTaskAssigneesPercentCompletes = "";
    String sTempTaskAssigneesAssignedTaskIds = "";
    MapList mlRoleMembers = new MapList();
    StringList slTaskIds = new StringList();
    String treeUrl = "";

    // Step 1 - Get selects tasks and get project roles
    //StringTokenizer stTasks = new StringTokenizer( taskIds, "," );

    //String[] saTaskIds = new String[ stTasks.countTokens() ];
    //for ( int i=0; i<saTaskIds.length; i++ ) {
    //    saTaskIds[i] = stTasks.nextToken();
    //}

    StringList idList = FrameworkUtil.split(taskIds,",");
    String[] saTaskIds = new String[idList.size()];
    idList.copyInto(saTaskIds);
    //String[] saTaskIds = (String[])idList.toArray();
    if(objectId==null || objectId.equals(""))
    {
        task = new Task((String)saTaskIds[0]);
       StringList strList = new StringList(1);
       strList.add(task.SELECT_ID);
       objectId = (String) task.getProject(context, strList).get(task.SELECT_ID);
    }
    StringList taskSelects = new StringList ( 9 );
    taskSelects.add( "id" );
    taskSelects.add( "physicalid" );
    taskSelects.add( "name" );
    taskSelects.add( "owner" );
    taskSelects.add( "current" );
    taskSelects.add(task.SELECT_TASK_ESTIMATED_START_DATE);
    taskSelects.add(task.SELECT_TASK_ESTIMATED_FINISH_DATE);
    taskSelects.add( "attribute[" + sAttributeProjectRole + "]" );
    taskSelects.add( "to[" + sRelationshipAssignedTasks + "].businessobject.name" );
    taskSelects.add( "to[" + sRelationshipAssignedTasks + "].businessobject.id" );
    taskSelects.add( "from[" + sRelationshipSubTask + "]" );
    taskSelects.add( "from[" + sRelationshipSubTask + "].businessobject.id" );
	taskSelects.add( "locker" );
	taskSelects.add( "context.user" );
	taskSelects.add( DomainConstants.ATTRIBUTE_PROJECT_ROLE );
    String sPercentComplete = "to[" + sRelationshipAssignedTasks + "].attribute[" + sAttributePercentAllocation + "].value";
	taskSelects.add( sPercentComplete );
    String sAssignedTaskId = "to[" + sRelationshipAssignedTasks + "].id";
	taskSelects.add( sAssignedTaskId );
    DomainObject.MULTI_VALUE_LIST.add("to[" + sRelationshipAssignedTasks + "].businessobject.name");
    DomainObject.MULTI_VALUE_LIST.add("to[" + sRelationshipAssignedTasks + "].businessobject.id");
    DomainObject.MULTI_VALUE_LIST.add(sPercentComplete);
    DomainObject.MULTI_VALUE_LIST.add(sAssignedTaskId);

    StringList taskRelSelects = new StringList( 2 );
    taskRelSelects.add( "id[connection]" );
    taskRelSelects.add( "attribute[" + sAttributeTaskWBS + "]" );

    MapList mlTasks = FrameworkUtil.toMapList( BusinessObject.getSelectBusinessObjectData( context, saTaskIds, taskSelects ),DomainObject.MULTI_VALUE_LIST );

    MapList mlAllTasks = new MapList();
    MapList tempMapList = new MapList();
    Integer integerType                     = null;

    // Step 2 - Get all project members and assigned roles
    StringList busSelects = new StringList( 5 );
    busSelects.add( com.matrixone.apps.common.Person.SELECT_ID );
    busSelects.add( com.matrixone.apps.common.Person.SELECT_NAME );
    busSelects.add( com.matrixone.apps.common.Person.SELECT_FIRST_NAME );
    busSelects.add( com.matrixone.apps.common.Person.SELECT_LAST_NAME );

    StringList relSelects = new StringList( 2 );
    relSelects.add( "attribute[" + sAttributeProjectRole + "]" );
    relSelects.add( "id[connection]" );

    //[ADDED:PA4:23-Sept-2011:IR-127329V6R2013]
    MapList wbsMemberList = new MapList();
    ProjectSpace project = null;
    StringList objectSelects = new StringList(3);
	objectSelects.add(ProgramCentralConstants.SELECT_IS_PROJECT_SPACE);
	objectSelects.add(ProgramCentralConstants.SELECT_IS_PROJECT_CONCEPT);
	objectSelects.add(ProgramCentralConstants.SELECT_IS_TASK_MANAGEMENT);
	objectSelects.add(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_TASK);
	objectSelects.add(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);

	MapList projectInfoMapList= DomainObject.getInfo(context,new String[]{objectId}, objectSelects);
	String palId = "";

	if(projectInfoMapList !=null && projectInfoMapList.size()>0){
		Map<String,String> projectMap = (Map)projectInfoMapList.get(0);
		String isKindOfProjectSpace   = projectMap.get(ProgramCentralConstants.SELECT_IS_PROJECT_SPACE);
		String isKindOfProjectConcept = projectMap.get(ProgramCentralConstants.SELECT_IS_PROJECT_CONCEPT);
		String isKindOfTaskManagement = projectMap.get(ProgramCentralConstants.SELECT_IS_TASK_MANAGEMENT);
		
		palId = (String) projectMap.get(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_TASK);
		if (palId == null || palId.isEmpty()) {
			palId = (String) projectMap.get(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);
		}
		
		if("TRUE".equalsIgnoreCase(isKindOfProjectSpace) || "TRUE".equalsIgnoreCase(isKindOfProjectConcept))
	    	project = new com.matrixone.apps.program.ProjectSpace(objectId);

	    if("TRUE".equalsIgnoreCase(isKindOfTaskManagement)){
	        Task _task = new Task(objectId);
	        project = _task.getProject(context);
	    }
	    if(project != null)
	        wbsMemberList = project.getMembers( context, busSelects, relSelects, null, null );
	}

	
	Map<String,Dataobject> seqData = new HashMap<>();
	try{
		ProjectSequence ps = new ProjectSequence(context,palId);
		seqData = ps.getSequenceData(context);
	}
	catch(Exception e){
		e.printStackTrace();
		throw e;
	}
	

	for ( int i=0; i<mlTasks.size(); i++ ) {
        Map mTask = (Map) mlTasks.get( i );
        mlAllTasks.add ( mTask );
        String hassub = (String) mTask.get( "from[" + sRelationshipSubTask + "]" );
        if ( ( (String) mTask.get( "from[" + sRelationshipSubTask + "]" ) ).equalsIgnoreCase("true") ) {
            DomainObject doTask = DomainObject.newInstance( context, (String) mTask.get( "id" ) );       
            tempMapList = doTask.getRelatedObjects( context, sRelationshipSubTask, sTypeTaskManagement, taskSelects, taskRelSelects, false, true, (short)0, null, null );
             for(int k = 0, j= tempMapList.size(); k<j; k++) {
				Map taskMap = (Map) tempMapList.get(k);
				String taskId = (String) taskMap.get("physicalid");
				String seqId = ((String) seqData.get(taskId).getDataelements().get(ProgramCentralConstants.KEY_WBS_ID));
				taskMap.put("attribute[" + sAttributeTaskWBS + "]", seqId);
			} 
            
            tempMapList.sort("attribute[" + sAttributeTaskWBS + "]" , "ascending","multilevel");
            mlAllTasks.addAll(tempMapList);
        }
    }


		//START -To get extended members if LPI is installed and append it to the member list
	    boolean isLPIInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionLPI",false,null,null);
	    if(isLPIInstalled && project != null){
	    	Map<String, String> argumentMap = new HashMap<String,String>();
	    	argumentMap.put("objectId", project.getObjectId(context));
	    	String classname = JPOSupport.getClassName(context, "emxExtendedMembershipUI");
	    	MapList mpLstExtendedMembers = (MapList)JPO.invokeLocal(context, classname, null, "getExtendedMembers", JPO.packArgs(argumentMap), MapList.class);

			//Adding the Extended members to the list of members
			wbsMemberList.addAll(mpLstExtendedMembers);
		}
	    //END - Adding Extended Members to the Member list


    //[END:PA4:23-Sept-2011:IR-127329V6R2013]

    // Create hashmap that contains parsed string lists of available project roles
    HashMap hmRoles = new HashMap();
    String sRole;
    for ( int i=0; i<wbsMemberList.size(); i++ ) {
        Map mMemberList = (Map) wbsMemberList.get( i );
        sRole = (String) mMemberList.get ( "attribute[" + sAttributeProjectRole + "]" );
        if ( hmRoles.containsKey( sRole ) ) {
            MapList mlPeople = (MapList) hmRoles.get( sRole );
            mlPeople.add( mMemberList );
            mlPeople.sort( "name", "ascending", "string" );
            hmRoles.put( sRole, mlPeople );
        } else {
            MapList mlPeople = new MapList();
            mlPeople.add( mMemberList );
            hmRoles.put( sRole, mlPeople );
        }
    }


//    com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
    String taskPolicy = task.getDefaultPolicy(context);
    String completeState     = PropertyUtil.getSchemaProperty(context, "policy", taskPolicy, "state_Complete" );
    String reviewState       = PropertyUtil.getSchemaProperty(context, "policy", taskPolicy, "state_Review" );

	String superUser = PropertyUtil.getSchemaProperty(context,"person_UserAgent");

    int iIndent = 0;
    String sTaskWBS;

    // Step 3 - Iterate and display tasks on screen
    %>
	<form name="editForm" method="post" action="emxProgramCentralAutomaticAssignmentProcess.jsp">
	<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
    <table border="0" width="100%" class="list">
        <tr>
            <th width="30%" nowrap="nowrap">
                <img src="../common/images/utilSpacer.gif" border="0" height="10" />
                <framework:i18nScript localize="i18nId">emxProgramCentral.Common.PhaseTaskName</framework:i18nScript>
            </th>
            <th width="25%" nowrap="nowrap">
                <framework:i18nScript localize="i18nId">emxProgramCentral.Common.ProjectRole</framework:i18nScript>
            </th>
            <th width="25%" nowrap="nowrap">
                <framework:i18nScript localize="i18nId">emxProgramCentral.Common.Name</framework:i18nScript>
            </th>
            <th width="5%" nowrap="nowrap">
                <framework:i18nScript localize="i18nId">emxProgramCentral.Common.Owner</framework:i18nScript>
            </th>
            <th width="5%" nowrap="nowrap">
                <framework:i18nScript localize="i18nId">emxProgramCentral.Common.Assignee</framework:i18nScript>
            </th>
            <th width="5%" nowrap="nowrap">
                <framework:i18nScript localize="i18nId">emxProgramCentral.Common.TaskAllocation</framework:i18nScript>
            </th>
            <th width="5%" nowrap="nowrap">
                <framework:i18nScript localize="i18nId">emxProgramCentral.Common.FTE</framework:i18nScript>
            </th>
        </tr>


    <framework:mapListItr mapList="<%=mlAllTasks%>" >
        <%
            if ( !slTaskIds.contains(map.get( "id" )))
            {
               slTaskIds.add((String)map.get( "id" ));

               sTaskStartDate = (String) map.get(task.SELECT_TASK_ESTIMATED_START_DATE);
               sTaskEndDate = (String) map.get(task.SELECT_TASK_ESTIMATED_FINISH_DATE);

               // Prior to displaying the task and project role, we need to determine
               // how many people are in that role for the project.  This number
               // is then used to determine the rowspan of the taskname and role cells
               sTaskRole = (String) map.get( "attribute[" + sAttributeProjectRole + "]" );

               if ( sTaskRole != null && !sTaskRole.equals( "" ) ) {
                   mlRoleMembers = (MapList) hmRoles.get( sTaskRole );
               } else {
                   mlRoleMembers = wbsMemberList;
               }
               if ( mlRoleMembers == null ) mlRoleMembers = new MapList();

                   //[ADDED:PA4:23-Sept-2011:IR-127329V6R2013] 
                   StringList sProjectMemberNames = new StringList();
                   StringList sProjectMemberIds = new StringList();
                   sTaskAssigneesNames = new StringList();
                   sTaskAssigneesIds = new StringList();
                   //[END:PA4:23-Sept-2011:IR-127329V6R2013] 

                   if ( map.get( "to[" + sRelationshipAssignedTasks + "].businessobject.name" ) != null ) 
                   {
                      try
                      {
                         sTaskAssigneesNames = (StringList) map.get( "to[" + sRelationshipAssignedTasks + "].businessobject.name" );
                      }
                      catch(Exception e)
                      {
                         sTempTaskAssigneesName = (String) map.get( "to[" + sRelationshipAssignedTasks + "].businessobject.name" );
                         if (sTempTaskAssigneesName != null)
                         {
                            sTaskAssigneesNames = new StringList(1);
                            sTaskAssigneesNames.add(sTempTaskAssigneesName);
                         }
                      }
                   }
                           
                   if ( map.get( "to[" + sRelationshipAssignedTasks + "].businessobject.id" ) != null ) 
                   {
                      try
                      {
                         sTaskAssigneesIds = (StringList) map.get( "to[" + sRelationshipAssignedTasks + "].businessobject.id" );
                      }
                      catch(Exception e)
                      {
                         sTempTaskAssigneesIds = (String) map.get( "to[" + sRelationshipAssignedTasks + "].businessobject.id" );
                         if (sTempTaskAssigneesIds != null)
                         {
                           sTaskAssigneesIds = new StringList(1);
                           sTaskAssigneesIds.add(sTempTaskAssigneesIds);
                         }
                      }
                   }
            
                   sTaskAssigneesPercentCompletes = new StringList();
                   if ( map.get( sPercentComplete ) != null ) 
                   {
                      try
                      {
                         sTaskAssigneesPercentCompletes = (StringList) map.get( sPercentComplete );
                      }
                      catch(Exception e)
                      {
                         sTempTaskAssigneesPercentCompletes = (String) map.get( sPercentComplete );
                         if (sTempTaskAssigneesPercentCompletes != null)
                         {
                           sTaskAssigneesPercentCompletes = new StringList(1);
                           sTaskAssigneesPercentCompletes.add(sTempTaskAssigneesPercentCompletes);
                         }
                      }
                   }
    
                   sTaskAssigneesAssignedTaskIds = new StringList();
                   if ( map.get( sAssignedTaskId ) != null ) 
                   {
                      try
                      {
                         sTaskAssigneesAssignedTaskIds = (StringList) map.get( sAssignedTaskId );
                      }
                      catch(Exception e)
                      {
                         sTempTaskAssigneesAssignedTaskIds = (String) map.get( sAssignedTaskId );
                         if (sTempTaskAssigneesPercentCompletes != null)
                         {
                           sTaskAssigneesAssignedTaskIds = new StringList(1);
                           sTaskAssigneesAssignedTaskIds.add(sTempTaskAssigneesAssignedTaskIds);
                         }
                      }
                   }
            
                   // loop thru names creating list that these are already assignees
                   StringList sTaskAssigneesIsAssignee = new StringList();
                   if ( sTaskAssigneesNames != null )
                   {
                       for (int i = 0; i < sTaskAssigneesNames.size(); i++)
                       {
                          sTaskAssigneesIsAssignee.add("true");
                       }
                   }
                   String strTaskRole = (String)map.get(DomainConstants.ATTRIBUTE_PROJECT_ROLE);
                   //[ADDED:PA4:23-Sept-2011:IR-127329V6R2013] 
                   for(int i=0;i<wbsMemberList.size();i++){
                       Map member = (Map)wbsMemberList.get(i);
                       String strMemRole = (String)member.get("attribute["+DomainConstants.ATTRIBUTE_PROJECT_ROLE+"]");
                       String memberName = (String)member.get("name");
                       String memberId = (String)member.get("id");
                       //If Task has no Project Role show all project members while assgning by project role.
                       if("".equals(strTaskRole)){
                       // Checks if project member is an assignee. If not then include 
                       // them in the list of assignees and marked false in 
                       // sTaskAssigneesIsAssignee list.
                       if(!sTaskAssigneesNames.contains(memberName) && !sTaskAssigneesIds.contains(memberId)){
                            sTaskAssigneesNames.add(memberName);
                            sTaskAssigneesIds.add(memberId);
                            sTaskAssigneesIsAssignee.add("false");
                                sTaskAssigneesPercentCompletes.add("100.0");
                                sTaskAssigneesAssignedTaskIds.add("null");
                           }
                       }else{
                       //Show Project Memebrs which match Task Project Role and Memebr Project Role.
                    	   if(strMemRole.equals(strTaskRole) && !sTaskAssigneesNames.contains(memberName)){
                    		   sTaskAssigneesNames.add(memberName);
                               sTaskAssigneesIds.add(memberId);
                               sTaskAssigneesIsAssignee.add("false");
                               sTaskAssigneesPercentCompletes.add("100.0");
                               sTaskAssigneesAssignedTaskIds.add("null");
                    	   }
                       }
                   }
                   //[END:PA4:23-Sept-2011:IR-127329V6R2013] 

                   sTaskOwner = (String) map.get( "owner" );
                   String ownerId = com.matrixone.apps.common.Person.getPerson(context, sTaskOwner).getId();
                   if (( sTaskAssigneesIds != null ) && ( !sTaskAssigneesIds.contains(ownerId)))
                   {
                      sTaskAssigneesNames.add(sTaskOwner);
                      sTaskAssigneesIds.add(ownerId);
                      sTaskAssigneesPercentCompletes.add("100.0" );
                      sTaskAssigneesIsAssignee.add("false");
                      sTaskAssigneesAssignedTaskIds.add("null");
                   }
                
                   for ( int i=0; i<mlRoleMembers.size(); i++ )
                   {
                       Map mMember = (Map) mlRoleMembers.get( i );
                       if (( sTaskAssigneesIds != null ) && ( !sTaskAssigneesIds.contains(mMember.get( "id" ))))
                       {
                          sTaskAssigneesNames.add((String)mMember.get( "name" ) );
                          sTaskAssigneesIds.add((String)mMember.get( "id" ));
                          sTaskAssigneesPercentCompletes.add("100.0" );
                          sTaskAssigneesIsAssignee.add("false");
                          sTaskAssigneesAssignedTaskIds.add("null");
                       }
                   }
            
                   if ( sTaskAssigneesNames != null )
                   {
                       for (int i = 0; i < sTaskAssigneesNames.size(); i++)
                       {
				
				
                           %>
               <tr class='<framework:swap id="1"/>'>
        
                               <td nowrap=nowrap height="28">
                                   <%
				   if(i == 0)
				   {
                   		treeUrl = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, (String)map.get( "id" ));
                   		// As the displayed items may potentially be sub-tasks of the parent,
                   		// we need to indent the list appropriately.  The indent shall consist
                   		// of 5 spaces (using the utilspacer gif) for every level down plus the
                   		// |_ image (utilTreeLineLast.gif)
                  		sTaskWBS = (String) map.get( "attribute[" + sAttributeTaskWBS + "]" );
                   		if ( sTaskWBS != null && sTaskWBS.indexOf( "." ) > 0 ) {
                       			StringTokenizer stTaskWBS = new StringTokenizer( sTaskWBS, "." );
                       			iIndent = 7 * stTaskWBS.countTokens();
                   %>
                       <img src="../common/images/utilSpacer.gif" height="5" width="<%=iIndent%>" border="0" />
                       <img src="../common/images/utilTreeLineLast.gif" border="0" />
                       (<%=sTaskWBS%>)
                       <%
                   		}
                                   if (printerFriendly.equals("true"))
                                   {
                                   %>
        					<%-- XSSOK--%>   <%=map.get( "name" )%>  
                                   <%
                                   } else
                                   {
                                   %>
                                     <a href="javascript:showDetailsPopup('<%=treeUrl%>')">       <%-- XSSOK--%>
                     		<xss:encodeForHTML><%=map.get( "name" )%></xss:encodeForHTML>
                                     </a>
                                   <%
                                   }
				   }
                                   %>
                               </td>
               <td  nowrap=nowrap height="28">
			     <%-- IR Fix 319707 Start --%>
			     <!--%=sTaskRole%-->
                       <%
				   if(i == 0){
				   //Added:3-Mar-10:VF2:R209:PRG Bug :036275
				   //task.setId(taskIds);
				   task = new Task(taskIds);
				   String actualType = task.getType(context);
				   MapList typeMapList    = mxType.getAttributes(context, actualType);
				   StringList rolesList = new StringList(); 
				   Iterator typeMapListItr = typeMapList.iterator();
				   while(typeMapListItr.hasNext())
				   {
				     Map item = (Map) typeMapListItr.next();
				     String attrName = (String) item.get("name");
				     String attrType = (String) item.get("type");  
				     if ( attrName.equals(task.ATTRIBUTE_PROJECT_ROLE) ) 
				     {
				    	 rolesList = (StringList)item.get("choices");
                       }
                   }
				   //End:3-Mar-10:VF2:R209:PRG Bug :036275
				   String i18nSelectedRole = null;				
				     i18nSelectedRole = sTaskRole;

				     if(i18nSelectedRole != null && !"".equals(i18nSelectedRole))
				     {
					   if(i18nSelectedRole.startsWith("role_"))
					   {
					     String sIntProjectRole = PropertyUtil.getSchemaProperty(context, i18nSelectedRole);
					     if(sIntProjectRole != null)
					     {
						   i18nSelectedRole = i18nNow.getRoleI18NString(sIntProjectRole, sLanguage);
						   //Added:3-Mar-10:VF2:R209:PRG Bug :036275
						   if(rolesList.contains(sIntProjectRole))
						   {
                               i18nSelectedRole += EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                         			  "emxProgramCentral.MemberRoles.Suffix.RDO", context.getSession().getLanguage());
                           }					   
						   //End:3-Mar-10:VF2:R209:PRG Bug :036275
					     }
					   } 
					   else
					   {
					     i18nSelectedRole = i18nNow.getRangeI18NString(
							   PropertyUtil.getSchemaProperty(context, "attribute_ProjectRole"),
							   i18nSelectedRole,
							   sLanguage);
					   }
				     }
				   
				   %>
				   <%=i18nSelectedRole%>
				   <%-- IR Fix 319707 Start --%>
				    <%
				}
                   %>
               </td>
           
               <td  nowrap=nowrap height="28">
                   
                   <%
                   
                           treeUrl = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, (String)sTaskAssigneesIds.get(i));
                           %>
                           
                                   <!-- Checkbox is used to make sure user names line up with radio and checkboxes in next two columns -->
                                   <img src="../common/images/utilSpacer.gif" height="1"  border="0" />
                                   <%
                                   if (printerFriendly.equals("true"))
                   {
                                   %>
                                     <%=com.matrixone.apps.common.Person.getDisplayName(context, (String)sTaskAssigneesNames.get(i))%>  <%-- XSSOK--%>
                                   <%
                                   } else
                       {
                           %>
                                     <a href="javascript:showDetailsPopup('<%=treeUrl%>')">       <%-- XSSOK--%>
                                       <%=com.matrixone.apps.common.Person.getDisplayName(context, (String)sTaskAssigneesNames.get(i))%>     <%-- XSSOK--%>
                                     </a>
                                   <%
                                   }
                                   %>
                               
                       <%
                   
                   
                   %>
                   
               </td>
                               <td nowrap=nowrap height="28">
                               
                                   <img src="../common/images/utilSpacer.gif" height="1"  border="0" />
                           <%
                           if ( sTaskOwner.equals( (String) sTaskAssigneesNames.get(i) ) ) {
                               checked = "checked";
                               %>
                               <input type="hidden" name="ownerorig~<%=map.get( "id" )%>" value="<xss:encodeForHTMLAttribute><%=(String) sTaskAssigneesNames.get(i)%></xss:encodeForHTMLAttribute>" />
                               <%
                           } else {
                               checked = "";
                               %>
                               <input type="hidden" name="junk~<%=map.get( "id" )%>" value="<xss:encodeForHTMLAttribute><%=(String) sTaskAssigneesNames.get(i)%></xss:encodeForHTMLAttribute>" />
                               <%
                           }
                           
                           if (printerFriendly.equals("true"))
                           {
                           %>
                               <input type="radio" disabled name="owner~<%=XSSUtil.encodeForHTMLAttribute(context,(String)map.get( "id" ))%>" value="<%=XSSUtil.encodeForHTMLAttribute(context,(String) sTaskAssigneesNames.get(i))%>" <%=checked%> />  <%-- XSSOK--%> 
                           <%
                           } else
                           {
                           %>
                               <input type="radio" name="owner~<%=XSSUtil.encodeForHTMLAttribute(context,(String)map.get( "id" ))%>" value="<%=XSSUtil.encodeForHTMLAttribute(context,(String) sTaskAssigneesNames.get(i))%>" <%=checked%> />    <%-- XSSOK--%> 
                           <%
                           }
                           %>
                       
                   
                               </td>
               <td nowrap=nowrap height="28">
                   
                   <%
                   if ( map.get( "to[" + sRelationshipAssignedTasks + "].businessobject.id" ) != null ) {
                       sTaskAssignees = (String) map.get( "to[" + sRelationshipAssignedTasks + "].businessobject.id" ).toString();
                   } else {
                       sTaskAssignees = "";
                   }
                
                           %>
                           
                               
                                   <img src="../common/images/utilSpacer.gif" height="1"  border="0" />
                           <%

                           if (( sTaskAssigneesIds.get(i) != null ) && (sTaskAssigneesIsAssignee.get(i).equals("true"))) {
                               checked = "checked";
                               onColor = "transparent";
                               offColor = BG_COLOR_RED;
                               %>
                               <input type="hidden" name="taskorig~<%=XSSUtil.encodeForHTMLAttribute(context,(String)map.get( "id" ))%>~<%=XSSUtil.encodeForHTMLAttribute(context,(String) sTaskAssigneesIds.get(i))%>" value="yes" />
                               <%
                           } else {
                               checked = "";
                               onColor = BG_COLOR_BLUE;
                               offColor = "transparent";
                               %>
                               <input type="hidden" name="taskorig~<%=XSSUtil.encodeForHTMLAttribute(context,(String)map.get( "id" ))%>~<%=XSSUtil.encodeForHTMLAttribute(context,(String) sTaskAssigneesIds.get(i))%>" value="no" />
                               <%
                           }

                           if (printerFriendly.equals("true"))
                           {
                           %>
                           <input type="checkbox" disabled name="task~<%=XSSUtil.encodeForHTMLAttribute(context,(String)map.get( "id" ))%>~<%=XSSUtil.encodeForHTMLAttribute(context,(String) sTaskAssigneesIds.get(i))%>" value="<%=XSSUtil.encodeForHTMLAttribute(context,(String) sTaskAssigneesIds.get(i))%>" <%=checked%> onclick="javascript:toggleBackground( this, '<%=onColor%>', '<%=offColor%>')" /><%-- XSSOK--%>
                           <%
                           } else
                           {
                           %>
                           <input type="checkbox" name="task~<%=XSSUtil.encodeForHTMLAttribute(context,(String)map.get( "id" ))%>~<%=XSSUtil.encodeForHTMLAttribute(context,(String) sTaskAssigneesIds.get(i))%>" value="<%=XSSUtil.encodeForHTMLAttribute(context,(String) sTaskAssigneesIds.get(i))%>" <%=checked%> onclick="javascript:toggleBackground( this, '<%=onColor%>', '<%=offColor%>')" /> <%-- XSSOK--%>
                           <%
                           }
                           %>
                                           
                               </td>
                               <td nowrap=nowrap height="28">
                   
                           
                                   <!-- Checkbox is used to make sure user names line up with radio and checkboxes in next two columns -->
                                   <img src="../common/images/utilSpacer.gif" height="1"  border="0" />
                                   <input type="hidden" name="PAorigValue~<%=map.get( "id" )%>~<%=(String) sTaskAssigneesIds.get(i)%>" value="<xss:encodeForHTMLAttribute><%=(String) sTaskAssigneesPercentCompletes.get(i)%></xss:encodeForHTMLAttribute>" />
                                   <input type="hidden" name="PAorigId~<%=map.get( "id" )%>~<%=(String) sTaskAssigneesIds.get(i)%>" value="<xss:encodeForHTMLAttribute><%=(String) sTaskAssigneesAssignedTaskIds.get(i)%></xss:encodeForHTMLAttribute>" />
                                   <%
                                   if (printerFriendly.equals("true"))
                                   {
                                   %>
                                     <input type="text" disabled size="5" name="PA~<%=map.get( "id")%>~<%=(String) sTaskAssigneesIds.get(i)%>" value="<%=sTaskAssigneesPercentCompletes.get(i)%>" /></td>   <%-- XSSOK--%>
                                   <%
                                   } else
                                   {
                                   %>
                                     <input type="text" size="5" name="PA~<%=map.get( "id" )%>~<%=(String) sTaskAssigneesIds.get(i)%>" value="<%=sTaskAssigneesPercentCompletes.get(i)%>" /></td>      <%-- XSSOK--%>
                                   <%
                                   }
                                   %>

               </td>
               <td nowrap="nowrap" align="center" height="28">
                   
                   <%
                   
                           newURL = "emxProgramCentralResourceDialogFS.jsp?suiteKey=ProgramCentral&initSource=&objectId=null&emxTableRowId=personid_"+sTaskAssigneesIds.get(i)+"&type=null&start="+sTaskStartDate+"&end="+sTaskEndDate+"&start_msvalue=0&end_msvalue=0&optionSelected=Weekly&contentPageIsDialog=false&usepg=false&warn=true&portalMode=false&launched=false";
                           %>
                          

                                <%
                                if (printerFriendly.equals("true"))
                                {
                                %>
                                  <a ><img src="../common/images/iconSmallReport.gif" border="0" /></a>
                                <%
                                } else
                                {
                                %>
                                  <a href="javascript:showDialog('<%=newURL%>')"><img src="../common/images/iconSmallReport.gif" border="0"
                                       alt="<framework:i18n localize="i18nId">emxProgramCentral.Common.NewWindow</framework:i18n>" /></a>
                                <%
                                }
                                %>
                   
          </td>
           <%
           }
            }
        
           %>
        </tr>
        <%
        }
        %>
    </framework:mapListItr>
    </table>
</form>

<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.program.ProjectSpace"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.program.Task"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.common.ProjectManagement"%>
<%@page import="com.matrixone.apps.program.ProjectConcept"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.db.JPOSupport"%></html>
