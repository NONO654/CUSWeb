<%--  emxComponentsAddExistingPersonRolesDialog.jsp - to assign roles to a person

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsAddExistingPersonRolesDialog.jsp.rca 1.12 Wed Oct 22 16:18:15 2008 przemek Experimental przemek $
--%>
<%@ include file = "emxComponentsDesignTopInclude.inc"%>
<%@ include file = "emxComponentsVisiblePageInclude.inc"%>
<%@ include file = "../emxPaginationInclude.inc" %>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "emxComponentsJavaScript.js"%>

<%

  DomainObject domainObj = DomainObject.newInstance(context);
  String objectId         = emxGetParameter(request,"objectId");
  String typeAlias        = emxGetParameter(request,"typeAlias");
  String queryLimit       = emxGetParameter(request,"queryLimit");
  String strUserName      = emxGetParameter(request,"userName");
  String strFirstName     = emxGetParameter(request,"firstName");
  String strLastName      = emxGetParameter(request,"lastName");
  String strCompanyName   = emxGetParameter(request,"companyName");
  String firstname        = PropertyUtil.getSchemaProperty(context,"attribute_FirstName");
  String lastname         = PropertyUtil.getSchemaProperty(context,"attribute_LastName");
  String selectedPeople[] = (String[]) session.getAttribute("selectedPeople");
  String tempPersonList="";
    for (int i = 0; i < selectedPeople.length; i++) {
     tempPersonList+=selectedPeople[i]+";";
  }
  
  String languageStr = request.getHeader("Accept-Language");

%>

<script language="JavaScript">
  // previous button implementation
  function selectPrevious()
  {
     parent.location='emxComponentsAddExistingPersonSearchResultsFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&typeAlias=<%=XSSUtil.encodeForURL(context, typeAlias)%>&userName=<%=XSSUtil.encodeForURL(context,strUserName)%>&firstName=<%=XSSUtil.encodeForURL(context,strFirstName)%>&lastName=<%=XSSUtil.encodeForURL(context,strLastName)%>&companyName=<%=XSSUtil.encodeForURL(context,strCompanyName)%>&tempPersonList=<%=XSSUtil.encodeForURL(context, tempPersonList)%>';
  }

  function selectDone()
  {
      document.searchResultForm.action = 'emxComponentsAddExistingPersonProcess.jsp';
      if (jsDblClick()) {
        document.searchResultForm.submit();
      }
  }

  function selectAllPersonsRoles(loop, whichPerson)
  {
       var operand = "";
       var bChecked = false;
       var count = eval("document.searchResultForm.elements.length");
       var typeStr = "";

       //retrieve the checkAll's checkbox value
       var allChecked = eval("document.searchResultForm.allRoles"+loop+".checked");
       for(var i = 1; i < count; i++)
       {
          if (document.searchResultForm.elements[i].type == "checkbox")
          {
             operand = "document.searchResultForm.elements[" + i + "].checked";
             if(document.searchResultForm.elements[i].name == whichPerson)
             {
                operand += " = " + allChecked + ";";
                eval (operand);
             }
          }
       }
       return;
  }

</script>

<%
  MapList personMapList = new MapList();
  HashMap tempMap = new HashMap();

  for (int i = 0; i < selectedPeople.length; i++) {
     tempMap.put(Person.SELECT_ID, selectedPeople[i]);
     personMapList.add(tempMap);
  }
  StringList sortList = new StringList(3);
  sortList.addElement("sortKey");
  sortList.addElement("sortType");
  sortList.addElement("sortDir");
  String queryString = JSPUtil.removeParametersFromQueryString(request, sortList);
  int loop = 0;
  int paginationLoop = 0;
  if(emxPage.getCurrentPage()!=-1)
   {
     paginationLoop=((int)emxPage.getCurrentPage()-1)*10;
   }
  if (emxPage.isNewQuery())
   {
     emxPage.getTable().setObjects(personMapList);
   }
  personMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());


%>
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="searchResultForm" method="post" onSubmit="selectDone(); return false;">
  <table class="list" id="searchResultList">
    <fw:sortInit
        defaultSortKey="<%= Person.SELECT_LAST_NAME %>"
        defaultSortType="string"
        resourceBundle="emxComponentsStringResource"
        mapList="<%= personMapList %>"
        params="<%= XSSUtil.encodeForHTML(context, queryString) %>"
        ascendText="emxComponents.Common.SortAscending"
        descendText="emxComponents.Common.SortDescending" />

     <tr>
      <th width="20%" nowrap="nowrap">
        <fw:sortColumnHeader
            title="emxComponents.Common.Name"
            sortKey="<%= Person.SELECT_LAST_NAME%>"
            sortType="string" />
      </th>

      <th width="15%" nowrap="nowrap">
        <fw:sortColumnHeader
            title="emxComponents.Common.Company"
            sortKey="<%= Person.SELECT_COMPANY_NAME %>"
            sortType="string" />
      </th>

      <th width="20%" nowrap="nowrap">
        <fw:sortColumnHeader
            title="emxComponents.PersonDetails.EmailAddress"
            sortKey="<%= Person.SELECT_EMAIL_ADDRESS %>"
            sortType="string" />
      </th>

      <th width="5%" nowrap><emxUtil:i18n localize="i18nId">emxComponents.Common.AllRoles</emxUtil:i18n></th>

      <th width="40%" nowrap><emxUtil:i18n localize="i18nId">emxComponents.Common.OrganizationalRoles</emxUtil:i18n></th>
    </tr>

      <fw:mapListItr mapList="<%= personMapList %>" mapName="personMap">
       <tr class='<framework:swap id ="1" />'>
<%
        // build list of things we need for each person
        domainObj.setId(selectedPeople[paginationLoop]);
        StringList selects = domainObj.getObjectSelectList(6);
        selects.addElement("attribute["+lastname+"]");
        selects.addElement("attribute["+firstname+"]");
        selects.addElement(Person.SELECT_NAME);
        selects.addElement(Person.SELECT_COMPANY_ID);
        selects.addElement(Person.SELECT_COMPANY_NAME);
        selects.addElement(Person.SELECT_EMAIL_ADDRESS);
        Map mapNext = domainObj.getInfo(context,selects);

        // get the values to display
        String fullName = mapNext.get("attribute["+lastname+"]") + ", " + mapNext.get("attribute["+firstname+"]");
        String companyId = (String)mapNext.get(Person.SELECT_COMPANY_ID);
        String companyName = (String)mapNext.get(Person.SELECT_COMPANY_NAME);
        if ((companyName == null) || companyName.equals("null"))
           companyName = "";
        String emailAddress = (String)mapNext.get(Person.SELECT_EMAIL_ADDRESS);
        String newCompanyWindowURL = "emxComponentsCompanyDetailsFS.jsp?&objectId=" + companyId;
        String allCheckBoxName = "allRoles" + loop;

%>
        <td ><img src="../common/images/iconSmallPerson.png" border="0"/>&nbsp;<%=XSSUtil.encodeForHTML(context,fullName)%></td>
        <!-- //XSSOK -->
        <td ><a href="javascript:showDetailsPopup('<%=newCompanyWindowURL%>')"><%=XSSUtil.encodeForHTML(context,companyName)%></td>
        <td ><%=XSSUtil.encodeForHTML(context, emailAddress)%></td>
        <!-- //XSSOK -->
        <td ><input type="checkbox" name="<%=allCheckBoxName%>" onClick="selectAllPersonsRoles('<%=loop%>','<%=selectedPeople[loop]%>')"/></td>
        <td nowrap>

        <table border="0">
<%
        // get the persons admin roles
        String roleAlias = "";
        String userName = (String)mapNext.get(Person.SELECT_NAME);
        String roleName = "";
        matrix.db.Person mxDbPerson = new matrix.db.Person(userName);
        mxDbPerson.open(context);

        UserItr userItr = new UserItr(mxDbPerson.getAssignments(context));

        while(userItr.next()) {
          User userObj = userItr.obj();
          if(userObj instanceof matrix.db.Role)
          {
            roleName = userItr.obj().getName();
            if( RoleUtil.isOnlyRole(context, roleName) )
            {
            roleAlias = FrameworkUtil.getAliasForAdmin(context, "role", roleName, true);

%>
            <tr><td nowrap><input type="checkbox" name="<%=selectedPeople[loop]%>" value="<%=XSSUtil.encodeForHTMLAttribute(context, roleAlias)%>" /><%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Role",roleName,languageStr))%></td></tr>
<%
	    }
          }
        }

        mxDbPerson.close(context);
        loop++;
        paginationLoop++;
%>
        </table>
        </td>

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
  <input type="hidden" name="selectedPeople" value="<xss:encodeForHTMLAttribute><%=selectedPeople%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="typeAlias" value="<xss:encodeForHTMLAttribute><%=typeAlias%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="userName" value="<xss:encodeForHTMLAttribute><%=strUserName%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="firstName" value="<xss:encodeForHTMLAttribute><%=strFirstName%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="lastName" value="<xss:encodeForHTMLAttribute><%=strLastName%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="companyName" value="<xss:encodeForHTMLAttribute><%=strCompanyName%></xss:encodeForHTMLAttribute>"/>
    
  
  </form>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "emxComponentsVisiblePageButtomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
