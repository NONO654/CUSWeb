<%--  emxRouteTemplateWizardRemoveMemberProcess.jsp - Removes Content from the route Template.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $: Exp $

--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<html>
<body>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%


String keyValue=emxGetParameter(request,"keyValue");

if(keyValue == null){
        keyValue = formBean.newFormKey(session);
}
formBean.processForm(session,request,"keyValue");




  Route routeObject       = (Route) DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE,DomainConstants.TEAM);
  DomainObject BaseObject = DomainObject.newInstance(context);

  String templateId       = emxGetParameter(request, "templateId");
  String templateName     = emxGetParameter(request, "template");
  String objectId         = emxGetParameter(request, "objectId");
  String routeId          = emxGetParameter(request, "routeId");
  String sRoles           = emxGetParameter(request, "selRoles");
  String sGroup           =emxGetParameter(request, "selGroup");
  StringList roleList = FrameworkUtil.split(sRoles,";");
  StringList groupList = FrameworkUtil.split(sGroup,";");


  String tempTreeLabel    = "";

  String removeMember = (String) formBean.getElementValue("removeMember");

  if(removeMember == null){
	  removeMember = "blank";
  }

  try {

         String[] selPersons   = emxGetParameterValues(request, "chkItem");
         MapList routeMemberMapList =(MapList)formBean.getElementValue("routeMemberMapList");
         MapList routeRoleMapList =(MapList)formBean.getElementValue("routeRoleMapList");
         MapList routeGroupMapList =(MapList)formBean.getElementValue("routeGroupMapList");
         
         // Begin : Bug 341297 : Code modification
         MapList taskMapList =(MapList)formBean.getElementValue("taskMapList");
         if (taskMapList == null) {
             taskMapList = new MapList();
         }
         // End : Bug 341297 : Code modification
         
         boolean hasRole=false;
         boolean hasGroup=false;
         int selPersonCount = 0;
         java.util.List selectedPersonList = Arrays.asList(selPersons);
         
         Iterator routeMemberMapListItr = routeMemberMapList.iterator();
                 while(routeMemberMapListItr.hasNext()){
                        HashMap memberMap = (HashMap)routeMemberMapListItr.next();
                        String memid = (String)memberMap.get("id");
                        String memName = (String)memberMap.get("name");
                        hasRole=false;
                        hasGroup=false;
                        if(memid.equals("Role"))
                        {
                                hasRole=roleList.contains(memName);
                                if(hasRole){
                                        routeMemberMapListItr.remove();
                                        routeRoleMapList.remove(memberMap);
                                        selPersonCount++;
                                }
                        }else if(memid.equals("Group"))
                        {
                                hasGroup=groupList.contains(memName);
                                if(hasGroup){
                                        routeMemberMapListItr.remove();
                                        routeGroupMapList.remove(memberMap);
                                        selPersonCount++;
                                }
                        }else if(selectedPersonList.contains(memid))
                        {
                               routeMemberMapListItr.remove();
                                selPersonCount++;
                        }
                        if(selPersonCount == selPersons.length){
                            break;
                        }                        
                 }

                 // Begin : Bug 341297 : Code modification
                 // Remove the corresponding tasks for the person/role/group
                 Map mapTaskInfo = null;
                 String strPersonId = null;
                 String strName = null;
                 
                 Iterator taskMapListItr = taskMapList.iterator();
                 while(taskMapListItr.hasNext()) {
                     mapTaskInfo = (Map)taskMapListItr.next();
                     
                     strPersonId = (String)mapTaskInfo.get("PersonId");
                     strName = (String)mapTaskInfo.get("name");
                     if (strName == null) {
                         strName = (String)mapTaskInfo.get("PersonName");
                     }
                     
                     if("Role".equals(strPersonId)) {
	                     if(roleList.contains(strName)) {
	                         taskMapListItr.remove();
	                     }
                     }
                     else if("Group".equals(strPersonId)) {
						if(groupList.contains(strName)) {
						    taskMapListItr.remove();
						}
                     }
                     else if(selectedPersonList.contains(strPersonId)) {
                         taskMapListItr.remove();
                     }
              	}
              	// End : Bug 341297 : Code modification
        formBean.setElementValue("routeMemberMapList",routeMemberMapList);
        // Begin : Bug 341297 : Code modification
        formBean.setElementValue("taskMapList", taskMapList);
        // End : Bug 341297 : Code modification
       formBean.setElementValue("routeRoleMapList", routeRoleMapList);
       formBean.setElementValue("routeGroupMapList", routeGroupMapList);
       formBean.setFormValues(session);
  } catch (Exception ex ) {
    session.putValue("error.message",ex);
  }

%>

<form name="newForm" target="_parent">
  <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=templateName %></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="objectId"   value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="routeId"    value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>"/>
</form>

<script language="javascript">


 document.newForm.action = ' emxCreateRouteTemplateWizardMembersDialogFS.jsp?Routewizard="RouteWizard"&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>';
document.newForm.submit();
</script>
</body>
</html>


