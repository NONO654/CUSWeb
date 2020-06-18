<%--  emxRouteSelectProjectRolesOrGroups.jsp   -  Creating the WorkSpace Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxRouteSelectProjectRolesOrGroups.jsp.rca 1.14 Wed Oct 22 16:17:52 2008 przemek Experimental przemek $ 
--%>

<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script language="JavaScript" src="emxRouteSimpleFunctions.js" type="text/javascript"></script>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%

  String keyValue = emxGetParameter(request, "keyValue");
  /*Quick Route Start */
  String fromPage= emxGetParameter(request, "fromPage");
/*Quick Route End */
  boolean isProgramInstalled = false;

  Class clsProjectSpace=null;
try{
        clsProjectSpace = Class.forName("com.matrixone.apps.program.ProjectSpace");
        isProgramInstalled = true;
}catch (Exception ex){}

  com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);
  com.matrixone.apps.common.MemberRelationship member = (com.matrixone.apps.common.MemberRelationship) DomainRelationship.newInstance(context, DomainConstants.RELATIONSHIP_MEMBER,"COMMON");

  //Get Localized Version
  String languageStr = request.getHeader("Accept-Language");

  // Get the project id from the request.
  String projectId = request.getParameter("projectId");
  String memberType = emxGetParameter(request,"memberType");
  String portalMode  = request.getParameter("portalMode");


  StringList  existingList = new StringList();
  String routeId   = emxGetParameter(request,"routeId");
  
  Object objProject = null;
        if(isProgramInstalled){
                Method setId=null;
                objProject = clsProjectSpace.newInstance();
                Class[] clsArg = new Class[1];
                clsArg[0]  = String.class;
                setId = clsProjectSpace.getMethod("setId",clsArg);
                setId.invoke(objProject,new Object[] {projectId});
        }

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

  String sRoleList        = emxGetParameter(request, "roleList");
  if (sRoleList == null){
    sRoleList = "";
  }

  String sGroupList        = emxGetParameter(request, "groupList");
  if (sGroupList == null){
    sGroupList = "";
  }
  
  StringList roleList = new StringList();
  StringList groupList = new StringList();

  boolean multiSelect = true;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
  //Gather project members
  // Set the project id.
  //project.setId(projectId);
  String radioBoxName = "&RemoveBox=";

  // Retrieve the poject's member list.
  StringList memberSelects = new StringList(6);
  memberSelects.add(person.SELECT_ID);
  memberSelects.add(person.SELECT_TYPE);
  memberSelects.add(person.SELECT_NAME);
  memberSelects.add(person.SELECT_FIRST_NAME);
  memberSelects.add(person.SELECT_COMPANY_NAME);
  memberSelects.add(person.SELECT_LAST_NAME);
  StringList relSelects = new StringList(2);
  relSelects.add(member.SELECT_PROJECT_ROLE);
  relSelects.add(member.SELECT_PROJECT_ACCESS);
  MapList membersList = new MapList();

 boolean isPortal = false;
  if(portalMode != null && "true".equalsIgnoreCase(portalMode)){
    isPortal = true;
  }

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
                arguments[1]=memberSelects;
                arguments[2]=relSelects;
                arguments[3]=null;
                arguments[4]=null;
                arguments[5]=Boolean.valueOf(true);
                membersList = (MapList)getMembers.invoke(objProject,arguments);

        }
        //membersList = project.getMembers(context, memberSelects, relSelects, null, null, true);

    //Creates a display name that can be sorted by and adds it to the map
    MapList personNameList = new MapList();
    Iterator itr = membersList.iterator();

    while (itr.hasNext())
    {
      Map mapPersonName = (Map) itr.next();
      String lastName = (String) mapPersonName.get(person.SELECT_LAST_NAME);
      String firstName = (String) mapPersonName.get(person.SELECT_FIRST_NAME);
      String fullName = lastName + ", " + firstName;

      if (lastName == null && firstName == null) {
          fullName = (String) mapPersonName.get(person.SELECT_NAME);
      }
      mapPersonName.put("displayName", fullName);

      String level = (String) mapPersonName.get(person.SELECT_LEVEL);
      if (level == null) {
        mapPersonName.put(person.SELECT_LEVEL,"1");
      }
      personNameList.add(personNameList);

      String userType  = (String) mapPersonName.get(person.SELECT_TYPE);
      if(userType != null && userType.equals("Role")) {
        roleList.add((String) mapPersonName.get(person.SELECT_NAME));
      }
      if(userType != null && userType.equals("Group")) {
        groupList.add((String) mapPersonName.get(person.SELECT_NAME));
      }
    }

  int i=0;
  boolean allowExtend         = true;
  boolean isFound=false;
 MapList constructedList = new MapList();
 MapList memberMapList = null;
 MapList taskMapList = null;

 if(routeId==null || routeId.equals("") || routeId.equals("null")  ){
   try{
  	  memberMapList = (MapList)formBean.getElementValue("routeMemberMapList");
   }catch(Exception mml){
      memberMapList = new MapList();
   }

  if(memberMapList == null) {
    memberMapList = new MapList();
  }

  try{
    taskMapList = (MapList)formBean.getElementValue("taskMapList");
  }catch(Exception tml){
      taskMapList = new MapList();
  }

  if(taskMapList == null){
    taskMapList = new MapList();
  }
 }

if(memberType.equals("Role"))
{
	
	if(routeId==null || routeId.equals("") || routeId.equals("null")  ) //aded on 29 nov
		{ 
				MapList roleMapList =null;
			 try{
			      roleMapList = (MapList)formBean.getElementValue("routeRoleMapList");
				  }catch(Exception rmt){
													roleMapList = new MapList();
													}

				 if(roleMapList == null)
				{
				    roleMapList = new MapList();
				  }

		//to check already added Roles
		
		if(memberMapList.size()!=0)
		{
		Iterator mapItr = memberMapList.iterator();
	    while(mapItr.hasNext()) {
		    Map  map                = (Map)mapItr.next();
			String type = (String)map.get(DomainConstants.SELECT_TYPE);
			if(type.equals("Role"))
			  {
			   existingList.add((String)map.get(DomainConstants.SELECT_NAME));
			   
			  }
		}
     }
}
	
MapList tempRoleMapList = new MapList();

if(roleList.size() > 0)
{
	isFound           = true;
	
  for( int count = 0; count < roleList.size(); count++ )
  {
    String roleName = (String)roleList.elementAt(count);
    if( !"".equals(roleName))
    {
      HashMap tempMap = new HashMap();
      tempMap.put(DomainObject.SELECT_NAME,roleName);
      tempMap.put(DomainObject.SELECT_TYPE, "Role");
      tempMap.put(DomainConstants.SELECT_ID , "Role");
      tempRoleMapList.add((Map)tempMap);
   }
  }
    constructedList.addAll(tempRoleMapList);
    
}
}


if(memberType.equals("Group") )
{
		
	if(routeId==null || routeId.equals("") || routeId.equals("null")  )
	{
		 MapList groupMapList =null;
		 try{
		      groupMapList = (MapList)formBean.getElementValue("routeGroupMapList");
		  }catch(Exception rmt){
								  groupMapList = new MapList();
										  }

		 if(groupMapList == null)
		 {
		    groupMapList = new MapList();
		  }

		  if(memberMapList.size()!=0)
		 {
			Iterator mapItr = memberMapList.iterator();
		    while(mapItr.hasNext()) {
		    Map  map                = (Map)mapItr.next();
			String type = (String)map.get(DomainConstants.SELECT_TYPE);
			if(type.equals("Group"))
			  {
			   existingList.add((String)map.get(DomainConstants.SELECT_NAME));
			  }
			}
		 }
    }

MapList tempGroupMapList = new MapList();
if(groupList.size() > 0 )
{
	isFound           = true;
  for( int count = 0; count < groupList.size(); count++ )
  {
    String groupName = (String)groupList.elementAt(count);
    if( !"".equals(groupName))
    {
      HashMap tempMap = new HashMap();
      tempMap.put(DomainObject.SELECT_NAME,groupName);
      tempMap.put(DomainObject.SELECT_TYPE, "Group");
      tempMap.put(DomainConstants.SELECT_ID , "Group");
      tempGroupMapList.add((Map)tempMap);
	}
  }
	constructedList.addAll(tempGroupMapList);

}
}


/*if(routeId==null || routeId.equals("") )
{
//to put the MapList reqd for the 4th step of Route Wizard in the session
  formBean.setElementValue("taskMapList",taskMapList);
  formBean.setElementValue("routeMemberMapList",memberMapList);
}*/
 %>

 <script language="javascript" type="text/javaScript">//<![CDATA[

 // function to close window
  function closeWindow() {
   window.closeWindow();
  }

 function submitForm()
 {
	 //added on 29 nov
     var quickRouteRoleList="";
     var quickRouteGroupList="";
<%if(memberType.equals("Role") )
		 {
	%>
 if (document.projectRolesresults.roleList.value == ""){
      document.projectRolesresults.roleList.value = ";";
    }

    for (var varj = 0; varj < document.projectRolesresults.elements.length; varj++) {
      if (document.projectRolesresults.elements[varj].type == "checkbox") {
        chkbxFlag = "true";
        if (document.projectRolesresults.elements[varj].checked ){
          checkedFlag = "true";
          if (document.projectRolesresults.elements[varj].name.indexOf('chkItem1') > -1) {
            if (document.projectRolesresults.roleList.value.indexOf(";"+document.projectRolesresults.elements[varj].value+";") == -1) {
                document.projectRolesresults.roleList.value=document.projectRolesresults.roleList.value+document.projectRolesresults.elements[varj].value+";";
                quickRouteRoleList= quickRouteRoleList+document.projectRolesresults.elements[varj].alt+"|"+document.projectRolesresults.elements[varj].value+";";
            }
          }
        }
      }
    }
<%
	}
if(memberType.equals("Group") )
		 {
	%>
 if (document.projectRolesresults.groupList.value == ""){
      document.projectRolesresults.groupList.value = ";";
    }

    for (var varj = 0; varj < document.projectRolesresults.elements.length; varj++) {
      if (document.projectRolesresults.elements[varj].type == "checkbox") {
        chkbxFlag = "true";
        if (document.projectRolesresults.elements[varj].checked ){
          checkedFlag = "true";
          if (document.projectRolesresults.elements[varj].name.indexOf('chkItem1') > -1) {
            if (document.projectRolesresults.groupList.value.indexOf(";"+document.projectRolesresults.elements[varj].value+";") == -1) {
				document.projectRolesresults.groupList.value=document.projectRolesresults.groupList.value+document.projectRolesresults.elements[varj].value+";";
                quickRouteGroupList= quickRouteGroupList+document.projectRolesresults.elements[varj].alt+"|"+document.projectRolesresults.elements[varj].value+";";
            }
          }
        }
      }
    }
<%
	}
%>

	 //till here

	 var foundflag = "<%=isFound%>";
     var checkedFlag = "false";
    for( var i = 0; i < document.projectRolesresults.elements.length; i++ ){
      if (document.projectRolesresults.elements[i].type == "checkbox" &&
        document.projectRolesresults.elements[i].checked &&
        document.projectRolesresults.elements[i].name == "chkItem1" ){
        checkedFlag = "true";
        break;
      }
    }

	 if (checkedFlag == "false" && foundflag=="true" ) {
         <%	
			 if(memberType.equals("Group") )
		   {
		 %>
			 alert("<emxUtil:i18nScript localize="i18nId">emxComponents.SearchGroup.SelectOne</emxUtil:i18nScript>");
		 <%
			 }
		 else if(memberType.equals("Role") )
		 {
		 %>
             alert("<emxUtil:i18nScript localize="i18nId">emxComponents.SearchRole.SelectOne</emxUtil:i18nScript>");
		 <%
		 }
		 %>

      return;
    }
    /*Quick Route Start*/
    else if("QuickRoute"=="<%=XSSUtil.encodeForJavaScript(context,fromPage)%>")
    {
            if("Group"=="<%=XSSUtil.encodeForJavaScript(context,memberType)%>")
           {
                    populateQuickRouteMemberList("GROUP",quickRouteGroupList);
                    getTopWindow().closeWindow();
                    return false;

            }
            else if("Role"=="<%=XSSUtil.encodeForJavaScript(context,memberType)%>")
            {
                    populateQuickRouteMemberList("ROLE",quickRouteRoleList);
                    getTopWindow().closeWindow();
                    return false;
            }
            else
            {
                ;
            }
    } //Quick Route End
	else
	 {
		document.projectRolesresults.action = "emxRouteSelectProjectRolesOrGroupsProcess.jsp?hasTarget=true&multiSelect=true&memberType=<%=XSSUtil.encodeForURL(context,memberType)%>&routeId=<%=XSSUtil.encodeForURL(context,routeId)%>&keyValue=<%=XSSUtil.encodeForURL(context,keyValue)%>&roleList=" + document.projectRolesresults.roleList.value+"&groupList=" + document.projectRolesresults.groupList.value;
			document.projectRolesresults.submit();
	 }
 }

function doCheck(){
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



<form name="projectRolesresults" id="projectRolesresults" method="post" action="" onSubmit="return false" >
<input type="hidden" name="roleList" value="<xss:encodeForHTMLAttribute><%=sRoleList%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="groupList" value="<xss:encodeForHTMLAttribute><%=sGroupList%></xss:encodeForHTMLAttribute>" />

 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

  <framework:sortInit
    defaultSortKey="RoleName"
    defaultSortType="string"
    mapList="<%=constructedList%>"
    resourceBundle="emxComponentsStringResource"
    ascendText="emxComponents.Common.SortAscending"
    descendText="emxComponents.Common.SortDescending"
    params = ""  />
    <tr>
<%
    if(multiSelect) {
%>

 <th width="2%" style="text-align: center;">
        <span style="text-align: center;">
          <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" />
        </span>
		</th>
<%
    } else {
%>
      <th width="5%" style="text-align:center">&nbsp;</th>
<%

    }
%>

		  <th nowrap="nowrap">
            <framework:sortColumnHeader title="emxComponents.Common.Name"
              sortKey="<%= person.SELECT_NAME %>"
              sortType="string"/>
          </th>

      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Type"
          sortKey="<%=person.SELECT_TYPE%>"
          sortType="string"/>
      </th>
    </tr>
<%
  i=0;
%>

  <framework:mapListItr mapList="<%=constructedList%>" mapName="templateMap">
    <tr class='<framework:swap id ="1" />'>
<%
	String sRoleOrGroupName  = (String)templateMap.get(DomainObject.SELECT_NAME);
    String tRoleOrGroupName  = (String)templateMap.get(DomainObject.SELECT_TYPE);
    isFound           = true;
    if(multiSelect) {
		if(existingList.contains(sRoleOrGroupName) )
		{
%>
        <td align="center"><img src="../common/images/utilCheckOffDisabled.gif" alt="" /></td>
<%
      } else {
%>
        <td align="center"><input type="checkbox" name ="chkItem1" id="chkItem1" value = "<%=sRoleOrGroupName%>" onclick="updateCheck()" alt=" <%=sRoleOrGroupName%>"/></td>
<%
      }
    } else {
%>
        <td align="center"><input type="radio" name ="chkItem1" id="chkItem1" value = "<%=sRoleOrGroupName%>" alt=" <%=sRoleOrGroupName%>"/></td>
        <input type="hidden" name="RoleName<%=i%>" value="<%=tRoleOrGroupName%>" />
<%
    }
%>
         <td><%=sRoleOrGroupName%></td>
        <td><img src="../common/images/iconSmallGroup.gif" name="imgRole" id="imgRole" alt="<%=tRoleOrGroupName%>" /> <%=tRoleOrGroupName%>&nbsp;</td>

    </tr>
<%
  i++;
%>
  </framework:mapListItr>

<%
  if (!isFound && memberType.equals("Role")) {
%>
    <tr>
      <td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.SearchRole.NoRolesFound</emxUtil:i18n></td>
    </tr>
<%
  }
%>
<%
  if (!isFound && memberType.equals("Group")) {
%>
    <tr>
      <td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.SearchGroup.NoGroupsFound</emxUtil:i18n></td>
    </tr>
<%
  }
%>
  </table>
</form>
</html>

