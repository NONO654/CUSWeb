<%-- emxComponentsCapabilityDetails.jsp   -  This page displays allows to view/update the Capability Detail of a process for the company.

  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsCapabilityDetails.jsp.rca 1.7 Wed Oct 22 16:18:17 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>

<!-- content begins here -->
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@ include file = "../emxJSValidation.inc" %>

<%
  String strObjectId = emxGetParameter(request,"objectId");
  String strRelId    = emxGetParameter(request,"relId");
  String pageURL = "emxComponentsEditCapabilityDialogFS.jsp?objectId=" + strObjectId + "&relId=" + strRelId;
%>

<script language = "JavaScript">

function editDetails()
{
  showModalDialog("<%=XSSUtil.encodeForJavaScript(context, pageURL)%>", 575, 575);
}

// function to trim the value of the the text box.
function trim (textBox) 
{
   while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
   {
    textBox = textBox.substring(0,textBox.length - 1);
   }
   while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
   {
    textBox = textBox.substring(1,textBox.length);
   }
   return textBox;
}

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String sRoleSupplierRepresentative = PropertyUtil.getSchemaProperty(context,"role_SupplierRepresentative");
  String sRoleBuyer                  = PropertyUtil.getSchemaProperty(context,"role_Buyer");

  // preload lookup strings
  String sAttrCapabilityStatus       = PropertyUtil.getSchemaProperty(context, "attribute_CapabilityStatus");
  String sAttrMaterialLimit          = PropertyUtil.getSchemaProperty(context, "attribute_MaterialLimitation");
  String sAttrQualificationStatus    = PropertyUtil.getSchemaProperty(context, "attribute_ProcessQualificationStatus");
  String sAttrShapeLimit             = PropertyUtil.getSchemaProperty(context, "attribute_ShapeLimitation");
  String sAttrPrototypeCapability    = PropertyUtil.getSchemaProperty(context, "attribute_PrototypeCapability");
  String sAttrSizeLimit              = PropertyUtil.getSchemaProperty(context, "attribute_SizeLimitation");
  String sAttrPrototypeLeadTime      = PropertyUtil.getSchemaProperty(context, "attribute_StandardLeadTimePrototype");
  String sAttrWeightLimit            = PropertyUtil.getSchemaProperty(context, "attribute_WeightLimitation");
  String sAttrProductLeadTime        = PropertyUtil.getSchemaProperty(context, "attribute_StandardLeadTimeProduction");
  String sAttrToolingLeadTime        = PropertyUtil.getSchemaProperty(context, "attribute_StandardLeadTimeTooling");
  String sAttrComments               = PropertyUtil.getSchemaProperty(context, "attribute_Comments");
  String sOrganization               = PropertyUtil.getSchemaProperty(context,"type_Organization");
  String sCapabilityRel              = PropertyUtil.getSchemaProperty(context,"relationship_Capability");

  boolean bShowButtons = false;

  Hashtable displayValues = new Hashtable();

  // Create the Process Objecst from the request
  BusinessObject boProcess = new BusinessObject( strObjectId );
  boProcess.open(context);
  String strProcessName = boProcess.getName();
  String strProcessType = boProcess.getTypeName();
  boProcess.close(context);

  Relationship processRelObject = new Relationship(strRelId);
  processRelObject.open(context);
  AttributeItr attrItr = new AttributeItr( processRelObject.getAttributes(context));
  while ( attrItr.next() ) 
  {
    Attribute attr = attrItr.obj();
    displayValues.put(attr.getName(),attr.getValue());
  }
  BusinessObject busParent = processRelObject.getFrom();
  busParent.open(context);
  String strOrgName = busParent.getName();
  String strOrgId   = busParent.getObjectId();
  busParent.close(context);
  processRelObject.close(context);
  String strLanguage = request.getHeader("Accept-Language");

//23 july
  boolean isPrinterFriendly = false;
  String printerFriendly = emxGetParameter(request, "PrinterFriendly");

  if (printerFriendly != null && "true".equals(printerFriendly) ) 
  {
    isPrinterFriendly = true;
  }
//23 july
%>
<form name="CapabilityDetails" method="post" action="">
  <input type="hidden" name = "objectId"     value = "<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name = "relId"     value = "<xss:encodeForHTMLAttribute><%=strRelId%></xss:encodeForHTMLAttribute>" />
  
  <table border="0" width="100%" cellspacing="2" cellpadding="5" >
<%  
    String popTreeUrl = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + strOrgId ;
    popTreeUrl  ="javascript:showModalDialog('" + popTreeUrl + "', 800,575)";
%>        
      <tr>
         <td width="40%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Company</emxUtil:i18n></td>
         <td width="60%" class="field">
            <img src="../common/images/iconCompany16.png" />
            <%
            if(!isPrinterFriendly)
            {
            %>
            <a href="<%= XSSUtil.encodeURLwithParsing(context,popTreeUrl)%>"><xss:encodeForHTML><%= strOrgName %></xss:encodeForHTML></a>&nbsp;
            <%
            }
            else
            {
            %>
           <xss:encodeForHTML> <%= strOrgName %></xss:encodeForHTML>&nbsp;
            <%
             }
            %>
         </td>
      </tr>
      <tr>
         <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Capabilities.Process</emxUtil:i18n></td>
         <td class="field"><xss:encodeForHTML><%=strProcessType%></xss:encodeForHTML>&nbsp;</td>
      </tr>
      <tr>
        <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Capabilities.ProcessType</emxUtil:i18n></td>
        <td class="field"><xss:encodeForHTML><%=strProcessName%></xss:encodeForHTML>&nbsp;</td>
      </tr>
      <tr>
        <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Capabilities.CapabilityStatus</emxUtil:i18n></td>
        <td class="field">
           <%=i18nNow.getRangeI18NString(sAttrCapabilityStatus, (String) displayValues.get(sAttrCapabilityStatus), strLanguage)%>&nbsp;
        </td>
      </tr>
      <tr>
        <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Capabilities.ProcessQualificationStatus</emxUtil:i18n></td>
        <td class="field">
            <%=i18nNow.getRangeI18NString(sAttrQualificationStatus, (String) displayValues.get(sAttrQualificationStatus), strLanguage)%>&nbsp;
        </td>
      </tr>

      <tr>
        <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.PrototypeCapability</emxUtil:i18n>
        </td>
        <td class="field">
            <%=i18nNow.getRangeI18NString(sAttrPrototypeCapability, (String) displayValues.get(sAttrPrototypeCapability), strLanguage)%>&nbsp;
        </td>
      </tr>

      <tr>
        <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.StandardLeadTimePrototype</emxUtil:i18n>
        </td>
        <td class="field">
         <xss:encodeForHTML><%=displayValues.get(sAttrPrototypeLeadTime)%></xss:encodeForHTML>&nbsp;
        </td>
      </tr>

      <tr>
        <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.StandardLeadTimeProduction</emxUtil:i18n>
        </td>
        <td class="field">
         <xss:encodeForHTML> <%=displayValues.get(sAttrProductLeadTime)%></xss:encodeForHTML> &nbsp;
        </td>
      </tr>
      
      <tr>
        <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.StandardLeadTimeTooling</emxUtil:i18n>
        </td>
        <td class="field">
         <xss:encodeForHTML> <%=displayValues.get(sAttrToolingLeadTime)%></xss:encodeForHTML> &nbsp;
        </td>
      </tr>

      <tr>
        <td class="label">
            <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.MaterialLimitation</emxUtil:i18n>
        </td>
        <td class="field">
         <xss:encodeForHTML> <%=displayValues.get(sAttrMaterialLimit)%></xss:encodeForHTML> &nbsp;
        </td>
      </tr>

      <tr>
        <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.ShapeLimitation</emxUtil:i18n>
        </td>
        <td class="field">
        <xss:encodeForHTML>  <%=displayValues.get(sAttrShapeLimit)%> </xss:encodeForHTML>&nbsp;
        </td>
      </tr>

      <tr>
        <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.SizeLimitation</emxUtil:i18n>
        </td>
        <td class="field">
         <xss:encodeForHTML> <%=displayValues.get(sAttrSizeLimit)%></xss:encodeForHTML> &nbsp;
        </td>
      </tr>

      <tr>
        <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.WeightLimitation</emxUtil:i18n>
        </td>
        <td class="field">
         <xss:encodeForHTML> <%=displayValues.get(sAttrWeightLimit)%></xss:encodeForHTML> &nbsp;
        </td>
      </tr>

      <tr>
        <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.Comments</emxUtil:i18n>
        </td>
        <td class="field">
         <xss:encodeForHTML> <%=displayValues.get(sAttrComments)%></xss:encodeForHTML> &nbsp;
        </td>
      </tr>
    </table>
</form>

<!-- content ends here -->
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
