<%--
=================================================================
 emxLibraryCentralUIFormCreateValidation.jsp

 Copyright (c) 1992-2016 Dassault Systemes.
 All Rights Reserved.
 This program contains proprietary and trade secret information of MatrixOne,Inc.
 Copyright notice is precautionary only
 and does not evidence any actual or intended publication of such program
=================================================================
emxLibraryCentralUIFormValidation.jsp
 This file is used to add any validation routines to be used by the Library Central UIForm component
-----------------------------------------------------------------

static const char RCSID[] = $Id: emxLibraryCentralUIFormCreateValidation.jsp.rca 1.3.1.4 Wed Oct 22 16:02:43 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorNoDocTypeInclude.inc"%>
<%
out.clear();
response.setContentType("text/javascript; charset=" + response.getCharacterEncoding());
%>

<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil" %>
<%-- XSSOK --%>
<emxUtil:localize id="i18nId" bundle="emxLibraryCentralStringResource" locale='<%= request.getHeader("Accept-Language") %>' />

<%
  String ResFormFileId = "emxLibraryCentralStringResource";
  String MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE = EnoviaResourceBundle.getProperty(context, ResFormFileId, new Locale((String)request.getHeader("Accept-Language")),"emxLibraryCentral.FormValidate.MustEnterAValidPositiveNumericValueFor");
%>

//Start Changes for Retention Schedule
  var MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE = "<%=MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE%>";
  //End Changes for Retention Schedule

  // following javascript if there are any positive integer or real fields
  function isPositiveRealNumber()
  {
      var varValue=this.value;
      if (isNaN(varValue))
      {
          alert(MUST_ENTER_VALID_NUMERIC_VALUE + " "+this.attributes["fieldlabel"].value);
          this.focus();
          return false;
      }
      else if((Math.abs(varValue)) !=(varValue) || varValue==0)
      {
          alert(MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE+" "+this.attributes["fieldlabel"].value);
          this.focus();
          return false;
      } else{
          return true;
      }
  }
  
  function reloadMessageField()
  {
        emxFormReloadField("Message");
  }
  function validateForBadCharacters()
  {
        var invalidInputMsg = "<emxUtil:i18nScript localize =  "i18nId">emxDocumentCentral.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>" + " ";
        var invalidCharMsg  = "\n <emxUtil:i18nScript localize =  "i18nId">emxDocumentCentral.ErrorMsg.InvalidCharMsg</emxUtil:i18nScript> \n ";
        return (checkForSpecialChars(this,invalidInputMsg, invalidCharMsg));
  }
  function checkDescriptionLength()
  {
        if( checkMaxLength(this,'<%=EnoviaResourceBundle.getProperty(context,"eServiceLibraryCentral.TextArea.MaxLength")%>'))
        {
            alert("<emxUtil:i18nScript localize = "i18nId">emxDocumentCentral.ErrorMsg.DescriptionTooLong</emxUtil:i18nScript>");
            return false;
        }
        return true;
  }

  function reloadDuplicateAttributesInCreateForm(fieldName,fieldValue){
  	var currentActualValue  = fieldValue.current.actual;
    var currentDisplayValue = fieldValue.current.display;
    var fieldNameValues     =  fieldName.split("|");
    if (FormHandler) {
        var attributeGroups     = FormHandler.GetField(fieldName).GetSettingValue("AttributeGroups");
        var attributeGroupsList = attributeGroups.split("|");
        for(var i = 0; i < attributeGroupsList.length; i++) {
            if(attributeGroupsList[i] != "" && attributeGroupsList[i]!=fieldNameValues[0]) {
                FormHandler.GetField(attributeGroupsList[i]+"|"+fieldNameValues[1]).SetFieldValue(currentActualValue,currentDisplayValue);
            }
        }
    }
  }
  
