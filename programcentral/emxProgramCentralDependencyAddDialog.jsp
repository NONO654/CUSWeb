<%-- emxProgramCentralProjectTemplateWBSSummary.jsp

  Displays the tasks/phases for a given project.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = "$Id: emxProgramCentralDependencyAddDialog.jsp.rca 1.31 Tue Oct 28 22:59:42 2008 przemek Experimental przemek $";
--%>

<%@page import="com.dassault_systemes.enovia.tskv2.ProjectSequence"%>
<%@page import="com.dassault_systemes.enovia.e6wv2.foundation.jaxb.Dataobject"%>
<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "emxPopupSelectUtil.inc"%>
<%@page import="com.matrixone.apps.program.DurationKeywordsUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<html>
<%
  com.matrixone.apps.common.Person person=
      (com.matrixone.apps.common.Person) DomainObject.newInstance(context,
      DomainConstants.TYPE_PERSON);
  com.matrixone.apps.program.ProjectTemplate template =
      (com.matrixone.apps.program.ProjectTemplate) DomainObject.newInstance(context,
      DomainConstants.TYPE_PROJECT_TEMPLATE, DomainConstants.PROGRAM);
  com.matrixone.apps.common.SubtaskRelationship subtask =
      (com.matrixone.apps.common.SubtaskRelationship) DomainRelationship.newInstance(context,
      DomainConstants.RELATIONSHIP_SUBTASK);
  com.matrixone.apps.program.Task task =
      (com.matrixone.apps.program.Task) DomainObject.newInstance(context,
      DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
  com.matrixone.apps.program.ProjectSpace project =
   (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE, DomainConstants.PROGRAM);
  String taskEstimatedDuration = PropertyUtil.getSchemaProperty(context, "attribute_TaskEstimatedDuration");

  //Added:12-Mar-09:QZV:R207:ECH:Bug:369850
  boolean isECHInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionEnterpriseChange",false,null,null);
  //End:R207:ECH:Bug:369850  
  
  // Get business object id from URL
  String showSel         = emxGetParameter(request, "mx.page.filter");
  String objectId        = emxGetParameter(request, "objectId");
  String mainObjectId    = emxGetParameter(request, "mainObjectId"); //Added 24-Aug-2010:PRG:rg6:R210:IR-063755V6R2011x
  String jsTreeID        = emxGetParameter(request, "jsTreeID");
  String topId           = emxGetParameter(request, "topId");
  String topTaskId       = emxGetParameter(request, "topTaskId");
  String hasEditAccess   = emxGetParameter(request, "hasEditAccess");
  String expanded        = emxGetParameter(request, "expanded");
  String wbsNumber       = emxGetParameter(request, "wbsNumber");
  String timeStamp       = emxGetParameter(request, "timeStamp");
  String rootId = emxGetParameter(request, "rootId");
  String jsTreeIDValue   = null;
  String taskPolicy      = task.getDefaultPolicy(context);
  String completeState   = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Complete");
  String reviewState     = PropertyUtil.getSchemaProperty(context,"policy",taskPolicy,"state_Review");
  String printerFriendly = emxGetParameter(request,"PrinterFriendly");
  MapList multiTasksList = new MapList();
  String languageStr     = request.getHeader("Accept-Language");
  StringList dependencyTypeList     = task.getDependencyTypes(context);
  StringList i18nDependencyTypeList = new StringList();
  StringItr strItr                  = new StringItr(dependencyTypeList);
 
  //Added 24-Aug-2010:PRG:rg6:R210:IR-063755V6R2011x
  if (mainObjectId == null || "".equals(mainObjectId) || "null".equals(mainObjectId)) {
	  mainObjectId = objectId;
  }
 //End 24-Aug-2010:PRG:rg6:R210:IR-063755V6R2011x
//added by ixe for IR-011601V6R2011
  String isShowAll       = emxGetParameter(request, "action");
  if(isShowAll==null || isShowAll.equals("null")|| isShowAll.equals("")) {
	  isShowAll = "minus";
	  }

  if(rootId == null){
      rootId = topTaskId;
  }

  while(strItr.next()){
      i18nDependencyTypeList.addElement(i18nNow.getRangeI18NString(PropertyUtil.getSchemaProperty(context, "attribute_DependencyType"),
            strItr.obj(),
            languageStr));
  }

  String cleanupTimeStamp        = emxGetParameter(request, "cleanupTimeStamp");
  if (cleanupTimeStamp!=null && !cleanupTimeStamp.equals("") && !cleanupTimeStamp.equals("null"))
  {
     session.removeAttribute("taskAllList" + cleanupTimeStamp);
  }

  // checks on variables
  if (null != jsTreeID){
     jsTreeIDValue = jsTreeID;
  }
  if(timeStamp==null || timeStamp.equals("null")) {
    multiTasksList = null;
    timeStamp = null;
  } else {
    multiTasksList = (MapList) session.getAttribute("taskAllList" + timeStamp);
  }
  if(expanded==null || expanded.equals("null")|| expanded.equals("")) {
    expanded = "false";
  }

  if(wbsNumber==null || wbsNumber.equals("null")) {
    wbsNumber = "0";
  }

  if(topId == null || topId.equals("null") || topId.equals("")) {
   topId = objectId;
  }

  /*External Cross project Dependency*/
  String strTemplateId = emxGetParameter(request,"TemplateId");
  strTemplateId = XSSUtil.encodeForURL(context, strTemplateId);
  boolean showFindProjects = true;
  String externalDependency = emxGetParameter(request,"externalDependency");
  externalDependency = XSSUtil.encodeForURL(context, externalDependency);
  String subProjectId = null;
  if(externalDependency!=null && "true".equals(externalDependency)) {
      subProjectId = strTemplateId;
      showFindProjects = false;
      if(subProjectId == null || "null".equalsIgnoreCase(subProjectId)) {
          subProjectId = "";
      }
  }
  /*External Cross project Dependency*/

 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Retrieve the tasks for the project template or task parent
  StringList busSelects = new StringList(22);
  StringList relSelects = new StringList(1);
  busSelects.add(task.SELECT_ID);
  busSelects.add(ProgramCentralConstants.SELECT_PHYSICALID);
  busSelects.add(task.SELECT_NAME);
  busSelects.add(task.SELECT_OWNER);
  busSelects.add(task.SELECT_TYPE);
  busSelects.add(task.SELECT_CURRENT);
  busSelects.add(task.SELECT_SEQUENCE_ORDER);
  busSelects.add(task.SELECT_LEVEL);
  busSelects.add(task.SELECT_DESCRIPTION);
  busSelects.add(task.SELECT_TASK_ESTIMATED_DURATION);
  busSelects.add(task.SELECT_TASK_ESTIMATED_START_DATE);
  busSelects.add(task.SELECT_TASK_ESTIMATED_FINISH_DATE);
  busSelects.add(task.SELECT_TASK_ACTUAL_DURATION);
  busSelects.add(task.SELECT_TASK_ACTUAL_START_DATE);
  busSelects.add(task.SELECT_TASK_ACTUAL_FINISH_DATE);
  busSelects.add(task.SELECT_HAS_THREAD);
  busSelects.add(task.SELECT_PREDECESSOR_IDS);
  busSelects.add(task.SELECT_PREDECESSOR_TYPES);
  busSelects.add(task.SELECT_HAS_ASSIGNED_TASKS);
  busSelects.add(task.SELECT_HAS_TASK_DELIVERABLE);
  busSelects.add(task.SELECT_TASK_REQUIREMENT);
  busSelects.add(task.SELECT_HAS_SUBTASK);
  busSelects.add(task.SELECT_HAS_QUESTIONS);
  busSelects.add(task.SELECT_QUESTION_ID);
  busSelects.add("current.access[read]");
  busSelects.add("to[Subtask].from.id");
  relSelects.add(subtask.SELECT_TASK_WBS);

  // get the tasks from the parent and get the parent info as well
  if(externalDependency!=null && "true".equals(externalDependency)) {
      task.setId(subProjectId);
  } else {
  task.setId(objectId);
  }

  /* Begin - Below existing code not required. Not used anywhere so commenting out. */
  /* Map parentList    = task.getInfo(context, busSelects);
  String objectName = (String) parentList.get(task.SELECT_NAME);
  parentList.put(subtask.SELECT_TASK_WBS, wbsNumber); */
   /* End -Below code not required. Not used anywhere */
 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  boolean taskDisplayed = false;
  String none = "none";
  boolean readWrite = false;
  if (hasEditAccess != null && "true".equalsIgnoreCase(hasEditAccess)) {
    readWrite = true;
  }

  // Get the project template Id
  String templateId = null;
  //If objectId is of type project template then objectId is templateId
  //Else objectId is of a Task, then find templateId
  // object passed in is a task
  
  
  StringList slBusSelect = new StringList();
  slBusSelect.add(task.SELECT_ID);
  slBusSelect.add(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_TASK);
  slBusSelect.add(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);
  
  Map templateMap = task.getProject(context, slBusSelect);
  
  
  String palId = (String) templateMap.get(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_TASK);
		if (palId == null || palId.isEmpty()) {
			palId = (String) templateMap.get(ProgramCentralConstants.SELECT_PAL_PHYSICALID_FROM_PROJECT);
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

  

  /*External Cross project Dependency*/
  if(templateMap==null && subProjectId!=null) {
      templateId = subProjectId;
  } else {
  templateId = (String) templateMap.get(task.SELECT_ID);
  }
  /*External Cross project Dependency*/

  template.setId(templateId);
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // now build the tasklist (factors: hide all/show all; expand/collapse; add project)
  MapList taskList = new MapList();

  /*External Cross project Dependency*/
  MapList parent = new MapList();
  String projectType = "";
  if(subProjectId != null && !"null".equalsIgnoreCase(subProjectId) && !"".equals(subProjectId)) {
      DomainObject dom = new DomainObject();
      dom.setId(subProjectId);
      projectType = dom.getInfo(context,DomainConstants.SELECT_TYPE);
      String readAccess = dom.getInfo(context,"current.access[read]");
      HashMap map = new HashMap();
      map.put(task.SELECT_ID,subProjectId);
      map.put("current.access[read]",readAccess);
      parent.add(map);

  } else {
      parent = task.getParentInfo(context, 1, busSelects);
      projectType = task.getInfo(context,DomainConstants.SELECT_TYPE);
  }
  /*External Cross project Dependency*/

  boolean hasParentReadAccess = false;
  if (parent.size() > 0)
  {
    Map parentInfo = (Map) parent.get(0);
    String parentId = (String) parentInfo.get(task.SELECT_ID);
    project.setId(parentId);
    if("TRUE".equalsIgnoreCase((String)parentInfo.get("current.access[read]"))){
      hasParentReadAccess=true;
    }
  }
  if(hasParentReadAccess)
  {
    if (timeStamp == null) {
        //if for the first time then task is a project
        task.setId(templateId);
    }

    if(null != topTaskId && !"".equals(topTaskId)){
      task.setId(topTaskId);
      if(topTaskId.equals(objectId)) {
        topTaskId= task.getInfo(context, "to["+ DomainConstants.RELATIONSHIP_SUBTASK +"].from.id");
        task.setId(topTaskId);
      }
    }

      if(expanded.equals("false")) {
        taskList = task.getTasks(context, task, 1, busSelects, relSelects);
      } else {
        taskList = task.getTasks(context, task, 0, busSelects, relSelects);
      }
      if(multiTasksList != null) {
        int counter = 0;              //index counter for parentListItr
        boolean parentFound = false;  //If parent is found then brean from both loops
        if(expanded.equals("false")) {

          Iterator parentListItr = multiTasksList.iterator();
          while(parentListItr.hasNext()) {
            Map parentTaskMap = (Map) parentListItr.next();
            String parentWBS = (String) parentTaskMap.get(subtask.SELECT_TASK_WBS);
            String parentId = (String) parentTaskMap.get("id");
            //Loops thorugh child list
            Iterator childListItr = taskList.iterator();
            while(childListItr.hasNext()) {
              Map childTaskMap = (Map) childListItr.next();
              String childWBS = (String) childTaskMap.get(subtask.SELECT_TASK_WBS);
              Object childParentId =  childTaskMap.get("to[Subtask].from.id");
              //Remove everything after the last period for the childWBS
              String shortChildWBS = null;
          /*    if (childWBS.lastIndexOf('.') != -1) {
                shortChildWBS = childWBS.substring(0,childWBS.lastIndexOf('.'));
              }  else {
                shortChildWBS = parentWBS;
              }

              //If the child belongs to the parent, then set the childPlacementIndex
             if(shortChildWBS.equals(parentWBS)) {
                parentFound = true;
                break; //break from while childListItr.hsNext() loop
              }
            } //end while childListItr.hasNext()
            if (parentFound == true) {
              break; //break from while(parentListItr.hasNext()
            }*/

            if(childParentId instanceof StringList){
                StringList chParent = (StringList)childParentId;
                if(chParent.indexOf(parentId)>=0){
                     parentFound = true;
                     break;
                }
            } else if(childParentId instanceof String){
                String chParent = (String)childParentId;
                if(childParentId.equals(parentId)) {
                parentFound = true;
                break; //break from while childListItr.hsNext() loop
              }
            }
            } //end while childListItr.hasNext()
            if (parentFound == true) {
              break; //break from while(parentListItr.hasNext()
            }
            counter++;
          } //end while parentListItr.hasNext()
          multiTasksList.addAll(counter+1, taskList);
          // new maplist is created cotaning the unique the task 
          //as same tasks are getting added in the maplist multiple times which
          // was resulting in same task displayed multiple times after expand
          MapList mlMultiTaskList = new MapList();
          ArrayList arrList = new ArrayList();
          for(int i =0; i < multiTasksList.size(); i++)
          {
        	Map mMutliTaskMap =   (Map)multiTasksList.get(i);
        	String sObjectId = (String)mMutliTaskMap.get("id");
        	if(!arrList.contains(sObjectId))
        	{
        		arrList.add(sObjectId);
        		mlMultiTaskList.add(mMutliTaskMap);
        	}
          }
          multiTasksList.clear();
          multiTasksList.addAll(mlMultiTaskList);
          taskList.clear();
          taskList.addAll(multiTasksList);
        }
        else
        {
          //following removes tasks from taskList away from tasks in multiTasksList
          Iterator multiTasksListItr = multiTasksList.iterator();
          MapList combinedList = new MapList();
          while(multiTasksListItr.hasNext()) {
            boolean foundTask = false;
            Map tasksMap = (Map) multiTasksListItr.next();
            String tasksId = (String) tasksMap.get(task.SELECT_ID);
            Iterator taskListItr = taskList.iterator();
            while(taskListItr.hasNext()) {
              Map taskMap = (Map) taskListItr.next();
              String taskId = (String) taskMap.get(task.SELECT_ID);
              if(tasksId.equals(taskId)) {
                foundTask = true;
                break;
              }
            }
            if(!foundTask) {
              combinedList.add(tasksMap);
            }
          }
          // list needs to be updated to the new current list
          taskList = combinedList;
        }
      }
    // map the task id with an index number for dependencies; assign if the task is expanded or not;
    java.util.Hashtable indexMap = new Hashtable();
    Iterator listIndexItr = taskList.iterator();
    int listItrNum = 0;
    while (listIndexItr.hasNext()) {
      // index for dependencies
      Map listIndexObj = (Map) listIndexItr.next();
      String listId = (String) listIndexObj.get(task.SELECT_ID);
      String listItrStr = "" + listItrNum;
      indexMap.put (listId, listItrStr);
      listItrNum++;

      // expanding and collapsing part
      String isExpanded = (String) listIndexObj.get("EXPANDED");
      if(isExpanded == null || isExpanded.equals("null")) {
        listIndexObj.put("EXPANDED", "false");
        isExpanded = "false";
      }
      if(listId.equals(objectId) && multiTasksList != null) {
        if(isExpanded.equals("false")) {
          listIndexObj.put("EXPANDED", "true");
        } else {
          listIndexObj.put("EXPANDED", "false");
        }
      }
    //Added:nr2:PRG:R212:26 July 2011:IR-029016V6R2012x
      //Whatever the case may be if action==plus all tasks are expanded
      if("plus".equalsIgnoreCase(isShowAll)){
    	  listIndexObj.put("EXPANDED", "true");
      }
    //End:nr2:PRG:R212:26 July 2011:IR-029016V6R2012x
    }
    // Get person id and name
    person = person.getPerson(context);
    busSelects.clear();
    busSelects.add(person.SELECT_ID);
    busSelects.add(person.SELECT_NAME);
    busSelects.add(person.SELECT_FIRST_NAME);
    busSelects.add(person.SELECT_LAST_NAME);
    Map personMap     = (Map) person.getInfo(context, busSelects);
    String personId   = (String) personMap.get(person.SELECT_ID);
    String personName = (String) personMap.get(person.SELECT_NAME);
    // the following list of variables are used in the map iterator
    int row = 0;

    // set the session attribute to be able to past it along to itself
    Date time = new Date();
    if(timeStamp == null) {
        // create a new timestamp if one doesn't exist
        timeStamp = Long.toString(time.getTime());
    }
      //all the parents can not be depended
      StringList tempSelects = new StringList(1);
      tempSelects.add(task.SELECT_ID);
      tempSelects.add(task.SELECT_NAME);
      task.setId(topId);
      MapList tempParents = task.getParentInfo(context,0,tempSelects);
      MapList tempChildren = task.getTasks(context,task,0,tempSelects,null);
      if (tempParents != null) {
        Iterator tempParentItr = tempParents.iterator();
        while (tempParentItr.hasNext()) {
          Map tempParentObj = (Map) tempParentItr.next();
          String tempParentId = (String) tempParentObj.get(task.SELECT_ID);
          String tempParentName = (String) tempParentObj.get(task.SELECT_NAME);
          Iterator taskIndexItr = taskList.iterator();
          while (taskIndexItr.hasNext()) {
            Map taskIndexObj = (Map) taskIndexItr.next();
            String taskIndexId = (String) taskIndexObj.get(task.SELECT_ID);
            String taskIndexName = (String) taskIndexObj.get(task.SELECT_NAME);
            if (taskIndexId.equals(tempParentId)) {
              taskIndexObj.put("DEPENDABLE", "false");
            }
            //itself can not be depended
            if (taskIndexId.equals(topId)) {
              taskIndexObj.put("DEPENDABLE", "false");
            }
          }
        }
      }

      //all the children can not be depended
      if (tempChildren != null) {
        Iterator tempChildItr = tempChildren.iterator();
        while (tempChildItr.hasNext()) {
          Map tempChildObj = (Map) tempChildItr.next();
          String tempChildId = (String) tempChildObj.get(task.SELECT_ID);
          String tempChildName = (String) tempChildObj.get(task.SELECT_NAME);
          Iterator taskIndexItr = taskList.iterator();
          while (taskIndexItr.hasNext()) {
            Map taskIndexObj = (Map) taskIndexItr.next();
            String taskIndexId = (String) taskIndexObj.get(task.SELECT_ID);
            String taskIndexName = (String) taskIndexObj.get(task.SELECT_NAME);
            if (taskIndexId.equals(tempChildId)) {
              taskIndexObj.put("DEPENDABLE", "false");
            }
          }
        }
      }
      session.setAttribute("taskAllList" + timeStamp, taskList);
    }

  java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
  int rollId = 0;
  Hashtable ht = new Hashtable();
%>


  <body>
    <form name="EditTasks" method="post" onsubmit="submitFormAdd();return false">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	
      <input type="hidden" name="taskId" value="" />
      <input type="hidden" name="busID" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="level" value="" />
      <input type="hidden" name="requirement" value="" />
      <input type="hidden" name="state" value="" />
      <input type="hidden" name="selectedTaskParentState" value="" />
      <input type="hidden" name="topId" value="<xss:encodeForHTMLAttribute><%=topId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="projectId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="mainObjectId" value="<xss:encodeForHTMLAttribute><%=mainObjectId%></xss:encodeForHTMLAttribute>" />  <!-- Added 24-Aug-2010:PRG:rg6:R210:IR-063755V6R2011x  -->
      <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="expanded" value="<xss:encodeForHTMLAttribute><%=expanded%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="sessionTimeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="rootId" value="<xss:encodeForHTMLAttribute><%=rootId%></xss:encodeForHTMLAttribute>" />
      <table border="0" width="100%">
       <%-- XSSOK--%> 
              <framework:ifExpr expr="<%=showFindProjects && mxType.isOfParentType(context,projectType,DomainConstants.TYPE_PROJECT_SPACE)%>">
        <tr>
          <td>
          <img src = "../common/images/utilActionbarBullet.gif" />&nbsp;<a href = "javascript:performProjectSearch()" ><framework:i18n localize="i18nId">emxProgramCentral.Search.FindProjects</framework:i18n></a>
          </td>
        </tr>
        </framework:ifExpr>
        <tr>
          <td>
            <table class="list" border="0" width="100%">
              <!-- Setting up the table header -->
              <tr>
                <%-- XSSOK--%>
                   <framework:ifExpr expr="<%= taskList.size() != 0 && readWrite %>">
                  <th width="5%" style="text-align:center">
                    <input type="checkbox" name="selectAll" onClick="checkAll(this,'selectedIds');" />
                  </th>
                </framework:ifExpr>
                <th nowrap="nowrap" width="45%">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.Name</framework:i18n>
                </th>
                <th nowrap="nowrap" width="5%">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.ID</framework:i18n>
                </th>
                <th nowrap="nowrap" width="10%">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.WBS</framework:i18n>
                </th>
                <th nowrap="nowrap" width="15%">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.TaskType</framework:i18n>
                </th>
                <th nowrap="nowrap" width="5%">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.Owner</framework:i18n>
                </th>
                <th nowrap="nowrap" width="5%">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.DependencyType</framework:i18n>
                </th>
           <%
 //Added:10-Dec-09:wqy:R209:PRG:Keyword Duration
              DurationKeyword[] durationKeyword = DurationKeywordsUtil.getDurationKeywordsValueForDependancy(context,topId);
                if(null!=durationKeyword && durationKeyword.length>0)
                {
                %>
                <th nowrap="nowrap" width="5%">
                  <framework:i18n localize="i18nId">emxProgramCentral.DurationKeywords.DurationKeywords</framework:i18n>
                </th>
                <%
                }
 //End:R209:PRG :Keyword Duration
                %>
                <th nowrap="nowrap" width="5%">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.SlackTime</framework:i18n>
                </th>
              </tr>

              <framework:ifExpr expr="<%=hasParentReadAccess%>">
                <%-- XSSOK--%>
                      <framework:mapListItr mapList="<%= taskList %>" mapName="taskMap">
                  <!-- only display task if the user can set dependency (has displaystate of none) -->
                <%-- XSSOK--%>
                     <framework:ifExpr expr='<%= taskMap.get("DISPLAYSTATE") == null %>'>
<%
    // truncate the Name field to ensure it always displays evenly.
    // the icon image ALT will have the full name
    String taskName = (String) taskMap.get(task.SELECT_NAME);
  
	
	String taskPhysicalId = (String) taskMap.get(ProgramCentralConstants.SELECT_PHYSICALID);
	Dataobject taskObj = seqData.get(taskPhysicalId);
	String taskSeqId = (String)taskObj.getDataelements().get(ProgramCentralConstants.KEY_SEQ_ID);
	String taskLevel = (String)taskObj.getDataelements().get(ProgramCentralConstants.KEY_WBS_ID);
	
  

     /* Modified for bugIR-065616V6R2011x

    if (taskName.length() > 30) {
      taskName = taskName.substring(0,30);
    }END for bugIR-065616V6R2011x
     */
    String thisObjectType = (String) taskMap.get(task.SELECT_TYPE);
    String newURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, (String)taskMap.get(task.SELECT_ID));
    newURL += "&jsTreeID=" + jsTreeID + "&AppendParameters=true&treeMenu=";
    newURL += "&wbsNumber=" + XSSUtil.encodeForURL(context, (String)taskMap.get(subtask.SELECT_TASK_WBS));
    
    String isTaskExpanded =(String)taskMap.get("EXPANDED");
    
    String refreshURL = "emxProgramCentralDependencyAddDialog.jsp?objectId=" + XSSUtil.encodeForURL(context, (String)taskMap.get(task.SELECT_ID));
    refreshURL += "&mx.page.filter=" + showSel + "&jsTreeID=" + jsTreeID;
    refreshURL += "&expanded=" + isTaskExpanded + "&hasEditAccess=" + hasEditAccess;
    refreshURL += "&timeStamp=" + timeStamp + "&topId=" + XSSUtil.encodeForURL(context,topId);
    refreshURL += "&rootId=" + XSSUtil.encodeForURL(context,rootId) + "&mainObjectId=" + XSSUtil.encodeForURL(context, mainObjectId); //Modified 24-Aug-2010:PRG:rg6:R210:IR-063755V6R2011x
    // get the level for displaying reasons
    int level = 0;
    int count = 1;
    String wbs = (String) taskMap.get(subtask.SELECT_TASK_WBS);
    if(wbs.indexOf(".") > -1) {
      while(wbs.indexOf(".") > -1) {
        wbs = wbs.substring(wbs.indexOf(".") + 1, wbs.length());
        count++;
      }
    }
    int cnt = 0;

    //  Start Display sequence
    Object strParentId =  taskMap.get("to[Subtask].from.id");
    int n = ht.size();
    StringList val = null;
    StringList strParentList = new StringList();
    if(strParentId instanceof StringList){
        strParentList = (StringList)strParentId;
    } else {
        strParentList.addElement((String)strParentId);
    }

    if(strParentList.indexOf(rootId)>=0){
        val = (StringList)ht.get(new Integer(0).toString());
        if(val == null){
            ht.put("0",strParentList);
        }
        cnt = 0;
    } else {
        int i = 0;
        for(;i<n;i++){
            val = (StringList)ht.get(new Integer(i).toString());
            if(strParentList.equals(val)){
                cnt = i;
                break;
            } else{
                continue;
            }
        }
        if(i==n){
            cnt = n;
            ht.put(new Integer(n).toString(),strParentList);
        }
    }
    //  End Display sequence
    /*
    task1.setId(topId);
    MapList testList = task1.getTasks(context,task1,0,tempSelects,null);
     String parentId = (String) taskMap.get("to[Subtask].from.id");
     //out.println("ParentId"+parentId);
     for(int i=0; i< testList.size(); i++){
        Map childMap = (Map)testList.get(i);
        //out.println("childMap"+childMap);
        String parentOrgid = (String) childMap.get("id");
        out.println("parentOrgid"+parentOrgid);
        if(parentId.equals(parentOrgid)){
          count = Integer.parseInt((String) childMap.get("attribute[Task WBS].value"));
          out.println("count"+count);
          break;
        }
     }*/
//    }
      //level = count;
      level = cnt+1;
    //User might think page has an error if no tasks are displayed and nothing is printed to the screen
    //so need this boolean to tell if any tasks have been displayed
    taskDisplayed = true;
    //Setup Localized value for Task Type
    String i18nTaskType =  i18nNow.getTypeI18NString((String)taskMap.get(task.SELECT_TYPE),languageStr);
    String taskType = (String)taskMap.get(task.SELECT_TYPE);
    
	//Added:12-Mar-09:QZV:R207:ECH:Bug:369850
    String disabled = "";
    if(isECHInstalled) {
		//Modified:08-APR-09:QZV:R207:ECH:Bug:373345
        String allowDep = EnoviaResourceBundle.getProperty(context, "emxEnterpriseChange.AllowChangeTaskDependencies");
        com.matrixone.apps.domain.DomainObject doObj = new com.matrixone.apps.domain.DomainObject((String)taskMap.get(task.SELECT_ID));
        disabled = (doObj.isKindOf(context, project.TYPE_CHANGE_TASK) && "false".equalsIgnoreCase(allowDep)) ? "disabled" : "";
        //End:R207:ECH:Bug:373345
    }
	//End:R207:ECH:Bug:369850	
    
    String srcImage ="../common/images/iconSmallWBSTask.gif";
    if(taskType.equals(DomainConstants.TYPE_PROJECT_SPACE)){
            srcImage = "../common/images/iconSmallProject.gif";
    } else if(taskType.equals(DomainConstants.TYPE_PROJECT_CONCEPT)){
            srcImage = "../common/images/iconSmallProjectConcept.gif";
    }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //Workaround for limitation in win9x platform
    //If user is on win95 or win98, display buttons instead of drop down boxes
    String selectedDependencyTypeValue = "";
    String selectedDependencyTypeOption = "";
    String textfieldName = "";
    String lagFieldName = "";
    if (isWin9x) {
      selectedDependencyTypeValue = (String)taskMap.get("dependency");
      if(selectedDependencyTypeValue == null) {
        selectedDependencyTypeValue = "";
      }
      selectedDependencyTypeOption = i18nNow.getRangeI18NString(PropertyUtil.getSchemaProperty(context, "attribute_DependencyType"),selectedDependencyTypeValue,languageStr);
      textfieldName = "textfield" + ((String)taskMap.get(task.SELECT_ID)).replace('.','_');
      lagFieldName  = "lag_" + (String)taskMap.get(task.SELECT_ID);
    }

    String dependableString = (String)taskMap.get("DEPENDABLE");
    if (dependableString == null) {
       dependableString = "true";
    }
    String currentWBS = (String)taskMap.get(subtask.SELECT_TASK_WBS);
    
  //Added:nr2:PRG:R212:22 July 2012
    String id = (String)taskMap.get(task.SELECT_ID);
    boolean isOfTypeProject = false;
    if(ProgramCentralUtil.isNotNullString(id)){
        DomainObject dObj = DomainObject.newInstance(context,id);
        isOfTypeProject = (dObj.isKindOf(context,DomainConstants.TYPE_PROJECT_SPACE)|| dObj.isKindOf(context,DomainConstants.TYPE_PROJECT_CONCEPT))?true:false;
    }
  //End:nr2:PRG:R212:22 July 2012
    
%>
                    <tr class='<framework:swap id="1"/>'>
                        <td align="center" width="5%">
          <%-- XSSOK--%> 
                          <framework:ifExpr expr='<%=(dependableString.equals("true")) && !isOfTypeProject%>'>
                            <input type="checkbox" name="selectedIds" value="<xss:encodeForHTMLAttribute><%=taskMap.get(task.SELECT_ID)%></xss:encodeForHTMLAttribute>" <%=disabled %> /> <%-- XSSOK--%>
                          </framework:ifExpr>
                        </td>
                      <!-- Name column -->
                      <td width="10%" nowrap="nowrap">
                        <!-- Not a top level object, not a project template -->
                        <framework:ifExpr expr="<%=level >= 1%>">
                          <!-- display correct amount of indention spaces -->
                          <img src="../common/images/utilSpacer.gif" height="5" width="<%= (level-1)*10 %>" border="0" />
                          <!-- If the task has a subTask, show minus or plus icon -->
                   <%-- XSSOK--%> 
                          <framework:ifExpr expr='<%=(((String)taskMap.get(task.SELECT_HAS_SUBTASK) != null) && ((String)taskMap.get(task.SELECT_HAS_SUBTASK)).equalsIgnoreCase("true"))%>'>
                            <!-- if task is expanded, show the minus icon ((String) taskMap.get("EXPANDED")).equals("true") && -->
                              <!--added by ixe for IR-011601V6R2011-->
                            <%-- XSSOK--%> 
                             <framework:ifExpr expr='<%=( isTaskExpanded.equals("true"))%>'>
                              <a href="<%=refreshURL%>">  <%-- XSSOK --%> 
                              </a>
                            </framework:ifExpr>
                            <!-- else if the task is not expanded, show the plus icon  ((String) taskMap.get("EXPANDED")).equals("false") &&-->
                             <!--added by ixe for IR-011601V6R2011-->
                          <%-- XSSOK--%> 
                               <framework:ifExpr expr='<%=( isTaskExpanded.equals("false"))%>'>
                              <a href="<%=refreshURL %>"> <%-- XSSOK--%> 
                            </framework:ifExpr>
                          </framework:ifExpr>
                         <!-- Else if the task does not have any subTasks, display connection icon -->
                           <%-- XSSOK--%>
                            <framework:ifExpr expr='<%=!((String)taskMap.get(task.SELECT_HAS_SUBTASK) !=null && ((String)taskMap.get(task.SELECT_HAS_SUBTASK)).equalsIgnoreCase("true")) && level!=0%>'>
                           <!--  <img src="../common/images/utilTreeLineLast.gif" border="0" alt="" /> -->
                          </framework:ifExpr>
                        </framework:ifExpr>
                        <!-- Displays correct icon if object is a project or a task, and name of object -->
                          <img src="<xss:encodeForHTMLAttribute><%=srcImage%></xss:encodeForHTMLAttribute>" border="0" alt="<xss:encodeForHTMLAttribute><%= taskMap.get(task.SELECT_NAME) %></xss:encodeForHTMLAttribute>" />
						  <%-- XSSOK --%>
                          <a href="javascript:showDetailsPopup('<%=newURL%>')"><xss:encodeForHTML><%=taskName%></xss:encodeForHTML></a>
                      </td>
                      
                      <%-- <td nowrap="nowrap"><%=rollId++%></td>
                      <td nowrap="nowrap"><xss:encodeForHTML><%=taskMap.get(subtask.SELECT_TASK_WBS)%></xss:encodeForHTML></td> --%>
                     
                      <td nowrap="nowrap"><%=taskSeqId%></td>
                      <td nowrap="nowrap"><xss:encodeForHTML><%=taskLevel%></xss:encodeForHTML></td>
                      <td nowrap="nowrap"><%=i18nTaskType%></td>
                      <td nowrap="nowrap"><xss:encodeForHTML><%=taskMap.get(task.SELECT_OWNER)%></xss:encodeForHTML></td>
                      <td nowrap="nowrap">
<%
                      String selectedDependency = (String)taskMap.get("dependency");
                      if (selectedDependency == null){
                        selectedDependency ="";
                      }
%>
                        <framework:ifExpr expr="<%= readWrite %>">
                          <!-- //If user is on win95 or win98, display buttons instead of drop down boxes -->
                          <framework:ifExpr expr="<%= isWin9x %>">
                            <input type="text" name="<%=textfieldName%>" readonly="true" value="<xss:encodeForHTMLAttribute><%=selectedDependencyTypeOption%></xss:encodeForHTMLAttribute>" />
                            <input type="button" name="..." value="..." onclick="javascript:popupSelectDialog('<%=XSSUtil.encodeURLForServer(context,textfieldName)%>','','changeTextFieldValue','document.ManageDependencies.<%=XSSUtil.encodeURLForServer(context,textfieldName)%>.value','getDependencyTypeOptionList','getDependencyTypeValueList','emxProgramCentral.Common.DependencyType');" />
                            <input type="hidden" name="<%=textfieldName%>_value" value="<xss:encodeForHTMLAttribute><%=selectedDependencyTypeValue%></xss:encodeForHTMLAttribute>" />
                          </framework:ifExpr>
                          <!-- //If user is not on win95 or win98, display buttons drop down boxes -->
                          <framework:ifExpr expr="<%= !isWin9x %>">
                            <select name="<xss:encodeForHTMLAttribute><%=taskMap.get(task.SELECT_ID)%></xss:encodeForHTMLAttribute>" onChange="selectCheckBox(this, '<%=XSSUtil.encodeURLForServer(context, (String)taskMap.get(task.SELECT_ID)) %>','selectedIds');">
						<%-- XSSOK --%>
					   <framework:optionList optionList="<%=i18nDependencyTypeList%>" valueList="<%= dependencyTypeList%>"
                               selected='<%=i18nNow.getRangeI18NString(PropertyUtil.getSchemaProperty(context, "attribute_DependencyType"), selectedDependency, languageStr)%>'/></select>
                          </framework:ifExpr>
                        </framework:ifExpr>
						<%-- XSSOK--%>
                        <framework:ifExpr expr="<%= !readWrite %>">
                            <%=i18nNow.getRangeI18NString(PropertyUtil.getSchemaProperty(context, "attribute_DependencyType"), selectedDependency, languageStr)%>
                        </framework:ifExpr>
                      </td>
                      <!--Lag-->
                      
            <%
//Added:10-Dec-09:wqy:R209:PRG:Keyword Duration
                String strPreviousKeywordSelected = emxGetParameter (request, "durationKeyword_"+taskMap.get(task.SELECT_ID));
                if(null!=durationKeyword && durationKeyword.length>0)
                {
            %>
              <td nowrap="nowrap">
                 <framework:ifExpr expr="<%= readWrite %>">
                   <select id="<xss:encodeForHTMLAttribute>durationKeyword_<%=taskMap.get(task.SELECT_ID)%></xss:encodeForHTMLAttribute>" name="<xss:encodeForHTMLAttribute>durationKeyword_<%=taskMap.get(task.SELECT_ID)%></xss:encodeForHTMLAttribute>" size="1" onchange="populateDurationUnit('<%=XSSUtil.encodeURLForServer(context, (String)taskMap.get(task.SELECT_ID)) %>');">
<% 
                for( int i=0;i<durationKeyword.length;i++)
                {
                    if(i==0)
                    {
%>                      
                        <option value="NotSelected"></option>
<%                      
                    }
                    if (strPreviousKeywordSelected != null) 
                    {
%>
                        <option value="<xss:encodeForHTMLAttribute><%=durationKeyword[i].getName()+"|"+durationKeyword[i].getDuration()+"|"+durationKeyword[i].getUnit()%></xss:encodeForHTMLAttribute>" <%=(strPreviousKeywordSelected.equals(durationKeyword[i].getName()))?"selected":"" %> Title="<xss:encodeForHTMLAttribute><%=durationKeyword[i].getDescription()%></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%=durationKeyword[i].getName()%></xss:encodeForHTML></option>
<%                          
                    }
                    else 
                    {
%>
                        <option value="<xss:encodeForHTMLAttribute><%=durationKeyword[i].getName()+"|"+durationKeyword[i].getDuration()+"|"+durationKeyword[i].getUnit()%></xss:encodeForHTMLAttribute>" Title="<xss:encodeForHTMLAttribute><%=durationKeyword[i].getDescription()%></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%=durationKeyword[i].getName()%></xss:encodeForHTML></option>
<%                          
                    }
                }
%>
                    </select>
                    </framework:ifExpr>
                </td>
              <%
                }
 //End:R209:PRG :Keyword Duration
              %>
                      <td nowrap="nowrap">
                        <framework:ifExpr expr="<%= readWrite %>">
                          <input type="text" name="<xss:encodeForHTMLAttribute>lag_<%=taskMap.get(task.SELECT_ID)%></xss:encodeForHTMLAttribute>" id="<xss:encodeForHTMLAttribute>lag_<%=taskMap.get(task.SELECT_ID)%></xss:encodeForHTMLAttribute>" size="9" value="" onChange="validate(this, '<%=XSSUtil.encodeURLForServer(context, (String)taskMap.get(task.SELECT_ID))%>', 'selectedIds' );" />

						 <%
                         String dimensionName = MqlUtil.mqlCommand(context,"print attribute $1 select $2 dump",taskEstimatedDuration,"Dimension");

				         String units = MqlUtil.mqlCommand(context,"print Dimension $1 select $2 dump",dimensionName,"unit.label");
				         String[] unitsArray = units.split(",");
						 StringList unitOptionsList = new StringList();

				         String unitsVals = MqlUtil.mqlCommand(context,"print Dimension $1 select $2 dump",dimensionName,"unit.name");
				         String[] unitsArrayVals = unitsVals.split(",");
				         String unitLable=ProgramCentralConstants.EMPTY_STRING;	
						 StringList unitValueList = new StringList();
						 for( int i=0;i<unitsArray.length;i++){
							 // unitOptionsList.add(unitsArray[i]);
							 if(i==0)
							{				
								unitLable = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
										"emxProgramCentral.DurationUnits.Days", context.getSession().getLanguage());
							unitOptionsList.add(unitLable);
							}else if(i==1){
								unitLable = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
										"emxProgramCentral.DurationUnits.Hours", context.getSession().getLanguage());								
								unitOptionsList.add(unitLable);
							}
							unitValueList.add(unitsArrayVals[i]);
					      }
						%>
						<select id="<xss:encodeForHTMLAttribute>unit_<%=taskMap.get(task.SELECT_ID)%></xss:encodeForHTMLAttribute>" name="<xss:encodeForHTMLAttribute>unit_<%=taskMap.get(task.SELECT_ID)%></xss:encodeForHTMLAttribute>" onchange="checkDurationKeyword('<%=XSSUtil.encodeURLForServer(context, (String)taskMap.get(task.SELECT_ID)) %>')" onChanged="setField(this)">
							<framework:optionList
								optionList="<%=unitOptionsList%>"
								valueList="<%=unitValueList%>"
								selected=''/>
						</select>

                        </framework:ifExpr>
                      </td>
                      </tr>
                  </framework:ifExpr>
                </framework:mapListItr>

                <!--/td-->
                <!-- If the list has tasks, but none were displayed, display message to that effect -->
               <%-- XSSOK--%> 
                      <framework:ifExpr expr="<%= !taskList.isEmpty() && (taskDisplayed == false) %>">
                  <tr>
                    <td class="noresult" colspan="5">
                      <center><framework:i18n localize="i18nId">emxProgramCentral.Common.NoTasksToSetDependency</framework:i18n></center>
                    </td>
                  </tr>
                </framework:ifExpr>
              </framework:ifExpr>
              <framework:ifExpr expr = "<%=!hasParentReadAccess%>">
                <tr>
                  <td class="requiredNotice" align="center" valign="top" colspan="13">
                    <center><framework:i18n localize="i18nId">emxProgramCentral.Common.NoParentAccess</framework:i18n></center>
                  </td>
                </tr>
              </framework:ifExpr>
            </table>
          </td>
        </tr>
      </table>
    </form>

  </body>

  <script language="javascript" type="text/javaScript">//<![CDATA[
  <!-- hide JavaScript from non-JavaScript browsers

  <%if (isWin9x) {%>
      // fieldId is not busId, it is the id of the text and checkbox
      function popupSelectDialog(fieldId, attrName, methodName, selectedValue, optionListFuncName, valueListFuncName, tableTitle) {
        url = "emxProgramGUIPopupSelect.jsp?busId="+fieldId+"&attrName="+attrName+"&methodName="+methodName+"&selectedValue="+selectedValue+"&optionList="+optionListFuncName+"&valueList="+valueListFuncName+"&tableTitle="+tableTitle+"&returnOption=true";
        window.open(url,'SelectValue','height=280,width=250,status=no,toolbar=no,menubar=no,location=no,scrollbars=yes');
      }

      function getDependencyTypeValueList() {
    	  <%-- XSSOK--%> 
              dependencyList = new Array(<%=ProgramCentralUtil.optionListToCommaList(dependencyTypeList)%>);
       return dependencyList;
      }

      function getDependencyTypeOptionList() {
    	  <%-- XSSOK--%> 
            dependencyList = new Array(<%=ProgramCentralUtil.optionListToCommaList(i18nDependencyTypeList)%>);
        return dependencyList;
      }

      function changeTextFieldValue(fieldId, attrType, newOption, newValue) {
        checkboxName = "selectedIds";
        // Update the checkbox
        //**** Feature does not work currently ****.
        //selectedIds is not a unique name so eval(command) does not check box
        if (newValue != "None") {
          checked = true;
        }
        else {
          checked = false;
        }
        command = "document.EditTasks." + checkboxName + ".checked=" + checked;
        eval(command);

        // Change the option in the textfield
        command = "document.EditTasks." + fieldId + ".value='" + newOption + "'";
        eval(command);

        // Change value in the hidden textfield
        command = "document.EditTasks." + fieldId + "_value.value='" + newValue + "'";
        eval(command);
      }
    <%}%>

    function selectCheckBox(allbox, checkBoxValue, chkprefix) {
      form = allbox.form;
      max = form.elements.length;
      for (var i=0; i<max; i++) {
        fieldname = form.elements[i].name;

        if (fieldname.substring(0,chkprefix.length) == chkprefix) {
          foundValue = form.elements[i].value;
          if (foundValue == checkBoxValue) {
            form.elements[i].checked = true;
          }
        }
      }//end for loop
    }

    function clearAll() {
      // Mozilla not accepting reload.
      //parent.document.location.reload();
        parent.document.location.href = parent.document.location.href;
    }

    function validate(allElements, checkBoxValue, chkprefix){
      if (!validLagTime(allElements)){
        selectCheckBox(allElements, checkBoxValue, chkprefix);
      }
      checkDurationKeyword(checkBoxValue);
    }

    function validLagTime(allElements){
      form = allElements.form;
      max = form.elements.length;
      for (var i=0; i<max; i++) {
        fieldname = form.elements[i].name;
        if (fieldname.substring(0,3) == 'lag' )
        {
          lagTime = form.elements[i].value;
          if (lagTime != "" )
          {
            if (!isNumeric(lagTime) || (lagTime != form.elements[i].value.replace(/ /g,"")))
            {
              alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Financials.PleaseEnterOnlyNumbers</emxUtil:i18nScript>");
              form.elements[i].value = "";
              return true;
            }
          }
        }
      }//end for loop
      return false;//it didn't fail
    }// function validLagTime

    function checkAll (allbox, chkprefix) {
      form = allbox.form;
      max = form.elements.length;
      for (var i=0; i<max; i++) {
        fieldname = form.elements[i].name;
        if (fieldname.substring(0,chkprefix.length) == chkprefix) {
          form.elements[i].checked = allbox.checked;
        }
      }
    }

    function submitClose() {
      if(parent.window.getWindowOpener().parent.turnOffProgress)
      {
        parent.window.getWindowOpener().parent.turnOffProgress();
      }

      form = document.EditTasks;
      form.action = "emxProgramCentralDependencyProcess.jsp?popup=true&justCleanupSession=true&timeStamp=<%=XSSUtil.encodeForJavaScript(context,timeStamp)%>";
      form.submit();
    }

    function submitFormAdd() {
      form = document.EditTasks;
      chkprefix = 'selectedIds';
      max = form.elements.length;
      num = 0;
      MembersCount = 0;
      for (var i=0; i<max; i++) {
        fieldname = form.elements[i].name;
	// Fix for IR:R-055842V6R2011x: check the validity of lag time befor submit once.        
        if (fieldname.substring(0,3) == 'lag' )
        {
          lagTime = form.elements[i].value;
          if (lagTime != "" )
          {
            if (!isNumeric(lagTime) || (lagTime != form.elements[i].value.replace(/ /g,"")))
            {
              alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Financials.PleaseEnterOnlyNumbers</emxUtil:i18nScript>");
              form.elements[i].focus();
	      form.elements[i].select();
              return;
            }
          }
        }         
        // EOF:Fix for IR:R-055842V6R2011x
        
        if (fieldname.substring(0,chkprefix.length) == chkprefix) {
          MembersCount++;
          if(form.elements[i].checked == true) {
            num++;
          }
        }
      }
      if (num == 0) {
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.SelectItem</emxUtil:i18nScript>");
        return;
      } else {
        form.action = "emxProgramCentralDependencyProcess.jsp?popup=true&fromWBS=false&busId=<%=XSSUtil.encodeForJavaScript(context,topId)%>&timeStamp=<%=XSSUtil.encodeForJavaScript(context,timeStamp)%>";
        form.submit();
      }
   }

    function submitHideAllWBS() {
      form = document.EditTasks;
      hiddenView = "true";
      form.action = "emxProgramCentralDependencyAddDialogFS.jsp?hiddenView="+hiddenView+"&objectId="+form.mainObjectId.value+"&hasEditAccess=true&mode=internal&topTaskId=<%=XSSUtil.encodeForJavaScript(context,topTaskId)%>&cleanupTimeStamp=<%=XSSUtil.encodeForJavaScript(context,timeStamp)%>&externalDependency=<%=XSSUtil.encodeForJavaScript(context,externalDependency)%>&TemplateId=<%=XSSUtil.encodeForJavaScript(context,strTemplateId)%>"; //modified 24-Aug-2010:PRG:rg6:R210:IR-063755V6R2011x
      form.target = "_parent";
      form.submit();
    }


    function submitShowAllWBS() {
      form = document.EditTasks;
      hiddenView = "false";
      form.action = "emxProgramCentralDependencyAddDialogFS.jsp?hiddenView="+hiddenView+"&objectId="+form.mainObjectId.value+"&hasEditAccess=true&mode=internal&topTaskId=<%=XSSUtil.encodeForJavaScript(context,topTaskId)%>&cleanupTimeStamp=<%=XSSUtil.encodeForJavaScript(context,timeStamp)%>&externalDependency=<%=XSSUtil.encodeForJavaScript(context,externalDependency)%>&TemplateId=<%=XSSUtil.encodeForJavaScript(context,strTemplateId)%>";//modified 24-Aug-2010:PRG:rg6:R210:IR-063755V6R2011x
      form.target = "_parent";
      form.submit();
    }

    // Popup a chooser (Workaround for limitation in win9x platform, see Microsoft Knowledge Base Article - 265489 )

//Added:10-Dec-09:wqy:R209:PRG:Keyword Duration
    function populateDurationUnit(checkBoxValue)
    {
    	var durationKeyword = "durationKeyword_"+checkBoxValue;
    	var lag = "lag_"+checkBoxValue;
        var unit = "unit_"+checkBoxValue;
        var durationKeywordVal = document.getElementById(durationKeyword).value;
        if(durationKeywordVal!="NotSelected")
        {
            var temp = new Array();
            temp = durationKeywordVal.split('|');
            document.getElementById(lag).value = temp[1];
            document.getElementById(unit).value = temp[2];
        }
        else
        {
        	document.getElementById(lag).value = "";
        }
    }

    function checkDurationKeyword(checkBoxValue)
    {
    	var durationKeyword = "durationKeyword_"+checkBoxValue;
        var lag = "lag_"+checkBoxValue;
        var unit = "unit_"+checkBoxValue;
        var durationKeywordVal = document.getElementById(durationKeyword).value;
        if(durationKeywordVal!="NotSelected")
        {
            var temp = new Array();
            temp = durationKeywordVal.split('|');
            if(!(document.getElementById(lag).value==temp[1] && document.getElementById(unit).value==temp[2]))
            {
            	document.getElementById(durationKeyword).value="NotSelected";
            }
        }
    }
 //End:R209:PRG :Keyword Duration
  //Stop hiding here -->//]]>
  </script>
</html>
