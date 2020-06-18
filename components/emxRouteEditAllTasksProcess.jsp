 <%--  emxRouteEditAllTasksProcess.jsp -  This page is to update the attribute values for route node.

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteEditAllTasksProcess.jsp.rca 1.12 Tue Oct 28 19:01:09 2008 przemek Experimental przemek $
  --%>

 <%@page import="com.matrixone.apps.domain.DomainConstants"%>
 <%@include file  = "../emxUICommonAppInclude.inc"%>
 <%@include file  = "emxRouteInclude.inc"%>
 <%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
 <%
 try {
   String sPersonIds[]                   = emxGetParameterValues(request, "personId");
   StringList personslist = new StringList();
   for(String taskAssignee : sPersonIds) {
	   personslist.add(taskAssignee);
   }
//   String sAssignedTaskID                = emxGetParameter(request, "assignedTaskID"); //Added for Bug-310065
   String sAssignedTaskID[]              = emxGetParameterValues(request, "assignedTaskOldID");
   String strOldAssigneeIds[]            = emxGetParameterValues(request, "assignedTaskOwner");
   String objectId                       = emxGetParameter(request, "objectId");
   String strRelIds[]                    = emxGetParameterValues(request, "relIds");
   String sRouteAction[]                 = emxGetParameterValues(request, "routeAction");
   String sInstructions[]                = emxGetParameterValues(request, "routeInstructions");
   String sTitle[]                       = emxGetParameterValues(request, "taskName");
   String sSequence[]                    = emxGetParameterValues(request, "routeOrder");
   String strTime[]                      = emxGetParameterValues(request, "routeTime");
   String strDeltaOffset[]               = emxGetParameterValues(request, "duedateOffset");
   String strDeltaOffsetFrom[]           = emxGetParameterValues(request, "duedateOffsetFrom");
   String AllowDelegations[]             = emxGetParameterValues(request, "AllowDelegationchkItem");
   String NeedsReview[]                  = emxGetParameterValues(request, "NeedsReviewchkItem");
   String strRouteStatus                 = emxGetParameter(request, "routeStatus");
   String strCurrentRouteLevel           = emxGetParameter(request, "currentRouteLevel");
   String strIsTaskStartedValues[]       = emxGetParameterValues(request, "isTaskStarted");
   String taskNeedsReview       = PropertyUtil.getSchemaProperty(context, "attribute_ReviewTask");
   String  sRelRouteTask                =  PropertyUtil.getSchemaProperty(context,"relationship_RouteTask");
   String  sAttRouteNodeID              =  PropertyUtil.getSchemaProperty(context,"attribute_RouteNodeID");
   String newTaskIds=emxGetParameter(request,"newTaskIds");
   String srecepientListArr[] 		=emxGetParameterValues(request,"recepientList");
   if (newTaskIds == null)
        newTaskIds="";

   String sDueDate                       = "";
   String sAttrValue                     = "";
   String routeInst                      = "";
   String routeOrd                       = "";
   String title                          = "";
   String routeAct                       = "";
   String person                         = "";
   String routeNodes                     = "";
   String templateId                     = "";
   String template                       = "";
   String sRelId                         = "";
   String treeUrl                        = "";
   String strIsTaskStarted               = "";

   Pattern relPattern                          = null;
   Pattern typePattern                         = null;
   RelationshipWithSelectItr relItr            = null;

   boolean bExecute                            = false;
   boolean bChange                             = false;

   //Added for the Bug No:350789 starts
   Map routeDetailsMap = new HashMap();
   //Added for the Bug No:350789 Ends

   Route boRoute = new Route(objectId);
   String sType = boRoute.getType(context);
   String parentTaskDueDate     =boRoute.getParentTaskDueDate(context,objectId);

   DomainObject newPersonObject = DomainObject.newInstance(context);

   //Place Holder for a Route Task User Object
   DomainObject rtaskUser = DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TASK_USER);

   String dateChecking  = "";
   if(sPersonIds !=null)
   {
   try {
     Integer integerType        = null;
     String iString             = "";
     String boolStr             = "No";
     String sDueDateOption      = "";
     boolean bAssigneeDueDate   = false;
     boolean bDeltaDueDate      = false;
     String routeScheduledCompletionDate = null;
     String routeScheduledCompletionDatemsValue = null;
     String duedateOption = null;
     String strDateTime    =  null;
     java.text.SimpleDateFormat USformatter = new java.text.SimpleDateFormat ("MM/dd/yyyy hh:mm:ss a");
     // looping into physical tasks - Complete and In progress.
     int iDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
     java.text.DateFormat formatter = DateFormat.getDateTimeInstance(iDateFormat, iDateFormat, request.getLocale());
     int intDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();

   if (strRelIds != null) {
     String dates[] = new String[strRelIds.length];
   String strdates[] = new String[strRelIds.length];
      String maxDueDate = emxGetParameter(request,"maxDueDateForJS");
      String maxOrder = emxGetParameter(request,"maxOrder");
     for (int i = 0; i < strRelIds.length; i++) {
       routeScheduledCompletionDate = emxGetParameter(request, "routeScheduledCompletionDate"+i);
       duedateOption = emxGetParameter(request, "duedateOption"+i);
       if(duedateOption.equals("calendar") && routeScheduledCompletionDate.equals("")){
           dateChecking = i18nNow.getI18nString("emxComponents.RouteAction.EnterdPastDate",
                           "emxComponentsStringResource",
                            context.getLocale().toString());
       }
       if(routeScheduledCompletionDate != null && !"null".equals(routeScheduledCompletionDate) && !"".equals(routeScheduledCompletionDate)){
         double clientTZOffset  = (new Double((String)session.getValue("timeZone"))).doubleValue();
         routeScheduledCompletionDate=eMatrixDateFormat.getFormattedInputDateTime(context,routeScheduledCompletionDate,strTime[i],clientTZOffset,request.getLocale());
         String tempDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, routeScheduledCompletionDate, true, intDateFormat, clientTZOffset,request.getLocale());
         Date dDueDate = formatter.parse(tempDate);
         dates[i] = USformatter.format(dDueDate);
         strdates[i] = routeScheduledCompletionDate;
       }// eof if loop
       else{
         dates[i] = null;
       }
     }// eof for loop
     if("".equals(dateChecking) && parentTaskDueDate != null)
     {
         dateChecking  = boRoute.dateCompare(context,sSequence,dates,maxDueDate,maxOrder,(String)session.getValue("timeZone"),request.getLocale(),parentTaskDueDate);
     }

     String sAllowDelegation    = null;
     String sReviewTask  = null;

     for (int i = 0; i < strRelIds.length; i++) {
       integerType   = new Integer(i);
       iString       = integerType.toString();
       sDueDateOption = emxGetParameter(request, "duedateOption"+iString);
       if(sDueDateOption == null || "null".equals(sDueDateOption)){
            sDueDateOption = "";
       }
       // boolStr temp string for determining whether this attribute has indeed changed; Only if yes, update to database
       if("assignee".equalsIgnoreCase(sDueDateOption)){
             boolStr          = "Yes";
             bAssigneeDueDate = true;
        }else{
             boolStr          = "No";
             bAssigneeDueDate = false;
        }
        if("delta".equalsIgnoreCase(sDueDateOption)){
          bDeltaDueDate = true;
        }else{
         bDeltaDueDate = false;
        }
       String personName = "";
       StringTokenizer st = new StringTokenizer(sPersonIds[i],"~");
       String personObject = st.nextToken();
       String attrRouteTaskUser = null;
       if ("none".equals(personObject)){
         personName = " ";
       }else if("Role".equalsIgnoreCase(personObject) || "Group".equalsIgnoreCase(personObject) || "UserGroup".equalsIgnoreCase(personObject)){
         personName = st.nextToken();
       }else{
         String id = st.nextToken();
         BusinessObject boPerson = new BusinessObject(id);
         boPerson.open(context);
         personName = JSPUtil.getAttribute(context, session,boPerson,newPersonObject.ATTRIBUTE_LAST_NAME)+", "+JSPUtil.getAttribute(context, session,boPerson,newPersonObject.ATTRIBUTE_FIRST_NAME);
         boPerson.close(context);
       }
       person    = person + personName + "~";
       if(sTitle[i].equals(""))
            title     = title +"none~";
       else
            title     = title + sTitle[i] + "~";
       routeInst = routeInst + sInstructions[i] + "~";
       routeOrd  = routeOrd + sSequence[i] + "~";
       routeAct  = routeAct + sRouteAction[i] + "~";
       strIsTaskStarted += strIsTaskStartedValues[i] + "~";

       Relationship relGeneric = null;

       DomainObject oldPerson = DomainObject.newInstance(context,strOldAssigneeIds[i]);
       String strKindOfProxyGroup = "type.kindof["+ PropertyUtil.getSchemaProperty(context, "type_GroupProxy") +"]";
       relGeneric = new Relationship(strRelIds[i]);
       StringList selects = new StringList(3);
       selects.add(DomainConstants.SELECT_TYPE);
       selects.add(DomainConstants.SELECT_NAME);
       selects.add(strKindOfProxyGroup);
       
       Map personDetails = oldPerson.getInfo(context,selects);
       
       String oldPersonType =(String)personDetails.get(DomainConstants.SELECT_TYPE);
       String oldPersonName =(String)personDetails.get(DomainConstants.SELECT_NAME);
       String oldPersonkindOfGroup =(String)personDetails.get(strKindOfProxyGroup);
       if(DomainObject.TYPE_PERSON.equals(oldPersonType)){
         strOldAssigneeIds[i]= "Person~"+strOldAssigneeIds[i];
       }else if("true".equalsIgnoreCase(oldPersonkindOfGroup)){
    	   strOldAssigneeIds[i]= "UserGroup~"+strOldAssigneeIds[i];
       }else{
         attrRouteTaskUser = FrameworkUtil.getRelAttribute(context,relGeneric, DomainObject.ATTRIBUTE_ROUTE_TASK_USER);
         if(attrRouteTaskUser==null || "".equals(attrRouteTaskUser)){
           strOldAssigneeIds[i] = "none~none";
         }else{
             if((attrRouteTaskUser.substring(0,attrRouteTaskUser.indexOf("_"))).equalsIgnoreCase("Role")){
                 strOldAssigneeIds[i] = "Role~"+attrRouteTaskUser;
             }else{
                 strOldAssigneeIds[i] = "Group~"+attrRouteTaskUser;
             }
         }
       }

    if (strOldAssigneeIds[i] != null && sPersonIds[i] != null && !(strOldAssigneeIds[i].equals(sPersonIds[i])) || ((null!=srecepientListArr) &&!srecepientListArr[i].isEmpty()&& !("Any".equals(srecepientListArr[i])))) {
         sRelId = strRelIds[i];
         DomainRelationship DoRelShip = new  DomainRelationship(sRelId);
         StringTokenizer tokenizer = new StringTokenizer(sPersonIds[i],"~");
		//Start: Added or Modified for Bug-310065
		 String persType = tokenizer.nextToken();
		 String persValue = tokenizer.nextToken();

         StringTokenizer tokenizerOld = new StringTokenizer(strOldAssigneeIds[i],"~");
         String persTypeOld = tokenizerOld.nextToken();
		 String persValueOld = tokenizerOld.nextToken();

		 if ("none".equals(persType)){
		   // Route.getRouteTaskUserObject() creates RTU object if no RTU is already connected and returns if the boolean parameter is passed as true
		   // If RTU is already connected then it returns the RTU object
           rtaskUser = Route.getRouteTaskUserObject(context, boRoute, true);

           DoRelShip.setAttributeValue(context,sRelId,DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
           DoRelShip.setAttributeValue(context,sRelId,DomainObject.ATTRIBUTE_ROUTE_TASK_USER_COMPANY,"");
           DoRelShip.modifyTo(context,sRelId,rtaskUser);
           relGeneric = new Relationship(sRelId);
         }else if("Role".equals(persType) || "Group".equalsIgnoreCase(persType)){
		   // Route.getRouteTaskUserObject() creates RTU object if no RTU is already connected and returns if the boolean parameter is passed as true
		   // If RTU is already connected then it returns the RTU object
	         if(("Role".equals(persType) && null!=srecepientListArr && !srecepientListArr[i].isEmpty()&&!("Any".equals(srecepientListArr[i])))) {
				DomainObject tempAssignPerson=PersonUtil.getPersonObject(context, srecepientListArr[i]);
		        DoRelShip.setAttributeValue(context,sRelId,DomainObject.ATTRIBUTE_ROUTE_TASK_USER,personName);
	            DoRelShip.modifyTo(context,sRelId,tempAssignPerson);
	            relGeneric = new Relationship(sRelId);
				DomainObject objPerson = new DomainObject();
				objPerson.setId(tempAssignPerson.getObjectId());
		   }
		   else {
           rtaskUser = Route.getRouteTaskUserObject(context, boRoute, true);

           DoRelShip.setAttributeValue(context,sRelId,DomainObject.ATTRIBUTE_ROUTE_TASK_USER,persValue); //Added for Bug-310065
           DoRelShip.setAttributeValue(context,sRelId,DomainObject.ATTRIBUTE_ROUTE_TASK_USER_COMPANY,"");
           DoRelShip.modifyTo(context,sRelId,rtaskUser);
           relGeneric = new Relationship(sRelId);

		   if(sAssignedTaskID[i]!=null && !"".equals(sAssignedTaskID[i])){
			   InboxTask inboxTaskObj = (InboxTask)DomainObject.newInstance(context,DomainConstants.TYPE_INBOX_TASK);
			   inboxTaskObj.setId(sAssignedTaskID[i]);
			   inboxTaskObj.reAssignTask(context, rtaskUser,persTypeOld, persValueOld, persType, persValue);
			}
		 }
		 }else{
           BusinessObject newPerson = new BusinessObject(persValue); //Added for Bug-310065
           newPersonObject.setId(newPerson.getObjectId());
           DoRelShip.setAttributeValue(context,sRelId,DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
           DoRelShip.modifyTo(context,sRelId,newPersonObject);
           relGeneric = new Relationship(sRelId);

		   DomainObject objPerson = new DomainObject();
		   objPerson.setId(newPerson.getObjectId());

		   if(sAssignedTaskID[i]!=null && !"".equals(sAssignedTaskID[i])){
			   InboxTask inboxTaskObj = (InboxTask)DomainObject.newInstance(context,DomainConstants.TYPE_INBOX_TASK);
			   inboxTaskObj.setId(sAssignedTaskID[i]);
			   inboxTaskObj.reAssignTask(context, objPerson, persTypeOld, persValueOld, persType, objPerson.getInfo(context, DomainConstants.SELECT_NAME));
			}
		 }
		 //End: Added or Modified for Bug-310065
		 //p9y need to remove the grants for thr existing users when selected none/Group?Role from the edit all page.		
		 if(DomainObject.TYPE_PERSON.equals(oldPersonType)){
			 Route.revokeAccessForOldAssigneeOnReassigningToGroup(context, objectId, sType, boRoute.getName(), oldPerson.getName(), oldPersonType, oldPerson.getId(context) );	 
		 }
		 if("Group".equals(oldPersonType) || "Proxy Group".equals(oldPersonType)){
			 if(!personslist.contains("UserGroup~"+oldPerson.getId(context))){
			 	DomainAccess.deleteObjectOwnership(context, objectId, null,oldPersonName,DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);
			 }
		 }
     } else {
         sRelId = strRelIds[i];
         relGeneric = new Relationship(sRelId);
     }
       relGeneric.open(context);
       routeNodes = routeNodes + sRelId + "~";

       // get all the attributes on the relationship into an iterator
       AttributeItr attrItrGeneric = new AttributeItr(relGeneric.getAttributes(context));
       AttributeList attrListGeneric = new AttributeList();
       //get the attribute values from the dialog page and put them in a list
       while (attrItrGeneric.next()) {
         Attribute attrGeneric = attrItrGeneric.obj();

         if (newPersonObject.ATTRIBUTE_ROUTE_ACTION.equals(attrGeneric.getName())) {
           if (sRouteAction[i] != null) {
             if ( !attrGeneric.getValue().equals(sRouteAction[i]) ) {
               bChange = true;
             }
             attrGeneric.setValue(sRouteAction[i]);
             attrListGeneric.addElement(attrGeneric);
           }

         } else if (newPersonObject.ATTRIBUTE_ROUTE_INSTRUCTIONS.equals(attrGeneric.getName())) {

           if (sInstructions[i] != null) {
             if ( !attrGeneric.getValue().equals(sInstructions[i]) ) {
               bChange = true;
             }
             attrGeneric.setValue(sInstructions[i]);
             attrListGeneric.addElement(attrGeneric);
           }

         }else if (DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE.equals(attrGeneric.getName())) {

             if ( !attrGeneric.getValue().equals(boolStr) ) {
               bChange = true;
             }
             if(bAssigneeDueDate){
               attrGeneric.setValue("Yes");
             }else{
               attrGeneric.setValue("No");
             }
              // reset assignee due-date if delta due date and itz assignee-set attribute value is not negative
             if(bDeltaDueDate && !attrGeneric.getValue().equals("No")){
               bChange = true;
               attrGeneric.setValue("No");
             }
             attrListGeneric.addElement(attrGeneric);

         }else if (DomainObject.ATTRIBUTE_DUEDATE_OFFSET.equals(attrGeneric.getName())) {

           if(bDeltaDueDate){
              if (strDeltaOffset[i] != null) {
                if (!attrGeneric.getValue().equals(strDeltaOffset[i]) ) {
                  bChange = true;
                }
                attrGeneric.setValue(strDeltaOffset[i]);
                attrListGeneric.addElement(attrGeneric);
              }
           }else{
             bChange = true;
             attrGeneric.setValue("");
             attrListGeneric.addElement(attrGeneric);
           }
           // reset delta offset if assignee due-date and itz due date offset attribute value is not empty
           if(bAssigneeDueDate && !attrGeneric.getValue().equals("")){
             bChange = true;
             attrGeneric.setValue("");
             attrListGeneric.addElement(attrGeneric);
           }

         }else if (DomainObject.ATTRIBUTE_DATE_OFFSET_FROM.equals(attrGeneric.getName())) {

           if(bDeltaDueDate){
            if (strDeltaOffsetFrom[i] != null) {
              if (!attrGeneric.getValue().equals(strDeltaOffsetFrom[i]) ) {
                     bChange = true;
              }
             attrGeneric.setValue(strDeltaOffsetFrom[i]);
             attrListGeneric.addElement(attrGeneric);
             }
           }

         }else if (newPersonObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE.equals(attrGeneric.getName()) && dateChecking.equals("")) {
           // set route scheduled completion date
              strDateTime = strdates[i];
             if(!bAssigneeDueDate && !bDeltaDueDate && strDateTime != null){
           Date dtUserValue  = eMatrixDateFormat.getJavaDate(strDateTime);
           Date dtAttrValue = null;

           if ( !attrGeneric.getValue().equals("") ) {
             dtAttrValue  = eMatrixDateFormat.getJavaDate(attrGeneric.getValue());
           } else if ( attrGeneric.getValue().equals("") ) {
             bChange = true;
           }
           if ( !attrGeneric.getValue().equals("") && !dtAttrValue.equals(dtUserValue) ) {
             bChange = true;
           }
          }else{
             if(!attrGeneric.getValue().equals("")){
                 bChange = true;
             }
             strDateTime = "";
          }
           attrGeneric.setValue(strDateTime);
           attrListGeneric.addElement(attrGeneric);

         }else if (newPersonObject.ATTRIBUTE_TITLE.equals(attrGeneric.getName())) {

           if (sTitle[i] != null) {
             if ( !attrGeneric.getValue().equals(sTitle[i]) ) {
               bChange = true;
             }
             attrGeneric.setValue(sTitle[i]);
             attrListGeneric.addElement(attrGeneric);
           }

         } else if (newPersonObject.ATTRIBUTE_ROUTE_SEQUENCE.equals(attrGeneric.getName()) && dateChecking.equals("")) {

           if (sSequence[i] != null) {
              attrListGeneric.addElement(attrGeneric);
            if ( !attrGeneric.getValue().equals(sSequence[i]) ) {
               bChange = true;
             }
             attrGeneric.setValue(sSequence[i]);
           }

         }else if (DomainObject.ATTRIBUTE_ALLOW_DELEGATION.equals(attrGeneric.getName())) {

			   sAllowDelegation    = emxGetParameter(request, "allowDelegation"+strRelIds[i]);

			   if(sAllowDelegation == null || "null".equals(sAllowDelegation)){
				  attrGeneric.setValue("FALSE");
				  attrListGeneric.addElement(attrGeneric);
			   }
			   else
			   {
				  if (!attrGeneric.getValue().equalsIgnoreCase("TRUE")){
						 bChange = true;
				  }
				  attrGeneric.setValue("TRUE");
				  attrListGeneric.addElement(attrGeneric);
				  
			   }

		 }else if (taskNeedsReview.equals(attrGeneric.getName())) {

			 sReviewTask  = emxGetParameter(request, "reviewTask"+strRelIds[i]);

			 if(sReviewTask == null || "null".equals(sReviewTask)){
				attrGeneric.setValue("No");
				attrListGeneric.addElement(attrGeneric);
			 }
			 else
			 {
				if (!attrGeneric.getValue().equalsIgnoreCase("Yes")){
					 bChange = true;
				}
				attrGeneric.setValue("Yes");
				attrListGeneric.addElement(attrGeneric);
			 }
         }
       }
	    //Added for the Bug No:350789 starts
		routeDetailsMap.put(relGeneric, attrListGeneric);
		//Added for the Bug No:350789 ends
			//Commented for the bug No:350789
       /*if ( sType.equals(newPersonObject.TYPE_ROUTE) || sType.equals(newPersonObject.TYPE_ROUTE_TEMPLATE) ) {

         relGeneric.setAttributes(context, attrListGeneric);

         if ( sType.equals(newPersonObject.TYPE_ROUTE) ) {

           AttributeItr attrItr = new AttributeItr(attrListGeneric);
           AttributeList attrList1 = new AttributeList();
           attrItr.reset();
           while (attrItr.next()) {
             String sAttrName = attrItr.obj().getName();
             if (!sAttrName.equals(newPersonObject.ATTRIBUTE_ROUTE_SEQUENCE)) {
               attrList1.addElement(attrItr.obj());
             }
           }

           relPattern                = new Pattern(newPersonObject.RELATIONSHIP_ROUTE_TASK);
           typePattern               = new Pattern(newPersonObject.TYPE_INBOX_TASK);

           ExpansionWithSelect projectSelect     = null;
           RelationshipWithSelectItr relItrTask  = null;

           SelectList selectStmts    = new SelectList();
           selectStmts.addName();
           selectStmts.addDescription();
           SelectList selectRelStmts = new SelectList();
           projectSelect = boRoute.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(), selectStmts, selectRelStmts,true,false,(short)1);
           boRoute.close(context);
           relItrTask           = new RelationshipWithSelectItr(projectSelect.getRelationships());
           BusinessObject boTask               = null;
           String sRouteNodeID  = "";

           while (relItrTask != null && relItrTask.next()) {
             boTask = relItrTask.obj().getFrom();
             boTask.open(context);
             sRouteNodeID = (String)JSPUtil.getAttribute(context,session,boTask,newPersonObject.ATTRIBUTE_ROUTE_NODE_ID);

             if ( sRelId.equals(sRouteNodeID) ) {
               boTask.setAttributes(context,attrList1);
               break;
             }
             boTask.close(context);
           }
         }

         relGeneric.close(context);
       }*/

     }
      routeDetailsMap.put("sType", sType);
	  // Modified for 356917
	  session.setAttribute("routeDetailsMap",routeDetailsMap);
   } else {
      for (int i = 0; i < sPersonIds.length; i++) {
       BusinessObject boPerson = new BusinessObject(sPersonIds[i]);
       boPerson.open(context);
       String personName = JSPUtil.getAttribute(context, session,boPerson,newPersonObject.ATTRIBUTE_LAST_NAME)+", "+JSPUtil.getAttribute(context, session,boPerson,newPersonObject.ATTRIBUTE_FIRST_NAME);
       boPerson.close(context);
       person    = person + personName + "~";
     }
   }

   boRoute.close(context);
 } catch (Exception ex ){
   session.putValue("error.message"," " + ex.getMessage());
   bExecute = true;
 %>
   <form name="newForm">
   </form>
   <html>
     <body>
       <script language="javascript">
        parent.window.location.href="emxRouteEditAllTasksDialogFS.jsp?objectId="+"<%=XSSUtil.encodeForURL(context, objectId)%>&sortName=true&newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>";
       </script>
     </body>
   </html>
 <%
   }
   treeUrl = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, objectId) +"&emxSuiteDirectory="+XSSUtil.encodeForURL(context, appDirectory)+"&AppendParameters=true";
   }
   if(!dateChecking.equals("")){
 %>
   <html>
     <body>
     <script language="javascript">
       alert("<%=XSSUtil.encodeForJavaScript(context, dateChecking)%>");
       parent.window.location.href="emxRouteEditAllTasksDialogFS.jsp?objectId="+"<%=XSSUtil.encodeForURL(context, objectId)%>&sortName=true&newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>";
    </script>
    </body>
   </html>
 <%
    }
   if(!bExecute) {
     if (newPersonObject.TYPE_ROUTE_TEMPLATE.equals(sType)) {
 %>
       <html>
       <body>
       <script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
       <script language="javascript">
         //var tree = getTopWindow().getWindowOpener().getTopWindow().tempTree;
         var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
         //XSSOK
         frameContent.document.location.href = "<%= treeUrl %>";
         window.closeWindow();
       </script>
       </body>
       </html>
 <%
     } else if (newPersonObject.TYPE_ROUTE.equals(sType)) {
       // to get the template id from route
       relPattern             =  new Pattern(newPersonObject.RELATIONSHIP_INITIATING_ROUTE_TEMPLATE);
       typePattern            = new Pattern(newPersonObject.TYPE_ROUTE_TEMPLATE);
       SelectList selectStmts = new SelectList();
       selectStmts.addName();
       SelectList selectRelStmts = new SelectList();
       ExpansionWithSelect projectSelect = null;
       projectSelect = boRoute.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(), selectStmts, selectRelStmts,false,true,(short)1);
       relItr        = new RelationshipWithSelectItr(projectSelect.getRelationships());

       while (relItr != null && relItr.next()) {
         BusinessObject boTemplate = relItr.obj().getTo();
         templateId = boTemplate.getObjectId();
         boTemplate.open(context);
         template = boTemplate.getName();
         boTemplate.close(context);
       }
 %>
       <form name="newForm" target="_parent">
         <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
         <input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeOrd%></xss:encodeForHTMLAttribute>"/>
		<!-- Bug No:306217  Dt:20-Jun-2005 -->
		<!-- //XSSOK -->
        <!--<input type="hidden" name="routeInstructions" value="<%=routeInst%>"/>-->
		<!-- Bug No:306217  Dt:20-Jun-2005 -->
         <input type="hidden" name="routeAction" value="<xss:encodeForHTMLAttribute><%=routeAct%></xss:encodeForHTMLAttribute>"/>
         <input type="hidden" name="personName" value="<xss:encodeForHTMLAttribute><%=person%></xss:encodeForHTMLAttribute>"/>
         <input type="hidden" name="title" value="<xss:encodeForHTMLAttribute><%=title%></xss:encodeForHTMLAttribute>"/>
         <input type="hidden" name="routeNode" value="<xss:encodeForHTMLAttribute><%=routeNodes%></xss:encodeForHTMLAttribute>"/>
         <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>"/>
         <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=template%></xss:encodeForHTMLAttribute>"/>
         <input type="hidden" name="sourcePage" value="EditAllTasks"/>
         <input type="hidden" name="newTaskIds" value="<xss:encodeForHTMLAttribute><%=newTaskIds%></xss:encodeForHTMLAttribute>"/>
         <input type="hidden" name="routeStatus" value="<xss:encodeForHTMLAttribute><%=strRouteStatus%></xss:encodeForHTMLAttribute>"/> <!-- Is the route started? -->
         <input type="hidden" name="currentRouteLevel" value="<xss:encodeForHTMLAttribute><%=strCurrentRouteLevel%></xss:encodeForHTMLAttribute>"/> <!-- What is the level of route executing? -->
         <input type="hidden" name="isTaskStarted" value="<xss:encodeForHTMLAttribute><%=strIsTaskStarted%></xss:encodeForHTMLAttribute>"/> <!-- Are the corresponding tasks started -->


       </form>
     <html>
       <body>
         <script language="javascript">
           document.newForm.action = "emxRouteWizardActionRequiredFS.jsp";
           document.newForm.submit();
         </script>
       </body>
     </html>
 <%
     }
   }
 } catch(Exception e){
   session.putValue("error.message",e.getMessage());
 }
 %>
