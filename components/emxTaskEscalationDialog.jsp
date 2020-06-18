<%--  emxTaskEscalationDialog.jsp  -   Setting Task Escalation.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTaskEscalationDialog.jsp.rca 1.11 Wed Oct 22 16:18:43 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
  DomainObject Route = DomainObject.newInstance(context);
  String jsTreeID                 = emxGetParameter(request,"jsTreeID");
  String objectId                 = emxGetParameter(request,"objectId");
  String suiteKey                 = emxGetParameter(request,"suiteKey");
  String WorkspaceScope           = "false";
  String fromPage  = emxGetParameter(request,"fromPage");
  String routeIds =emxGetParameter(request,"routeIds");

  String relTaskEscalation        = PropertyUtil.getSchemaProperty(context, "relationship_TaskEscalationMessage");
  String typeTaskEscalationMessage=PropertyUtil.getSchemaProperty(context,"type_TaskEscalationMessage");

  String strAttrRecipient         = "attribute["+ PropertyUtil.getSchemaProperty(context, "attribute_Recipient") + "]";
  String strAttrDayDelta          = "attribute["+ PropertyUtil.getSchemaProperty(context, "attribute_DayDelta") + "]";
  String strAttrHoursDelta        = "attribute["+ PropertyUtil.getSchemaProperty(context, "attribute_HoursDelta") + "]";

  String sTaskAsigneePlusorMinus  = null;
  String sTaskAsigneeDeltaDays    = null;
  String sTaskAsigneeDeltaHours   = null;

  String sRouteOwnerPlusorMinus   = null;
  String sRouteOwnerDeltaHours    = null;
  String sRouteOwnerDeltaDays     = null;

  String sWrkLeadsPlusorMinus     = null;
  String sWrkLeadsDeltaHours      = null;
  String sWrkLeadsDeltaDays       = null;

  String sProjectLeadsPlusorMinus     = null;
  String sProjectLeadsDeltaHours      = null;
  String sProjectLeadsDeltaDays       = null;

  Hashtable taskAsigneeTable      = null;
  Hashtable routeOwnerTable       = null;
  Hashtable wrkspLeadsTable       = null;
  Hashtable projectLeadsTable       = null;
  boolean isTeamCentralInstalled = FrameworkUtil.isSuiteRegistered(context,"featureVersionTeamCentral",false,null,null);
  boolean isProgramCentralInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionProgramCentral",false,null,null);


MapList taskEscalationMapList = new MapList();
if( ((fromPage == null) || (fromPage.equals(""))) && UIUtil.isNotNullAndNotEmpty(objectId) )
{
        Route.setId(objectId);
        StringList relSelectStmts = new StringList(4);
        relSelectStmts.addElement("id");
        relSelectStmts.addElement(strAttrRecipient);
        relSelectStmts.addElement(strAttrDayDelta);
        relSelectStmts.addElement(strAttrHoursDelta);

        taskEscalationMapList = Route.getRelatedObjects(context,relTaskEscalation,typeTaskEscalationMessage,
                                                Route.EMPTY_STRINGLIST,
                                                relSelectStmts,
                                                false,
                                                true,
                                                (short)1,
                                                Route.EMPTY_STRING,
                                                Route.EMPTY_STRING,
                                                null,
                                                null,
                                                null);
        int size = taskEscalationMapList.size();
        Map taskEscalationMap=null;
          for(int i=0;i<size;i++)
          {
              taskEscalationMap=(Map)taskEscalationMapList.get(i);
              if ("emxTaskAssignee".equals((String)taskEscalationMap.get(strAttrRecipient)))
              {
                taskAsigneeTable = new Hashtable();
                taskAsigneeTable.put("DeltaDays", (String)taskEscalationMap.get(strAttrDayDelta));
                taskAsigneeTable.put("DeltaHours", (String)taskEscalationMap.get(strAttrHoursDelta));
              }else if ("emxRouteOwner".equals((String)taskEscalationMap.get(strAttrRecipient))){
                routeOwnerTable = new Hashtable();
                routeOwnerTable.put("DeltaDays", (String)taskEscalationMap.get(strAttrDayDelta));
                routeOwnerTable.put("DeltaHours", (String)taskEscalationMap.get(strAttrHoursDelta));
              }else if( ("emxWorkspaceLeads".equals((String)taskEscalationMap.get(strAttrRecipient))) && (isTeamCentralInstalled) ){
                wrkspLeadsTable = new Hashtable();
                wrkspLeadsTable.put("DeltaDays", (String)taskEscalationMap.get(strAttrDayDelta));
                wrkspLeadsTable.put("DeltaHours", (String)taskEscalationMap.get(strAttrHoursDelta));
              }else if( ("emxProjectLeads".equals((String)taskEscalationMap.get(strAttrRecipient)))&& (isProgramCentralInstalled) ){
                projectLeadsTable = new Hashtable();
                projectLeadsTable.put("DeltaDays", (String)taskEscalationMap.get(strAttrDayDelta));
                projectLeadsTable.put("DeltaHours", (String)taskEscalationMap.get(strAttrHoursDelta));
              }
            }

		String restrictScope = Route.getAttributeValue(context, DomainConstants.ATTRIBUTE_RESTRICT_MEMBERS);
		if ((restrictScope != null )&& (!restrictScope.equals("All")) && (!restrictScope.equals("Organization")))
		{
		Route route = new Route(objectId);
		boolean hasAccessToScopeObject = route.hasReadAccessToScopeObject(context, restrictScope);
    	Map scopeObjInfo = route.getScopeObjectTypeNameRevision(context, restrictScope, !hasAccessToScopeObject);
    	String scope = (scopeObjInfo.get(DomainConstants.SELECT_TYPE).toString());
    	if(DomainConstants.TYPE_PROJECT.equals(scope)){
    		WorkspaceScope = "true";
		}
    		}
		}
%>


<script language = javascript>
  function doCheck() {
    var objForm   = document.forms[0];
    var chkList   = objForm.checkAll;
    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].type == "checkbox"){
        objForm.elements[i].checked = chkList.checked;
      }
  }
  function updateCheck() {
    var chkList = document.forms[0].checkAll;
    chkList.checked = false;
    if(!document.subscribeForm.TaskAssignee.checked) {
       document.subscribeForm.TaskAssigneePlusorMinus.selectedIndex=0
       document.subscribeForm.TaskAssigneeDays.selectedIndex=0
       document.subscribeForm.TaskAssigneeHours.selectedIndex=0
    }
    if(!document.subscribeForm.RouteOwner.checked) {
       document.subscribeForm.RouteOwnerPlusorMinus.selectedIndex=0
       document.subscribeForm.RouteOwnerDays.selectedIndex=0
       document.subscribeForm.RouteOwnerHours.selectedIndex=0
    }
<%
    if(isTeamCentralInstalled && WorkspaceScope.equals("true"))
    {
%>
    if(!document.subscribeForm.WorkspaceLeads.checked) {
       document.subscribeForm.WorkspaceLeadsPlusorMinus.selectedIndex=0
       document.subscribeForm.WorkspaceLeadsDays.selectedIndex=0
       document.subscribeForm.WorkspaceLeadsHours.selectedIndex=0
    }
<%
}
%>
<%

    if(isProgramCentralInstalled)
    {
%>
    if(!document.subscribeForm.ProjectLeads.checked) {
       document.subscribeForm.ProjectLeadsPlusorMinus.selectedIndex=0
       document.subscribeForm.ProjectLeadsDays.selectedIndex=0
       document.subscribeForm.ProjectLeadsHours.selectedIndex=0
    }
<%
}
%>
  }

  function submitForm() {
   var checkedFlag = "false";
   if((document.subscribeForm.TaskAssigneePlusorMinus.selectedIndex ==0 &&  document.subscribeForm.TaskAssigneeDays.selectedIndex ==0 &&  document.subscribeForm.TaskAssigneeHours.selectedIndex ==0 || document.subscribeForm.TaskAssignee.checked) &&
      (document.subscribeForm.RouteOwnerPlusorMinus.selectedIndex ==0 &&  document.subscribeForm.RouteOwnerDays.selectedIndex ==0 &&  document.subscribeForm.RouteOwnerHours.selectedIndex ==0 || document.subscribeForm.RouteOwner.checked)
      <%
        if(isTeamCentralInstalled && WorkspaceScope.equals("true"))
        {
        %>
         &&(document.subscribeForm.WorkspaceLeadsPlusorMinus.selectedIndex ==0 &&  document.subscribeForm.WorkspaceLeadsDays.selectedIndex ==0 &&  document.subscribeForm.WorkspaceLeadsHours.selectedIndex ==0 || document.subscribeForm.WorkspaceLeads.checked)
        <%
        }
        %>
        <%
        if(isProgramCentralInstalled)
        {
        %>
        &&(document.subscribeForm.ProjectLeadsPlusorMinus.selectedIndex ==0 &&  document.subscribeForm.ProjectLeadsDays.selectedIndex ==0 &&  document.subscribeForm.ProjectLeadsHours.selectedIndex ==0 || document.subscribeForm.ProjectLeads.checked)
        <%
        }%>

     ) {
    checkedFlag = "true";
    }

    if(checkedFlag == "false")
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.DiscussionSummary.EventAlert</emxUtil:i18nScript>");
      checkedFlag = "false";
      return;
    }
    startProgressBar();
    document.subscribeForm.submit();
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="subscribeForm" method="post" action="emxTaskEscalationProcess.jsp" onSubmit="javascript:submitForm(); return false">

<input type= hidden  name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
<input type= "hidden"  name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="fromPage" value="Dialog"/>
<input type="hidden" name="routeIds" value="<xss:encodeForHTMLAttribute><%=routeIds%></xss:encodeForHTMLAttribute>"/>

 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

  <tr>
    <th ><input type="checkbox" name="checkAll" id="checkAll" onclick="doCheck()"/></th>
    <th><emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.EscalateTo</emxUtil:i18n></th>
    <th><emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.EscalateonDueDate</emxUtil:i18n></th>
  </tr>
  <tr class="odd">
<%
  if (taskAsigneeTable != null ) {
%>
    <td><input type="checkbox" name="TaskAssignee" onclick="updateCheck()" checked/></td>
<%
  } else {
%>
    <td><input type="checkbox" name="TaskAssignee" onclick="updateCheck()"/></td>
<%
  }
%>
    <td><emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.TaskAssignee</emxUtil:i18n></td>
    <td>
    <select name="TaskAssigneePlusorMinus">
    <option name="plus" value="plus"><emxUtil:i18n localize="i18nId">emxComponents.Common.Plus</emxUtil:i18n></option>
    <option name="minus" value="minus"><emxUtil:i18n localize="i18nId">emxComponents.Common.Minus</emxUtil:i18n></option>
    </select>
    <select name="TaskAssigneeDays">
<%
  int noDays = Integer.parseInt(JSPUtil.getApplicationProperty(context,application,"emxComponents.SetTaskEscalationDeltaDays"));
  for(int i=0;i<noDays+1;i++)
  {
%>
    <option value="<%=i%>"><%=i%></option>
<%
  }
%>
    </select>
    <emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.Days</emxUtil:i18n>
    <select name="TaskAssigneeHours">
<%
  for(int j=0;j<24;j++)
  {
%>
    <option value="<%=j%>"><%=j%></option>
<%
  }
%>
    </select>
    <emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.Hours</emxUtil:i18n>

    </td>
  </tr>
  <tr class="even">
<%
  if (routeOwnerTable != null ) {
%>
    <td><input type="checkbox" name="RouteOwner" onclick="updateCheck()" checked/></td>
<%
  } else {
%>
    <td><input type="checkbox" name="RouteOwner" onclick="updateCheck()"/></td>
<%
  }
%>
    <td><emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.RouteOwner</emxUtil:i18n></td>
    <td>
    <select name="RouteOwnerPlusorMinus">
    <option name="plus" value="plus"><emxUtil:i18n localize="i18nId">emxComponents.Common.Plus</emxUtil:i18n></option>
    <option name="minus" value="minus"><emxUtil:i18n localize="i18nId">emxComponents.Common.Minus</emxUtil:i18n></option>
    </select>
    <select name="RouteOwnerDays">

<%
  for(int i=0;i<noDays+1;i++)
  {
%>
    <option value="<%=i%>"><%=i%></option>
<%
  }
%>
    </select>
    <emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.Days</emxUtil:i18n>
    <select name="RouteOwnerHours">
<%
  for(int j=0;j<24;j++)
  {
%>
    <option value="<%=j%>"><%=j%></option>
<%
  }
%>
    </select>
    <emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.Hours</emxUtil:i18n>

    </td>
  </tr>
<%
if(isTeamCentralInstalled && WorkspaceScope.equals("true"))
{
%>
    <tr class="odd">
<%
  if (wrkspLeadsTable != null ) {
%>
    <td><input type="checkbox" name="WorkspaceLeads" onclick="updateCheck()" checked/></td>
<%
  } else {
%>
    <td><input type="checkbox" name="WorkspaceLeads" onclick="updateCheck()"/></td>
<%
  }
%>
    <td><emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.WorkspaceLeads</emxUtil:i18n></td>
    <td>
    <select name="WorkspaceLeadsPlusorMinus">
    <option name="plus" value="plus"><emxUtil:i18n localize="i18nId">emxComponents.Common.Plus</emxUtil:i18n></option>
    <option name="minus" value="minus"><emxUtil:i18n localize="i18nId">emxComponents.Common.Minus</emxUtil:i18n></option>
    </select>
    <select name="WorkspaceLeadsDays">
<%
  for(int i=0;i<noDays+1;i++)
  {
%>
    <option value="<%=i%>"><%=i%></option>
<%
  }
%>
    </select>
    <emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.Days</emxUtil:i18n>
    <select name="WorkspaceLeadsHours">
<%
  for(int j=0;j<24;j++)
  {
%>
    <option value="<%=j%>"><%=j%></option>
<%
  }
%>
    </select>
    <emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.Hours</emxUtil:i18n>

    </td>
  </tr>
  <%
  }
  %>
<%
    if(isProgramCentralInstalled)
   {
%>
   <tr class="odd">
<%
  if (projectLeadsTable != null ) {
%>
    <td><input type="checkbox" name="ProjectLeads" onclick="updateCheck()" checked/></td>
<%
  } else {
%>
    <td><input type="checkbox" name="ProjectLeads" onclick="updateCheck()"/></td>
<%
  }
%>
    <td><emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.ProjectLeads</emxUtil:i18n></td>
    <td>
    <select name="ProjectLeadsPlusorMinus">
    <option name="plus" value="plus"><emxUtil:i18n localize="i18nId">emxComponents.Common.Plus</emxUtil:i18n></option>
    <option name="minus" value="minus"><emxUtil:i18n localize="i18nId">emxComponents.Common.Minus</emxUtil:i18n></option>
    </select>
    <select name="ProjectLeadsDays">
<%
  for(int i=0;i<noDays+1;i++)
  {
%>
    <option value="<%=i%>"><%=i%></option>
<%
  }
%>
    </select>
    <emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.Days</emxUtil:i18n>
    <select name="ProjectLeadsHours">
<%
  for(int j=0;j<24;j++)
  {
%>
    <option value="<%=j%>"><%=j%></option>
<%
  }
%>
    </select>
    <emxUtil:i18n localize="i18nId">emxComponents.TaskEscalation.Hours</emxUtil:i18n>

    </td>
  </tr>
<%
}
%>
</table>

</form>

<script language="javascript">
<%
    if (taskAsigneeTable != null )
    {
        sTaskAsigneeDeltaDays = (String)taskAsigneeTable.get("DeltaDays");
        sTaskAsigneeDeltaHours = (String)taskAsigneeTable.get("DeltaHours");

        if (sTaskAsigneeDeltaDays.indexOf("-")==0 || sTaskAsigneeDeltaHours.indexOf("-")==0  )
        {
            sTaskAsigneePlusorMinus = "-";
            sTaskAsigneeDeltaDays = sTaskAsigneeDeltaDays.substring(sTaskAsigneeDeltaDays.indexOf("-") + 1);
            sTaskAsigneeDeltaHours = sTaskAsigneeDeltaHours.substring(sTaskAsigneeDeltaHours.indexOf("-") + 1);
        }
%>
        //XSSOK
        document.subscribeForm.TaskAssigneeDays.options[<%=(new Integer(sTaskAsigneeDeltaDays).intValue())%>].selected=true;
        //XSSOK
        document.subscribeForm.TaskAssigneeHours.options[<%=(new Integer(sTaskAsigneeDeltaHours).intValue())%>].selected=true;
<%
        if ("-".equals(sTaskAsigneePlusorMinus) ){
%>
            document.subscribeForm.TaskAssigneePlusorMinus.options[1].selected=true;
<%
        }
    }
    if (routeOwnerTable != null )
    {

        sRouteOwnerDeltaDays = (String)routeOwnerTable.get("DeltaDays");
        sRouteOwnerDeltaHours = (String)routeOwnerTable.get("DeltaHours");
        if (sRouteOwnerDeltaDays.indexOf("-")==0 || sRouteOwnerDeltaHours.indexOf("-")==0  ){
            sRouteOwnerPlusorMinus = "-";
            sRouteOwnerDeltaDays = sRouteOwnerDeltaDays.substring(sRouteOwnerDeltaDays.indexOf("-") + 1);
            sRouteOwnerDeltaHours = sRouteOwnerDeltaHours.substring(sRouteOwnerDeltaHours.indexOf("-") + 1);
        }
        if ("-".equals(sRouteOwnerPlusorMinus))
        {

%>
            document.subscribeForm.RouteOwnerPlusorMinus.options[1].selected=true;
<%
        }
%>
        //XSSOK
        document.subscribeForm.RouteOwnerDays.options[<%=(new Integer(sRouteOwnerDeltaDays).intValue())%>].selected=true;
        //XSSOK
        document.subscribeForm.RouteOwnerHours.options[<%=(new Integer(sRouteOwnerDeltaHours).intValue())%>].selected=true;
<%
    }
    if (wrkspLeadsTable != null )
    {

        sWrkLeadsDeltaDays = (String)wrkspLeadsTable.get("DeltaDays");
        sWrkLeadsDeltaHours = (String)wrkspLeadsTable.get("DeltaHours");
        if (sWrkLeadsDeltaDays.indexOf("-")==0 || sWrkLeadsDeltaHours.indexOf("-")==0  ){
            sWrkLeadsPlusorMinus = "-";
            sWrkLeadsDeltaDays = sWrkLeadsDeltaDays.substring(sWrkLeadsDeltaDays.indexOf("-") + 1);
            sWrkLeadsDeltaHours = sWrkLeadsDeltaHours.substring(sWrkLeadsDeltaHours.indexOf("-") + 1);
        }
        if ("-".equals(sWrkLeadsPlusorMinus))
        {

%>
            document.subscribeForm.WorkspaceLeadsPlusorMinus.options[1].selected=true;
<%
        }
%>
		//XSSOK
        document.subscribeForm.WorkspaceLeadsDays.options[<%=(new Integer(sWrkLeadsDeltaDays).intValue())%>].selected=true;
        //XSSOK
        document.subscribeForm.WorkspaceLeadsHours.options[<%=(new Integer(sWrkLeadsDeltaHours).intValue())%>].selected=true;
<%
    }
    if (projectLeadsTable != null )
    {

        sProjectLeadsDeltaDays = (String)projectLeadsTable.get("DeltaDays");
        sProjectLeadsDeltaHours = (String)projectLeadsTable.get("DeltaHours");
        if (sProjectLeadsDeltaDays.indexOf("-")==0 || sProjectLeadsDeltaHours.indexOf("-")==0  ){
            sProjectLeadsPlusorMinus = "-";
            sProjectLeadsDeltaDays = sProjectLeadsDeltaDays.substring(sProjectLeadsDeltaDays.indexOf("-") + 1);
            sProjectLeadsDeltaHours = sProjectLeadsDeltaHours.substring(sProjectLeadsDeltaHours.indexOf("-") + 1);
        }
        if ("-".equals(sProjectLeadsPlusorMinus))
        {
%>
            document.subscribeForm.ProjectLeadsPlusorMinus.options[1].selected=true;
<%
        }
%>
		//XSSOK
        document.subscribeForm.ProjectLeadsDays.options[<%=(new Integer(sProjectLeadsDeltaDays).intValue())%>].selected=true;
        //XSSOK
        document.subscribeForm.ProjectLeadsHours.options[<%=(new Integer(sProjectLeadsDeltaHours).intValue())%>].selected=true;
<%
    }
%>

</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

