<%--  emxRouteWizardAssignTaskProcess.jsp   --  Editing Route object

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteWizardAssignTaskProcess.jsp.rca 1.14 Wed Oct 22 16:18:26 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%

String keyValue=emxGetParameter(request,"keyValue");

if(keyValue == null){
	keyValue = formBean.newFormKey(session);
}
formBean.processForm(session,request,"keyValue");

framesetObject fs = new framesetObject();

String showmenuinToolbar = fs.getShowmenuinToolbarValue();

String advanceDateOption = EnoviaResourceBundle.getProperty(context,"emxComponents.common.AdvancedDateOption");


%>

<%!
  private static final String  routeActionStr                   = DomainConstants.ATTRIBUTE_ROUTE_ACTION;
  private static final String  routeSequenceStr                 = DomainConstants.ATTRIBUTE_ROUTE_SEQUENCE;
  private static final String  routeInstructionsStr             = DomainConstants.ATTRIBUTE_ROUTE_INSTRUCTIONS;
  private static final String  taskNameStr                      = DomainConstants.ATTRIBUTE_TITLE;
  private static final String  routeScheduledCompletionDateStr  = DomainConstants.ATTRIBUTE_SCHEDULED_COMPLETION_DATE;
  private static final String  routeAllowDelegation             = DomainConstants.ATTRIBUTE_ALLOW_DELEGATION;
  private static final String  relRouteNode                     = DomainConstants.RELATIONSHIP_ROUTE_NODE;

  private static final class Helper {
  String routeAssigneeDueDateOpt;
  String taskNeedsReview        ;
  String routeDueDateOffset     ;
  String routeDueDateOffsetFrom ;
         public Helper(String routeAssigneeDueDateOpt,
                  String taskNeedsReview        ,
                  String routeDueDateOffset     ,
                  String routeDueDateOffsetFrom) {
                  this.routeAssigneeDueDateOpt=routeAssigneeDueDateOpt;
                  this.taskNeedsReview=taskNeedsReview;
                  this.routeDueDateOffset=routeDueDateOffset;
                  this.routeDueDateOffsetFrom=routeDueDateOffsetFrom;
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
        throws MatrixException,java.text.ParseException 
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
         throws MatrixException,java.text.ParseException 
         {


  HashMap routeNodeMap = new HashMap();

  //setting Route Node ID.
  routeNodeMap.put(relRouteNode,sRouteNodeId);

  //setting task action
  routeNodeMap.put(routeActionStr,sRouteAction);


  StringTokenizer sToken = new StringTokenizer(sRoutePersonId, "~");
  DomainObject personObj = DomainObject.newInstance(context);


  //setting Person Name and Id.
  while(sToken.hasMoreElements()) {
  String pId   = (String)sToken.nextToken();
  String pName = (String)sToken.nextToken();


  routeNodeMap.put("PersonId",pId);
  routeNodeMap.put("PersonName",pName);
    if(pId != null && !"".equals(pId) && !"none".equals(pId) && !"Role".equals(pId) && !"Group".equals(pId))
    {

		 personObj.setId(pId);
         routeNodeMap.put(DomainConstants.SELECT_NAME,personObj.getName(context));
        //Commeted for Testing purpose
        //routeNodeMap.put(DomainConstants.SELECT_NAME,pName);

    }
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

  String routeAssigneeDueDateOpt          = PropertyUtil.getSchemaProperty(context, "attribute_AssigneeSetDueDate");
  String routeDueDateOffset               = PropertyUtil.getSchemaProperty(context, "attribute_DueDateOffset");
  String routeDueDateOffsetFrom           = PropertyUtil.getSchemaProperty(context, "attribute_DateOffsetFrom");
  String taskNeedsReview                  = PropertyUtil.getSchemaProperty(context, "attribute_ReviewTask");
  Helper helper = new Helper(routeAssigneeDueDateOpt,taskNeedsReview       ,routeDueDateOffset     ,routeDueDateOffsetFrom);

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
  String templateFlagArr[]          = emxGetParameterValues(request, "templateTask");
  String sRecepientArr[]          = emxGetParameterValues(request, "recepientList");

  String[] strDeltaOffset           = null;
  String[] strDeltaOffsetFrom       = null;

  if(advanceDateOption.equals("true")){

   	strDeltaOffset           = emxGetParameterValues(request, "duedateOffset");
   	strDeltaOffsetFrom       = emxGetParameterValues(request, "duedateOffsetFrom");

  }


  double clientTZOffset   = (new Double((String)session.getValue("timeZone"))).doubleValue();



     String projectId  =  (String) formBean.getElementValue("projectId");
     String templateId    =  (String) formBean.getElementValue("templateId");
     String templateName  =  (String) formBean.getElementValue("templateName");
     String portalMode    =  (String) formBean.getElementValue("portalMode");

     String toAccessPage       =  (String) formBean.getElementValue("toAccessPage");
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

       if(advanceDateOption.equals("true")){

			 if("delta".equalsIgnoreCase(sDueDateOption) && strDeltaOffset[i] != null){
				bDeltaDueDate = true;
			}else{
				bDeltaDueDate = false;
			}
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
	 	}catch(Exception ad){}

	    // boolean isneedRev = false;
       try{
		  for(int nr = 0; nr < NeedsReview.length ; nr++){
			  int chnr = Integer.parseInt(NeedsReview[nr]);
		      if( i == chnr){
			   needRev = "Yes";
			   break;
			}
	     }
       }catch(Exception nr){}



        try{
        	if(advanceDateOption.equals("true")){
				taskMaplist.add(helper.setTaskMapList(context, routeNodeId[i],routeAction[i],routePersonId[i],taskName[i],allowDeg,needRev,routeOrder[i],routeInstructions[i],strDateTime, sAssigneeDueDateOption, strDeltaOffset[i],strDeltaOffsetFrom[i], bDeltaDueDate ,templateFlagArr[i],strRoleUser));
			}else{
				taskMaplist.add(helper.setTaskMapList(context, routeNodeId[i],routeAction[i],routePersonId[i],taskName[i],allowDeg,needRev,routeOrder[i],routeInstructions[i],strDateTime, sAssigneeDueDateOption, "","", bDeltaDueDate ,templateFlagArr[i],strRoleUser));
			}

		}catch(Exception tml){
			throw new Exception(tml.getMessage());
		}


        tempRouteNodeIds     = Integer.parseInt(routeNodeId[i]);
        routeNodeIds         = (tempRouteNodeIds > routeNodeIds)?tempRouteNodeIds:routeNodeIds;
      }
    }


    // if the bExecute = true;sortflag is true the user clicked the sorttasklist link
    if(linkFlag != null){

      if("sortList".equals(linkFlag)) {

        bExecute = true;

      }else if("AddTask".equals(linkFlag)) {

        sAssigneeDueDateOption = "No"; // new tasks defaultly taken to have calendar option
        routeNodeIds++;
        personObject = personObject.getPerson(context);
        String strPersonId      = personObject.getId();
        String strPersonIdName  = personObject.getInfo(context,personObject.SELECT_LAST_NAME) + ", " + personObject.getInfo(context,personObject.SELECT_FIRST_NAME);
        taskMaplist.add(0,helper.setTaskMapList(context , String.valueOf(routeNodeIds),"",(strPersonId+"~"+strPersonIdName),"",sAllowDelegation,sNeedsReview,"","","", sAssigneeDueDateOption, "","",false , "No",""));

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
			   if((strPersonId).equals(perId))
			   {
				 flag = true;
				  break;
			   }

			}

			if(!flag){
				routeMemberMapList.add(tempMap);
				}

	    }else {
		   routeMemberMapList.add(tempMap);
		}

  		bExecute = true;

     }else if(("RemoveSelected".equals(linkFlag)) && (chkrouteNode != null)){

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

          if(advanceDateOption.equals("true")){
			  if("delta".equalsIgnoreCase(sDueDateOption) && strDeltaOffset[i] != null){
				   bDeltaDueDate = true;
			  }else{
				   bDeltaDueDate = false;
			  }
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
		  	 	}catch(Exception ad){}

		  	    // boolean isneedRev = false;
		         try{
		  		  for(int nr = 0; nr < NeedsReview.length ; nr++){
		  			  int chnr = Integer.parseInt(NeedsReview[nr]);
		  		      if( i == chnr){
		  			   needRev = "Yes";
		  			   break;
		  			}
		  	     }
		         }catch(Exception nr){}


           //HashMap SelectedRowMap = helper.setTaskMapList(context , routeNodeId[i],routeAction[i],routePersonId[i],taskName[i],allowDeg,needRev,routeOrder[i],routeInstructions[i],strDateTime, sAssigneeDueDateOption, strDeltaOffset[i], strDeltaOffsetFrom[i], bDeltaDueDate ,  templateFlagArr[i]);
          //  HashMap SelectedRowMap = helper.setTaskMapList(context , routeNodeId[i],routeAction[i],routePersonId[i],taskName[i],allowDeg,needRev,routeOrder[i],routeInstructions[i],strDateTime, sAssigneeDueDateOption, "", "", bDeltaDueDate ,  templateFlagArr[i]);
           HashMap SelectedRowMap = null;

          if(advanceDateOption.equals("true")){
			   SelectedRowMap = helper.setTaskMapList(context , routeNodeId[i],routeAction[i],routePersonId[i],taskName[i],allowDeg,needRev,routeOrder[i],routeInstructions[i],strDateTime, sAssigneeDueDateOption, strDeltaOffset[i], strDeltaOffsetFrom[i], bDeltaDueDate ,  templateFlagArr[i],strRoleUser);
		  }else{
			   SelectedRowMap = helper.setTaskMapList(context , routeNodeId[i],routeAction[i],routePersonId[i],taskName[i],allowDeg,needRev,routeOrder[i],routeInstructions[i],strDateTime, sAssigneeDueDateOption, "", "", bDeltaDueDate ,  templateFlagArr[i],strRoleUser);
		  }


          if(taskMaplist.contains(SelectedRowMap)) {

            int index = taskMaplist.indexOf(SelectedRowMap);
            if("RemoveSelected".equals(linkFlag)) {

              Map taskMap = (Map) taskMaplist.get(index);
              String sequnceStr= (String)taskMap.get(routeSequenceStr);


              /*  for(int i1=index+1; i1< taskMaplist.size(); i1++)
                {
                  Map taskMap1 = (Map)taskMaplist.get(i1);
                  //added for bug 318384
                  taskMap1.put(routeSequenceStr,"1");
                }*/
              taskMaplist.remove(index);

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

              if("Yes".equalsIgnoreCase((String)SelectedRowMap.get(taskNeedsReview))) {

                sNeedsReview = "No";

              }else {

                sNeedsReview = "Yes";

              }

              SelectedRowMap.put(taskNeedsReview,sNeedsReview);
              taskMaplist.set(index,SelectedRowMap);
           }
          }
        }
		  //added for 329211
			 	if("RemoveSelected".equals(linkFlag)&& taskMaplist.size()>0) {
				int initval=0;
				Map inittaskMap = (Map)taskMaplist.get(0);
				Map finaltaskMap=null;
				  String oldSeqnumber = (String)inittaskMap.get(routeSequenceStr);
				  String newSeqnumber=null;
				  String strvalue,strval=null;
				  int midval,middleval=0;

				  
				  if((Integer.parseInt(oldSeqnumber))!=1)
				{
					  
					  inittaskMap.put(routeSequenceStr,String.valueOf(initval+1));
				}
				for(int init=1;init< taskMaplist.size();init++)
				{
						finaltaskMap = (Map)taskMaplist.get(init);
				       newSeqnumber = (String)finaltaskMap.get(routeSequenceStr);
				   if(Integer.parseInt(oldSeqnumber)==Integer.parseInt(newSeqnumber))
					{
							inittaskMap = (Map)taskMaplist.get(init-1);
							strvalue = (String)inittaskMap.get(routeSequenceStr);
						   midval=Integer.parseInt(strvalue);
						
							 finaltaskMap.put(routeSequenceStr,String.valueOf(midval));
					}
					else
					{
						oldSeqnumber=newSeqnumber;
						 inittaskMap = (Map)taskMaplist.get(init-1);
				        strval = (String)inittaskMap.get(routeSequenceStr);
						middleval=Integer.parseInt(strval);
						finaltaskMap.put(routeSequenceStr,String.valueOf(middleval+1));
					}
				}

       }//added for 329211

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
		  formBean.setElementValue("toAccessPage","");
                  formBean.setElementValue("sourcePage","");
%>
       document.newForm.action = "emxRouteWizardAccessMembersFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&showmenuinToolbar=<%=showmenuinToolbar%>";
<%
     }else{
        formBean.setElementValue("sourcePage","");
%>
      document.newForm.action = "emxRouteWizardActionRequiredFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";

<%
     }
   } else {
%>
      document.newForm.action = "emxRouteWizardAssignTaskFS.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";

<%
    }
%>
   document.newForm.submit();
</script>
</form>

</body>
</html>

