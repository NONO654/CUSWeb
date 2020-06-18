 <%--  emxComponentsFindMemberDialog.jsp   -  Search for members in the company
Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsFindMemberDialog.jsp.rca 1.14 Wed Oct 22 16:18:40 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>

<%
    com.matrixone.apps.common.Person contextPerson = com.matrixone.apps.common.Person.getPerson(context);
//added for bug 299784
    String sCurrentFile           = request.getRequestURI();
    if(sCurrentFile!=null && sCurrentFile.length()>0)
    {
        sCurrentFile=sCurrentFile.substring(sCurrentFile.lastIndexOf("/")+1,sCurrentFile.length());
        sCurrentFile=sCurrentFile.trim();
    }
//till here
  String formName   = emxGetParameter(request,"formName");
  String fieldNameDisplay  = emxGetParameter(request,"fieldNameDisplay");
  String fieldNameActual  = emxGetParameter(request,"fieldNameActual");
%>

<script language="javascript">
  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }


  function doSearch() {
    if(jsIsClicked()) {

        return;
    }
    var varLastName  = trim(document.findDialog.lastName.value);
    var varFirstName = trim(document.findDialog.firstName.value);
    var varUserName  = trim(document.findDialog.userName.value);

    if(varLastName=="") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.LastNameRequired</emxUtil:i18nScript>");
      document.findDialog.lastName.focus();
      return;
    } else if(varFirstName=="") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.FirstNameRequired</emxUtil:i18nScript>");
      document.findDialog.firstName.focus();
      return;
    } else if(varUserName=="") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.PersonDialog.UserNameRequired</emxUtil:i18nScript>");
      document.findDialog.userName.focus();
      return;
    } else {
      document.findDialog.lastName.value =  varLastName;
      document.findDialog.firstName.value = varFirstName;
      document.findDialog.userName.value = varUserName;
      if(jsDblClick()) {
        startProgressBar(true);
        document.findDialog.submit();
      }
      return;
    }
  }


  function selectMembers() {
    //Bug 299784 - Modified action link
    document.findDialog.action="../common/emxTable.jsp";
    document.findDialog.submit();
    return;
  }
  function change()
  {

  }


</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
 <!--Bug 299784 - Modified action -->
<form name="findDialog" method="post" onSubmit="doSearch(); return false" target="_parent" action="../common/emxTable.jsp"">

  <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <tr>
      <td width="150" nowrap  class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n></td>
      <td nowrap  width="380" class="inputField"><img src="../common/images/iconPerson16.png" border="0"name="imgPerson" id="imgPerson" alt="<emxUtil:i18n localize='i18nId'>emxComponents.Common.Person</emxUtil:i18n>" /><emxUtil:i18n localize="i18nId">emxComponents.Common.Person</emxUtil:i18n></td>
    </tr>
    <tr>
     <td width="150" class="label"><label for="UserName"><emxUtil:i18n localize="i18nId">emxComponents.Common.UserName</emxUtil:i18n></label></td>
     <td width="380" class="inputField"><input type="Text" name="userName" value="*" size="20" /></td>
    </tr>

    <tr>
     <td width="150" class="label"><label for="LastName"><emxUtil:i18n localize="i18nId">emxComponents.Common.LastName</emxUtil:i18n></label></td>
     <td width="380" class="inputField"><input type="Text" name="lastName" value="*" size="20" /></td>
    </tr>

    <tr>
     <td width="150" class="label"><label for="FirstName"><emxUtil:i18n localize="i18nId">emxComponents.Common.FirstName</emxUtil:i18n></label></td>
     <td width="380" class="inputField"><input type="Text" name="firstName" value="*" size="20" /></td>
    </tr>

    <tr>
      <td nowrap  width="150" class="label"><label for="Organization"><emxUtil:i18n localize="i18nId">emxComponents.Common.Organization</emxUtil:i18n></label></td>
      <td nowrap width="380" class="inputField">
<%
         String customerStr     = PropertyUtil.getSchemaProperty(context, "relationship_CollaborationPartner");
		 String TYPE_ORGANIZATION = PropertyUtil.getSchemaProperty(context,"type_Organization");
		 String TYPE_COMPANY = PropertyUtil.getSchemaProperty(context,"type_Company");
		 String TYPE_BUSINESS_UNIT = PropertyUtil.getSchemaProperty(context,"type_BusinessUnit");
		 Person person  = (Person) com.matrixone.apps.common.Person.getPerson(context);
         Company myOrganization = (Company) person.getCompany(context);
         String relBusinessUnitEmployee = PropertyUtil.getSchemaProperty(context,"relationship_BusinessUnitEmployee");
         String str = "relationship["+relBusinessUnitEmployee+"].from.id";
         StringList strList = new StringList(1);
         strList.addElement(str);
         BusinessObjectWithSelect busWithSel = person.select(context,strList);
         String strBusUnitId = busWithSel.getSelectData(str);
         BusinessObject myBusinessUnit = null;
         if(strBusUnitId != null && !"".equals(strBusUnitId))
         {
            myBusinessUnit = new BusinessUnit(strBusUnitId);
         }


         BusinessObjectList organizationList = new BusinessObjectList();
         organizationList.add( myOrganization );

         // add the list of companies collaborating with your Parent Comapny
         myOrganization.open( context );
         String myOrganizationId = myOrganization.getObjectId();
         
         
            //Bug 364023 : Start
            /*   RelationshipItr collaborationRelItr = new RelationshipItr( myOrganization.getFromRelationship( context ));
             while (collaborationRelItr.next()) {
             if ( collaborationRelItr.obj().getTypeName().equals( customerStr )) {
             organizationList.add( collaborationRelItr.obj().getTo());
             }
             }*/

            StringList strSelectables = new StringList(1);
            strSelectables.add(DomainConstants.SELECT_ID);

            MapList mapList = myOrganization.getRelatedObjects(context,
                    customerStr, // relationship pattern
                    TYPE_ORGANIZATION, // type pattern
                    strSelectables, // object selects
                    null, false, // to
                    true, // from
                    (short) 0, // level
                    null, null);
            if (mapList != null) {
                for (int count = 0; count < mapList.size(); count++) {
                    Map map = (Map)mapList.get(count);
                	String strId = (String) map.get("id");
                    DomainObject bObject = new DomainObject(strId);
                    organizationList.add(bObject);
                }
            }
            /*											
             // add the list of companies collaborating with BusinessUnit if you are a BU employee
             if (myBusinessUnit != null) {
             myBusinessUnit.open(context);
             collaborationRelItr = new RelationshipItr(myBusinessUnit.getFromRelationship(context));
             while (collaborationRelItr.next()) {
             if (collaborationRelItr.obj().getTypeName().equals(customerStr)) {
             organizationList.add(collaborationRelItr.obj().getTo());
             }
             }
             }*/
             //Bug 364023 : End

         //sorting of company names disregarding case begins.
         Vector orgVect = new Vector(organizationList.size());
         Vector orgDetails = new Vector(2);
         HashMap orgMap = new HashMap();

         BusinessObjectItr orgItr = new BusinessObjectItr( organizationList );
         
         while (orgItr.next()) {
           orgDetails = new Vector(2);
           DomainObject organization = (DomainObject)orgItr.obj();
           String organizationName =  organization.getInfo(context,"name");
           // store as HashMap (String, Vector)
           if(!orgVect.contains(organizationName)){
           orgDetails.add(organizationName);
           orgDetails.add(organization.getObjectId());
           orgMap.put(organizationName,orgDetails);
           orgVect.addElement(organizationName);
           }
         }

         //sort Vector
         java.util.Collections.sort(orgVect);

         int vecSize = orgVect.size();

         //sorting of company names ends.
        if(vecSize>1)
        {
%><!--for bug 299784 name of select is changed-->
         <select name="orgId" size="1" >
<%
         for (int i=0;i<orgVect.size();i++){
           String orgKey = (String)orgVect.elementAt(i);
           orgDetails = (Vector)orgMap.get(orgKey);
           String organizationName = (String)orgDetails.elementAt(0);
           String organizationId = (String)orgDetails.elementAt(1);
           if ( organizationId.equals( myOrganizationId ) ) {
%>
             <option value="<%=XSSUtil.encodeForHTMLAttribute(context,organizationId)%>" selected><%=XSSUtil.encodeForHTML(context,organizationName)%></option>
<%
           } else {
%>
             <option value="<%=XSSUtil.encodeForHTMLAttribute(context,organizationId)%>" ><%=XSSUtil.encodeForHTML(context,organizationName)%></option>
<%
           }
         }
%>
        </select>

<%
        }
        else
        {
           String orgKey = (String)orgVect.elementAt(0);
           orgDetails = (Vector)orgMap.get(orgKey);
           String organizationName = (String)orgDetails.elementAt(0);
           String organizationId = (String)orgDetails.elementAt(1);

%>
            <%= XSSUtil.encodeForHTML(context,organizationName) %>&nbsp;
            <!--//Bug 299784 - Added hidden paramaters for table body-->
            <input type="hidden" name="orgId" value="<%=XSSUtil.encodeForHTMLAttribute(context,organizationId)%>" />
<%
        }
%>

      </td>
    </tr>
  </table>

    <input type="hidden" name="table" value="APPPersonSearchResults" />
    <input type="hidden" name="Style" value="dialog" />
    <input type="hidden" name="program" value="emxPerson:getPersonSearchResult" />
    <input type="hidden" name="toolbar" value="APPAbsenceDelegatePersonSearchToolBar" />
    <input type="hidden" name="header" value="emxComponents.FindLike.Common.Results" />
    <input type="hidden" name="selection" value="single" />
    <input type="hidden" name="QueryLimit" value="" />
    <input type="hidden" name="pagination" value="" />
    <input type="hidden" name="listMode" value="search" />
    <input type="hidden" name="SubmitURL" value="../components/emxPersonSearchProcess.jsp?" />
    <input type="hidden" name="SubmitButton" value="true" />
    <input type="hidden" name="CancelButton" value="true" />
    <input type="hidden" name="CancelLabel" value="emxComponents.Button.Close" />
    <input type="hidden" name="HelpMarker" value="emxhelpselectuserresults" />
    <input type="hidden" name="languageStr" value="<%=XSSUtil.encodeForHTMLAttribute(context, request.getHeader("Accept-Language").toString())%>" />
    <input type="hidden" name="sortColumnName" value="Name" />
    <input type="hidden" name="sortDirection" value="ascending" />
    <input type="hidden" name="suiteKey" value="Components" />
    <input type="hidden" name="StringResourceFileId" value="emxComponentsStringResource" />
    <input type="hidden" name="SuiteDirectory" value="components" />
    <!-- //XSSOK -->
    <input type="hidden" name="FromFile" value="<%= XSSUtil.encodeForHTMLAttribute(context,sCurrentFile)%>" />
    <input type="hidden" name="formName" value="<%= XSSUtil.encodeForHTMLAttribute(context,formName)%>" />
    <input type="hidden" name="fieldNameDisplay" value="<%= XSSUtil.encodeForHTMLAttribute(context,fieldNameDisplay)%>" />
    <input type="hidden" name="fieldNameActual" value="<%= XSSUtil.encodeForHTMLAttribute(context,fieldNameActual)%>" />    
    



</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
