<%-- emxProgramCentralWBSDeleteProcess.jsp
 
  Performs the action to remove a specific task

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralWBSDeleteProcess.jsp.rca 1.35 Tue Oct 28 22:59:43 2008 przemek Experimental przemek $";
--%>
 
<%@page import="com.dassault_systemes.enovia.tskv2.ProjectSequence"%>
<%@include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.common.ICDocument"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script src="../programcentral/emxProgramCentralUIFormValidation.js" type="text/javascript"></script>
<%
  com.matrixone.apps.program.Task task =
    (com.matrixone.apps.program.Task) DomainObject.newInstance(context,
    DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);

	com.matrixone.apps.common.Task commonTask = (com.matrixone.apps.common.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK);
  	// get all the WBS request parameters to return
	String topId      		= emxGetParameter(request, "topId");
	String jsTreeID   		= emxGetParameter(request, "jsTreeID");
	String expanded   		= emxGetParameter(request, "expanded");
	String timeStamp  		= emxGetParameter(request, "timeStamp");
	String projectId  		= emxGetParameter(request, "projectId");
	String objectIds  		= emxGetParameter(request, "objectIds");
	String showSel    		= emxGetParameter(request, "mx.page.filter");
	String rowIds 			= (String) emxGetParameter(request, "rowIds");
	String fromPage 		= (String) emxGetParameter(request, "fromPage");
	String currentframe 	= XSSUtil.encodeForJavaScript(context,(String)emxGetParameter(request, "portalCmdName"));
	
	String selectedProjectRelIds = (String) emxGetParameter(request, "selectedIds");
    StringList relIdList = FrameworkUtil.split(selectedProjectRelIds, ",");
    String[] relationshipIds = (String []) relIdList.toArray(new String[] {});

	boolean isFromRMB 		= "true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"));
  	String message = ProgramCentralConstants.EMPTY_STRING;
	boolean isDeleteAllowed = true;
  	boolean boolStructureBrowser = false;
  	String strLanguage = context.getSession().getLanguage();
  	 
    if(fromPage!=null && "StructureBrowser".equalsIgnoreCase(fromPage)){
      boolStructureBrowser=true;
    }
 
   if(relationshipIds.length > 0){
	   ContextUtil.startTransaction(context, true);
       DomainRelationship relRemove = new DomainRelationship(DomainConstants.RELATIONSHIP_SUBTASK);
       relRemove.disconnect(context, relationshipIds,false);
       ContextUtil.commitTransaction(context);
       
     //Start- New re-squenece logic
       String selectedProjectIds 	= (String) emxGetParameter(request, "selectedProjectIds");
  		StringList deletedObjIdList = FrameworkUtil.split(selectedProjectIds, ",");
  		
	    		Map<String,StringList> deletedObjectIds = new HashMap<>();
	    		
	    		for(int i = 0, j = deletedObjIdList.size(); i<j; i++) {
	    			String deletedProjectId = deletedObjIdList.get(0);

	    			StringList parentIdList = FrameworkUtil.split(deletedProjectId, "|");
	    			String taskId = parentIdList.get(0);
	    			String parentId = parentIdList.get(1);

	    			if(deletedObjectIds.containsKey(parentId)) {
	    				deletedObjectIds.get(parentId).add(taskId);
	    			}else {
	    				StringList deletedTaskSet = new StringList();
	    				deletedTaskSet.add(taskId);
	    				deletedObjectIds.put(parentId, deletedTaskSet);
	    			}

			}


			java.util.Set<String> parentIdSet = deletedObjectIds.keySet();
			String mqlCmd = "print bus $1 select $2 $3 dump $4";
				
				Iterator<String> itr = parentIdSet.iterator();
				while(itr.hasNext()) {
				
					String parentId = itr.next();
					StringList deletedTaskList = deletedObjectIds.get(parentId);
			
					String rootNodePALPhysicalId = MqlUtil.mqlCommand(context, 
						true,
						true,
						mqlCmd, 
						true,
						parentId,
						ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT,
						ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_TASK,
						"|");
			

					try{
					ProjectSequence ps = new ProjectSequence(context, rootNodePALPhysicalId);
      				ps.unAssignSequence(context, deletedTaskList);
					}
					catch(Exception e){
						e.printStackTrace();
						throw e;
					}
			//End
   }
   }
    
    StringList rowIdList = new StringList();
	StringList idList = new StringList();
	
	if(objectIds == null){
		idList = (StringList) session.getAttribute("DPMTaskIdsToDelete");
	 	session.removeAttribute("DPMTaskIdsToDelete");
	}
  
	if(rowIds == null){
		rowIdList = (StringList) session.getAttribute("DPMRowIds");
	 	session.removeAttribute("DPMRowIds");
	 	
	}
  
	String[] taskIds = (String []) idList.toArray(new String[] {});
	
	StringList newIdList = new StringList();
	
	StringList nonDeletedTasks = new StringList();
	StringList nonDeletedICTasks = new StringList();
	StringList subTaskNotInCreateState = new StringList();

	Map preProcessMap = Task.deleteTaskPreProcess(context, taskIds, rowIdList);
  	
	StringList mandatoryTasksList = (StringList)preProcessMap.get("MandatoryTasks");
	StringList tasksWithEffortsList = (StringList)preProcessMap.get("TasksWithEfforts");
	StringList tasksBeyondStateList = (StringList)preProcessMap.get("TasksBeyondState");
	StringList tasksToBeDeletedList = (StringList)preProcessMap.get("TasksToBeDeleted");
  	
	String projectSchedule = ProgramCentralConstants.PROJECT_SCHEDULE_AUTO;
  	if(tasksToBeDeletedList!=null &&  !tasksToBeDeletedList.isEmpty()){
	  	String[] newTaskIds = (String []) tasksToBeDeletedList.toArray(new String[] {});
  	if(ProjectSpace.isEPMInstalled(context)){
	  		Task.deleteICObjects(context, newTaskIds, tasksToBeDeletedList, nonDeletedICTasks);
		newTaskIds = (String []) newIdList.toArray(new String[] {});
	}    

    //Added by DI7
    Map<String,String> projectScheduleMap = ProgramCentralUtil.getProjectSchedule(context, topId);
	   projectSchedule = projectScheduleMap.get(topId);
	   
	try { 
		boolean doRollup = ProgramCentralConstants.PROJECT_SCHEDULE_AUTO.equalsIgnoreCase(projectSchedule);
		Task.deleteTasks(context, tasksToBeDeletedList, doRollup);
	} catch (Exception exp) {
		message = exp.getMessage();
		isDeleteAllowed = false;
	}
  	}


%>


<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><html>
  <body>
    <form name="wbsForm" action="emxProgramCentralWBSModifyDialog.jsp" method="post">    
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	
      <input type="hidden" name="jsTreeId" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="topId" value="<xss:encodeForHTMLAttribute><%=topId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="hideWBS" value="false" />
      <input type="hidden" name="expanded" value="<xss:encodeForHTMLAttribute><%=expanded%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="projectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="reload" value="true" />
    </form>
  </body>
 
</html>
<%  

if(boolStructureBrowser){
    if(!tasksBeyondStateList.isEmpty()) {
       String strTaskBeyondStatemessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
  			  "emxProgramCentral.Common.UnableToDeleteTasks", strLanguage);
        message = strTaskBeyondStatemessage+"\\n"+tasksBeyondStateList;
    	}
    
    if(!mandatoryTasksList.isEmpty()){
    	String strMandatoryTaskmessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
    			  "emxProgramCentral.Common.CannotDeleteMandatoryTask", strLanguage);
          
          message = message+"\\n"+strMandatoryTaskmessage+"\\n"+mandatoryTasksList;
		}           
    
    if(!tasksWithEffortsList.isEmpty()){
    	String strTasksWithEffortmessage = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
  			  "emxProgramCentral.WeeklyTimeSheet.DeleteTask.TaskWithEffortCannotBeDeleted", strLanguage);
        message = message+"\\n"+strTasksWithEffortmessage+"\\n"+tasksWithEffortsList;
		}
      

    if(ProjectSpace.isEPMInstalled(context)) {    
        if(!subTaskNotInCreateState.isEmpty()) {
            message = message+"\n" + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
      			  "emxProgramCentral.Common.SubTasksNotInCreateState", strLanguage);
            message = message+"\n"+subTaskNotInCreateState;
        }
        if(!nonDeletedICTasks.isEmpty()) {
            message = message+"\n" + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
      			  "emxProgramCentral.Common.UnableToDeleteICTasks", strLanguage);
            message = message+"\n"+nonDeletedICTasks;
        }
    } else {  
        if(!subTaskNotInCreateState.isEmpty()) {
            message = message+"\n" + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
      			  "emxProgramCentral.Common.SubTasksNotInCreateState", strLanguage);
            message = message+"\n"+subTaskNotInCreateState;
        }
    }   
    boolean boolRemoved=false;
    if( ProgramCentralUtil.isNotNullString(message))
    {
%>
<script language="javascript" type="text/javaScript">
		alert("<%=message%>");
</script>
<%
    }  
    
    
    if(rowIdList!=null && !rowIdList.isEmpty() && isDeleteAllowed){
%>
    	  <script language="javascript" type="text/javaScript">
    	  var cBoxArray = new Array();
<%
    	  String[] emxTableRowIdArray = new String[rowIdList.size()];	
    	  for (int i=0; i<rowIdList.size(); i++) {
    		  emxTableRowIdArray[i]= " | | |"+rowIdList.get(i);
%>
    		  cBoxArray["<%=i%>"]="<%=emxTableRowIdArray[i]%>";
<%
          } 
%>

		var currentFrameName = "<%=currentframe%>";
		
		var displaytopFrame = findFrame(getTopWindow(), "detailsDisplay");
		var topFrame = findFrame(displaytopFrame, currentFrameName);
		
		if(null == topFrame){
			topFrame = findFrame(getTopWindow(), "PMCWhatIfExperimentStructure");
			if(null == topFrame){
				topFrame = findFrame(getTopWindow(), "detailsDisplay");
			}
        }
	
		var projectScheduleValue = "<%=projectSchedule%>";
	
		if("Manual" == projectScheduleValue){
			 topFrame.emxEditableTable.removeRowsSelected(cBoxArray);
			top.jQuery('button.refresh', '.field.button').toggleClass('refresh').toggleClass('refresh-with-cache');
			toggleRollupIcon(topFrame,"iconActionUpdateDates","iconActionUpdateDatesActive");
		  }else{
			 topFrame.rebuildViewInProcess = true;
		  	 topFrame.syncSBInProcess = true;
			 topFrame.emxEditableTable.removeRowsSelected(cBoxArray);
			 topFrame.rebuildViewInProcess = false
		  	 topFrame.syncSBInProcess = false;
		topFrame.emxEditableTable.refreshStructureWithOutSort();
		  }
		
		topFrame.toggleProgress('hidden');
		getTopWindow().RefreshHeader();

	</script>
<%
    }
%>
    <script language="javascript" type="text/javaScript">
		var currentFrameName = "<%=currentframe%>";
		var displaytopFrame = findFrame(getTopWindow(), "detailsDisplay");
		var topFrame1 = findFrame(displaytopFrame, currentFrameName);
		topFrame1.toggleProgress('hidden');
		getTopWindow().RefreshHeader();
   </script>

<%
} else {
%>
    <script>
	    var url = "emxProgramCentralWBSModifyDialog.jsp?objectId=<%=XSSUtil.encodeForURL(context,topId)%>"+"&mx.page.filter="+"<%=XSSUtil.encodeForURL(context,showSel)%>";
	    document.wbsForm.action = url;
	    document.wbsForm.submit();
    </script>
    </html>
<%  
  }
%>


