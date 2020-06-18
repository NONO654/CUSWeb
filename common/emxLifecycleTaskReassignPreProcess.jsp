<%--  emxLifecycleTaskReassignPreProcess.jsp   -   To do the preprocess validations

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleTaskReassignPreProcess.jsp.rca 1.6.3.2 Wed Oct 22 15:48:17 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>


<!-- Java script functions -->
<script language="JavaScript">
   var selectedPerson = null;
   var strComment = null;
   var searchType= null;

    function submitNewAssignee(objWndToClose, selPerson , strSearchType) {
        if (objWndToClose) {
            selectedPerson = selPerson;
            searchType = strSearchType;
            var objForm = document.formNewAssigneeData;
            var strExists= objForm.strExists.value
            if(strExists.indexOf("TRUE")!= -1){

               objWndToClose.location.href = "emxLifecycleTaskReassignCommentsFS.jsp";
            }else{
               submitComments(objWndToClose,"");
            }
        }
    }
    function submitComments(objWndToClose, strCommentsGiven){
        if (objWndToClose) {
            objWndToClose.closeWindow();
        }
        strComment = strCommentsGiven;
        var objForm = document.formNewAssigneeData;
        objForm.notificationComment.value= strComment;
        objForm.txtAssignee.value= selectedPerson;
        objForm.searchType.value= searchType;
        objForm.action = "emxLifecycleTaskReassignProcess.jsp";
        objForm.submit();
    }

  function submit() {
    document.formNewAssigneeData.submit();
  }
</script>



<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<%
try {
    String appDirectory = (String)EnoviaResourceBundle.getProperty(context, "eServiceSuiteFramework.Directory");
    if(appDirectory == null || "".equals(appDirectory) || "null".equals(appDirectory))
        {
            appDirectory = "common";
        }
    //fs.setDirectory(appDirectory);
    String initSource = emxGetParameter(request,"initSource");
    if (initSource == null){
            initSource = "";
    }


//initialising the parameters
  String jsTreeID           = emxGetParameter(request,"jsTreeID");
  String suiteKey           = emxGetParameter(request,"suiteKey");
  String objectId           = emxGetParameter(request,"objectId");
  String[] emxTableRowId    = emxGetParameterValues(request,"emxTableRowId");
  String taskInfo = "";
  
  DomainObject taskObject   = null;
  int size=0;
  int i=0;
  int nCountOfActiveTasks   = 0;
  String strTaskId          = "";
  String strTaskState       = "";
  String strExists          = "";
  String strSignature       = "";
  boolean isRouteNotStopped = true;
  String strRouteStatus = "";
  String[] arrParameters;

  final String POLICY_INBOX_TASK_STATE_COMPLETE = PropertyUtil.getSchemaProperty(context, "Policy", DomainObject.POLICY_INBOX_TASK, "state_Complete");


  StringList slParameters   = null;
  StringBuffer slContentURL = new StringBuffer(150);
  //emxTableRowId = <Object Id>|<State Name>|<Signature Name>|<Task id>
	String[] taskId = new String[emxTableRowId.length];
	String sLoggedInUser = context.getUser();  
	boolean bErrorFlag = false;
	boolean taskIdExists = false;
	String STATE_ASSIGNED = PropertyUtil.getSchemaProperty(context, "policy", DomainConstants.POLICY_INBOX_TASK, "state_Assigned");
	String STATE_REVIEW = PropertyUtil.getSchemaProperty(context, "policy", DomainConstants.POLICY_INBOX_TASK, "state_Review");
	for (int k = 0; k < emxTableRowId.length; k++) 
	{
		String tempParentId  = (String) emxTableRowId[k];
		StringList slParam   =  FrameworkUtil.split(tempParentId,"^");
		if(slParam.size()>=4){
		taskId[k]               = (String) slParam.get(3); //Task Id		
			taskIdExists 			= true;
		}
	}	
	if(!taskIdExists){%>
    <script>
	//XSSOK
		var msg = "<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.CannotPerform", context.getLocale())%>";
		alert(msg);</script>
 	<%
	return;
	}	
	String SELECT_ROUTE_ID = "from[" + DomainConstants.RELATIONSHIP_ROUTE_TASK + "].to.id";  
	String SELECT_ROUTE_OWNER = "from[" + DomainConstants.RELATIONSHIP_ROUTE_TASK + "].to.owner"; 
	String selAttrAllowDelegation = "attribute[Allow Delegation].value";       
	StringList selectables = new StringList(6);
	selectables.add(DomainConstants.SELECT_ID);
	selectables.add(DomainConstants.SELECT_OWNER);
	selectables.add(DomainConstants.SELECT_CURRENT);
	selectables.add(selAttrAllowDelegation);
	selectables.add(SELECT_ROUTE_ID);
	selectables.add(SELECT_ROUTE_OWNER);
	MapList mlInfoList = (MapList) DomainObject.getInfo(context,taskId,selectables);
	Iterator itr = (Iterator) mlInfoList.iterator();
	while(itr.hasNext())
	{
		HashMap infoMap = (HashMap) itr.next();
		String taskOwner = (String)infoMap.get(DomainConstants.SELECT_OWNER);
		String allowDelegation = (String)infoMap.get(selAttrAllowDelegation);
		String routeId = (String)infoMap.get(SELECT_ROUTE_ID);
		String sRouteOwner     = (String)infoMap.get(SELECT_ROUTE_OWNER);
		String strCurrentState = (String)infoMap.get(DomainConstants.SELECT_CURRENT);
		if (UIUtil.isNullOrEmpty(sRouteOwner)) 
		{
			DomainObject doInboxTask = DomainObject.newInstance(context,(String)infoMap.get(DomainConstants.SELECT_ID));
			DomainObject dmoLastRevision = new DomainObject(doInboxTask.getLastRevision(context));
			sRouteOwner = dmoLastRevision.getInfo(context, SELECT_ROUTE_OWNER);
		}
		boolean isInAssignedState = STATE_ASSIGNED.equals(strCurrentState);
		boolean isRouteOwner = sRouteOwner.equals(sLoggedInUser);
		boolean isTaskOwner = taskOwner.equals(sLoggedInUser);
		boolean showAssigneeField =  isInAssignedState &&
									   (isRouteOwner || 
									   (isTaskOwner && "TRUE".equalsIgnoreCase(allowDelegation)));

		if(!showAssigneeField)
		{
			bErrorFlag = true;
		}
	}

	if(bErrorFlag)
	{
		%>
					<script language="javascript">
						alert("<%=i18nNow.getI18nString("emxFramework.Alert.InvalidTaskReassign", "emxFrameworkStringResource", lStr)%>");
					</script>
		   <% 
		   return;
	} 
    for (int j = 0; j < emxTableRowId.length; j++) {
        if(j== (emxTableRowId.length-1)){
            taskInfo += emxTableRowId[j];
        }
        else{
            taskInfo += emxTableRowId[j]+ ",";
        }
        slParameters = FrameworkUtil.split(emxTableRowId[j],"^");
        Iterator itrRelPrjItr = slParameters.iterator();
        size = slParameters.size();

        arrParameters = new String[size];
        i=0;

        while(itrRelPrjItr.hasNext()){
           arrParameters[i] = (String) itrRelPrjItr.next();
          i++;
        }
        if(arrParameters.length > 3){
        	strSignature= arrParameters[2];
        }

        if(arrParameters.length <=2 ) {
            %>
                <script language="javascript">
                    alert("<%=i18nNow.getI18nString("emxFramework.Common.CannotPerform", "emxFrameworkStringResource", lStr)%>");

                </script>
       <% return;
       }
       else if(!"".equals(strSignature)){

        %>
            <script>alert("<%=i18nNow.getI18nString("emxFramework.Alert.InvalidActionForSignatures", "emxFrameworkStringResource", lStr)%>");</script>
        <%
        	return;
        }
        else{
            if (arrParameters[3] != null && !"".equals(arrParameters[3].trim())){
                strTaskId = arrParameters[3];
                String strRouteId = "";
                Map mapInfo = null;
                StringList slBusSelect = null;
                //checking if the Route is started ot not
                final String SELECT_ROUTE_ID_FROM_TASK = "from[" + DomainObject.RELATIONSHIP_ROUTE_TASK + "].to.id";
                final String SELECT_ATTRIBUTE_ROUTE_STATUS       = "attribute[" + DomainObject.ATTRIBUTE_ROUTE_STATUS + "]";
                boolean isBusinessObject = "true".equalsIgnoreCase(MqlUtil.mqlCommand(context, "print bus $1 select $2 dump",true,strTaskId,"exists"));
     

                if (isBusinessObject){
                    DomainObject domainObject = new DomainObject(strTaskId);
                    slBusSelect = new StringList(SELECT_ROUTE_ID_FROM_TASK);
                    slBusSelect.add(DomainObject.SELECT_CURRENT);
                    mapInfo = domainObject.getInfo(context, slBusSelect);
                    strRouteId = (String)mapInfo.get(SELECT_ROUTE_ID_FROM_TASK);
                    strTaskState = (String)mapInfo.get(DomainObject.SELECT_CURRENT);

                    if (!POLICY_INBOX_TASK_STATE_COMPLETE.equals(strTaskState)) {
                        nCountOfActiveTasks++;
                    }
                }
                else{
                    //DomainRelationship dmRelationship = new DomainRelationship(strTaskId);
                    StringList relationshipSelects = new StringList("from.id");
                    MapList mlRouteNodeInfo = DomainRelationship.getInfo(context, new String[]{strTaskId}, relationshipSelects);

                    mapInfo = (Map)mlRouteNodeInfo.get(0);
                    strRouteId = (String)mapInfo.get("from.id");
                }

                DomainObject dmrObject = new DomainObject (strRouteId);
                slBusSelect = new StringList();
                slBusSelect.add(SELECT_ATTRIBUTE_ROUTE_STATUS);
                Map mapRouteInfo = dmrObject.getInfo(context, slBusSelect);
                strRouteStatus = (String)mapRouteInfo.get(SELECT_ATTRIBUTE_ROUTE_STATUS);
                strExists += MqlUtil.mqlCommand(context,"print bus $1 select $2",strTaskId,"exists");
                strExists +="";
             }
         }
  }

    //
    // Decide which links to be shown on search dialog
    //
    String strHideRoleSearch = "false";
    String strHideGroupSearch = "false";
    String strHidePersonSearch = "false";

    // If user selects multiple tasks, and all of them are active, then only person search will be shown
    // if one the tasks is not active, then person/role/group searches will be shown
    if (nCountOfActiveTasks == emxTableRowId.length) {
        strHideRoleSearch = "true";
        strHideGroupSearch = "true";
    }

  if("Stopped".equalsIgnoreCase(strRouteStatus) || "Finished".equalsIgnoreCase(strRouteStatus)){
    isRouteNotStopped = false;
%>
    <script>
    //XSSOK
        var msg = "<%=FrameworkUtil.i18nStringNow("emxFramework.Alert.RouteIsNotStarted",request.getHeader("Accept-Language"))%>";
        alert(msg);
    </script>
<%
  }
%>
<form name="formNewAssigneeData" method="post" onsubmit="submit(); return false"  >
    <input type="hidden" name="taskInfo" value="<xss:encodeForHTMLAttribute><%=taskInfo%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="notificationComment"  id="notificationComment"   value="" />
    <input type="hidden" name="txtAssignee" id="txtAssignee" value="" />
    <input type="hidden" name="searchType" id="searchType" value="" />
    <!-- //XSSOK -->
    <input type="hidden" name="strExists" value="<%=strExists%>" />
</form>
<%
        if(strTaskId != null && !"".equals(strTaskId) && "".equals(strSignature) && isRouteNotStopped){
%>
            <script language="javascript">
                //XSSOK
                emxShowModalDialog("emxLifecycleTaskAssigneeSearchFS.jsp?hidePersonSearch=<%=strHidePersonSearch%>&hideRoleSearch=<%=strHideRoleSearch%>&hideGroupSearch=<%=strHideGroupSearch%>",775, 500);
            </script>
<%
    }
   }
    catch (Exception ex) {
        if (ex.toString() != null && ex.toString().length() > 0) {
             emxNavErrorObject.addMessage(ex.toString());
        }

        ex.printStackTrace();
    } finally {
       // Add cleanup statements if required like object close, cleanup session, etc.
    }
    %>







<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>




