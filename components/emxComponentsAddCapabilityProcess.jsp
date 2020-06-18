<%-- emxComponentsAddCapabilityProcess.jsp   -  This page assigns the Capability to the company.

  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsAddCapabilityProcess.jsp.rca 1.7 Wed Oct 22 16:17:57 2008 przemek Experimental przemek $
--%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<script language="javascript" src="scripts/emxUIModal.js"></script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<!-- content begins here -->

<%
  BusinessObject boProcessObject = null;
  BusinessObject boOrganization = null;
  String strObjectId = emxGetParameter(request,"objectId");
  String strProcessId = emxGetParameter(request,"processId");
  String sLanguage = request.getHeader("Accept-Language");
  if ( strProcessId != null && strObjectId != null )  
  {
    boProcessObject = new BusinessObject(strProcessId);
    boOrganization = new BusinessObject(strObjectId);

    // Getting the realtionship object with name Capability.
    RelationshipType relTypeCapability = new RelationshipType(PropertyUtil.getSchemaProperty(context, "relationship_Capability"));

    boOrganization.open(context);
    boProcessObject.open(context );

    Relationship capabilityRel = boOrganization.connect(context, relTypeCapability, true, boProcessObject);
    boProcessObject.close(context);
    boOrganization.close(context);
    
    capabilityRel.open(context);
    AttributeList  attrListProcessRel = new AttributeList();
    
    // All the attributes for Capability Details
    attrListProcessRel.addElement(new Attribute(new AttributeType(PropertyUtil.getSchemaProperty(context, "attribute_CapabilityStatus")), emxGetParameter(request,"CapabilityStatus").trim()));
    attrListProcessRel.addElement(new Attribute(new AttributeType(PropertyUtil.getSchemaProperty(context, "attribute_ProcessQualificationStatus")), emxGetParameter(request,"ProcessQualificationStatus")));
    attrListProcessRel.addElement(new Attribute(new AttributeType(PropertyUtil.getSchemaProperty(context, "attribute_PrototypeCapability")), emxGetParameter(request,"PrototypeCapability")));
    attrListProcessRel.addElement(new Attribute(new AttributeType(PropertyUtil.getSchemaProperty(context, "attribute_StandardLeadTimePrototype")), emxGetParameter(request,"StandardLeadTimePrototype").trim()));
    attrListProcessRel.addElement(new Attribute(new AttributeType(PropertyUtil.getSchemaProperty(context, "attribute_StandardLeadTimeProduction")),emxGetParameter(request,"StandardLeadTimeProd").trim()));
    attrListProcessRel.addElement(new Attribute(new AttributeType(PropertyUtil.getSchemaProperty(context, "attribute_StandardLeadTimeTooling")),  emxGetParameter(request,"StandardLeadTimeTooling").trim()));
    attrListProcessRel.addElement(new Attribute(new AttributeType(PropertyUtil.getSchemaProperty(context, "attribute_MaterialLimitation")), emxGetParameter(request,"MaterialLimitation").trim()));
    attrListProcessRel.addElement(new Attribute(new AttributeType(PropertyUtil.getSchemaProperty(context, "attribute_ShapeLimitation")), emxGetParameter(request,"ShapeLimitation").trim()));
    attrListProcessRel.addElement(new Attribute(new AttributeType(PropertyUtil.getSchemaProperty(context, "attribute_SizeLimitation")), emxGetParameter(request,"SizeLimitation").trim()));
    attrListProcessRel.addElement(new Attribute(new AttributeType(PropertyUtil.getSchemaProperty(context, "attribute_WeightLimitation")), emxGetParameter(request,"WeightLimitation").trim()));
    attrListProcessRel.addElement(new Attribute(new AttributeType(PropertyUtil.getSchemaProperty(context, "attribute_Comments")), emxGetParameter(request,"Comments").trim()));

    capabilityRel.setAttributes(context,attrListProcessRel);

    capabilityRel.close(context);    
    
  } else {
    session.putValue("Error", ComponentsUtil.i18nStringNow("emxComponents.Capabilities.ErrorMessage1", sLanguage));
  }

%>
<script language="javascript">
  if(getTopWindow().getWindowOpener().getTopWindow().modalDialog)
  {
    getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
  }
  getTopWindow().getWindowOpener().parent.document.location.href=getTopWindow().getWindowOpener().parent.document.location.href;
  window.closeWindow();
</script>
<!-- content ends here -->

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
