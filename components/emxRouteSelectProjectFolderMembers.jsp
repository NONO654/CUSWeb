<%--  emxRouteSelectProjectFolderMembers.jsp

  Displays the permissions for the selected folder for each member.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteSelectProjectFolderMembers.jsp.rca 1.11 Wed Oct 22 16:18:36 2008 przemek Experimental przemek $;
--%>

<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxPaginationInclude.inc"%>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%

  boolean isProgramInstalled = false;
  Class clsProjectSpace=null;
try{
        clsProjectSpace = Class.forName("com.matrixone.apps.program.ProjectSpace");
        isProgramInstalled = true;
}catch (Exception ex){}

  com.matrixone.apps.common.WorkspaceVault workspaceVault = (com.matrixone.apps.common.WorkspaceVault) DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);
  com.matrixone.apps.common.Route route = (com.matrixone.apps.common.Route) DomainObject.newInstance(context, DomainConstants.TYPE_ROUTE);
 com.matrixone.apps.common.Person person = null;

  String attribute_FolderAccess = PropertyUtil.getSchemaProperty(context, "attribute_FolderAccess");

  String languageStr = request.getHeader("Accept-Language");

  String objectId          = emxGetParameter(request, "objectId");
  String topParentHolderId = emxGetParameter(request, "topParentHolderId");
  String folderAccess      = emxGetParameter(request, "FOLDER_ACCESS");

  String memberType = emxGetParameter(request,"memberType");
  String routeId = emxGetParameter(request,"routeId");

  String keyValue = emxGetParameter(request, "keyValue");
  
  StringList  existingList = new StringList();
  if(routeId!=null && !routeId.equals("") )
  {
	Route routeObj = (Route)DomainObject.newInstance(context, DomainConstants.TYPE_ROUTE,
                                                               DomainConstants.TEAM);
	MapList existingRoleorGroup = new MapList();
	routeObj.setId(routeId);
    SelectList selectPersonRelStmts = new SelectList();
    selectPersonRelStmts.addElement(routeObj.SELECT_ROUTE_TASK_USER);
    existingRoleorGroup = routeObj.getAssignedRoles(context, null, selectPersonRelStmts, false);
	
    if( existingRoleorGroup != null && existingRoleorGroup.size() > 0)
    {
      Iterator roleItr = existingRoleorGroup.iterator();
      while(roleItr.hasNext())
      {
         Map roleMap  = (Map)roleItr.next();
         String roleName = (String) roleMap.get(routeObj.SELECT_ROUTE_TASK_USER);
         roleName  = PropertyUtil.getSchemaProperty(context, roleName);
		 existingList.addElement(roleName);
      }
    }
}
  else //if(keyValue!=null)
  {
   MapList memberMapList = null;
   try{
  	  memberMapList = (MapList)formBean.getElementValue("routeMemberMapList");
   }catch(Exception mml){
      memberMapList = new MapList();
   }

   if(memberMapList != null && memberMapList.size() >0) {
              Iterator mapMemberItr = memberMapList.iterator();
              while(mapMemberItr.hasNext()) {
                  Map mapMember     = (Map)mapMemberItr.next();
                  String mType  = (String)mapMember.get(DomainConstants.SELECT_TYPE);
		          String sName = (String)mapMember.get("name");
	              existingList.add(sName.trim());
              }
      }
  }


  String sRoleList        = emxGetParameter(request, "roleList");
  if (sRoleList == null){
    sRoleList = "";
  }

  String sGroupList        = emxGetParameter(request, "groupList");
  if (sGroupList == null){
    sGroupList = "";
  }

  String self = context.getUser();


  HashMap i18nRoleMap = new HashMap();
  HashMap i18nGroupMap = new HashMap();
  Locale locale = context.getLocale();
  String i18nGroup = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", locale, "emxComponents.Common.Group");//i18nStringNow("emxComponents.Common.Group", languageStr);
  String i18nRole = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", locale, "emxComponents.Common.Role");//i18nStringNow("emxComponents.Common.Role", languageStr);
  String i18nPerson   = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", locale, "emxComponents.PersonDialog.Person");//i18nStringNow("emxComponents.PersonDialog.Person", languageStr);

  //Create a vaultMemberList containing only projectMembers that are also vaultMembers
  MapList vaultMemberList = null;

  if (emxPage.isNewQuery()) {

    workspaceVault.setId(objectId);
    workspaceVault.setContentRelationshipType(workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);
    HashMap memberMap =(HashMap) workspaceVault.getUserPermissions(context);
    StringList roleList = new StringList();
    StringList groupList = new StringList();


    StringList projectMemberSelects = new StringList(4);
    projectMemberSelects.add(person.SELECT_TYPE);
    projectMemberSelects.add(person.SELECT_NAME);
    projectMemberSelects.add(person.SELECT_FIRST_NAME);
    projectMemberSelects.add(person.SELECT_LAST_NAME);
    projectMemberSelects.add(person.SELECT_COMPANY_NAME);
    projectMemberSelects.add(person.SELECT_ID);

    MapList projectMemberList = new MapList();

    if (topParentHolderId != null && !"null".equals(topParentHolderId))
    {
        //Need to get a MapList of all projectMembers for the project
        //project.setId(topParentHolderId);
        Object objProject = null;
        if(isProgramInstalled){
                Method setId=null;
                objProject = clsProjectSpace.newInstance();
                Class[] clsArg = new Class[1];
                clsArg[0]  = String.class;
                setId = clsProjectSpace.getMethod("setId",clsArg);
                setId.invoke(objProject,new Object[] {topParentHolderId});
        }

        String typeVariable = "";
        //Determine the type of parent: it may be a route
        try {
                if(isProgramInstalled){
                        Method getInfo=null;
                        Class[] clsArg = new Class[2];
                        clsArg[0]  = Context.class;
                        clsArg[1]  = String.class;
                        getInfo = clsProjectSpace.getMethod("getInfo",clsArg);

                        Object[] arguments = new Object[2];
                        arguments[0]=context;
                        arguments[1]=DomainObject.SELECT_TYPE;
                        typeVariable = (String)getInfo.invoke(objProject,arguments);
                }
          //typeVariable = project.getInfo(context, project.SELECT_TYPE);
        } catch (Exception e) {
          // do nothing - person has no access to top parent
        }

        if("".equals(typeVariable) || typeVariable.equals(DomainConstants.TYPE_BUSINESS_GOAL)) {
            //Business Goals doesn't have members
        } else if(typeVariable.equals(route.TYPE_ROUTE)) {
            route.setId(topParentHolderId);
            projectMemberList = route.getRouteMembers(context, projectMemberSelects, null,false);
        } else {
                
                if(isProgramInstalled){
                        Method getMembers=null;
                        Class[] clsArg = new Class[6];
                        clsArg[0]  = Context.class;
                        clsArg[1]  = StringList.class;
                        clsArg[2]  = StringList.class;
                        clsArg[3]  = String.class;
                        clsArg[4]  = String.class;
                        clsArg[5]  = boolean.class;
                        getMembers = clsProjectSpace.getMethod("getMembers",clsArg);

                        Object[] arguments = new Object[6];
                        arguments[0]=context;
                        arguments[1]=projectMemberSelects;
                        arguments[2]=null;
                        arguments[3]=null;
                        arguments[4]=null;
                        arguments[5]=Boolean.valueOf(true);
                        projectMemberList = (MapList)getMembers.invoke(objProject,arguments);
                }
                //projectMemberList = project.getMembers(context, projectMemberSelects, null, null, null, true);
        }
    }

    vaultMemberList = new MapList();
    Iterator projectMemberItr = projectMemberList.iterator();
    //cycle through each projectMember...
    while (projectMemberItr.hasNext()) {
      Map projectMemberMap = (Map) projectMemberItr.next();
      projectMemberMap.remove(DomainObject.SELECT_LEVEL);

       String userType  = (String) projectMemberMap.get(person.SELECT_TYPE);
		
	   if(userType.equalsIgnoreCase(memberType))
		{

      String lastName = (String) projectMemberMap.get(person.SELECT_LAST_NAME);
      String firstName = (String) projectMemberMap.get(person.SELECT_FIRST_NAME);
      String fullName = lastName + ", " + firstName;
      //260156
      if (lastName == null && firstName == null) {
          fullName = (String) projectMemberMap.get(person.SELECT_NAME);
      }
      projectMemberMap.put("displayName", fullName);
      //If projectMember is also a vaultMember, then
      if (memberMap.containsKey(projectMemberMap.get(person.SELECT_NAME)))
      {
		  if(userType.equalsIgnoreCase("Role") || userType.equalsIgnoreCase("Group"))
		  {
			  projectMemberMap.put("vaultAccess", "Read");
		  }
		  else
		  {
        //add users vault access to Map
	        projectMemberMap.put("vaultAccess", memberMap.get(projectMemberMap.get(person.SELECT_NAME)));
		  }
		projectMemberMap.put("id", projectMemberMap.get(person.SELECT_ID));
        //add them to vaultMemberList
		vaultMemberList.add(projectMemberMap);	
        memberMap.remove(projectMemberMap.get(person.SELECT_NAME));
     }

      if(userType != null && userType.equals("Role")) {
        roleList.add((String) projectMemberMap.get(person.SELECT_NAME));
      }
      if(userType != null && userType.equals("Group")) {
        groupList.add((String) projectMemberMap.get(person.SELECT_NAME));
      }
		}
    }
    
   // i18nRoleMap   = getTranslatedList(roleList, "Role", context.getLocale());
   // i18nGroupMap  = getTranslatedList(groupList, "Group", context.getLocale());


    //the following grants are not project users, but should still be displayed.
    java.util.Set set = memberMap.keySet();
    Iterator itr = set.iterator();
    while (itr.hasNext())
    {
      String user = (String) itr.next();
	  String access = (String) memberMap.get(user);
      Map map = new HashMap();

      String output = MqlUtil.mqlCommand(context, "print user \"" + user + "\" select isaperson isarole isagroup dump |");
      if ("TRUE|FALSE|FALSE".equalsIgnoreCase(output) && memberType.equalsIgnoreCase("person")) {
        //person
	  map.put(person.SELECT_NAME, user);
      map.put("displayName", user);
      map.put("vaultAccess", access);
	  map.put(person.SELECT_TYPE, "Person");
      com.matrixone.apps.common.Person tempPerson =
      com.matrixone.apps.common.Person.getPerson(context, user);
      String companyName = tempPerson.getInfo(context, person.SELECT_COMPANY_NAME);
      map.put(person.SELECT_COMPANY_NAME, companyName);
	  vaultMemberList.add(map);
      } else {
        map.put(person.SELECT_COMPANY_NAME, "");
        if ("FALSE|TRUE|FALSE".equalsIgnoreCase(output) && memberType.equalsIgnoreCase("role")) {
          //role
		  	    map.put(person.SELECT_NAME, user);
			    map.put("displayName", user);
//		        map.put("vaultAccess", access);
		        map.put("vaultAccess", "Read");
	            map.put(person.SELECT_TYPE, "Role");
				vaultMemberList.add(map);
        } else if ("FALSE|FALSE|TRUE".equalsIgnoreCase(output) && memberType.equalsIgnoreCase("group")) {
          //group
  		
		      map.put(person.SELECT_NAME, user);
		      map.put("displayName", user);
//		      map.put("vaultAccess", access);
	          map.put("vaultAccess", "Read");
	          map.put(person.SELECT_TYPE, "Group");
			  vaultMemberList.add(map);
        } /*else {
          //assoc
		  map.put(person.SELECT_TYPE, "Association");
		  vaultMemberList.add(map);
        }*/
      }
      
    }
    emxPage.getTable().setObjects(vaultMemberList);
    // this is for sorting the list.  Use it if your want the page to be initialy sorted.
    emxPage.getTable().setDefaultSortValues(person.SELECT_NAME, "ascending", "string");
  }
  vaultMemberList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());

  StringList selectedRoles = new StringList();
  StringList selectedGroups = new StringList();
  Iterator itr = vaultMemberList.iterator();
  while (itr.hasNext())
  {
    Map map = (Map) itr.next();
    String type = (String) map.get(person.SELECT_TYPE);
    if ("Group".equals(type))
    {	
      selectedGroups.add((String)map.get(person.SELECT_NAME));
    } else if ("Role".equals(type)) {		
      selectedRoles.add((String)map.get(person.SELECT_NAME));
    }
  }

%>

    <framework:sortInit
      defaultSortKey="displayName"
      defaultSortType="string"
      mapList="<%= vaultMemberList %>"
      params='<%= "&objectId=" + objectId %>'
      resourceBundle="emxComponentsStringResource"
      ascendText="emxComponents.Common.SortAscending"
      descendText="emxComponents.Common.SortDescending"/>

    <form name="DisplayAccessPermission" method="post">
      <input type="hidden" name="topVaultHolderId" value="<xss:encodeForHTMLAttribute><%= topParentHolderId %></xss:encodeForHTMLAttribute>">
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectId %></xss:encodeForHTMLAttribute>">
      <input type="hidden" name="defaultVaultAccess" value="None">
	  <input type="hidden" name="roleList" value="<xss:encodeForHTMLAttribute><%=sRoleList%></xss:encodeForHTMLAttribute>">
	  <input type="hidden" name="groupList" value="<xss:encodeForHTMLAttribute><%=sGroupList%></xss:encodeForHTMLAttribute>">


 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

        <tr>
          <framework:ifExpr expr='<%= "none".equals(folderAccess) == false %>'>
            <th width="1%">
              <input type="checkbox" name="selectAll" onClick="checkAll(this,'chkItem1');"/>
            </th>
          </framework:ifExpr>
          <th nowrap="nowrap">
            <framework:sortColumnHeader
              title="emxComponents.Common.Name"
              sortKey="displayName"
              sortType="string"/>
          </th>
          <th nowrap="nowrap">
            <framework:sortColumnHeader
              title="emxComponents.Common.Type"
              sortKey="<%= person.SELECT_TYPE %>"
              sortType="string"/>
          </th>
          <th nowrap="nowrap">
            <framework:sortColumnHeader
              title="emxComponents.Common.Organization"
              sortKey="<%= person.SELECT_COMPANY_NAME %>"
              sortType="string"/>
          </th>
          <th nowrap="nowrap">
            <framework:sortColumnHeader
              title="emxComponents.Common.Access"
              sortKey="vaultAccess"
              sortType="string"/>
          </th>
        </tr>
        <!-- end table heading -->

        <framework:ifExpr expr='<%= vaultMemberList.size() <= 0 %>'>
          <tr>
            <td align="center" colspan="13" class="error">
              <emxUtil:i18n localize="i18nId">emxComponents.Common.NoAssignedFolderMembers</emxUtil:i18n>
            </td>
          </tr>
        </framework:ifExpr>

        <!-- begin displaying table data -->
        <framework:ifExpr expr='<%= vaultMemberList.size() > 0 %>'>
          <framework:mapListItr mapList="<%= vaultMemberList %>" mapName="memberDisplayMap">
<%
			  String userType  = (String) memberDisplayMap.get(person.SELECT_TYPE);
              String i18nUserType = i18nPerson;
              String i18nName = "";
              if(userType != null && userType.equals("Role")) {
            	String roleName =  (String) memberDisplayMap.get("name");
            	i18nName = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, "emxFramework.Role."+roleName.replace(" ","_"));
                //i18nName = (String) i18nRoleMap.get((String) memberDisplayMap.get("name"));
                i18nUserType = i18nRole;
				memberDisplayMap.put("id",i18nName);
              }
              if(userType != null && userType.equals("Group")) {
                String group = (String) memberDisplayMap.get("name");
                i18nName = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, "emxFramework.Group."+group.replace(" ","_"));
                //i18nName = (String) i18nGroupMap.get(group);
                i18nUserType = i18nGroup;
				memberDisplayMap.put("id",i18nName);
              }

		    String relRouteNode           = DomainObject.RELATIONSHIP_ROUTE_NODE;
			StringList routeIdList = new StringList();
			String sPersonId = "";
			 if(userType != null && userType.equals("Person")) {
			sPersonId = (String)memberDisplayMap.get("id");
			com.matrixone.apps.common.Person personObject = new com.matrixone.apps.common.Person(sPersonId);
			routeIdList        = personObject.getInfoList(context,"to["+relRouteNode+"].from.id");

			if(routeIdList == null){
		        routeIdList                 = new StringList();
		      }
			
			 }
			 String temp = (String)memberDisplayMap.get(person.SELECT_NAME);
			 temp = temp.trim();
%>
<%
	if(!(routeIdList.contains(routeId) || existingList.contains(temp))) {
%>
             <tr class='<framework:swap id="1"/>'>
              <framework:ifExpr expr='<%= "none".equals(folderAccess) == false %>'>
                <td>    
				<input type="checkbox" name="chkItem1" id="chkItem1" value="<%= (String)memberDisplayMap.get("id") %>">
				</td>
              </framework:ifExpr>
              <td nowrap="nowrap">
              <framework:ifExpr expr='<%= userType.equals("Role") || userType.equals("Group")%>'>
                <%= i18nName %>
              </framework:ifExpr>
              <framework:ifExpr expr='<%= userType.equals(DomainConstants.TYPE_PERSON) %>'>
               <%= memberDisplayMap.get(person.SELECT_NAME) %>
              </framework:ifExpr>
              </td>
              <td nowrap="nowrap">
                <%= i18nUserType %>&nbsp;
              </td>

              <td nowrap="nowrap">
                <%= memberDisplayMap.get(person.SELECT_COMPANY_NAME) != null ? memberDisplayMap.get(person.SELECT_COMPANY_NAME) : "" %>&nbsp;
              </td>
              <td nowrap="nowrap">
                <%=getRangeI18NString(attribute_FolderAccess,
                      (String)memberDisplayMap.get("vaultAccess"), languageStr)%>

              </td>
            </tr>
<%}%>

          </framework:mapListItr>
        </framework:ifExpr>

      </table>
    </form>
  </body>

  <script language="javascript" type="text/javaScript">
    //<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers

    if(parent.frames[0].document.progress) {
      parent.frames[0].document.progress.src="../common/images/utilSpacer.gif";
    }

    function checkAll (allbox, chkprefix) {
      form = allbox.form;
      max = form.elements.length;
      for (var i=0; i<max; i++) {
        fieldname = form.elements[i].name;
        if (fieldname.substring(0,chkprefix.length) == chkprefix) {
          form.elements[i].checked = allbox.checked;
        }
      }
    }

 function submitForm() {

<%if(memberType.equals("Role") || memberType.equals("Group") )
		 {
	%>
 if (document.DisplayAccessPermission.roleList.value == ""){
      document.DisplayAccessPermission.roleList.value = ";";
    }

    for (var varj = 0; varj < document.DisplayAccessPermission.elements.length; varj++) {
      if (document.DisplayAccessPermission.elements[varj].type == "checkbox") {
        chkbxFlag = "true";
        if (document.DisplayAccessPermission.elements[varj].checked ){
          checkedFlag = "true";
          if (document.DisplayAccessPermission.elements[varj].name.indexOf('chkItem1') > -1) {
            if (document.DisplayAccessPermission.roleList.value.indexOf(";"+document.DisplayAccessPermission.elements[varj].value+";") == -1) {
		          document.DisplayAccessPermission.roleList.value=document.DisplayAccessPermission.roleList.value+document.DisplayAccessPermission.elements[varj].value+";";
            }
          }
        }
      }
    }
<%
	}
%>
   var checkedFlag = "false";
    for( var i = 0; i < document.DisplayAccessPermission.elements.length; i++ ){
      if (document.DisplayAccessPermission.elements[i].type == "checkbox" &&
        document.DisplayAccessPermission.elements[i].checked &&
        document.DisplayAccessPermission.elements[i].name == "chkItem1" ){
        checkedFlag = "true";
        break;
      }
    }
    if (checkedFlag == "false") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.PeopleSummary.SelectOneMember</emxUtil:i18nScript>");
      return;
    }else {
      //set the member type as "Role" in the URL
      //will be used in the processing page to determine whether the member
      //added is a Person, Group or Role.
		   document.DisplayAccessPermission.action= "emxRouteSelectProjectMembersProcess.jsp?memberType=<%=XSSUtil.encodeForURL(context,memberType)%>&action=add&routeId=<%=XSSUtil.encodeForURL(context,routeId)%>&projectId=<%=XSSUtil.encodeForURL(context,objectId)%>&roleList=" + document.DisplayAccessPermission.roleList.value+"&groupList=" + document.DisplayAccessPermission.groupList.value;
		  document.DisplayAccessPermission.submit();
    }
  }

  function closeWindow() {
    window.closeWindow();
    return;
  }

    //Stop hiding here -->
    //]]>
  </script>
</html>

