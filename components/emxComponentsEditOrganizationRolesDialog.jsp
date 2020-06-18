<%--  emxComponentsEditOrganizationRolesDialog.jsp - edit roles assigned to a person

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsEditOrganizationRolesDialog.jsp.rca 1.9 Tue Oct 28 23:01:05 2008 przemek Experimental przemek $
--%>
<%@ include file = "emxComponentsDesignTopInclude.inc"%>
<%@ include file = "emxComponentsVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "emxComponentsJavaScript.js"%>

<%
  DomainObject domainObj = DomainObject.newInstance(context);
  String objectId         = emxGetParameter(request,"objectId");
  String languageStr    = request.getHeader("Accept-Language");
  String relId         = emxGetParameter(request,"relId");
  String typeAlias = emxGetParameter(request,"typeAlias");
  String sChecked = "";

  // we need to get the type of the object that we want to connect the eople to so that
  // we know what relationship to use later
  MQLCommand mqlCom = new MQLCommand();
   
  String strType =  MqlUtil.mqlCommand(context,"print connection $1 select $2 dump $3",relId,"from.type","|");

  BusinessObject busObj = new BusinessObject(objectId);
  busObj.open(context);
  String sObjectName = busObj.getName();
  busObj.close(context);

  // get the persons admin roles
  String roleAlias = "";
  String roleName = "";

  matrix.db.Person mxDbPerson = new matrix.db.Person(sObjectName);
  mxDbPerson.open(context);

  UserItr userItr = new UserItr(mxDbPerson.getAssignments(context));

  MapList roleMapList = new MapList();

  while(userItr.next()) {
    HashMap tempMap = new HashMap();
    User userObj = userItr.obj();
    if(userObj instanceof matrix.db.Role)
    {
      roleName = userItr.obj().getName();
      roleAlias = FrameworkUtil.getAliasForAdmin(context, "role", roleName, true);
      if( roleAlias != null )
      {

      tempMap.put("roleName", roleName);
      tempMap.put("roleAlias", roleAlias);
      roleMapList.add(tempMap);
      }
    }
  }

  mxDbPerson.close(context);

  // get roles person already has assigned to them
  StringList roleStringList = Organization.getMemberRoles(context, relId);
  StringList leadRoles = new StringList();
  StringList sortList = new StringList(3);
  sortList.addElement("sortKey");
  sortList.addElement("sortType");
  sortList.addElement("sortDir");
  String queryString = JSPUtil.removeParametersFromQueryString(request, sortList);
  int loop = 0;
%>



<% 
// To get Person Lead Roles
  String DefinedLeadResponsibilities = " ";
  String iResultFirst = Organization.getPersonLeadRoles(context, objectId, relId);
  String sLeadResponsibility = PropertyUtil.getSchemaProperty(context,"relationship_LeadResponsibility");
  
  // Check whether LeadRoles is true or not.
  // Do not display the lead roles column if Lead Responsibility relationship is not present.
  if((EnoviaResourceBundle.getProperty(context, "emxComponents", context.getLocale(), "emxComponents.RCO.EnableLeadRolesForOrganizations").equals("false")) || ("".equals(sLeadResponsibility)))
	DefinedLeadResponsibilities = "";


// End
%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

<form name="searchResultForm" method="post" onSubmit="selectDone(); return false;">
  <table class="list" id="UITable">
     <tr>
      <th width="5%">
        <input type="checkbox" name="checkAll" onClick="allSelected('searchResultForm')" />
      </th>
      <th width="40%" nowrap><emxUtil:i18n localize="i18nId">emxComponents.Common.OrganizationalRoles</emxUtil:i18n></th>

<% if (DefinedLeadResponsibilities.equals(" ")) { %>
      <th width="40%" nowrap><emxUtil:i18n localize="i18nId">emxComponents.Common.LeadRoles</emxUtil:i18n></th>

<% } %>
     </tr>

      <fw:mapListItr mapList="<%= roleMapList %>" mapName="roleMap">
       <tr class='<fw:swap id="even"/>'>
<%
        // get the values to display
        String sRoleName = (String)roleMap.get("roleName");
        sRoleName=i18nNow.getAdminI18NString("Role",sRoleName.trim(),languageStr);
        String sRoleAlias = (String)roleMap.get("roleAlias");
        sChecked = "";

        for (int i = 0; i < roleStringList.size(); i++)
        {
           if (roleStringList.get(i).equals(sRoleAlias))
           {
              sChecked = "checked";
              break;
           }

        }
%>
        <td>
          <input type="checkbox" name="roleAlias" <%=XSSUtil.encodeForHTML(context, sChecked)%> value="<xss:encodeForHTMLAttribute><%=sRoleAlias%></xss:encodeForHTMLAttribute>" />
        </td>
        <td>
          <%=XSSUtil.encodeForHTML(context, sRoleName)%>
        </td>

	

		
		 <% if (DefinedLeadResponsibilities.equals(" ")) { 
			  if(iResultFirst.contains(sRoleAlias)) {
		%>
			<td>
		 <input type="checkbox" name="LeadRole" checked value="<%=XSSUtil.encodeForHTMLAttribute(context, sRoleAlias) %>" /> </td>
		 <% } else { %>
		 <td><input type="checkbox" name="LeadRole"  value="<%=XSSUtil.encodeForHTMLAttribute(context, sRoleAlias) %>" />
		 </td>
		 <% leadRoles.addElement(sRoleAlias);
		       }
		     } %>
		

       </tr>
      </fw:mapListItr>


<%
	String iResult2 = Organization.checkLeadRoleAssign(context, objectId, relId, languageStr,(String[])leadRoles.toArray(new String[0]));
	String iresult = "";
	String leadUser = "";
	if (!iResult2.equals("")) {
	    String sIDs[] = iResult2.split("#");
	    leadUser = sIDs[sIDs.length-1];
	    iresult = iResult2.substring(0, iResult2.lastIndexOf("#"));
	}
	if (roleMapList.size() == 0) {
%>
    <tr>
      <td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.Common.NoMatchFound</emxUtil:i18n></td>
    </tr>
<%
  }

%>

    </table>
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="relId" value="<xss:encodeForHTMLAttribute><%=relId%></xss:encodeForHTMLAttribute>" />

  <script language="JavaScript">
  function selectDone()
  { 
    // Added for IR-059528V6R2011x starts
  	var items = "<%=XSSUtil.encodeForJavaScript(context, iresult)%>".split("#");
  	var leadUsers = "<%=XSSUtil.encodeForJavaScript(context, leadUser)%>".split("\n");
	var array = [];	
	var leadArray = [];	
	var mappedids = [];
	var finalArray = [];
	var isAssigned = false;
	for(var i = 0 ; i < items.length;)
	{
		array.push( { id : items[i], value : items[i+1] });
		 i = i+2;
	}
	for(var x = 0 ; x < leadUsers.length; x++)
	{
		leadArray.push( { id : x, value : leadUsers[x] });
	}
	for(var y = 0 ; y < leadArray.length; y++)
	{
		finalArray.push( { id : leadArray[y].value, value : array[y].value });
	}	
	for (var i = 1; i<document.searchResultForm.elements.length; i++) 
	{
		var obj = document.searchResultForm.elements[i]; 	
		for(var k = 0; k < finalArray.length; k++)
		{
			if(finalArray[k].value == obj.value && obj.checked && obj.type == "checkbox" && obj.name == "LeadRole")
			{
				mappedids.push(finalArray[k].id);
				isAssigned = true;
			}
		}
	}
   	if(isAssigned)
   	{
   	        if(confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.checkLeadRoleAssign</emxUtil:i18nScript>\n" + mappedids.join("\n")))
  	  		{
				submit();
      	    }
    }else{
				submit();
    }
 }
 // Added for IR-059528V6R2011x Ends
 function submit()
 {
 	document.searchResultForm.action = 'emxComponentsEditOrganizationRolesProcess.jsp';
	if (jsDblClick()) {
		 document.searchResultForm.submit();
    }
 }

</script>
</form>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "emxComponentsVisiblePageButtomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
