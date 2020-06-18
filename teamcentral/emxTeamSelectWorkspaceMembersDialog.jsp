<%--  emxTeamWorkspaceSelectMembersDialog.jsp   -  Search for members in the company
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamSelectWorkspaceMembersDialog.jsp.rca 1.40 Wed Oct 22 16:06:12 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamProfileUtil.inc"%>
<%@include file = "emxTeamUtil.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxPaginationInclude.inc" %>

<%@ page import = "com.matrixone.apps.team.TeamUtil" %>

<%
  String flag       = emxGetParameter(request,"flag");
  String searchFlag = emxGetParameter(request,"searchFlag");
  Workspace workspaceObject = (Workspace)DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,
           DomainConstants.TEAM);
  DomainObject wsVaultObj = null;
  // get the search conditions selected
  String sProjectId             = emxGetParameter(request, "projectId");
  String sRouteId               = emxGetParameter(request, "routeId");
  String firstPersonName        = emxGetParameter(request, "firstName");
  String lastPersonName         = emxGetParameter(request, "lastName");
  String role                   = emxGetParameter(request, "role");
  String chkSubscribeEvent      = emxGetParameter(request, "chkSubscribeEvent");
  String objectId               = emxGetParameter(request, "objectId");
  String sfromPage              = emxGetParameter(request,"fromPage");
  String strnoSearch            = emxGetParameter(request, "noSearch");
  String strcompanyFilter       = emxGetParameter(request, "company");
  String userName               = emxGetParameter(request,"userName");
%>

<script language = "Javascript" type = "text/javascript">
  var flag = "<%=XSSUtil.encodeForJavaScript(context, flag)%>";
  function closeWindow() {
    parent.window.closeWindow();
    return;
  }
  function newSearch() {
    parent.window.location.href="emxTeamSearchWorkspaceMembersDialogFS.jsp?projectId=<%=XSSUtil.encodeForURL(context, sProjectId)%>&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&noSearch=<%=XSSUtil.encodeForURL(context, strnoSearch)%>&company=<%=XSSUtil.encodeForURL(context, strcompanyFilter)%>&userName=<%=XSSUtil.encodeForURL(context, userName)%>&chkSubscribeEvent=<%=XSSUtil.encodeForURL(context, chkSubscribeEvent)%>&searchFlag=<%=XSSUtil.encodeForURL(context, searchFlag)%>&flag=<%=XSSUtil.encodeForURL(context, flag)%>";
  }

  function submitForm() {
    var checkedFlag = "false";
    for( var i = 0; i < document.formMembers.elements.length; i++ ){
      if (document.formMembers.elements[i].type == "checkbox" &&
        document.formMembers.elements[i].checked &&
        document.formMembers.elements[i].name == "chkItem1" ){
        checkedFlag = "true";
        break;
      }
    }
    if (checkedFlag == "false") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.TeamMemberSearch.SelectOneMember</emxUtil:i18nScript>");
      return;
    }
    if(flag == null || flag == "null" || flag == "") {
      document.formMembers.action = "emxTeamSelectWorkspaceMembersProcess.jsp";
      startProgressBar(true);
      document.formMembers.submit();
    } else {
      document.formMembers.action = "emxTeamSubscribeWorkspaceOptions.jsp";
      startProgressBar(true);
      document.formMembers.submit();
    }
   }

  function doCheckCheckBox(){
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].name.indexOf('chkItem1') > -1){
        objForm.elements[i].checked = chkList.checked;
      }
  }

  function updateCheck() {
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    chkList.checked = false;
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%

  if (firstPersonName != null){
    firstPersonName = firstPersonName.trim();
  }

  if (lastPersonName != null){
    lastPersonName = lastPersonName.trim();
  }

  if (strnoSearch != null && strnoSearch.equals("true"))
  {
    firstPersonName = "*";
    lastPersonName  = "*";
    userName        = "*";

  }
  role = "All";
  String employeeRel   = workspaceObject.RELATIONSHIP_EMPLOYEE;
  String projMembership= workspaceObject.RELATIONSHIP_PROJECT_MEMBERSHIP;

  DomainObject routeScopeObj  = null;
  AccessUtil accessUtil         = new AccessUtil();
  Access access                 = new Access();
  String sAccess                = "";
  String projectId              = "";

  String sParams                = "projectId="+XSSUtil.encodeForHTML(context, sProjectId)+"&routeId="+XSSUtil.encodeForHTML(context, sRouteId)+"&firstName="+XSSUtil.encodeForHTML(context, firstPersonName)+"&lastName="+XSSUtil.encodeForHTML(context, lastPersonName)+"&role="+XSSUtil.encodeForHTML(context, role);

  String sProjectMemebership    = DomainObject.RELATIONSHIP_PROJECT_MEMBERSHIP;
  String sProjectMembers        = DomainObject.RELATIONSHIP_PROJECT_MEMBERS;
  String relVaultedDocuments    = DomainObject.RELATIONSHIP_VAULTED_DOCUMENTS;
  String relProjectVaults       = DomainObject.RELATIONSHIP_PROJECT_VAULTS;
  String relRouteNode           = DomainObject.RELATIONSHIP_ROUTE_NODE;
  String relRouteScope          = DomainObject.RELATIONSHIP_ROUTE_SCOPE;
  String sTypeProject           = DomainObject.TYPE_PROJECT;
  String firstNameStr           = DomainObject.ATTRIBUTE_FIRST_NAME;
  String lastNameStr            = DomainObject.ATTRIBUTE_LAST_NAME;
  String eventType              = Framework.getPropertyValue( session, "attribute_EventType");
  String type_Event             = Framework.getPropertyValue( session, "type_Event");
  String type_Pub_Subscribe     = Framework.getPropertyValue( session, "type_PublishSubscribe");

  String sState                 = "";
  String routeScopeObjId        = "";
  String sid                    = "";
  String sBusWhere              = "";
  String sBusWherePerson 		= "";
  String sPersonId              = "";
  String sPersonLastFirstName   = "";
  String sType                  = "";
  String sProjectLead           = "";
  String eventId  = "";
  MapList eventList = new MapList();
  StringList personEventList = new StringList();

  MapList memberMapList = new MapList();
  StringList  routeMemList = new StringList();
  StringList  routeWizRoleList= new StringList();
  StringList  routeRoleList   = new StringList();

  //to check whether the list of Members already added as Route Member
  if(sfromPage != null && sfromPage.equals("routeWizard")) {
      memberMapList =(MapList)session.getValue("routeMemberMapList");
      if(memberMapList != null && memberMapList.size() >0) {
              Iterator mapMemberItr = memberMapList.iterator();
              while(mapMemberItr.hasNext()) {
                  Map mapMember     = (Map)mapMemberItr.next();
                  String smemberID  = (String)mapMember.get(workspaceObject.SELECT_ID);
                  if(smemberID.equals("Role"))
                  {
                    routeWizRoleList.add("Role~" + (String)mapMember.get(DomainConstants.SELECT_NAME));
                  }
                  else
                  {
                    routeMemList.add("Person~" + smemberID);
                  }
              }
      }

    Hashtable hashRouteWizFirst =(Hashtable)session.getValue("hashRouteWizFirst");

    if(sProjectId == null || "".equals(sProjectId))
    {
      String scopeId = (String)hashRouteWizFirst.get("scopeId");
      sProjectId = scopeId;

    }

    if(objectId == null || "".equals(objectId))
    {
      String objId = (String)hashRouteWizFirst.get("objectId");
      objectId = objId;

    }
        routeScopeObjId = (String)hashRouteWizFirst.get("scopeId");
        routeScopeObj   = DomainObject.newInstance(context, routeScopeObjId, DomainConstants.TEAM);


    } else {
        if(sRouteId != null && !"".equals(sRouteId) && !"null".equals(sRouteId)){
            sRouteId                    = sRouteId.trim();
            Route routeObj       = (Route)DomainObject.newInstance(context , sRouteId , DomainConstants.TEAM);
            SelectList selectPersonRelStmts = new SelectList();
            selectPersonRelStmts.addElement(routeObj.SELECT_ROUTE_TASK_USER);
            MapList routeRoleMapList  = routeObj.getAssignedRoles(context, null, selectPersonRelStmts, false);
            Iterator routeRoleMapListItr = routeRoleMapList.iterator();
            Map roleMap = null;
            String roleName = null;
            while(routeRoleMapListItr.hasNext())
            {
               roleMap = (Map)routeRoleMapListItr.next();
               roleName = (String) roleMap.get("attribute[" + DomainConstants.TYPE_ROUTE_TASK_USER + "]");
               if(roleName != null)
               {
                roleName  = Framework.getPropertyValue(session, roleName);
                routeRoleList.add("Role~" + roleName);
               }
            }
            routeScopeObjId             = routeObj.getInfo(context,"to["+relRouteScope+"].from.id");


            if(routeScopeObjId == null){
                routeScopeObjId = "";
            }

            if(!"".equals(routeScopeObjId)){
                routeScopeObj             = DomainObject.newInstance(context, routeScopeObjId,DomainConstants.TEAM);

            }
        }
    }
  //set the domain object as Work space.
  workspaceObject.setId(sProjectId);
  projectId                     = sProjectId;
  if(workspaceObject.getType(context).equals(DomainObject.TYPE_PROJECT_VAULT) ) {
    wsVaultObj                  = DomainObject.newInstance(context,sProjectId,DomainConstants.TEAM);
    sid                         = UserTask.getProjectId(context,sProjectId);
    workspaceObject.setId(sid);
    projectId                   = sid;

  } else if(workspaceObject.getType(context).equals(DomainObject.TYPE_DOCUMENT) )  {
    // get the project id of the passed document.
    sid                         = workspaceObject.getInfo(context, "to[" + relVaultedDocuments + "].from.to[" + relProjectVaults + "].from.id");
    workspaceObject.setId(sid);
    projectId                   = sid;

  }
  String sTitleNamePerson                    = "name";
  String sTitleTypePerson                    = "type";
  String sTypeIdPerson                       = "id";
  String sCurrentStatePerson                 = "currentstate";
  String sFirstNamePerson                    = "attribute["+firstNameStr+"]";
  String sLastNamePerson                     = "attribute["+lastNameStr+"]";
  String sStatePerson                        = DomainObject.SELECT_CURRENT;

  Pattern pattFirstName = null;
  Pattern pattLastName = null;

  boolean bListedPerson = false;

  String typeSecurityContext = PropertyUtil.getSchemaProperty(context, DomainSymbolicConstants.SYMBOLIC_type_SecurityContext);
  String assingedSecurityContext =  PropertyUtil.getSchemaProperty(context, DomainSymbolicConstants.SYMBOLIC_relationship_AssignedSecurityContext);
  
  String sTitleName                    = "relationship[" + assingedSecurityContext + "].from.name";
  String sTitleType                    = "relationship[" + assingedSecurityContext + "].from.type";
  String sTypeId                       = "relationship[" + assingedSecurityContext + "].from.id";
  String sCurrentState                 = "relationship[" + assingedSecurityContext + "].from.current";
  String sFirstName                    = "relationship[" + assingedSecurityContext + "].from.attribute[First Name]";
  String sLastName                     = "relationship[" + assingedSecurityContext + "].from.attribute[Last Name]";

  MapList wsMembersMapList = new MapList();
  String strLastFirstName = "LastFirstName";
  String strTitleType = "sTitleType";
  if (emxPage.isNewQuery()) {
      StringList selects = new StringList();
      selects.addElement(sTitleType);
      selects.addElement(sTitleName);
      selects.addElement(sCurrentState);
      selects.addElement(sTypeId);
      selects.addElement(sLastName);
      selects.addElement(sFirstName);
      selects.addElement(sTitleName);
      
      Collection personAttrMultiValueList = new HashSet(6);
      personAttrMultiValueList.add(sTitleType);
	  personAttrMultiValueList.add(sTitleName);
	  personAttrMultiValueList.add(sCurrentState);
	  personAttrMultiValueList.add(sTypeId);
      personAttrMultiValueList.add(sLastName);
      personAttrMultiValueList.add(sFirstName);
      personAttrMultiValueList.add(sTitleName);

	  //added for person
	  StringList selRelList         = new StringList();
      StringList selTypeList        = new StringList();
      selTypeList.add(workspaceObject.SELECT_NAME);
      selTypeList.add(sTypeIdPerson);
      selTypeList.add(sTitleNamePerson);
      selTypeList.add(sTitleTypePerson);
      selTypeList.add(sCurrentStatePerson);
      selTypeList.add(sFirstNamePerson);
      selTypeList.add(sLastNamePerson);
      selTypeList.add(sStatePerson);
      
      if(!firstPersonName.equals("*") && !firstPersonName.equals("")) {
      	if(firstPersonName.indexOf("*") == -1) {
			firstPersonName = firstPersonName+"*";
        }
		sBusWhere = "(relationship[" + assingedSecurityContext + "].from.attribute["+firstNameStr+"] ~~ \""+firstPersonName+"\")";
		sBusWherePerson = "(attribute["+firstNameStr+"] ~~ \""+firstPersonName+"\")";
      }

      if(!lastPersonName.equals("*") && !lastPersonName.equals("")) {
        if(lastPersonName.indexOf("*") == -1) {
			lastPersonName = lastPersonName+"*";
		}
        if(sBusWhere.length()>0) {sBusWhere += " && ";}
			sBusWhere += "(relationship[" + assingedSecurityContext + "].from.attribute["+lastNameStr+"] ~~ \""+lastPersonName+"\")";
        if(sBusWherePerson.length()>0) {sBusWherePerson += " && ";}
			sBusWherePerson += "(attribute["+lastNameStr+"] ~~ \""+lastPersonName+"\")";
    }

      if(!userName.equals("*") && !userName.equals("")) {
            if(userName.indexOf("*") == -1) {
				userName = userName+"*";
			}
            if(sBusWhere.length()>0) {sBusWhere += " && ";}
           	sBusWhere += "(relationship[" + assingedSecurityContext + "].from.name ~~ \""+userName+"\")";
          	if(sBusWherePerson.length()>0) {sBusWherePerson += " && ";}
			sBusWherePerson += "(name ~~ \""+userName+"\")";
    }



    if(strcompanyFilter != null && !(strcompanyFilter.equals("*")) && !(strcompanyFilter.equals(""))) {
      
    	if(sBusWhere.length()>0) { sBusWhere += " && "; }
    	if(sBusWherePerson.length()>0) {  sBusWherePerson += " && "; }
    	if(strcompanyFilter.indexOf("*") == -1) {
          sBusWhere += "(relationship[" + assingedSecurityContext +"].organization == \""+ strcompanyFilter + "\")";
          sBusWherePerson += "(to[" + employeeRel +"].from.name] == \""+ strcompanyFilter + "\")";  
      	} else { 
          sBusWhere += "(relationship[" + assingedSecurityContext +"].organization ~= \""+strcompanyFilter+"\")";
          sBusWherePerson += "(to["+employeeRel+"].from.name] ~= \""+strcompanyFilter+"\")";
            }
    }
    String isPersonPresent = "True";
    if(sBusWhere.length() > 0) {
        sBusWhere += " && (relationship[" + assingedSecurityContext +"] == \""+ isPersonPresent + "\")"; 
    }else {
       sBusWhere += "(relationship[" + assingedSecurityContext +"] == \""+ isPersonPresent + "\")"; 
    }
  MapList workspaceSecurityContext = DomainAccess.getAccessSummaryList(context, projectId);
  Iterator mapItrNew = workspaceSecurityContext.iterator();
  String objectNamePattern = "";
  while(mapItrNew.hasNext())
  {
	  Map map = (Map)mapItrNew.next();
      String securityContextName   = (String)map.get("name");
      String organization  =  (String)map.get("org");
      String project = (String)map.get("project");
      String personName = (String)map.get("username");
	  if(UIUtil.isNotNullAndNotEmpty(organization) && UIUtil.isNotNullAndNotEmpty(project) ) {
    	  objectNamePattern = objectNamePattern+"*"+organization+"."+project;
    	  objectNamePattern = objectNamePattern+",";
      }else if(UIUtil.isNotNullAndNotEmpty(securityContextName)){
    	  objectNamePattern =  objectNamePattern+securityContextName;
    	  objectNamePattern = objectNamePattern+",";
      }
    }

  objectNamePattern = objectNamePattern.substring(0,objectNamePattern.length()-1);
  sBusWhere += " && from[" + assingedSecurityContext + "].to.name" + " matchlist " + "\"" + objectNamePattern + "\" \",\"";
  String typePerson = DomainConstants.TYPE_PERSON;
  MapList mapList = DomainObject.findObjects(context, typePerson, DomainObject.QUERY_WILDCARD, DomainObject.QUERY_WILDCARD, DomainObject.QUERY_WILDCARD, DomainObject.QUERY_WILDCARD, sBusWhere, DomainObject.QUERY_WILDCARD, true, selects, (short)0,null, null, personAttrMultiValueList);

  //Added for person
  MapList mapListPerson =  workspaceObject.getWorkspaceMembers(context,selTypeList, sBusWherePerson);
  Iterator mapListPersonItr = mapListPerson.iterator();
  while(mapListPersonItr.hasNext()){
     Map personMap = (Map)mapListPersonItr.next();
     mapList.add(personMap);
  }
  //End

  MapList roleSubMapList = null;
  StringList wsVaultGranteeList = null;
  if(!"searchDialog".equals(searchFlag))
  {
    roleSubMapList = workspaceObject.getAssignedRoles(context,"sub");
    Iterator roleSubMapItr = roleSubMapList.iterator();
    if(wsVaultObj!=null){
      wsVaultGranteeList = wsVaultObj.getGrantees(context);
      while(roleSubMapItr.hasNext()){
        Map roleSubMap = (Map)roleSubMapItr.next();
        String roleName = (String)roleSubMap.get("name");
        if(!wsVaultGranteeList.contains(roleName)){
          roleSubMapItr.remove();
        }
      }
    }
  }
    Iterator mapItr = mapList.iterator();
    HashSet tempSet=new HashSet();  
    if(routeScopeObj == null) {
      routeScopeObj = DomainObject.newInstance(context, objectId);
    }
    while (mapItr.hasNext()) {
      Map map = (Map)mapItr.next();
	    StringList sStateList =(StringList) map.get(sCurrentState);
      	if(null != sStateList){
        StringList sTypeIdList =(StringList) map.get(sTypeId);
        StringList sTitleNameList = (StringList)map.get(sTitleName);
		StringList sTitleTypeList = (StringList)map.get(sTitleType);
        StringList sLastNameList = (StringList) map.get(sLastName);
        StringList sFirstNameList = (StringList) map.get(sFirstName);

        for (int j = 0;j < sStateList.size(); j++){
        	HashMap tempMap = new HashMap();
        	String strState = (String)sStateList.get(j);
        	String strTypeId = (String)sTypeIdList.get(j);
        	String strTitleName = (String)sTitleNameList.get(j);
        	String strTitleType1 = (String)sTitleTypeList.get(j);
        	String strLastName = (String)sLastNameList.get(j);
        	String strFirstName = (String)sFirstNameList.get(j);
			
        	if(strState.equals("Active") && !tempSet.contains(strTypeId)) {
          		tempMap.put("id",strTypeId);
          		tempMap.put("name",strTitleName);
          		tempMap.put(strTitleType,strTitleType1);
          		tempMap.put("currentstate", strState);
          		tempMap.put(strLastFirstName, strLastName +", " +strFirstName);
          wsMembersMapList.add(tempMap);
          		tempSet.add(strTypeId);
        	}
        }
      	}else{
      		 String personId = (String)map.get(sTypeIdPerson);
      		 String strStateP =(String) map.get(sStatePerson);
      		 if(strStateP.equals("Active") && !tempSet.contains(personId)) {
                HashMap tempMap = new HashMap();
                tempMap.put(workspaceObject.SELECT_NAME, map.get(workspaceObject.SELECT_NAME));
                tempMap.put("id", map.get(sTypeIdPerson));
                tempMap.put("name", map.get(sTitleNamePerson));
                tempMap.put(strTitleType, map.get(sTitleTypePerson));
                tempMap.put("currentstate", map.get(sCurrentStatePerson));
                tempMap.put(strLastFirstName, map.get(sLastNamePerson) +", " +map.get(sFirstNamePerson));
                wsMembersMapList.add(tempMap);
                tempSet.add(personId);
              }
      	}
      }
    if(roleSubMapList != null)
    {
      Iterator roleListItr = roleSubMapList.iterator();
      MapList tempMapList = new MapList();
      StringList checkList = new StringList();
      while(roleListItr.hasNext())
      {
         Map map = (Map)roleListItr.next();
         if(!checkList.contains((String)map.get("name")))
         {
           HashMap tempMap = new HashMap();
           tempMap.put("sTitleType" , "Role");
           tempMap.put("LastFirstName" , (String)map.get("name"));
           tempMapList.add(tempMap);
           checkList.add((String)map.get("name"));
         }
      }
      if(tempMapList != null && tempMapList.size() > 0)
      {
        wsMembersMapList.addAll(tempMapList);
      }
    }

          emxPage.getTable().setObjects(wsMembersMapList);
          //emxPage.getTable().setSelects(new SelectList());
}

            // this Maplist is the one which is used to make the table.
    wsMembersMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());

    if(flag!=null && "pushSubscription".equals(flag)){
    DomainObject routeObject     = DomainObject.newInstance(context , objectId , DomainConstants.TEAM);
    String routeOwner     = routeObject.getInfo(context,DomainObject.SELECT_OWNER);
    //Commented for Bug 370092 Should display owner as well in Add Recipients
 	//Iterator mapItr = wsMembersMapList.iterator();
      //while(mapItr.hasNext()){
        //Map tempMap = (Map)mapItr.next();
        //if(routeOwner.equals((String)tempMap.get("to["+sProjectMemebership+"].from.name"))){
         // mapItr.remove();
         // break;
        //}
      //}
    Pattern typePattern1 = new Pattern(type_Event);
    typePattern1.addPattern(type_Pub_Subscribe);

    Pattern relPattern1 = new Pattern(DomainObject.RELATIONSHIP_PUBLISH);
    relPattern1.addPattern(DomainObject.RELATIONSHIP_PUBLISH_SUBSCRIBE);

    StringList objectSelects = new StringList();

    objectSelects.add(DomainObject.SELECT_ID);
    objectSelects.add("attribute["+eventType+"]");

    eventList = routeObject.getRelatedObjects(context,
                                                  relPattern1.getPattern(),
                                                  typePattern1.getPattern(),
                                                  objectSelects,
                                                  null,
                                                  true,
                                                  true,
                                                  (short)2,
                                                  "",
                                                  "",
                                                  null,
                                                  new Pattern(DomainObject.RELATIONSHIP_PUBLISH),
                                                  null);

    Iterator mapItr1 = eventList.iterator();
    while(mapItr1.hasNext()){
      Map map = (Map)mapItr1.next();
      if(((String)map.get("attribute["+eventType+"]")).equals(chkSubscribeEvent)){
        eventId = (String)map.get(DomainObject.SELECT_ID);
        break;
      }
    }

    if(eventId !=null && !"".equals(eventId)){
      DomainObject eventObj = DomainObject.newInstance(context, eventId);
      personEventList = eventObj.getInfoList(context, "from["+DomainObject.RELATIONSHIP_PUSHED_SUBSCRIPTION+"].to.id");
      if(personEventList == null){
        personEventList = new StringList();
      }
    }
  }
 %>
 <form name="formMembers" method="post" action="" target="_parent">
  <input type="hidden" name="projectId" value="<xss:encodeForHTMLAttribute><%=sProjectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=sRouteId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="flag" value="<xss:encodeForHTMLAttribute><%=flag%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="chkSubscribeEvent" value="<xss:encodeForHTMLAttribute><%=chkSubscribeEvent%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="firstName" value="<xss:encodeForHTMLAttribute><%=firstPersonName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="lastName" value="<xss:encodeForHTMLAttribute><%=lastPersonName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="role" value="<xss:encodeForHTMLAttribute><%=role%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="fromPage" value="<xss:encodeForHTMLAttribute><%=sfromPage%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="memberType" value="Person"/>

  <table class="list" id="searchResultList" border="0" cellpadding="3" cellspacing="2" width="100%">
    <!-- //XSSOK -->
	<framework:sortInit  defaultSortKey="<%=strLastFirstName%>"  defaultSortType="string"  mapList="<%= wsMembersMapList %>"  resourceBundle="emxTeamCentralStringResource"  ascendText="emxTeamCentral.Common.SortAscending"  descendText="emxTeamCentral.Common.SortDescending"  params = "<%=sParams%>"  />

    <tr>
      <th width="2%" style="text-align: center;">
        <span style="text-align: center;">
          <input type="checkbox" name="chkList" id="chkList" onclick="doCheckCheckBox()" />
        </span>
      </th>
      <th>
		<!-- //XSSOK -->
        <framework:sortColumnHeader title="emxTeamCentral.Common.Name" sortKey="<%=strLastFirstName%>" sortType="string" anchorClass="sortMenuItem"/>
      </th>
      <th>
		<!-- //XSSOK -->
        <framework:sortColumnHeader  title="emxTeamCentral.Common.Type"  sortKey="<%=strTitleType%>"  sortType="string"  anchorClass="sortMenuItem"/>
      </th>
    </tr>
<%
  if(wsMembersMapList.size() == 0)  {
    bListedPerson =true;
%>
    <tr class=odd>
      <td style="text-align:center" class="noresult" colspan="3" ><emxUtil:i18n localize="i18nId"> emxTeamCentral.TeamMemberSearch.NoMembers</emxUtil:i18n></td>
    </tr>

<%
  } else {
    if(routeScopeObj == null) {
      routeScopeObj = DomainObject.newInstance(context, objectId);
    }
%>
    <!-- //XSSOK -->
    <framework:mapListItr mapList="<%=wsMembersMapList%>" mapName="wsMembersMap">
<%

    sPersonId                     = (String)wsMembersMap.get("id");
    sType                         = (String)wsMembersMap.get(strTitleType);

    if(sType != null && sType.equals(DomainConstants.TYPE_PERSON))
    {
      com.matrixone.apps.common.Person personObject = new com.matrixone.apps.common.Person(sPersonId);
      StringList routeIdList        = personObject.getInfoList(context,"to["+relRouteNode+"].from.id");

      if(routeIdList == null){
        routeIdList                 = new StringList();
      }

    boolean personInEvent = false;
    if(personEventList.contains(sPersonId)){
      personInEvent = true;
    }

    boolean bHasRole = true;
    bListedPerson               = true;
    sPersonId                   = "Person~" +  sPersonId;
    sPersonLastFirstName          = (String)wsMembersMap.get(strLastFirstName);

%>
    <tr class='<framework:swap id ="1" />'>
      <td align="center">
        <table border="0">
          <tr>
<%
           if(routeIdList.contains(sRouteId) || routeMemList.contains(sPersonId) || (flag != null && "pushSubscription".equals(flag) && personInEvent)) {
%>
           <td align="center">
              <img border="0" src="images/iconCheckoffdisabled.gif" align="center" />
           </td>
<%
           }else{
%>
           <td align="center">
             <!-- //XSSOK -->
             <input type="checkbox" name="chkItem1" id="chkItem1" value="<%=sPersonId%>" onclick="updateCheck()" />
           </td>
<%
           }

sType = TeamUtil.i18NUserType(request, sType);
%>
          </tr>
        </table>
      </td>
      <!-- //XSSOK -->
      <td><img src="images/iconSmallPerson.gif" name="imagePerson" value="imgPerson" /><%=sPersonLastFirstName%></td>
      <!-- //XSSOK -->
      <td><%=sType%></td>
    </tr>


<%
}else{
    String roleName = (String)wsMembersMap.get("LastFirstName");
    sType = TeamUtil.i18NUserType(request, sType);
    String checkBoxId = "Role~" + roleName;
%>

    <tr class='<framework:swap id ="1" />'>
          <td width="5%" style="text-align:center">
              <table border="0">
              <tr>
<%
  if(routeRoleList.contains(checkBoxId) || routeWizRoleList.contains(checkBoxId)) {
%>
                <td align="center">
                    <img border="0" src="images/iconCheckoffdisabled.gif" align="center" />
                </td>
<%
}else{
%>
               <td align="center">
                 <!-- //XSSOK -->
                 <input type="checkbox" name="chkItem1" id="chkItem1" value="<%=checkBoxId%>" onclick="updateCheck()" />
               </td>
<%
}
%>
              </tr>
            </table>
          </td>
          <td><img src="../common/images/iconSmallRole.gif" name="imageRole" value="imgRole" /><%=i18nNow.getRoleI18NString(roleName,request.getHeader("Accept-Language"))%></td>
        <!-- //XSSOK -->
        <td><%=sType%></td>
    </tr>
 <%
 }
 %>

    </framework:mapListItr>
<%
}
  if(!bListedPerson) {
%>
    <tr class=odd>
      <td style="text-align:center" class="noresult" colspan="3" ><emxUtil:i18n localize="i18nId"> emxTeamCentral.TeamMemberSearch.NoMembers</emxUtil:i18n></td>
    </tr>

<%
  }
%>
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>



