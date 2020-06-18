<%-- emxLibMultuBusinessSkillSearchResults.jsp -- The Page displays the List of Role

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsMultiBusinessSkillSearchResults.jsp.rca 1.6 Wed Oct 22 16:18:56 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%
  DomainObject dObject = new DomainObject();
  
  String objectId         = emxGetParameter(request, "objectId");
  String personId         = emxGetParameter(request, "personId");
  String fieldName         = emxGetParameter(request, "fieldName");
  
  String[] selectedSkills = emxGetParameterValues(request, "businessSkills");
  
  String HAS_SUB_SKILL = "from[SubSkill]";
  
  StringList busSelects = new StringList();
  busSelects.add(HAS_SUB_SKILL);
  busSelects.add(dObject.SELECT_ID);
  busSelects.add(dObject.SELECT_NAME);
  busSelects.add(dObject.SELECT_DESCRIPTION);
  ArrayList checkList = new ArrayList();
  HashMap finalMap = new HashMap();
  
  Map tempMap = DomainRelationship.getTypeAttributes(context,PropertyUtil.getSchemaProperty(context, "relationship_hasBusinessSkill") );
  Map CompetencyMap = (Map)tempMap.get(PropertyUtil.getSchemaProperty(context,"attribute_Competency"));
  StringList CompetencyList = (StringList)CompetencyMap.get("choices");  
  
  StringList nonSelectList = (StringList) session.getAttribute("nonSelectList");

  String skillName = "";
  String skillIds = "";
  for(int i=0; i < selectedSkills.length; i++){
    dObject.setId(selectedSkills[i]);
    MapList businessSkillList = dObject.getRelatedObjects(context, PropertyUtil.getSchemaProperty(context,"relationship_SubSkill"), PropertyUtil.getSchemaProperty(context,"type_BusinessSkill"), busSelects, DomainConstants.EMPTY_STRINGLIST, false, true, (short)0, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
    if(businessSkillList.size() <= 0) businessSkillList.add(dObject.getInfo(context, busSelects));
    Iterator childListItr = businessSkillList.iterator();
    while(childListItr.hasNext()) {
      Map childSkillMap = (Map) childListItr.next();
      String skillId = (String) childSkillMap.get(dObject.SELECT_ID);
      String hasSubSkill = childSkillMap.get(HAS_SUB_SKILL).toString();
      if(hasSubSkill.equalsIgnoreCase("false") && !checkList.contains(skillId)){
        checkList.add(skillId);
	skillName += "," + childSkillMap.get(dObject.SELECT_NAME);
	skillIds += "#" + childSkillMap.get(dObject.SELECT_ID);
	finalMap.put(childSkillMap.get(dObject.SELECT_ID), childSkillMap.get(dObject.SELECT_NAME));
      }
    }
  }
  
  skillName = skillName.substring(1, skillName.length());
  skillIds = skillIds.substring(1, skillIds.length());

%>

<script>
  objForm = parent.window.getWindowOpener().document.forms[0];
  objForm.<%=XSSUtil.encodeForJavaScript(context,fieldName)%>.value= "<%=skillName%>";//XSSOK
  objForm.<%=XSSUtil.encodeForJavaScript(context,fieldName)%>Id.value= "<%=skillIds%>";//XSSOK
  window.closeWindow();
</script>
