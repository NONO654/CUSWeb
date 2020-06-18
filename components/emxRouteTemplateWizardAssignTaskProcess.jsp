<%--  emxRouteTemplateWizardAssignTaskProcess.jsp   --  Editing Route object

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $: Exp $
 --%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%

String keyValue=emxGetParameter(request,"keyValue");


if(keyValue == null){
 keyValue = formBean.newFormKey(session);
}
formBean.processForm(session,request,"keyValue");


%>

<%!

  private static final String routeActionStr                   = DomainConstants.ATTRIBUTE_ROUTE_ACTION;
  private static final String routeSequenceStr                 = DomainConstants.ATTRIBUTE_ROUTE_SEQUENCE;
  private static final String routeInstructionsStr             = DomainConstants.ATTRIBUTE_ROUTE_INSTRUCTIONS;
  private static final String routeScheduledCompletionDateStr  = DomainConstants.ATTRIBUTE_SCHEDULED_COMPLETION_DATE;
  private static final String taskNameStr                      = DomainConstants.ATTRIBUTE_TITLE;
  private static final String routeAllowDelegation             = DomainConstants.ATTRIBUTE_ALLOW_DELEGATION;
  private static final String relRouteNode                     = DomainConstants.RELATIONSHIP_ROUTE_NODE;

  private static final class Helper {

  private final String routeAssigneeDueDateOpt          ;
  public  final String taskNeedsReview                  ;
  private final String routeDueDateOffset               ;
  private final String routeDueDateOffsetFrom           ;

          public Helper(String routeAssigneeDueDateOpt, String taskNeedsReview, String routeDueDateOffset, String routeDueDateOffsetFrom) {
                this.routeAssigneeDueDateOpt          =routeAssigneeDueDateOpt          ;
                this.taskNeedsReview                  =taskNeedsReview                  ;
                this.routeDueDateOffset               =routeDueDateOffset               ;
                this.routeDueDateOffsetFrom           =routeDueDateOffsetFrom           ;
          }

  public HashMap setTaskMapList(Context context , String sRouteNodeId,
                              String sRouteAction,
                              String sRoutePersonId,
                              String sTaskName,
                              String sRouteAllowDelegation,
                              String sTaskNeedsReview,
                              String sRouteOrder,
                              String sRouteInstructions,
                              String sRouteDateTime,
                              String sAssigneeDueDateOption,
                              String sDueDateOffset,
                              String sDueDateOffsetFrom,
                              boolean bDeltaDueDate , String sTaskFlag)
         //throws MatrixException,java.text.ParseException 
         {
             return setTaskMapList(context , sRouteNodeId,
                              sRouteAction,
                              sRoutePersonId,
                              sTaskName,
                              sRouteAllowDelegation,
                              sTaskNeedsReview,
                              sRouteOrder,
                              sRouteInstructions,
                              sRouteDateTime,
                              sAssigneeDueDateOption,
                              sDueDateOffset,
                              sDueDateOffsetFrom,
                               bDeltaDueDate , sTaskFlag, null);
  }

  public HashMap setTaskMapList(Context context , String sRouteNodeId,
                              String sRouteAction,
                              String sRoutePersonId,
                              String sTaskName,
                              String sRouteAllowDelegation,
                              String sTaskNeedsReview,
                              String sRouteOrder,
                              String sRouteInstructions,
                              String sRouteDateTime,
                              String sAssigneeDueDateOption,
                              String sDueDateOffset,
                              String sDueDateOffsetFrom,
                              boolean bDeltaDueDate , String sTaskFlag,String strRoleUser)
         //throws MatrixException,java.text.ParseException 
         {


  HashMap routeNodeMap = new HashMap();

  //setting Route Node ID.
  routeNodeMap.put(relRouteNode,sRouteNodeId);

  //setting task action
  routeNodeMap.put(routeActionStr,sRouteAction);

try {

  StringTokenizer sToken = new StringTokenizer(sRoutePersonId, "~");
  DomainObject personObj = DomainObject.newInstance(context);



  //setting Person Name and Id.
  while(sToken.hasMoreElements()) {
  String pId   = (String)sToken.nextToken();
  String pName = (String)sToken.nextToken();

  routeNodeMap.put("PersonId",pId);
  routeNodeMap.put("PersonName",pName);


    if(pId != null && !"".equals(pId) && !"none".equals(pId) && !(("Role".equals(pId))||("Group".equals(pId))))
    {

   personObj.setId(pId);
         routeNodeMap.put(DomainConstants.SELECT_NAME,personObj.getName(context));
        //Commeted for Testing purpose
        //routeNodeMap.put(DomainConstants.SELECT_NAME,pName);

    }
/* if(pId != null && !"".equals(pId) && !"none".equals(pId) && !"Group".equals(pId))
    {

   personObj.setId(pId);
         routeNodeMap.put(DomainConstants.SELECT_NAME,personObj.getName(context));
        //Commeted for Testing purpose
        //routeNodeMap.put(DomainConstants.SELECT_NAME,pName);

    }*/
  }
}catch(Exception e) {

}


  //setting task Name
  routeNodeMap.put(taskNameStr,sTaskName);

  //setting AllowDelegation Value.
  routeNodeMap.put(routeAllowDelegation,sRouteAllowDelegation);
  routeNodeMap.put(taskNeedsReview,sTaskNeedsReview);
  //setting Sequence order
  routeNodeMap.put(routeSequenceStr,sRouteOrder);

    //setting Instructions
  routeNodeMap.put(routeInstructionsStr,sRouteInstructions);
//  if(sRouteDateTime != null && !"".equals(sRouteDateTime))
//  {
  routeNodeMap.put(routeScheduledCompletionDateStr,sRouteDateTime);
//  }
  //  setting due-date mode - Assignee-set or other options.
  routeNodeMap.put(routeAssigneeDueDateOpt, sAssigneeDueDateOption);

  // if this boolean is passed false, its not a delta task
  if(bDeltaDueDate){
     //  setting due-date offset in days
     routeNodeMap.put(routeDueDateOffset, sDueDateOffset);

     //  setting due-date offset from
     routeNodeMap.put(routeDueDateOffsetFrom, sDueDateOffsetFrom);

     // reset assignee due option if delta date.
     sAssigneeDueDateOption = "No";
     routeNodeMap.put(routeAssigneeDueDateOpt, sAssigneeDueDateOption);
   }else{
     // reset any existing delta offset value if not delta option now
     routeNodeMap.put(routeDueDateOffset, "");
  }
  routeNodeMap.put("templateFlag" , sTaskFlag);
  routeNodeMap.put("recepient" , strRoleUser);
  return routeNodeMap;
}
  }
%>


<%


  com.matrixone.apps.common.Person personObject = null;

   Helper h = new Helper(PropertyUtil.getSchemaProperty(context, "attribute_AssigneeSetDueDate"),
		   		PropertyUtil.getSchemaProperty(context, "attribute_ReviewTask"), 
		   		PropertyUtil.getSchemaProperty(context, "attribute_DueDateOffset"),
             	PropertyUtil.getSchemaProperty(context, "attribute_DateOffsetFrom"));

  String routePersonId[]          = emxGetParameterValues(request, "personId");
  String routeOrder[]               = emxGetParameterValues(request, "routeOrder");
  String routeAction[]              = emxGetParameterValues(request, "routeAction");
  String routeInstructions[]        = emxGetParameterValues(request, "routeInstructions");
  String routeTime[]                = emxGetParameterValues(request,"routeTime");
  String taskName[]                 = emxGetParameterValues(request,"taskName");
  String linkFlag                   = emxGetParameter(request, "linkFlag");
  String routeNodeId[]              = emxGetParameterValues(request, "routeNodeId");
  String chkrouteNode[]             = emxGetParameterValues(request, "chkItem1");
  String AllowDelegations[]         = emxGetParameterValues(request, "AllowDelegationchkItem");
  String NeedsReview[]              = emxGetParameterValues(request, "NeedsReviewchkItem");
  String strDeltaOffset[]           = emxGetParameterValues(request, "duedateOffset");
  String strDeltaOffsetFrom[]       = emxGetParameterValues(request, "duedateOffsetFrom");
  String templateFlagArr[]          = emxGetParameterValues(request, "templateTask");
  String sRecepientArr[]          = emxGetParameterValues(request, "recepientList");





  double clientTZOffset   = (new Double((String)session.getValue("timeZone"))).doubleValue();



     String projectId  =  (String) formBean.getElementValue("projectId");
     String templateId    =  (String) formBean.getElementValue("templateId");
     String templateName  =  (String) formBean.getElementValue("templateName");
     String portalMode    =  (String) formBean.getElementValue("portalMode");

     String toAccessPage       =  (String) emxGetParameter(request,"toAccessPage");
     String slctdd   =  (String) formBean.getElementValue("slctdd");
     String slctmm    =  (String) formBean.getElementValue("slctmm");
     String slctyy    =  (String) formBean.getElementValue("slctyy");



  if(toAccessPage == null || "null".equals(toAccessPage)){
    toAccessPage = "";
  }
  int routeNodeIds                  = 0;
  int tempRouteNodeIds              = 0;

  boolean bExecute                  = false;
  boolean bDeltaDueDate             = false;
  String sAllowDelegation           = "FALSE";
  String sDueDateOption             = "";
  String sAssigneeDueDateOption     = "";
  String sNeedsReview               = "No";

    String person = "";
    String routeInst="";
    String routeOrd="";
    String routeAct="";
    String routeNodes="";
    String sRouteTaskUser = "";
    String sPersonId = "";
    String sPersonName = "";
    String assigneeType="";
    String strRoleUser="";

  try {

    MapList taskMaplist = new MapList();


 if (routeNodeId != null) {


      for (int i = 0; i < routeNodeId.length; i++) {
       strRoleUser= "";
		if(null!=sRecepientArr && null!=sRecepientArr[i]){
			strRoleUser=sRecepientArr[i];
		}
        String strDateTime     = "";

        String strDate         = emxGetParameter(request, "routeScheduledCompletionDate"+i) ;
        sDueDateOption         = emxGetParameter(request, "duedateOption"+i) ;


        if(sDueDateOption == null || "null".equals(sDueDateOption) || "".equals(sDueDateOption)){
            sDueDateOption = "";
        }
        if("assignee".equalsIgnoreCase(sDueDateOption)){
           sAssigneeDueDateOption = "Yes";
        } else {
           sAssigneeDueDateOption = "No";
        }

        if("delta".equalsIgnoreCase(sDueDateOption) && strDeltaOffset[i] != null){
            bDeltaDueDate = true;
        }else{
            bDeltaDueDate = false;
        }

        if(strDate != null && !"null".equals(strDate) && !strDate.equals("")){
           strDateTime                =   strDate+ " " + routeTime[i];

           //Formatting Date to Ematrix Date Format
           strDateTime = eMatrixDateFormat.getFormattedInputDateTime(context,strDate,routeTime[i],clientTZOffset,request.getLocale());
        }else{
           strDateTime                = "";
        }


      String allowDeg = "FALSE";
      String needRev = "No";

      try{ //If user hasnot selected any checkbox then it is handled in try catch block

       for(int ad = 0; ad < AllowDelegations.length ; ad++){
     int chad = Integer.parseInt(AllowDelegations[ad]);
     if( i == chad){
      allowDeg = "TRUE";
      break;
      }
     }
   }catch(Exception ad){

   }

     // boolean isneedRev = false;
       try{
    for(int nr = 0; nr < NeedsReview.length ; nr++){
     int chnr = Integer.parseInt(NeedsReview[nr]);
        if( i == chnr){
      needRev = "Yes";
      break;
   }
      }
       }catch(Exception nr){

   }

        try{


         taskMaplist.add(h.setTaskMapList(context, routeNodeId[i],routeAction[i],routePersonId[i],taskName[i],allowDeg,needRev,routeOrder[i],routeInstructions[i],strDateTime, sAssigneeDueDateOption, strDeltaOffset[i],strDeltaOffsetFrom[i], bDeltaDueDate ,templateFlagArr[i],strRoleUser));
  


  }catch(Exception tml){

  }


        tempRouteNodeIds     = Integer.parseInt(routeNodeId[i]);
        routeNodeIds         = (tempRouteNodeIds > routeNodeIds)?tempRouteNodeIds:routeNodeIds;
      }
    }


    // if the bExecute = true;sortflag is true the user clicked the sorttasklist link
    if(linkFlag != null){

      if("sortList".equals(linkFlag)) {

        bExecute = true;

      } 
      else if("AddTask".equals(linkFlag)) {

        sAssigneeDueDateOption = "No"; // new tasks defaultly taken to have calendar option
        routeNodeIds++;
        
        //Begin : Bug 341297 : Code modification 
        // When clicked on Add Task in Edit Task page, current login user was added to the route member list
        // and the task for him was created. The correct behavior is there should not be extra user added to
        // route member list, but only task is to be created.
        /* Commented !!!
        personObject = personObject.getPerson(context);
        String strPersonId      = personObject.getId();
        String strPersonIdName  = personObject.getInfo(context,personObject.SELECT_LAST_NAME) + ", " + personObject.getInfo(context,personObject.SELECT_FIRST_NAME);

        //taskMaplist.add(0,setTaskMapList(context , String.valueOf(routeNodeIds),"",(strPersonId+"~"+strPersonIdName),"",sAllowDelegation,sNeedsReview,"","","", sAssigneeDueDateOption, "","",false , "No"));
        */

        taskMaplist.add(0,h.setTaskMapList(context , String.valueOf(routeNodeIds),"","none~none","",sAllowDelegation,sNeedsReview,"","","", sAssigneeDueDateOption, "","",false , "No",""));

        /* Commented !!!
        //personObject.setId(strPersonId);
       // BusinessObject memberObject = JSPUtil.getProjectMember(context,  session , projectId, new BusinessObject(strPersonId));
       // String sProjectLead         = getAttribute(context, session,memberObject,personObject.ATTRIBUTE_PROJECT_ACCESS);
       // String sCreateRoute         = getAttribute(context, session,memberObject,PropertyUtil.getSchemaProperty(context, "attribute_CreateRoute"));
        String sOrgName             = personObject.getInfo(context,personObject.SELECT_COMPANY_NAME);

        //MapList routeMemberMapList = (MapList)session.getAttribute("routeMemberMapList");
        MapList routeMemberMapList = (MapList)formBean.getElementValue("routeMemberMapList");

        HashMap tempMap = new HashMap();
        tempMap.put(personObject.SELECT_ID,strPersonId);
        tempMap.put("LastFirstName",strPersonIdName);
        tempMap.put(personObject.SELECT_TYPE,personObject.getType(context));
        //tempMap.put("projectLead",sProjectLead);
        //tempMap.put("createRoute",sCreateRoute);
        tempMap.put("OrganizationName",sOrgName);
        tempMap.put("access","");
        tempMap.put("name",personObject.getName(context));


        if(routeMemberMapList != null){
   Iterator memberMapItr = routeMemberMapList.iterator();
   boolean flag = false;
   while(memberMapItr.hasNext()) {
      Map map      = (Map)memberMapItr.next();
      String perId = (String)map.get(personObject.SELECT_ID);
				if((strPersonId).equals(perId)) {
     flag = true;
      break;
      }
   }

   if(!flag){
    routeMemberMapList.add(tempMap);
    }
	   	}
	   	else {
			routeMemberMapList = new MapList();
     routeMemberMapList.add(tempMap);
			formBean.setElementValue("routeMemberMapList", routeMemberMapList);
  }
        */
		// End : Bug 341297 : Code modification

    bExecute = true;

     }
     else if(("RemoveSelected".equals(linkFlag)) && (chkrouteNode != null)) {

        for (int j = 0; j < chkrouteNode.length; j++) {
          int i = Integer.parseInt(chkrouteNode[j]);
          bDeltaDueDate = false;

          String strDateTime            = "";
          String strDate                =   emxGetParameter(request, "routeScheduledCompletionDate"+i) ;

          sDueDateOption                =   emxGetParameter(request, "duedateOption"+i) ;

          if(sDueDateOption == null || "null".equals(sDueDateOption) || "".equals(sDueDateOption)){
            sDueDateOption = "";
          }
          if("assignee".equalsIgnoreCase(sDueDateOption)){
               sAssigneeDueDateOption = "Yes";
          } else {
               sAssigneeDueDateOption = "No";
          }

          if("delta".equalsIgnoreCase(sDueDateOption) && strDeltaOffset[i] != null){
               bDeltaDueDate = true;
          }else{
               bDeltaDueDate = false;
          }

          if(strDate != null && !"null".equals(strDate) && !strDate.equals("")){
             strDateTime                =   strDate+ " " + routeTime[i];
             //Formatting Date to Ematrix Date Format
             strDateTime = eMatrixDateFormat.getFormattedInputDateTime(context,strDate,routeTime[i],clientTZOffset,request.getLocale());
          }else{
             strDateTime                = "";
          }

          //TESING PURPOSE HARD CODED AD AND NR

          //HashMap SelectedRowMap = setTaskMapList(context , routeNodeId[i],routeAction[i],routePersonId[i],taskName[i],AllowDelegations[i],NeedsReview[i],routeOrder[i],routeInstructions[i],strDateTime, sAssigneeDueDateOption, strDeltaOffset[i], strDeltaOffsetFrom[i], bDeltaDueDate ,  templateFlagArr[i]);


                String allowDeg = "FALSE";
          String needRev = "No";

          try{ //If user hasnot selected any checkbox then it is handled in try catch block

           for(int ad = 0; ad < AllowDelegations.length ; ad++){
         int chad = Integer.parseInt(AllowDelegations[ad]);
         if( i == chad){
          allowDeg = "TRUE";
          break;
          }
         }
       }catch(Exception ad){

       }

         // boolean isneedRev = false;
           try{
        for(int nr = 0; nr < NeedsReview.length ; nr++){
         int chnr = Integer.parseInt(NeedsReview[nr]);
            if( i == chnr){
          needRev = "Yes";
          break;
       }
          }
           }catch(Exception nr){

       }


           HashMap SelectedRowMap = h.setTaskMapList(context , routeNodeId[i],routeAction[i],routePersonId[i],taskName[i],allowDeg,needRev,routeOrder[i],routeInstructions[i],strDateTime, sAssigneeDueDateOption, strDeltaOffset[i], strDeltaOffsetFrom[i], bDeltaDueDate ,  templateFlagArr[i],strRoleUser);


          if(taskMaplist.contains(SelectedRowMap)) {

            int index = taskMaplist.indexOf(SelectedRowMap);
            if("RemoveSelected".equals(linkFlag)) {
                //taskMaplist.remove(index);

			  // Begin : Bug 341297 : Code modification
			  // When all the tasks for the assignee are removed the route member should also be removed from the
			  // Step 2 of the wizard.
			  Map mapRemovedTask = (Map)taskMaplist.remove(index);
			  MapList routeMemberMapList = (MapList)formBean.getElementValue("routeMemberMapList");

			  // Find the assignee of this task, if all the tasks for this assignee are removed then
              // remove the assignee from the routeMemberMapList
              String strPersonId = (String)mapRemovedTask.get("PersonId");
              String strPersonName = (String)mapRemovedTask.get("name");
              if (strPersonName == null) {
                  strPersonName = (String)mapRemovedTask.get("PersonName");
              }
              
              boolean hasMoreTasks = false;
              String strRemainingTaskPersonId = null;
              String strRemainingTaskPersonName = null;
              Map mapRemainingTasksInfo = null;
              
              for (Iterator itrRemainingTasks = taskMaplist.iterator(); itrRemainingTasks.hasNext(); ) {
                  
                  mapRemainingTasksInfo = (Map)itrRemainingTasks.next();
                  
                  strRemainingTaskPersonId = (String)mapRemainingTasksInfo.get("PersonId");
                  strRemainingTaskPersonName = (String)mapRemainingTasksInfo.get("name");
                  if (strRemainingTaskPersonName == null) {
                      strRemainingTaskPersonName = (String)mapRemainingTasksInfo.get("PersonName");
                  }
                  
                  if (strRemainingTaskPersonId.equals(strPersonId) && strRemainingTaskPersonName.equals(strPersonName)) {
                      // This person has more tasks...
                      hasMoreTasks = true;
                      break;
                  }
              }
              
              // If there are no more tasks then remove this person from routeMemberMapList
              if (!hasMoreTasks) {
	              for (int k = 0; k < routeMemberMapList.size(); k++) {
	                  if (strPersonName != null && strPersonName.equals(((Map)routeMemberMapList.get(k)).get("name"))) {
	                      routeMemberMapList.remove(k);
	                      break;
	                  }
	              }
              }
              
              formBean.setElementValue("routeMemberMapList", routeMemberMapList);
              // End : Bug 341297 : Code modification

            }else if("AllowDel".equals(linkFlag)) {

              sAllowDelegation = "FALSE";

              if("TRUE".equalsIgnoreCase((String)SelectedRowMap.get(personObject.ATTRIBUTE_ALLOW_DELEGATION))) {

                sAllowDelegation = "FALSE";

              }else {

                sAllowDelegation = "TRUE";

              }

              SelectedRowMap.put(personObject.ATTRIBUTE_ALLOW_DELEGATION,sAllowDelegation);
              taskMaplist.set(index,SelectedRowMap);

           }else if("NeedsReview".equals(linkFlag)) {
              sNeedsReview = "No";

              if("Yes".equalsIgnoreCase((String)SelectedRowMap.get(h.taskNeedsReview))) {

                sNeedsReview = "No";

              }else {

                sNeedsReview = "Yes";

              }

              SelectedRowMap.put(h.taskNeedsReview,sNeedsReview);
              taskMaplist.set(index,SelectedRowMap);
           }
          }
        }

       }

        bExecute = true;
      }



    formBean.setElementValue("taskMapList",taskMaplist);
    formBean.setFormValues(session);

  } catch (Exception ex ){
    session.putValue("error.message"," " + ex);
    bExecute = true;
  }
%>


<html>
<body>

<form name="newForm" target="_parent" method="post">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="slctdd" value="<xss:encodeForHTMLAttribute><%=slctdd%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="slctmm" value="<xss:encodeForHTMLAttribute><%=slctmm%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="slctyy" value="<xss:encodeForHTMLAttribute><%=slctyy%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="toAccessPage" value="<xss:encodeForHTMLAttribute><%=toAccessPage%></xss:encodeForHTMLAttribute>"/>


     <input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeOrd%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="routeInstructions" value="<xss:encodeForHTMLAttribute><%=routeInst%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="routeAction" value="<xss:encodeForHTMLAttribute><%=routeAct%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="personName" value="<xss:encodeForHTMLAttribute><%=person%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="routeNode" value="<xss:encodeForHTMLAttribute><%=routeNodes%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="templateName" value="<xss:encodeForHTMLAttribute><%=templateName%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="assigneeType" value="<xss:encodeForHTMLAttribute><%=assigneeType%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />

<script language="javascript">
<%
    if(!bExecute) {
      // if the flag is yes, need to redirect to step 3 after keyed in values are loaded into session
      if("yes".equalsIgnoreCase(toAccessPage)){
%>
       document.newForm.action = "emxCreateRouteTemplateWizardMembersDialogFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";
<%
     }else{
%>
//       alert(" hi going for 4 th");
      document.newForm.action = "emxRouteTemplateWizardActionRequiredFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";

<%
     }
   } else {
%>
document.newForm.action = "emxRouteTemplateWizardAssignTaskFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";

<%
    }
%>
   document.newForm.submit();
</script>
</form>

</body>
</html>

