<%-- emxRouteRolesSearchResults.jsp -- The Page displays the List of Role

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsBusinessSkillSearchResults.jsp.rca 1.8 Wed Oct 22 16:18:53 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@ include file = "../emxJSValidation.inc"%>
<%
  DomainObject dObject = new DomainObject();
  
  String objectId         = emxGetParameter(request, "objectId");
  String personId         = emxGetParameter(request, "personId");
  String mode			  = emxGetParameter(request, "mode");
  
  String[] selectedSkills = (String[]) session.getAttribute("selectedSkills");
  //session.removeAttribute("selectedSkills");
  
  String HAS_SUB_SKILL = "from[SubSkill]";
  
  StringList busSelects = new StringList();
  busSelects.add(HAS_SUB_SKILL);
  busSelects.add(dObject.SELECT_ID);
  busSelects.add(dObject.SELECT_NAME);
  busSelects.add(dObject.SELECT_DESCRIPTION);
  ArrayList checkList = new ArrayList();
  
  Map tempMap = DomainRelationship.getTypeAttributes(context,PropertyUtil.getSchemaProperty(context, "relationship_hasBusinessSkill") );
  Map CompetencyMap = (Map)tempMap.get(PropertyUtil.getSchemaProperty(context,"attribute_Competency"));
  StringList CompetencyList = (StringList)CompetencyMap.get("choices");  
  StringList CompetencyDispList = new StringList(CompetencyList.size());
  StringItr CompetencyListItr =new StringItr(CompetencyList);
  while(CompetencyListItr.next())
  {
    CompetencyDispList.addElement(i18nNow.getRangeI18NString(PropertyUtil.getSchemaProperty(context,"attribute_Competency"),(String)CompetencyListItr.obj(), request.getHeader("Accept-Language")));
  }
  
  StringList nonSelectList = (StringList) session.getAttribute("nonSelectList");
%>
<script language="javascript">
  function newSearch() {
	  parent.location="emxComponentsBusinessSkillSearchFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, personId)%>&targetSearchPage=emxComponentsBusinessSkillSearchResultsFS.jsp&personId=<%=XSSUtil.encodeForURL(context, personId)%>";
  }


  function submitform() {
      var objForm = document.skillsresults;
      var selection = true;
      var selectNumeric = true;
      for (var i=0; i < objForm.elements.length; i++){
        if (objForm.elements[i].name.indexOf('Experience') != -1){
          if(objForm.elements[i].value.length <= 0){selection = false;
            }else{
            	//[Modified::Jan 11, 2011:s4e:R211:IR-083958V6R2012 ::Start]
            	var fieldValue = objForm.elements[i].value;
                if(trimWhitespace(fieldValue) == "" || (fieldValue) < 0 || isNaN(fieldValue) || (fieldValue % 1 != 0) ){
                    alert("<emxUtil:i18n localize="i18nId">emxComponents.Alert.IntegerPositive</emxUtil:i18n>");
                  //[Modified::Jan 11, 2011:s4e:R211:IR-083958V6R2012 ::Start]    
                    selectNumeric = false;
                }
            }
            
        }
      }
      
      if(selection && selectNumeric){
        objForm.submit();
      }
      else if(selectNumeric == true && selection == false){
       alert("<emxUtil:i18n localize="i18nId">emxComponents.Alert.EnterExperience</emxUtil:i18n>");
       }
  }

  function closeWindow() {
    window.closeWindow();
    return;
  }

</script>
<script type="text/javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<form name="skillsresults" id="skillsresults" method="post" action="emxComponentsPersonAddSkillProcess.jsp">
 <input type="hidden" name="personId" value="<xss:encodeForHTMLAttribute><%=personId%></xss:encodeForHTMLAttribute>"/>
 <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
 <input type="hidden" name="mode" value="<xss:encodeForHTMLAttribute><%=mode%></xss:encodeForHTMLAttribute>"/>
  <table class="list">
    <tr>
      <th width="30%" nowrap>
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n>
      </th>
      <th width="50%"  nowrap>
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n>
      </th>
      <th width="10%"  nowrap>
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Competency</emxUtil:i18n>
      </th>
      <th width="10%" nowrap>
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Experience</emxUtil:i18n>
      </th>      
    </tr>
<%
    for(int i=0; i < selectedSkills.length; i++){
        dObject.setId(selectedSkills[i]);
        MapList businessSkillList = dObject.getRelatedObjects(context, PropertyUtil.getSchemaProperty(context,"relationship_SubSkill"), PropertyUtil.getSchemaProperty(context,"type_BusinessSkill"), busSelects, DomainConstants.EMPTY_STRINGLIST, false, true, (short)0, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
        if(businessSkillList.size() <= 0)
            businessSkillList.add(dObject.getInfo(context, busSelects));
        Iterator childListItr = businessSkillList.iterator();
        while(childListItr.hasNext()) {
            Map childSkillMap = (Map) childListItr.next();
            String skillId = (String) childSkillMap.get(dObject.SELECT_ID);
            String hasSubSkill = childSkillMap.get(HAS_SUB_SKILL).toString();
            
            if(hasSubSkill.equalsIgnoreCase("false") && !checkList.contains(skillId) && !nonSelectList.contains(skillId)){
                checkList.add(skillId);
        
%>
     <tr class='<framework:swap id ="1" />'>
        <td>
            <!-- //XSSOK -->
			<input type="hidden" name="businessSkills" value="<%=childSkillMap.get(XSSUtil.encodeForHTMLAttribute(context, dObject.SELECT_ID))%>"/>
            <!-- //XSSOK -->
			<b><%=childSkillMap.get(XSSUtil.encodeForHTML(context, dObject.SELECT_NAME))%></b>
        </td>
        <!-- //XSSOK -->
		<td><%=childSkillMap.get(XSSUtil.encodeForHTML(context, dObject.SELECT_DESCRIPTION))%></td>
      <td>
        <select name="Competency">
        <!-- //XSSOK -->
          <framework:optionList  valueList="<%=CompetencyList%>" optionList="<%=CompetencyDispList%>"
          />
        </select>
      </td>
        <td><input type="text" name="Experience" size="2"/></td>
     </tr>

<%
            }
        }
    }
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
