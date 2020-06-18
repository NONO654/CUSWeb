<%--  emxCreateRouteTemplateWizardMembersDialog.jsp   -   Displays the AccessMembers Objects List
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCreateRouteTemplateWizardMembersDialog.jsp.rca 1.16 Wed Oct 22 16:17:48 2008 przemek Experimental przemek $

--%>


 <%@include file = "../emxUICommonAppInclude.inc" %>
 <%@include file = "emxRouteInclude.inc" %>
 <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
 <%@include file = "emxComponentsJavaScript.js" %>
 <%@include file = "../emxPaginationInclude.inc" %>

 <jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
 <%
 framesetObject fs = new framesetObject();
 String showmenuinToolbar = fs.getShowmenuinToolbarValue();
 String keyValue=emxGetParameter(request,"keyValue");

 String relatedObjectId  =  (String)formBean.getElementValue("objectId");

 String templateId       =  (String) formBean.getElementValue("templateId");
 String scopeId          =  (String) formBean.getElementValue("scopeId");
 String templateName     =  (String) formBean.getElementValue("templateName");
 String routeId          =  (String) formBean.getElementValue("routeId");
  // flag to find if user coming back from step 3 to 2
 String toAccessPage    =  (String) formBean.getElementValue("toAccessPage");

 String workspaceId     =  (String) formBean.getElementValue("WorkspaceId");
 String folderId   =  (String) formBean.getElementValue("folderId");
 String suiteKey    =  (String) formBean.getElementValue("suiteKey");
 String jsTreeID    =  (String) formBean.getElementValue("jsTreeID");
 String portalMode  =  (String) formBean.getElementValue("portalMode");
 String supplierOrgId     =  (String) formBean.getElementValue("supplierOrgId");
 String routeAction    =  (String) formBean.getElementValue("selectedAction");
 String owningOrganization = (String) formBean.getElementValue("organization");
 
 workspaceId = (workspaceId != null && !"".equals(workspaceId)) ? workspaceId : scopeId;
//added by pritam on 18 nov
 Hashtable hashRouteWizFirst  =  (Hashtable)formBean.getElementValue("hashRouteWizFirst");

  String sReadWriteSelected = "";
  String sReadSelected      = "";
  String sAddSelected       = "";
  String sRemoveSelected    = "";
  String sAddRemoveSelected = "";
  String sAccess            = "";
  String sTargetId          = "";
  String userName          = "";
  String sTargetType        = "";
  String sTargetName        = "";
  String sDisplayTargetName = "";
  String sTargetOrganization = "";
  String sProjectLead       = "";
  String sCreateRoute       = "";
  String sProjectId         = null;

  int i=0;

  Vector vectPersons       = new Vector();
  Hashtable hashTargetData = new Hashtable();

 // MapList routeMemberMapList = (MapList)session.getValue("routeMemberMapList");
  // MapList routeRoleMapList   = (MapList)session.getValue("routeRoleMapList");

  MapList routeRoleMapList   = null;
  try{
            routeRoleMapList   = (MapList)formBean.getElementValue("routeRoleMapList");

   }catch(Exception rrm){
           routeRoleMapList = new MapList();

   }


   MapList routeMemberMapList = null;
   try{
           routeMemberMapList = (MapList)formBean.getElementValue("routeMemberMapList");
   }catch(Exception rrm){
           routeMemberMapList = new MapList();
   }



  // merge routeMemberMapList, routeRoleMapList into one
/*  if( routeMemberMapList == null) //ITS NOT NECESSARY
  {
    routeMemberMapList = new MapList();
  }

  if( routeRoleMapList == null)
  {
    routeRoleMapList = new MapList();
  }*/


  AccessUtil accessUtil            = new AccessUtil();
  Access access                    = new Access();

  BusinessObject routeObj          = null;
  BusinessObject memberObje        = null;
  SelectList selectPersonStmts     = null;
  SelectList selectPersonRelStmts  = null;
  ExpansionWithSelect personSelect = null;

  RelationshipWithSelectList relWithSelList = null;
  RelationshipWithSelectItr relWithSelItr   = null;
  String relProjectVaults     = PropertyUtil.getSchemaProperty( context, "relationship_ProjectVaults");
  String relVaultedDocuments  = PropertyUtil.getSchemaProperty( context, "relationship_VaultedDocuments");
  String sAttrProjectAccess   = PropertyUtil.getSchemaProperty(context, "attribute_ProjectAccess");
  String sAttrCreateRoute     = PropertyUtil.getSchemaProperty(context, "attribute_CreateRoute");
  String strTypePerson        = PropertyUtil.getSchemaProperty(context, "type_Person");
  String strTypeProject       = PropertyUtil.getSchemaProperty(context, "type_Project");
  String strTypeProjectVault  = PropertyUtil.getSchemaProperty(context, "type_ProjectVault");
  String relRouteNode         = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode");
  String relEmployee          = PropertyUtil.getSchemaProperty(context, "relationship_Employee");

  String sSelOrgName          = "to["+relEmployee+"].from.name";


  String sParams = "jsTreeID="+ jsTreeID +"&suiteKey="+suiteKey+"&objectId="+relatedObjectId+"&routeId="+routeId;
  sParams += "&templateId=" +templateId+"&template="+templateName+"&toAccessPage="+toAccessPage+"&supplierOrgId=" + supplierOrgId + "&portalMode=" +portalMode;

  String sRoute  = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.Route");

%>

<script language="Javascript" type="text/javascript">

  // function to close window
  function closeWindow() {

   submitWithCSRF("emxRouteWizardCancelProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>", window);

  }

  function goBack() {	
    document.ContenForm.target = "_parent";	
    document.ContenForm.action="emxCreateRouteTemplateWizardDialogFS.jsp?previousButtonClick=true&keyValue=<%=XSSUtil.encodeForJavaScript(context, keyValue)%>&<%=XSSUtil.encodeForJavaScript(context, sParams)%>&showmenuinToolbar=<%=showmenuinToolbar%>";
	document.ContenForm.submit();
    return ;
		
}

  // function to select all the check boxes
  function doCheck() {
    var objForm = document.ContenForm;
    var chkList = objForm.chkList;
    for (var i=0; i < objForm.elements.length; i++)
    if (objForm.elements[i].name.indexOf('chkItem') > -1){
      objForm.elements[i].checked = chkList.checked;
    }
  }

  // function to uncheck all the check box values.
  function updateCheck() {
    var objForm     = document.ContenForm;
    var chkList     = objForm.chkList;
    chkList.checked = false;
  }



  function submitForm() {
    var checkedFlag = "false";
    // force to select atleast one member to add
    for( var i = 0; i < document.ContenForm.elements.length; i++ ){
      if (document.ContenForm.elements[i].type == "checkbox" && document.ContenForm.elements[i].name == "chkItem" ){
        checkedFlag = "true";
        break;
      }
    }
    if (checkedFlag == "false") {
      alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.PeopleSummary.SelectOneMember</emxUtil:i18nScript>");
      return;
    }
    document.ContenForm.target = "_parent";
     document.ContenForm.action="emxCreateRouteTemplateWizardMembersProcess.jsp?keyValue=<%=XSSUtil.encodeForJavaScript(context, keyValue)%>";

    startProgressBar(true);
    document.ContenForm.submit();
    return;

  }

 function addMembers() {	 	
	 	var frame = findFrame(getTopWindow(), "pagehidden");
	 	frame.location.href = 'emxRouteMembersSearch.jsp?fromPage=routeTemplateWizard&memberType=Person&scopeId=<%=XSSUtil.encodeForURL(context,workspaceId)%>&OwningOrganization=<%=XSSUtil.encodeForURL(context,owningOrganization)%>&supplierOrgId=<%=XSSUtil.encodeForURL(context,supplierOrgId)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>';
  }


//added on 11nov
  function addRole()
  {
        emxShowModalDialog('emxRouteMembersSearch.jsp?memberType=Role&fromPage=routeTemplateWizard&scopeId=<%= XSSUtil.encodeForURL(context,workspaceId)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>',600,500);
   }


function addGroup()
{

        emxShowModalDialog('emxRouteMembersSearch.jsp?memberType=Group&fromPage=routeTemplateWizard&scopeId=<%= XSSUtil.encodeForURL(context,workspaceId)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>',600,500);

  }

function addUserGroup()
{
		var frame = findFrame(getTopWindow(), "pagehidden");
		frame.location.href = 'emxRouteMembersSearch.jsp?memberType=UserGroup&fromPage=routeTemplateWizard&scopeId=<%= XSSUtil.encodeForURL(context,workspaceId)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>';

}
//added on 12th Feb 04 for bug no 282964
function addMemberList()
{
	var frame = findFrame(getTopWindow(), "pagehidden");
 	frame.location.href = 'emxRouteMembersSearch.jsp?fromPage=routeTemplateWizard&memberType=MemberList&scopeId=<%=XSSUtil.encodeForURL(context,workspaceId)%>&OwningOrganization=<%=XSSUtil.encodeForURL(context,owningOrganization)%>&supplierOrgId=<%=XSSUtil.encodeForURL(context,supplierOrgId)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>';
}
// bug no 282964

function removeMembers() {
    var checkedFlag = "false";
    // force to select atleast one member to add
    for( var i = 0; i < document.ContenForm.elements.length; i++ ){
      if (document.ContenForm.elements[i].type == "checkbox" && document.ContenForm.elements[i].name == "chkItem"
          && document.ContenForm.elements[i].checked){
        checkedFlag = "true";
        break;
      }
    }

 // Sending all the selected roles in input type hidden

	    for( var i = 0; i < document.ContenForm.elements.length; i++ ){
	      if ((document.ContenForm.elements[i].type == "checkbox") && (document.ContenForm.elements[i].name == "chkItem") && (document.ContenForm.elements[i].checked) && (document.ContenForm.elements[i].value == "Role") && (document.ContenForm.elements[i+1].name == "userRole")){
	        document.ContenForm.selRoles.value = document.ContenForm.selRoles.value + document.ContenForm.elements[i+1].value + ";";
	      } //Bug No : 296864 Added else condition for sending  all selected Group in input type hidden
	      else if ((document.ContenForm.elements[i].type == "checkbox") && (document.ContenForm.elements[i].name == "chkItem") && (document.ContenForm.elements[i].checked) && (document.ContenForm.elements[i].value == "Group") && (document.ContenForm.elements[i+3].name == "groupId")){
	        document.ContenForm.selGroup.value = document.ContenForm.selGroup.value + document.ContenForm.elements[i+3].value + ";";
	      }
    }

    if (checkedFlag == "false") {
      alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.AccessMembersDialog.SelectRemove</emxUtil:i18nScript>");
      return;
    }
    else
    {
      if(confirm("<emxUtil:i18nScript  localize="i18nId">emxComponents.RouteMember.RemoveMsgConfirm</emxUtil:i18nScript>"))
      {
        document.ContenForm.action="emxRouteTemplateWizardRemoveMemberProcess.jsp?keyValue=<%=XSSUtil.encodeForJavaScript(context, keyValue)%>&removeMember=removeMember";
        document.ContenForm.submit();
      }
    }
    return ;
  }

  function ChangeAccess(accessChangedCount){
	 var selectName = "selAccess"+accessChangedCount;
	 var accessSelected=document.ContenForm.elements[selectName].options[document.ContenForm.elements[selectName].selectedIndex].value;
      		document.location.href="emxCreateRouteTemplateWizardMembersProcess.jsp?changedAccessPage=changedAccessPage&changedAccess="+accessChangedCount+"&accessSelected="+accessSelected+"&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";
  }


</script>
<%
  String sUser = context.getUser();
  if(routeMemberMapList != null) 
  {
      for (Iterator iter = routeMemberMapList.iterator(); iter.hasNext();) {
          java.util.Map memberMap = (java.util.Map) iter.next();
          
          String LastFirstName = (String) memberMap.get("LastFirstName");
          String type = (String) memberMap.get("type");
          
          String Ttype = type;
          String TLastFirstName = LastFirstName;
          
          if("Person".equals(type)) {
              Ttype = i18nNow.getI18nString("emxComponents.Common.Person", "emxComponentsStringResource", sLanguage);
          } else if("Role".equals(type)) {
              Ttype = i18nNow.getI18nString("emxComponents.Common.Role", "emxComponentsStringResource", sLanguage);
              TLastFirstName = i18nNow.getAdminI18NString("Role", LastFirstName, sLanguage);
          } else if("Group".equals(type)) {
              Ttype = i18nNow.getI18nString("emxComponents.Common.Group", "emxComponentsStringResource", sLanguage);
              TLastFirstName = i18nNow.getAdminI18NString("Group", LastFirstName, sLanguage);
          }
          memberMap.put("Ttype", Ttype);
          memberMap.put("TLastFirstName", TLastFirstName);
       } 
  }
%>


<form name="ContenForm" method="post" target="_parent">
  <input type="hidden" name="routeId"    value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="objectId"   value="<xss:encodeForHTMLAttribute><%=relatedObjectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=templateName%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="toAccessPage" value="<xss:encodeForHTMLAttribute><%=toAccessPage%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="selRoles"   value=""/>
  <input type="hidden" name="selGroup"   value=""/> <%// Bug No :296864 %>

  <input type="hidden" name="scopeId" value="<xss:encodeForHTMLAttribute><%=scopeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="selectedAction" value="<xss:encodeForHTMLAttribute><%=routeAction%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="supplierOrgId" value="<xss:encodeForHTMLAttribute><%=supplierOrgId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />


 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

    <framework:sortInit
       defaultSortKey="TLastFirstName"
       defaultSortType="string"
       mapList="<%=routeMemberMapList%>"
       resourceBundle="emxComponentsStringResource"
       ascendText="emxComponents.Common.SortAscending"
       descendText="emxComponents.Common.SortDescending"
       params = "<%=XSSUtil.encodeForHTML(context, sParams)%>"/>

     <tr>
       <th width="2%" style="text-align: center;" >
        <span style="text-align: center;">
         <input type="checkbox" name="chkList" id="chkList" onclick="doCheck('ContenForm')" />
        </span>
       </th>
       <th nowrap>
         <framework:sortColumnHeader
           title="emxComponents.Common.Name"
           sortKey="TLastFirstName"
           sortType="string"/>
       </th>
       <th nowrap>
         <framework:sortColumnHeader
           title="emxComponents.Common.Type"
           sortKey="Ttype"
           sortType="string"/>
       </th>
       <th nowrap>
         <framework:sortColumnHeader
           title="emxComponents.Common.Organization"
           sortKey="OrganizationName"
           sortType="string"/>
      </th>
      <th><emxUtil:i18n localize="i18nId">emxComponents.Route.Scope</emxUtil:i18n></th>
      <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Access</emxUtil:i18n></th>
    </tr>


    <framework:mapListItr mapList="<%=routeMemberMapList%>" mapName="routeAccessMemberMap">

<%

     if(routeMemberMapList == null || routeMemberMapList.size() == 0) {


%>
      <tr>
        <td align="center" colspan="13" class="error">
          <emxUtil:i18n localize="i18nId">emxComponents.AddMembers.NoMembers</emxUtil:i18n>
        </td>
      </tr>
<%
    } else {

	   StringList memberList = new StringList();

      sTargetId           = (String)routeAccessMemberMap.get(DomainConstants.SELECT_ID);
      userName            = (String)routeAccessMemberMap.get(DomainConstants.SELECT_NAME);
      sTargetType         = (String)routeAccessMemberMap.get(DomainConstants.SELECT_TYPE);
      sTargetOrganization = (String)routeAccessMemberMap.get("OrganizationName");
      sAccess             = (String)routeAccessMemberMap.get("access");
		
	  String TLastFirstName  = (String)routeAccessMemberMap.get("TLastFirstName");
	  String Ttype         = (String)routeAccessMemberMap.get("Ttype");


      if(!memberList.contains(userName)) {

%>
       <tr class='<framework:swap id ="1" />'>
          <td style="font-size: 8pt" align="center" >
            <input type="checkbox" name="chkItem" id="chkItem" onclick="updateCheck()" value="<xss:encodeForHTMLAttribute><%=sTargetId%></xss:encodeForHTMLAttribute>"/>
            <input type="hidden" name="userRole" value="<xss:encodeForHTMLAttribute><%=userName%></xss:encodeForHTMLAttribute>"/>
            <input type="hidden" name="<%="personid"+i%>" value="<xss:encodeForHTMLAttribute><%=userName%></xss:encodeForHTMLAttribute>"/>
            <input type="hidden" name="<%="groupId"%>" value="<xss:encodeForHTMLAttribute><%=userName%></xss:encodeForHTMLAttribute>"/><% // Bug No :296864%>
          </td>

          <td><%=XSSUtil.encodeForHTML(context, TLastFirstName)%></td>

<%

		  boolean showLabel = false;
		  boolean isOwner = false;
		  if("Role".equals(sTargetType) || "Group".equals(sTargetType) || "User Group".equals(sTargetType))
		  {
			showLabel = true;
		  }else if(userName.equals(sUser)){
			 isOwner = true;
		  }
       //Start of add by: Infosys on 6/14/2005
          String i18NScopeId = "";
          if (scopeId!=null && scopeId.equals("All")){
           i18NScopeId = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.All");
           }
           else if (scopeId!=null && scopeId.equals("Organization")){
            i18NScopeId = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.Organization");
           }
           else {
           i18NScopeId  = scopeId;
           }
      //End of add by: Infosys on 6/14/2005
 %>


    <td><%=XSSUtil.encodeForHTML(context, Ttype)%>&nbsp;</td>
    <td><%=XSSUtil.encodeForHTML(context, sTargetOrganization)%>&nbsp;</td>
    <!--Modified By Infosys on 6/14/2005-->
    <td><%=XSSUtil.encodeForHTML(context, i18NScopeId)%>&nbsp;</td>
    <td>

<%
    if(!showLabel && !isOwner)
    {
            if(sAccess.equals("Read")) {
              sReadSelected="selected";
            } else if(sAccess.equals("Read Write")) {
              sReadWriteSelected="selected";
            } else if(sAccess.equals("Add")) {
              sAddSelected="selected";
            } else if(sAccess.equals("Remove")) {
              sRemoveSelected="selected";
            } else if (sAccess.equals("Add Remove")) {
              sAddRemoveSelected="selected";
            }
%>
            <input type="hidden" name="<%="access"+i%>" value="<xss:encodeForHTMLAttribute><%=sAccess%></xss:encodeForHTMLAttribute>" />

			<select name=<%="selAccess"+i%> style="font-size:8pt" onChange="ChangeAccess(<%=i%>)">
				<!-- //XSSOK -->
              <option value="Read" <%=sReadSelected%> ><emxUtil:i18n localize="i18nId">emxComponents.Access.Read</emxUtil:i18n></option>
				<!-- //XSSOK -->
			  <option value="Read Write" <%=sReadWriteSelected%> ><emxUtil:i18n localize="i18nId">emxComponents.Access.ReadWrite</emxUtil:i18n></option>
				<!-- //XSSOK -->
			  <option value="Add" <%=sAddSelected%> ><emxUtil:i18n localize="i18nId">emxComponents.Access.Add</emxUtil:i18n></option>
				<!-- //XSSOK -->
			  <option value="Remove" <%=sRemoveSelected%> ><emxUtil:i18n localize="i18nId">emxComponents.Access.Remove</emxUtil:i18n></option>
				<!-- //XSSOK -->
			  <option value="Add Remove" <%=sAddRemoveSelected%> ><emxUtil:i18n localize="i18nId">emxComponents.Access.AddRemove</emxUtil:i18n></option>

            </select>

<%
    }else if(showLabel){

%>

        <input type="hidden" name='<%="access"+i%>' value="<xss:encodeForHTMLAttribute><%=sAccess%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name='<%="selAccess"+i%>' value="Read" />
        <emxUtil:i18n localize="i18nId">emxComponents.Access.Read</emxUtil:i18n>

<%
      }else if(isOwner){
%>

        <input type="hidden" name='<%="access"+i%>' value="<xss:encodeForHTMLAttribute><%=sAccess%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name='<%="selAccess"+i%>' value="Read" />
        <emxUtil:i18n localize="i18nId">emxComponents.Access.AddRemove</emxUtil:i18n>
<%
	}
%>

        </td>
    </tr>
<%

        sAccess            = "";
        sReadSelected      = "";
        sReadWriteSelected = "";
        sAddSelected       = "";
        sRemoveSelected    = "";
        sAddRemoveSelected = "";
        i++;
        memberList.addElement(userName);
     }
   }
%>

   </framework:mapListItr>
  </table>

  <input type="hidden" name='count' value="<%=i%>" />

</form>

<%@ include file = "../emxUICommonEndOfPageInclude.inc" %>
