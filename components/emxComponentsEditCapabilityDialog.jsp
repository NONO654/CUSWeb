<%-- emxComponentsEditCapabilityDialog.jsp   -  This page displays allows to view/update the Capability Detail of a process for the company.

  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsEditCapabilityDialog.jsp.rca 1.8 Wed Oct 22 16:18:57 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>

<!-- content begins here -->
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@ include file = "../emxJSValidation.inc" %>

<script language = "JavaScript">

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

  // And It Also Validates The User Input
  function modify() 
  {
    var isValidData = true;

    var sLeadTime     = trim(document.EditCapability.StandardLeadTimePrototype.value);
    var sLeadTimeProd = trim(document.EditCapability.StandardLeadTimeProd.value);
    var sLeadTimeTool = trim(document.EditCapability.StandardLeadTimeTooling.value);

    if ( !isNumeric(sLeadTime) || sLeadTime.indexOf("-") != -1 ) 
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxProfileManager.ProfileEditCapabilityDialog.ProtoTypeMessage</emxUtil:i18nScript>");
      document.EditCapability.StandardLeadTimePrototype.focus();
      isValidData = false;
      return;
    } else if ( !isNumeric(sLeadTimeProd) || sLeadTimeProd.indexOf("-") != -1 ) {
       alert("<emxUtil:i18nScript localize="i18nId">emxProfileManager.ProfileEditCapabilityDialog.ProductionMessage</emxUtil:i18nScript>");
       document.EditCapability.StandardLeadTimeProd.focus();
       isValidData = false;
       return;
    } else if ( !isNumeric(sLeadTimeTool) || sLeadTimeTool.indexOf("-") != -1 ) {
       alert("<emxUtil:i18nScript localize="i18nId">emxProfileManager.ProfileEditCapabilityDialog.ToolingMessage</emxUtil:i18nScript>");
       document.EditCapability.StandardLeadTimeTooling.focus();
       isValidData = false;
       return;
    }

    if ((isValidData == true)) 
    {
      var badCharacters = checkForBadChars(document.EditCapability.Comments);
      if(badCharacters.length != 0)
      {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.InvalidChars</emxUtil:i18nScript>"+badCharacters+"<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript>"+" \""+"<emxUtil:i18nScript localize="i18nId">emxComponents.Capabilities.Comments</emxUtil:i18nScript>"+"\"");
          document.EditCapability.Comments.focus();
          return;
      }
      // trim the values before submitting.
      document.EditCapability.CapabilityStatus.value   = trim(document.EditCapability.CapabilityStatus.value);
      document.EditCapability.MaterialLimitation.value = trim(document.EditCapability.MaterialLimitation.value);
      document.EditCapability.ShapeLimitation.value    = trim(document.EditCapability.ShapeLimitation.value);
      document.EditCapability.SizeLimitation.value     = trim(document.EditCapability.SizeLimitation.value);
      document.EditCapability.WeightLimitation.value   = trim(document.EditCapability.WeightLimitation.value);
      document.EditCapability.Comments.value           = trim(document.EditCapability.Comments.value);

      // submit the trimmed values
      document.EditCapability.StandardLeadTimePrototype.value = sLeadTime;
      document.EditCapability.StandardLeadTimeProd.value      = sLeadTimeProd;
      document.EditCapability.StandardLeadTimeTooling.value   = sLeadTimeTool;

      document.EditCapability.action = "emxComponentsEditCapabilityProcess.jsp";
      document.EditCapability.submit();
    }
    return;
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
 // Get the Orgnanization Id and the Process ID from the request
  String strObjectId     = emxGetParameter(request,"objectId");
  String strRelId      = emxGetParameter(request,"relId");

  String sRoleSupplierRepresentative = PropertyUtil.getSchemaProperty(context,"role_SupplierRepresentative");
  String sRoleBuyer                  = PropertyUtil.getSchemaProperty(context,"role_Buyer");
  String sRoleBuyerAdmin             = PropertyUtil.getSchemaProperty(context,"role_BuyerAdministrator");

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

  BusinessObject boProcess = new BusinessObject( strObjectId );
  boProcess.open(context);
  String strProcessName = boProcess.getName();
  String strProcessType = boProcess.getTypeName();
  boProcess.close(context);
  
  Hashtable displayValues = new Hashtable();

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
%>
<form name="EditCapability" method="post" onSubmit="modify(); return false;">
  <input type="hidden" name = "objectId" value = "<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name = "relId" value = "<xss:encodeForHTMLAttribute><%=strRelId%></xss:encodeForHTMLAttribute>" />
  
    <table border="0" cellpadding="3" cellspacing="2" width="100%">
      <tr>
         <td width="40%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Company</emxUtil:i18n></td>
         <td width="60%" class="inputField">
            <img src="../common/images/iconCompany16.png" alt="*" />
          <xss:encodeForHTML>  <%= strOrgName %></xss:encodeForHTML>&nbsp;
         </td>
      </tr>
      
      <tr>
         <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Capabilities.Process</emxUtil:i18n></td>
         <td class="inputField"><xss:encodeForHTML><%=strProcessType%></xss:encodeForHTML>&nbsp;</td>
      </tr>
      <tr>
        <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Capabilities.ProcessType</emxUtil:i18n></td>
        <td class="inputField"><xss:encodeForHTML><%=strProcessName%></xss:encodeForHTML>&nbsp;</td>
      </tr>
      
      <tr>
        <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Capabilities.CapabilityStatus</emxUtil:i18n></td>
        <td class="inputField">
           <input type="text" name="CapabilityStatus" value="<%=XSSUtil.encodeForHTMLAttribute(context, (String)displayValues.get(sAttrCapabilityStatus))%>" size="20" onFocus="select()" />
            &nbsp;
        </td>
      </tr>

      <tr>
        <td width="300" class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.ProcessQualificationStatus</emxUtil:i18n>
        </td>
        <td class="inputField">
             <select name = "ProcessQualificationStatus">
<%
             StringList sAttrQualStatus = mxAttr.getChoices(context, sAttrQualificationStatus);
             MapList ml = AttributeUtil.sortAttributeRanges(context,sAttrQualificationStatus,sAttrQualStatus,strLanguage);
             Iterator mlItr = ml.iterator();
             while (mlItr.hasNext())
             {
                Map choiceMap = (Map) mlItr.next();
                String choice = (String) choiceMap.get("choice");
                String translation = (String) choiceMap.get("translation");
     
                if(choice.equals(displayValues.get(sAttrQualificationStatus)))
                {
%>        
                 <option selected value ="<xss:encodeForHTMLAttribute><%=choice%></xss:encodeForHTMLAttribute>" > <xss:encodeForHTML><%=translation%></xss:encodeForHTML></option>
<%
                } else {
%>
                 <option  value ="<xss:encodeForHTMLAttribute><%=choice%></xss:encodeForHTMLAttribute>" > <xss:encodeForHTML><%=translation%></xss:encodeForHTML></option>
<%
                }
             }
%>
             </select>
        </td>
      </tr>

      <tr>
        <td class="label">
           <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.PrototypeCapability</emxUtil:i18n>
        </td>
        <td class="inputField">
            <select name = "PrototypeCapability">
<%
            StringList sAttrProtoCap = mxAttr.getChoices(context, sAttrPrototypeCapability);     
            MapList mAttrProtoCap = AttributeUtil.sortAttributeRanges(context,sAttrPrototypeCapability,sAttrProtoCap,request.getHeader("Accept-Language"));
            Iterator AttrProtoCapItr = mAttrProtoCap.iterator();
            while (AttrProtoCapItr.hasNext())
            {
                Map choiceMap = (Map) AttrProtoCapItr.next();
                String choice = (String) choiceMap.get("choice");
                String translation = (String) choiceMap.get("translation");
                if(choice.equals(displayValues.get(sAttrPrototypeCapability)))
                {
 %>        
                  <option selected value ="<xss:encodeForHTMLAttribute><%=choice%></xss:encodeForHTMLAttribute>" > <xss:encodeForHTML><%=translation%></xss:encodeForHTML></option>
<%
                 } else {
%>
                  <option  value ="<xss:encodeForHTMLAttribute><%=choice%></xss:encodeForHTMLAttribute>" ><xss:encodeForHTML> <%=translation%></xss:encodeForHTML></option>
<%
                 }
            }
 %>
            </select>
        </td>
      </tr>

      <tr>
        <td class="label">
           <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.StandardLeadTimePrototype</emxUtil:i18n>
        </td>
        <td class="inputField">
         <input type="text" name = "StandardLeadTimePrototype" value = "<%=XSSUtil.encodeForHTMLAttribute(context, (String)displayValues.get(sAttrPrototypeLeadTime))%>" size = "20" onFocus="select()" />
        </td>
      </tr>

      <tr>
        <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.StandardLeadTimeProduction</emxUtil:i18n>
        </td>
        <td class="inputField">
           <input type= "text" name = "StandardLeadTimeProd" value = "<%= XSSUtil.encodeForHTMLAttribute(context, (String)displayValues.get(sAttrProductLeadTime))%>" size = "20" onFocus="select()" />
        </td>
      </tr>
      
      <tr>
        <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.StandardLeadTimeTooling</emxUtil:i18n>
        </td>
        <td class="inputField">
         <input type="text" name = "StandardLeadTimeTooling" value = "<%= XSSUtil.encodeForHTMLAttribute(context, (String)displayValues.get(sAttrToolingLeadTime))%>" size = "20" onFocus="select()" />
        </td>
      </tr>
      
      <tr>
        <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.MaterialLimitation</emxUtil:i18n>
        </td>
        <td class="inputField">
          <input type="text" name = "MaterialLimitation" size = "20" value = "<%= XSSUtil.encodeForHTMLAttribute(context, (String)displayValues.get(sAttrMaterialLimit))%>" onFocus="select()" />
        </td>
      </tr>

      <tr>
        <td class="label">
            <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.ShapeLimitation</emxUtil:i18n>
        </td>
        <td class="inputField">
          <input type="text" name="ShapeLimitation" size="20" value="<%= XSSUtil.encodeForHTMLAttribute(context, (String)displayValues.get(sAttrShapeLimit))%>" onFocus="select()" />
        </td>
      </tr>

      <tr>
        <td class="label">
           <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.SizeLimitation</emxUtil:i18n>
        </td>
        <td class="inputField">
           <input type="text" name="SizeLimitation" size="20" value="<%=  XSSUtil.encodeForHTMLAttribute(context, (String)displayValues.get(sAttrSizeLimit))%>" onFocus="select()" />
        </td>
      </tr>

      <tr>
        <td class="label">
           <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.WeightLimitation</emxUtil:i18n>
        </td>
        <td class="inputField">
           <input type="text" name="WeightLimitation" size="20" value="<%= XSSUtil.encodeForHTMLAttribute(context, (String)displayValues.get(sAttrWeightLimit))%>" onFocus="select()" />
        </td>
      </tr>

      <tr>
        <td class="label" valign="top">
          <emxUtil:i18n localize="i18nId">emxComponents.Capabilities.Comments</emxUtil:i18n>
        </td>
        <td class="inputField">
        <textarea rows="3" name="Comments" cols="30" wrap><%= XSSUtil.encodeForHTMLAttribute(context, (String)displayValues.get(sAttrComments))%></textarea>
        </td>
      </tr>
    </table>
 </form>

<!-- content ends here -->
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
