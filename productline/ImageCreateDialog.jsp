<%--  ImageCreateDialog.jsp

Copyright (c) 1999-2018 Dassault Systemes.

All Rights Reserved.
This program contains proprietary and trade secret information
of MatrixOne, Inc.  Copyright notice is precautionary only and
does not evidence any actual or intended publication of such program

static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/ImageCreateDialog.jsp 1.4.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";

--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "GlobalSettingInclude.inc"%>


<%--Importing package com.matrixone.apps.product --%>
<%@page import="com.matrixone.apps.productline.*" %>
<%@page import  = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.util.i18nNow"%>
<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>  


<%
//Retrieves Objectid in context
  String strImagePolicy = "";
  String objectId = emxGetParameter(request, "objectId");
  String strBaseType = ProductLineConstants.TYPE_IMAGE;

  //Added for IR-075292V6R2012 -Start
  String mcsURL = com.matrixone.apps.common.CommonDocument.getMCSURL(context, request);
  //Added for IR-075292V6R2012 -End
try{
  String busId = (String) emxGetParameter(request,"objectId");
  String[] arrAttributeRanges = new String[1];
  arrAttributeRanges[0] = ProductLineConstants.ATTRIBUTE_IMAGE_UOM;

  Map attrRangeMap = ProductLineUtil.getAttributeChoices(context,arrAttributeRanges);
  MapList attrMapListImageUOM = (MapList) attrRangeMap.get(arrAttributeRanges[0]);
  //Getting the internationalized values
  attrMapListImageUOM = ProductLineCommon.getI18nValues(attrMapListImageUOM, ProductLineConstants.ATTRIBUTE_IMAGE_UOM, acceptLanguage);


  MapList mapPolicyList = com.matrixone.apps.domain.util.mxType.getPolicies(context,strBaseType,false);
    String strDefaultPolicy = (String)((HashMap)mapPolicyList.get(0)).get(DomainConstants.SELECT_NAME);
    Locale Local = request.getLocale();
    String strPolicy = ProductLineConstants.POLICY;
    String i18nPolicy  = i18nNow.getMXI18NString(strDefaultPolicy,"",Local.toString(),strPolicy);
%>

    <%@include file = "../emxUICommonHeaderEndInclude.inc"%>
    <form name="ImageCreate" method="post" onsubmit="moveNext(); return false">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
    <input type="hidden" name="busId" value="<xss:encodeForHTMLAttribute><%=busId%></xss:encodeForHTMLAttribute>">
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <%-- Display the input fields. --%>
<%
    /*
         *This logic defines if the name field is to be made visible to the user or not
         *These setting are based on the global settings for each module made in the
         *application property file.
    */
    if (strAutoNamer.equalsIgnoreCase("False") || strAutoNamer.equalsIgnoreCase("") )
    {
%>
      <!--Name Field-->
      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Name
          </emxUtil:i18n>
        </td>
        <td nowrap="nowrap" class="field">
          <input type="text" name="txtName" size="20" value="" onFocus="valueCheck()" onBlur="updateMarketingName()">
          &nbsp;
          <input type="hidden" name="Imagename" value="">
<%
           if (strAutoNamer.equalsIgnoreCase("")){
%>
             <input type="checkbox" name="chkAutoName" onclick="nameDisabled()"><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Autoname</emxUtil:i18n>
<%
           }
%>
        </td>
      </tr>

<%
    }else{
%>
      <input type="hidden" name="Imagename" value="">
<%
    }
%>
      <!-- Description Field-->
      <tr>
        <td width=150 class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Description</emxUtil:i18n> &nbsp;</td>
        <td class="inputField">
        <textarea name="description" rows="4" cols="25" wrap></textarea>
        </td>
      </tr>

      <!--Image Horizontal Size Field-->
      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.ImageHorizontalSize
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="Horsize" size="20">
        </td>
      </tr>

        <!--Image Vertical Size Field-->
        <tr>
            <td width="150" nowrap="nowrap" class="label">
                <emxUtil:i18n localize="i18nId">
                    emxFramework.Attribute.ImageVerticalSize
                </emxUtil:i18n>
            </td>
            <td  nowrap="nowrap" class="field">
                <input type="text" name="Versize" size="20">
            </td>
        </tr>

        <!--Image Unit Of Measure-->
        <tr>
            <td width="150" nowrap="nowrap" class="labelRequired">
                <emxUtil:i18n localize="i18nId">
                    emxFramework.Attribute.ImageUOM
                </emxUtil:i18n>
            </td>
            <td class="field">
                <select name="UnitOfMeasure">
                <!-- XSSOK -->
                    <emxUtil:optionList optionMapList="<%=attrMapListImageUOM%>" optionKey="<%= DomainConstants.SELECT_NAME%>" valueKey="<%= ProductLineConstants.VALUE%>"/></emxUtil>
                </select>
            </td>
        </tr>

        <!--Image Owner Field-->
        <tr>
            <td width="150" nowrap="nowrap" class="label">
                <emxUtil:i18n localize="i18nId">
                    emxFramework.Basic.Owner
                </emxUtil:i18n>
            </td>
            <td  nowrap="nowrap" class="field">
                <input type="text" name="owner" size="20" readonly value="<xss:encodeForHTMLAttribute><%=context.getUser()%></xss:encodeForHTMLAttribute>">
                <input class="button" type="button" name="btnOwner" size="200" value="..." alt=""  onClick="javascript:showPersonSelector();">
                <input type="hidden" name="txtOwnerId" value="">
            </td>
        </tr>

        <tr>
            <td width="150" nowrap="nowrap" class="label">
              <emxUtil:i18n localize="i18nId">
                emxFramework.Attribute.Marketing_Name
              </emxUtil:i18n>
            </td>
            <td nowrap="nowrap" class="field">
                <input type="text" name="txtMarketingName" size="20" onBlur="setMarketingNameFlag()">
                <input type="hidden" name="MarName" value="">
            </td>
        </tr>

        <tr>
            <td width="150" nowrap="nowrap" class="label">
                <emxUtil:i18n localize="i18nId">
                    emxFramework.Attribute.Marketing_Text
                </emxUtil:i18n>
            </td>
            <td nowrap="nowrap" class="field">
                <textarea name="MarText" rows="5" cols="25"></textarea>
            </td>
        </tr>

<%

    if (!bPolicyAwareness)
    {
      if( mapPolicyList.size() > 1)
      {
%>
        <tr>
          <td width="150" class="label" valign="top">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Basic.Policy
            </emxUtil:i18n>
          </td>
          <td class="field">
            <select name="policy">
<!-- XSSOK -->
              <framework:optionList
                optionMapList="<%=mapPolicyList%>"
                optionKey="<%=DomainConstants.SELECT_NAME%>"
                valueKey="><%=DomainConstants.SELECT_NAME%>"
                selected = ""/>
            </select>
          </td>
        </tr>
<%
      }
      else
      {
%>
      <tr>
        <td width="150" class="label" valign="top">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Policy
          </emxUtil:i18n>
        </td>
        <td class="field">
          <%=i18nPolicy%>
          <input type="hidden" name="policy" value="<xss:encodeForHTMLAttribute><%=i18nPolicy%></xss:encodeForHTMLAttribute>">
        </td>
      </tr>
<%
      strImagePolicy=i18nPolicy;
      }
    }
    else
    {
%>
      <input type="hidden" name="policy" value="<xss:encodeForHTMLAttribute><%=i18nPolicy%></xss:encodeForHTMLAttribute>">
<%
    }
%>
<%
    if (bShowVault)
    {
%>
        <tr>
            <td width="150" class="label" valign="top">
                <emxUtil:i18n localize="i18nId">
                  emxFramework.Basic.Vault
                </emxUtil:i18n>
            </td>
            <td  class="field">
                <input type="text" name="txtImageVaultDisplay" size="20" value="<xss:encodeForHTMLAttribute><%=strUserVaultDisplay%></xss:encodeForHTMLAttribute>">
                <input type="hidden" name="ImageVault" size="15" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>">
                <input class="button" type="button" name="btnVault" size="200" value="..." alt=""  onClick="javascript:showVaultSelector();">&nbsp;
                <a class="dialogClear" name="ancClear" href="#ancClear" onclick="document.ImageCreate.txtImageVault.value='';document.ImageCreate.txtImageVaultDisplay.value=''"><emxUtil:i18n localize="i18nId">
               emxProduct.Button.Clear
             </emxUtil:i18n></a>

            </td>
        </tr>
<%
    }else{
%>
        <input type="hidden" name="ImageVault" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>">
<%
    }
%>


        <tr>
            <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
            <td width="90%">&nbsp;</td>
        </tr>

      </table>
        <!-- NextGen UI Adoption : Commented below image-->
      	<!-- Modified for removing unnecessary link on Page  -->
        <!-- <input type="image" value="" height="1" width="1" border="0" >  -->
    </form>

<%

}catch(Exception e) {
    session.putValue("error.message", e.toString().trim());
}
    //Retrieves the tree node id to insert the created object
    String treeId = emxGetParameter(request, "jsTreeID");
%>
    <script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
     <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
    <%@include file = "emxValidationInclude.inc" %>
     <script language="javascript" type="text/javaScript">

    var  formName = document.ImageCreate;
    var autoNameValue = "<xss:encodeForJavaScript><%=strAutoNamer%></xss:encodeForJavaScript>";
     function valueCheck()
        {
            if (autoNameValue == '')
            {
                if (formName.chkAutoName.checked)
                formName.Horsize.focus();
            }
        }


    function nameDisabled()
    {
        if (autoNameValue == "")
        {
            if (formName.chkAutoName.checked)
            {
                formName.Imagename.value="";
                formName.txtName.value="";
                formName.chkAutoName.value="true";
                formName.description.focus();
                updateMarketingName();
            }
            else
            {
                formName.txtName.focus();
            }
        }
    }


    function moveNext()
    {
        var iValidForm = true;

       //XSSOK
        if (!(<%=strAutoNamer.equalsIgnoreCase("True")%>))
        {
            //XSSOK
          if ((<%=strAutoNamer.equalsIgnoreCase("False")%>))
          {
            if (iValidForm)
            {
              var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
              var field = formName.Imagename;
              iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
            }
          }else{
            if (!formName.chkAutoName.checked)
            {
              if (iValidForm)
              {
                var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
                var field = formName.txtName;
                iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
              }
            }
          }
        }

        if (iValidForm)
        {
          var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
          var field = formName.description;
          iValidForm = basicValidation(formName,field,fieldName,false,true,true,false,false,false,false);
        }

        if (iValidForm)
        {
          var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.ImageHorizontalSize", bundle,acceptLanguage)%> ";
          var field = formName.Horsize;
              iValidForm = basicValidation(formName,field,fieldName,false,true,false,true,false,false,false);
        }

        if (iValidForm)
        {
          var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.ImageVerticalSize", bundle,acceptLanguage)%> ";
          var field = formName.Versize;
          iValidForm = basicValidation(formName,field,fieldName,false,true,false,true,false,false,false);
        }

        if (iValidForm)
        {
          if (!trimWhitespace(formName.MarName.value)=="")
          {
            var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.Marketing_Name", bundle,acceptLanguage)%> ";
            var field = formName.txtMarketingName;
            iValidForm = basicValidation(formName,field,fieldName,false,true,false,false,false,false,false);
          }
        }

        var iValidFormImage = true;
        var msg = "";

        if (iValidFormImage==true && iValidForm==true && (trimWhitespace(formName.Versize.value)=="" && trimWhitespace(formName.Horsize.value)!="" ))
        {
          msg = "<%=i18nStringNowUtil("emxProduct.Alert.VerticalSizeBlank",bundle,acceptLanguage)%>";
          formName.Versize.focus();
          iValidFormImage = false;
        }

        if (iValidFormImage==true && iValidForm==true && (trimWhitespace(formName.Horsize.value)=="" && trimWhitespace(formName.Versize.value)!="" ))
        {
          msg = "<%=i18nStringNowUtil("emxProduct.Alert.HorizontalSizeBlank",bundle,acceptLanguage)%>";
          formName.Horsize.focus();
          iValidFormImage = false;
        }

        if (trimWhitespace(formName.Horsize.value)=="")
        {
          formName.Horsize.value="";
        }

         if (trimWhitespace(formName.Versize.value)=="")
        {
          formName.Versize.value="";
        }


        if (!iValidForm)
        {
            return ;
        }

        if (!iValidFormImage)
        {
            alert(msg);
            return ;
        }

        //URL is passed with all params since this invokes the components
        //check In dialog.Image JPO is called to create the Image and check In
        //the object


        
        var type = "<xss:encodeForJavaScript><%=strBaseType%></xss:encodeForJavaScript>";

		formName.Imagename.value = formName.txtName.value;
		formName.MarName.value = formName.txtMarketingName.value;
        // Modifed by Enovia MatrixOne for Bug#318079 on Apr 07,2006
        var uploadURL = "../components/emxCommonDocumentPreCheckin.jsp?parentId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>";

        uploadURL += "&JPOName=emxImage&methodName=checkin&objectAction=image&realType="+type+"&type="+type+"&override=false&showFormat=false&showComments=false&HelpMarker=emxhelpimagesupload&noOfFiles=1";
        uploadURL += "&appDir=productline&appName=product";
        uploadURL += "&mcsUrl=<xss:encodeForURL><%=mcsURL%></xss:encodeForURL>";// Added for IR-075292V6R2012
        uploadURL = fnEncode(uploadURL);

        formName.action=uploadURL;
        formName.target="_top";

        formName.submit();

    }

    //Function to close the window
    function closeWindow()
    {
      parent.window.closeWindow();
    }

      // Replace vault dropdown box with vault chooser.
        var txtVault = null;
        var bVaultMultiSelect = false;
        var strTxtVault = "document.forms['ImageCreate'].ImageVault";
        function showVaultSelector()
        {
          //This function is for popping the Person chooser.
          txtVault = eval(strTxtVault);
          showChooser('../common/emxVaultChooser.jsp?fieldNameActual=ImageVault&fieldNameDisplay=txtImageVaultDisplay&incCollPartners=false&multiSelect=false');
    }

  function showPersonSelector(){

	var objCommonAutonomySearch = new emxCommonAutonomySearch();

	   objCommonAutonomySearch.txtType = "type_Person";
	   objCommonAutonomySearch.selection = "single";
	   objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchOwner"; 
	   objCommonAutonomySearch.open();
  }
  function submitAutonomySearchOwner(arrSelectedObjects) 
	{
   
		var objForm = document.forms["ImageCreate"];
		
		var hiddenElement = objForm.elements["txtOwnerId"];
		var displayElement = objForm.elements["owner"];

		for (var i = 0; i < arrSelectedObjects.length; i++) 
		{ 
			var objSelection = arrSelectedObjects[i];
			hiddenElement.value = objSelection.name;
			displayElement.value = objSelection.name;
			break;
      }
  }

//This file contains the function to update the marketing name
<%@include file = "./emxUpdateMarketingNameInclude.inc" %>

    </script>

    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    <%@include file = "../emxUICommonEndOfPageInclude.inc"%>
