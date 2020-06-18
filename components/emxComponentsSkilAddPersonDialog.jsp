<%--  emxComponentsAddExistingPersonRolesDialog.jsp - to assign roles to a person

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsSkilAddPersonDialog.jsp.rca 1.8 Wed Oct 22 16:18:33 2008 przemek Experimental przemek $
--%>
<%@ include file = "emxComponentsDesignTopInclude.inc"%>
<%@ include file = "emxComponentsVisiblePageInclude.inc"%>
<%@ include file = "../emxPaginationInclude.inc" %>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "emxComponentsJavaScript.js"%>
<%@ include file = "../emxJSValidation.inc"%>

<%

  DomainObject domainObj = DomainObject.newInstance(context);
  String objectId         = emxGetParameter(request,"objectId");
  String typeAlias        = emxGetParameter(request,"typeAlias");
  String queryLimit       = emxGetParameter(request,"queryLimit");
  String strUserName      = emxGetParameter(request,"userName");
  String strFirstName     = emxGetParameter(request,"firstName");
  String strLastName      = emxGetParameter(request,"lastName");
  String strCompanyName   = emxGetParameter(request,"companyName");

  String showCompanyAsLabel = emxGetParameter(request,"showCompanyAsLabel");
  String defaultCompany = emxGetParameter(request,"defaultCompany");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");

  String firstname        = PropertyUtil.getSchemaProperty(context,"attribute_FirstName");
  String lastname         = PropertyUtil.getSchemaProperty(context,"attribute_LastName");
  String selectedPeople[] = (String[]) session.getAttribute("selectedPeople");
  String tempPersonList="";
  String tempSelectPeople[] = new String[selectedPeople.length];
  String sRelHasBusinessSkill  = PropertyUtil.getSchemaProperty(context, "relationship_hasBusinessSkill" );
  String sTypeBusinessSkill  = PropertyUtil.getSchemaProperty(context, "type_BusinessSkill" );
  StringList commonSelects = new StringList();
  StringList alertSelects = new StringList();
  String alertNames = "";
  int count =0;
  for (int i = 0; i < selectedPeople.length; i++) {
     domainObj.setId(selectedPeople[i]);
     MapList tempList = domainObj.getRelatedObjects(context, sRelHasBusinessSkill, sTypeBusinessSkill, commonSelects, commonSelects, false, true, (short)1, "id=="+objectId, "");
     if(tempList.size() > 0){
        alertSelects.addElement("attribute["+lastname+"]");
        alertSelects.addElement("attribute["+firstname+"]");
        Map mapNext = domainObj.getInfo(context, alertSelects);
        alertNames += mapNext.get("attribute["+lastname+"]") + ", " + mapNext.get("attribute["+firstname+"]") + "\\n";
     }
     else{
        tempPersonList+=selectedPeople[i]+";";
        tempSelectPeople[count] = selectedPeople[i];
        count++;
     }
  }
  selectedPeople = new String[count];
  for(int i=0; i <count; i++){
    selectedPeople[i] = tempSelectPeople[i];    
  }

%>

<script language="JavaScript">
  // previous button implementation
  function selectPrevious()
  {
     parent.location='emxComponentsAddExistingPersonSearchResultsFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&typeAlias=<%=XSSUtil.encodeForURL(context, typeAlias)%>&userName=<%=XSSUtil.encodeForURL(context, strUserName)%>&firstName=<%=XSSUtil.encodeForURL(context, strFirstName)%>&lastName=<%=XSSUtil.encodeForURL(context, strLastName)%>&companyName=<%=XSSUtil.encodeForURL(context, strCompanyName)%>&tempPersonList=<%=XSSUtil.encodeForURL(context, tempPersonList)%>&showCompanyAsLabel=<%=XSSUtil.encodeForURL(context, showCompanyAsLabel)%>&defaultCompany=<%=XSSUtil.encodeForURL(context, defaultCompany)%>&targetSearchPage=<%=XSSUtil.encodeForURL(context, targetSearchPage)%>';
  }

  function selectDone()
  {
      var objForm = document.searchResultForm;
      var selection = true;
      var selectNumeric = true;
      for (var i=0; i < objForm.elements.length; i++){
        if (objForm.elements[i].name.indexOf('Experience') > -1){
            if(objForm.elements[i].value.length <= 0){ selection = false;
            }else{
            	//[Modified::Jan 11, 2011:s4e:R211:IR-083958V6R2012 ::Start] 
            	var fieldValue = objForm.elements[i].value;
            	if(trimWhitespace(fieldValue) == "" || (fieldValue) < 0 || isNaN(fieldValue) || (fieldValue % 1 != 0) ){
                    alert("<emxUtil:i18n localize="i18nId">emxComponents.Alert.IntegerPositive</emxUtil:i18n>");
                  //[Modified::Jan 11, 2011:s4e:R211:IR-083958V6R2012 ::End]
                    selectNumeric = false;
                }
            }
            
        }
      }
      if(selection && selectNumeric){
        document.searchResultForm.action = 'emxComponentsSkillAddPersonProcess.jsp';
        if (jsDblClick()) {
          document.searchResultForm.submit();
        }
      } else if(selectNumeric == true && selection == false)
        alert("<emxUtil:i18n localize="i18nId">emxComponents.Alert.EnterExperience</emxUtil:i18n>");
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

 
  Map attriMap = DomainRelationship.getTypeAttributes(context,PropertyUtil.getSchemaProperty(context, "relationship_hasBusinessSkill") );
  Map CompetencyMap = (Map)attriMap.get(PropertyUtil.getSchemaProperty(context,"attribute_Competency"));
  StringList CompetencyList = (StringList)CompetencyMap.get("choices");
  StringList CompetencyDispList = new StringList(CompetencyList.size());
  StringItr CompetencyListItr =new StringItr(CompetencyList);
  while(CompetencyListItr.next())
  {
    CompetencyDispList.addElement(i18nNow.getRangeI18NString(PropertyUtil.getSchemaProperty(context,"attribute_Competency"),(String)CompetencyListItr.obj(), request.getHeader("Accept-Language")));
  }
  int iCount = -1;

%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="searchResultForm" method="post">
 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

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

      <th width="20%" nowrap="nowrap">
        <fw:sortColumnHeader
            title="emxComponents.Common.UserName"
            sortKey="<%= Person.SELECT_NAME %>"
            sortType="string" />
      </th>
      
      <th width="15%" nowrap="nowrap">
        <fw:sortColumnHeader
            title="emxComponents.Common.Company"
            sortKey="<%= Person.SELECT_COMPANY_NAME %>"
            sortType="string" />
      </th>



      <th width="5%" nowrap><emxUtil:i18n localize="i18nId">emxComponents.Common.Competency</emxUtil:i18n></th>

      <th width="40%" nowrap><emxUtil:i18n localize="i18nId">emxComponents.Common.Experience</emxUtil:i18n></th>
    </tr>

      <fw:mapListItr mapList="<%= personMapList %>" mapName="personMap">
       <tr class='<fw:swap id="even"/>'>
<%
        // build list of things we need for each person
        domainObj.setId(selectedPeople[paginationLoop]);
        StringList selects = domainObj.getObjectSelectList(6);
        selects.addElement("attribute["+lastname+"]");
        selects.addElement("attribute["+firstname+"]");
        selects.addElement(Person.SELECT_NAME);
        selects.addElement(Person.SELECT_COMPANY_ID);
        selects.addElement(Person.SELECT_COMPANY_NAME);
        Map mapNext = domainObj.getInfo(context,selects);

        // get the values to display
        String fullName = mapNext.get("attribute["+lastname+"]") + ", " + mapNext.get("attribute["+firstname+"]");
        String companyId = (String)mapNext.get(Person.SELECT_COMPANY_ID);
        String companyName = (String)mapNext.get(Person.SELECT_COMPANY_NAME);
        if ((companyName == null) || companyName.equals("null"))
           companyName = "";
        String name = (String)mapNext.get(Person.SELECT_NAME);
        String newCompanyWindowURL = "emxComponentsCompanyDetailsFS.jsp?&objectId=" + companyId;
        String allCheckBoxName = "allRoles" + loop;
        ++iCount;
        String sCompetencyBox = "Competency[" + iCount + "]";
        String sExperienceBox = "Experience[" + iCount + "]";
        
%>
        <td ><img src="../common/images/iconSmallPerson.gif" border="0"/>&nbsp;<xss:encodeForHTML><%=fullName%></xss:encodeForHTML></td>
        <td ><xss:encodeForHTML><%=name%></xss:encodeForHTML></td>
		<!-- //XSSOK -->
        <td ><a href="javascript:showDetailsPopup('<%=newCompanyWindowURL%>')"><xss:encodeForHTML><%=companyName%></xss:encodeForHTML></a></td>
        
             
        <td class="field">
        <!-- //XSSOK -->
                    <select name="<%=sCompetencyBox%>">
<!-- //XSSOK -->      
                <framework:optionList valueList="<%=CompetencyList%>" optionList="<%=CompetencyDispList%>"/>
                    </select>
                  </td>
        <td class="field" align="left">
        <!-- //XSSOK -->
                  <input type="text" name="<%=sExperienceBox%>" size="5" value=""/>
                </td>
<%
        loop++;
        paginationLoop++;
%>
       </tr>
      </fw:mapListItr>


<%
  if (personMapList.size() == 0) {
%>
    <tr>
      <td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxComponents.Common.NoMatchFound</emxUtil:i18n></td>
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

<%if(alertNames != null && alertNames.trim().length() > 0 ){%>
    <Script>
    alert("<emxUtil:i18n localize="i18nId">emxComponents.Alert.PersonAlreadyConnected</emxUtil:i18n>\n\n<xss:encodeForJavaScript><%=alertNames%></xss:encodeForJavaScript>");
    </script>
<%}%>
