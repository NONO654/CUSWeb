 
<%--
  ProducLineCreateDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 static const char RCSID[] = "$Id: /web/productline/ProductLineCreateDialog.jsp 1.11.2.2.1.1.1.1.1.1 Tue Jan 06 18:09:18 2009 GMT pmogusala Experimental$";
 --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "GlobalSettingInclude.inc"%>


<%@page import = "matrix.util.StringList"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLine"%>
<%@page import = "com.matrixone.apps.common.Person"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.domain.util.i18nNow"%>

<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>  
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
  // Added by Mayukh, Enovia MatrixOne Bug # 296939 Date 03/14/2005
  String strType = "";


String strDesName="";
String strDesID ="";
String strOldDOId = "";

try{

  //Retrieves Objectid in context
  String strObjectId = emxGetParameter(request, "objectId");

  /* Start-Added by Amarpreet Singh 3dPLM for addition of Design Responsibility*/	
   ProductLineCommon plcBean = null; //Initialised for Bug:376487 
	if (strObjectId != null && !"".equals(strObjectId)){

        plcBean = new ProductLineCommon();
		strDesID = plcBean.getDefaultRDO(context,strObjectId);
		if(strDesID != null && !"".equals(strDesID))
		{
			DomainObject RDODom = new DomainObject(strDesID);
			strDesName = RDODom.getInfo(context,DomainConstants.SELECT_NAME);
		}
		strOldDOId = strDesID;	 
	}

/* End-Added by Amarpreet Singh 3dPLM for addition of Design Responsibility*/

  String strCommandSource = emxGetParameter(request,"commandSource");

  String strTreeId        = emxGetParameter(request, "jsTreeID");
  String strSuiteKey      = emxGetParameter(request, "suiteKey");
  // Modified by Mayukh, Enovia MatrixOne Bug # 296939 Date 03/14/2005
  strType = ProductLineConstants.TYPE_PRODUCT_LINE;

 

  MapList policyList = com.matrixone.apps.domain.util.mxType.getPolicies(context,strType,false);
  String strDefaultPolicy = (String)((HashMap)policyList.get(0)).get(DomainConstants.SELECT_NAME);
  Locale Local = request.getLocale();
  String strLocale = context.getSession().getLanguage();

  String strPolicy = ProductLineConstants.POLICY;
  String i18nPolicy  = i18nNow.getMXI18NString(strDefaultPolicy,"",strLocale.toString(),strPolicy);

  
  String strProductLine = i18nNow.getTypeI18NString(ProductLineConstants.TYPE_PRODUCT_LINE, strLocale);
%>
  <%@include file = "../emxUICommonHeaderEndInclude.inc"%>
    <!--form action is given for testing-->
    <form name="ProductLineCreate" method="post" onsubmit="submitForm(); return false">
      <input type="hidden" name="txtObjectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>">
      <input type="hidden" name="txtTreeId" value="<xss:encodeForHTMLAttribute><%=strTreeId%></xss:encodeForHTMLAttribute>">
      <input type="hidden" name="strCommandSource" value="<xss:encodeForHTMLAttribute><%=strCommandSource%></xss:encodeForHTMLAttribute>">
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <%-- Display the input fields. --%>

      <!--Name Field-->
<%
      if (strAutoNamer.equalsIgnoreCase("false") || strAutoNamer.equalsIgnoreCase((DomainConstants.EMPTY_STRING)) )
      {
%>
        <tr>
          <td width="150" nowrap="nowrap" class="labelRequired">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Basic.Name
            </emxUtil:i18n>
          </td>
          <td nowrap="nowrap" class="field">
            <input type="text" name="txtName" size="20" onFocus="valueCheck()" onBlur="updateMarketingName()">
            &nbsp;
<%
      if (strAutoNamer.equalsIgnoreCase((DomainConstants.EMPTY_STRING))){
%>
        <input type="checkbox" name="chkAutoName" onclick="nameDisabled()"><emxUtil:i18n localize="i18nId">
                emxProduct.Form.Label.Autoname</emxUtil:i18n></a>
<%
      }
%>
          </td>
        </tr>

<%
      }else{
%>
        <input type="hidden" name="txtName" value="">
<%
      }
%>
      <!-- Begin of Add Mayukh, Enovia MatrixOne Bug # 296939 Date 03/14/2005 -->
      <!--Type Field -->
	        <tr>
	          <td width="150" nowrap="nowrap" class="labelRequired">
	            <emxUtil:i18n localize="i18nId">
	              emxFramework.Basic.Type
	            </emxUtil:i18n>
	          </td>
	          <td  nowrap="nowrap" class="field">
	            <input type="text" name="txtProductLineType" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%= strProductLine%></xss:encodeForHTMLAttribute>">
	            <input class="button" type="button" name="btnType" size="200" value="..." alt=""  onClick="javascript:showTypeSelector();">
	            <input type="hidden" name="txtProductLineActualType" value="<xss:encodeForHTMLAttribute><%= ProductLineConstants.TYPE_PRODUCT_LINE%></xss:encodeForHTMLAttribute>" >
	          </td>
            </tr>
      <!-- End of Add Mayukh, Enovia MatrixOne Bug # 296939 Date 03/14/2005 -->

      <!--Description Field-->
        <tr>
          <td width="150" class="labelRequired">
            <emxUtil:i18n localize="i18nId">emxFramework.Basic.Description</emxUtil:i18n>
          </td>
          <td class="field">
            <textarea name="txtProductLineDescription" rows="5" cols="25"></textarea>
          </td>
        </tr>


     <!--Owner Field and Chooser-->
      <%
        Person person = Person.getPerson(context);
        String strFirstName = person.getInfo(context,Person.SELECT_FIRST_NAME);
        String strLastName = person.getInfo(context,Person.SELECT_LAST_NAME);
        String strOwnerDisplay = strLastName + "," + strFirstName;

      %>
        <tr>
          <td width="150" nowrap="nowrap" class="label">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Basic.Owner
            </emxUtil:i18n>
          </td>
          <td nowrap="nowrap" class="field">
            <input type="text" name="txtProductLineOwnerId" size="20" value="<xss:encodeForHTMLAttribute><%=strOwnerDisplay%></xss:encodeForHTMLAttribute>" readonly="readonly">

            <input type="hidden" name="txtProductLineOwner" value="<xss:encodeForHTMLAttribute><%=context.getUser()%></xss:encodeForHTMLAttribute>">


            <input class="button" type="button" name="btnOwner" size="200" value="..." alt=""  onclick="javascript:showPersonSelector()">
          </td>
        </tr>


        <!--Company Field and Chooser-->
<%
    //Instantiating a StringList for fetching value of Company Id and Company name
    StringList strCompany = (StringList)ProductLineUtil.getUserCompanyIdName(context);
    //The id of the company
    String strCompanyId = (String)strCompany.get(0);
    //The name of the company
    String strCompanyName = (String)strCompany.get(1);
%>
        <tr>
          <td width="150" class="labelRequired">
            <emxUtil:i18n localize="i18nId">
              emxProduct.Form.Label.Company
            </emxUtil:i18n>
          </td>
          <td nowrap="nowrap" class="field">
            <input type="text" name="txtProductLineCompany" size="20" value="<xss:encodeForHTMLAttribute><%=strCompanyName%></xss:encodeForHTMLAttribute>" readonly="readonly">
            <input type="hidden" name="txtProductLineCompanyId" size="20" value="<xss:encodeForHTMLAttribute><%=strCompanyId%></xss:encodeForHTMLAttribute>" readonly>
            <input class="button" type="button" name="btnCompany" size="200" value="..." alt=""  onClick="javascript:showCompanySelector();">&nbsp;
            <a name="ancClear" href="#ancClear" class="dialogClear" onclick="javascript:doCompanyClear();"><emxUtil:i18n localize="i18nId">
              emxProduct.Button.Clear
            </emxUtil:i18n></a></td>
          </td>
        </tr>

        <!--Product Line Marketing Name-->
        <tr>
          <td width="150" class="labelRequired">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Attribute.Marketing_Name
            </emxUtil:i18n>
          </td>
          <td class="field">
            <input type="text" name="txtMarketingName" size="20" onBlur="setMarketingNameFlag()">
          </td>
        </tr>

	   <!--Added by Amarpreet Singh,3dPLM for adding Design Responsibility,Begin-->
       <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxProduct.Form.Label.DesignResponsibility
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtProductDesResp" size="20" readonly="readonly" value = "<xss:encodeForHTMLAttribute><%=strDesName%></xss:encodeForHTMLAttribute>">
          <input class="button" type="button" name="btnProductDesignResponsibility" size="200" value="..." alt=""  onClick="javascript:showDesignResponsibilitySelector();">
          <input type="hidden" name="txtDRId" value="<xss:encodeForHTMLAttribute><%=strDesID%></xss:encodeForHTMLAttribute>"><a class="dialogClear" href="#" onclick="javascript:doValidateClear();"><emxUtil:i18n localize="i18nId">emxProduct.Button.Clear</emxUtil:i18n></a>
        </td>
      </tr>
	  <!--Added by Amarpreet Singh,3dPLM for adding Design Responsibility,End-->
	  <% if (ProductLine.isDisplayProgramField(context))
          {
    	  //Following block added for Bug:376487  
          String strPrgName = DomainConstants.EMPTY_STRING;
          //End of Block for Bug:376487  
          %>
 <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxProduct.Table.Program
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtProductLineProgram" size="20" readonly="readonly" value = "<xss:encodeForHTMLAttribute><%=strPrgName%></xss:encodeForHTMLAttribute>">
          <input class="button" type="button" name="btnProductLineProgram" size="200" value="..." alt=""  onClick="javascript:showProgramSelector();">
          <!--Modified for IR-070451V6R2012-->
          <input type="hidden" name="txtPLPId" value=""><a class="dialogClear" href="#" onclick="javascript:clearProgramField();"><emxUtil:i18n localize="i18nId">emxProduct.Button.Clear</emxUtil:i18n></a>
        </td>
      </tr>
<% }%>
        <!--Product Line Marketing Text-->
        <tr>
          <td width="150" class="label">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Attribute.Marketing_Text
            </emxUtil:i18n>
          </td>
          <td class="field">
            <textarea name="txtProductLineMarketingText" rows="5" cols="25"></textarea>
          </td>
        </tr>

       


        <!--Product Line Policy Chooser-->
<%
    if (!bPolicyAwareness)
    {
      if( policyList.size() > 1)
      {
%>
        <tr>
          <td width="150" class="label" valign="top">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Basic.Policy
            </emxUtil:i18n>
          </td>
          <td class="field">
            <select name="txtProductLinePolicy">
            <!-- XSSOK -->
              <emxUtil:optionList
                optionMapList="<%= policyList%>"
                optionKey="<%=DomainConstants.SELECT_NAME%>"
                valueKey="<%=DomainConstants.SELECT_NAME%>"
                selected = ""/>
              </emxUtil>
            </select>
          </td>
        </tr>
<%
      }else{
%>
        <tr>
          <td width="150" class="label" valign="top">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Basic.Policy
            </emxUtil:i18n>
          </td>
          <td class="field">
            <%=XSSUtil.encodeForHTML(context,i18nPolicy)%>
            <input type="hidden" name="txtProductLinePolicy" value="">
          </td>
        </tr>
<%
      }
    }else{
%>
        <input type="hidden" name="txtProductLinePolicy" value="">
<%
    }
%>
        <!--Product Line Vault Chooser-->
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
          <td class="field">
            <input type="text" name="txtProductLineVaultDisplay" size="20" value="<xss:encodeForHTMLAttribute><%=strUserVaultDisplay%></xss:encodeForHTMLAttribute>" readonly="readonly">&nbsp;
            <input type="hidden" name="txtProductLineVault" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>" size=15>
            <input class="button" type="button" name="btnVault" size="200" value="..." alt=""  onClick="javascript:showVaultSelector();">
            <a name="ancClear" href="#ancClear" class="dialogClear" href="#" onclick="javascript:doVaultClear();">
              <emxUtil:i18n localize="i18nId">
                emxProduct.Button.Clear
              </emxUtil:i18n></a>
          </td>
        </tr>
<%
    }else{
%>
        <input type="hidden" name="txtProductLineVault" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>">
<%
    }
%>

        <tr>
          <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/>
          </td>
          <td width="90%">
            &nbsp;
          </td>
        </tr>
      </table>
	  <input type="image" value="" height="1" width="1" border="0" >
    </form>

<%
 }catch(Exception e)
{
    String alertString = "emxProduct.Alert." + e.getMessage();
    String i18nErrorMessage = i18nStringNowUtil(alertString,bundle,acceptLanguage);
    session.putValue("error.message", i18nErrorMessage);
}

%>
<%@include file = "emxValidationInclude.inc" %>

<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" type="text/javaScript">
//variable containing the form
var  formName = document.ProductLineCreate;


//This function is called when the Autoname checkbox is checked
function nameDisabled()
{
  if (formName.chkAutoName.checked)
  {
	formName.txtName.value="";
	formName.chkAutoName.value="true";
	formName.txtProductLineDescription.focus();
	updateMarketingName();
  }
  else
  {
	formName.txtName.focus();
  }
}

//This function is called to get the Focus on Name or chcekbox on the OnLoad of Form.
function getFocus()
{
  if(!formName.txtName.type=="hidden")
  {
	formName.txtName.focus();
  }
}

function valueCheck()
{
  if (formName.chkAutoName.checked)
  {
	formName.txtProductLineDescription.focus();
  }
}
function showProgramSelector()
    {
      var sURL=
		'../common/emxFullSearch.jsp?field=TYPES=type_Program:IS_PRODUCTLINE_PROGRAM=False&table=AEFGeneralSearchResults&selection=single&formName=ProductLineCreate&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../productline/SearchUtil.jsp?&mode=Chooser&chooserType=FormChooser&fieldNameActual=txtPLPId&fieldNameDisplay=txtProductLineProgram';
      showChooser(sURL, 850, 630)
    }

<%-- Start Added by Amarpreet --%>

function showDesignResponsibilitySelector()
    {
      var sURL=
		'../common/emxFullSearch.jsp?field=TYPES=type_Organization,type_ProjectSpace&table=PLCDesignResponsibilitySearchTable&selection=single&formName=ProductLineCreate&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../productline/SearchUtil.jsp?&mode=Chooser&chooserType=FormChooser&fieldNameActual=txtDRId&fieldNameDisplay=txtProductDesResp';
      showChooser(sURL, 850, 630)
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
					formName.txtProductDesResp.value = "<%=XSSUtil.encodeForJavaScript(context,strDesName)%>";
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
	if(choice)
	{
			formName.txtDRId.value = "";
			formName.txtProductDesResp.value = "";			
	} 
}

//Added for the Bug#370777 - ECH
function clearProgramField()
{
	formName.txtProductLineProgram.value = "";
	formName.txtPLPId.value = "";			
}
//End for the Bug#370777

<%-- End Added by Amarpreet --%>

//When Enter Key Pressed on the form
function submitForm()
{
submit();
}
//Submits the form after validation
function submit()
{
  //This variable is equal to true if the form is valid
  var iValidForm=true;
  iValidForm =fnValidate();
  if (!iValidForm)
  {
	  return ;
  }
  //Submit the form to ProductLineUtil.jsp
  var strURL =  "../productline/ProductLineUtil.jsp?mode=create";
  formName.action= strURL;
  formName.target = "jpcharfooter";

  var isContinue = checkDesignResponsibility();
  if (!isContinue){
		return ;
	}

  //To display the Progress clock
  //nexgenui
  
  if (jsDblClick()) {
	formName.submit();
  }
}

function fnValidate()
{
  //This variable is equal to true if the form is valid
  var iValidForm = true;
  //XSSOK
  if (!(<%=strAutoNamer.equalsIgnoreCase("True")%> == true))
  {
	  //XSSOK
	if (<%=strAutoNamer.equalsIgnoreCase("False")%> == true)
	{
	  if (iValidForm)
	  {
		var fieldName = " <%=i18nStringNowUtil("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
		var field = formName.txtName;
		iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
	  }
	}else
	{
	  if (!formName.chkAutoName.checked)
	  {
		if (iValidForm)
		{
		  var fieldName = " <%=i18nStringNowUtil("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
		  var field = formName.txtName;
		  iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
		}
	  }
	}
  }

  // Begin of Add Mayukh, Enovia MatrixOne Bug # 296939 Date 03/14/2005
  //Validation for Required field for Type
  if (iValidForm)
  {
		var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Type", bundle,acceptLanguage)%> ";
		var field = formName.txtProductLineType;
		iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,false);
  }
  // End of Add Mayukh, Enovia MatrixOne Bug # 296939 Date 03/14/2005

  //validation for special chars in the description field - The sixth(true/false) and last parameter 'checkBadChars' specifies which characters have to be blocked (all bad chars, common illegal characters are now Restricted Characters)
  if (iValidForm)
  {
	var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
	var field = formName.txtProductLineDescription;
	iValidForm = basicValidation(formName,field,fieldName,true,false,true,false,false,false,checkBadChars);
  }

  if (iValidForm)
  {
	var fieldName = "<%=i18nStringNowUtil("emxProduct.Form.Label.Company", bundle,acceptLanguage)%> ";
	var field = formName.txtProductLineCompany;
	iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,false);
  }

  if (iValidForm)
  {
	var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.Marketing_Name", bundle,acceptLanguage)%> ";
	var field = formName.txtMarketingName;
	iValidForm = basicValidation(formName,field,fieldName,true,true,false,false,false,false,false);
	// Added for bug no. IR-052159V6R2011x
	if(iValidForm)
	{
		iValidForm = chkMarketingNameBadChar(field);
	}
  }

  if (iValidForm)
  {
	var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.Marketing_Text", bundle,acceptLanguage)%> ";
	var field = formName.txtProductLineMarketingText;
	iValidForm = basicValidation(formName,field,fieldName,false,false,false,false,false,false,checkBadChars);

  }

  if (!iValidForm)
  {
	  return ;
  }
  return iValidForm;
}

function closeWindow()
{
  parent.window.closeWindow();
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
   
		var objForm = document.forms["ProductLineCreate"];
		
		var hiddenElement = objForm.elements["txtProductLineOwner"];
		var displayElement = objForm.elements["txtProductLineOwnerId"];

		for (var i = 0; i < arrSelectedObjects.length; i++) 
		{ 
			var objSelection = arrSelectedObjects[i];
			hiddenElement.value = objSelection.name;
			displayElement.value = objSelection.name;
			break;
      }
}

function doCompanyClear()
{
	  //This function is to clear the field.
	  document.ProductLineCreate.txtProductLineCompany.value="";
	  document.ProductLineCreate.btnCompany.focus();
}

function doVaultClear()
{
	  //This function is to clear the field.
	  document.ProductLineCreate.txtProductLineVault.value="";
	  document.ProductLineCreate.txtProductLineVaultDisplay.value="";
	  document.ProductLineCreate.btnVault.focus();
}

function showCompanySelector()
{
	var objCommonAutonomySearch = new emxCommonAutonomySearch();

	   objCommonAutonomySearch.txtType = "type_Company";
	   objCommonAutonomySearch.selection = "single";
	   objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchCompany"; 
	   objCommonAutonomySearch.open();
}
function submitAutonomySearchCompany(arrSelectedObjects) 
	{

		var objForm = document.forms["ProductLineCreate"];
		
		var hiddenElement = objForm.elements["txtProductLineCompanyId"];
		var displayElement = objForm.elements["txtProductLineCompany"];

		for (var i = 0; i < arrSelectedObjects.length; i++) 
		{ 
			var objSelection = arrSelectedObjects[i];
			hiddenElement.value = objSelection.objectId;
			displayElement.value = objSelection.name;
			break;
      }
}


// Begin of Add Mayukh, Enovia MatrixOne Bug # 296939 Date 03/14/2005
function showTypeSelector()
{

  //This function is for popping the Type chooser.
  //The value chosen by the type chooser is returned to the corresponding field.

  var field = formName.txtProductLineType.name;
  var fieldActual = formName.txtProductLineActualType.name;
  showChooser('../common/emxTypeChooser.jsp?fieldNameDisplay='+field+'&fieldNameActual='+fieldActual+'&formName=ProductLineCreate&SelectType=single&SelectAbstractTypes=false&InclusionList=<%=XSSUtil.encodeForURL(context,strType)%>&ObserveHidden=true&SuiteKey=eServiceSuiteProductLine&ShowIcons=true',500,400);

}
// End of Add Mayukh, Enovia MatrixOne Bug # 296939 Date 03/14/2005

// Replace vault dropdown box with vault chooser.
var txtVault = null;
var bVaultMultiSelect = false;
var strTxtVault = "document.forms[\"ProductLineCreate\"].txtProductLineVault";
function showVaultSelector()
{
  //This function is for popping the Person chooser.
  txtVault = eval(strTxtVault);
  showChooser('../common/emxVaultChooser.jsp?fieldNameActual=txtProductLineVault&fieldNameDisplay=txtProductLineVaultDisplay&incCollPartners=false&multiSelect=false');
}

//This file contains the function to update the marketing name
<%@include file = "./emxUpdateMarketingNameInclude.inc" %>

</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
