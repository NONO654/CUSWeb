<%--  emxEditRouteTaskDetailsDialog.jsp   -   Edit Details of Tasks

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxEditRouteTaskDetailsDialog.jsp.rca 1.33 Wed Oct 22 16:18:28 2008 przemek Experimental przemek $"
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
</head>
<%
  DomainObject domainObject = DomainObject.newInstance(context);
  String languageStr  = request.getHeader("Accept-Language");
  String routeId      = emxGetParameter(request,"routeId");
  String taskId       = emxGetParameter(request,"taskId");
  String routeNodeId  = emxGetParameter(request,"routeNodeId");
  String taskCreated  = emxGetParameter(request,"taskCreated");

  String sTypeRouteTaskUser = PropertyUtil.getSchemaProperty(context, "type_RouteTaskUser");
  String sAttrRouteAction   = PropertyUtil.getSchemaProperty(context, "attribute_RouteAction");
  String sPolicy            = "";
  String sAttrRouteBasePurpose = PropertyUtil.getSchemaProperty(context, "attribute_RouteBasePurpose" );
  String SELECT_ROUTE_BASE_PURPOSE = DomainObject.getAttributeSelect(sAttrRouteBasePurpose);
  String routeBasePurpose = "";
  String objType = "";

  final String STRING_NONE = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.None");  

  long prevObjectDate = 0;
  long nextObjectDate = 0;
  MapList RouteMapList = null;

  if(routeId != null && !routeId.equals("") && !routeId.equals("null"))
  {
      Pattern typePattern1                         = null;

      domainObject.setId(routeId);
      routeBasePurpose = domainObject.getInfo(context,SELECT_ROUTE_BASE_PURPOSE);
      objType = domainObject.getInfo(context,DomainObject.SELECT_TYPE);

      typePattern1 = new Pattern(domainObject.TYPE_PERSON);
      typePattern1.addPattern(domainObject.TYPE_ROUTE_TASK_USER);
      SelectList selectStmts = new SelectList();
      selectStmts.addName();
      selectStmts.addId();
      selectStmts.addType();
      selectStmts.addAttribute(DomainObject.ATTRIBUTE_TEMPLATE_TASK);

      StringList relSelStmts = new StringList();
      relSelStmts.addElement("attribute["+domainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
      relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_SEQUENCE+"]");
      relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE+"]");
      relSelStmts.addElement("attribute["+DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]");

      RouteMapList = domainObject.getRelatedObjects(context,
                                                    domainObject.RELATIONSHIP_ROUTE_NODE,            //String relPattern
                                                    typePattern1.getPattern(),     //String typePattern
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

  }
%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<script language = javascript>
  function submitForm() {
  var instructions = document.frmTaskDetails.instructions.value;
  instructions = trim(instructions);
   if ( instructions == "" ) {
     alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
     document.frmTaskDetails.instructions.focus();
     return;
   }
   if(document.frmTaskDetails.oldDueDate && document.frmTaskDetails.scheduledDate)
   {
    var scheduledDate = document.frmTaskDetails.scheduledDate.value;
   //Script modified for Bug Id : Mx358173V6R2011 : IXI
    if ( scheduledDate == "" ) {
	   //Do Nothing 
       // alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterDate</emxUtil:i18nScript>");
       // document.frmTaskDetails.scheduledDate.focus();
       //  return true;
    }
   else
   {
    var pastDate = "false";
    var oldDateMilli = Number(document.frmTaskDetails.oldDueDate.value); 
    var oldDate = new Date(oldDateMilli);
    var newDateMilli = Number(document.frmTaskDetails.scheduledDate_msvalue.value);
    var newDateVal = new Date(newDateMilli);

    if(oldDateMilli != newDateMilli) {
      // Date Validation for giving message to user if any selected date is 
      // past date
      // Taking current date into a variable
      var toDayDate = new Date();

      // Decrimentng the current date by one day
      // This is required since we are taking month/date/year only and 
      // putting time as 00.00.00
      //  so this function will give alert if user picks up even todays date.
      toDayDate.setDate(toDayDate.getDate() - 1);
      var date1 = new Date(newDateMilli);
      //  Addressing  Y2K.
      if (date1.getFullYear()< 1950) {
        // add 100 years.
        date1.setFullYear(date1.getFullYear() + 100);
      }

      if ( (Date.parse(date1.toGMTString()) <= Date.parse(toDayDate.toGMTString())) ){
        pastDate = "true";
      }
      if ( pastDate == "true" ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.EditTaskDetails.DateMessage</emxUtil:i18nScript>");
        return;
      }
    }
  }
  }
    var apostrophePosition   = instructions.indexOf("'");
    var hashPosition         = instructions.indexOf("#");
    var doublequotesPosition = instructions.indexOf("\"");
    if (apostrophePosition != -1 || hashPosition != -1 || doublequotesPosition != -1){
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.InstructionSpecialCharacters</emxUtil:i18nScript>");
        document.frmTaskDetails.instructions.focus();
        return;
    }
    document.frmTaskDetails.action = "emxEditRouteTaskProcess.jsp";
<%
if(objType.equals(DomainObject.TYPE_ROUTE_TEMPLATE))
{	
%>
    document.frmTaskDetails.action = "emxEditRouteTemplateTaskProcess.jsp";
<%
}
%>
    document.frmTaskDetails.submit();
  }

  function closeWindow() {
    window.closeWindow();
    return;
  }

  function redirectFocus(str) {
      document.frmTaskDetails.routeTime.focus();
      getDate('frmTaskDetails',str);
      return;
  }

</script>
<body  onLoad="loaddates()" >

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String attrRouteAction         = PropertyUtil.getSchemaProperty(context, "attribute_RouteAction");
  String attrRouteInstruction    = PropertyUtil.getSchemaProperty(context, "attribute_RouteInstructions");
  String attrApprovalStatus      = PropertyUtil.getSchemaProperty(context, "attribute_ApprovalStatus");
  String relRouteNode            = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode");
  String attrRouteTaskUser       = PropertyUtil.getSchemaProperty(context, "attribute_RouteTaskUser");

  String taskName            = "";
  String taskOwner           = "";
  String taskCreateDate      = "";
  String taskDueDate         = "";
  String taskAllowDelegation = "";
  String taskAssignee        = "";
  String taskAssigneeId      = "";
  String taskRouteName       = "";
  String taskAction          = "";
  String taskState           = "";
  String taskInstructions    = "";
  String taskApprovalStatus  = "";
  String timeZone            = (String)session.getValue("timeZone");
  String taskRouteTaskUser   = "";

  String taskSequence        = "";

  int mmonth                 = 0;
  int yyear                  = 0;
  int dday                   = 0;
  int hhrs                   = 10;
  int mmin                   = 0;
  int iChange                = 0;
  String selectdate          = "";
  long selectdateMilli       = 0;
  Date tempdate              = new Date();

  if(taskId != null && !taskId.equals(""))
  {
    domainObject.setId(taskId);

    String selTaskName = "attribute["+domainObject.ATTRIBUTE_TITLE+"]";
    String selTaskDueDate = "attribute["+domainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]";
    String selTaskAllowDelegation = "attribute["+domainObject.ATTRIBUTE_ALLOW_DELEGATION+"]";
    String selRouteName = "from["+domainObject.RELATIONSHIP_ROUTE_TASK+"].to.name";
    String selTaskAction = "attribute["+attrRouteAction+"]";
    String selTaskInstructions = "attribute["+attrRouteInstruction+"]";
    String selTaskApprovalStatus = "attribute["+attrApprovalStatus+"]";
    String selTaskAssigneeId = "from["+domainObject.RELATIONSHIP_PROJECT_TASK+"].to.id";
    String selRouteTaskUser = "attribute[Route Task User]";

    StringList busSelects = new StringList();
    busSelects.addElement(selTaskName);
    busSelects.addElement(domainObject.SELECT_OWNER);
    busSelects.addElement(domainObject.SELECT_ORIGINATED);
    busSelects.addElement(selTaskDueDate);
    busSelects.addElement(selTaskAllowDelegation);
    busSelects.addElement(selRouteName);
    busSelects.addElement(selTaskAction);
    busSelects.addElement(domainObject.SELECT_POLICY);
    busSelects.addElement(domainObject.SELECT_CURRENT);
    busSelects.addElement(selTaskInstructions);
    busSelects.addElement(selTaskApprovalStatus);
    busSelects.addElement(selTaskAssigneeId);
    busSelects.addElement(selRouteTaskUser);

    Map taskMap = domainObject.getInfo(context, busSelects);

    taskName              = (String)taskMap.get(selTaskName);
    taskOwner             = (String)taskMap.get(domainObject.SELECT_OWNER);
    taskCreateDate        = (String)taskMap.get(domainObject.SELECT_ORIGINATED);
    taskDueDate           = (String)taskMap.get(selTaskDueDate);
    taskAllowDelegation   = (String)taskMap.get(selTaskAllowDelegation);
    taskAssignee          = (String)taskMap.get(domainObject.SELECT_OWNER);
    taskAssigneeId        = (String)taskMap.get(selTaskAssigneeId);
    taskRouteName         = (String)taskMap.get(selRouteName);
    taskAction            = (String)taskMap.get(selTaskAction);
    sPolicy               = (String)taskMap.get(domainObject.SELECT_POLICY);
    taskState             = (String)taskMap.get(domainObject.SELECT_CURRENT);
    taskInstructions      = (String)taskMap.get(selTaskInstructions);
    taskApprovalStatus    = (String)taskMap.get(selTaskApprovalStatus);
    taskRouteTaskUser     = (String)taskMap.get(selRouteTaskUser);

  }
  else if(routeNodeId != null && !routeNodeId.equals(""))
  {
    domainObject.setId(routeId);

    StringList busSelects = new StringList();
    busSelects.addElement(domainObject.SELECT_NAME);
    busSelects.addElement(domainObject.SELECT_ORIGINATED);
    busSelects.addElement(domainObject.SELECT_TYPE);
    Map routeMap = domainObject.getInfo(context, busSelects);

    DomainRelationship domainRel = DomainRelationship.newInstance(context,routeNodeId);
    domainRel.open(context);
    Map taskMap    = domainRel.getAttributeMap(context);
    taskAssignee   = domainRel.getTo().getName();
    taskAssigneeId = domainRel.getTo().getObjectId();
    domainRel.close(context);

    taskName            = (String)taskMap.get(domainObject.ATTRIBUTE_TITLE);
    taskCreateDate      = (String)routeMap.get(domainObject.SELECT_ORIGINATED);
    taskDueDate         = (String)taskMap.get(domainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE);
    taskAllowDelegation = (String)taskMap.get(domainObject.ATTRIBUTE_ALLOW_DELEGATION);
    taskRouteName       = (String)routeMap.get(domainObject.SELECT_NAME);
    taskAction          = (String)taskMap.get(attrRouteAction);
    taskInstructions    = (String)taskMap.get(attrRouteInstruction);
    taskApprovalStatus  = (String)taskMap.get(attrApprovalStatus);
    taskRouteTaskUser   = (String)taskMap.get(attrRouteTaskUser);

    taskSequence        = (String) taskMap.get(domainObject.ATTRIBUTE_ROUTE_SEQUENCE);
    
    if(taskSequence.equals("")) {
    	taskSequence = "0";
    }

    objType = (String)routeMap.get(domainObject.SELECT_TYPE);

//Bug  299237 - Added the code
	RouteMapList.addSortKey("attribute["+DomainObject.ATTRIBUTE_ROUTE_SEQUENCE+"]", "ascending", "String");
	RouteMapList.sort();
//till here
    for(int i=0; i < RouteMapList.size() ; i++){
      Map taskMap2 = (Map) RouteMapList.get(i);
      String compDate = (String)taskMap2.get("attribute["+DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]");
      String sequence = (String)taskMap2.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_SEQUENCE+"]");
      if(sequence.equals("")) {
    	  sequence = "0";
      }
      if(((Integer.parseInt(taskSequence)-1) == Integer.parseInt(sequence)) && (compDate != null && !compDate.equals("")) )
      {
        prevObjectDate = eMatrixDateFormat.getJavaDate(compDate).getTime();
      }
      else if (((Integer.parseInt(taskSequence)+1) == Integer.parseInt(sequence)) && (compDate != null && !compDate.equals(""))){
        nextObjectDate = eMatrixDateFormat.getJavaDate(compDate).getTime();
        break;
      }
    }
  }
                Long time;
  //Modified by Infosys on 14 Jun 2005 for date display format bug
  //Moved this code out of the if loop
  int iTimeZone         = (new Double((new Double((String)session.getValue("timeZone"))).doubleValue() * -3600000)).intValue();
  double iTimeZoneDbl= (new Double((String)session.getValue("timeZone"))).doubleValue();
  //End modification

  if ((taskDueDate.equals(null))||(taskDueDate.equals(""))) {
    selectdate            = "";
        time = new Long(0);
  } else {
                Date dtObj = new Date(taskDueDate);
                time = new Long(dtObj.getTime());
     selectdate = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedDisplayDate(taskDueDate,iTimeZoneDbl,request.getLocale());
    tempdate              = com.matrixone.apps.domain.util.eMatrixDateFormat.getJavaDate(taskDueDate);
    selectdateMilli = tempdate.getTime();
    GregorianCalendar cal = new GregorianCalendar();
    int totaloffset       = cal.get(Calendar.ZONE_OFFSET);
    tempdate.setTime(tempdate.getTime()-totaloffset+iTimeZone);
    mmonth                = tempdate.getMonth() + 1;
    yyear                 = tempdate.getYear();
    dday                  = tempdate.getDate();
    if ( yyear >= 100 ) {
      yyear               = yyear - 100;
    }

    hhrs                  = tempdate.getHours();
    mmin                  = tempdate.getMinutes();
  }
                String timeStr = time.toString();

    //Added by Infosys on 14 Jun 2005 for date display format bug
    String originatedDate = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedDisplayDate(taskCreateDate,
                                                                                                            iTimeZoneDbl,
                                                                                                            request.getLocale());
%>

<%
if(objType.equals(DomainObject.TYPE_ROUTE_TEMPLATE))
{
%>
	<form name = "frmTaskDetails" onSubmit="javascript:submitForm(); return false" method = "post" action="">
<%
}
%>

<%
if(objType.equals(DomainObject.TYPE_ROUTE))
{
%>
	<form name = "frmTaskDetails" onSubmit="javascript:submitFormRoute(); return false" method = "post" action="">
<%
}
%>
 
<input type="hidden" name=routeId value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name=taskId value="<xss:encodeForHTMLAttribute><%=taskId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name=routeNodeId value="<xss:encodeForHTMLAttribute><%=routeNodeId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name=taskCreated value="<xss:encodeForHTMLAttribute><%=taskCreated%></xss:encodeForHTMLAttribute>" />

<table>
  <tr>
    	<td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></td>
    	<td class="inputField"><xss:encodeForHTML><%= taskName %></xss:encodeForHTML>&nbsp;</td>
  </tr>
<%
  	if(taskCreated.equals("yes")) {
%>
    <tr>
		<td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Owner</emxUtil:i18n></td>
      	<td class="inputField"><xss:encodeForHTML><%= taskOwner %></xss:encodeForHTML></td>
    </tr>
<%
  }
%>
    <!--Modified by Infosys on 14 Jun 2005 for date display format bug-->
    <tr>
		<td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.Originated</emxUtil:i18n></td>
      	<!-- //XSSOK -->
      	<td class="inputField"><%= originatedDate %></td>
    </tr>
<%
if(objType.equals(DomainObject.TYPE_ROUTE)) {
%>
    <tr>
    <!--  Removed class = labelRequired :IXI For IR : Mx358173V6R2011 -->
      	<td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.DueDate</emxUtil:i18n></td>
      	<td class="inputField">
      <table border="0">
        <tr>
          <td><!-- //XSSOK -->
            <!-- //XSSOK -->
            <input readonly type="text" name="scheduledDate" value="<%=selectdate%>" dateValue="<%=timeStr%>" />&nbsp;
            <!-- //XSSOK -->
            <a href="javascript:showCalendar('frmTaskDetails','scheduledDate','<%=taskDueDate%>')"><img src="../common/images/iconSmallCalendar.gif" border="0" valign="absmiddle" name="img5" /></a>&nbsp;
          </td>
        </tr>
        <tr>
          <td>
            <select name="routeTime">
<%
            for (int i=0;i<48;i++) {
              String ttime = "";
              String Slct ="";
              String timeValue = "";
              if (hhrs==24){
                hhrs =0;
              }

              if (hhrs>12) {
                ttime = (hhrs-12)+":";
              } else if (hhrs ==0) {
                ttime = "12:";
              } else {
                ttime = hhrs+":";
              }

              if (mmin<10) {
                ttime= ttime + "0" + mmin;
              } else {
                ttime= ttime + mmin;
              }
              timeValue  = ttime + ":00";
              if (hhrs>=12) {
                ttime= ttime + " PM";
                timeValue = timeValue + " PM";
              } else {
                ttime= ttime + " AM";
                timeValue = timeValue + " AM";
              }
              if (i==0) {
                Slct = "Selected";
              } else {
                Slct ="";
              }
%><!-- //XSSOK -->
           <Option value="<%=timeValue%>" <%=Slct%>> <%=ttime%> </Option>
<%
            mmin += 30;
            if (mmin == 60) {
               mmin = 0;
               hhrs ++;
            }
            }
%>
            </select>
          </td>
        </tr>
      </table>
      </td>
    </tr>
<%
}
%><!-- //XSSOK -->
	<input type="hidden" name="scheduledDate_msvalue" value="<%=timeStr%>" />
	<!-- //XSSOK -->
    <input type="hidden" name=oldDueDate value="<%=selectdateMilli%>" />

    <tr>
		<td class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.AllowDelegation</emxUtil:i18n></td>
      	<td class="inputField">
<%
    String yesChecked = "";
    String noChecked  = "checked";
    boolean allowDelegation = false;
		    if (taskAllowDelegation.equals("True") || taskAllowDelegation.equals("TRUE")) {
      yesChecked = "checked";
      noChecked  = "";
      allowDelegation = true;
    }
%>
        <table border="0">
          <tr>
            <td><!-- //XSSOK -->
              <input type="radio" <%=yesChecked%> value="True" name="allowDelegation" />
              			<%=i18nNow.getI18nString("emxComponents.Common.Yes", "emxComponentsStringResource", languageStr)%>
            </td>
          </tr>
          <tr>
            <td><!-- //XSSOK -->
              <input type="radio" <%=noChecked%> value="False" name="allowDelegation" />
              			<%=i18nNow.getI18nString("emxComponents.Common.No", "emxComponentsStringResource", languageStr)%>
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.Assignee</emxUtil:i18n></td>
      <td class="inputField">
        <select name="comboAssignee" size="1">
<%
          domainObject.setId(routeId);
          Pattern typePattern = new Pattern(domainObject.TYPE_PERSON);
          typePattern.addPattern(sTypeRouteTaskUser);
          Pattern relPattern  = new Pattern(domainObject.RELATIONSHIP_ROUTE_NODE);
          StringList objectSelect = new StringList();
          objectSelect.add(domainObject.SELECT_NAME);
          objectSelect.add(domainObject.SELECT_ID);
          objectSelect.add(domainObject.SELECT_TYPE);

          StringList relationshipSelects = new StringList();
          relationshipSelects.add(domainObject.SELECT_RELATIONSHIP_ID);
          relationshipSelects.add(Route.SELECT_ROUTE_TASK_USER);


          MapList resultList = domainObject.getRelatedObjects(context, relPattern.getPattern(), typePattern.getPattern(),objectSelect, relationshipSelects, false, true, (short)1, null, null);

          StringList memberList = new StringList();
          java.util.List<Hashtable> resMemberList = new java.util.ArrayList<Hashtable>();
          Hashtable tempTable = null;

          //HashMap tempMap = new HashMap();
          Hashtable tempMap = new Hashtable();

          String personId = "";
          String personName = "";
          String assigneeType = "";
          boolean isRouteTaskUserObject = false;

          for(int i =0; i < resultList.size(); i++)
          {
            tempMap = (Hashtable) resultList.get(i);
            personName = (String) tempMap.get(Route.SELECT_ROUTE_TASK_USER);
            personId = (String) tempMap.get(Route.SELECT_ID);
            isRouteTaskUserObject = DomainObject.TYPE_ROUTE_TASK_USER.equals ((String) tempMap.get(DomainObject.SELECT_TYPE));

            if(personName == null || "".equals(personName)){
              personName =  (String) tempMap.get(Route.SELECT_NAME);
                if (isRouteTaskUserObject) {
                    assigneeType = "None";
                }
                else {
              assigneeType = "Person";
                }
            }
            else {
              assigneeType = personName.substring(0,personName.indexOf("_"));
              personName = PropertyUtil.getSchemaProperty(context, personName);
              if(assigneeType.equalsIgnoreCase("role")) {
                assigneeType = "Role";
              }
              else {
                assigneeType = "Group";
              }
            }

            if(!memberList.contains(personName))
            {
              memberList.addElement(personName);
              tempTable = new Hashtable();
              tempTable.put("id", personId);
              tempTable.put("name", personName);
              tempTable.put("assigneeType", assigneeType);
              resMemberList.add(tempTable);
            }
          }

          String id = "";
          String name = "";
          String memberName = "";
          String memberNameIntl = "";
          String assigType = "";

          Hashtable ht = new Hashtable();
          String routeTaskUser = taskRouteTaskUser;
          if(routeTaskUser == null || "".equals(routeTaskUser)){
            memberName =  taskAssignee;
          } else{
            memberName = PropertyUtil.getSchemaProperty(context, routeTaskUser);
          }
          for(int j = 0; j < resMemberList.size(); j++)
          {
            ht = (Hashtable) resMemberList.get(j);
            id = (String) ht.get("id");
            name = (String) ht.get("name");
            assigType =(String) ht.get("assigneeType");

            if (assigType.equals("person")) {
              memberNameIntl =  name;
            }
            else  if ("None".equals(assigType)) {
                memberNameIntl = STRING_NONE;
            }
            else {
              memberNameIntl = i18nNow.getAdminI18NString(assigType,name,languageStr);
            }

            if(memberName.equals(ht.get("name"))) {
%>
                      <option value="<%=id + "#" + name   %>" Selected > <xss:encodeForHTML><%=PersonUtil.getFullName(context, memberNameIntl)%></xss:encodeForHTML> </option>

<%
            } else {
%>
                      <option value="<%=id + "#" + name %>"> <xss:encodeForHTML><%=PersonUtil.getFullName(context, memberNameIntl)%></xss:encodeForHTML> </option>
<%
            }
          }
%>
                </select>


        <input type="hidden" name="txtOldAssigneeId" value="<xss:encodeForHTMLAttribute><%= taskAssigneeId %></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

<%
String parentType = "emxComponents.Common.Route";
String parentIcon = "../common/images/iconSmallRoute.png";
if(objType.equals(DomainObject.TYPE_ROUTE_TEMPLATE))
{
  parentType = "emxComponents.Common.RouteTemplate";
  parentIcon= "../common/images/iconSmallRouteTemplate.gif";
}

%>

    <tr>
      <!-- //XSSOK -->
	  <td class="label"><emxUtil:i18n localize="i18nId"><%=parentType%></emxUtil:i18n></td>
      <!-- //XSSOK -->
      <td class="inputField" class="object"><img src="<%=parentIcon%>" name="imgRoute" id="imgRoute" alt="*" /> <xss:encodeForHTML><%=taskRouteName%></xss:encodeForHTML>&nbsp;</td>
    </tr>

    <tr>
<%
      Map paramMap        = new HashMap();
	  Map programMap      = new HashMap();
	  
      paramMap.put("objectId", routeId);
	  paramMap.put("languageStr", languageStr);
	  programMap.put("paramMap", paramMap);
	  String[] methodargs = JPO.packArgs(programMap);

	  Map resultMap= (Map)JPO.invoke(context, "emxRoute", null, "getRouteNodeTaskRouteActionValues",methodargs, Map.class);
%>
      <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.Action</emxUtil:i18n></td>
      <td class="inputField">
        <select name="routeAction">
<%
if("Approval".equals(routeBasePurpose))
{
%>
          <option value="<xss:encodeForHTMLAttribute><%=taskAction%></xss:encodeForHTMLAttribute>"><%=i18nNow.getRangeI18NString(sAttrRouteAction,"Approve",languageStr)%></option>
<%
} else if("Review".equals(routeBasePurpose))
{
%>
          <option value="<xss:encodeForHTMLAttribute><%=taskAction%></xss:encodeForHTMLAttribute>"><%=i18nNow.getRangeI18NString(sAttrRouteAction,"Comment",languageStr)%></option>
<%
} else
{
%>
          <option value="<xss:encodeForHTMLAttribute><%=taskAction%></xss:encodeForHTMLAttribute>"><%=i18nNow.getRangeI18NString(sAttrRouteAction,taskAction,languageStr)%></option>
<%
      if(resultMap != null && resultMap.size()>0)
      {
          StringList sResultList = (StringList)resultMap.get("field_display_choices");
		  StringItr  actionItr  = new StringItr(sResultList);
		  while(actionItr.next())
          {
			String actionRangeValue = actionItr.obj();
			if(!actionRangeValue.equals(taskAction))
			{
%>
            <option value="<xss:encodeForHTMLAttribute><%=actionRangeValue%></xss:encodeForHTMLAttribute>"><%=i18nNow.getRangeI18NString(sAttrRouteAction,actionRangeValue,languageStr)%></option>
<%
			}
        }
	  }
}
%>
        </select>
      </td>
    </tr>
<%
  if(taskCreated.equals("yes"))
  {
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.State</emxUtil:i18n></td>
      <td class="field"><%=i18nNow.getStateI18NString(sPolicy,taskState, languageStr)%></td>
    </tr>
<%
  }
%>
    <tr>
      <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.Instructions</emxUtil:i18n></td>
      <td class="inputField">
        <textarea name="instructions" cols="40" rows="5" wrap><xss:encodeForHTML><%=taskInstructions%></xss:encodeForHTML></textarea>
      </td>
    </tr>
  </table>
<script language="Javascript">
        function loaddates() {
          if(document.frmTaskDetails.scheduledDate != null) {
        	  //XSSOK
             document.frmTaskDetails.scheduledDate.dateValue ='<%=timeStr%>';
          }
       }

       function checkDates()
       {   
		 var taskAssignedDate  =  document.frmTaskDetails.scheduledDate_msvalue.value;
		 var time  =   document.frmTaskDetails.routeTime.value;
         var hour=time.substring(0,time.indexOf(":"));
         var minute=time.substring((time.lastIndexOf(":"))-2,time.lastIndexOf(":"));
         var ampm=trim(time.substring(time.indexOf(" ")),time.indexOf(" ")+2);		 
         var dateStr=new Date();
         dateStr.setTime(taskAssignedDate);
		
         if(ampm=="AM"){
            dateStr.setHours(parseInt(hour));
         }else if(ampm=="PM"){
            if(parseInt(hour) == 12){
              hour="0";
             }
            dateStr.setHours(parseInt(hour)+12);
         }
         dateStr.setMinutes(parseInt(minute));
         taskAssignedDate=dateStr.getTime();
         //XSSOK
         var previousDate  = <%=prevObjectDate%>
         //XSSOK
         var nextDate  = <%=nextObjectDate%>
         if( previousDate != 0 && nextDate != 0) { 
            if(taskAssignedDate < previousDate || taskAssignedDate > nextDate){
              alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskDetails.TaskDateError</emxUtil:i18nScript>");
              return "Error";
            }
         }
         else if(previousDate != 0)
         {
            if(taskAssignedDate < previousDate){
              alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskDetails.TaskDateError1</emxUtil:i18nScript>");
              return "Error";
            }
         }
         else if(nextDate != 0)
         {
            if(taskAssignedDate > nextDate){
              alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskDetails.TaskDateError2</emxUtil:i18nScript>");
              return "Error";
            }
         }
         return "";
       }
  function submitFormRoute() {
  var instructions = document.frmTaskDetails.instructions.value;
  instructions = trim(instructions);
   if ( instructions == "" ) {
     alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
     document.frmTaskDetails.instructions.focus();
     return;
   }
<% 
if( (prevObjectDate != 0 && nextObjectDate != 0) || (prevObjectDate != 0) || (nextObjectDate != 0) )
   {
%>
   var returnValue = checkDates();
   if(returnValue == "Error")
     return;
<%
  }
%>
   if(document.frmTaskDetails.oldDueDate && document.frmTaskDetails.scheduledDate)
   {
    var pastDate = "false";
    var oldDateMilli = Number(document.frmTaskDetails.oldDueDate.value); 
    var oldDate = new Date(oldDateMilli);
    var newDateMilli = Number(document.frmTaskDetails.scheduledDate_msvalue.value);
    var scheduledDate = document.frmTaskDetails.scheduledDate.value;
    if(oldDateMilli != newDateMilli) {
      // Date Validation for giving message to user if any selected date is 
      // past date
      // Taking current date into a variable
      var toDayDate = new Date();
      // Decrimentng the current date by one day
      // This is required since we are taking month/date/year only and 
      // putting time as 00.00.00
      //  so this function will give alert if user picks up even todays date.
      toDayDate.setDate(toDayDate.getDate() - 1);
      var date1 = new Date(newDateMilli);
      //  Addressing  Y2K.
      if (date1.getFullYear()< 1950) {
        // add 100 years.
        date1.setFullYear(date1.getFullYear() + 100);
      }
      if ( (Date.parse(date1.toGMTString()) <= Date.parse(toDayDate.toGMTString())) ){
        pastDate = "true";
      }
      if ( pastDate == "true" ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.EditTaskDetails.DateMessage</emxUtil:i18nScript>");
        return;
      }
    } else if ( scheduledDate == "" ) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterDate</emxUtil:i18nScript>");
      document.frmTaskDetails.scheduledDate.focus();
      return;
    }
  }
    var apostrophePosition   = instructions.indexOf("'");
    var hashPosition         = instructions.indexOf("#");
    var doublequotesPosition = instructions.indexOf("\"");
    if (apostrophePosition != -1 || hashPosition != -1 || doublequotesPosition != -1){
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.InstructionSpecialCharacters</emxUtil:i18nScript>");
        document.frmTaskDetails.instructions.focus();
        return;
    }
    document.frmTaskDetails.action = "emxEditRouteTaskProcess.jsp";
<%
if(objType.equals(DomainObject.TYPE_ROUTE_TEMPLATE))
{
%>
    document.frmTaskDetails.action = "emxEditRouteTemplateTaskProcess.jsp";
<%
}
%>
   document.frmTaskDetails.submit();
  }

  function closeWindow() {
    window.closeWindow();
    return;
  }

  function redirectFocus(str) {
      document.frmTaskDetails.routeTime.focus();
      getDate('frmTaskDetails',str);
      return;
  }

</script>
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
