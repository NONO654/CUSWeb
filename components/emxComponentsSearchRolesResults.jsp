<%-- emxComponentsSearchRolesResults.jsp -- The Page displays the List of Role

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsSearchRolesResults.jsp.rca 1.12 Wed Oct 22 16:18:46 2008 przemek Experimental przemek $
--%>
<%@page import="com.matrixone.apps.domain.util.RoleUtil"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../emxPaginationInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%!
RoleList getChildRoles(Context context, Role matrixRole) throws Exception
{

  RoleList roleList = new RoleList();
  matrixRole.open(context);

  if(matrixRole.hasChildren())
  {
      roleList.addAll(matrixRole.getChildren());
      RoleItr roleItr = new RoleItr(roleList);
      while (roleItr.next())
      {
         Role childRole = (Role)roleItr.obj();
         roleList.addAll(getChildRoles(context, childRole));
      }

  }
  matrixRole.close(context);
  return roleList;
}

boolean isParentCompanyAHostCompany(Context context, String strOrganizationId) throws Exception
{
    String strCompanyType             = DomainObject.TYPE_COMPANY;
    String strBusinessUnitType        = DomainObject.TYPE_BUSINESS_UNIT;
    String strDepartmentType          = DomainObject.TYPE_DEPARTMENT;
    String strDivisionRel             = DomainObject.RELATIONSHIP_DIVISION;
    String strCompanyDepRel           = DomainObject.RELATIONSHIP_COMPANY_DEPARTMENT;
    String strSubsidiaryRel           = DomainObject.RELATIONSHIP_SUBSIDIARY;

    DomainObject busOrganization = new DomainObject(strOrganizationId);
    String sOrgTypeName = busOrganization.getInfo(context,DomainObject.SELECT_TYPE);

    while(!sOrgTypeName.equals(strCompanyType) && !"".equals(sOrgTypeName))
    {
        if(sOrgTypeName.equals(strBusinessUnitType))
        {
            sOrgTypeName        = busOrganization.getInfo(context,"to[" + strDivisionRel + "].from.type");
            strOrganizationId   = busOrganization.getInfo(context,"to[" + strDivisionRel + "].from.id");
            busOrganization     = new DomainObject(strOrganizationId);
        }
        else if (sOrgTypeName.equals(strDepartmentType))
        {
            sOrgTypeName        = busOrganization.getInfo(context,"to[" + strCompanyDepRel + "].from.type");
            strOrganizationId   = busOrganization.getInfo(context,"to[" + strCompanyDepRel + "].from.id");
            busOrganization     = new DomainObject(strOrganizationId);
        }
        else
        {
            sOrgTypeName = "";
        }
    }
    
    String strHostCompId = Company.getHostCompany(context);
    
    if(strHostCompId.equals(strOrganizationId))
    {
        return true;
    }
    
    while(strCompanyType.equals(sOrgTypeName))
    {
        sOrgTypeName = busOrganization.getInfo(context,"to[" + strSubsidiaryRel + "].from.type");
        strOrganizationId = busOrganization.getInfo(context,"to[" + strSubsidiaryRel + "].from.id");
        if(strHostCompId.equals(strOrganizationId))
        {
            return true;
        }
        busOrganization = new DomainObject(strOrganizationId);
    }
    
    return false;
}

%>

<%
  String objectId         = emxGetParameter(request,"objectId");
  String sNamePattern     = emxGetParameter(request,"txtName");
  String sTopChecked      = emxGetParameter(request,"chkTopLevel");
  String sSubChecked      = emxGetParameter(request,"chkSubLevel");
  String sCallpage        = emxGetParameter(request,"callPage");
  String sRoleList        = emxGetParameter(request,"roleList");
  String parentForm       = emxGetParameter(request,"form");
  String parentField      = emxGetParameter(request,"field");
  String parentFieldDisp  = emxGetParameter(request,"fieldDisp");
  String strMultiSelect   = emxGetParameter(request,"multiSelect");
  String mainSearchPage   = emxGetParameter(request,"mainSearchPage");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  
  String languageStr        = request.getHeader("Accept-Language");
  
  String queryLimit = emxGetParameter(request,"queryLimit");
  int roleLimit=Integer.parseInt(queryLimit);
  // Only one line added - Nishchal
  String keyValue = emxGetParameter(request,"keyValue");
  if(keyValue == null || "null".equals(keyValue))
  {
      keyValue = "";
  }

  String strOrgId         = emxGetParameter(request,"orgId");
  if(strOrgId == null || "null".equals(strOrgId))
  {
    strOrgId = "";
  }

  if(parentFieldDisp == null || "null".equals(parentFieldDisp)) {
    parentFieldDisp ="";
  } else {
    parentFieldDisp = parentFieldDisp.trim();
  }

  boolean multiSelect = true;
  if(strMultiSelect != null && "false".equals(strMultiSelect)){
    multiSelect = false;
  }

  if(objectId == null ){
    objectId = "";
  }
  
  String sNewSearchPage ="emxComponentSearchRolesDialog.jsp";
  if(mainSearchPage != null && !"null".equals(mainSearchPage) && !"".equals(mainSearchPage)){
    sNewSearchPage = mainSearchPage;
  }

%>
<!--Modified for bung no:-312078-->
<script language = "Javascript" type = "text/javascript">
//added for the bug no:-312078
// hasPersistence must be true if persistence is required in pagination
  var hasPersistence = true;
  // page array has values were in idArray minus the checked items in the current page
 //end the bug 312078
  function newSearch() {
	  parent.location='<%=XSSUtil.encodeForURL(context,sNewSearchPage)%>?form=<%=XSSUtil.encodeForURL(context,parentForm)%>&field=<%=XSSUtil.encodeForURL(context,parentField)%>&fieldDisp=<%=XSSUtil.encodeForURL(context,parentFieldDisp)%>&multiSelect=<%=XSSUtil.encodeForURL(context,strMultiSelect)%>&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&targetSearchPage=<%=XSSUtil.encodeForURL(context,targetSearchPage)%>&mainSearchPage=<%=XSSUtil.encodeForURL(context,mainSearchPage)%>&callPage=<%=XSSUtil.encodeForURL(context,sCallpage)%>&txtName=<%=XSSUtil.encodeForURL(context,sNamePattern)%>&chkTopLevel=<%=XSSUtil.encodeForURL(context,sTopChecked)%>&chkSubLevel=<%=XSSUtil.encodeForURL(context,sSubChecked)%>&orgId=<%=XSSUtil.encodeForURL(context,strOrgId)%>&keyValue=<%=XSSUtil.encodeForURL(context,keyValue)%>';
  }
// Modified the function name as it was clashing and also modified where it was being called - Nishchal
  function doCheckCheckbox(){
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;
    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].name.indexOf('chkItem') > -1){
        objForm.elements[i].checked = chkList.checked;
		//added for the bug 338629 
		updateIdArray(objForm.elements[i].value,chkList.checked);
      }

  }
// Modified the function name as it was clashing and also modified where it was being called - Nishchal

  function updateCheckCheckbox(checkbox) {
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    if (checkbox.checked == false)
    {
      chkList.checked = false;
	  //added for 312078
		updateIdArray(checkbox.value,false);
		//end 312078

    }
    else
    {
		
        var checkBoxObjects = objForm.elements[checkbox.name];
		//added for 312078
		updateIdArray(checkbox.value,true);
		//end 312078
		
        if (checkBoxObjects.length == null || (checkBoxObjects.length == "undefined"))
        {
            chkList.checked = true;
        }
        else
        {
            var checkHeader=0;
            for (var i = 0; i < checkBoxObjects.length; i++)
            {
                if (checkBoxObjects[i].checked == true)
                {
                    checkHeader++;
                }
            }
            if(checkHeader == checkBoxObjects.length)
            {
                chkList.checked = true;
            }
            else
            {
                chkList.checked = false;
            }
        }
    }
  }
  //added for the bug no:-312078
function updateIdArray(objId,flag)
  {
    idArrayObj = parent.idArray;
    if(idArrayObj!=null)
    {
          exists=false;
          i=0;
          for(i=0;i<idArrayObj.length;i++)
          {
             if(idArrayObj[i]==objId)
         {
            exists=true;
            break;
         }
          }
          if(flag)
          {
              if(!exists){
              idArrayObj[idArrayObj.length]=objId;
          }
          }
          else
          {
              if(exists)
          {
             idArrayObj[i]="";
          }
          }
    }
	//added for 312078
	 parent.idArray = idArrayObj;
	 //end the bug no:-312078
	
  }

// populate the Array with selections made in this page, and pass it on to the hidden object
    function populateArray() {
    var arrayValue = parent.idArray.toString();
    document.templateresults.idArrayHidden.value = arrayValue;
//added for 312078
	arrayValue=arrayValue.replace(/,/g, '|');
	//modified for the bug 338629
	document.templateresults.roleList.value = "|"+arrayValue+"|";


  }
//end the bug no:-312078
  function submitform() {
    var checkedFlag = "false";
    var chkbxFlag = "false";
    var displayRole="";
    var originalRole = "";
	//added for 312078
	 populateArray();
	 //end 312078
    if (document.templateresults.roleList.value == ""){
      document.templateresults.roleList.value = "|";
    }
    // force to select atleast one member to remove
<%
    if(multiSelect) {
%>

    for (var varj = 0; varj < document.templateresults.elements.length; varj++) {
      if (document.templateresults.elements[varj].type == "checkbox") {
        chkbxFlag = "true";
        if (document.templateresults.elements[varj].checked ){
          checkedFlag = "true";

			if (document.templateresults.elements[varj].name.indexOf('chkItem') > -1) {

            if (document.templateresults.roleList.value.indexOf("|"+document.templateresults.elements[varj].value+"|") == -1){

			document.templateresults.roleList.value=document.templateresults.roleList.value+document.templateresults.elements[varj].value+"|";
            }
          }
        }
      }
    }
    if ((checkedFlag == "false") && (chkbxFlag == "true")) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.RoleMessage</emxUtil:i18nScript>");
      return;
      
    } else if("CreatePeopleRoleSumary" == "<%=XSSUtil.encodeForJavaScript(context,sCallpage)%>"){
    	/*XSSOK*/
      var stmt1 = "parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,parentForm)%>.<%=XSSUtil.encodeForJavaScript(context,parentField)%>.value=parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,parentForm)%>.<%=XSSUtil.encodeForJavaScript(context,parentField)%>.value + document.templateresults.roleList.value";
	  eval(stmt1);
      stmt1 = "parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,parentForm)%>.action=\"emxComponentsPeopleRoleSummaryFS.jsp\"";
      eval(stmt1);
      /*XSSOK */
      stmt1 = "parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,parentForm)%>.submit()";
      eval(stmt1);
     window.closeWindow();
    } else if("PeopleEditRoleSumary" == "<%=XSSUtil.encodeForJavaScript(context,sCallpage)%>"){
      document.templateresults.action = "emxComponentsAddRole.jsp";
      document.templateresults.submit();
    }
        // Added Nishchal
    else if ("emxComponentsObjectAccessUsersDialog" == "<%=XSSUtil.encodeForJavaScript(context,sCallpage)%>")
    {
        document.location.href=fnEncode("emxComponentsObjectAccessAddUsersProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context,keyValue)%>&userType=Role&userList="+document.templateresults.roleList.value);
    }

<%
    } else {
   %>
    var count = 0;
    for (var varj = 0; varj < document.templateresults.elements.length; varj++) {
      if (document.templateresults.elements[varj].type == "radio") {
        chkbxFlag = "true";
        if (document.templateresults.elements[varj].checked ){
          checkedFlag = "true";
          originalRole = document.templateresults.elements[varj].value;
          displayRole = eval('document.templateresults.RoleName' + count + '.value');
        }
        count++;
      }
    }

     if ((checkedFlag == "false") && (chkbxFlag == "true")) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.RoleMessage</emxUtil:i18nScript>");
      return;
    } else {
      //XSSOK Form names can contain special chars and would fail if it is encoded
      parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,parentForm)%>.<%=XSSUtil.encodeForJavaScript(context,parentField)%>.value=originalRole;
      var dispFieldPassed = '<%=parentFieldDisp%>';
      if(dispFieldPassed != "")
      {
    	//XSSOK Form names can contain special chars and would fail if it is encoded  
        var dispField = eval('parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,parentForm)%>.<%=XSSUtil.encodeForJavaScript(context,parentFieldDisp)%>');
        if(dispField) {
          dispField.value=displayRole;
        }
      }
      window.closeWindow();
    }
<%
  }
%>
  }

  function closeWindow() {
    window.closeWindow();
    return;
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%

  String strProjectId       = objectId;
  BusinessObject boProject  = new BusinessObject(strProjectId);

  if (sRoleList == null){
    sRoleList = "";
  }

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
  try
  {
    isSetupAsPrivateExchange = EnoviaResourceBundle.getProperty(context,"emxComponents.isSetupAsPrivateExchange");
  }
  catch(Exception e)
  {}

  if(isSetupAsPrivateExchange != null && "false".equalsIgnoreCase(isSetupAsPrivateExchange.trim()) )
  {
      isPrivateExchange = false;
  }


  if(sNamePattern != null) {
    pattern = new Pattern(sNamePattern);
  } else {
    sNamePattern = sAll;
    pattern = new Pattern(sAll);
  }
 //Added for the Bug No: 325300
  String caseSensitivity="print system  casesensitive";
  String caseStatus=MqlUtil.mqlCommand(context,caseSensitivity);
  if(caseStatus.equals("CaseSensitive=Off"))
	{
		pattern.setCaseSensitive(false);
	}
 // Till Here
  /** List Subfolders based on the Checkbox Select
  * if both 'TopLevel' & 'SubLevel' were selected/not selected  - display all roles
  * if 'Top Level' selected and 'Sub Level' not selected  - display only Top Level roles
  * if 'Sub Level' selected and 'Top Level' not selected  - display only Sub Level roles
  */
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
  if(strOrgId != null && strOrgId.length() > 0)
  {
      Vector vectOfRoles = new Vector(); // this vector will eliminate the roles to be displayed.

      if(isParentCompanyAHostCompany(context,strOrgId)) // host company
      {
          vectOfRoles.add(PropertyUtil.getSchemaProperty(context, "role_ExternalProgramLead"));
          vectOfRoles.add(PropertyUtil.getSchemaProperty(context, "role_ExternalProjectAdministrator"));
          vectOfRoles.add(PropertyUtil.getSchemaProperty(context, "role_ExternalProjectLead"));
          vectOfRoles.add(PropertyUtil.getSchemaProperty(context, "role_ExternalProjectUser"));
      }
      else
      {
          vectOfRoles.add(PropertyUtil.getSchemaProperty(context, "role_BusinessManager"));
          vectOfRoles.add(PropertyUtil.getSchemaProperty(context, "role_ProgramLead"));
          vectOfRoles.add(PropertyUtil.getSchemaProperty(context, "role_ProjectAdministrator"));
          vectOfRoles.add(PropertyUtil.getSchemaProperty(context, "role_ProjectLead"));
          vectOfRoles.add(PropertyUtil.getSchemaProperty(context, "role_ProjectUser"));

          // for hiding emplyee and sub roles.
          String strEmpRole = PropertyUtil.getSchemaProperty(context, "role_Employee");
          vectOfRoles.add(strEmpRole);
          Role roleEmployee = new Role(strEmpRole);
          RoleList strRolesList = getChildRoles (context,roleEmployee);
          int roleListSize = strRolesList.size();

          // this is defined to eliminate some roles from the "above rolelist for hiding"
          Vector vectExceptionRoles = new Vector();
          vectExceptionRoles.add(PropertyUtil.getSchemaProperty(context, "role_Buyer"));
          vectExceptionRoles.add(PropertyUtil.getSchemaProperty(context, "role_BuyerAdministrator"));

          for(int i = 0 ; i < roleListSize ; i++)
          {
             if(!isPrivateExchange)
             {
                if(!vectExceptionRoles.contains(strRolesList.get(i).toString()))
                {
                  vectOfRoles.add(strRolesList.get(i).toString());
                }
             }
             else
             {
                if(!vectExceptionRoles.contains(strRolesList.get(i).toString()))
                {
                  vectOfRoles.add(strRolesList.get(i).toString());
                }
             }
          }
      }

      while (roleItr.next())
      {
        String sRole  = roleItr.obj().getName();
		String tranVal= i18nNow.getAdminI18NString("Role",sRole,sLanguage);
        if (!vectOfRoles.contains(sRole) && !topRoleNameList.contains(sRole) && pattern.match(tranVal))
        {

            Hashtable hashTableFinal  = new Hashtable();
            hashTableFinal.put("RoleName",sRole);
            hashTableFinal.put("TroleName" ,tranVal);
            //<Fix 376110>
            hashTableFinal.put("Description", i18nNow.getRoleDescriptionI18NString(sRole, languageStr));
            //</Fix 376110>
            templateMapList.add(hashTableFinal);
            if(templateMapList.size()>roleLimit-1){
                break;
            }
        }
      }
  }
  else
  {
      while (roleItr.next())
      {

        String sRole  = roleItr.obj().getName();
        String tranVal= i18nNow.getAdminI18NString("Role",sRole,sLanguage);
        if (!topRoleNameList.contains(sRole) && pattern.match(tranVal))
        {
          Hashtable hashTableFinal  = new Hashtable();
          hashTableFinal.put("RoleName",sRole);
          hashTableFinal.put("TroleName" ,tranVal);
          //<Fix 376110>
          hashTableFinal.put("Description", i18nNow.getRoleDescriptionI18NString(sRole, languageStr));
          //</Fix 376110>
          templateMapList.add(hashTableFinal);
          if(templateMapList.size()>roleLimit-1){
              break;
          }
        }
      }
  }

  //START BUG 377064
  templateMapList  = RoleUtil.filterRoleSearchResults(context, templateMapList, "RoleName");
  //END BUG 377064

  if (emxPage.isNewQuery()) {
    emxPage.getTable().setObjects(templateMapList);
    emxPage.getTable().setSelects(new SelectList());
  }
  // this Maplist is the one which is used to make the table.
  constructedList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
  String sParams  = "objectId="+objectId+"&roleList="+sRoleList;
%>

<form name="templateresults" id="templateresults" method="post" onSubmit="return false">
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectId %></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="roleList" value="<xss:encodeForHTMLAttribute><%=sRoleList%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="orgId" value="<xss:encodeForHTMLAttribute><%=strOrgId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="idArrayHidden" value=""/>  
  <table class="list" id="UITable">
  <framework:sortInit
    defaultSortKey="TroleName"
    defaultSortType="string"
    mapList="<%=constructedList%>"
    resourceBundle="emxComponentsStringResource"
    ascendText="emxComponents.Common.SortAscending"
    descendText="emxComponents.Common.SortDescending"
    params = "<%=sParams%>"  />
    <tr>
<%
    if(multiSelect) {
%>
      <th width="5%" style="text-align:center"><input type="checkbox" name="chkList" id="chkList" onclick="doCheckCheckbox()" /></th>
<%
    } else {
%>
      <th width="5%" style="text-align:center">&nbsp;</th>
<%

    }
%>
      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Name"
          sortKey="TroleName"
          sortType="string"/>
      </th>
      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Description"
          sortKey="Description"
          sortType="string"/>
      </th>
	  <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Type"
          sortKey="RoleType"
          sortType="string"/>
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
 //<Fix 376110>
 String description = (String) templateMap.get("Description");
 description = description == null ? i18nNow.getRoleDescriptionI18NString(sRoleName, languageStr) : description;
 //</Fix 376110>
 
 isFound      = true;
    if(multiSelect)
    {
%>
        <td align="center"><input type="checkbox" name ="chkItem" id="chkItem" value = "<%=XSSUtil.encodeForHTMLAttribute(context, sRoleName)%>" onclick="updateCheckCheckbox(this)"/></td>
<%
    } else {
%>
        <td align="center"><input type="radio" name ="chkItem" id="chkItem" value = "<%=XSSUtil.encodeForHTMLAttribute(context, sRoleName)%>"/></td>
        <input type="hidden" name="RoleName<%=i%>" value="<%=XSSUtil.encodeForHTMLAttribute(context, tRoleName)%>" />
<%
    }
%>
        <td><img src="../common/images/iconSmallRole.gif" name="imgRole" id="imgRole" alt="<%=XSSUtil.encodeForHTMLAttribute(context, tRoleName)%>" /> <%=XSSUtil.encodeForHTML(context, tRoleName)%>&nbsp;</td>
        <td><%=XSSUtil.encodeForHTML(context, description)%></td>
        <td><emxUtil:i18n localize="i18nId">emxComponents.Common.Role</emxUtil:i18n>&nbsp;</td>
    </tr>
<%
  i++;
%>
  </framework:mapListItr>

<%
  if (!isFound) {
%>
    <tr>
      <td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.SearchRole.NoRolesFound</emxUtil:i18n></td>
    </tr>
<%
  }
%>
<!--added for the bug no:-312078 -->
<script language="JavaScript">

  // make check-box checked if values in the idArray matches the checkbox values
  // populate rest of the values of idArray to pageArray
 //added code for 304116
if ((parent.idArray != null) && (parent.idArray != "undefined")){
	
    for(var i = 0; i < document.templateresults.elements.length; i++){
      if (document.templateresults.elements[i].name == "chkItem") {
        for(var j=0 ; j< parent.idArray.length; j++){
        if(parent.idArray[j]==document.templateresults.elements[i].value) {
          document.templateresults.elements[i].checked = true;
          break;
        }
        }
       }
     }
    }//end the bug no 312078 
</script>

  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

