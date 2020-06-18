<%--  emxLifecycleApproveRejectPreProcess.jsp   -   PreProcess page for Approval dialog

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleApproveRejectPreProcess.jsp.rca 1.7.3.2 Wed Oct 22 15:48:19 2008 przemek Experimental przemek $
--%>
<%@ page import = "com.matrixone.apps.domain.*, com.matrixone.apps.domain.util.*" %>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>



<%
    try {
        String appDirectory = (String)EnoviaResourceBundle.getProperty(context, "eServiceSuiteFramework.Directory");
        if(appDirectory == null || "".equals(appDirectory) || "null".equals(appDirectory)) {
            appDirectory = "common";
        }
        String initSource = emxGetParameter(request,"initSource");
        if (initSource == null){
                initSource = "";
        }

//    initialising the parameters
      String jsTreeID = emxGetParameter(request,"jsTreeID");
      String suiteKey = emxGetParameter(request,"suiteKey");
      String objectId = emxGetParameter(request,"objectId");
      String emxTableRowId = emxGetParameter(request,"emxTableRowId");
	  Locale locale = context.getLocale();	
      int size=0;
      int i=0;
      String strTaskId ="";
      String strSignatureName = "";
      String strState="";
      String strTaskOwner = "";
      String strCurrentUser ="";
      String strRouteTaskUserType="";
      String strPolicyName="";
      String strRoleOrGroup="";
      String[] arrParameters;
      String strExists = "false";

      boolean isFutureState=false;
      boolean hasAccess = false;
      boolean isEverythingOk= false;
      boolean isProcessTask= false;
      StringBuffer slContentURL = new StringBuffer(150);

      State state = null;
      DomainObject taskObject= null;
      StringList slParameters = null;

      slParameters = FrameworkUtil.split(emxTableRowId,"^");
      Iterator itrRelPrjItr = slParameters.iterator();
      size = slParameters.size();
      arrParameters = new String[size];

      while(itrRelPrjItr.hasNext()){
          arrParameters[i] = (String) itrRelPrjItr.next();
          i++;
       }
      if(objectId == null || arrParameters.length <= 2){%>
        <script>
		//XSSOK
		var msg = "<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.CannotPerform", locale)%>";alert(msg);</script>
     <%}
       else {
    	   if(arrParameters[4] != null && DomainObject.RELATIONSHIP_ROUTE_NODE.equalsIgnoreCase(arrParameters[4])){
    %>
    		<!-- //XSSOK -->
            <script>var msg = "<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Alert.CannotPerformOnDefinedTask", locale)%>";alert(msg);</script>
    <%		
    		return;
    	   }
	       if(arrParameters[1] != null){
	       	strState = arrParameters[1];
	       }
	       if(arrParameters[2] != null){
	       	strSignatureName = arrParameters[2];
	       }

	       if (arrParameters[3] != null){
	        if(arrParameters[3].indexOf("_") != -1) {
	            String strFullParam = arrParameters[3];
	           int index= strFullParam.lastIndexOf("_");
	           strTaskId =strFullParam.substring(index+1);
	        }
	        else{
	            strTaskId = arrParameters[3];
	        }
	       }
	       
	       // Check if the selected row contains either signature or task
	       if (strSignatureName == null || "".equals(strSignatureName)) {
	           if (strTaskId == null || "".equals(strTaskId)) {
%>	               
	               <script>
				   //XSSOK
				   var msg = "<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.CannotPerform", locale)%>";alert(msg);</script>
<%
				   return;
	           }
	       }
	    // Check if the task has any incompleted subroutes/tasks
           if (UIUtil.isNotNullAndNotEmpty(strTaskId) && UIUtil.isNullOrEmpty(strSignatureName)) {
        	   String relPattern  = DomainConstants.RELATIONSHIP_TASK_SUBROUTE;
               String typePattern = DomainConstants.TYPE_ROUTE;
               StringList typeSelects = new StringList();
               typeSelects.add(DomainConstants.SELECT_ID);
               DomainObject domObj = DomainObject.newInstance(context, strTaskId);
               boolean canComplete=true;
               MapList routeList   = domObj.getRelatedObjects(context,
                                                   relPattern,
                                                   typePattern,
                                                   typeSelects,
                                                   null,
                                                   false,
                                                   true,
                                                   (short)1,
                                                   null,
                                                   null);
               Iterator it=routeList.iterator();
               while(it.hasNext())
               {
                   Hashtable ht=(Hashtable)it.next();
                   String objId=(String)ht.get(DomainConstants.SELECT_ID);
                   DomainObject routeDo=DomainObject.newInstance(context,objId);
                   String routeStatus =routeDo.getInfo(context,"attribute["+DomainConstants.ATTRIBUTE_ROUTE_STATUS+"]");
                   if(!"Finished".equalsIgnoreCase(routeStatus))
                   {
                       canComplete=false;
                       break;
                   }
               }
               
        	   if(!canComplete)
				{
        		%>
        	   	    <script>var msg = "<%=EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(),"emxComponents.Common.CanNotPromoteTask")%>";alert(msg);</script>
        	   <%
        	   		return;
        	   }
           }
	       
        //Processing for object
        DomainObject busObject = DomainObject.newInstance(context, objectId);
        StringList busSelects = new StringList();
        busSelects.addElement(DomainConstants.SELECT_CURRENT);
        Map taskMap= busObject.getInfo(context, busSelects);
        String currentState =  (String)taskMap.get(DomainConstants.SELECT_CURRENT);
        strPolicyName = ((Policy) (busObject.getPolicy(context))).getName();
        strCurrentUser=context.getUser();

        //Checking if the parameter list contains the state
        if(strState != null && !"".equals(strState)){
            //Is the Future state task
            isFutureState = com.matrixone.apps.domain.util.PolicyUtil.checkState(context, objectId, strState, com.matrixone.apps.domain.util.PolicyUtil.LT);
            if(isFutureState){%>
            <!-- //XSSOK -->
                <script>var msg = "<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Alert.CannotApproveFutureTask",locale)%>";alert(msg);</script>
           <%}
            else {
                if(strTaskId != null && !"".equals(strTaskId)){
                    //Process task
                    isProcessTask=true;
                }
                else
                {
                //Process signature
                ContextUtil.startTransaction(context, false);
                StateList stateList = busObject.getStates(context);
                StateItr stateItr = new StateItr(stateList);

                boolean bFound = false;
                State fromState= null;
                State toState= null;

                stateList = busObject.getStates(context);
                stateItr = new StateItr(stateList);
                //Finding the tostate and from state
                while (stateItr.next())
                {
                    state = stateItr.obj();
                    String stateName = state.getName();
                    if (!bFound)
                    {
                        if (strState.equalsIgnoreCase(stateName))
                        {
                            fromState = state;
                            bFound = true;
                        }
                    }
                    else
                    {
                        toState = state;
                        break;
                    }
                }

                //Finding the signature between the states
                if (fromState != null && toState != null)
                {
                    MapList mlSignatureDetails = null;
                    Map mapSignatureInfo = null;
                    String strResult = null;
                    StringList slSignatureApprovers = null;
                    StringList slParentRolesOrGroups=null;
                    String strCurrentSignatureName = null;
                    StringBuffer strMQLForAccess = null;
                    DomainObject dmoObject = new DomainObject(objectId);
                    mlSignatureDetails = dmoObject.getSignaturesDetails(context, fromState, toState);
                    for (Iterator itrSignatureDetails = mlSignatureDetails.iterator(); itrSignatureDetails.hasNext();)
                    {
                        mapSignatureInfo = (Map) itrSignatureDetails.next();
                        strCurrentSignatureName = (String)mapSignatureInfo.get("name");
                        if (strSignatureName.equals(strCurrentSignatureName)) {
                            break;
                        }
                    }
                    if (mapSignatureInfo != null)
                    {
                        if (!"true".equalsIgnoreCase((String)mapSignatureInfo.get("signed")))
                        {
                            strResult = MqlUtil.mqlCommand(context,"print policy $1 select $2 $3 $4 dump $5",true, 
                            		                          strPolicyName,
                            		                          "state[" + currentState + "].signature["+strSignatureName+"].approve",
                            		                          "state[" + currentState + "].signature["+strSignatureName+"].reject",
                            		                          "state[" + currentState + "].signature["+strSignatureName+"].ignore",
                            		                          ",");
                            if(!"".equalsIgnoreCase(strResult) && strResult != null && strResult.length() != 0){
                            slSignatureApprovers = FrameworkUtil.split(strResult, ",");
                            }
                            if (slSignatureApprovers.contains(context.getUser()))
                            {
                                hasAccess = true;
                            }
                            else
                            {  // Check if any of the role/groups are assigned to me
                                StringBuffer mqlBuf = new StringBuffer();
                                String[] methodArgs = new String[slSignatureApprovers.size()+1]; 
                                mqlBuf.append("print person $1");
                                methodArgs[0] = context.getUser();
                                mqlBuf.append(" select ");
                                for(int iSign = 0 ;iSign<slSignatureApprovers.size();iSign++){
                                	mqlBuf.append("$").append(iSign+2).append(" ");
                                	methodArgs[iSign+1] = ("isassigned[").concat((String)slSignatureApprovers.get(iSign)).concat("] ");
                                }
                                mqlBuf.append("dump");
                                strResult = MqlUtil.mqlCommand(context,mqlBuf.toString(),true,methodArgs);
                                
                                if (strResult != null && strResult.indexOf("TRUE") != -1) {
                                    hasAccess = true;
                                }
                            }
                        }
                     }
                    //Checking for the access of the signature.
                    if(hasAccess){
                        isEverythingOk=true;
                    }
                    else{%>
                    <!-- //XSSOK -->
                    <script>var msg = "<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Alert.CannotApproveRejectUnassignedTasks",locale)%>";alert(msg);</script>
                    <%}
                }
             }
           }
        }
        else{
            //Ad hoc type task
            isProcessTask=true;
        }
     }

//    Process task further
    if(isProcessTask) {
        taskObject = new DomainObject(strTaskId);
        //Checking the assignee of the task
            strTaskOwner   = (String)taskObject.getInfo(context,"from["+DomainObject.RELATIONSHIP_PROJECT_TASK+"].to.name");
            if(strTaskOwner != null && !"".equals(strTaskOwner) && strTaskOwner.equals(context.getUser())){
             hasAccess=true;
            }
            if(hasAccess){
                strRouteTaskUserType   = (String)taskObject.getInfo(context,"from["+DomainObject.RELATIONSHIP_PROJECT_TASK+"].to.type");
                //Checking for the person object
                if((strRouteTaskUserType != null)&& !strRouteTaskUserType.equals(DomainObject.TYPE_ROUTE_TASK_USER)){
                    isEverythingOk=true;

                    //
                    // Check if the route is started or not
                    //
                    final String SELECT_ROUTE_ID_FROM_TASK = "from[" + DomainObject.RELATIONSHIP_ROUTE_TASK + "].to.id";
                    StringList slBusSelect = new StringList();
                    slBusSelect.add(SELECT_ROUTE_ID_FROM_TASK);

                    Map mapInfo = taskObject.getInfo(context, slBusSelect);
                    String strRouteId = (String)mapInfo.get(SELECT_ROUTE_ID_FROM_TASK);
                    if (strRouteId != null && !"".equals(strRouteId.trim()) && !"null".equals(strRouteId.trim())) {
                        DomainObject dmrObject = new DomainObject (strRouteId);

                        final String SELECT_ATTRIBUTE_ROUTE_STATUS       = "attribute[" + DomainObject.ATTRIBUTE_ROUTE_STATUS + "]";
                        slBusSelect = new StringList();
                        slBusSelect.add(SELECT_ATTRIBUTE_ROUTE_STATUS);
                        mapInfo = dmrObject.getInfo(context, slBusSelect);
                        String strRouteStatus = (String)mapInfo.get(SELECT_ATTRIBUTE_ROUTE_STATUS);

                        if("Started".equalsIgnoreCase(strRouteStatus)){
                            isEverythingOk = true;
                        }
                        else {
                            isEverythingOk = false;
%>
							<!-- //XSSOK -->
                            <script>var msg = "<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Alert.RouteIsNotStarted",locale)%>";alert(msg);</script>
<%
                        }
                    }
                }
                else{%>
                <!-- //XSSOK -->
                <script>var msg = "<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Alert.PleaseAcceptTaskBeforeApproveReject",locale)%>";alert(msg);</script>
                 <%}
            }
            else { %>
            <!-- //XSSOK -->
            <script>var msg = "<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Alert.CannotApproveRejectUnassignedTasks",locale)%>";alert(msg);</script>
             <% }
        
    }

    	String isFDAEnabled = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.EnableFDA");
    	String isResponsibleRoleEnabled = DomainConstants.EMPTY_STRING;
    	try{
   			isResponsibleRoleEnabled = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.ResponsibleRoleForSignatureMeaning.Preserve");
    	}
    	catch(Exception e){
    		
    		isResponsibleRoleEnabled = "false";
    	}
    	boolean hasRole =true;
    	String strRouteTaskUser = null;
    	if(taskObject!=null){
    		strRouteTaskUser=taskObject.getAttributeValue(context,DomainConstants.ATTRIBUTE_ROUTE_TASK_USER);
    	}
    	if( UIUtil.isNotNullAndNotEmpty(strRouteTaskUser) && strRouteTaskUser.startsWith("role_"))
    	   		hasRole = PersonUtil.hasAssignment(context,PropertyUtil.getSchemaProperty(context, strRouteTaskUser));
	    if(UIUtil.isNotNullAndNotEmpty(isFDAEnabled) && UIUtil.isNotNullAndNotEmpty(isResponsibleRoleEnabled) && isFDAEnabled.equals("true") && isResponsibleRoleEnabled.equals("true") && !hasRole)
	    {
	    %>
<script language="javascript">
        //XSSOK
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskDetails.AlertNotResposibleRole</emxUtil:i18nScript>");
    	</script>
<%
	
	    	
	    }
	    else
	    {
	    	
	    
    //Everythig ok.
    if(isEverythingOk){
                      //Building the URL
                       slContentURL.append("emxLifecycleApproveRejectDialogFS.jsp");
                       slContentURL.append("?suiteKey=");
                       slContentURL.append(XSSUtil.encodeForURL(context, suiteKey));
                       slContentURL.append("&initSource=");
                       slContentURL.append(XSSUtil.encodeForURL(context, initSource));
                       slContentURL.append("&jsTreeID=");
                       slContentURL.append(XSSUtil.encodeForURL(context, jsTreeID));
                       slContentURL.append("&objectId=");
                       slContentURL.append(XSSUtil.encodeForURL(context, objectId));
                       slContentURL.append("&signatureName=");
                       slContentURL.append(XSSUtil.encodeForURL(context, strSignatureName));
                       slContentURL.append("&stateName=");
                       slContentURL.append(XSSUtil.encodeForURL(context, strState));
                       slContentURL.append("&taskId=");
                       slContentURL.append(XSSUtil.encodeForURL(context, strTaskId));
		                       if(UIUtil.isNotNullAndNotEmpty(isFDAEnabled) && UIUtil.isNotNullAndNotEmpty(isResponsibleRoleEnabled) && isFDAEnabled.equals("true") && isResponsibleRoleEnabled.equals("true"))
		                       {
		                       		if(UIUtil.isNotNullAndNotEmpty(strRouteTaskUser) && strRouteTaskUser.startsWith("role_"))
		                       		{
		                    	  			slContentURL.append("&routeTaskUser=").append(XSSUtil.encodeForURL(context,strRouteTaskUser));
		                       		}
		                       }
                       String strUrl= slContentURL.toString();

%>
                    <script language="javascript">
                        //XSSOK
                        emxShowModalDialog('<%=strUrl%>', 600, 400, false);
                    </script>
<%
        }
	    }

    }
    catch (Exception ex) {
        if (ex.toString() != null && ex.toString().length() > 0) {
             emxNavErrorObject.addMessage(ex.toString());

        }
    }
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>
