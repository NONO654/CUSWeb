<%--
  emxComponentsAddExistingPersonSkillPreProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsAddExistingPersonSkillPreProcess.jsp.rca 1.5 Wed Oct 22 16:18:44 2008 przemek Experimental przemek $

--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<html>
<body>
<form name="skillform">
<%
String accessUsers = "role_ResourceManager,role_VPLMProjectAdministrator,role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  String objectId    = emxGetParameter(request,"objectId");
  String SkillAction = emxGetParameter(request,"SkillAddPerson");
  String showCompanyAsLabel = emxGetParameter(request,"showCompanyAsLabel");
  String defaultCompany = "";

  try{
    DomainObject dObj = new DomainObject(objectId);
    String RELATIONSHIP_ORGANIZATIONSKILL = PropertyUtil.getSchemaProperty(context,"relationship_OrganizationSkill");
    String RELATIONSHIP_SUBSKILL = PropertyUtil.getSchemaProperty(context,"relationship_SubSkill");
    defaultCompany = dObj.getInfo(context,"to["+RELATIONSHIP_ORGANIZATIONSKILL+"].from.name");

    if(defaultCompany == null)
    {
        StringList busSelects = new StringList(2);
        busSelects.add(dObj.SELECT_ID);
        busSelects.add("to["+RELATIONSHIP_ORGANIZATIONSKILL+"].from.name");

        MapList parentSkill = dObj.getRelatedObjects(context, RELATIONSHIP_SUBSKILL, PropertyUtil.getSchemaProperty(context,"type_BusinessSkill"), busSelects, DomainConstants.EMPTY_STRINGLIST, true, false, (short)0, null, DomainConstants.EMPTY_STRING);
        Iterator listIndexItr = parentSkill.iterator();
        while (listIndexItr.hasNext())
        {
            Map listIndexObj = (Map) listIndexItr.next();
            defaultCompany = (String) listIndexObj.get("to["+RELATIONSHIP_ORGANIZATIONSKILL+"].from.name");
            if(defaultCompany == null || "".equals(defaultCompany))
            {
              continue;
            }
        }
    }
  }
  catch(Exception e)
  {
    throw e;
  }
  


  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsAddExistingPersonSearchDialogFS.jsp";
  // add these parameters to each content URL
  contentURL += "?objectId=" + XSSUtil.encodeForURL(context, objectId) + "&SkillAddPerson=" + XSSUtil.encodeForURL(context, SkillAction) + "&showCompanyAsLabel=" + XSSUtil.encodeForURL(context, showCompanyAsLabel)+"&defaultCompany="+defaultCompany;
  contentURL = Framework.encodeURL(response, contentURL);
                context.shutdown();

%><!-- //XSSOK -->
<jsp:forward page ="<%=contentURL%>" />

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</form>
</body>
</html>

