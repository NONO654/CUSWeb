<%--  emxProgramCentralAssigneeAddProcess.jsp

  Applies the results of the member search to the task.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralAssigneeAddProcess.jsp.rca 1.25.2.1 Thu Dec  4 12:37:03 2008 ds-ksuryawanshi Experimental $";
--%>
<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import =  "com.matrixone.apps.program.Task"%>
<%@ page import =  "com.matrixone.apps.program.RiskManagement"%>
<%@ page import =  "com.matrixone.apps.program.Opportunity"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<jsp:useBean id="effort" class="com.matrixone.apps.program.Effort" scope="request"/>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

<%
  com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, "PROGRAM");
  com.matrixone.apps.program.Risk risk = (com.matrixone.apps.program.Risk) DomainObject.newInstance(context, DomainConstants.TYPE_RISK, "PROGRAM");
//  com.matrixone.apps.program.Opportunity opportunity = (com.matrixone.apps.program.Opportunity) DomainObject.newInstance(context, RiskManagement.TYPE_OPPORTUNITY, "PROGRAM");
  com.matrixone.apps.common.AssignedTasksRelationship assignee = null;
  
  //Get paramters from url
  String objectId = emxGetParameter(request, "objectId");
  String languageStr = request.getHeader("Accept-Language");
  String strCommandName = emxGetParameter(request,"fromPage");  // [ADDED::PRG:RG6:Dec 30, 2010:IR-055926V6R2012:R211::OLD jsp is bypassed now redirected towards the search page]
  //Get results returned from search
  StringList searchResultList = (StringList)session.getAttribute("searchResultList");

  // Modified:V6R2010:PRG Autonomy search
	//
	// Added for Autonomy search integration
	//
	if (searchResultList == null) {
		searchResultList = new StringList();

		String[] emxTableRowId = emxGetParameterValues(request, "emxTableRowId");
		int numPeople = 0;
		if ( emxTableRowId != null ) {
			// get the number of people
			numPeople = emxTableRowId.length;
		}

		String strPersonId="";
		StringTokenizer strtokenizer = null;
		for (int intPCount = 0; intPCount < numPeople; intPCount++)
		{
			if(emxTableRowId[intPCount].indexOf("|") != -1) {
				strtokenizer = new StringTokenizer(emxTableRowId[intPCount], "|"); //PersonID|RelID

				strPersonId = strtokenizer.nextToken().trim();  //personID
				searchResultList.add (strPersonId +",");
			}
		}
	}
// End:V6R2010:PRG Autonomy search

  //remove session variable
  session.removeAttribute("searchResultList");
  
  // Start Bug 338718 - To handle multiple risk assignees updation
  String strObjectId ="";
  if(objectId.indexOf(",")>=0){
    strObjectId = objectId.substring(0,objectId.indexOf(","));
  } else {
    strObjectId = objectId;
  }
  // End Bug 338718
  
  boolean isARisk = false;

  //Test to see if objectId is a risk
  risk.setId(strObjectId);
  
  if (risk.getInfo(context, risk.SELECT_TYPE).equals(risk.TYPE_RISK) || risk.getInfo(context, risk.SELECT_TYPE).equals(Opportunity.TYPE_OPPORTUNITY)) {
    isARisk = true;
  }
  // get person IDs from the calling page.
  if (searchResultList != null){
    Iterator resultListItr = searchResultList.iterator();

    //If objexct type is a risk then add people to risk
    if(isARisk)
    {
      StringTokenizer tokenizer = new StringTokenizer(objectId,",",false);
      int tokens = tokenizer.countTokens();
      for(int m=0;m<tokens;m++){
          String riskId = tokenizer.nextToken();
          risk.setId(riskId);
      
      
      // Retrieve the assignees's list for a task
      MapList assigneesList = null;
      // Get list of assignees to this risk.
      StringList busSelects = new StringList(2);
      busSelects.add(task.SELECT_ID);
      busSelects.add(task.SELECT_NAME);

      StringList relSelects = new StringList(2);
      relSelects.add(assignee.SELECT_ID);
      relSelects.add(assignee.SELECT_ASSIGNEE_ROLE);
      assigneesList = risk.getAssignees(context, busSelects, relSelects, null, null);
      Iterator assigneesItr = assigneesList.iterator();
      HashMap riskAssigneeMap = new HashMap();
      while (assigneesItr.hasNext())
      {
        Map memberMap = (Map) assigneesItr.next();
        String name = (String) memberMap.get(task.SELECT_NAME);
        riskAssigneeMap.put(memberMap.get(task.SELECT_ID),name);
      }
      //Create an array containing all assignees
      int i = 0;
      ArrayList assignees = new ArrayList(searchResultList.size());
      //Loop through results sent in from search
      resultListItr = searchResultList.iterator();
      while (resultListItr.hasNext())
      {
        String userId = (String) resultListItr.next();
        int index = userId.indexOf(',');
        userId = userId.substring(0,index);
        if (!riskAssigneeMap.containsKey(userId)){
          assignees.add(userId);
          i++;
        }
      }
      // Put the assignees into a string array
      Iterator assigneeItr = assignees.iterator();
      if (i > 0){
        String[] assigneeArr = new String[i];
        int j = 0;
        while (assigneeItr.hasNext())
        {
          String theAssignee = (String) assigneeItr.next();
          assigneeArr[j] = theAssignee;
          j++;
        }
        risk.addAssignees(context, assigneeArr);
        //to send mail to Risk assignees
        StringList toList = new StringList();
        com.matrixone.apps.common.Person person = new com.matrixone.apps.common.Person();
        for(int k=0;k<assigneeArr.length;k++){
          if(assigneeArr[k]!=null && !"".equals(assigneeArr[k])){
            person.setId(assigneeArr[k]);
            toList.addElement(person.getName(context));
          }
        }
        
        String riskName = risk.getName(context);
        Map tempMap = risk.getParentInfo(context,busSelects);
        String projectName = (String)tempMap.get(risk.SELECT_NAME);
        String subjectKey = "emxProgramCentral.Common.AssignRisk.Subject";
        String[] subjectKeys = {};
        String[] subjectValues = {};

        String messageKey = "emxProgramCentral.Common.AssignRisk.Message";
        String[] messageKeys = {"riskName","projectName"};
        String[] messageValues = {riskName, projectName};

        ProjectConcept.sendNotification(context,
                                        riskId,
                                        toList,
                                        subjectKey,
                                        subjectKeys,
                                        subjectValues,
                                        messageKey,
                                        messageKeys,
                                        messageValues);
      } // if for all assignees
      } // for each rist
    }
    //Else, object type is a task
    else
    {
      try {
        // set the id
        task.setId(objectId);
        // start a write transaction and lock business object
        task.startTransaction(context, true);

        // Get list of persons already assigned to this task
        MapList assigneesList = null;
        StringList busSelects = new StringList(2);
        busSelects.add(task.SELECT_ID);
        busSelects.add(task.SELECT_NAME);
        StringList relSelects = new StringList(2);
        relSelects.add(assignee.SELECT_ID);
        relSelects.add(assignee.SELECT_ASSIGNEE_ROLE);
        assigneesList = task.getAssignees(context, busSelects, relSelects, null);

        HashMap taskAssigneeMap = new HashMap();
        Iterator assigneesItr = assigneesList.iterator();
        while (assigneesItr.hasNext())
        {
          Map memberMap = (Map) assigneesItr.next();
          String name = (String) memberMap.get(task.SELECT_NAME);
          taskAssigneeMap.put(memberMap.get(task.SELECT_ID),name);
        }
        boolean isAsssinged = false;
        while (resultListItr.hasNext())
        {
          String selectedPerson = (String) resultListItr.next();
          int index = selectedPerson.indexOf(',');
          selectedPerson = selectedPerson.substring(0,index);
          if (!taskAssigneeMap.containsKey(selectedPerson)){
            task.addAssignee(context, selectedPerson, null);
            isAsssinged = true;
            effort.updateRelAssignedDate(context,selectedPerson,objectId);
          }
        }
     // [ADDED::PRG:RG6:Jan 12, 2011:IR-075151V6R2012 :R211::Start]
        String strAssignStateName = PropertyUtil.getSchemaProperty(context,"policy",DomainConstants.POLICY_PROJECT_TASK,"state_Assign");
        
	        if(isAsssinged)
	        {
                     Map mapTaskParam = new HashMap();
               	     mapTaskParam.put("taskId",objectId);
            
                  if(Task.isToMoveTaskInToAssignState(context,mapTaskParam))
                  {
	             task.setState(context,strAssignStateName);  
	           }
                }
         // [ADDED::PRG:RG6:Jan 12, 2011:IR-075151V6R2012 :R211::End]
        // commit the data
        ContextUtil.commitTransaction(context);

      }
      catch (Exception e) 
      {
          ContextUtil.abortTransaction(context);
          throw e;
      }
    }
  }
%>
<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    // Modified:V6R2010:PRG Autonomy search
      // [MODIFIED::PRG:rg6:Dec 23, 2010:IR-060464V6R2012 :R211::Start]
    var commandName = "<%=XSSUtil.encodeForJavaScript(context,strCommandName)%>";  
    if(commandName == "fromWBSMainSBPage"){    	
    	//getTopWindow().getWindowOpener().parent.refreshSBTable(getTopWindow().getWindowOpener().parent.configuredTableName);
    	<%
    	if(!ProgramCentralUtil.is3DSearchEnabled(context)){
    	%>
    	getTopWindow().close();
    	<%}%>
    }
    else if(commandName != null && commandName == "assignSelectedFromActionHidden"){
        <%
    	if(!ProgramCentralUtil.is3DSearchEnabled(context)){
    	%>
	    	getTopWindow().parent.getWindowOpener().parent.location.href = getTopWindow().parent.getWindowOpener().parent.location.href;
	    	getTopWindow().close();
		<%}%>
		var topFrame = findFrame(getTopWindow(), "PMCAssignee");
			if(topFrame == null){
			topFrame = findFrame(getTopWindow(), "detailsDisplay");
			}
	    	if (topFrame != null) {
			topFrame.location.href = topFrame.location.href;
		}else{
			getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
			getTopWindow().close();
		}
    }
    else if(commandName != null && commandName == "LRASubmissionAssigneeAdd"){
    	getTopWindow().parent.getWindowOpener().parent.location.href = getTopWindow().parent.getWindowOpener().parent.location.href;
    	getTopWindow().close();
    }
    else{
    	getTopWindow().parent.getWindowOpener().location.href = getTopWindow().parent.getWindowOpener().location.href;
    	getTopWindow().close();
    }
    
  </script>
</html>
