<%--  emxRouteEditAllTasksDialog.jsp

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteEditAllTasksDialog.jsp.rca 1.30 Tue Oct 28 19:01:06 2008 przemek Experimental przemek $

--%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file  = "../emxJSValidation.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxComponentsJavaScript.js"%>
<%@ page import = "com.matrixone.apps.framework.ui.UIUtil"%>

<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
</head>
<% 
String isPreviousPage=emxGetParameter(request,"previous");
if(UIUtil.isNullOrEmpty(isPreviousPage)){
  session.removeAttribute("formBean");	
}
%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  String temp_hhrs_mmin                 = JSPUtil.getApplicationProperty(context,application,"emxComponents.RouteScheduledCompletionTime");
  Calendar calendar                     = new GregorianCalendar();
  int AllowDelegationCount         = 0;
  int NeedsReviewCount                  = 0;
  String mode=emxGetParameter(request,"mode");
  String strAny =EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),
  		"emxComponents.AssignTasksDialog.Any");

       boolean isResponsibleRoleEnabled=com.matrixone.apps.common.InboxTask.checkIfResponsibleRoleEnabled(context);
   String strAssigneeLabel=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.AssignTasksDialog.AssigneeInstructions");
  if(isResponsibleRoleEnabled){
  	strAssigneeLabel=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.AssignTasksDialog.AssigneeReviewerInstructions");
  }

  if(UIUtil.isNotNullAndNotEmpty(mode)&& mode.equals("EnableResponsibleRole")){
  //Method To list Role or Person for selected value in Route Template create form
        String strValue=emxGetParameter(request,"assigneeName");
        String strcount=emxGetParameter(request,"count");
		StringList slVal=FrameworkUtil.split(strValue, "~");
		String strAssigneeName=(String)slVal.get(1);
  	 	StringList slRecepientList=new StringList();
  	 	StringBuffer strHTMLElement  = new StringBuffer();
  	 	String strUserOrg = PersonUtil.getActiveOrganization(context);
  	 	boolean isRole=false;
  		try{
  			strAssigneeName=PropertyUtil.getSchemaProperty(context, strAssigneeName);
  			slRecepientList=PersonUtil.getPersonFromRole(context,strAssigneeName);
  			isRole=true;
  		}catch(Exception e){
  			slRecepientList.removeAllElements();
  		}
  		
  		if((slRecepientList.size()==0)&&!isRole){
  			strHTMLElement.append("<input type=\"text\"  id=\"recepientList"+XSSUtil.encodeForHTMLAttribute(context,strcount)+"\" name = \"recepientList\" readonly=true disabled style=\"width:200px\"></input>").append("<input type=\"hidden\" id=\"recepientList"+XSSUtil.encodeForHTMLAttribute(context,strcount)+"\" name = \"recepientList\"  style=\"width:200px\" value=\" \">  </input>");
  		}
  		else{
  			strHTMLElement.append("<select id=\"recepientList"+XSSUtil.encodeForHTMLAttribute(context,strcount)+"\" name = \"recepientList\"  style=\"width:200px\">");
  		strHTMLElement.append("<option value=\"Any\">"+strAny+" </option>");
  		for(Object obj :slRecepientList){
  				String strAssign=(String)obj;
  				String strOrg=PersonUtil.getDefaultOrganization(context, strAssign);
  				if(strUserOrg.equals(strOrg)){
  				strHTMLElement.append(" <option value=\""+strAssign+"\">"+PersonUtil.getFullName(context, strAssign) +"</option>");
                	}
                }
  		strHTMLElement.append("</select>");
  		}
  	out.clear();
  	out.println(strHTMLElement);
  }
  else if(UIUtil.isNullOrEmpty(mode)){
// Added for the Bug No:350789 starts
 Map routeMapDetails;
  try {
	routeMapDetails = (Map) formBean.getElementValue("mapRouteDetails");
  }
  catch(Exception e) {
	  routeMapDetails=null;
  }
  //Added for the Bug No:350789 Ends

	 com.matrixone.apps.common.Person PersonObject = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);
  String timeZone                       = (String)session.getValue("timeZone");
  double clientTZOffset   = (new Double(timeZone)).doubleValue();
  int intDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
  String sDisplayPersonName             = "";
  String strTemplateTaskSetting         = "";
  String routeId                         = emxGetParameter(request,"objectId");
  String sSortName                       = emxGetParameter(request, "sortName");
  String slctdd                          = emxGetParameter(request,"slctdd");
  String slctmm                          = emxGetParameter(request,"slctmm");
  String slctyy                          = emxGetParameter(request,"slctyy");
  String isTemplate                      = emxGetParameter(request,"isTemplate");
  String addTasks                        = emxGetParameter(request,"addTasks");
  String fromPage                        = emxGetParameter(request,"fromPage");
  String newTaskIds                      = emxGetParameter(request,"newTaskIds");
  String parentTaskDueDate = getParentTaskDueDate(context,routeId);

  String roleI18N = "(" + i18nNow.getI18nString("emxComponents.Common.Role", "emxComponentsStringResource",sLanguage) + ")";
  String groupI18N = "(" + i18nNow.getI18nString("emxComponents.Common.Group", "emxComponentsStringResource",sLanguage) + ")";
  String userGroupI18N = "(" + EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",new Locale(sLanguage), "emxFramework.Type.Group") + ")";
%>
	<script language="javascript">
	<!--
		var dtParentTaskDueDate = null;
		//
		// Method to check task due date against parent tasks due date value and for past dates
		// Parameters:
		// dtParentTaskDueDate : The Date object, initialized with parent task due date
		// lngSelectedDateMsValue : The miliseconds of the due date selected against a task
		// strSelectedTime : The time selected in format "5:30:00 PM"
		// Returns:
		// true if the validation is successful, false is validation fails
		//
		function validateTaskDueDate(dtParentTaskDueDate, lngSelectedDateMsValue, strSelectedTime) {
			var dtGivenDueDate = new Date();
			dtGivenDueDate.setTime(lngSelectedDateMsValue);
			
			var arrRouteTime = strSelectedTime.split(":");//5:00:00 PM format
			var arrRouteTimeSecAMPM = arrRouteTime[2].split(" ");//00 PM
			
			var strHours = arrRouteTime[0];
			var strMinutes = arrRouteTime[1];
			var strSeconds = arrRouteTimeSecAMPM[0];
			
			var strAMPM = arrRouteTimeSecAMPM[1];
			if (strAMPM == "PM") {
				strHours = parseInt(strHours) + 12;// Convert to 24 hr format
			}
			
			dtGivenDueDate.setHours(strHours);
			dtGivenDueDate.setMinutes(strMinutes);
			dtGivenDueDate.setSeconds(strSeconds);
			
			var dtCurrentDate = new Date();
			
			if (dtGivenDueDate.getTime() < dtCurrentDate.getTime()) {
				alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterdPastDate</emxUtil:i18nScript>");
				return false;
			}
			
			if (dtGivenDueDate.getTime() >= dtParentTaskDueDate.getTime()) {
				alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskDetails.IncorrectSubordinateDate</emxUtil:i18nScript>");
				return false;
			}
			
			return true;
		}
	-->
	</script>
<% 
	//Find if this route is subroute
  if (routeId != null && !"".equals(routeId) && !"null".equals(routeId)) {
      final String SELECT_ATTRIBUTE_SCHEDULED_COMPLETION_DATE = "attribute[" + DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE + "]";
      
      StringList slBusSelect = new StringList();
      slBusSelect.addElement(SELECT_ATTRIBUTE_SCHEDULED_COMPLETION_DATE);
      
      DomainObject dmoRoute = DomainObject.newInstance(context, routeId);
      Map mapParentTask = dmoRoute.getRelatedObject (context, 
              											DomainObject.RELATIONSHIP_TASK_SUBROUTE,
              											false,
              											slBusSelect, 
              											new StringList()) ;
      if (mapParentTask != null) {
          String strScheduledDate = (String)mapParentTask.get(SELECT_ATTRIBUTE_SCHEDULED_COMPLETION_DATE);
          if (strScheduledDate == null || "".equals(strScheduledDate) || "null".equals(strScheduledDate)) {
%>
			<script language="javascript">
			<!--
				dtParentTaskDueDate = null;
			-->
			</script>
<%              
          }
          else {
              Date dtParentTaskDueDate = eMatrixDateFormat.getJavaDate(strScheduledDate);
%>
			<script language="javascript">
			<!--
				dtParentTaskDueDate = new Date();
				dtParentTaskDueDate.setTime(<%=dtParentTaskDueDate.getTime()%>);
			-->
			</script>
<%              
          }
          
      }
  }
//End : Bug 344305


  String OFFSET_FROM_ROUTE_START_DATE    = "Route Start Date";

  boolean isTemplateEdit      = false;
  boolean showDefaultDate     = false;  // flag shows date only for calendar option

  if(isTemplate != null && !"null".equals(isTemplate) && "yes".equals(isTemplate)){
    isTemplateEdit            = true;
  }  else {
    isTemplate               = "no";
    isTemplateEdit           = false;
  }

  if(fromPage == null || "null".equals(fromPage)){
    fromPage = "";
  }

  if("task".equals(fromPage)){
    // set true only if this dialog page called from Route Summary page.
    showDefaultDate = true;
  }

  if (sSortName==null){
    sSortName="";
  }
  String sAsigneeId        = "";
  String sRelId            = "";
  String sTypeName         = "";
  String sRouteNodeID      = "";
  String sSequence         = "";
  String sConnectedRoute   = "";
  String sName             = null;
  String sAsignee          = null;
  String sDueDate          = null;
  String sAllowDelegation  = null;
  String sAction           = null;
  String sReviewTask       = null;
  String sInstruction      = null;
  String sRouteState       = null;
  String sTaskId           = null;
  String sAssigneeDueDate  = null;
  String sSelected         = "";
  String tempId            = "";

  int taskCount      = 0;
  int xx             = 0;
  int hhrs           = 0;
  int mmin           = 0;
  int intSeq         = 1;

  SelectList selectStmts = new SelectList();

  //For creating a new revision of Route template
  Pattern relPattern                          = null;
  Pattern typePattern                         = null;
  SelectList selectStmt                       = null;
  SelectList selectRelStmt                    = null;
  Vector vectTitles                     = new Vector();
  Vector vectAssignedTitles             = new Vector(); //Added for Bug-310065
  boolean bOwnerNotSetDate              = false;
  boolean bAssigneeDueDate              = false;
  boolean bDeltaDueDate                 = false;
  boolean bDueDateEmpty                 = false;
  Date maxDueDate                      = null;
  String actualRouteNodeId             = null;
  String maxOrder                      = "0";
  String routeSequenceValueStr1         = null;
  // This HardCoded Date formate should be used for JavaScript conversion..
  // Please don't replace with eMatrixDateFormat.getEMatrixDateFormat()....
  java.text.SimpleDateFormat USformatter = new java.text.SimpleDateFormat ("MM/dd/yyyy hh:mm:ss a");
  // looping into physical tasks - Complete and In progress.
  int iDateFormat1 = eMatrixDateFormat.getEMatrixDisplayDateFormat();
  java.text.DateFormat formatter = DateFormat.getDateTimeInstance(iDateFormat1, iDateFormat1, request.getLocale());

  // build select params
  selectStmts = new SelectList();
  selectStmts.addName();
  selectStmts.addId();
  selectStmts.addType();
  selectStmts.addAttribute(DomainObject.ATTRIBUTE_TEMPLATE_TASK);

  Route RouteObj = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);

  RouteObj.setId(routeId);
  
  /*vh5 modification for UI Adoption*/
  StringList selectTypeStmts  =  new StringList();
  StringList selectTypeStmts1  =  new StringList();
  selectTypeStmts.add(RouteObj.SELECT_NAME);
  selectTypeStmts.add(RouteObj.SELECT_ID);
  selectTypeStmts.add(RouteObj.SELECT_TYPE);
  String strKindOfProxyGroup = "type.kindof["+ PropertyUtil.getSchemaProperty(context, "type_GroupProxy") +"]";
  selectTypeStmts.add(RouteObj.SELECT_TYPE);
  selectTypeStmts.add(strKindOfProxyGroup);
  MapList routeMemberList  = RouteObj.getRouteMembers(context, selectTypeStmts,selectTypeStmts1,false);
  StringBuffer personList = new StringBuffer(100);
  StringBuffer rolesList = new StringBuffer(100);
  StringBuffer groupsList = new StringBuffer(100);
  StringBuffer userGroupList = new StringBuffer(100);
  Iterator mapItr1 = routeMemberList.iterator();

  while(mapItr1.hasNext()){
      Map roleMap = (Map)mapItr1.next();
      String type = (String)roleMap.get(DomainObject.SELECT_TYPE);
      String roleName = (String)roleMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
      String kindOfProxyGroup = (String)roleMap.get(strKindOfProxyGroup);
      if(type.equals(DomainObject.TYPE_ROUTE_TASK_USER)) {
          if(UIUtil.isNullOrEmpty(roleName)) {
              continue;
          }
          if(roleName.startsWith("role_")) {
              rolesList.append(roleMap.get("name")).append("|");
          } else if(roleName.startsWith("group_")) {
              groupsList.append(roleMap.get("name")).append("|");
          }
      }else if("true".equalsIgnoreCase(kindOfProxyGroup)){
    	  userGroupList.append(roleMap.get("id")).append("|");
      } else {
          personList.append(roleMap.get("id")).append("|");
      }
  }
  
  if(personList.length() > 0) {
      personList.deleteCharAt(personList.length() -1);
  }
  if(rolesList.length() > 0) {
      rolesList.deleteCharAt(rolesList.length() -1);
  }
  if(groupsList.length() > 0) {
      groupsList.deleteCharAt(groupsList.length() -1);
  }
  if(userGroupList.length() > 0) {
	  userGroupList.deleteCharAt(userGroupList.length() -1);
  }
  
  StringList slBusSelect = new StringList(RouteObj.SELECT_ROUTE_BASE_PURPOSE);
  slBusSelect.add (DomainObject.SELECT_TYPE);
  slBusSelect.add (DomainObject.SELECT_CURRENT);
  
  Map mapRouteObjInfo = RouteObj.getInfo (context, slBusSelect);
  sTypeName = (String) mapRouteObjInfo.get (DomainObject.SELECT_TYPE);
  String sRoute = (String) mapRouteObjInfo.get (RouteObj.SELECT_ROUTE_BASE_PURPOSE);
  String sCurrentState = (String) mapRouteObjInfo.get (DomainObject.SELECT_CURRENT);

  boolean showNoneOption = (DomainObject.TYPE_ROUTE_TEMPLATE.equals(sTypeName) || 	
        				   (DomainObject.TYPE_ROUTE.equals(sTypeName) && DomainObject.STATE_ROUTE_DEFINE.equals(sCurrentState)));


  StringBuffer selectAssigneeURL = new StringBuffer();
  selectAssigneeURL.append("../common/emxIndentedTable.jsp?");
  selectAssigneeURL.append("table=APPUserSummary").append('&');
  selectAssigneeURL.append("selection=single").append('&');
  selectAssigneeURL.append("program=emxRoute:getRouteAssigneesToSelect").append('&');
  selectAssigneeURL.append("showNone=").append(showNoneOption).append('&');
  selectAssigneeURL.append("personList=").append(personList).append('&');
  selectAssigneeURL.append("roleList=").append(rolesList).append('&');
  selectAssigneeURL.append("groupList=").append(groupsList).append('&');
  selectAssigneeURL.append("userGroupList=").append(userGroupList).append('&');
  selectAssigneeURL.append("submitURL=").append("../components/emxRouteWizardTaskAssignSelectProcess.jsp?fromPage=Route").append('&');
  selectAssigneeURL.append("suiteKey=Components").append('&');
  selectAssigneeURL.append("header=emxComponents.Common.AssignTasks").append('&');
  selectAssigneeURL.append("submitLabel=emxFramework.Common.Done").append('&');
  selectAssigneeURL.append("cancelLabel=emxFramework.Common.Cancel").append('&');
  selectAssigneeURL.append("objectBased=false").append('&');
  selectAssigneeURL.append("displayView=details").append('&');
  selectAssigneeURL.append("HelpMarker=emxhelpcreateroutewizard3").append('&');
  selectAssigneeURL.append("showClipboard=false").append('&');
  
  // Bug 345680: Show options Approve,Comment,Notify Only only
  AttributeType attrRouteAction = new AttributeType(DomainConstants.ATTRIBUTE_ROUTE_ACTION);
  attrRouteAction.open(context);
    
  // Remove the Info Only and Investigate ranges which we no longer support - Bug 347955
  StringList routeActionList = attrRouteAction.getChoices(context);
  routeActionList.remove ("Information Only");
  routeActionList.remove ("Investigate");
//Modified for bug 359347
  Collections.sort ((java.util.List)routeActionList); // To maintain order Approve, Comment, Notify Only
 
  attrRouteAction.close(context);

  if("Approval".equals(sRoute))
  {
      routeActionList = new StringList(1);
      routeActionList.add("Approve");
  }
  else if("Review".equals(sRoute))
  {
      routeActionList = new StringList(1);
      routeActionList.add("Comment");
  }

  // Get route information
  final String SELECT_ATTRIBUTE_ROUTE_STATUS = "attribute[" + DomainObject.ATTRIBUTE_ROUTE_STATUS + "]";
  final String ATTRIBUTE_CURRENT_ROUTE_NODE = PropertyUtil.getSchemaProperty(context, "attribute_CurrentRouteNode");
  final String SELECT_ATTRIBUTE_CURRENT_ROUTE_NODE = "attribute[" + ATTRIBUTE_CURRENT_ROUTE_NODE + "]";

  StringList selStmt = new StringList();
  selStmt.add(DomainObject.SELECT_CURRENT);
  selStmt.add("from[" + DomainObject.RELATIONSHIP_INITIATING_ROUTE_TEMPLATE + "].to.id");
  selStmt.add(SELECT_ATTRIBUTE_ROUTE_STATUS);
  selStmt.add(SELECT_ATTRIBUTE_CURRENT_ROUTE_NODE);

  Map routeMap = RouteObj.getInfo(context, selStmt);

  sRouteState  = (String)routeMap.get(DomainObject.SELECT_CURRENT);
  String strRouteStatus = (String)routeMap.get(SELECT_ATTRIBUTE_ROUTE_STATUS);
  String strCurrentRouteLevel = (String)routeMap.get(SELECT_ATTRIBUTE_CURRENT_ROUTE_NODE);

  Person routeOwner = Person.getPerson(context);
  String routeOwnerName          ="Person~"+routeOwner.getObjectId();

  tempId= (String)routeMap.get("from[" + DomainObject.RELATIONSHIP_INITIATING_ROUTE_TEMPLATE + "].to.id");
  strTemplateTaskSetting = getTaskSetting(context,tempId);
  
  if(UIUtil.isNotNullAndNotEmpty(strTemplateTaskSetting)&& ("Maintain Exact Task List".equals(strTemplateTaskSetting)||"Extend Task List".equals(strTemplateTaskSetting) || "Modify Task List".equals(strTemplateTaskSetting))){
	  showNoneOption=false;
  }
  String groupType = PropertyUtil.getSchemaProperty(context,"type_Group");
  String proxyGoupType = PropertyUtil.getSchemaProperty(context,"type_GroupProxy");
  typePattern = new Pattern(RouteObj.TYPE_PERSON);
  typePattern.addPattern(RouteObj.TYPE_ROUTE_TASK_USER);
  typePattern.addPattern(proxyGoupType);

  StringList relSelStmts = new StringList();
  relSelStmts.addElement("attribute["+RouteObj.ATTRIBUTE_ROUTE_TASK_USER+"]");
  relSelStmts.addElement("attribute["+RouteObj.ATTRIBUTE_ROUTE_SEQUENCE+"]");
  relSelStmts.addElement("attribute["+RouteObj.ATTRIBUTE_ALLOW_DELEGATION+"]");
  relSelStmts.addElement("attribute["+RouteObj.ATTRIBUTE_ROUTE_ACTION+"]");
  relSelStmts.addElement("attribute["+RouteObj.ATTRIBUTE_ROUTE_INSTRUCTIONS+"]");
  relSelStmts.addElement("attribute["+RouteObj.ATTRIBUTE_TITLE+"]");
  relSelStmts.addElement("attribute["+RouteObj.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]");
  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE+"]");
  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_REVIEW_TASK+"]");
  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_NODE_ID+"]");
  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_DUEDATE_OFFSET+"]");
  relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_DATE_OFFSET_FROM+"]");
   relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_TEMPLATE_TASK+"]");

  MapList RouteMapList = RouteObj.getRelatedObjects(context,
                                                    RouteObj.RELATIONSHIP_ROUTE_NODE,            //String relPattern
                                                    typePattern.getPattern(),     //String typePattern
                                                    selectStmts,              //StringList objectSelects,
                                                    relSelStmts,                     //StringList relationshipSelects,
                                                    false,                     //boolean getTo,
                                                    true,                     //boolean getFrom,
                                                    (short)1,                 //short recurseToLevel,
                                                    "",                       //String objectWhere,
                                                    "",                       //String relationshipWhere,
                                                    null,                     //Pattern includeType,
                                                    null,                     //Pattern includeRelationship,
                                                    null);                    //Map includeMap
  RouteMapList.sort("attribute["+RouteObj.ATTRIBUTE_ROUTE_SEQUENCE+"]", "ascending","integer");
  Iterator personItr = RouteMapList.iterator();

  selectStmts = new SelectList();
  selectStmts.addId();
  selectStmts.addAttribute(DomainObject.ATTRIBUTE_TEMPLATE_TASK);
  selectStmts.add("attribute["+Route.ATTRIBUTE_ROUTE_NODE_ID+"]");
  selectStmts.add(DomainConstants.SELECT_ID); //Added for Bug-310065
  selectStmts.add(DomainConstants.SELECT_CURRENT); //Added for Bug-310065
  selectStmts.add("from[" + RouteObj.RELATIONSHIP_PROJECT_TASK + "].to.id"); //Added for Bug-310065
  selectStmts.addElement("attribute["+RouteObj.ATTRIBUTE_ROUTE_SEQUENCE+"]");


  MapList InboxTaskList = RouteObj.getRelatedObjects(context,
                                                    RouteObj.RELATIONSHIP_ROUTE_TASK,   //String relPattern
                                                    RouteObj.TYPE_INBOX_TASK,           //String typePattern
                                                    selectStmts,                        //StringList objectSelects,
                                                    null,                               //StringList relationshipSelects,
                                                    true,                               //boolean getTo,
                                                    false,                              //boolean getFrom,
                                                    (short)1,                           //short recurseToLevel,
                                                    "",                                 //String objectWhere,
                                                    "",                                 //String relationshipWhere,
                                                    null,                               //Pattern includeType,
                                                    null,                               //Pattern includeRelationship,
                                                    null);                              //Map includeMap

//Start: Resume Process modifications
    // Due to Resume Process implemented for route, there can be situations when task objects are not connected to
    // person but connected to route object. Such tasks are the tasks which will be reused in future for new task assignments.
    // Here we will be ignoring such tasks. This can be decided, when value for "from[" + RouteObj.RELATIONSHIP_PROJECT_TASK + "].to.id"
    // is null, it means that the task is not connected to person object.
    MapList mlFilteredTasks = new MapList();
    Map mapTempTaskInfo = null;
    for (Iterator itrInboxTasks = InboxTaskList.iterator(); itrInboxTasks.hasNext();) {
        mapTempTaskInfo = (Map)itrInboxTasks.next();

        if (mapTempTaskInfo.get("from[" + RouteObj.RELATIONSHIP_PROJECT_TASK + "].to.id") != null) {
            mlFilteredTasks.add(mapTempTaskInfo);
        }
    }
    InboxTaskList = mlFilteredTasks;
//End: Resume Process modifications

  InboxTaskList.sort("attribute["+RouteObj.ATTRIBUTE_ROUTE_SEQUENCE+"]", "ascending","integer");
  int sTaskSequence = 0;

  // to check whether the route is connected with Object Route Relationship
  String sRouteId  = (String)RouteObj.getInfo(context,"from[" + RouteObj.RELATIONSHIP_ROUTE_NODE + "].to.id");
  BusinessObject boRouteNode = null;
  if(sRouteId != null) {
   boRouteNode =new BusinessObject(sRouteId);
  }

%>


<script language="Javascript" >
  var lastSeq;
  var bChange = false;
  var completedTasksRouteOrders = new Array;
  var CurrentDate = "";
<%
  if(slctdd!=null && !"null".equals(slctdd) && !"".equals(slctdd)){
%>
    emxUIPopupCalendar.prevDate = new Date('<%=XSSUtil.encodeForJavaScript(context, slctyy)%>','<%=XSSUtil.encodeForJavaScript(context, slctmm)%>','<%=XSSUtil.encodeForJavaScript(context, slctdd)%>');
<%
  }
%>


  // function to be called on click of Add Task Link
  function addTask() {
  //added for the bug no  341551 Rev 1
    submitAction = true;
    var thisday   = null;
    var thismonth = null;
    var thisyear  = null;
    var sSelectedDate = emxUIPopupCalendar.prevDate;

    if(sSelectedDate != null) {
      thismonth = sSelectedDate.getMonth();
      thisyear  = sSelectedDate.getFullYear();
      thisday   = sSelectedDate.getDate();
    }
    document.TaskSummary.fromPage.value="task";
    document.TaskSummary.action="emxRouteAssignNewTask.jsp?slctdd="+thisday+"&slctmm="+thismonth+"&slctyy="+thisyear+"&newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>";
    document.TaskSummary.submit();
    return;
  }
//added for the bug no  341551 Rev 1
  var submitAction = false;
  // function to close window
  function closeWindow() {
    //added for the bug no  341551 Rev 1
  submitAction = true;
    strurl ="emxRouteCancelNewTaskProcess.jsp?newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>";
    submitWithCSRF(strurl, window);
  }

  function setValue(){
    bChange = true;
  }

//Added for Bug-310065
  function changeAssignedOwner(taskNewOwner){
  	  /*if(taskNewOwner.value.match(document.TaskSummary.assignedTaskOwner.value)){
		  document.TaskSummary.assignedTaskID.value="";
	  }else{
		  document.TaskSummary.assignedTaskID.value = document.TaskSummary.assignedTaskOldID.value;
	  }*/
	  
  	// Begin Bug 346478 Changes
  	// Find out the position of given listbox element in the array of the listbox element
  	// then use the corresponding position of the other elements in their respective
  	// element array inside form.
  	var nPositionOfThisOwnerListBox = 0;
  	var nCurrentPosition = 0;
  	for (var i = 0; i < document.TaskSummary.elements.length; i++) {
  		if (document.TaskSummary.elements[i].name == "personId" && document.TaskSummary.elements[i].type == "select-one") {
  			if (document.TaskSummary.elements[i] == taskNewOwner) {
  				nPositionOfThisOwnerListBox = nCurrentPosition;
  				break;
  			}
  			nCurrentPosition ++;	
  		}
  	}
  	
  	var objAssignedTaskOwner = null;
  	var objAssignedTaskID = null;
  	var objAssignedTaskOldID = null;
  	
  	nCurrentPosition = 0;
  	for (var i = 0; i < document.TaskSummary.elements.length; i++) {
  		if (document.TaskSummary.elements[i].name == "assignedTaskOwner") {
  			if (nPositionOfThisOwnerListBox == nCurrentPosition) {
  				objAssignedTaskOwner = document.TaskSummary.elements[i];
  				break;
  			}
  			nCurrentPosition ++;
  		}
  	}
  	
  	nCurrentPosition = 0;
  	for (var i = 0; i < document.TaskSummary.elements.length; i++) {
  		if (document.TaskSummary.elements[i].name == "assignedTaskID") {
  			if (nPositionOfThisOwnerListBox == nCurrentPosition) {
  				objAssignedTaskID = document.TaskSummary.elements[i];
  				break;
  			}
  			nCurrentPosition ++;
  		}
  	}
  	
  	nCurrentPosition = 0;
  	for (var i = 0; i < document.TaskSummary.elements.length; i++) {
  		if (document.TaskSummary.elements[i].name == "assignedTaskOldID") {
  			if (nPositionOfThisOwnerListBox == nCurrentPosition) {
  				objAssignedTaskOldID = document.TaskSummary.elements[i];
  				break;
  			}
  			nCurrentPosition ++;
  		}
  	}

  	// If we do not find any of these elements then return
  	if (objAssignedTaskOwner == null || objAssignedTaskID == null || objAssignedTaskOldID == null) {
  		return;
  	}
  
  	if(taskNewOwner.value.match(objAssignedTaskOwner.value)){
		objAssignedTaskID.value = "";
	}else{
		objAssignedTaskID.value = objAssignedTaskOldID.value;
	}
	// End Bug 346478 Changes
  }

  // This Function Checks For The Length Of The Data That Has
  // Been Entered And Trims the Extra Spaces In The Front And Back.
  function trimStr (textBox) {
    while (textBox.charAt(textBox.length-1)==' ')
      textBox = textBox.substring(0,textBox.length-1);
    while (textBox.charAt(0)==' ')
      textBox = textBox.substring(1,textBox.length);
    return textBox;
  }

//function to return the checked check box value.
  function checkedCheckBoxValues(){

     var checkedVal='';
     for (var i=0; i < document.TaskSummary.elements.length; i++) {

      if (document.TaskSummary.elements[i].type == "checkbox"
      && document.TaskSummary.elements[i].name == "chkItem1" && document.TaskSummary.elements[i].checked)  {

        checkedVal = checkedVal+document.TaskSummary.elements[i].value+'~'+document.TaskSummary.elements[i+2].value+'~';
       }
    }

    return checkedVal;
  }


//function to open the RouteTaskAssignSelected dialog window.
  function AssignSelected(){

    var checkedValue = checkedCheckBoxValues();

    if (checkedValue == '') {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignSelected.SelectTask</emxUtil:i18nScript>");
      return;
    } else {
    	var selectAssigneeURL = "<%=selectAssigneeURL%>routeNodeId=" + escape(checkedValue);
        emxShowModalDialog(selectAssigneeURL, 575, 575);
    }
  }

  // to allow only integers as delta offsets
  function CheckValidity(toCheckStr){
    var allowedChars = "0123456789";

    for (i = 0; i < toCheckStr.length; i++){
       checkChar = allowedChars.indexOf(toCheckStr.charAt(i))
        if (checkChar < 0){
          return true;
        }
    }
    return false;
  }

  //Array sort numerically
  function sortNum(arrayName,length){
    for (var i=0; i<(length-1); i++){
      for (var b=i+1; b<length; b++){
        if (arrayName[b] < arrayName[i]){
          var temp = arrayName[i];
          arrayName[i] = arrayName[b];
          arrayName[b] = temp;
        }
      }
    }
  }

  var showCalendarAlert = true; // to prevent second alert due to focus made again on radio option

  //removing focus from date field.Not letting user to update the field.
  function redirectFocus(num) {
    var count = 0;
    for ( var k = 0; k < document.TaskSummary.length; k++ ) {
    if ((document.TaskSummary.elements[k].name == "routeOrder")){
        count++;
      }
    }
    if (count == 1) {
       // check if calendar date radio is checked. Else alert calendar option not selected
      if((document.TaskSummary.duedateOption0[2].checked  && document.TaskSummary.duedateOption0[2].value == "assignee") || (document.TaskSummary.duedateOption0[1].checked  && document.TaskSummary.duedateOption0[1].value == "delta")){
        if(showCalendarAlert){
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.NotCalendarOption</emxUtil:i18nScript>");
         showCalendarAlert = false;
        }else{
          showCalendarAlert = true;
        }
        document.TaskSummary.duedateOption0[2].focus();
        return;
       }else{
        document.TaskSummary.routeTime.focus();
        showCalendar('TaskSummary','routeScheduledCompletionDate0',CurrentDate,true);
      }
    } else{
      if((eval("document.TaskSummary.duedateOption"+num+"[2].checked") && eval("document.TaskSummary.duedateOption"+num+"[2].value") =="assignee") || (eval("document.TaskSummary.duedateOption"+num+"[1].checked") && eval("document.TaskSummary.duedateOption"+num+"[1].value") =="delta")){
         if(showCalendarAlert){
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.NotCalendarOption</emxUtil:i18nScript>");
            showCalendarAlert = false;
         }else{
            showCalendarAlert = true;
         }
         eval("document.TaskSummary.duedateOption"+num+"[2].focus();");
         return;
      }else{
        showCalendarAlert = true;
        eval("document.TaskSummary.routeTime[" + num + "].focus();");
        eval("showCalendar('TaskSummary','routeScheduledCompletionDate"+ num +"',CurrentDate,true);");
      }
    }
    return;
  }

 // javascript function shows calendar popup only if calendar radio is chosen. Else alert user.
  function showCal(formName,dateField, id, num){
     var count = 0;
     for ( var k = 0; k < document.TaskSummary.length; k++ ) {
       // For Bug 346734: Checked how many listbox elements with name "routeTime" exists on this page
       if (( document.TaskSummary.elements[k].type  == "select-one" )&& (document.TaskSummary.elements[k].name == "routeTime")){
       	count++;
       }
     }
    if (count == 1) {
       if((document.TaskSummary.duedateOption0[2].checked && document.TaskSummary.duedateOption0[2].value =="assignee") || (document.TaskSummary.duedateOption0[1].checked && document.TaskSummary.duedateOption0[1].value =="delta")){
           alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.NotCalendarOption</emxUtil:i18nScript>");
           document.TaskSummary.duedateOption0[2].focus();
           return;
       }else{
          document.TaskSummary.routeTime.focus();
          showCalendar(formName,dateField,CurrentDate,true);
       }
    } else{
       if((eval("document.TaskSummary.duedateOption"+num+"[2].checked") && eval("document.TaskSummary.duedateOption"+num+"[2].value") =="assignee") || (eval("document.TaskSummary.duedateOption"+num+"[1].checked") && eval("document.TaskSummary.duedateOption"+num+"[1].value") =="delta")){
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.NotCalendarOption</emxUtil:i18nScript>");
          eval("document.TaskSummary.duedateOption"+num+"[2].focus();");
          return;
        }else{
          eval("document.TaskSummary.routeTime[" + num + "].focus();");
          showCalendar(formName,dateField,CurrentDate,true);
       }
     }

     return;
   }

  // javascript function to clear date value at particular field
  function cleardate(num) {
    var defaultTime = '<%=temp_hhrs_mmin.substring(0, (temp_hhrs_mmin.indexOf(':')+3))+":00 "+(temp_hhrs_mmin.indexOf("AM")>0?"AM":"PM")%>';
        var count = 0;
        for ( var k = 0; k < document.TaskSummary.length; k++ ) {
           if ((document.TaskSummary.elements[k].name == "routeOrder")){
               count++;
            }
        }

       if (count == 1) {
         if(trimStr(document.TaskSummary.routeScheduledCompletionDate0.value) !="") {
              document.TaskSummary.routeScheduledCompletionDate0.value="";
         }
         if(trimStr(document.TaskSummary.routeScheduledCompletionDate0_msvalue.value) !="") {
              document.TaskSummary.routeScheduledCompletionDate0_msvalue.value="";
         }

         for ( var z = 0; z < document.TaskSummary.routeTime.options.length; z++ ) {
           if(document.TaskSummary.routeTime.options[z].value==defaultTime) {
              document.TaskSummary.routeTime.options[z].selected=true;
              break;
           }
         }
        } else {
          if(trimStr(eval("document.TaskSummary.routeScheduledCompletionDate"+num+".value")) !="") {
            eval("document.TaskSummary.routeScheduledCompletionDate"+num+".value=\"\";");
         }
          if(trimStr(eval("document.TaskSummary.routeScheduledCompletionDate"+num+"_msvalue.value")) !="") {
            eval("document.TaskSummary.routeScheduledCompletionDate"+num+"_msvalue.value=\"\";");
         }


           var sCombo = eval("document.TaskSummary.routeTime[" + num + "];");
           for ( var z = 0; z < sCombo.options.length; z++ ) {
             if(sCombo.options[z].value==defaultTime) {
               sCombo.options[z].selected=true;
               break;
             }
           }
        }
      return;
    }

   // if assignee due-date selected, clear default date... when deselected show again..
  function toggleDefaultDate(num) {
      var count = 0;
      for ( var k = 0; k < document.TaskSummary.length; k++ ) {
         if ((document.TaskSummary.elements[k].name == "routeOrder")){
              count++;
         }
      }
      if (count == 1) {
         if((document.TaskSummary.duedateOption0[2].checked && document.TaskSummary.duedateOption0[2].value =="assignee") || (document.TaskSummary.duedateOption0[1].checked && document.TaskSummary.duedateOption0[1].value =="delta")) {
             cleardate(num);
         }
         if((document.TaskSummary.duedateOption0[0].checked && document.TaskSummary.duedateOption0[0].value =="calendar") || (document.TaskSummary.duedateOption0[2].checked && document.TaskSummary.duedateOption0[2].value =="assignee")) {
            document.TaskSummary.duedateOffset.value = "";
         }
         return;
      }else{
        if((eval("document.TaskSummary.duedateOption"+num+"[2].checked") && eval("document.TaskSummary.duedateOption"+num+"[2].value") =="assignee") || (eval("document.TaskSummary.duedateOption"+num+"[1].checked") && eval("document.TaskSummary.duedateOption"+num+"[1].value") =="delta")) {
           cleardate(num);
         }
         if((eval("document.TaskSummary.duedateOption"+num+"[0].checked") && eval("document.TaskSummary.duedateOption"+num+"[0].value") =="calendar") || (eval("document.TaskSummary.duedateOption"+num+"[2].checked") && eval("document.TaskSummary.duedateOption"+num+"[2].value") =="assignee")) {
           document.TaskSummary.duedateOffset[num].value = "";
         }
         return;
      }
      return;
  }


  function isDeltaRadio(num){
     var count = 0;
     for ( var k = 0; k < document.TaskSummary.length; k++ ) {
       if ((document.TaskSummary.elements[k].name == "routeOrder")){
           count++;
        }
     }
     if (count == 1) {
        if((document.TaskSummary.duedateOption0[0].checked && document.TaskSummary.duedateOption0[0].value =="calendar") || (document.TaskSummary.duedateOption0[2].checked && document.TaskSummary.duedateOption0[2].value =="assignee")) {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.NotDeltaOption</emxUtil:i18nScript>");
          document.TaskSummary.duedateOffset.value = "";
          document.TaskSummary.duedateOption0[2].focus();
          return;
        }
      }else {
        if((eval("document.TaskSummary.duedateOption"+num+"[0].checked") && eval("document.TaskSummary.duedateOption"+num+"[0].value") =="calendar" ) || (eval("document.TaskSummary.duedateOption"+num+"[2].checked") && eval("document.TaskSummary.duedateOption"+num+"[2].value") =="assignee")) {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.NotDeltaOption</emxUtil:i18nScript>");
          document.TaskSummary.duedateOffset[num].value = "";
          eval("document.TaskSummary.duedateOption"+num+"[2].focus();");
          return;
        }
      }
  }




  // function to make all the check box enable
  function doCheck(){
    var objForm   = document.TaskSummary;
    var chkList   = objForm.chkList;

    for (var i=0; i < objForm.elements.length; i++){
    //Check for the disabled check boxes
    if(!objForm.elements[i].disabled){
      if (objForm.elements[i].name.indexOf('chkItem1') > -1){
        objForm.elements[i].checked = chkList.checked;
      }
      }
    }
  }

  // function to make all the check box disable
  function updateCheck() {
    var objForm = document.TaskSummary;
    var chkList = objForm.chkList;
    chkList.checked = false;
  }

  // function to sort tasks.
  function sortTaskList(){
    //added for the bug no  341551 Rev 1
      submitAction = true;
    <%
        if ( boRouteNode == null ) {
    %>
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.TaskMessage</emxUtil:i18nScript>");
          return;
    <%
        } else {
    %>
          document.TaskSummary.sortName.value="true";
          document.TaskSummary.fromPage.value="task";

          document.TaskSummary.action="emxSortTaskList.jsp?sortName=true&newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>";

          document.TaskSummary.submit();
          return;
    <%
        }
    %>
    }








  //-----------------------------------------------------------------------------------
  // Function to trim strings
  //-----------------------------------------------------------------------------------

  function trimtext (str) {
    return str.replace(/\s/gi, "");
  }







  function showDeleteSelected() {
    //added for the bug no  341551 Rev 1
    submitAction = true;

    var checkedFlag = "false";

    for (var i=0; i < document.TaskSummary.elements.length; i++) {
      if (document.TaskSummary.elements[i].type == "checkbox"
         && document.TaskSummary.elements[i].name != "chkList" && document.TaskSummary.elements[i].checked   )  {
         checkedFlag = "true";
      }
    }
    if (checkedFlag == "false") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskSummary.SelectTask</emxUtil:i18nScript>");
      return;
    } else {
      if (confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskSummary.MsgConfirm</emxUtil:i18nScript>") != 0)  {
        document.TaskSummary.action="emxDeleteTask.jsp?objectId=<%=XSSUtil.encodeForURL(context, routeId)%>&srcPg=editAllTasks&newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>";
        document.TaskSummary.submit();
        return;
      }
    }
  }
    //added for the bug no  341551 Rev 1 -Begin
function setUnloadMethod()
{
  var bodyElement = document.getElementById("taskdelete");
    if (isIE && bodyElement)
    {
        bodyElement.onunload = function () { windowClose(); };
    }
    else
    {
        bodyElement.setAttribute("onbeforeunload",  "return windowClose()");
    }
}

function windowClose()
{
    if (submitAction != true )
    {
     emxUICore.getDataPost("emxRouteCancelNewTaskProcess.jsp", "newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>");
    }
}

//function to list Role And Person for Route
function getReviewersList(objThis,count) {
	var assigneeName=objThis.value;
			document.getElementById("recepientList"+count).style.visibility = 'visible';
			document.getElementById("recepientList"+count).style="width:200px";
			var response = emxUICore.getDataPost("../components/emxRouteEditAllTasksDialog.jsp?mode=EnableResponsibleRole&assigneeName="+assigneeName+"&count="+count);
			 document.getElementById("recepientDivList"+count).innerHTML=response;
     }


</script>

 <script language="Javascript">
  addStyleSheet("emxUIRoutes");
 </script>


<body id="taskdelete" name="taskdelete" onload="setUnloadMethod()" class="editable">
<!--    added for the bug no  341551 Rev 1  - Ends-->


<form name = "TaskSummary" method="post" onSubmit="return false" action="emxRouteEditAllTasksProcess.jsp" target="_parent">
<input type="hidden" name="objectId"   value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="sortName"  value=""/>
<input type="hidden" name="fromPage" value="task"/>
<input type="hidden" name="isTemplate" value="<xss:encodeForHTMLAttribute><%=isTemplate%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="slctdd" value="<xss:encodeForHTMLAttribute><%=slctdd%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="slctmm" value="<xss:encodeForHTMLAttribute><%=slctmm%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="slctyy" value="<xss:encodeForHTMLAttribute><%=slctyy%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="newTaskIds"    value="<xss:encodeForHTMLAttribute><%=newTaskIds%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="routeStatus" value="<xss:encodeForHTMLAttribute><%=strRouteStatus%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="currentRouteLevel" value="<xss:encodeForHTMLAttribute><%=strCurrentRouteLevel%></xss:encodeForHTMLAttribute>"/>

 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>
<table class="list" id="taskList">
	<tbody>
	<tr>
			<th width="5%" style="text-align:center">
				<input type="checkbox" name="chkList" id="chkList" onclick="doCheck()"/>
			</th>
		<!-- modified for IR-050410V6R2011x -->
			<th nowrap width="20%" class="required">
				<emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.TitleActionOrder</emxUtil:i18n>
			</th>
			<th nowrap width="35%" class="required">
				<%=strAssigneeLabel%>
			</th>
			<th nowrap width="42%" class="required">
				<emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.DueDateTimeEDT</emxUtil:i18n>
			</th>
	</tr>
<%
	//Added for the Bug No:350789 starts
	java.util.Set setKeys = new HashSet();
	Map mapRouteDets = new HashMap();
	if(routeMapDetails!=null) {
		routeMapDetails.remove("sType");
		setKeys = routeMapDetails.keySet();
		Iterator itrKeys = setKeys.iterator();
		while(itrKeys.hasNext()) {
			Relationship keyName =(Relationship)itrKeys.next();
			AttributeList attrblist = (AttributeList)routeMapDetails.get(keyName);
			String strRelId = keyName.getName();
			mapRouteDets.put(strRelId, attrblist);
		}
	}
	//Added for the Bug No:350789 ends
 for(int i =0 ; i< InboxTaskList.size(); i++) {
      taskCount++;
      Map RouteTask = (Map) InboxTaskList.get(i);
      String tempTask = (String)RouteTask.get("attribute[" + DomainObject.ATTRIBUTE_TEMPLATE_TASK + "]");

	  //Added for Bug-310065
	  String taskState = (String)RouteTask.get(DomainObject.SELECT_CURRENT);
	  String taskID = (String)RouteTask.get(DomainObject.SELECT_ID);
	  String taskOwner = (String)RouteTask.get("from[" + RouteObj.RELATIONSHIP_PROJECT_TASK + "].to.id");

	  if(taskState==null || "null".equals(taskState)){
		  taskState = "";
	  }

      sAsignee = "";
      sDisplayPersonName = "";
      sRouteNodeID = (String)RouteTask.get("attribute[" + RouteObj.ATTRIBUTE_ROUTE_NODE_ID+ "]");
     //Get the correct relId for the RouteNodeRel given the attr routeNodeId from the InboxTask.
      actualRouteNodeId = RouteObj.getRouteNodeRelId(context, sRouteNodeID);
      DomainRelationship rel = new DomainRelationship(actualRouteNodeId);
      Map relMap = rel.getAttributeMap(context);
      String sRouteTaskUser = null;
      if(relMap.get(RouteObj.ATTRIBUTE_ROUTE_TASK_USER) != null && relMap.get(RouteObj.ATTRIBUTE_ROUTE_TASK_USER).toString().length()!= 0){
           sRouteTaskUser = (String)relMap.get(RouteObj.ATTRIBUTE_ROUTE_TASK_USER);
      }
      rel.open(context);
      sAsigneeId                            = rel.getTo().getObjectId();
      String typeName                       = rel.getTo().getTypeName();
      Person busPerson = new Person(sAsigneeId);
      String sPersonName = busPerson.getName();
      sAsignee                              = "";
      rel.close(context);
      if(typeName.equals(DomainObject.TYPE_PERSON)){
        sDisplayPersonName  = (JSPUtil.getAttribute(context, session,busPerson,RouteObj.ATTRIBUTE_LAST_NAME)+", "+JSPUtil.getAttribute(context, session,busPerson,RouteObj.ATTRIBUTE_FIRST_NAME)).toString();
      }else if (groupType.equals(typeName) || proxyGoupType.equals(typeName)){
    	  sDisplayPersonName = sPersonName;
      } else if(sRouteTaskUser!=null && !"".equals(sRouteTaskUser)) {
		  //modified for 311950
		sDisplayPersonName=PropertyUtil.getSchemaProperty( context,sRouteTaskUser);
			sDisplayPersonName = sRouteTaskUser.startsWith("role") ? sDisplayPersonName + roleI18N :
		    													 sDisplayPersonName + groupI18N;
      }
          sReviewTask = (String)relMap.get(DomainObject.ATTRIBUTE_REVIEW_TASK);
          sName = (String)relMap.get(RouteObj.ATTRIBUTE_TITLE);
          sSequence = (String)relMap.get(RouteObj.ATTRIBUTE_ROUTE_SEQUENCE);
          sTaskSequence = Integer.parseInt(sSequence);
          sDueDate=(String)relMap.get(RouteObj.ATTRIBUTE_SCHEDULED_COMPLETION_DATE);
          if(sDueDate == null || "null".equals(sDueDate) || "".equals(sDueDate)){
               sDueDate="";
          } else {
          // Due-Dates can be null when Assignee-Sets due-date or if owner not set date and clears default system date
          //To get maximum date of all the physical tasks
          String tempDate = eMatrixDateFormat.getFormattedDisplayDateTime(context, sDueDate, true, intDateFormat, clientTZOffset,request.getLocale());
          Date dDueDate = formatter.parse(tempDate);


          if(maxDueDate == null){
            maxDueDate = dDueDate;
          }else {
            if((maxDueDate.compareTo(dDueDate)) < 0 ) {
              maxDueDate = dDueDate;
              maxOrder = sSequence;
             }
           }
         }
          sInstruction=(String)relMap.get(RouteObj.ATTRIBUTE_ROUTE_INSTRUCTIONS);
          sAssigneeDueDate =(String) relMap.get(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE);

		  //Added for Bug-310065
		  if("Complete".equals(taskState)){
			  vectTitles.addElement(sRouteNodeID);
		  }else if("Assigned".equals(taskState)){
			  vectAssignedTitles.addElement(sRouteNodeID);
			  continue;
		  }else{
			  continue;
		  }

	  boolean isTemplateTask = tempTask != null && tempTask.equals("Yes");
	  String taskName = isTemplateTask ? sName + " (t)" : sName;
	  boolean allowDelegation = relMap.get(RouteObj.ATTRIBUTE_ALLOW_DELEGATION).equals("TRUE");
	  boolean isReviewTask = sReviewTask.equalsIgnoreCase("Yes");
     %>

 <tr class='<framework:swap id="1"/>'>
 	<td style="text-align: center;vertical-align:top;">
 		&nbsp;
 	</td>
	<td style="vertical-align:top"><!-- Title, Action & Number Column -->
		<table>
			<tr>
				<td>
					<table>
     					<tr>
							<td>
								<%=XSSUtil.encodeForHTMLAttribute(context, taskName)%>&nbsp;							
							</td>
     					</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table>
    					<tr>
							<td style="font-weight: bold;padding-top:10px;padding-bottom: 2px;">
						        <emxUtil:i18n localize = "i18nId">emxComponents.common.Action</emxUtil:i18n>&nbsp;
		  			        </td>
					    </tr>
				        <tr>
							<td>
								<%=XSSUtil.encodeForHTMLAttribute(context, i18nNow.getRangeI18NString(PersonObject.ATTRIBUTE_ROUTE_ACTION, (String)relMap.get(RouteObj.ATTRIBUTE_ROUTE_ACTION), sLanguage))%>&nbsp;
							</td>
				        </tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table>
					      <tr>
								<td style="font-weight: bold;padding-top:10px;padding-bottom: 2px;">
	          						<emxUtil:i18n localize = "i18nId">emxComponents.common.Order</emxUtil:i18n>&nbsp;
						       </td>
					      </tr>
			 			  <tr>
								<td>
									<%=XSSUtil.encodeForJavaScript(context, sSequence)%>&nbsp;
								</td>
	  					 </tr>
     </table>
  </td>
			</tr>
		</table>
	</td>
	<td style="vertical-align:top"> <!-- Assignee & Instructions -->
		<table>
			<tr>
				<td>
					<table>
          				<tr>
							<td style="padding-top:3px;">
								<xss:encodeForHTML><%=sDisplayPersonName%></xss:encodeForHTML>&nbsp;
							</td>
							<framework:ifExpr expr="<%=allowDelegation%>">
								<td>
									<img src="../common/images/iconAssignee.gif" name="imgTask" id="imgTask" 
									alt="<emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.AllowDelegation</emxUtil:i18n>"/>&nbsp;
								</td>				
							</framework:ifExpr>
							<framework:ifExpr expr="<%=isReviewTask%>">
								<td>
									<img src="../common/images/iconSmallOwnerReview.gif" name="ownerReview" id="ownerReview" 
									alt="<emxUtil:i18n localize="i18nId">emxComponents.TaskSummary.ToolTipOwnerReview</emxUtil:i18n>"/>&nbsp;								
								</td>				
							</framework:ifExpr>
						</tr>
					</table>
      </td>
      </tr>
          <tr>
				<td>
					<table>
						<tr>
							<td style="padding-top:3px;">
          					<xss:encodeForHTML><%=(String)relMap.get(RouteObj.ATTRIBUTE_ROUTE_INSTRUCTIONS)%></xss:encodeForHTML>&nbsp;&nbsp;
      						</td>
      					</tr>
         			</table>
     			</td>
			</tr>
		</table>
	</td>
	<td style="vertical-align:top"> <!-- Due Date & Time (EDT)  -->
		<table>
        	<tr>
				<td style="padding-top:3px;">
					<!-- //XSSOK -->
					<emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTML(context, timeZone)%>' format='<%=DateFrm%>'><%=sDueDate%></emxUtil:lzDate>&nbsp;
				</td>
       		</tr>
      </table>
     </td>
  <%
    }
     String maxDueDateForJS = (maxDueDate!=null) ? USformatter.format(maxDueDate) : "";

  %>

  <input type="hidden" name="maxDueDateForJS" value="<xss:encodeForHTMLAttribute><%=maxDueDateForJS%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="maxOrder" value="<xss:encodeForHTMLAttribute><%=maxOrder%></xss:encodeForHTMLAttribute>"/>

<script language="javascript">
    lastSeq = "<%=XSSUtil.encodeForJavaScript(context, sSequence)%>";
</script>
  <%
    if ( !sSequence.equals("") ) {
      intSeq=Integer.parseInt(sSequence);
    }

    Vector vectPersons1 = new Vector();
    Vector vectPersons1Types = new Vector();
    Vector vectPersons1Name = new Vector();
    Vector vectRoles    = new Vector();
    Vector vectPersons = new Vector();


    while(personItr.hasNext()) {

      Map person = (Map) personItr.next();
      String strType = (String)person.get(RouteObj.SELECT_TYPE);
      sAsignee   = (String)person.get("attribute["+RouteObj.ATTRIBUTE_ROUTE_TASK_USER+"]");
      if(strType!=null && RouteObj.TYPE_PERSON.equals(strType)&&(!isResponsibleRoleEnabled||(isResponsibleRoleEnabled&&sAsignee.isEmpty()))){
        sAsigneeId = (String)person.get(RouteObj.SELECT_ID);
        sAsignee   = (String)person.get(RouteObj.SELECT_NAME);
        if (!(vectPersons1.contains(sAsigneeId))){
          vectPersons1.addElement(sAsigneeId);
          vectPersons1Types.addElement((String)person.get(RouteObj.SELECT_TYPE));
          vectPersons1Name.addElement(sAsignee);
        }
      }else if(groupType.equals(strType) || proxyGoupType.equals(strType)){
    	  sAsigneeId = (String)person.get(RouteObj.SELECT_ID);
          sAsignee   = (String)person.get(RouteObj.SELECT_NAME);
          if (!(vectPersons1.contains(sAsigneeId)) && sAsignee!=null && !"".equals(sAsignee)){
        	   vectPersons1.addElement(sAsigneeId);
        	  vectPersons1Types.addElement((String)person.get(RouteObj.SELECT_TYPE));
        	  vectPersons1Name.addElement(sAsignee);
        }
      }else{
        sAsigneeId = "Role";
        sAsignee   = (String)person.get("attribute["+RouteObj.ATTRIBUTE_ROUTE_TASK_USER+"]");
        if (!(vectRoles.contains(sAsignee)) && sAsignee!=null && !"".equals(sAsignee)){
          vectRoles.addElement(sAsignee);
        }
      }
    }


    // variables for date formatting scheduled dates below..
    Date taskDueDate = null;
    //converting the date to Lzdate format in java
    String finalLzDate = null;

    String routeSequence                        = null;

    String routeSequenceValueStr                = null;
    String routeAllowDelegationStr              = null;
    String routeInstructionsValueStr            = null;
    String taskNameValueStr                     = null;
    String personName                           = null;
    String routeScheduledCompletionDateValueStr = null;
    long routeScheduledCompletionDateValueMilli = 0;
    String routeActionValueStr                  = null;
    String routeAssigneeDueDateOptStr           = null;
    String taskReviewTaskStr                    = null;
    String routeDueDateDeltaStr                 = "";
    String routeDueDateOffsetFromStr            = "";

    int listSize   = RouteMapList.size();
    Map taskMap = null;
    DomainRelationship rel =null;
// looping into logical / assigned tasks
  for(int i1=0;i1< listSize ;i1++) {
      taskMap = (Map)RouteMapList.get(i1);
      bAssigneeDueDate = false;
      bOwnerNotSetDate = false;
      bDeltaDueDate    = false;
      taskCount++;
      String sRelId2 = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_NODE_ID+"]");
	  //Added for the Bug No:350789 starts
	  if(mapRouteDets.containsKey(sRelId2)) {
			AttributeList attrList = (AttributeList)mapRouteDets.get(sRelId2);
			AttributeItr attrItr = new AttributeItr(attrList);
			while(attrItr.next()) {
				Attribute attr = (Attribute)attrItr.obj();
				String keyName1 = attr.getName();
				String keyValue1 = attr.getValue();
				if(keyValue1!=null && !keyValue1.equals("")) {
					if(taskMap.containsKey("attribute["+keyName1+"]")) {
						taskMap.put("attribute["+keyName1+"]",keyValue1);
					}
				}
				
			}
		}
	  //Added for the Bug No:350789 ends
      // dont display the physical tasks again.
      if (vectTitles.contains(sRelId2)) {
%>
		<script language="javascript">
			// Just accumulate the route orders of the tasks that are already completed.
			completedTasksRouteOrders[completedTasksRouteOrders.length] = "<%=XSSUtil.encodeForJavaScript(context,(String)taskMap.get("attribute["+RouteObj.ATTRIBUTE_ROUTE_SEQUENCE+"]"))%>";
		</script>
<%
        continue;
      }
      routeSequenceValueStr1                = (String)taskMap.get("attribute["+RouteObj.ATTRIBUTE_ROUTE_SEQUENCE+"]");
      sRelId                                = sRelId2;
      routeActionValueStr                   = (String)taskMap.get("attribute["+RouteObj.ATTRIBUTE_ROUTE_ACTION+"]");
      routeInstructionsValueStr             = (String)taskMap.get("attribute["+RouteObj.ATTRIBUTE_ROUTE_INSTRUCTIONS+"]");
      taskNameValueStr                      = (String)taskMap.get("attribute["+RouteObj.ATTRIBUTE_TITLE+"]");
      routeAllowDelegationStr               = (String)taskMap.get("attribute["+RouteObj.ATTRIBUTE_ALLOW_DELEGATION+"]");
      routeScheduledCompletionDateValueStr  = (String)taskMap.get("attribute["+RouteObj.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]");
      routeAssigneeDueDateOptStr            = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE+"]");
      taskReviewTaskStr                     = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_REVIEW_TASK+"]");
      routeDueDateDeltaStr                  = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_DUEDATE_OFFSET+"]");
      routeDueDateOffsetFromStr             = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_DATE_OFFSET_FROM+"]");
      String sTemplateTask                  = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_TEMPLATE_TASK+"]");
      String routeTaskUser                  = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
      rel = DomainRelationship.newInstance(context, sRelId);
      rel.open(context);
      personName                            = rel.getTo().getName();
      sAsigneeId                            = rel.getTo().getObjectId();
      String typeName                       = rel.getTo().getTypeName();
      sAsignee                              = "";
	  if((DomainObject.TYPE_ROUTE_TASK_USER.equals(typeName)||isResponsibleRoleEnabled) && routeTaskUser!=null && !"".equals(routeTaskUser)){
        sAsignee = routeTaskUser;
      }
      rel.close(context);

      boolean isTaskAssignedToUser = vectAssignedTitles.contains(sRelId2);
  	  String restrictAssignees = (isTaskAssignedToUser||
			((!"Modify/Delete Task List".equals(strTemplateTaskSetting)&&!"Modify Task List".equals(strTemplateTaskSetting))&&"Yes".equals(sTemplateTask))) ? "disabled" : "";
	  boolean restrictAssigneeOptions =  "".equals(restrictAssignees)?true:false;
      
 	  boolean isTemplateTask = sTemplateTask != null && sTemplateTask.equals("Yes");
      boolean canModDelTemplateTask = "Modify/Delete Task List".equals(strTemplateTaskSetting);
      boolean canModTaskList = "Modify Task List".equals(strTemplateTaskSetting);
	  String checkDisabled  = (isTaskAssignedToUser||
					(!"Modify/Delete Task List".equals(strTemplateTaskSetting) && isTemplateTask)) ? "disabled" : "";
	  boolean checkBoxDisabled = "".equals(checkDisabled)?true:false;	  
	  showNoneOption=restrictAssigneeOptions && sRouteState.equals(DomainConstants.STATE_ROUTE_DEFINE);
%>
	<tr class='<framework:swap id="1"/>'>
		  <input type="hidden" name="relIds" value="<xss:encodeForHTMLAttribute><%=sRelId%></xss:encodeForHTMLAttribute>"/>
		<td style="text-align: center;vertical-align:top;">
			<table>
				<tr>
					<td>
						<input type="checkbox" name="chkItem1" id="chkItem1" onClick= updateCheck() value="<xss:encodeForHTMLAttribute><%=sRelId%></xss:encodeForHTMLAttribute>" <%=checkDisabled%>/>					 				 
<%
						String assignedTaskOldIDValue = "";
						String assignedTaskOwnerValue = "";
						if(isTaskAssignedToUser) {
							// If this is assigned task, then find out the Inbox Task object for this Route Node id 
							// and generate the hidden elements value for this assigned task.
			    for (Iterator itrInboxTasks = InboxTaskList.iterator(); itrInboxTasks.hasNext();) {
			        Map mapTaskInfo = (Map)itrInboxTasks.next();
			        String strTaskId = (String)mapTaskInfo.get(DomainObject.SELECT_ID);
			        String strTaskOwner = (String)mapTaskInfo.get("from[" + RouteObj.RELATIONSHIP_PROJECT_TASK + "].to.id");
			        String strTasksRouteNodeId = (String)mapTaskInfo.get("attribute[" + RouteObj.ATTRIBUTE_ROUTE_NODE_ID+ "]");
			        if (strTasksRouteNodeId != null && strTasksRouteNodeId.equals(sRelId)) {
									assignedTaskOldIDValue = strTaskId;
									assignedTaskOwnerValue = strTaskOwner;
			            break;
			        }
			    }//~for
			}else{
				assignedTaskOwnerValue = (String)taskMap.get("id");
				
			}
%>
						<input type="hidden" value="<xss:encodeForHTMLAttribute><%=assignedTaskOldIDValue%></xss:encodeForHTMLAttribute>" name="assignedTaskOldID"/>
						<input type="hidden" name="assignedTaskOwner" value="<xss:encodeForHTMLAttribute><%=assignedTaskOwnerValue%></xss:encodeForHTMLAttribute>"/>
          </td>
				</tr>
		 	</table>
		 </td>

		 <td style="vertical-align:top"> <!-- Title, Action & Number Column -->
		 	<table>
				<tbody>
                	<tr><!-- Title Field -->
                  		<td>
							<table>
       							<tr>
						 			<td>
						 				<!-- //XSSOK -->
		 								<framework:ifExpr expr="<%=(isTemplateTask && canModDelTemplateTask) || (!isTemplateTask && !isTaskAssignedToUser)%>">
		 									<input type="text" name="taskName" id="<%=XSSUtil.encodeForHTML(context, RouteObj.ATTRIBUTE_TITLE)%>" size="12" value="<xss:encodeForHTMLAttribute><%=taskNameValueStr%></xss:encodeForHTMLAttribute>"/>
		 								</framework:ifExpr>
		 								<!-- //XSSOK -->
		 								<framework:ifExpr expr="<%=(isTemplateTask && !canModDelTemplateTask) || (!isTemplateTask && isTaskAssignedToUser)%>"><input type="hidden" name="taskName" value="<xss:encodeForHTMLAttribute><%=taskNameValueStr%></xss:encodeForHTMLAttribute>"/><%=taskNameValueStr%></framework:ifExpr><framework:ifExpr expr="<%=isTemplateTask%>">(t)</framework:ifExpr>
		 							</td>
       							</tr>
		 					</table>
		 				</td>
		 			</tr>		 				
		 			<tr><!-- Action -->
                   		<td>
							<table>
								<tbody>
     								 <tr>
										<td style="font-weight: bold;padding-top:10px;padding-bottom: 2px;">
											<emxUtil:i18n localize = "i18nId">emxComponents.common.Action</emxUtil:i18n>
        								</td>
      								</tr>

        							<tr>
		 								<td>
		 									<framework:ifExpr expr="<%=!isTemplateTask && isTaskAssignedToUser%>">
												<input type="hidden" name="routeAction" value="<xss:encodeForHTMLAttribute><%=routeActionValueStr%></xss:encodeForHTMLAttribute>"/>
												<%= XSSUtil.encodeForHTMLAttribute(context, i18nNow.getRangeI18NString(PersonObject.ATTRIBUTE_ROUTE_ACTION, routeActionValueStr, sLanguage)) %>
					 						</framework:ifExpr>
		 									<framework:ifExpr expr="<%=isTemplateTask || !isTaskAssignedToUser%>">
                								<select name="routeAction">
<%
                 for(int i=0; i< routeActionList.size() ; i++) {
                    String rangeValue = (String)routeActionList.get(i);
                    String i18nRouteAction=i18nNow.getRangeI18NString(PersonObject.ATTRIBUTE_ROUTE_ACTION, rangeValue, sLanguage);
                    								String selected = (routeActionValueStr != null) && routeActionValueStr.equals(rangeValue) ? "selected"  : "";

%>
													<option value="<%=XSSUtil.encodeForHTMLAttribute(context, rangeValue)%>" <%=XSSUtil.encodeForHTMLAttribute(context, selected)%>> <%=XSSUtil.encodeForHTML(context, i18nRouteAction)%> </option>
<%
                      }
%>
                </select>
					 						</framework:ifExpr>
            </td>
         </tr>
		 							<tr> <!-- Order Field -->
										<td>
											<table>
												<tbody>
      <tr>
											 			<td style="font-weight: bold;padding-top:10px;padding-bottom: 2px;">
           <emxUtil:i18n localize = "i18nId">emxComponents.common.Order</emxUtil:i18n>&nbsp;
       </td>
      </tr>
           <tr>
		 												<td><!-- //XSSOK -->
		 													<framework:ifExpr expr="<%=isTemplateTask && (canModDelTemplateTask || canModTaskList)%>">
		 															<select name="routeOrder" onchange = "setValue()">
         <%
																		sTaskSequence = isTaskAssignedToUser ? Integer.parseInt(routeSequenceValueStr1) : sTaskSequence;
            															for (int ctr=1;ctr<=20;ctr++) {
										    								String  selected = String.valueOf(ctr).equals(routeSequenceValueStr1) ? "selected" : "";
        %>
																			<option value="<%= ctr %>" <%=XSSUtil.encodeForHTMLAttribute(context, selected)%>><%= ctr %></option>
        <%

          																}
        %>
              														</select>
          														<input type="hidden" name="isTaskStarted" value="false"/>
		 													</framework:ifExpr>
		 													<!-- //XSSOK -->
		 													<framework:ifExpr expr="<%=isTemplateTask && !(canModDelTemplateTask || canModTaskList)%>">
              													<%=XSSUtil.encodeForJavaScript(context, routeSequenceValueStr1)%>
					          									<input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeSequenceValueStr1%></xss:encodeForHTMLAttribute>"/>
									 				            <input type="hidden" name="isTaskStarted" value="true"/>
		 													</framework:ifExpr>
		 													<framework:ifExpr expr="<%=!isTemplateTask && !isTaskAssignedToUser%>">
		 														<select name="routeOrder" onchange = "setValue()">
     <%
							    	        					String sAttCurrentRouteNode = PropertyUtil.getSchemaProperty(context,"attribute_CurrentRouteNode");
													            String strCurrentRouteNode = RouteObj.getInfo(context, "attribute["+sAttCurrentRouteNode+"]");//getting the current route level
								            					int nCurrentRouteNode = !UIUtil.isNullOrEmpty(strCurrentRouteNode) ?
												                Integer.parseInt(strCurrentRouteNode) : intSeq;
													            for (int ctr = nCurrentRouteNode;ctr <= 20; ctr++) {
									                				String selected = String.valueOf(ctr).equals(routeSequenceValueStr1) ? "selected" : "";
%>
                													<option value="<%= ctr %>" <%= XSSUtil.encodeForHTMLAttribute(context, selected) %>><%= ctr %></option>
<%
            													}
         %>
             													 </select>
																<input type="hidden" name="isTaskStarted" value="false"/>
		 													</framework:ifExpr>
		 													<framework:ifExpr expr="<%=!isTemplateTask && isTaskAssignedToUser%>">
<%
          																sTaskSequence = Integer.parseInt(routeSequenceValueStr1);
%>
		 																<%=XSSUtil.encodeForJavaScript(context, routeSequenceValueStr1)%>
          																<input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeSequenceValueStr1%></xss:encodeForHTMLAttribute>"/>
																         <input type="hidden" name="isTaskStarted" value="true"/>
		 													</framework:ifExpr>
		 												</td>											
													</tr>
												</tbody>
											</table>
										</td>
									</tr>
								</tbody>
							</table>
						</td>
					</tr>						
				</tbody>
			</table>
            <input type="hidden" name="oldAssignee" value="<xss:encodeForHTMLAttribute><%=sAsigneeId%></xss:encodeForHTMLAttribute>"/>
            <input type="hidden" name="routeNode" value="<xss:encodeForHTMLAttribute><%=sRelId%></xss:encodeForHTMLAttribute>"/>
  </td>

		 <td style="vertical-align:top"> <!-- Assignee & Instructions -->
		 	<table>
		 	<tbody>
        		<tr> <!-- Assignee -->
      				<td>
            			<table>
             				<tr>
             					<td>
      <%
								  	String assigneeChangeEvent = isTaskAssignedToUser ? "onChange=\"changeAssignedOwner(this);getReviewersList(this,"+i1+")\"" : "onChange=\"getReviewersList(this,"+i1+")\"";
					              	boolean showDelegationIcon = routeAllowDelegationStr.equals("TRUE");
					              	boolean showReviewIcon = taskReviewTaskStr.equalsIgnoreCase("Yes");
   
					              	 String strRoleName="";
					                 String sPersonTemp = null;
					                 String sRole="";
					                 String strRouteNodeIdForInboxTask=(String)taskMap.get("attribute[Route Node ID]");
					                 boolean isInboxTask=false;
					                 for (Iterator itrInboxTasks = InboxTaskList.iterator(); itrInboxTasks.hasNext();) {
                                                               Map mapInboxTask = (Map)itrInboxTasks.next();
                                                               isInboxTask= mapInboxTask.containsValue(strRouteNodeIdForInboxTask);
        					               if(isInboxTask)    
        					                    	 break;
					                 }
					                 boolean isRoleBasedTask=false;
					                 String strAttrRouteTaskUser=(String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
					                 if(UIUtil.isNotNullAndNotEmpty(strAttrRouteTaskUser)){
					                	 String assigneeType = "";
					                	if(strAttrRouteTaskUser.indexOf("_") > 1){
					                	 assigneeType = strAttrRouteTaskUser.substring(0, strAttrRouteTaskUser.indexOf("_"));
					                	}
			                  		  isRoleBasedTask = "role".equals(assigneeType);
					                 }
					                 boolean restrictAssigneesChange = false;
					           	     if(UIUtil.isNotNullAndNotEmpty(strTemplateTaskSetting) && UIUtil.isNotNullAndNotEmpty(sTemplateTask)){
					           			 restrictAssigneesChange = !"Modify/Delete Task List".equals(strTemplateTaskSetting) && !"Modify Task List".equals(strTemplateTaskSetting) && "Yes".equals(sTemplateTask);
					           	 	 }
					                 String strAssigneeinList="";
					                 boolean isShowDropDown = !isResponsibleRoleEnabled || (isResponsibleRoleEnabled && ((!isRoleBasedTask)||(isRoleBasedTask&&(!isInboxTask&&!isTemplateTask))));
					                
      %>
      <framework:ifExpr expr="<%=isShowDropDown &&  !restrictAssigneesChange%>">
									<select name="personId"  id="personId" <%=assigneeChangeEvent%>>
										<framework:ifExpr expr="<%=showNoneOption%>">
										<%
										strAssigneeinList="none~none";
										%>
                							<option value="none~none"><emxUtil:i18n localize="i18nId">emxComponents.RouteTemplateTaskAssignees.None</emxUtil:i18n></option>
										</framework:ifExpr>
      <%
      String strIsRolePresentInList=DomainObject.EMPTY_STRING;
              for (int ctr=0;ctr<vectPersons1.size();ctr++) {
                String sPersonId = (String) vectPersons1.elementAt(ctr);
                String sPersonType = (String) vectPersons1Types.elementAt(ctr);
											String selected = sPersonId.equals(sAsigneeId) ? "selected" : "";
											if(!(proxyGoupType.equals(sPersonType) || groupType.equals(sPersonType))){
											Person busPerson1 = new Person();
											busPerson1.setId(sPersonId);
											busPerson1.open(context);
											sDisplayPersonName  = com.matrixone.apps.domain.util.PersonUtil.getFullName(context, busPerson1.getName());
											busPerson1.close(context);
                sPersonId = "Person~"+sPersonId;
											}else {
												DomainObject dObject = new DomainObject(sPersonId);
												sPersonId = "UserGroup~"+sPersonId;
												sDisplayPersonName =(String) dObject.getInfo(context,DomainObject.SELECT_ATTRIBUTE_TITLE);
												sDisplayPersonName = sDisplayPersonName + userGroupI18N;
											}
                
      if(UIUtil.isNotNullAndNotEmpty(selected)&&isResponsibleRoleEnabled&&(isRoleBasedTask)){
    	  sPersonId="Role~"+strAttrRouteTaskUser;
    	  sDisplayPersonName=PropertyUtil.getSchemaProperty(context,strAttrRouteTaskUser);
    	  sDisplayPersonName=  i18nNow.getAdminI18NString("Role", sDisplayPersonName, sLanguage) + roleI18N;
    	  strIsRolePresentInList=sDisplayPersonName;
		}
                      if(UIUtil.isNullOrEmpty(strAssigneeinList)){
		               	strAssigneeinList=sPersonId;
		          }
%>
								  			<option value="<%=XSSUtil.encodeForHTMLAttribute(context, sPersonId)%>" <%=XSSUtil.encodeForHTMLAttribute(context, selected)%>><%=XSSUtil.encodeForHTML(context, sDisplayPersonName)%></option>
<%
              }
              for(int ctr=0;ctr<vectRoles.size();ctr++){
              sRole = (String)vectRoles.elementAt(ctr);
              String sType = "";
              if(sRole.indexOf("_") > -1){
            	  sType = sRole.substring(0, sRole.indexOf("_"));
              }
             
				boolean isRole = "role".equals(sType);
				
				                  			String selected = sRole.equals(sAsignee) ? "selected" : "";
								  			// Modified for 311950
			  sDisplayPersonName=PropertyUtil.getSchemaProperty(context,sRole);
			  strRoleName=sDisplayPersonName;
				  sDisplayPersonName = isRole ? i18nNow.getAdminI18NString("Role", sDisplayPersonName, sLanguage) + roleI18N:
  		 				    			               i18nNow.getAdminI18NString("Group", sDisplayPersonName, sLanguage) + groupI18N;  
		    			          			sRole = isRole ? "Role~" + sRole : "Group~" + sRole;         
		    			          			if(!strIsRolePresentInList.equals(sDisplayPersonName)){
				    			  				 if(UIUtil.isNullOrEmpty(strAssigneeinList)){
			    			          			    	strAssigneeinList=(String)vectRoles.elementAt(ctr);
			    			          			    }
%>
				                  			<option value="<%=XSSUtil.encodeForHTMLAttribute(context, sRole)%>" <%=XSSUtil.encodeForHTMLAttribute(context, selected)%>><%=XSSUtil.encodeForHTML(context, sDisplayPersonName)%></option>
<%
             
		    			          			}
              }
%>
            </select>
           </framework:ifExpr>
           <framework:ifExpr expr="<%=isShowDropDown &&  restrictAssigneesChange%>">
									
      <%
			String strIsRolePresentInList = DomainObject.EMPTY_STRING;
			String displayPersonName = DomainObject.EMPTY_STRING;
			String personNameValue = DomainObject.EMPTY_STRING;
			for (int ctr = 0; ctr < vectPersons1.size(); ctr++) {
				String sPersonId = (String) vectPersons1.elementAt(ctr);
				String sPersonType = (String) vectPersons1Types.elementAt(ctr);
				String selected = sPersonId.equals(sAsigneeId) ? "selected" : "";
				if(!(groupType.equals(sPersonType) || proxyGoupType.equals(sPersonType))){
				Person busPerson1 = new Person();
				busPerson1.setId(sPersonId);
				busPerson1.open(context);
				sDisplayPersonName = com.matrixone.apps.domain.util.PersonUtil.getFullName(context,
				busPerson1.getName());
				busPerson1.close(context);
				}else {
					sDisplayPersonName = (String)vectPersons1Name.elementAt(ctr);
				}
				sPersonId = "Person~" + sPersonId;
				if (UIUtil.isNotNullAndNotEmpty(selected) && isResponsibleRoleEnabled&& (isRoleBasedTask)) {
					sPersonId = "Role~" + strAttrRouteTaskUser;
					sDisplayPersonName = PropertyUtil.getSchemaProperty(context, strAttrRouteTaskUser);
					sDisplayPersonName = EnoviaResourceBundle.getAdminI18NString(context,"Role", sDisplayPersonName, sLanguage)+ roleI18N;
					strIsRolePresentInList = sDisplayPersonName;
				}
				if (UIUtil.isNullOrEmpty(strAssigneeinList)) {
					strAssigneeinList = sPersonId;
				}
				if (UIUtil.isNotNullAndNotEmpty(selected)) {
					displayPersonName = sDisplayPersonName;
					personNameValue = sPersonId;
					break;
				}
			}
			for (int ctr = 0; ctr < vectRoles.size(); ctr++) {
				sRole = (String) vectRoles.elementAt(ctr);
				String sType = sRole.substring(0, sRole.indexOf("_"));
				sDisplayPersonName = PropertyUtil.getSchemaProperty(context, sRole);
				boolean isRole = sType.equals("role");
				String selected = sRole.equals(sAsignee) ? "selected" : "";
				strRoleName = sDisplayPersonName;
				sDisplayPersonName = isRole? EnoviaResourceBundle.getAdminI18NString(context,"Role", sDisplayPersonName, sLanguage) + roleI18N : EnoviaResourceBundle.getAdminI18NString(context,"Group", sDisplayPersonName, sLanguage) + groupI18N;
				sRole = isRole ? "Role~" + sRole : "Group~" + sRole;

					
					if (!strIsRolePresentInList.equals(sDisplayPersonName)) {
						if (UIUtil.isNullOrEmpty(strAssigneeinList)) {
							strAssigneeinList = (String) vectRoles.elementAt(ctr);
						}
						if (UIUtil.isNotNullAndNotEmpty(selected)) {
							displayPersonName = sDisplayPersonName;
							personNameValue = sRole;
							break;
						}

					}
				}
%>
				<input type="hidden" name="personId" value="<%=XSSUtil.encodeForHTMLAttribute(context, personNameValue)%>">
				<%=XSSUtil.encodeForHTML(context, displayPersonName)%></input>
           </framework:ifExpr>
            <framework:ifExpr expr="<%=(isResponsibleRoleEnabled &&(isRoleBasedTask&&(isTemplateTask||isInboxTask))) %>">
           <%
           String strRouteTaskUser=(String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
           if(UIUtil.isNotNullAndNotEmpty(strRouteTaskUser)){
        	   String sType = strRouteTaskUser.substring(0, strRouteTaskUser.indexOf("_"));
        		  sDisplayPersonName=PropertyUtil.getSchemaProperty(context,strRouteTaskUser);
        	 
     			boolean isRole = sType.equals("role");
     			strRouteTaskUser = isRole ? "Role~" + strRouteTaskUser : "Group~" + strRouteTaskUser;   
     			    sDisplayPersonName = isRole ?
  			           i18nNow.getAdminI18NString("Role", sDisplayPersonName, sLanguage) + roleI18N:
			               i18nNow.getAdminI18NString("Group", sDisplayPersonName, sLanguage) + groupI18N;  
           }else{
        	   strRouteTaskUser=(String)taskMap.get("name");
        	   sDisplayPersonName= PersonUtil.getFullName(context, strRouteTaskUser);
        	   strRouteTaskUser="Person~"+PersonUtil.getPersonObjectID(context, strRouteTaskUser);
        	         	   
           }
          %>
		<input type="hidden" name="personId" value="<%=XSSUtil.encodeForHTMLAttribute(context, strRouteTaskUser)%>">
	     	<%=XSSUtil.encodeForHTML(context, sDisplayPersonName)%> </input>
	</framework:ifExpr>
			<framework:ifExpr expr="<%=showDelegationIcon%>">
					&nbsp;
						<img src="../common/images/iconAssignee.gif" name="imgTask" id="imgTask" 	
							alt="<emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.AllowDelegation</emxUtil:i18n>"/>						
			</framework:ifExpr>
			<framework:ifExpr expr="<%=showReviewIcon%>">
		 			&nbsp;
	       				 <img src="../common/images/iconSmallOwnerReview.gif" name="ownerReview" id="ownerReview" 		
		             		alt="<emxUtil:i18n localize="i18nId">emxComponents.TaskSummary.ToolTipOwnerReview</emxUtil:i18n>" />
			</framework:ifExpr>
            <input type="hidden" name="NeedsReview" value="<xss:encodeForHTMLAttribute><%=taskReviewTaskStr%></xss:encodeForHTMLAttribute>"/>
           </tr>
          </table>
		</td>
       </tr>
       <%
         	if(isResponsibleRoleEnabled){
         	String strUserOrg = PersonUtil.getActiveOrganization(context);
         	String strType=	(String)taskMap.get("type");
         	 String strRouteTaskUser=(String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
                 String strName=	(String)taskMap.get("name");
         	 boolean showRecepient=UIUtil.isNotNullAndNotEmpty(strRouteTaskUser);
         	 boolean isTypeRTU=strType.equals(Route.TYPE_ROUTE_TASK_USER);
         	 if(isTypeRTU&&!showRecepient){
         		strRouteTaskUser=strAssigneeinList;
         		showRecepient=UIUtil.isNotNullAndNotEmpty(strRouteTaskUser);
         	 }
         		if(showRecepient){
         		  strRoleName=PropertyUtil.getSchemaProperty(context,strRouteTaskUser);
         		}else{
         			strRoleName="";
         		}
         		 matrix.util.StringList slSelect=new StringList();
                        try{                        	 
            	              slSelect=PersonUtil.getPersonFromRole(context, strRoleName);
            	              isRoleBasedTask=true;
			}catch(Exception e){
				slSelect.removeAllElements();
			}
            			                 				%>
            					 <td width="2%" style="text-align: left;" >
                 <div id="recepientDivList<%=i1%>" style="text-align: left;">
                 <framework:ifExpr expr="<%=(isRoleBasedTask&&!isInboxTask)%>">
        <select id = "recepientList<%=i1 %>" name = "recepientList"  style="width:200px">
    
        <%
        if(showRecepient){
        	%>
        	  <option value="Any"><%=strAny %></option>
        	  
        	  <% 
        }
        for(Object strAssign:slSelect){
        	String strAssigneeName=(String)strAssign;
        			String strOrg=PersonUtil.getDefaultOrganization(context, strAssigneeName);
        			if(strUserOrg.equals(strOrg)){
        	String  strAssingeeDisplay=PersonUtil.getFullName(context, strAssigneeName);
        	String selected = "";
				 if(UIUtil.isNotNullAndNotEmpty(strName)&&strName.equals(strAssigneeName))
				selected="selected";
      %>
		  <option value="<%=strAssign %>" <%=selected %>><%=strAssingeeDisplay %></option>
              <%
        }
        		}
          %>
          </select>
          	</framework:ifExpr>
          	<framework:ifExpr expr="<%=!isRoleBasedTask||(isRoleBasedTask&&isInboxTask)%>">
          	<%
          	String strValue=strRouteTaskUser;
          	String strDisaplayName=DomainObject.EMPTY_STRING;
          	if(UIUtil.isNotNullAndNotEmpty(strValue)){
          	if(!isTypeRTU){
          		strValue=strName;
          		strDisaplayName=PersonUtil.getFullName(context, strValue);
          	}else{
          		strValue="Any";
              		strDisaplayName=strAny;
          	}
          	}
           	if(isRoleBasedTask){
          	%>
               	<input type="hidden"  id = "recepientList<%=i1 %>" name = "recepientList" style="width:200px" value="<%=XSSUtil.encodeForHTMLAttribute(context, strValue)%>"> <%=XSSUtil.encodeForHTMLAttribute(context, strDisaplayName)%> </input>
               	<%
           	}
               	else{
               		%>
                		<input type="text"  id="recepientList<%=i1 %>" name = "recepientList" readonly=true disabled style="width:200px"></input><input type="hidden"  id = "recepientList<%=i1 %>" name = "recepientList"  value="">  </input>
               		<%
               	}
               	%>
          	  	</framework:ifExpr>
          	
        </div>
       
       </td>
        </tr>
            				<%
            
  				}
            				%>
							
            				
		<tr> <!-- Instructions -->
    		<td style="padding-top:3px;">
				<table>
		           <tr>
			           <td>
							<textarea style="min-height:50px;width:250px;" rows="6" name="routeInstructions"><xss:encodeForHTML><%=routeInstructionsValueStr%></xss:encodeForHTML></textarea>
				       </td>
			        </tr>
		          </table>
		       </td>
		</tr>
		</tbody>
      </table>            
	</td>
  <%
            taskDueDate = null;
            int taskHour      = 17;
            int taskMinitue   = 0;

            //converting the date to Lzdate format in java
            finalLzDate = "";

            if(! "".equals(routeScheduledCompletionDateValueStr) && routeScheduledCompletionDateValueStr != null   && !"null".equals(routeScheduledCompletionDateValueStr)) {

              finalLzDate             = eMatrixDateFormat.getFormattedDisplayDateTime(context, routeScheduledCompletionDateValueStr, true, intDateFormat, clientTZOffset,request.getLocale());

              taskDueDate             = formatter.parse(finalLzDate);
              routeScheduledCompletionDateValueMilli = taskDueDate.getTime();
              finalLzDate             = eMatrixDateFormat.getFormattedDisplayDateTime(context, routeScheduledCompletionDateValueStr, false, intDateFormat, clientTZOffset,request.getLocale());
              Hashtable hashDateTime = eMatrixDateFormat.getFormattedDisplayInputDateTime(routeScheduledCompletionDateValueStr,clientTZOffset);
              taskHour = (new Integer((String)hashDateTime.get("hours"))).intValue();
              taskMinitue = (new Integer((String)hashDateTime.get("minutes"))).intValue();
            }else{
               bDueDateEmpty = true;
            }

            // check if due-date can be set by assignee
            if (("".equals(routeScheduledCompletionDateValueStr) || routeScheduledCompletionDateValueStr == null) && "Yes".equalsIgnoreCase(routeAssigneeDueDateOptStr)){
                bAssigneeDueDate = true;
            }

            if (routeDueDateDeltaStr != null && !"null".equals(routeDueDateDeltaStr) && !"".equals(routeDueDateDeltaStr) && bDueDateEmpty){
            bDeltaDueDate = true;
            }
            if(!bAssigneeDueDate && taskDueDate != null) {
              calendar.setTime(taskDueDate);
            }else if(! bAssigneeDueDate && !bDeltaDueDate && (finalLzDate == null || "".equals(finalLzDate) || "null".equals(finalLzDate))) {
              bOwnerNotSetDate = true;
            }
          String taskDate   = "";
          if(bOwnerNotSetDate && showDefaultDate){
            calendar = getTimeNow(temp_hhrs_mmin);
          }
          if(bOwnerNotSetDate && !showDefaultDate){
            // reset this as it carries Current System time; System time should apply only when from RouteTasksummary page
            taskDate = "";
            calendar = getTimeNow(temp_hhrs_mmin);
            taskHour      = calendar.get(Calendar.HOUR_OF_DAY);
            taskMinitue   = calendar.get(Calendar.MINUTE);
          }

          taskDate      = finalLzDate;
  %>
        <td style="vertical-align:top"> <!-- Due Date & Time (EDT)  -->
			<table>
				<tr> <!-- Date and Time selection -->
					<td>
						<table>
				            <tr>
					             <td style="padding-top:5px;">
                 <input type="hidden" name="routeScheduledCompletionDate<%=xx%>_msvalue" value="<xss:encodeForHTMLAttribute><%=(!bAssigneeDueDate && !bDeltaDueDate)?routeScheduledCompletionDateValueMilli:(long)0%></xss:encodeForHTMLAttribute>"/>
                 <input type = "radio" onclick="javascript:toggleDefaultDate('<%=xx%>')" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx%>" value = "calendar" <%= (!bAssigneeDueDate && !bDeltaDueDate)?"checked":""%> />
                 					<input onfocus="redirectFocus('<%=xx%>')" type="text" size="12" name="routeScheduledCompletionDate<%=xx%>" value="<xss:encodeForHTMLAttribute><%=(!bAssigneeDueDate && !bDeltaDueDate)?taskDate:""%></xss:encodeForHTMLAttribute>"/>&nbsp;
                 <a href="javascript:showCal('TaskSummary','routeScheduledCompletionDate<%=xx%>','Task','<%=xx%>')" ><img src="../common/images/iconSmallCalendar.gif" border=0 width="16" height="16"/></a>&nbsp;
                  <select name="routeTime" style="font-size: 8pt">
 <%
			int hour = 5;
			boolean is24= false;
			String amPm = "AM";
			// 24 Hours format for _de and _ja more can be added
			if(sLanguage.startsWith("de") || sLanguage.startsWith("ja") || sLanguage.startsWith("fr"))
			{
				is24 = true;
				//amPm="";
			}
			boolean minFlag = true;
			boolean amFlag = true;
			// 48 loops one for 00 mins and one for 30 mins. 24 hours * 2  times
			
                    for (int i=0;i<48;i++) {
                       String ttime     = "";
													String timeValue = "";
                       String Slct      ="";

													// After 12 PM , clock turns to 1 , for 24Hour format it becomes 13, below.													
													if(hour>12 && !is24)
													{
														hour =1 ;
                      }
													if(minFlag) // Alternating between 00 min and 30 min. Initially flag=true once we display 00 then flag=false, display 30 mins , alternate
													{
														if(is24){
															ttime = hour + ":00 ";
                      } else {
																ttime = hour + ":00 " + amPm;
                      }
														timeValue = hour  + ":00" + ":00 " + amPm;
														minFlag = false;
													}else
													{
														if(is24){
															ttime = hour + ":30 "; 
                      } else {
																ttime = hour + ":30 " + amPm; 
															}	
														timeValue = hour  + ":30" + ":00 " + amPm;
														hour++;
														minFlag = true;
														if(hour==12)// Once we reach 12, change amPm from AM to PM
										            	{
										            		amPm = "PM";
										            	}
                      }
							                    
												String toSelect = "";
													if(taskDueDate!=null){
													if(is24){	
														toSelect = taskDueDate.getHours()+":"+taskDueDate.getMinutes();
														if(!minFlag){
															toSelect += "0";
														}
														if(ttime.trim().equals(toSelect))
																Slct = "selected";
                      } else {
														toSelect = routeScheduledCompletionDateValueStr.substring(9);
														if(toSelect.trim().equals(timeValue) || toSelect.trim().equals("0"+timeValue))  
															Slct = "selected";
														if((hour ==12 || hour == 13) && amPm.equals("AM")){
															String timeValue1 = timeValue.replace("12:","00:") ;
															if(toSelect.trim().equals(timeValue) || toSelect.trim().equals(timeValue1))
															Slct = "selected";
														}
														
													}
                      }
  %>
                      <Option value="<%=timeValue%>" <%=Slct%>> <%=ttime%> </Option>
  <%
												if(hour>12 && is24 && amFlag){//If 24 hour format, change to 13 after 12PM not to 1PM 
													hour=13;
													amFlag = false;
												}
								            	if(hour>23 && is24){ //If 24 hour , after 23:30 change to 00 hours (12AM)
													hour=00;
													amPm = "AM";
                         }
								            	
								            	if(ttime.equalsIgnoreCase("11:30 PM"))
								            	{
								            		amPm = "AM";
                     }

											}
  %>
               </select>
               						&nbsp;
               <a href="javascript:cleardate('<%=xx%>')"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>

             </td>
            </tr>
						</table>
					</td>
      </tr>
        <tr>
					<td>
						<table>
							<tr>
								<td style="font-weight: bold;padding-top:10px;padding-bottom: 2px;">
           <emxUtil:i18n localize = "i18nId">emxComponents.common.Advanced</emxUtil:i18n>&nbsp;
         </td>
      </tr>
				<tr>
								<td style="padding-top:3px;">
            <input type = "radio" onclick="javascript:toggleDefaultDate('<%=xx%>')" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx%>" value ="delta" <%=bDeltaDueDate?"checked":""%>/>
            						&nbsp;
            <input type="text" onfocus="isDeltaRadio('<%=xx%>')" style="font-size:8pt; font-face=verdana, arial" name="duedateOffset" size="2" value="<xss:encodeForHTMLAttribute><%=bDeltaDueDate?routeDueDateDeltaStr:""%></xss:encodeForHTMLAttribute>" />
            						&nbsp;<emxUtil:i18n localize = "i18nId">emxComponents.common.DaysFrom</emxUtil:i18n>&nbsp;
              <select name="duedateOffsetFrom" style="font-size:8pt; font-face=verdana, arial" onFocus="isDeltaRadio('<%=xx%>')">
             <%
             String rangeValue       = "";
             String i18nRouteAction  = "";
             String i18nOffsetFrom   = "";
             StringItr  offsetItr    = new StringItr (FrameworkUtil.getRanges(context, DomainObject.ATTRIBUTE_DATE_OFFSET_FROM));
             while(offsetItr.next()) {
                rangeValue        = offsetItr.obj();
                // if Route not in define (Not started) state, skip choice for offset from Route Start
                if(!isTemplateEdit && !"Define".equals(sRouteState) && OFFSET_FROM_ROUTE_START_DATE.equals(rangeValue)){
                   continue;
                }
                i18nOffsetFrom    = i18nNow.getRangeI18NString(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM, rangeValue, sLanguage);
                sSelected         = (routeDueDateOffsetFromStr != null && routeDueDateOffsetFromStr.equals(rangeValue) )?"selected":"";
          %>
                <option value="<%=XSSUtil.encodeForHTMLAttribute(context, rangeValue)%>" <%=XSSUtil.encodeForHTMLAttribute(context, sSelected)%>> <%=XSSUtil.encodeForHTML(context, i18nOffsetFrom)%> </option>
          <%
                     }
                  %>
            </select>
           </td>
           </tr>
						</table>
					</td>
				</tr>				
				<tr>
    				<td>
    					&nbsp;
    				</td>
    			</tr>
            <tr>
             <td>
               <input type = "radio" onclick="javascript:toggleDefaultDate('<%=xx%>')" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx++%>" value ="assignee" <%=bAssigneeDueDate?"checked":""%>/>
               <emxUtil:i18n localize = "i18nId">emxComponents.AssignTasksDialog.AssigneeDueDate</emxUtil:i18n>
             </td>
            </tr>

       <tr>
    				<td>
    					&nbsp;
    				</td>
    			</tr>
         <tr>
          <td>
        <%

               if (routeAllowDelegationStr.equals("TRUE")) {
        %>
           <input type="checkbox" name="allowDelegation<%=XSSUtil.encodeForHTML(context, sRelId2)%>" id="AllowDelegationchkItem" value="<%=AllowDelegationCount++%>" checked />
        <% } else {
                %>
                   <input type="checkbox" name="allowDelegation<%=XSSUtil.encodeForHTML(context, sRelId2)%>" id="AllowDelegationchkItem" value="<%=AllowDelegationCount++%>" />
                <%
             }
                %>
           <emxUtil:i18n localize = "i18nId">emxComponents.AssignTasksDialog.AllowDelegation</emxUtil:i18n>
           			
        <%
                if (taskReviewTaskStr.equalsIgnoreCase("Yes")) {
          %>
           <input type="checkbox" name="reviewTask<%=XSSUtil.encodeForHTML(context, sRelId2)%>" id="NeedsReviewchkItem" value="<%=NeedsReviewCount++%>" checked />
          <%
          } else {
          %>
              <input type="checkbox" name="reviewTask<%=XSSUtil.encodeForHTML(context, sRelId2)%>" id="NeedsReviewchkItem" value="<%=NeedsReviewCount++%>" />
          <%
         }
          %>
           <emxUtil:i18n localize = "i18nId">emxComponents.AssignTasksDialog.RequiresOwnerReview</emxUtil:i18n>
          </td>
          </tr>
        </table>
          </td>
        </tr>
  <%
      }
    if ((taskCount == 0)) {
  %>

   <table border="0" cellpadding="3" cellspacing="2" width="100%">

      <tr class="odd">
        <td class="noresult" colspan="9" height="50">
          <emxUtil:i18n localize="i18nId">emxComponents.TeamSummary.NoTasksFound</emxUtil:i18n>
        </td>
      </tr>
	</table>
  <%
    }
%>
</tbody>
  </table>

<script language="javascript">
   function submitForm() {
	var pastDate = "false";
    //added for the bug no  341551 Rev 1
     submitAction = true;
<%
    if ( boRouteNode == null ) {
%>
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.TaskMessage</emxUtil:i18nScript>");
      return;
<%
    }
%>
    var count = 0;
    for (var k=0; k < document.TaskSummary.length; k++ ){
      if ((document.TaskSummary.elements[k].name == "routeOrder")) {
        count++;
      }
    }
	var toDayDate = new Date();
    toDayDate.setDate(toDayDate.getDate());
    var position = 0;
    var parentTaskDate = "false";
    // checking whether the date selected is earlier than current date.
    // also added check to prevent Route Owner asking self-review
    var taskCount=-1 ;
    for (var i=0; i<document.TaskSummary.length;i++) {

      if(document.TaskSummary.elements[i].type=="select-one" && document.TaskSummary.elements[i].name == "personId"){
        var rtOwnerStr    = '<%=XSSUtil.encodeForJavaScript(context, routeOwnerName)%>';
        var assigneeStr   = document.TaskSummary.elements[i].options[document.TaskSummary.elements[i].selectedIndex].value;
        var needReviewStr = document.TaskSummary.elements[i+2].value;
        if(rtOwnerStr == assigneeStr && needReviewStr=="Yes"){
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskEdit.CanNotHaveTaskReview</emxUtil:i18nScript>");
          document.TaskSummary.elements[i].focus();
          return;
        }
      }

      if ( (document.TaskSummary.elements[i].type == "text") && document.TaskSummary.elements[i].name == "taskName") {
        if(document.TaskSummary.elements[i].value.length > 0) {
            var namebadCharName       = checkForUnifiedNameBadChars(document.TaskSummary.elements[i], true);
            var nameAllBadCharName = getAllNameBadChars(document.TaskSummary.elements[i]);
            var name = document.TaskSummary.elements[i].name;
          if (namebadCharName.length != 0)  {
              alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInvalidInput</emxUtil:i18nScript>"+nameAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript> "+name+" <emxUtil:i18nScript localize="i18nId">emxComponents.Alert.Field</emxUtil:i18nScript>");
            document.TaskSummary.elements[i].focus();
            return;
          }
        }
        //Added for the Task Title Feature on 20th june 2007
        else {
            	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.EnterTitleField</emxUtil:i18nScript>");
            document.TaskSummary.elements[i].focus();
            return;
        }//End for the Task Title Feature on 20th june 2007

        document.TaskSummary.elements[i].value = trimStr(document.TaskSummary.elements[i].value);

        if (!(isAlphanumeric(trimtext(document.TaskSummary.elements[i].value), true))){
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidName</emxUtil:i18nScript>");
          document.TaskSummary.elements[i].focus();
          return;
        }
      }

      if (document.TaskSummary.elements[i].name == "routeInstructions") {
        var namebadCharDescrption = checkForBadChars(document.TaskSummary.elements[i]);
        if(document.TaskSummary.elements[i].value == "" ) {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTask.AlertInstruction</emxUtil:i18nScript>");
          document.TaskSummary.elements[i].focus();
          return;
        	} else if(namebadCharDescrption.length != 0) {
              alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
              document.TaskSummary.elements[i].focus();
              return;
        }
      }

//Added for bug 348298

if ((document.TaskSummary.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate") && (document.TaskSummary.elements[i].name.indexOf("_msvalue") > 0)){
			var rouSchComDate = document.TaskSummary.elements[i].value;
      taskCount++ ;
		 }

if ((document.TaskSummary.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate") && (document.TaskSummary.elements[i].name.indexOf("_msvalue") < 0)){

        var check= document.TaskSummary.elements[i].name.substring(28,29);
        	if(eval("document.TaskSummary.duedateOption"+check+"[0].checked")) {
          var dateStr = document.TaskSummary.elements[i].value;
          var time    = document.TaskSummary.elements[i+1].options[document.TaskSummary.elements[i+1].selectedIndex].value;
          var hour=time.substring(0,time.indexOf(":"));
          var minute=time.substring((time.lastIndexOf(":"))-2,time.lastIndexOf(":"));
          var ampm=trim(time.substring(time.indexOf(" ")),time.indexOf(" ")+2);
          dateStr=new Date(dateStr);
          if(ampm=="AM"){
          dateStr.setHours(parseInt(hour));
          }else if(ampm=="PM"){
            if(parseInt(hour) == 12){
              hour="0";
            }
          dateStr.setHours(parseInt(hour)+12);
          }
          dateStr.setMinutes(parseInt(minute));

      if (dateStr != "" && dateStr != null) {
<%
      if(parentTaskDueDate !=null && !("".equals(parentTaskDueDate))){
%>
        var parentTaskDuedate =new Date('<%=XSSUtil.encodeForJavaScript(context, parentTaskDueDate)%>');

/// bug No : 295599
        //var schDate = new Date(dateStr);
        var schDate = new Date();
	      schDate.setTime(rouSchComDate);
//till here

        if (schDate.getFullYear()< 1950) {
           // add 100 years.
           schDate.setFullYear(schDate.getFullYear() + 100);
        }
        if ( (Date.parse(schDate.toGMTString()) >= Date.parse(parentTaskDuedate.toGMTString())) ){
           parentTaskDate = "true";
           position =i;
           break;
        }
<%
      }
%>
/// bug No : 295599
        // var date1 = new Date(dateStr);
        var date1 = new Date();
	      date1.setTime(rouSchComDate);
//till here

          //  addressing  Y2K.
          if (date1.getFullYear()< 1950) {
            // add 100 years.
            date1.setFullYear(date1.getFullYear() + 100);
          }

//# bug No : 295599
    var hrs,mns,str1 ;

if ( count==1 ) {
    str1=document.TaskSummary.routeTime.value;
} else {
    str1=document.TaskSummary.routeTime[taskCount].value;
}
    hrs=parseInt(str1.substring(0,str1.indexOf(':')));
    mns=parseInt(str1.substring(str1.indexOf(':')+1,str1.indexOf(' ')));
	if (str1.substring(str1.indexOf(' ')+1) == 'PM') {
						if(hrs == 12) {
			hrs = 0;
		}
     		hrs=hrs+12 ;
   	}
    date1.setHours(hrs);
    date1.setMinutes(mns);
//# bug No : 295599 end
		if ( (Date.parse(date1.toGMTString()) <= Date.parse(toDayDate.toGMTString())) ){
            pastDate = "true";
            position = i;
            break;
          }
        }
       }
      }	 

 }



if ( pastDate == "true" ) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterdPastDate</emxUtil:i18nScript>");
      document.TaskSummary.elements[position].value = "";
      document.TaskSummary.elements[position].focus();
      return;
    }

 // End for bug 348298 

//Solved for Bug id 303944
	
//Check if tasks in order
//Start
    if (count == 1 && completedTasksRouteOrders.length == 0) {     //only one order field
      if (document.TaskSummary.routeOrder.options !=null && document.TaskSummary.routeOrder.options[document.TaskSummary.routeOrder.selectedIndex].value != 1 ) {
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderBig</emxUtil:i18nScript>" +" "+ document.TaskSummary.routeOrder.options[document.TaskSummary.routeOrder.selectedIndex].value + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderCont</emxUtil:i18nScript>");
         return;
      }
    } else {
      selArray = document.TaskSummary.elements["routeOrder"];
      storeArray = new Array(count);
      var missingValue;
      for (ct = 0; ct < count; ct++){
          //Modify:07-Aug-09:nr2:R208:COM:Bug:375526
    	  //Condition instanceof check added as for the case when only one task is coming
          if(selArray[ct] != undefined){
		   		if (selArray[ct].type == "select-one") {
		          // get array of values
		          storeArray[ct] = parseInt(selArray[ct].options[selArray[ct].selectedIndex].value);
		        } else {
		          storeArray[ct] = parseInt(selArray[ct].value);
		        }
	       	} else { 
	            storeArray[ct] = selArray.value;
      }
      	}
      
      // Add the completed Tasks' routeOrder to the list, so that we will check the orders of all of the tasks
      for (sorted = 0; sorted < completedTasksRouteOrders.length; sorted++) {
      	storeArray[storeArray.length] = parseInt(completedTasksRouteOrders[sorted]);
      	}      
      sortNum(storeArray,storeArray.length); // Sort in ascending order

      for (sorted = 0; sorted < (storeArray.length - 1) ; sorted++){
        // Make sure the first number in the sorted array is the last active sequence
        if (sorted == 0) {
            if (storeArray[sorted] != 1) {
                missingValue = 1;
                errorValue = storeArray[sorted];
                break;
            }
        }
        if ((storeArray[sorted] != storeArray[sorted + 1]) && ((storeArray[sorted] + 1) != storeArray[sorted + 1])){
          missingValue = (storeArray[sorted] + 1);
          errorValue = storeArray[sorted + 1];
          break;
        }
      }

      // check if a value is missing
      if (missingValue > -1) {
        tempValue ="<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Enterorder</emxUtil:i18nScript>";
        tempValue += missingValue + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderSmall</emxUtil:i18nScript> ";
        tempValue += errorValue + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Encounter</emxUtil:i18nScript> ";
        tempValue += missingValue + "  <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Missing</emxUtil:i18nScript>";
		
		//Solved for the issue id 303944
		//start
		alert(tempValue);
		//end 
		
        // set focus to errorValue
        for (ct = 0; ct < count; ct++){
        // compare to last value before above loop broke
        		if(selArray[ct].type == "select-one") {
          if ( parseInt(selArray[ct].options[selArray[ct].selectedIndex].value) == errorValue){
            selArray[ct].focus();
            break;
           }
         }
        }
        return;
      }
    }
    //END of 303944
    
    // step 2 :  Checking for Empty Dates - Bypassed for(Assignee-set duedate feature)
    //           Check for valid delta offset range, if option selected.

    if (count == 1) {
    	// Bug: 344305
    	// Check if the due date given is later parent task due date
    	if (dtParentTaskDueDate != null) {
    		if (document.TaskSummary.duedateOption0[0].checked && 
    			document.TaskSummary.duedateOption0[0].value == "calendar") {
    			if (document.TaskSummary.routeScheduledCompletionDate0.value == "") {
    				alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterdPastDate</emxUtil:i18nScript>");
    				document.TaskSummary.routeScheduledCompletionDate0.focus();
    				return;
    			}
    			if (!validateTaskDueDate(dtParentTaskDueDate, 
    												document.TaskSummary.routeScheduledCompletionDate0_msvalue.value, 
    												document.TaskSummary.routeTime.value)) {
    				document.TaskSummary.routeScheduledCompletionDate0_msvalue.value = "";
    				document.TaskSummary.routeScheduledCompletionDate0.value = "";
    				document.TaskSummary.routeScheduledCompletionDate0.focus();
    				return;
    			}
    		}
    	}
      if(document.TaskSummary.duedateOption0[1].checked && document.TaskSummary.duedateOption0[1].value =="delta"){
         var duedateOffsetJS = trimtext(document.TaskSummary.duedateOffset.value);
         var isInvalidRange = CheckValidity(duedateOffsetJS);

         if( duedateOffsetJS.length == 0 || duedateOffsetJS <1 || duedateOffsetJS > 365 || isInvalidRange){
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.EnterOffset </emxUtil:i18nScript>");
         document.TaskSummary.duedateOffset.value = "";
         document.TaskSummary.duedateOffset.focus();
         return;
         }

      }
    } else {

      for (var k=0; k < count; k++){
      	// Bug: 344305
    	// Check if the due date given is later parent task due date
    	if (dtParentTaskDueDate != null) {
    		var objDueDateOption = eval("document.TaskSummary.duedateOption"+k+"[0]");
    		var objRouteScheduledCompletionDate = eval("document.TaskSummary.routeScheduledCompletionDate"+k);
    		var objRouteScheduledCompletionDate_msvalue = eval("document.TaskSummary.routeScheduledCompletionDate"+k+"_msvalue");
    		var objRouteTime = eval("document.TaskSummary.routeTime["+k+"]");
    			if (objDueDateOption.checked && objDueDateOption.value == "calendar") {
    			if (objRouteScheduledCompletionDate.value == "") {
    				alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterdPastDate</emxUtil:i18nScript>");
    				objRouteScheduledCompletionDate.focus();
    				return;
    			}
    			if (!validateTaskDueDate(dtParentTaskDueDate, 
    												objRouteScheduledCompletionDate_msvalue.value, 
    												objRouteTime.value)) {
   				objRouteScheduledCompletionDate_msvalue.value = "";
    				objRouteScheduledCompletionDate.value = "";
    				objRouteScheduledCompletionDate.focus();
    				return;
    			}
    		}
    	}
        if((eval("document.TaskSummary.duedateOption"+k+"[1].checked") && eval("document.TaskSummary.duedateOption"+k+"[1].value") =="delta")){
          var duedateOffsetJS = trimtext(document.TaskSummary.duedateOffset[k].value);
          var isInvalidRange = CheckValidity(duedateOffsetJS);
          if( duedateOffsetJS.length == 0 || duedateOffsetJS <1 || duedateOffsetJS > 365 || isInvalidRange){
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.EnterOffset</emxUtil:i18nScript>");
          document.TaskSummary.duedateOffset[k].value="";
          document.TaskSummary.duedateOffset[k].focus();
          return;
          }
        }
      }
    }



    // step 4 : Check Instructions.
    if (count == 1) {
	  if (trimtext(document.TaskSummary.routeInstructions.value).length == 0){
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
        document.TaskSummary.routeInstructions.value="";
        document.TaskSummary.routeInstructions.focus();
        return;
      }
    } else {
      for (var k=0; k < count; k++){
        if(trimtext(document.TaskSummary.routeInstructions[k].value).length == 0){
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
          document.TaskSummary.routeInstructions[k].value="";
          document.TaskSummary.routeInstructions[k].focus();
          return;
        }
      }
    // Added for bug 348298 
   	  if (count > 1){
      var orderdate = dateOrderCompare();
      if (!orderdate){
           return;
      }
    }
  // End for bug 348298  


    }

      // Make sure user doesnt double clicks on create route
    if (jsDblClick()) {
              startProgressBar(true);
                document.TaskSummary.submit();
                return;
	} else {
                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
                return;
       }
  }
</script>
</form>
</body>

<%!
// method to return system date calendar; time will be from property
public GregorianCalendar getTimeNow(String temp_hhrs_mmin){


    GregorianCalendar cal = new GregorianCalendar();

    int hhrs              = Integer.parseInt(temp_hhrs_mmin.substring(0, temp_hhrs_mmin.indexOf(':')).trim());
    int index             = temp_hhrs_mmin.indexOf("AM");

    if(index < 0) {
         index            = temp_hhrs_mmin.indexOf("PM");
         if(hhrs < 12){
           hhrs += 12;
         }
    } else {
          if(hhrs == 12){
            hhrs = 0;
          }
    }

    int mmin              = Integer.parseInt(temp_hhrs_mmin.substring(temp_hhrs_mmin.indexOf(':')+1, index).trim());
    cal.set(Calendar.HOUR_OF_DAY, hhrs);
    cal.set(Calendar.MINUTE, mmin);

    return cal;
}
%>

<%/* Added for bug 348298  */ %>

<script language="javascript">


// function to populate array with date and order values.
    function dateOrderCompare() {

     // step  1 : Moving dates in the order to array, declaring an array to store the order number and date
      var arrcol    = 0;
      var goodDtCnt = 0; // to hold count of non-empty and valid dates
      var slctArray = document.TaskSummary.elements["routeOrder"];
      
      // loop to find out valid date elements
      for (ct = 0; ct < slctArray.length; ct++) {
        //if(trimStr(eval("document.TaskSummary.routeScheduledCompletionDate"+ct+".value")) != ""){
        if(eval("document.TaskSummary.routeScheduledCompletionDate"+ct+".value") != ""){
           goodDtCnt++;
        }
      }
      var dateOrder = new Array(goodDtCnt);

      arrcol        = 0;
      for (ct = 0; ct < slctArray.length; ct++){
	  	  // storing the order value
       //if(trimStr(eval("document.TaskSummary.routeScheduledCompletionDate"+ct+".value")) != ""){
       if(eval("document.TaskSummary.routeScheduledCompletionDate"+ct+".value") != ""){
        	if(slctArray[ct].type == "select-one") {
			  dateOrder[arrcol] = parseInt(slctArray[ct].options[slctArray[ct].selectedIndex].value);
              arrcol+=2;
			} else {           
            dateOrder[arrcol] = parseInt(slctArray[ct].value);
            arrcol+=2;
          }

       }
      }

      arrcol       = 1;
      DtArray      = document.TaskSummary.elements["routeTime"];
      var arrcount = 0;
    for (var i=0; i<document.TaskSummary.elements.length;i++) {
		if ((document.TaskSummary.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate") &&
            (document.TaskSummary.elements[i].value != "") &&
            (document.TaskSummary.elements[i].name.indexOf("_msvalue") > 0))
        {
	     var check= document.TaskSummary.elements[i].name.substring(28,29);
          arrcount++;
        	if(eval("document.TaskSummary.duedateOption"+check+"[0].checked")) {
          var milli = Number(document.TaskSummary.elements[i].value);
          var DtTm =  new Date(milli);
          var k = arrcount - 1;
          if (DtTm.getFullYear()< 1950){
            // add 100 years.
            DtTm.setFullYear(DtTm.getFullYear() + 100);
          }
          var AmPmVar = new String(DtArray[k].options[DtArray[k].selectedIndex].value.substring(DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(" ") +1 ,DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(" ") + 3));
          if (AmPmVar == "PM"){
            	   DtTm.setHours(parseInt(DtArray[k].options[DtArray[k].selectedIndex].value.substring(0,DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(":")))+12);
          } else if (AmPmVar == "AM"){
            var check = parseInt(DtArray[k].options[DtArray[k].selectedIndex].value.substring(0,DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(":")));
            if(check == 12){
                           DtTm.setHours("00");
            		} else {
                DtTm.setHours(check);
            } 
			//DtTm.setHours(parseInt(DtArray[k].options[DtArray[k].selectedIndex].value.substring(0,DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(":"))));
          }
          DtTm.setMinutes(parseInt(DtArray[k].options[DtArray[k].selectedIndex].value.substring(DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(":")+1,DtArray[k].options[DtArray[k].selectedIndex].value.length)));
          dateOrder[arrcol]=DtTm;
          arrcol+=2;
	 }
        }
      }


      // step 2 :Passing it thru function largestdate to check validity
      if (document.TaskSummary.routeOrder.length < 2){
		  //only a single date field
        return true;
      } else {
        for (var k =0 ; k < dateOrder.length; k+=2){
          for (var q = k + 2; q < dateOrder.length; q+=2){
            var rslt = largestdate(dateOrder[k],dateOrder[k+1],dateOrder[q],dateOrder[q+1]);
            if (!rslt){

              alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.DateOrder</emxUtil:i18nScript>");
              eval("document.TaskSummary.routeTime[1].focus();");
              k = arrcol;
              q = arrcol;
              return false;
            }
          }
        }
      }
     return true;
  }





// checks whether the dates are later than today. Also checks the ordering of the dates.
  function largestdate(order1,dt1,order2,dt2) {

      // if date variables below have empty or undefined values,they are assignee due-dates and ignored..
    if(dt1 == "undefined" || dt1== "" || dt1 == null || dt2 == "undefined" || dt2== "" || dt2== null ){
      return true;
    }
    var date1 = new Date(dt1);
    var date2 = new Date(dt2);

    //  addressing  Y2K.
    if (date1.getFullYear()< 1950) {
      // add 100 years.
      date1.setFullYear(date1.getFullYear() + 100);
    }
    if (date2.getFullYear()< 1950) {
      // add 100 years.
      date2.setFullYear(date2.getFullYear() + 100);
    }

   // comparing the order and the dates
    if (((((order1 >  order2) && (Date.parse(date1.toGMTString()) >= Date.parse(date2.toGMTString())))) || (((order1 <  order2) && (Date.parse(date1.toGMTString()) <= Date.parse(date2.toGMTString())))) || (order1 ==  order2))){
      return true;
    } else {
      return false;
    }
  }


</script>


<%!
// Method to return Parent Task Due Date will return null if no parent task
public static String getParentTaskDueDate(Context context,String objectId){
  String parentTaskDueDate=null;
  try{
    if(objectId!=null){
      DomainObject doObject=DomainObject.newInstance(context,objectId);
      if(DomainObject.TYPE_INBOX_TASK.equals(doObject.getType(context))){
        parentTaskDueDate=doObject.getInfo(context,"attribute["+DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]");
      }
    }
  }catch(Exception ex){
  }
  return parentTaskDueDate;
}

%>

<% 

      }
/* End for bug 348298 */%>







<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
