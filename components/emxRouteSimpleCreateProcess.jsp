<%--  emxRouteSimpleCreateProcess.jsp  --  Creates a Simple Route
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteSimpleCreateProcess.jsp.rca 1.2.2.6 Tue Oct 28 23:01:04 2008 przemek Experimental przemek $
 --%>
 
<%@ page import="matrix.db.*,matrix.util.*,com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,java.util.*"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%
    String keyValue=emxGetParameter(request,"keyValue");
    if(keyValue == null){
      keyValue = formBean.newFormKey(session);
    }
    formBean.processForm(session,request,"keyValue");
    double clientTZOffset   = (new Double((String)session.getValue("timeZone"))).doubleValue();
    String routeTime="5:00:00 PM";
    String formattedDueDate=eMatrixDateFormat.getFormattedInputDateTime(context,(String)formBean.getElementValue("routeDueDate"),routeTime,clientTZOffset,request.getLocale());
    formBean.setElementValue("formattedDueDate",formattedDueDate);

    HashMap stateMap=getStateDetails(context,formBean);

    String[] contentIdArray=getContentId(context,formBean,stateMap);

    Hashtable routeDetails=getRouteAttributes(context,formBean,stateMap);

    MapList taskMapList=getTaskDetails(context,formBean);

    MapList routeMemberMapList=this.getMemberAccessDetails(context,taskMapList);

    SimpleRouteCreator routeCreator=new SimpleRouteCreator(context);

    HashMap createdRouteDetails=routeCreator.createSimpleRoute(stateMap,contentIdArray,routeDetails,routeMemberMapList,taskMapList,session);

%>
<%!
            // Following are the service methods which gives Data in the required format , to pass to the predefined methods in "Route" bean
   
            /**
                        Service method is to get all the content Ids.
            */
    String[] getContentId(Context context,FormBean formBean,HashMap stateMap) {
        String[] existingContentIds=null;
        java.util.Set contentIdSet=null;
        TreeSet tempSet=new  TreeSet();
        if(stateMap!=null && stateMap.size()>0) {
            contentIdSet=stateMap.keySet();
        }
        else {
            contentIdSet=new TreeSet();
        }
        String contentId=(String)formBean.getElementValue("searchDocId");
        String objectId=(String)formBean.getElementValue("objectId");
        if(objectId==null || objectId.equals("null") ) {
            objectId="";
        }
        if(contentId==null || contentId.equals("null") || contentId.equals("")) {
            return null;
        }
        StringTokenizer contentTokenizer=new StringTokenizer(contentId,"~");
        while(contentTokenizer.hasMoreTokens()) {
            String curToken=contentTokenizer.nextToken();
            if((!contentIdSet.contains(curToken)) && (!curToken.equals(objectId))) {
                tempSet.add(curToken);
            }
        }
        tempSet.addAll(contentIdSet);
        tempSet.remove(objectId);
        Object[] a=tempSet.toArray();
        String[] s=new String[a.length];
        System.arraycopy(a,0,s,0,a.length);
        return s;
    }

    /**
            Service method to get all the state details
            HashMap containing OBJECTID->Corresponding State is returned
    */
    HashMap getStateDetails(matrix.db.Context context,FormBean formBean) {
        String[] stateArray=(String [])formBean.getElementValues("stateSelect");
        String objectId=(String)formBean.getElementValue("objectId");
        if(objectId==null || objectId.equals("null") ) {
            objectId="";
        }
        HashMap stateMap=new HashMap();
        if(stateArray!=null && !stateArray.equals("null") && stateArray.length!=0) {
            for(int index=0;index<stateArray.length;index++) {
                String curState=stateArray[index];
                int delim=curState.indexOf("#");
                String contentId=curState.substring(0,delim);
                String contentState=curState.substring(delim+1);
                stateMap.put(contentId,contentState);
            }
        }
        return stateMap;
    }
    /**
    	Service method to get all the details required for Tasks Creation. The retuned map list will be used in "addRouteMembers()" method of Route Bean.
    */
    MapList getTaskDetails(matrix.db.Context context, FormBean formBean) throws Exception{
		MapList taskMapList=new MapList();
    	try {      
          com.matrixone.apps.common.Person personObject = null;
          String routeActionStr                   = Person.ATTRIBUTE_ROUTE_ACTION;
          String routeScheduledCompletionDate     = "";
          String routeSequenceStr                 = com.matrixone.apps.common.Person.ATTRIBUTE_ROUTE_SEQUENCE;
          String routeInstructionsStr             = com.matrixone.apps.common.Person.ATTRIBUTE_ROUTE_INSTRUCTIONS;
          String routeScheduledCompletionDateStr  = com.matrixone.apps.common.Person.ATTRIBUTE_SCHEDULED_COMPLETION_DATE;
          String taskNameStr                      = com.matrixone.apps.common.Person.ATTRIBUTE_TITLE;
          String routeAllowDelegation             = com.matrixone.apps.common.Person.ATTRIBUTE_ALLOW_DELEGATION;
          String relRouteNode                     = com.matrixone.apps.common.Person.RELATIONSHIP_ROUTE_NODE;
          String routeAssigneeDueDateOpt          = PropertyUtil.getSchemaProperty(context, "attribute_AssigneeSetDueDate");
          String routeDueDateOffset               = PropertyUtil.getSchemaProperty(context, "attribute_DueDateOffset");
          String routeDueDateOffsetFrom           = PropertyUtil.getSchemaProperty(context, "attribute_DateOffsetFrom");
          String taskNeedsReview                  = PropertyUtil.getSchemaProperty(context, "attribute_ReviewTask");
                 routeActionStr                   = PropertyUtil.getSchemaProperty(context, "attribute_RouteAction");
          String routeMembers=(String)formBean.getElementValue("routeMemberString");
		  
		  //Added for bug 351803
		  //Retrieving the value of allowDelegation from formBean
          String strAllowDelegation				  = (String) formBean.getElementValue("allowDelegation");
          if(routeMembers!=null && routeMembers.length() > 0) {
            StringTokenizer routeMemberTokenizer=new StringTokenizer(routeMembers,"|");
        		while(routeMemberTokenizer.hasMoreTokens()) {
                HashMap taskMap=new HashMap();
                String curMemberElement=routeMemberTokenizer.nextToken();
                String personId=curMemberElement.substring(0,curMemberElement.indexOf("~"));
                String personName=curMemberElement.substring(curMemberElement.indexOf("~")+1);
                String langRole = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,  "emxFramework.Common.Role", context.getLocale());
                String langGroup = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,  "emxFramework.Common.Group", context.getLocale());
                String userGroup = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.Type.Group",context.getLocale());
                if(personName.indexOf("("+langRole+")")!=-1) {
                    personName=personId;
                    personId="Role";
                }
                else if(personName.indexOf("("+langGroup+")")!=-1) {
                    personName=personId;
                    personId="Group";

                } else if (personName.indexOf("("+userGroup+")")!=-1){
                	 personName = personName.substring(0, personName.indexOf("("+userGroup+")"));
                }
                taskMap.put("PersonId",personId);
                taskMap.put("PersonName",personName);
                taskMap.put(routeInstructionsStr,(String)formBean.getElementValue("routeInstructions"));
                taskMap.put(taskNameStr,"");
                taskMap.put(routeScheduledCompletionDateStr,(String)formBean.getElementValue("formattedDueDate"));
                taskMap.put(routeActionStr,(String)formBean.getElementValue("routeAction"));
                taskMap.put(routeSequenceStr,"1");
                taskMap.put(routeDueDateOffset,"");
                taskMap.put("templateFlag",null);
                taskMap.put(taskNeedsReview,"No");
                taskMap.put(DomainConstants.SELECT_NAME,personName);
				//Added for bug 351803
				//Adding the allowDelegation parameter to HashMap
                taskMap.put(routeAllowDelegation,strAllowDelegation);

                taskMapList.add(taskMap);
            }
          }
    	} catch(Exception e) {
    	    throw e;
    	}
        return taskMapList;
    }

        /**
    	Service method to get All the member Access. The returned MapList will be used in the method "addRouteMemberAccess()" of "Route" bean
        */

    MapList getMemberAccessDetails(matrix.db.Context context,MapList taskMapList) {
        MapList routeMemberMapList=new MapList();
        String sUser = context.getUser();
        try {
            if(taskMapList!=null) {
                for(Iterator listItr=taskMapList.iterator();listItr.hasNext();) {
                    HashMap taskMap=(HashMap)listItr.next();
                    HashMap memberMap=new HashMap();
                    String personId=(String)taskMap.get("PersonId");
                    String personName=(String)taskMap.get("PersonName");

                    if(personId.equals("Role") || personId.equals("Group")) {
                        memberMap.put("type",personId);
                        memberMap.put("projectLead", "");
                        memberMap.put("createRoute", "");
                        memberMap.put("OrganizationName","");
                        memberMap.put("access","Read");
                        memberMap.put("LastFirstName",personName);
                        memberMap.put("name",personName);
                        memberMap.put(DomainConstants.SELECT_ID , personId);
                        memberMap.put(DomainConstants.SELECT_NAME ,personName);
                    }
                    else {
                        DomainObject personObject=null;
                        personObject =   DomainObject.newInstance(context , personId);
                        String sCreateRoute         = PropertyUtil.getSchemaProperty(context, "attribute_CreateRoute");
                        String sOrgName             = personObject.getInfo(context,"to["+DomainObject.RELATIONSHIP_EMPLOYEE+"].from.name");
                        String sFirstName           = personObject.getInfo(context,"attribute["+DomainObject.ATTRIBUTE_FIRST_NAME +"]");
                        String sLastName            = personObject.getInfo(context,"attribute["+DomainObject.ATTRIBUTE_LAST_NAME +"]");
                        String userName             = personObject.getName();
                        memberMap.put(DomainObject.SELECT_ID,personId);
                        memberMap.put(DomainObject.SELECT_NAME, userName);
                        memberMap.put("LastFirstName",sLastName+", "+sFirstName);
                        memberMap.put(DomainObject.SELECT_TYPE,personObject.getInfo(context,DomainConstants.SELECT_TYPE));
                        memberMap.put("projectLead","");
                        memberMap.put("createRoute",sCreateRoute);
                        memberMap.put("OrganizationName",sOrgName);
                        if(userName.equals(sUser)) {
                                memberMap.put("access","Add Remove");
                        }
                        else {
                                memberMap.put("access","Read");
                        }
                    }
                    routeMemberMapList.add(memberMap);
                }
            }
        }
        catch(Exception e) {}
        return routeMemberMapList;
    }
            /**
    	Service method to get the Attribute Values to set for the Route. The retuned Hashtable will be used in "createRouteWithScope()" method of Route  bean
            */
    Hashtable getRouteAttributes(Context context,FormBean formBean,HashMap stateMap) {
        Hashtable props=new Hashtable();
        String routeStart=(String)formBean.getElementValue("routeInitiateManner");
        String objectId=(String)formBean.getElementValue("objectId");
        if(objectId==null || objectId.equals("null") ) {
            objectId="";
        }
        String parentId=(String)formBean.getElementValue("parentId");
        String scopeId=(String)formBean.getElementValue("scopeId");
        props.put("routeName","");
        props.put("routeAutoName","true");
        props.put("templateId","");
        props.put("templateName","");
        if(routeStart!=null && routeStart.equals("start")) {
            props.put("routeStart","start");
        }
        else {
            props.put("routeStart","");
        }
        props.put("visblToParent","false");
        props.put("routeDescription","");
        props.put("routeCompletionAction","Notify Route Owner");
        props.put("routeBasePurpose","Standard");
        props.put("objectId",objectId);
        props.put("projectId",parentId);
        props.put("scopeId",scopeId);
        props.put("selscope","");
        props.put("routeDueDate",(String)formBean.getElementValue("formattedDueDate"));
        props.put("routeInstructions",(String)formBean.getElementValue("routeInstructions"));
        props.put("routeAction",(String)formBean.getElementValue("routeAction"));
        Hashtable earlierProps=(Hashtable)formBean.getElementValue("hashRouteWizFirst");
        for(Iterator keyItr=earlierProps.keySet().iterator();keyItr.hasNext();) {
            String curKey=(String)keyItr.next();
            if(!props.containsKey(curKey)) {

                props.put(curKey,(String)earlierProps.get(curKey));
            }
        }
        props.putAll(stateMap);
        return props;
    }

    /**
    	Class used to perform all the activities related to Simple Route Creation Only on entry point is provided "createSimpleRoute()" .
    */
    static final class SimpleRouteCreator {
        Context context=null;
        Route route=null;
        HashMap routeProps=null;
        String exceptionMessage="";
        com.matrixone.apps.common.Person person;
        BusinessObject personObject;
        public SimpleRouteCreator(Context context) {
            this.context=context;
            try {
                person = (com.matrixone.apps.common.Person)DomainObject.newInstance(context,DomainConstants.TYPE_PERSON);
                personObject = (BusinessObject)person.getPerson(context);
            }
            catch(Exception e) {}
        }

        /**
                The public method which internally calls the remaining methods
        */
        public HashMap createSimpleRoute(HashMap stateMap,String[] contentIdArray,Hashtable routeDetails,MapList routeMemberMapList,MapList taskMapDetails,HttpSession session) {
            String objectId="";
            String routeId="";
            DomainObject currentObject=null;
            try {
                objectId=(String)routeDetails.get("objectId");
                route=(Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
                currentObject=new DomainObject();
                currentObject.setId(objectId);
                routeProps=createRoute(context,objectId,routeDetails);
                if(routeProps!=null) {
                	routeId=(String)routeProps.get("routeId");
                    route.setId(routeId);
                }
                isProjectOrWorkspace(context,session);

                addRouteContent(contentIdArray,stateMap);

                createRouteTasks(taskMapDetails);

                giveRouteMembersAccess(routeMemberMapList);

            }
            catch(Exception e) {
                exceptionMessage=e.getMessage();
                session.putValue("error.message",exceptionMessage);
            }
            return routeProps;
        }
        private HashMap createRoute(Context context,String objectId,Hashtable routeDetails) throws Exception {
            HashMap routeProps=null;
            try {
                if( objectId!=null && !objectId.equals("null")  && !objectId.equals("") ) {
                    routeProps=Route.createRouteWithScope(context,objectId,"","",true,routeDetails);
                }
                else {
                     String autoRouteId=FrameworkUtil.autoName(context,"type_Route","","policy_Route");
                     routeProps=new HashMap();
                     routeProps.put("routeId",autoRouteId);
                      DomainObject tempRoute = (Route)DomainObject.newInstance(context,autoRouteId);
                      tempRoute.open(context);
                      personObject.open(context);
                      tempRoute.connect(context,new RelationshipType(DomainObject.RELATIONSHIP_PROJECT_ROUTE),true,personObject);
                }
            }
            catch(Exception e) {
                throw e;
            }
            return routeProps;
        }
        private void addRouteContent(String[] contentIdArray,HashMap stateMap) throws Exception {
            if(route!=null && stateMap!=null && contentIdArray!=null && contentIdArray.length > 0) {
                route.AddContent(context,contentIdArray,stateMap);
            }
        }
        private void createRouteTasks(MapList  taskMapList) throws Exception {
			if(route!=null && taskMapList!=null && taskMapList.size() > 0 ) {
                try {
                    route.addRouteMembers(context,taskMapList,new HashMap());
                }
                catch(Exception e) {
                    throw e;
                }
            }
        }
        
        
        private void giveRouteMembersAccess(MapList routeMemberMapList) throws Exception {
			if(route!=null && routeMemberMapList!=null && routeMemberMapList.size() > 0) {
            	try {
                    route.addRouteMemberAccess(context,routeMemberMapList);
                }
                catch(Exception e) {
                    throw e;
                }
            }
        }
        private void isProjectOrWorkspace(Context context,HttpSession session) throws Exception {
			if(route!=null && context!=null && routeProps!=null && routeProps.size() > 0) {
            	try {
                                 String workspaceId=(String)routeProps.get("workspaceId");
                    if(workspaceId!=null && !workspaceId.equals("null") && !workspaceId.equals("")) {
                                     DomainObject parentObject=new DomainObject(workspaceId);
                                     String sPrjType=parentObject.getInfo(context, DomainObject.SELECT_TYPE);
                        if(DomainObject.TYPE_WORKSPACE.equals(sPrjType) || DomainObject.TYPE_PROJECT.equals(sPrjType)) {
                                               com.matrixone.apps.common.Person pr1 = com.matrixone.apps.common.Person.getPerson(context);
                                               // get the project Member.
                                               BusinessObject memberObject = JSPUtil.getProjectMember( context, session , workspaceId, pr1);
                                               // connect Project Member to Route
                                               route.connect(context,new RelationshipType(DomainObject.RELATIONSHIP_MEMBER_ROUTE),true,memberObject);
                                     }
                               }
                        }
                catch(Exception e) {}
                }
        }
    }
%>
<script language="JavaScript">
function submitProcessForm() {
        document.simpleRouteProcessForm.submit();


}
</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<form name="simpleRouteProcessForm" action="emxRouteSimpleStartProcess.jsp">
<%
    if(createdRouteDetails!=null && createdRouteDetails.size() > 0) {
%>
        <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=(String)createdRouteDetails.get("routeId")%></xss:encodeForHTMLAttribute>"/>
        <input type="hidden" name="workspaceId" value="<xss:encodeForHTMLAttribute><%=(String)createdRouteDetails.get("workspaceId")%></xss:encodeForHTMLAttribute>"/>
        <!-- //XSSOK -->
        <input type="hidden" name="folderId" value="<%=((String)createdRouteDetails.get("folderId"))!=null?XSSUtil.encodeForHTMLAttribute(context, (String)createdRouteDetails.get("folderId")):""%>"/>
<%
    }
    else {
%>
        <input type="hidden" name="routeId" value=""/>
        <input type="hidden" name="workspaceId" value=""/>

        <input type="hidden" name="folderId" value=""/>

<%
    }

%>
  <input type="hidden" name="routeStart" value="<xss:encodeForHTMLAttribute><%=(String)formBean.getElementValue("routeInitiateManner")%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>"/>
  <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
    </form>
        <script language="javascript">
        submitProcessForm();
        </script>




