<%--  emxComponentsAddExistingPersonProcess.jsp   -   connect people to Company

   Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsSkillAddPersonProcess.jsp.rca 1.7 Wed Oct 22 16:18:53 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  //import com.matrixone.apps.common.*;
  DomainObject orgObj = DomainObject.newInstance(context);
  DomainObject personObj = DomainObject.newInstance(context);

  String objectId = emxGetParameter(request,"objectId");
  String typeAlias = emxGetParameter(request,"typeAlias");

  String selectedPeople[] = (String[]) session.getAttribute("selectedPeople");

 // String selectedPeople[] = (String[]) session.getAttribute("selectedPeople");
  session.removeAttribute("SkillAction");


  String sRelHasBusinessSkill  = PropertyUtil.getSchemaProperty(context, "relationship_hasBusinessSkill" );
  String sAttrCompetency = PropertyUtil.getSchemaProperty(context,"attribute_Competency");
  String sAttrExperience = PropertyUtil.getSchemaProperty(context,"attribute_Experience");
  for (int i = 0; i < selectedPeople.length; i++) {

     try {

     String sCompetency = emxGetParameter(request,"Competency[" + i + "]");
     String sExperience = emxGetParameter(request,"Experience[" + i + "]");
     String sPersonId = selectedPeople[i];

     try {
     DomainObject objPerson = new DomainObject(sPersonId);


     RelationshipType reltype =new RelationshipType(sRelHasBusinessSkill);
     DomainRelationship newRel =  objPerson.addToObject(context,reltype, objectId);

     Map attribMap = new HashMap();
     attribMap.put(sAttrCompetency, sCompetency);
         attribMap.put(sAttrExperience, sExperience);

     newRel.setAttributeValues(context, attribMap);
     } catch(MatrixException ex) {
     }



     }catch(MatrixException e) {
        session.putValue("error.message", e.getMessage());
     }
  }

%>
<script language="javascript">
      parent.window.getWindowOpener().location.href=parent.window.getWindowOpener().location.href;
      window.closeWindow();
</script>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
