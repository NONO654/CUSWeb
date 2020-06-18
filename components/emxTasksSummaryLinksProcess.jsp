<%-- emxTasksSummaryLinksProcess.jsp -- for Opening the Window on clicking the Top links in Content Page.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTasksSummaryLinksProcess.jsp.rca 1.23 Wed Oct 22 16:17:44 2008 przemek Experimental przemek $
--%>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc" %>

    <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
    <script language="javascript" src="../emxUIPageUtility.js"></script>
    <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

    <jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
    <%
     com.matrixone.apps.domain.DomainObject taskObject = new com.matrixone.apps.domain.DomainObject();
     com.matrixone.apps.common.Person person = new com.matrixone.apps.common.Person();
     com.matrixone.apps.common.Route rtObj   = new com.matrixone.apps.common.Route();
     formBean.processForm(session,request);
     String keyValue=emxGetParameter(request,"keyValue");

     if(keyValue == null){
             keyValue = formBean.newFormKey(session);
     }
     formBean.processForm(session,request,"keyValue");
     
     boolean blnAction=false;
    String objectId[] = formBean.getElementValues("emxTableRowId");
    String fromPage   = emxGetParameter(request,"fromPage");
    if( (fromPage == null) || (fromPage.equals("")) )
            fromPage   = (String)formBean.getElementValue("fromPage");
    String jsTreeID   = emxGetParameter(request,"jsTreeID");
    String suiteKey   = emxGetParameter(request,"suiteKey");
    String comments   = emxGetParameter(request,"txtComments");
    if( comments == null || comments.equals(""))
        comments   = (String)formBean.getElementValue("txtComments");
    String isFDAEntered   = emxGetParameter(request,"isFDAEntered");

    String attributeBracket = "attribute[";
    String closeBracket = "]";
    DomainRelationship domainRel            = null;
    String attrReviewCommentsNeeded         = PropertyUtil.getSchemaProperty(context, "attribute_ReviewCommentsNeeded");
    String sAttParallelNodeProcessonRule    = PropertyUtil.getSchemaProperty(context, "attribute_ParallelNodeProcessionRule");
    String strApprovalStatusAttr            = PropertyUtil.getSchemaProperty(context, "attribute_ApprovalStatus" );
    String attrTaskCommentsNeeded   =         PropertyUtil.getSchemaProperty(context, "attribute_TaskCommentsNeeded");
    String showComments          = EnoviaResourceBundle.getProperty(context,"emxComponents.Routes.ShowCommentsForTaskApproval");
    String ignoreComments        = EnoviaResourceBundle.getProperty(context,"emxComponentsRoutes.InboxTask.IgnoreComments");
    double clientTZOffset                   = (new Double((String)session.getValue("timeZone"))).doubleValue();
    String strAttrRouteTaskUser ="attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]";


    boolean bTaskCommentGiven               = false;
    boolean returnBack                      = false;
    String OFFSET_FROM_TASK_CREATE_DATE     = "Task Create Date";
    String routeTime                        = "";
    String taskComments       = "";
    String taskCommNeeded     = "";
    String strWorkspaceId   = "";
    String routeId  = "";
    String taskScheduledDate  = "";
    String taskStatus = fromPage;
	String routeTaskUserType ="";

		String[] onlyObjectId=new String[objectId.length];
		for(int arrIndex=0;arrIndex<objectId.length;arrIndex++)
		{
			onlyObjectId[arrIndex]=(objectId[arrIndex].indexOf("|")!=-1)?(objectId[arrIndex].substring(objectId[arrIndex].lastIndexOf("|")+1)):objectId[arrIndex];
		}
  if( ignoreComments == null || "".equals(ignoreComments) || "null".equals(ignoreComments)){
    ignoreComments = "false";
  }
  if( showComments == null || "".equals(showComments) || "null".equals(showComments)){
    showComments = "true";
  }

    //Getting the attributes from the Task Object

    StringBuffer sAttrComments =new StringBuffer(attributeBracket);
    sAttrComments.append(DomainConstants.ATTRIBUTE_COMMENTS);
    sAttrComments.append(closeBracket);
    StringBuffer sAttrReviewTask =new StringBuffer(attributeBracket);
    sAttrReviewTask.append(DomainConstants.ATTRIBUTE_REVIEW_TASK);
    sAttrReviewTask.append(closeBracket);
    StringBuffer sAttrRouteNodeId =new StringBuffer(attributeBracket);
    sAttrRouteNodeId.append(DomainConstants.ATTRIBUTE_ROUTE_NODE_ID);
    sAttrRouteNodeId.append(closeBracket);
    StringBuffer sAttrApprovalStatus =new StringBuffer(attributeBracket);
    sAttrApprovalStatus.append(DomainObject.ATTRIBUTE_APPROVAL_STATUS);
    sAttrApprovalStatus.append(closeBracket);
    StringBuffer sAttrScheduledCompletionDate =new StringBuffer(attributeBracket);
    sAttrScheduledCompletionDate.append(DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE );
    sAttrScheduledCompletionDate.append(closeBracket);

    StringList selectStmt = new StringList();
    selectStmt.addElement(sAttrComments.toString());
    selectStmt.addElement(sAttrReviewTask.toString());
    selectStmt.addElement(sAttrRouteNodeId.toString());
    selectStmt.addElement(sAttrApprovalStatus.toString());
    selectStmt.addElement(sAttrScheduledCompletionDate.toString());
    selectStmt.addElement("from["+DomainObject.RELATIONSHIP_ROUTE_TASK+"].to.id");
    selectStmt.addElement("from["+DomainObject.RELATIONSHIP_ROUTE_TASK+"].to.to["+DomainObject.RELATIONSHIP_ROUTE_SCOPE+"].from.id");
    selectStmt.addElement(strAttrRouteTaskUser);

	person=Person.getPerson(context);
    String personId = (String)person.getInfo(context,person.SELECT_ID);
    String personName = (String)person.getInfo(context,person.SELECT_NAME);

     String sRouteAction ="";
     String selRouteAction = "attribute["+taskObject.ATTRIBUTE_ROUTE_ACTION+"]";
     boolean blnRouteActionApprove=true;
     String taskId="";
     String routeTaskUser="";
    if(! fromPage.equals("RemoveCommand"))
    {
        for (int j=0 ;j< objectId.length; j++)
        {
        try{
				
                taskObject.setId(onlyObjectId[j]);
                sRouteAction = (String)taskObject.getInfo(context,selRouteAction);
                routeTaskUser= (String)taskObject.getInfo(context,strAttrRouteTaskUser);

				routeTaskUserType   = (String)taskObject.getInfo(context,"from["+DomainObject.RELATIONSHIP_PROJECT_TASK+"].to.type");
				
				                
				if( (sRouteAction != null) && (!sRouteAction.equals("Approve"))){
                        blnRouteActionApprove=false;
                        break;
                }
            } catch (Exception ex){
            session.putValue("error.message",ex.toString());
           }
         }
    }

    if(blnRouteActionApprove)
    {
        if( (fromPage.equals("ApproveCommand")) && (showComments.equalsIgnoreCase("false") ) )
        {
            fromPage="Approve";
            taskStatus = fromPage;
        }
        if( (fromPage.equals("RejectCommand")) && (ignoreComments.equalsIgnoreCase("true") ) )
        {
            fromPage="Reject";
            taskStatus = fromPage;
        }
    }

    String isFDAEnabled =  EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.EnableFDA");

    AttributeList attrList                  = new AttributeList();

     if( ((fromPage.equals("Approve") && !"true".equalsIgnoreCase(isFDAEnabled)) || (fromPage.equals("Reject") && !"true".equalsIgnoreCase(isFDAEnabled))) && blnRouteActionApprove || ("true".equalsIgnoreCase(isFDAEnabled) && "true".equalsIgnoreCase(isFDAEntered)))
      {
         blnAction=true;
         try{
            for (int index=0 ;index< objectId.length; index++)
            {
					
                    taskObject.setId(onlyObjectId[index]);
                    taskId=onlyObjectId[index];
                    Map taskInfoMap           = taskObject.getInfo(context, selectStmt);

                    taskComments       = (String)taskInfoMap.get(sAttrComments.toString());
                    taskCommNeeded     = taskObject.getAttributeValue(context , attrTaskCommentsNeeded);
                    strWorkspaceId                     = (String)taskInfoMap.get("from["+DomainObject.RELATIONSHIP_ROUTE_TASK+"].to.to["+DomainObject.RELATIONSHIP_ROUTE_SCOPE+"].from.id");
                    routeId                          = (String)taskInfoMap.get("from["+DomainObject.RELATIONSHIP_ROUTE_TASK+"].to.id");
                 
					taskScheduledDate                = (String)taskInfoMap.get(sAttrScheduledCompletionDate.toString());

                    rtObj.setId(routeId);
                    if("Yes".equals(taskCommNeeded)){
                        if(comments !=null && (!"".equals(comments.trim()))){
                                if(!trimStr(taskComments).equals(trimStr(comments))){
                                        bTaskCommentGiven =true;
                                }
                        }else{
                                bTaskCommentGiven =false;
                                comments="";
                        }
                        if(!bTaskCommentGiven){
                                returnBack = true;
                        }
                    }else{
                        if(comments !=null && (!"".equals(comments.trim()))){
                                // also compare with old comment
                                String oldComment=taskObject.getInfo(context,"attribute["+DomainConstants.ATTRIBUTE_COMMENTS+"]");
                                if(!oldComment.equals(comments)){
                                        bTaskCommentGiven =true;
                                }
                        }else{
                                bTaskCommentGiven =false;
                                comments="";
                        }
                   }
                    if (( fromPage.equals("Approve")) && (showComments.equalsIgnoreCase("false") ) )
                    {
                            returnBack=false;
                            bTaskCommentGiven=true;
                    }
                    if(( fromPage.equals("Reject")) && (ignoreComments.equalsIgnoreCase("true") ) )
                    {
                            returnBack=false;
                            bTaskCommentGiven=true;
                    }
                    if(!returnBack){
                            String strDateTime              = "";

                            if(taskScheduledDate != null && !"null".equals(taskScheduledDate) && !"".equals(taskScheduledDate)){
                                    strDateTime                     = taskScheduledDate;//eMatrixDateFormat.getFormattedInputDateTime(context,taskScheduledDate,routeTime,clientTZOffset,request.getLocale());
                            }
                            String routeNodeId        = (String)taskInfoMap.get(sAttrRouteNodeId.toString());
                            //Get the correct relId for the RouteNodeRel given the attr routeNodeId from the InboxTask.
                            routeNodeId = rtObj.getRouteNodeRelId(context, routeNodeId);
                            String reviewTask         = (String)taskInfoMap.get(sAttrReviewTask.toString());
                            if(bTaskCommentGiven){
                                    taskObject.setAttributeValue(context,attrTaskCommentsNeeded, "No");
                            } else {
                                    taskObject.setAttributeValue(context,attrTaskCommentsNeeded, "Yes");
                            }

                            // Setting the attributes to the task object
                            if (!"".equals(taskStatus)){
                                    attrList.addElement(new Attribute(new AttributeType(strApprovalStatusAttr), taskStatus));
                            }
                            if(!"".equals(strDateTime)){
                                    attrList.addElement(new Attribute(new AttributeType(DomainConstants.ATTRIBUTE_SCHEDULED_COMPLETION_DATE), strDateTime));
                            }
                            attrList.addElement(new Attribute(new AttributeType(DomainConstants.ATTRIBUTE_COMMENTS), comments));
                            taskObject.setAttributes(context,attrList);

                            String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceComponents.treeMenu.InboxTask");

                            if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
                                    MailUtil.setTreeMenuName(context, treeMenu );
                            }
                            // promote task object
                            if ("Yes".equalsIgnoreCase(reviewTask)){
                                    taskObject.promote(context);
                                    AttributeList attrList1 = new AttributeList();
                                    attrList1.addElement(new Attribute(new AttributeType(attrReviewCommentsNeeded), "Yes"));
                                    taskObject.setAttributes(context,attrList1);

                                    try{
                                            domainRel             = DomainRelationship.newInstance(context ,routeNodeId);
                                            Map attrMap           = new Hashtable();
                                            attrMap.put(attrReviewCommentsNeeded,"Yes");
                                            Route.modifyRouteNodeAttributes(context, routeNodeId, attrMap);
                                    }catch(Exception ex){
                                            session.putValue("error.message",ex.toString());
                                    }

                            }else{
                                    // do all operations for delta due-date offsets in this loop
                                    try {

                                            StringBuffer sAttrDueDateOffset =new StringBuffer(attributeBracket);
                                            sAttrDueDateOffset.append(DomainConstants.ATTRIBUTE_DUEDATE_OFFSET);
                                            sAttrDueDateOffset.append(closeBracket);
                                            StringBuffer sAttrDueDateOffsetFrom =new StringBuffer(attributeBracket);
                                            sAttrDueDateOffsetFrom.append(DomainConstants.ATTRIBUTE_DATE_OFFSET_FROM);
                                            sAttrDueDateOffsetFrom.append(closeBracket);
                                            StringBuffer sAttrSequence =new StringBuffer(attributeBracket);
                                            sAttrSequence.append(DomainConstants.ATTRIBUTE_ROUTE_SEQUENCE);
                                            sAttrSequence.append(closeBracket);
                                            String selState               = DomainObject.SELECT_CURRENT;  // get state

                                            StringList relSelects            = new StringList();

                                            StringBuffer sWhereExp           = new StringBuffer();
                                            int nextTaskSeq                  = 0;
                                            int currTaskSeq                  = 0;
                                            domainRel                     = DomainRelationship.newInstance(context ,routeNodeId);
                                            String currTaskSeqStr         = domainRel.getAttributeValue(context, DomainObject.ATTRIBUTE_ROUTE_SEQUENCE);
                                            String parallelType                  = domainRel.getAttributeValue(context, sAttParallelNodeProcessonRule);

                                            // get current / next task sequence
                                            if(currTaskSeqStr != null && !"".equals(currTaskSeqStr) && !"null".equals(currTaskSeqStr)){
                                                    currTaskSeq = Integer.parseInt(currTaskSeqStr);
                                                    nextTaskSeq = currTaskSeq+1;
                                            }
                                            relSelects.addElement(sAttrDueDateOffset.toString());
                                            relSelects.addElement(sAttrDueDateOffsetFrom.toString());
                                            relSelects.addElement(DomainObject.SELECT_RELATIONSHIP_ID);
                                            sWhereExp.append("(");
                                            sWhereExp.append(selState);
                                            sWhereExp.append(" != \"");
                                            sWhereExp.append(DomainObject.STATE_INBOX_TASK_COMPLETE);
                                            sWhereExp.append("\")");
                                            sWhereExp.append(" && (");
                                            sWhereExp.append(sAttrSequence.toString());
                                            sWhereExp.append(" == \"");
                                            sWhereExp.append(String.valueOf(currTaskSeq));
                                            sWhereExp.append("\")");
                                            // finds all same order tasks which are not yet complete; if any such exists, next offset task due-date is not set till all complete
                                            boolean shouldSetNextTaskDueDate = shouldSetNextTaskDueDate(context, rtObj,currTaskSeq+"");
                                            boolean completeAny              = true;
                                            if("All".equals(parallelType)){
                                                    completeAny = false;
                                            }
                                            // can proceed to set offset due-date for next task
                                            // only if Parallel node rule is 'Any' or corresponding flag got is true
                                            if(completeAny || shouldSetNextTaskDueDate){
                                                    // where clause filters to next order tasks offset from this task complete
                                                    sWhereExp = new StringBuffer();
                                                    sWhereExp.append("(");
                                                    sWhereExp.append(sAttrDueDateOffset.toString());
                                                    sWhereExp.append(" !~~ \"\")");
                                                    sWhereExp.append(" && (");
                                                    sWhereExp.append(sAttrDueDateOffsetFrom.toString());
                                                    sWhereExp.append(" ~~ \"");
                                                    sWhereExp.append(OFFSET_FROM_TASK_CREATE_DATE);
                                                    sWhereExp.append("\")");
                                                    sWhereExp.append(" && (");
                                                    sWhereExp.append(sAttrSequence.toString());
                                                    sWhereExp.append(" == \"");
                                                    sWhereExp.append(String.valueOf(nextTaskSeq));
                                                    sWhereExp.append("\")");
                                                    // get all next order tasks with offset from this task promotion / next task creation
                                                    MapList nextOrderOffsetList = getNextOrderOffsetTasks(context, rtObj, relSelects, sWhereExp.toString());

                                                    // set Scheduled Due Date attribute for all delta offset Route Nodes
                                                    Route.setDueDatesFromOffset(context, session, nextOrderOffsetList);
                                            }
                                    }catch(Exception e) {

                                            session.putValue("error.message",e.toString());

                                    }
                                    MapList subRouteList=rtObj.getAllSubRoutes(context);
									taskObject.promote(context);
                                    String sSubject =i18nNow.getI18nString("emxComponents.common.TaskDeletionNotice", "emxComponentsStringResource" ,sLanguage);
                                    String sMessage1=i18nNow.getI18nString("emxComponents.common.TaskDeletionMessage3", "emxComponentsStringResource" ,sLanguage);
                                    String sMessage2=i18nNow.getI18nString("emxComponents.common.TaskDeletionMessage2", "emxComponentsStringResource" ,sLanguage);
                                    String sMessage=sMessage1+" "+taskObject.getName()+" "+sMessage2;
                                    rtObj.deleteOrphanSubRoutes(context,subRouteList,sMessage,sSubject);
                                    // set Inbox Task title for auto-namer tasks
                                    try{
                                            ContextUtil.pushContext(context);
                                            InboxTask.setTaskTitle(context, routeId);
                                            ContextUtil.popContext(context);
                                        }catch(Exception ex){

                                            session.putValue("error.message",ex.toString());
                                        }
                                    // publish subscription events
                                    if (!"".equals(routeId)) {
                                            treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceComponents.treeMenu.Route");
                                            if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
                                                    MailUtil.setTreeMenuName(context, treeMenu );
                                            }
                                            StringList stringlist = new StringList(10);
                                            stringlist.clear();
                                            stringlist.add("id");
                                            stringlist.add("type");
                                            stringlist.add("grantor");
                                            stringlist.add("grantee");
                                            stringlist.add("granteeaccess");

                                            DomainObject domainobject1 = new DomainObject();
                                            domainobject1.setId(routeId);

                                            MapList maplist = domainobject1.getRelatedObjects(context, DomainConstants.RELATIONSHIP_OBJECT_ROUTE, "*", stringlist, DomainConstants.EMPTY_STRINGLIST, true, false, (short)1, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
                                            Map map1 = domainobject1.getInfo(context, stringlist);
                                            maplist.add(0, map1);
                                            Iterator iterator = maplist.iterator();
                                            while(iterator.hasNext()){
                                                    Map map2 = (Map)iterator.next();
                                                    Object obj1 = null;
                                                    Object obj2 = null;
                                                    Object obj3 = null;
                                                    Object obj4 = map2.get("grantor");
                                                    if((obj4 instanceof String) || obj4 == null){
                                                            if(obj4 == null || "".equals(obj4))
                                                                    continue;
                                                            obj1 = new ArrayList(1);
                                                            obj2 = new ArrayList(1);
                                                            obj3 = new ArrayList(1);
                                                            ((java.util.List) (obj1)).add(obj4);
                                                            ((java.util.List) (obj2)).add(map2.get("grantee"));
                                                            ((java.util.List) (obj3)).add(map2.get("granteeaccess"));
                                                    }else{
                                                            obj1 = (java.util.List)map2.get("grantor");
                                                            obj2 = (java.util.List)map2.get("grantee");
                                                            obj3 = (java.util.List)map2.get("granteeaccess");
                                                    }

                                                    String objId = (String)map2.get("id");
                                                    BusinessObject doc=new BusinessObject(objId);
                                                    doc.open(context);
                                                    if (doc.getTypeName().equals("Document")){

                                                            for(int i = 0; i < ((java.util.List) (obj1)).size(); i++) {
                                                                    String strGrantee = (String)((java.util.List) (obj2)).get(i);

                                                                    if(strGrantee.equals(personName)) {
                                                                            String strGrantor = (String)((java.util.List) (obj1)).get(i);

                                                                            if(strGrantor.equals(DomainConstants.PERSON_ROUTE_DELEGATION_GRANTOR)) {
                                                                            try {

                                                                                    ContextUtil.pushContext(context, DomainConstants.PERSON_ROUTE_DELEGATION_GRANTOR, null, context.getVault().getName());
                                                                                    String MQLstmt = "modify bus " + objId + " revoke grantor '" + strGrantor + "' grantee '" + personName + "';";
                                                                                    String MQLret = MqlUtil.mqlCommand(context, MQLstmt, false);

                                                                                    } catch(Exception exception4){
                                                                                            throw new FrameworkException(exception4);
                                                                                    }
                                                                                    finally{
                                                                                            ContextUtil.popContext(context);
                                                                                    }
                                                                            }
                                                                    }
                                                            }
                                                    }
                                                    doc.close(context);
                                            }
                                    }
                            }

                            //Publish Route Completed Event when Route goes to Complete State
                            String routeState = rtObj.getInfo(context,DomainObject.SELECT_CURRENT);
                            if(routeState != null && "Complete".equals(routeState)){
                                    treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceComponents.treeMenu.Route");
                                    boolean validTreeMenu=false;
                                    if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )){
                                            validTreeMenu=true;
                                    }
                                    String sScopeObjType = (String)rtObj.getInfo(context,"to["+rtObj.RELATIONSHIP_ROUTE_SCOPE+"].from.type");
                                    String sWorkspaceId = "";


                                    //To get the Workspace object to publish the corresponding subscribed events
                                    if(DomainConstants.TYPE_PROJECT_VAULT.equals(sScopeObjType)) {

                                            ContextUtil.pushContext(context);
                                            String sWorkspaceVaultId = rtObj.getInfo(context,"to["+rtObj.RELATIONSHIP_ROUTE_SCOPE+"].from.id");
                                            WorkspaceVault workspaceVault = (WorkspaceVault)DomainObject.newInstance(context ,sWorkspaceVaultId);

                                            if(validTreeMenu) {
                                                    MailUtil.setTreeMenuName(context, treeMenu );
                                            }
                                            sWorkspaceId = UserTask.getProjectId(context, sWorkspaceVaultId);
                                            ContextUtil.popContext(context);
                                    }else{

                                            ContextUtil.pushContext(context);
                                            sWorkspaceId  = rtObj.getInfo(context,"to["+rtObj.RELATIONSHIP_ROUTE_SCOPE+"].from.id");
                                            ContextUtil.popContext(context);
                                    }
                                    Workspace workspace =null;
                                    if((sWorkspaceId != null)|| sWorkspaceId.length()==0) {
                                            ContextUtil.pushContext(context);
                                            workspace = (Workspace)DomainObject.newInstance(context ,sWorkspaceId );

                                            if(validTreeMenu){
                                                    MailUtil.setTreeMenuName(context, treeMenu);
                                            }
                                            ContextUtil.popContext(context);
                                    }
                                    ContextUtil.pushContext(context);

                                    //To get list of documents attached to Route and publish Route Completed Event for the document
                                    StringList listContentIds = rtObj.getInfoList(context,"to["+rtObj.RELATIONSHIP_OBJECT_ROUTE+"].from.id");

                                    Document document = (Document)DomainObject.newInstance(context,DomainObject.TYPE_DOCUMENT);
                                    if(listContentIds == null){
                                            listContentIds = new StringList();
                                    }

                                    Iterator contentItr = listContentIds.iterator();

                                    while(contentItr.hasNext()){
                                            String sDocId = (String)contentItr.next();
                                            document.setId(sDocId);
                                            if(validTreeMenu) {
                                                    MailUtil.setTreeMenuName(context, treeMenu );
                                            }
                                    }

                                    if(validTreeMenu) {
                                            MailUtil.setTreeMenuName(context, treeMenu );
                                    }
                                    ContextUtil.popContext(context);
                            }
                    }
            }//end for task for
          } catch (Exception ex){ 
          session.putValue("error.message",ex.toString());
          }
      }
    %>
    <body>

    <%
      if( ((fromPage.equals("ApproveCommand"))|| (fromPage.equals("RejectCommand")) ) && (blnRouteActionApprove) && !routeTaskUserType.equals(DomainObject.TYPE_ROUTE_TASK_USER))
      {
    %>
      
     <script language="Javascript" >
        emxShowModalDialog('emxRouteTaskAddCommentsFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&isFDAEnabled=<%=isFDAEnabled%>',575, 575);
     </script>
    <% 
      }
      else if( ((fromPage.equals("ApproveCommand"))|| (fromPage.equals("RejectCommand")) ) && (blnRouteActionApprove) && routeTaskUserType.equals(DomainObject.TYPE_ROUTE_TASK_USER))
      {
    %>
     <script language="Javascript" >
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskSummary.TasksNotAccepted</emxUtil:i18nScript>");
     </script>
    <% 
      }
      else if("true".equalsIgnoreCase(isFDAEnabled) &&  (fromPage.equals("Approve") || fromPage.equals("Reject"))  && !"true".equalsIgnoreCase(isFDAEntered))
      {
    %>
     <script language="Javascript" >
         emxShowModalDialog('emxComponentsUserAuthenticationDialogFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&fromPage=<%=XSSUtil.encodeForURL(context, fromPage)%>',400, 400);
     </script>

    <% 
      }
      else if(fromPage.equals("RemoveCommand"))
      {
            blnAction=true;
            try{
                    for (int i=0 ;i< objectId.length; i++)
                    {
							
                            taskObject.setId(onlyObjectId[i]);
                            taskObject.deleteObject(context);
                    }
          } catch (Exception ex){ 

              session.putValue("error.message",ex.toString());}
      
      }
    %>
     <script language="Javascript" >
     <%
    if( (! blnRouteActionApprove)&&(!fromPage.equals("RemoveCommand")) )
      {
      %>
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskSummary.SelectApproveTask</emxUtil:i18nScript>");
    <%
    }

    if(blnAction && !fromPage.equals("RemoveCommand"))
    {
       if( (showComments.equalsIgnoreCase("true") && fromPage.equals("Approve")) || (ignoreComments.equalsIgnoreCase("false") && fromPage.equals("Reject")) || "true".equalsIgnoreCase(isFDAEntered))
       {
    %>
            var contentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
           contentFrame.document.location.href = contentFrame.document.location.href;
            window.closeWindow();
    <%
         }else if( (showComments.equalsIgnoreCase("false") && fromPage.equals("Approve")) || (ignoreComments.equalsIgnoreCase("true") && fromPage.equals("Reject")))
         {
    %>
                    parent.window.location.href = parent.window.location.href;
    <%
            }
      }else if(fromPage.equals("RemoveCommand"))
    {
    %>
             parent.window.location.href = parent.window.location.href;
    <%
    }
    %>
    </script>






 <%!
    // method gets all tasks of next order whose due-dates are offset from Task Complete Event
    // returns true only if all same sequence tasks with 'All' ParallelNode processing rule are completed
    public boolean shouldSetNextTaskDueDate(Context context, Route route, String currTaskSeq) throws Exception{

    boolean retVal =false;
    StringList objSelect=new StringList();
    objSelect.add(DomainObject.SELECT_ID);
    objSelect.add("attribute["+DomainObject.ATTRIBUTE_ROUTE_NODE_ID+"]");
    objSelect.add(DomainObject.SELECT_CURRENT);
    // get all Inbox Tasks
    MapList taskMapList = route.getRelatedObjects(context,
                                   Route.RELATIONSHIP_ROUTE_TASK, //String relPattern
                                   Route.TYPE_INBOX_TASK,         //String typePattern
                                   objSelect,                     //StringList objectSelects,
                                   null,                          //StringList relationshipSelects,
                                   true,                          //boolean getTo,
                                   false,                         //boolean getFrom,
                                   (short)1,                      //short recurseToLevel,
                                   "",                           //String objectWhere,
                                   "",                           //String relationshipWhere,
                                   null,                        //Pattern includeType,
                                   null,                        //Pattern includeRelationship,
                                   null);                       //Map includeMap

    // for getting all Same sequence tasks which are incomplete
     MapList incompleteSameSeqMapList=new MapList();
     Iterator it=taskMapList.iterator();
     String state = "";
     String relId = "";
     String currTaskSeqStr = "";
     DomainRelationship domRel = null;
     Hashtable hashTable = new Hashtable();
     while(it.hasNext()){
      hashTable=(Hashtable)it.next();
      state=(String)hashTable.get(DomainObject.SELECT_CURRENT);
      relId=(String)hashTable.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_NODE_ID+"]");
      
            //Get the correct relId for the RouteNodeRel given the attr routeNodeId from the InboxTask.
            relId = route.getRouteNodeRelId(context, relId);

      
      domRel=DomainRelationship.newInstance(context,relId);
      currTaskSeqStr    = domRel.getAttributeValue(context, DomainObject.ATTRIBUTE_ROUTE_SEQUENCE);
      if(currTaskSeq.equals(currTaskSeqStr) && !state.equalsIgnoreCase(DomainObject.STATE_INBOX_TASK_COMPLETE)){
        incompleteSameSeqMapList.add(hashTable);
      }
     }

     if(incompleteSameSeqMapList.size()==1 ){
      retVal=true;
     }
     return retVal;
    }
    %>

    <%!
    // method to get all tasks of next order whose due-dates are offset from Task Complete Event
    public MapList getNextOrderOffsetTasks(Context context, DomainObject route, StringList relSelects, String sWhereExp) throws Exception{

    MapList taskMapList = route.getRelatedObjects(context,
                                   Route.RELATIONSHIP_ROUTE_NODE, //String relPattern
                                    "*",                          //String typePattern
                                   null,                         //StringList objectSelects,
                                   relSelects,                     //StringList relationshipSelects,
                                   false,                     //boolean getTo,
                                   true,                     //boolean getFrom,
                                   (short)1,                 //short recurseToLevel,
                                   "",                       //String objectWhere,
                                   sWhereExp,           //String relationshipWhere,
                                   null,                     //Pattern includeType,
                                   null,                     //Pattern includeRelationship,
                                   null);                    //Map includeMap


    return taskMapList;

    }
    %>
    </body>
    <%!
    /*
      String from browser contains \n as well as \r this function removes \r
      from string for string comparison
    */
    public String trimStr(String val)
    {
       StringBuffer retBuffer=new StringBuffer();
       for(int i=0;i<val.length();i++)
       {
        if(val.charAt(i)!='\r'){
            retBuffer.append(val.charAt(i));
          }
       }
       return retBuffer.toString();
    }
    %>
