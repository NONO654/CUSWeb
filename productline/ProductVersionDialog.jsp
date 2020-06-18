<%--  ProductReviseDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/ProductVersionDialog.jsp 1.9.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";

--%>
<%-- Include file for error handling --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>

<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.productline.*,com.matrixone.apps.domain.DomainConstants,com.matrixone.apps.domain.DomainObject"%>
<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>  
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<%

/*Start -Added by Amarpreet Singh,3dPLM for Design Responsibility*/
String strDesResName = "";
String strRDOId=  null;
String strOldDOId = null;
/*End -Added by Amarpreet Singh,3dPLM for Design Responsibility*/


  try{
    //Retrieves Objectid to make use for the revise process
    String objectId = emxGetParameter(request, "objectId");

/*Start -Added by Amarpreet Singh,3dPLM for Design Responsibility*/


if(objectId!= null && !"".equals(objectId))
{
	DomainObject domCtxPrd = new DomainObject(objectId);
	StringList objectSelects = new StringList(DomainConstants.SELECT_ID);
	StringList relSelects = new StringList(DomainConstants.SELECT_RELATIONSHIP_ID);
	Map RDOmap = domCtxPrd.getRelatedObject(context,DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY,false,objectSelects,relSelects);
	if(RDOmap != null)
	{
	   strRDOId = (String)RDOmap.get(DomainConstants.SELECT_ID);
	}
	if(strRDOId!= null && !"".equals(strRDOId))
	{
		 DomainObject domRDO = new DomainObject(strRDOId);
		 strDesResName = domRDO.getInfo(context,DomainConstants.SELECT_NAME);
	}
	 strOldDOId = strRDOId;
}
/*End -Added by Amarpreet Singh,3dPLM for Design Responsibility*/

	String jsTreeID = emxGetParameter(request, "jsTreeID");

    String strMode = emxGetParameter(request,"PRCFSParam1");

    Product productBean = (Product) com.matrixone.apps.domain.DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCTS,"ProductLine");

    Map versionInfoMap = productBean.getVersionInfo(context,objectId);
    String strName = (String) versionInfoMap.get(DomainConstants.SELECT_NAME);
    String strType = (String) versionInfoMap.get(DomainConstants.SELECT_TYPE);
    strType=i18nNow.getAdminI18NString("Type",strType,acceptLanguage);
	String strRevision = (String) versionInfoMap.get(DomainConstants.SELECT_REVISION);
    String strDescription = (String) versionInfoMap.get(DomainConstants.SELECT_DESCRIPTION);
    String strVersion = (String) versionInfoMap.get(ProductLineConstants.SELECT_VERSION);
    //Fix for Bug: 372205
    String strMarketingNameTemp = (String) versionInfoMap.get(productBean.ATTRIBUTE_EDITED_MARKETING_NAME);
    String strMarketingName = strMarketingNameTemp.replaceAll("\"","&quot;");
    //End of fix.
    String strMarketingText = (String) versionInfoMap.get(productBean.ATTRIBUTE_EDITED_MARKETING_TEXT);

%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

    <form name="ProductVersion" action=submit() method="post">
    <%@include file="../common/enoviaCSRFTokenInjection.inc" %>
    
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
      <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>">


      <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <%-- Display the input fields. --%>

      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Name
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <xss:encodeForHTML><%=strName%></xss:encodeForHTML>
          <input type="hidden" name="txtName" value="<xss:encodeForHTMLAttribute><%=strName%></xss:encodeForHTMLAttribute>">
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Type
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <xss:encodeForHTML><%=strType%></xss:encodeForHTML>
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Revision
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <xss:encodeForHTML><%=strRevision%></xss:encodeForHTML>
          <input type="hidden" name="txtRevision" value="<xss:encodeForHTMLAttribute><%=strRevision%></xss:encodeForHTMLAttribute>">
        </td>
      </tr>


      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <framework:i18n localize="i18nId">
            emxProduct.Form.Label.Version
          </framework:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtVersion" value="<xss:encodeForHTMLAttribute><%=strVersion%></xss:encodeForHTMLAttribute>">
        </td>
      </tr>


      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Description
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <textarea name="txtProductDescription" rows="5" cols="25"><xss:encodeForHTML><%=strDescription%></xss:encodeForHTML></textarea>
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Owner
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtProductOwner" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=context.getUser()%></xss:encodeForHTMLAttribute>">
          <input class="button" type="button" name="btnOwner" size="200" value="..." alt=""  onClick="javascript:showPersonSelector();">
          <input type="hidden" name="txtOwnerId" value="">
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Marketing_Name
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtProductMarketingName" size="20" value="<xss:encodeForHTMLAttribute><%=strMarketingName%></xss:encodeForHTMLAttribute>">
        </td>
      </tr>

      <tr>
        <td width="150" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Marketing_Text
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <textarea name="txtProductMarketingText" rows="5" cols="25"><xss:encodeForHTML><%=strMarketingText%></xss:encodeForHTML></textarea>
        </td>
      </tr>

	  <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxProduct.Form.Label.DesignResponsibility
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtProductDesResp" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strDesResName%></xss:encodeForHTMLAttribute>">
          <input class="button" type="button" name="btnProductDesignResponsibility" size="200" value="..." alt=""  onClick="javascript:showDesignResponsibilitySelector();">
          <input type="hidden" name="txtDRId" value="<xss:encodeForHTMLAttribute><%=strRDOId%></xss:encodeForHTMLAttribute>"><a class="dialogClear" href="#" onclick="javascript:doValidateClear();"><emxUtil:i18n localize="i18nId">emxProduct.Button.Clear</emxUtil:i18n></a>
        </td>

      </tr>
      <tr>
        <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
        <td width="90%">&nbsp;</td>
      </tr>


      </table>
    </form>
<%
  }catch(Exception e)
  {
    session.putValue("error.message", e.getMessage());
  }
%>

  <%@include file = "emxValidationInclude.inc" %>

  <script language="javascript" type="text/javaScript">
  //<![CDATA[
    var  formName = document.ProductVersion;

    //when 'Cancel' button is pressed.
    function closeWindow()
    {
     //Releasing Mouse Events
      parent.window.closeWindow();
    }

<!-- Start -Added by Amarpreet Singh,3dPLM for Design Responsibility  -->

function showDesignResponsibilitySelector()
    {   
      var sURL= '../common/emxFullSearch.jsp?field=TYPES=type_Organization,type_ProjectSpace&table=PLCDesignResponsibilitySearchTable&selection=single&formName=ProductVersion&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../productline/SearchUtil.jsp?&mode=Chooser&chooserType=FormChooser&fieldNameActual=txtDRId&fieldNameDisplay=txtProductDesResp';
      showChooser(sURL, 850, 630);
    }
function checkDesignResponsibility()
	{
		/*Start - Added by Radhika Joge, 3dPLM on 8/7/2007*/
		var oldOID = "<%=XSSUtil.encodeForJavaScript(context,strOldDOId)%>";

		if(oldOID != null && oldOID != "" && oldOID != "null" && "<%=XSSUtil.encodeForJavaScript(context,strOldDOId)%>" != formName.txtDRId.value)
		{
			/*End - Added by Radhika Joge, 3dPLM on 8/7/2007*/
			 var choice = confirm("<%=i18nStringNowUtil("emxProduct.DesignResponsibilityChooser.ConfirmMessage", bundle,acceptLanguage)%> ");

			 if(!choice)
				{
					formName.txtDRId.value = "<%=XSSUtil.encodeForJavaScript(context,strOldDOId)%>";
					formName.txtProductDesResp.value = "<%=XSSUtil.encodeForJavaScript(context,strDesResName)%>";
					return false;
				}
			 else
				{
					return true;
				}
		}
		return true;
	}
function doValidateClear()
{
	
	var choice = confirm("<%=i18nStringNowUtil("emxProduct.DesignResponsibilityClear.ConfirmMessage", bundle,acceptLanguage)%> ");
	if(!choice)
		{
			formName.txtDRId.value = "<%=XSSUtil.encodeForJavaScript(context,strOldDOId)%>";
			formName.txtProductDesResp.value = "<%=XSSUtil.encodeForJavaScript(context,strDesResName)%>";
			return false;
		}
	 else
		{	
			formName.txtDRId.value = "";
			formName.txtProductDesResp.value = "";			
			return true;
		}
		
	return true;
}

<!-- End -Added by Amarpreet Singh,3dPLM for Design Responsibility  -->

    //When 'Done' is pressed
    function submit()
    {
      var iValidForm = true;

      //Validation check for Mandatory field, Max. Length, Bad Character, Numeric, Positive number and Integer for Version
      if (iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxProduct.Form.Label.Version", bundle,acceptLanguage)%> ";
        var field = formName.txtVersion;
        iValidForm = basicValidation(formName,field,fieldName,true,false,true,true,true,true,false);
      }

      //Validation for Dot in Integer for Version
      if(iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxProduct.Form.Label.Version", bundle,acceptLanguage)%> ";
        var field = formName.txtVersion;
        var iDotPosition = field.value.indexOf('.');

        if (iDotPosition >= 0)
        {
            var msg = "<%=i18nStringNowUtil("emxProduct.Alert.VersionInteger",bundle,acceptLanguage)%>";
            field.focus();
            alert(msg);
            iValidForm = false;
        }
      }

          //Validation for Number of Digits for Version
          if(iValidForm)
          {
        var fieldName = "<%=i18nStringNowUtil("emxProduct.Form.Label.Version", bundle,acceptLanguage)%> ";
        var field = formName.txtVersion;
        var maxLength= 9;
                  if (!isValidLength(field.value,0,maxLength))
                  
                  {                   
                      //  var msg = fieldName;
                        //msg = "<%=i18nStringNowUtil("emxProduct.Alert.ProductVersionMaxLengthAlert1",bundle,acceptLanguage)%>";
                        //msg += ' ' + maxLength + ' ';
                     var   msg = "<%=i18nStringNowUtil("emxProduct.Alert.ProductVersionMaxLengthAlert5",bundle,acceptLanguage)%>";
                        field.focus();
                        alert(msg);
                        iValidForm = false;
                  }

          }


      //validation for special chars in the description field - The sixth(true) and last parameter 'checkBadChars' specifies which characters have to be blocked (all bad chars, common illegal characters are now Restricted Characters)
      if (iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
        var field = formName.txtProductDescription;
        iValidForm = basicValidation(formName,field,fieldName,true,true,false,false,false,false,checkBadChars);
      }

      //Validation check for Mandatory field, Max Length and Bad Character for Marketing Name
      if (iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.Marketing_Name", bundle,acceptLanguage)%> ";
        var field = formName.txtProductMarketingName;
        iValidForm = basicValidation(formName,field,fieldName,true,true,false,false,false,false,false);
      }

      //Validation check for Mandatory field and Max Length for Marketing Text
      if (iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.Marketing_Text", bundle,acceptLanguage)%> ";
        var field = formName.txtProductMarketingText;
        iValidForm = basicValidation(formName,field,fieldName,true,true,false,false,false,false,checkBadChars);
      }

      //If Validation fails control will return to dialog
      if (!iValidForm)
      {
        return ;
      }

<!-- Start -Added by Amarpreet Singh,3dPLM for Design Responsibility  -->
    var isContinue = checkDesignResponsibility();

	if (!isContinue){
		return ;
	}

<!-- End -Added by Amarpreet Singh,3dPLM for Design Responsibility  -->

      formName.action="../productline/ProductUtil.jsp?mode=versionProduct&";
      //After successful Validation
      if (jsDblClick()) {
        formName.submit();
      }
    }

    function showPersonSelector()
    {
		var objCommonAutonomySearch = new emxCommonAutonomySearch();

		objCommonAutonomySearch.txtType = "type_Person";
		objCommonAutonomySearch.selection = "single";
		objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchOwner"; 
		objCommonAutonomySearch.open();
}
function submitAutonomySearchOwner(arrSelectedObjects) 
	{
   
		var objForm = document.forms["ProductVersion"];
		var hiddenElement = objForm.elements["txtOwnerId"];
		var displayElement = objForm.elements["txtProductOwner"];

		for (var i = 0; i < arrSelectedObjects.length; i++) 
		{ 
			var objSelection = arrSelectedObjects[i];
			hiddenElement.value = objSelection.name;
			displayElement.value = objSelection.name;
			break;
 
      }
    }

  //]]>
  </script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
