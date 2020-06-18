<%--  emxComponentsAddExistingPersonSearchResults.jsp - to search for Person objects

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsAddExistingPersonSearchResults.jsp.rca 1.15 Wed Oct 22 16:18:21 2008 przemek Experimental przemek $
--%>

<%@ include file = "emxComponentsDesignTopInclude.inc"%>
<%@ include file = "emxComponentsVisiblePageInclude.inc"%>
<%@ include file = "../emxPaginationInclude.inc" %>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "emxComponentsJavaScript.js"%>

<%
  DomainObject domainObj = DomainObject.newInstance(context);
  String objectId           = emxGetParameter(request,"objectId");
  String typeAlias          = emxGetParameter(request,"typeAlias");
  String lbcAccess         = emxGetParameter(request,"lbcAccess");
  String showCompanyAsLabel = emxGetParameter(request,"showCompanyAsLabel");
  String defaultCompany = emxGetParameter(request,"defaultCompany");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");

  // Only 2 lines added - Nishchal
  String keyValue = emxGetParameter(request,"keyValue");
  String callPage = emxGetParameter(request,"callPage");
  if(callPage == null || callPage.equals("null"))
  {
      callPage ="";
  }
  
%>

<script language="JavaScript">
 function newSearch() {
     // Added the parameters to the new search function - Nishchal
     <%if(Boolean.parseBoolean(lbcAccess)){%>
      parent.location='emxComponentsAddExistingPersonSearchDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&showCompanyAsLabel=<%=XSSUtil.encodeForURL(context, showCompanyAsLabel)%>&defaultCompany=<%=XSSUtil.encodeForURL(context,defaultCompany)%>&targetSearchPage=<%=XSSUtil.encodeForURL(context, targetSearchPage)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&callPage=<%=XSSUtil.encodeForURL(context, callPage)%>&lbcAccess=<%=XSSUtil.encodeForURL(context, lbcAccess)%>';
     <%}else{%>
      parent.location='emxComponentsAddExistingPersonSearchDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&showCompanyAsLabel=<%=XSSUtil.encodeForURL(context, showCompanyAsLabel)%>&defaultCompany=<%=XSSUtil.encodeForURL(context,defaultCompany)%>&targetSearchPage=<%=XSSUtil.encodeForURL(context, targetSearchPage)%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&callPage=<%=XSSUtil.encodeForURL(context, callPage)%>';
     <%}%>
  }

  // previous button implementation
  function selectPrevious()
  {
     parent.location='emxComponentsAddExistingPersonSearchDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&showCompanyAsLabel=<%=XSSUtil.encodeForURL(context, showCompanyAsLabel)%>&defaultCompany=<%=XSSUtil.encodeForURL(context,defaultCompany)%>&targetSearchPage=<%=XSSUtil.encodeForURL(context, targetSearchPage)%>';
  }

  function selectNext()
  {
  var bool=false;

    for (var i = 0; i<document.searchResultForm.elements.length; i++)
    {
      if( document.searchResultForm.elements[i].type == "checkbox" && document.searchResultForm.elements[i].checked == true && document.searchResultForm.elements[i].name == "selectedPeople")
      {

        bool=true;

      }
    }
    if(!bool)
    {
       alert("<emxUtil:i18n localize="i18nId">emxComponents.Common.PleaseMakeASelection</emxUtil:i18n>");
    }else
    {
    <%
      if (targetSearchPage != null && !"null".equals(targetSearchPage) && !"".equals(targetSearchPage)) {
    %>
        document.searchResultForm.action = '<%=XSSUtil.encodeForJavaScript(context, targetSearchPage)%>';
    <%
      } else {
    %>
      document.searchResultForm.action = 'emxComponentsAddExistingPersonRolesDialogFS.jsp';
    <%
     } 
     %>
      if (jsDblClick()) {
        document.searchResultForm.submit();
      }
    }

  }


    // Added the function - Nishchal
  function submitform()
  {
  var bool=false;

    if (document.searchResultForm.objectValues.value == "")
    {
        document.searchResultForm.objectValues.value = "|";
    }

    for (var i = 0; i<document.searchResultForm.elements.length; i++)
    {
      if(document.searchResultForm.elements[i].type == "checkbox" && document.searchResultForm.elements[i].checked == true && document.searchResultForm.elements[i].name == "selectedPeople")
      {
        bool = true;

        if (document.searchResultForm.objectValues.value.indexOf("|"+document.searchResultForm.elements[i].value+"|") == -1)
        {
            document.searchResultForm.objectValues.value = document.searchResultForm.objectValues.value + document.searchResultForm.elements[i].value + "|";
        }
      }
    }
    if(bool)
    {
        document.location.href=fnEncode("emxComponentsObjectAccessAddUsersProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&userType=Person&userList=" + document.searchResultForm.objectValues.value);
    }
    else
    {
        alert("<emxUtil:i18n localize="i18nId">emxComponents.Common.PleaseMakeASelection</emxUtil:i18n>");
    }
  }

</script>

<%
  String typePattern    = PropertyUtil.getSchemaProperty(context,"type_Person");
  String vaultPattern   = "*";

  SelectList selects    = new SelectList(4);
  MapList cached        = null;
  String whereClause    = "";

  // Check query limit

  String queryLimit = emxGetParameter(request,"queryLimit");
  if (queryLimit == null || queryLimit.equals("null") || queryLimit.equals("")){
    queryLimit = "0";
  }

  String strUserName    = emxGetParameter(request,"userName");
  String strFirstName   = emxGetParameter(request,"firstName");
  String strLastName    = emxGetParameter(request,"lastName");
  String strCompanyName = emxGetParameter(request,"companyName");
  String strPersonList = emxGetParameter(request,"tempPersonList");
  StringList tempPersonStringList = new StringList();
   if (strPersonList!=null) {
  StringTokenizer tempPersonList = new StringTokenizer(strPersonList,";");
      while(tempPersonList.hasMoreTokens()) {
          tempPersonStringList.addElement((String)tempPersonList.nextElement());
     }
   }
  if(strFirstName==null || strFirstName.length()<=0 || strFirstName.equals("null")){
    strFirstName="";
  }
  if(strLastName==null || strLastName.length()<=0 || strLastName.equals("null")){
      strLastName="";
  }
  if(strUserName==null || strUserName.length()<=0 || strUserName.equals("null")){
      strUserName="";
  }

  String firstname    = PropertyUtil.getSchemaProperty(context,"attribute_FirstName");
  String lastname     = PropertyUtil.getSchemaProperty(context,"attribute_LastName");
  String employeerel  = PropertyUtil.getSchemaProperty(context,"relationship_Member");
  String employeeRelationship  = DomainConstants.RELATIONSHIP_EMPLOYEE;
  String SELECT_ROLE_ASSIGNMENTS = "assignments";

	if(!strFirstName.equalsIgnoreCase("*")) {
		if(strFirstName.indexOf("*") == -1) {
			whereClause += "(\"" + "attribute["+firstname+"]\"" + " == " + "\"" + strFirstName + "\") && " ;
		}else{
			whereClause += "(\"" + "attribute["+firstname+"]\"" + " ~= " + "\"" + strFirstName + "\") && " ;
		}
	}
	if(!strLastName.equalsIgnoreCase("*")) {
		if(strLastName.indexOf("*") == -1) {
			whereClause += "(\"" + "attribute["+lastname+"]\"" + " == " + "\"" + strLastName + "\") && ";
		}else{
			whereClause += "(\"" + "attribute["+lastname+"]\"" + " ~= " + "\"" + strLastName + "\") && ";
		}
	}
	if(!strCompanyName.equalsIgnoreCase("*")) {
		if(strCompanyName.indexOf("*") == -1) {
		  whereClause += "((to["+employeeRelationship+"].from.name == \""+strCompanyName+"\")) && ";
		}else{
		  whereClause += "((to["+employeeRelationship+"].from.name ~= \""+strCompanyName+"\")) && ";
		}
	}
	whereClause += "!(to["+employeerel+"].from.id == \"" + objectId + "\")";

    // Nishchal
    if("emxComponentsObjectAccessUsersDialog".equalsIgnoreCase(callPage))
    {
        whereClause += " && (name!=\""+context.getUser()+"\")" ;
    }

  selects.addAttribute(firstname);
  selects.addAttribute(lastname);
  selects.addElement(Person.SELECT_ID);
  selects.addElement(Person.SELECT_NAME);
  selects.addElement(Person.SELECT_COMPANY_NAME);
  selects.addElement(Person.SELECT_COMPANY_ID);
  selects.addElement(Person.SELECT_EMAIL_ADDRESS);
  if (emxPage.isNewQuery()) {
     MapList mapList = DomainObject.findObjects(context,
                                                      typePattern,
                                                      strUserName,
                                                      null,
                                                      null,
                                                      vaultPattern,
                                                      whereClause,
                                                      null,
                                                      true,
                                                      selects,
                                                      Short.parseShort(queryLimit));
     emxPage.getTable().setObjects(mapList);
     emxPage.getTable().setSelects(selects);
     Iterator itr = mapList.iterator();
     matrix.db.Person mxDbPerson = null;
     Map dataMap = null;
     String roleName = null;
     String userName = null;
     UserItr userItr = null;
     User userObj = null;
     while(itr.hasNext()) {
       dataMap = (Map)itr.next();
       userName = (String)dataMap.get(Person.SELECT_NAME);
       roleName = "";
       mxDbPerson = new matrix.db.Person(userName);
       mxDbPerson.open(context);
       userItr = new UserItr(mxDbPerson.getAssignments(context));
       while(userItr.next()) {
         userObj = userItr.obj();
         if(userObj instanceof matrix.db.Role)
         {
           if (!roleName.equals("")) {
              roleName += ", ";
           }
           roleName += userObj.getName();
         }
       }
       mxDbPerson.close(context);
       dataMap.put(SELECT_ROLE_ASSIGNMENTS,roleName);
     }
  }

  MapList personMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
  StringList sortList = new StringList(3);
  sortList.addElement("sortKey");
  sortList.addElement("sortType");
  sortList.addElement("sortDir");
  String queryString = JSPUtil.removeParametersFromQueryString(request, sortList);

%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

<form name="searchResultForm" method="post" target="_parent">
  <table class="list" id="list">
    <fw:sortInit
        defaultSortKey="<%= Person.SELECT_LAST_NAME %>"
        defaultSortType="string"
        resourceBundle="emxComponentsStringResource"
        mapList="<%= personMapList %>"
        params="<%= XSSUtil.encodeForHTML(context, queryString) %>"
        ascendText="emxComponents.Common.SortAscending"
        descendText="emxComponents.Common.SortDescending" />

     <tr>
      <th  >
        <input type="checkbox" name="checkAll" onClick="allSelected('searchResultForm')" />
      </th>

      <th width="20%" >
        <fw:sortColumnHeader
            title="emxComponents.Common.Name"
            sortKey="<%= Person.SELECT_LAST_NAME%>"
            sortType="string" />
      </th>

      <th width="20%" >
        <fw:sortColumnHeader
            title="emxComponents.Common.Company"
            sortKey="<%= Person.SELECT_COMPANY_NAME %>"
            sortType="string" />
      </th>

      <th width="20%" >
        <fw:sortColumnHeader
            title="emxComponents.PersonDetails.EmailAddress"
            sortKey="<%= Person.SELECT_EMAIL_ADDRESS %>"
            sortType="string" />
      </th>
      <th width="35%" >
        <fw:sortColumnHeader
            title="emxComponents.Common.RoleAssignments"
            sortKey="<%= SELECT_ROLE_ASSIGNMENTS %>"
            sortType="string" />
      </th>

      <fw:mapListItr mapList="<%= personMapList %>" mapName="personMap">
       <tr class='<framework:swap id ="1" />'>
<%
        // get the persons admin roles
        String roleName = (String)personMap.get(SELECT_ROLE_ASSIGNMENTS);
        roleName = i18nNow.getRoleI18NString(roleName, request.getHeader("Accept-Language"));

        String fullName = personMap.get("attribute["+lastname+"]") + ", " + personMap.get("attribute["+firstname+"]");
        String companyId = (String)personMap.get(Person.SELECT_COMPANY_ID);
        String companyName = (String)personMap.get(Person.SELECT_COMPANY_NAME);
        if ((companyName == null) || companyName.equals("null"))
           companyName = "";
        String emailAddress = (String)personMap.get(Person.SELECT_EMAIL_ADDRESS);

        String newCompanyWindowURL = "emxComponentsCompanyDetailsFS.jsp?&objectId=" + companyId;

%>

        <td ><input type="checkbox" name="selectedPeople" value="<xss:encodeForHTMLAttribute><%=personMap.get("id")%></xss:encodeForHTMLAttribute>" onclick="updateSelected('searchResultForm')"
    <%
         if (tempPersonStringList.contains((String)personMap.get("id")))
          {
    %>
         checked
    <%
          }
    %>
       /></td>
        <td ><img src="../common/images/iconSmallPerson.png" border="0" />&nbsp;<%=XSSUtil.encodeForHTML(context, fullName)%></td>
        <!-- //XSSOK -->
        <td ><a href="javascript:showDetailsPopup('<%=newCompanyWindowURL%>')"><%=XSSUtil.encodeForHTML(context, companyName)%></td>
        <td ><%=XSSUtil.encodeForHTML(context, emailAddress)%></td>
        <td ><%=XSSUtil.encodeForHTML(context, roleName)%></td>


       </tr>
      </fw:mapListItr>


<%
  if (personMapList.size() == 0) {
%>
    <tr>
      <td align="center" colspan="13" class="error">
      	<emxUtil:i18n localize="i18nId">emxComponents.Common.NoMatchFound</emxUtil:i18n>
      </td>
    </tr>
<%
  }

%>

    </table>
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="typeAlias" value="<xss:encodeForHTMLAttribute><%=typeAlias%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="queryLimit" value="<xss:encodeForHTMLAttribute><%=queryLimit%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="userName" value="<xss:encodeForHTMLAttribute><%=strUserName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="firstName" value="<xss:encodeForHTMLAttribute><%=strFirstName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="lastName" value="<xss:encodeForHTMLAttribute><%=strLastName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="companyName" value="<xss:encodeForHTMLAttribute><%=strCompanyName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="showCompanyAsLabel" value="<xss:encodeForHTMLAttribute><%=showCompanyAsLabel%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="defaultCompany" value="<xss:encodeForHTMLAttribute><%=defaultCompany%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="targetSearchPage" value="<xss:encodeForHTMLAttribute><%=targetSearchPage%></xss:encodeForHTMLAttribute>" />

<!--Nishchal Added-->
  <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="callPage" value="<xss:encodeForHTMLAttribute><%=callPage%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="objectValues" value="" />

</form>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "emxComponentsVisiblePageButtomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
