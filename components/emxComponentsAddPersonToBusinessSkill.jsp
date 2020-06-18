<%-- emxComponentsAddPersonToBusinessSkill.jsp   -  This page disconnects the business objects connected to the Organization.
  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsAddPersonToBusinessSkill.jsp.rca 1.7 Wed Oct 22 16:18:18 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<%
String objectId    = emxGetParameter(request,"objectId");
String fromPage = emxGetParameter(request,"fromPage");%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUIConstants.js" ></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICore.js" ></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUIModal.js" ></script>
<%
if("AddPersonToBusinessSkill".equals(fromPage)){
String accessUsers = "role_ResourceManager,role_VPLMProjectAdministrator,role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

	  
  String SkillAction = emxGetParameter(request,"SkillAddPerson");
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
 %>
 <script>
	 	showModalDialog("../common/emxFullSearch.jsp?table=AEFPersonChooserDetails&submitURL=../components/emxCommonConnectObjects.jsp&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&srcDestRelName=relationship_hasBusinessSkill&field=TYPES=type_Person:member=<%=defaultCompany%>&selection=multiple&frameName=detailsDisplay&isTo=false");
 </script>
<%}else{
	DomainObject dObj = new DomainObject(objectId);
	String companyName = dObj.getInfo(context,"to["+DomainConstants.RELATIONSHIP_MEMBER+"].from.name");%>
	<script>
	showModalDialog("../common/emxFullSearch.jsp?table=AEFGeneralSearchResults&submitURL=../components/emxCommonConnectObjects.jsp&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&srcDestRelName=relationship_hasBusinessSkill&field=TYPES=type_BusinessSkill:organization=<%=companyName%>&selection=multiple&frameName=detailsDisplay&isTo=true&excludeOIDprogram=emxBusinessSkill:getAssociatedBusinessSkills");
	</script>
<%} %>
