<%--  emxLifecycleTaskAssigneeSearchResults.jsp  -   Search Result Page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleTaskAssigneeSearchResults.jsp.rca 1.6.3.2 Wed Oct 22 15:48:37 2008 przemek Experimental przemek $
--%>
<%@page import="com.matrixone.apps.domain.util.RoleUtil"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../components/emxComponentsDesignTopInclude.inc"%>
<%@include file = "../components/emxComponentsJavaScript.js"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%
  String strSearchType    = emxGetParameter(request,"searchType");
  String objectId         = emxGetParameter(request,"objectId");
  String strHidePersonSearch = emxGetParameter(request,"hidePersonSearch");
  String strHideRoleSearch   = emxGetParameter(request,"hideRoleSearch");
  String strHideGroupSearch  = emxGetParameter(request,"hideGroupSearch");
  
  String lstr= request.getHeader("Accept-Language");

  String targetSearchPage = "emxLifecycleTaskReassignCommentsFS.jsp";

  if ("Role".equals(strSearchType)) {
%>

<%!
	RoleList getChildRoles(Context context, Role matrixRole) throws Exception {
  	RoleList roleList = new RoleList();
  	matrixRole.open(context);
  		if(matrixRole.hasChildren()) {
      roleList.addAll(matrixRole.getChildren());
      RoleItr roleItr = new RoleItr(roleList);
      		while (roleItr.next()) {
         Role childRole = (Role)roleItr.obj();
         roleList.addAll(getChildRoles(context, childRole));
      }

  	}
  	matrixRole.close(context);
  	return roleList;
	}

	boolean isParentCompanyAHostCompany(Context context, String strOrganizationId) throws Exception {
	    String strCompanyType             = DomainObject.TYPE_COMPANY;
	    String strBusinessUnitType        = DomainObject.TYPE_BUSINESS_UNIT;
	    String strDepartmentType          = DomainObject.TYPE_DEPARTMENT;
	    String strDivisionRel             = DomainObject.RELATIONSHIP_DIVISION;
	    String strCompanyDepRel           = DomainObject.RELATIONSHIP_COMPANY_DEPARTMENT;
	    String strSubsidiaryRel           = DomainObject.RELATIONSHIP_SUBSIDIARY;

	    DomainObject busOrganization = new DomainObject(strOrganizationId);
	    String sOrgTypeName = busOrganization.getInfo(context,DomainObject.SELECT_TYPE);

	    while(!sOrgTypeName.equals(strCompanyType) && !"".equals(sOrgTypeName)) {
	        if(sOrgTypeName.equals(strBusinessUnitType)) {
	            sOrgTypeName        = busOrganization.getInfo(context,"to[" + strDivisionRel + "].from.type");
	            strOrganizationId   = busOrganization.getInfo(context,"to[" + strDivisionRel + "].from.id");
	            busOrganization     = new DomainObject(strOrganizationId);
	        } else if (sOrgTypeName.equals(strDepartmentType)) {
	            sOrgTypeName        = busOrganization.getInfo(context,"to[" + strCompanyDepRel + "].from.type");
	            strOrganizationId   = busOrganization.getInfo(context,"to[" + strCompanyDepRel + "].from.id");
	            busOrganization     = new DomainObject(strOrganizationId);
	        } else {
	            sOrgTypeName = "";
	        }
	    }

	    String strHostCompId = Company.getHostCompany(context);
	    if(strHostCompId.equals(strOrganizationId)) {
	        return true;
	    }
	    while(strCompanyType.equals(sOrgTypeName)) {
	        sOrgTypeName = busOrganization.getInfo(context,"to[" + strSubsidiaryRel + "].from.type");
	        strOrganizationId = busOrganization.getInfo(context,"to[" + strSubsidiaryRel + "].from.id");
	        if(strHostCompId.equals(strOrganizationId)) {
	            return true;
	        }
	        busOrganization = new DomainObject(strOrganizationId);
	    }

	    return false;
	}
%>
<%}
%>
<head>
<script language="JavaScript">

 function closeWindow() {
        window.closeWindow();
        return;
      }

  //Function for the new search button
  function newSearch() {
      var  sNewSearchPage = "emxLifecycleTaskAssigneeSearchFS.jsp";
      parent.location= sNewSearchPage + '?objectId=<%=XSSUtil.encodeForURL(context, objectId)%> + &hidePersonSearch=<%=XSSUtil.encodeForURL(context, strHidePersonSearch)%>&hideRoleSearch=<%=XSSUtil.encodeForURL(context, strHideRoleSearch)%>&hideGroupSearch=<%=XSSUtil.encodeForURL(context, strHideGroupSearch)%>';
  }

  //Function called when done clicked
  	function selectDone() {
  	// Find the getWindowOpener() window to return the result
        var objOpenerWnd = getTopWindow().getWindowOpener();
<% 
		if ("Person".equals(strSearchType)) {  %>
	    var cnt = 0;
	    var bool = false;
	    	for (var i = 0; i<document.searchResultForm.elements.length; i++) {
	       		if(document.searchResultForm.elements[i].checked == true) {
	         bool = true;
	         cnt = i;
	         break;
	       }
	    }

	    if(!bool){

	       alert("<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.UserChooser.Message", context.getLocale())%>");
	        
	    	} else {
	         var selCnt = document.searchResultForm.elements[cnt].value;
	         var selPerName = eval('document.searchResultForm.selPersonName' + selCnt + '.value');
	         var selPerId = eval('document.searchResultForm.selPersonId' + selCnt + '.value');
	         var memberType = eval('document.searchResultForm.memberType.value');

	         if (objOpenerWnd) {
	         	if (objOpenerWnd.submitNewAssignee) {
	         		objOpenerWnd.submitNewAssignee(window.getTopWindow(), selPerName, memberType);
	         	}
	         }

		 }

	<%} else if ("Role".equals(strSearchType) || "Group".equals(strSearchType)) {%>

	    var checkedFlag = "false";
        var chkbxFlag = "false";
        var originalRole = "";
        var count = 0;
        for (var varj = 0; varj < document.searchResultForm.elements.length; varj++) {
          if (document.searchResultForm.elements[varj].type == "radio") {
            chkbxFlag = "true";
            if (document.searchResultForm.elements[varj].checked ){
              checkedFlag = "true";
              originalRole = document.searchResultForm.elements[varj].value;

            }
            count++;
          }
        }

       if ((checkedFlag == "false") && (chkbxFlag == "true")) {
          alert("<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.RoleMessage", context.getLocale())%>");
          return;
        } else {
            var memberType = eval('document.searchResultForm.memberType.value');

            if (objOpenerWnd) {
                if (objOpenerWnd.submitNewAssignee) {
                    objOpenerWnd.submitNewAssignee(window.getTopWindow(), originalRole, memberType);
                }
            }
       }
<%  }%>
}


</script>
</head>

<body>

<%@ include file = "../components/emxComponentsVisiblePageInclude.inc"%>
<form name="searchResultForm" method="post" action="emxLifecycleTaskReassignCommentsFS.jsp">

<%
if ("Person".equals(strSearchType)) {

		  String typePattern = PropertyUtil.getSchemaProperty(context,"type_Person");
		  String vaultPattern = "*";
		  SelectList selects = new SelectList(4);
		  MapList cached = null;
		  String whereClause = null;

		  String strUserName    = emxGetParameter(request,"UserName");
		  String strFirstName   = emxGetParameter(request,"FirstName");
		  String strLastName    = emxGetParameter(request,"LastName");
		  String strCompanyName = emxGetParameter(request,"companyName");

		  if (strCompanyName == null) {
			  strCompanyName="";
		  }

		  if (strUserName.equals("*")){
		    strUserName = "**";
		  }
		  if (strFirstName.equals("*")){
		    strFirstName = "**";
		  }
		  if (strLastName.equals("*")){
		    strLastName = "**";
		  }
		  if (strCompanyName.equals("*")){
		    strCompanyName = "**";
		  }

		  String firstname = PropertyUtil.getSchemaProperty(context,"attribute_FirstName");
		  String lastname = PropertyUtil.getSchemaProperty(context,"attribute_LastName");
		  String employeerel = PropertyUtil.getSchemaProperty(context,"relationship_Employee");
		  String sPersonActiveState = PropertyUtil.getSchemaProperty(context,"policy", DomainConstants.POLICY_PERSON, "state_Active");

		  whereClause = "(" + "current" + " ~= " + "\"" + sPersonActiveState + "\")";
		  whereClause += " && " + "(\"" + "attribute["+firstname+"]" + "\"" + " ~~ " + "\"" + strFirstName + "\")";
		  whereClause += " && " + "(\"" + "attribute["+lastname+"]" + "\"" + " ~~ " + "\"" + strLastName + "\")";
		  whereClause += " && " + "(\"" + "to["+employeerel+"].from.id" + "\"" + " ~~ " + "\"" + strCompanyName + "\")";

		  selects.addAttribute(firstname);
		  selects.addAttribute(lastname);
		  selects.addElement("name");
		  selects.addElement("id");
		  selects.addElement("to["+employeerel+"].from");

		  MapList mapList = DomainObject.findObjects(context,typePattern,
																				 strUserName,null,null,
																				 vaultPattern,whereClause,
																				 false,selects);
		  String queryString = request.getQueryString();
		  MapList personMapList = null;
		  String  attrFirstName = "attribute["+firstname+"]";
		  String  attrLastName  = "attribute["+lastname+"]";
		  String  relEmployee   = "to["+employeerel+"].from";
		  personMapList = mapList;
		  /*if (emxPage.isNewQuery()) {
		    emxPage.getTable().setObjects(personMapList);
		    emxPage.getTable().setSelects(selects);
		  }*/
		  int i=0;
		  //personMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
%>
		    <!-- //XSSOK -->
			<framework:sortInit defaultSortKey="<%= DomainObject.SELECT_NAME %>" defaultSortType="string" resourceBundle="emxFrameworkStringResource" mapList="<%= personMapList %>" params="<%= XSSUtil.encodeForHTML(context, queryString) %>" ascendText="emxFramework.Common.SortAscending" descendText="emxFramework.Common.SortDescending" />

	<table class="list">
		    <!-- Table Column Headers -->
		     <tr>
		      <th>
		          <!-- <input type="checkbox" name="checkAll" id="checkAll" onclick="allSelected('searchResultForm')" />-->
		      </th>
		      <th class="thheading" nowrap="nowrap">
		        <!-- //XSSOK -->
				<framework:sortColumnHeader title="emxFramework.Common.Name" sortKey="<%=attrLastName%>" sortType="string" anchorClass="sortMenuItem" />
		      </th>
		      <th class="thheading" nowrap="nowrap">
		        <framework:sortColumnHeader
		            title="emxFramework.Common.LoginName"
		            sortKey="<%=DomainObject.SELECT_NAME %>"
		            sortType="string"
		            anchorClass="sortMenuItem" />
		      </th>
		      <th class="thheading" nowrap="nowrap">
		        <!-- //XSSOK -->
				<framework:sortColumnHeader title="emxFramework.Common.CompanyName" sortKey="<%=relEmployee%>" sortType="string" anchorClass="sortMenuItem" />
		      </th>
		    </tr>

		    <%--  //set the member type as "Person"
		          //will be used in the processing page to determine whether the member
		          //added is a Person, Group or Role. --%>
		    <input type="hidden" name="memberType" value="Person" />
		   <!-- //XSSOK -->
		   <framework:mapListItr mapList="<%=personMapList%>" mapName="personMap">
		   <%
		    String sPersonId        = (String) personMap.get("id");
		    com.matrixone.apps.common.Person personObject = new com.matrixone.apps.common.Person(sPersonId);
			String personName= (String)personMap.get("name");
			String hidden = MqlUtil.mqlCommand(context, "print person $1 select hidden dump", true, personName);
		       if(!"TRUE".equalsIgnoreCase(hidden))
		       {
		    %>
		    <tr class='<framework:swap id="even"/>'>
		      <td width="5%"><input type="radio" name="selectedPerson" value="<%=i%>" /></td>
		      <!-- //XSSOK -->
			  <input type='hidden' name='selPersonName<%=i%>' value='<%=personMap.get("name")%>' />
		      <input type='hidden' name='selPersonId<%=i%>' value='<%=XSSUtil.encodeForHTMLAttribute(context, (String) personMap.get("id"))%>' />
			<%
				   String fullName = personMap.get(attrLastName) + " , " + personMap.get(attrFirstName);
			%>
		    <td width="30%" ><img src="../common/images/iconSmallPerson.gif" border="0" />&nbsp;<%=fullName%></a></b></td>
		    <td><%= XSSUtil.encodeForHTML(context, (String) personMap.get(DomainObject.SELECT_NAME)) %></td>
		    <td><%= XSSUtil.encodeForHTML(context, (String) personMap.get(relEmployee)) %></td>
		    </tr>
			<%}
				i++;
			%>
		    </framework:mapListItr>
			<%
		if (personMapList.size() == 0) {
			%>
		        <tr class="odd">
		          <td class="noresult"  align="center" colspan="4"><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxFramework.SelectPerson.NoPersonsFound", "emxFrameworkStringResource", request.getHeader("Accept-Language")))%></td>
		        </tr>
			<%
			   }
			%>
		  </table>
  <%}else if ("Role".equals(strSearchType)) {


      String sNamePattern     = emxGetParameter(request,"txtName");
      String sTopChecked      = emxGetParameter(request,"chkTopLevel");
      String sSubChecked      = emxGetParameter(request,"chkSubLevel");
      String languageStr        = request.getHeader("Accept-Language");
      if(objectId == null ){
        objectId = "";
      }
    %>
    <%@include file = "../emxUICommonHeaderEndInclude.inc" %>
    <%
      String strProjectId       = objectId;
      BusinessObject boProject  = new BusinessObject(strProjectId);
      Role role         = new Role();
      RoleItr roleItr   = null;
      String classname  = "odd";
      String sAll       = "*";
      String sName      = "";
      String sType      = "Role";
      StringList topRoleNameList  = new StringList();
      boolean isFound   = false;
      MapList templateMapList  =  new MapList();
      MapList  constructedList =  new MapList();
      Pattern pattern = null;

      boolean isPrivateExchange = true;
      String isSetupAsPrivateExchange = "true";
      try {
        isSetupAsPrivateExchange = EnoviaResourceBundle.getProperty(context, "emxComponents.isSetupAsPrivateExchange");
      } catch(Exception e) {}

      if(isSetupAsPrivateExchange != null && "false".equalsIgnoreCase(isSetupAsPrivateExchange.trim()) ) {
          isPrivateExchange = false;
      }


      if(sNamePattern != null) {
        pattern = new Pattern(sNamePattern);
      } else {
        sNamePattern = sAll;
        pattern = new Pattern(sAll);
      }

      if (sSubChecked != null) {
        if (sTopChecked == null) {
          roleItr = new RoleItr(role.getTopLevelRoles(context));
          while(roleItr.next()) {
            topRoleNameList.add(roleItr.obj().getName());
          }
        }
        RoleList roleList = role.getRoles(context);
        roleList.sort();
        roleItr = new RoleItr(roleList);
      } else {
        if (sTopChecked != null) {
          RoleList roleList = role.getTopLevelRoles(context);
          roleList.sort();
          roleItr = new RoleItr(roleList);
        } else {
          RoleList roleList = role.getRoles(context);
          roleList.sort();
          roleItr = new RoleItr(roleList);
        }
      }
      while (roleItr.next()) {
            String sRole  = roleItr.obj().getName();
            String tranVal= i18nNow.getAdminI18NString("Role",sRole,request.getHeader("Accept-Language"));
        	//String sRoleId =roleItr.obj().getInfo(context, "SELECT_ID");
        if (!topRoleNameList.contains(sRole) && pattern.match(tranVal)) {
              Hashtable hashTableFinal  = new Hashtable();
              hashTableFinal.put("RoleName",sRole);
              hashTableFinal.put("TroleName" ,tranVal);
              templateMapList.add(hashTableFinal);
            }
          }

          //START BUG 377064
          templateMapList  = RoleUtil.filterRoleSearchResults(context, templateMapList, "RoleName");
          //END BUG 377064

      /*if (emxPage.isNewQuery()) {
        emxPage.getTable().setObjects(templateMapList);
        emxPage.getTable().setSelects(new SelectList());
      }*/
      // this Maplist is the one which is used to make the table.
      constructedList = templateMapList;//emxPage.getTable().evaluate(context, emxPage.getCurrentPage());*/
      String sParams  = "objectId="+objectId;
    %>
	  <input type="hidden" name="memberType" value="Role" />
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectId %></xss:encodeForHTMLAttribute>" />
      <table class="list">
      <framework:sortInit
        defaultSortKey="RoleName"
        defaultSortType="string"
        mapList="<%=constructedList%>"
        resourceBundle="emxFrameworkStringResource"
        ascendText="emxFramework.Common.SortAscending"
        descendText="emxFramework.Common.SortDescending"
        params = "<%=XSSUtil.encodeForHTML(context, sParams)%>"  />
        <tr>
        <th width="5%" style="text-align:center">&nbsp;</th>
        <th nowrap>
            <framework:sortColumnHeader
              title="emxFramework.Common.Name"
              sortKey="TroleName"
              sortType="string"
              anchorClass="sortMenuItem"/>
          </th>
          <th nowrap>
            <framework:sortColumnHeader
              title="emxFramework.Common.Description"
              sortKey="Description"
              sortType="string"
              anchorClass="sortMenuItem"/>
          </th>
    	  <th nowrap>
            <framework:sortColumnHeader
              title="emxFramework.Common.Type"
              sortKey="RoleType"
              sortType="string"
              anchorClass="sortMenuItem"/>
          </th>
        </tr>
    <%
      int i=0;
    %>

      <framework:mapListItr mapList="<%=constructedList%>" mapName="templateMap">
        <tr class='<framework:swap id ="1" />'>
    <%
        String sRoleName  = (String)templateMap.get("RoleName");
        String tRoleName  = (String)templateMap.get("TroleName");
        isFound           = true;

    %>
            <td align="center"><input type="radio" name ="chkItem" id="chkItem" value = "<xss:encodeForHTMLAttribute><%=sRoleName%></xss:encodeForHTMLAttribute>"/></td>
            <input type="hidden" name="RoleName<%=i%>" value="<xss:encodeForHTMLAttribute><%=tRoleName%></xss:encodeForHTMLAttribute>" />
            <td><img src="../common/images/iconSmallRole.gif" name="imgRole" id="imgRole" alt="<%=XSSUtil.encodeForHTML(context, tRoleName)%>" /> <%=XSSUtil.encodeForHTML(context, tRoleName)%>&nbsp;</td>
            <td><%=XSSUtil.encodeForHTML(context, i18nNow.getRoleDescriptionI18NString(sRoleName, languageStr))%></td>
            <td><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxFramework.Common.Role", "emxFrameworkStringResource", request.getHeader("Accept-Language")))%>&nbsp;</td>
        </tr>
    <%
      i++;
    %>
      </framework:mapListItr>

    <%
      if (!isFound) {
    %>
        <tr class="odd">
          <td class="noresult"  align="center" colspan="4"><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxFramework.SearchRole.NoRolesFound", "emxFrameworkStringResource", request.getHeader("Accept-Language")))%></td>
        </tr>
    <%
      }
    %>
      </table>


<%}
  else if ("Group".equals(strSearchType)) {

      	  String languageStr    = request.getHeader("Accept-Language");
	      String sNamePattern     = emxGetParameter(request,"txtName");
	      String sTopChecked      = emxGetParameter(request,"chkTopLevel");
	      String sSubChecked      = emxGetParameter(request,"chkSubLevel");
	      String scope     = emxGetParameter(request, "scope");
	      String sRouteId = emxGetParameter(request,"routeId");
	      if(objectId == null ){
	        objectId = "";
	      }
	        if(objectId.trim().length() > 0)
	        {
	        	DomainObject dObj = new DomainObject(objectId);
	        	//Get the list of assigness connected thru Route Node Relationship
	        	String assigneeSelect = "from[" + dObj.RELATIONSHIP_ROUTE_NODE + "].attribute[" + dObj.ATTRIBUTE_ROUTE_TASK_USER + "]";
	        	StringList symbolicAssigneeList = dObj.getInfoList(context,assigneeSelect);
	        	int listLen = symbolicAssigneeList.size();
	        	StringList assigneeList = new StringList(listLen);
	        	StringItr symbolicAssigneeListItr = new StringItr(symbolicAssigneeList);
	        	String realName = "";
	        	while(symbolicAssigneeListItr.next())
	        	{
	        	realName =  PropertyUtil.getSchemaProperty(context,symbolicAssigneeListItr.obj());
	        	assigneeList.add(realName);
	        	}
      	   }

		  String strProjectId       = objectId;
		  BusinessObject boProject  = new BusinessObject(strProjectId);
		  Group group         = new Group();
		  GroupItr groupItr   = null;
		  String classname  = "odd";
		  String sAll       = "*";
		  String sName      = "";
		  String sType      = "Group";
		  StringList topGroupNameList  = new StringList();
		  boolean isFound   = false;
		  MapList templateMapList  =  new MapList();
		  MapList  constructedList =  new MapList();
		  Pattern pattern = null;

		  if(sNamePattern != null) {
		    pattern = new Pattern(sNamePattern);
		  } else {
		    sNamePattern = sAll;
		    pattern = new Pattern(sAll);
		  }

  		  if(scope!=null && !scope.equals("") && !scope.equals("null"))
		  {
			 isFound  = false;
		  }
		 else{
			  //if (emxPage.isNewQuery()) {
			    if (sSubChecked != null) {
      				if (sTopChecked == null) {
			        groupItr = new GroupItr(group.getTopLevelGroups(context));
				        while(groupItr.next()) {
				          topGroupNameList.add(groupItr.obj().getName());
        				}
      				}
			      GroupList groupList = group.getGroups(context);
			      groupItr = new GroupItr(groupList);
			    } else {
				      if (sTopChecked != null) {
				        GroupList groupList = group.getTopLevelGroups(context);
				        groupItr = new GroupItr(groupList);
      				  } else {
        					GroupList groupList = group.getGroups(context);
        					groupItr = new GroupItr(groupList);
      				}
    			}
    		String strGroup = i18nNow.getI18nString("emxComponents.Common.Group", "emxComponentsStringResource", languageStr);
		    String symbolicGrpName = null;
			    while (groupItr.next()) {
			      String sGroup = groupItr.obj().getName();
				      if (!topGroupNameList.contains(sGroup) && pattern.match((String) sGroup)) {
				        String sCheckGroup = "false";
				        Hashtable hashTableFinal  = new Hashtable();
				        hashTableFinal.put("lock",sCheckGroup);
				        hashTableFinal.put("GroupName",sGroup);
				        hashTableFinal.put("GroupType",strGroup);
				        templateMapList.add(hashTableFinal);
				      }
    			}

		    //emxPage.getTable().setObjects(templateMapList);
  		//}

	    // this Maplist is the one which is used to make the table.
		constructedList = templateMapList;//emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
	 }//12 nov
     String sParams  = "objectId="+objectId;
	//added on 29 nov to disbale already added ppl  in ROUTE- start
	 StringList existingList = new StringList();
	if(sRouteId!=null && !sRouteId.equals(""))
	{
		Route routeObj = (Route)DomainObject.newInstance(context, DomainConstants.TYPE_ROUTE,
	                                                               DomainConstants.TEAM);
		MapList existingRoleorGroup = new MapList();
		routeObj.setId(sRouteId);
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
	else
	{
		MapList existingGroup =   null;
		try
		{
			existingGroup = (MapList)formBean.getElementValue("routeMemberMapList");
		}catch(Exception e1)
		{
		existingGroup = new MapList();
		}

		if(existingGroup==null)
		{
		existingGroup = new MapList();
		}

		if(existingGroup!=null)
		  {Iterator mapItr = existingGroup.iterator();
		      while(mapItr.hasNext())
		      {
		        Map map = (Map)mapItr.next();
				String id       = (String)map.get(DomainConstants.SELECT_ID);
		        String roleName = (String)map.get("name");
		        if(id != null && id.equals("Group"))
		        {
					    existingList.addElement((String)map.get("name"));
				}
		     }
		  }
	}

%>
    		    <input type="hidden" name="memberType" value="Group" />
	<input type="hidden" name="objectId" value="<%= XSSUtil.encodeForHTMLAttribute(context, objectId) %>" />
  	<table class="list">
  		<!-- //XSSOK -->
		<framework:sortInit defaultSortKey="GroupName" defaultSortType="string" mapList="<%=constructedList%>" resourceBundle="emxFrameworkStringResource" ascendText="emxFramework.Common.SortAscending" descendText="emxFramework.Common.SortDescending" params = "<%=sParams%>"  />
    	<tr>
      		<th width="5%" style="text-align:center"></th>
      		<th nowrap>
        	<framework:sortColumnHeader
          	title="emxFramework.Common.Name"
          	sortKey="GroupName"
          	sortType="string"
          	anchorClass="sortMenuItem"/>
      		</th>
	    	<th nowrap>
        	<framework:sortColumnHeader
         	 title="emxFramework.Common.Type"
          	sortKey="GroupType"
          	sortType="string"
          	anchorClass="sortMenuItem"/>
      		</th>
    	</tr>
  		<!-- //XSSOK -->
		<framework:mapListItr mapList="<%=constructedList%>" mapName="templateMap">
<%
      	String sGroupName  = (String)templateMap.get("GroupName");
%>
    	<tr class='<framework:swap id ="1" />'>
<%
      	String sGroupType  = (String)templateMap.get("GroupType");
      	String sLock       = (String)templateMap.get("lock");
      	isFound            = true;
	   	if (existingList.contains(sGroupName)) {
      //if (sLock.equals("true")) {
%>
       <td align="center"><img src="../common/images/utilCheckOffDisabled.gif" alt="" /></td>
<%
      } else {
%>

       <td align="center"><input type="radio" name ="chkItem" id="chkItem" value = "<xss:encodeForHTMLAttribute><%=sGroupName%></xss:encodeForHTMLAttribute>"/></td>
<%
      }
%>
       <td><img src="../common/images/iconSmallGroup.gif" name="imgGroup" id="imgGroup" alt="<%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Group",sGroupName,languageStr))%>" /> <%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Group",sGroupName,languageStr))%>&nbsp;</td>
       <td><%=XSSUtil.encodeForHTML(context, sGroupType)%>&nbsp;</td>
        </tr>
	  </framework:mapListItr>

<%


  	if (!isFound) {
%>
    <tr class="odd">
      <td class="noresult"  align="center" colspan="4"><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxFramework.SearchGroup.NoGroupFound", "emxFrameworkStringResource", request.getHeader("Accept-Language")))%></td>
    </tr>
<%
  	}
%>
 </table>
	
	<%}
	else {
	    String exMsg = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.InvlidSearchType.Message", context.getLocale());
	    throw new Exception(exMsg + " '" + strSearchType + "'");
	}
 %>
</form>
</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
