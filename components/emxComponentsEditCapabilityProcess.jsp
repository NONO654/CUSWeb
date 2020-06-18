<%-- emxComponentsEditCapabilityProcess.jsp   -  This page confirms the Updation Of An Existing Capability of the Organization

  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsEditCapabilityProcess.jsp.rca 1.6 Wed Oct 22 16:17:42 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<!-- content begins here -->
<%

  String strRelId = emxGetParameter(request,"relId");
  
  Relationship capabilityRel = new Relationship(strRelId);
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

%>
<script language="javascript">
   var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "pagecontent"); 
   frameContent.document.location.href=frameContent.document.location.href; 
   window.closeWindow();
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
