<%--  ProductConfigurationCreateDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/PartProductConfigurationCreateDialog.jsp 1.6.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "GlobalSettingInclude.inc"%>
<%@include file = "emxValidationInclude.inc" %>

<%@page import="com.matrixone.apps.domain.DomainObject" %>
<%@page import="com.matrixone.apps.productline.*,com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.configuration.*"%>

<%
  String objectId               = emxGetParameter(request, "objectId");
  String strFunctionality       = emxGetParameter(request, "functionality");
  String strPRCFSParam1         = emxGetParameter(request, "PRCFSParam1");
  String strResourceFileId      = emxGetParameter(request, "StringResourceFileId");
  String strSuiteDirectory      = emxGetParameter(request, "SuiteDirectory");
  String strSuiteKey            = emxGetParameter(request, "suiteKey");
  String strParentOID           = emxGetParameter(request, "parentOID");
  String strMode                = emxGetParameter(request, "mode");
  try {

    ProductConfigurationHolder productConfigurationHolder = null;

    DomainObject productConfiguration = DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCT_CONFIGURATION,"Configuration");
    //The default revision for the product object is obtained from the bean.
    String strDefaultRevision =productConfiguration.getDefaultRevision(context,ProductLineConstants.POLICY_PRODUCT_CONFIGURATION);
    MapList policyList = com.matrixone.apps.domain.util.mxType.getPolicies(context,ProductLineConstants.TYPE_PRODUCT_CONFIGURATION,false);
    String strDefaultPolicy = (String)((HashMap)policyList.get(0)).get(DomainConstants.SELECT_NAME);
    String strLocale = context.getSession().getLanguage();
    String strPolicy = ProductLineConstants.POLICY;
    String i18nPolicy  = i18nNow.getMXI18NString(strDefaultPolicy,"",strLocale.toString(),strPolicy);
%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

    
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><form name="ProductConfigurationCreate" method="post" onsubmit="submit(); return false">
      <input type="hidden" name="functionality" value="<xss:encodeForHTMLAttribute><%=strFunctionality%></xss:encodeForHTMLAttribute>" />
        <table border="0" cellpadding="5" cellspacing="2" width="100%">
          <tr>
            <td>
              <input type="hidden" name="hidPartId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
              <input type="hidden" name="hidDefaultRevision" value="<xss:encodeForHTMLAttribute><%=strDefaultRevision%></xss:encodeForHTMLAttribute>" />
            </td>
          </tr>
<%-- Display the input fields. --%>
<%
   /*
    *This logic defines if the name field is to be made visible to the user or not
    *These setting are based on the global settings for each module made in the
    *application property file.
    */
    if (strAutoNamer.equalsIgnoreCase("False") || strAutoNamer.equalsIgnoreCase("") ) {
%>
    <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Name
        </emxUtil:i18n>
      </td>
      <td nowrap="nowrap" class="field">
          <input type="text" name="txtProductConfigurationName" size="20" value="<% if(productConfigurationHolder != null){ out.println(productConfigurationHolder.getName());}%>" onfocus="valueCheck()" />&nbsp;
<%
        if (strAutoNamer.equalsIgnoreCase("")) {
%>
            <input type="checkbox" name="chkAutoName" <%if((productConfigurationHolder != null) &&(productConfigurationHolder.getName().equals(""))){%>checked <%}%>onclick="nameDisabled()" /><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Autoname</emxUtil:i18n>
<%
        }
%>
      </td>
    </tr>
<%
       }else{
%>
           <input type="hidden" name="txtProductConfigurationName" value="<% if(productConfigurationHolder != null){ out.println(productConfigurationHolder.getName());}%>" />
<%
       }
%>

    <tr>
        <td width="150" nowrap="nowrap" class="label">
            <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Product
        </emxUtil:i18n>
      </td>

      <td nowrap="nowrap" class="field">
        <input type="text" name="txtProductConfigurationProduct" size="20" value="" readonly="readonly" />
        <input type="hidden" name="hidProductId" size="20" value="" />

        <input type="button" name="btnProductConfigurationProduct" value="..." onclick="showBasedOnChooser()" />&nbsp;

      </td>
    </tr>

    <tr>
      <td width="150" class="label" valign="center">
        <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Description
        </emxUtil:i18n>
      </td>
      <td class="field">
          <textarea name="txtProductConfigurationDescription" rows="5" cols="25"> <% if(productConfigurationHolder != null){%><xss:encodeForHTML><%=productConfigurationHolder.getDescription()%></xss:encodeForHTML><%}%></textarea>
      </td>
    </tr>
    <tr>
        <td width="150" nowrap="nowrap" class="label">
        <emxUtil:i18n localize="i18nId">
          emxFramework.Basic.Owner
        </emxUtil:i18n>
      </td>
      <td nowrap="nowrap" class="field">
        <input type="text" name="txtProductConfigurationOwner" size="20" value="<% if(productConfigurationHolder != null){ out.println(productConfigurationHolder.getOwnerName());} else { out.println(context.getUser());}%>" readonly="readonly" />
                <input class="button" type="button" name="btnProductConfigurationOwner" size="200" value="..." alt=""  onClick="javascript:showPersonSelector();" />
                <input type="hidden" name="hidProductConfigurationOwnerId" value="" />
            </td>
    </tr>
        <input type="hidden" name="radProductConfigurationPurposeValue"  value="Standard Configuration" />
<%

        if (!bPolicyAwareness) {
          if( policyList.size() > 1) {
%>

            <tr>
              <td width="150" class="label" valign="top">
                  <emxUtil:i18n localize="i18nId">
                      emxFramework.Basic.Policy
                  </emxUtil:i18n>
              </td>
              <td class="field">
                  <select name="txtProductConfigurationPolicy">
                  <!-- XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.-->
                      <framework:optionList
                          optionMapList="<%= policyList%>"
                          optionKey="<%=DomainConstants.SELECT_NAME%>"
                          valueKey="<%=DomainConstants.SELECT_NAME%>"
                          selected = ""/>
                  </select>
                </td>
              </tr>
<%
          } else{
%>
            <tr>
                <td width="150" class="label" valign="top">
                    <emxUtil:i18n localize="i18nId">
                        emxFramework.Basic.Policy
                    </emxUtil:i18n>
                </td>
                <td class="field">
                    <%=XSSUtil.encodeForHTML(context,i18nPolicy)%>
                    <input type="hidden" name="txtProductConfigurationPolicy" value="" />
                </td>
            </tr>
<%
          }
        } else{
%>
          <input type="hidden" name="txtProductConfigurationPolicy" value="" />
<%
       }
       if (bShowVault) {
%>
        <tr>
            <td width="150" class="label" valign="center">
                <emxUtil:i18n localize="i18nId">
                    emxFramework.Basic.Vault
                </emxUtil:i18n>
            </td>
            <td class="field">
                <input type="text" name="txtProductConfigurationVaultDisplay" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strUserVaultDisplay%></xss:encodeForHTMLAttribute>" />
                <input type="hidden" name="txtProductConfigurationVault" size="15" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>" />
                <input class="button" type="button" name="btnVault" size="200" value="..." alt=""  onClick="javascript:showVaultSelector();" /> &nbsp;
            <a name="ancClear" href="#ancClear" class="dialogClear" onclick="document.ProductConfigurationCreate.txtProductConfigurationVault.value='';document.ProductConfigurationCreate.txtProductConfigurationVaultDisplay.value=''"><emxUtil:i18n localize="i18nId">emxProduct.Button.Clear</emxUtil:i18n></a>

            </td>
        </tr>
<%
        }else{
%>
          <input type="hidden" name="txtProductConfigurationVault" value="" />
<%
        }
%>
        </table>
        <input type="image" value="" height="1" width="1" border="0" />
        </form>
<%
      }catch(Exception e){
        session.putValue("error.message", e.getMessage());
      }
%>
  <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
  <script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>  
  <script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
  <script language="javascript" src="../common/scripts/emxUIModal.js"></script>

    <script language="javascript" type="text/javaScript">
        var  formName = document.ProductConfigurationCreate;
        //XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
        var autoNameValue = "<%= strAutoNamer %>";
        var closing = true;

        function valueCheck() {
          if(autoNameValue == '') {
            if (formName.chkAutoName.checked) {
              formName.txtProductConfigurationDescription.focus();
            }
          }
        }

        function nameDisabled() {
          if(formName.chkAutoName != null) {
            if (formName.chkAutoName.checked){
            formName.txtProductConfigurationName.value="";
            formName.chkAutoName.value="true";
            formName.txtProductConfigurationDescription.focus();
            } else {
            formName.txtProductConfigurationName.focus();
            }
          }
        }

        function submit() {
          closing = false;
          var iValidForm = true;
          var msg = "";
          var sTextValue =  trimWhitespace(formName.txtProductConfigurationName.value);
          formName.txtProductConfigurationName.value = sTextValue;
          //XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
          if (!(<%=strAutoNamer.equalsIgnoreCase("True")%> == true)) {
        	//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
            if (<%=strAutoNamer.equalsIgnoreCase("False")%> == true) {
              if (iValidForm) {
                var fieldName = "<%=i18nNow.getI18nString("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
                var field = formName.txtProductConfigurationName;
                iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
               }
            }else {
              if (!formName.chkAutoName.checked) {
                if (iValidForm) {
                  var fieldName = "<%=i18nNow.getI18nString("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
                  var field = formName.txtProductConfigurationName;
                  iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
                }
              }
            }
          }

         if (iValidForm && (!isValidLength(formName.hidPartId.value,1,100) || (formName.hidPartId.value == "null")) ) {
           msg = "<%=i18nNow.getI18nString("emxProduct.Alert.ReqProductAlert", bundle, acceptLanguage)%>";
           formName.btnProductConfigurationProduct.focus();
           alert(msg);
           iValidForm = false;
         }

        //validation for special chars in the description field - The sixth(true/false) and last parameter 'checkBadChars' specifies which characters have to be blocked (all bad chars, common illegal characters are now Restricted Characters)
        if (iValidForm) {
          var fieldName = "<%=i18nNow.getI18nString("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
          var field = formName.txtProductConfigurationDescription;
          iValidForm = basicValidation(formName,field,fieldName,false,false,false,false,false,false,checkBadChars);
        }
        if(!iValidForm) {
            return;
        }
        formName.target="_top";
         formName.action="../configuration/PartProductConfigurationUtil.jsp?functionality=<%=XSSUtil.encodeForURL(context,strFunctionality)%>&PRCFSParam1=<%=XSSUtil.encodeForURL(context,strPRCFSParam1)%>&mode=<%=XSSUtil.encodeForURL(context,strMode)%>&suiteKey=<%=XSSUtil.encodeForURL(context,strSuiteKey)%>&StringResourceFileId=<%=XSSUtil.encodeForURL(context,strResourceFileId)%>&SuiteDirectory=<%=XSSUtil.encodeForURL(context,strSuiteDirectory)%>&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentOID)%>";
        formName.submit();
      }

      function closeWindow() {
        getTopWindow().window.closeWindow();
      }

      // Replace vault dropdown box with vault chooser.
      var txtVault = null;
      var bVaultMultiSelect = false;
      var strTxtVault = "document.forms['ProductConfigurationCreate'].txtProductConfigurationVault";

      function showVaultSelector() {
        //This function is for popping the Vault chooser.
        txtVault = eval(strTxtVault);
        showChooser('../common/emxVaultChooser.jsp?fieldNameActual=txtProductConfigurationVault&fieldNameDisplay=txtProductConfigurationVaultDisplay&incCollPartners=false&multiSelect=false');
      }

      function showPersonSelector(){
       //This function is for popping the Person chooser.
       //showChooser('../components/emxCommonSearch.jsp?formName=ProductConfigurationCreate&frameName=pageContent&fieldNameActual=hidProductConfigurationOwnerId&fieldNameDisplay=txtProductConfigurationOwner&searchmode=chooser&suiteKey=Configuration&searchmenu=SearchAddExistingChooserMenu&searchcommand=PLCSearchPersonsCommand', 700, 500)
	   var objCommonAutonomySearch = new emxCommonAutonomySearch();
	   objCommonAutonomySearch.txtType = "type_Person";
	   objCommonAutonomySearch.selection = "single";
	   objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchOwner"; 
	   objCommonAutonomySearch.open();
      }

	 function submitAutonomySearchOwner(arrSelectedObjects) {
		var objForm = document.forms["ProductConfigurationCreate"];
		var hiddenElement = objForm.elements["hidProductConfigurationOwnerId"];
		var displayElement = objForm.elements["txtProductConfigurationOwner"];

		for (var i = 0; i < arrSelectedObjects.length; i++) 
		{ 
			var objSelection = arrSelectedObjects[i];
			hiddenElement.value = objSelection.name;
			displayElement.value = objSelection.name;
			break;
        }
      }
      
      function showBasedOnChooser() {
        //This function is for popping the Product chooser.
        //showChooser('../components/emxCommonSearch.jsp?formName=ProductConfigurationCreate&frameName=pageContent&fieldNameActual=hidProductId&fieldNameDisplay=txtProductConfigurationProduct&searchmode=chooser&suiteKey=Configuration&searchmenu=SearchAddExistingChooserMenu&searchcommand=PLCPartSearchProductsCommand', 700, 500);
        showChooser('../common/emxFullSearch.jsp?field=TYPES=type_Products,type_Features&table=PLCSearchProductsTable&showInitialResults=false&selection=single&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&mode=Chooser&chooserType=CustomChooser&fieldNameActual=hidProductId&fieldNameDisplay=txtProductConfigurationProduct&formName=ProductConfigurationCreate&frameName=pagecontent&suiteKey=Configuration&submitURL=../configuration/SearchUtil.jsp', 850, 630);
      
      }

    </script>

  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
