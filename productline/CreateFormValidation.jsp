<%--  CreateFormValidation.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
 --%>
 
<%-- 
@quickreview HAT1  ZUD     03      MAY           2016    Populating title as per autoName of Name in Web form.
@quickreview HAT1  ZUD     17      MAY           2016    IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated.
@quickreview HAT1  ZUD     25      MAY           2016    IR-445639-3DEXPERIENCER2017x: 	R419-STP: "Autoname" check box is not available on Creation form of Requirement objects. 
@quickreview HAT1  ZUD     10      JUNE          2016    IR-437663-3DEXPERIENCER2017x: Please translate the word of some tooltips into Japanese version 2.
@quickreview KIE1 HAT1 16:06:29 :  IR-453225-3DEXPERIENCER2017x: R419-FUN058646:In TRM application 3DSpace, RMC & widgets, title is display as "type + sequence + autonumbering" instead of "type + autonumbering" .
@quickreview KIE1 ZUD  16:11:15 :  		IR-478805-3DEXPERIENCER2017x: R419-FUN055837: Name Requirement object is getting editable on creation form in web top, consistency with wintop is not present.
--%>

<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import = "com.matrixone.apps.productline.Build,com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.productline.UnifiedAutonamingServices"%>
<%
out.clear();
response.setContentType("text/javascript; charset=" + response.getCharacterEncoding());
String accLanguage  = request.getHeader("Accept-Language");
String strDefRDOId="";
String defaultOrg=PersonUtil.getDefaultOrganization(context, context.getUser());
if(defaultOrg!=null || defaultOrg.length()>0){
strDefRDOId = MqlUtil.mqlCommand(context, "temp query bus $1 $2 $3 select $4 dump ",DomainConstants.TYPE_ORGANIZATION,defaultOrg,"*","id");
strDefRDOId = strDefRDOId.substring(strDefRDOId.lastIndexOf(",")+1, strDefRDOId.length());
}

String strBuildNameMaxLength=EnoviaResourceBundle.getProperty(context,"emxProductLine.Build.BuildNameMaxLength");

String strModelPrefixLength = EnoviaResourceBundle.getProperty(context,"emxProductLine.Model.ModelPrefixLength");


String typeTestCase      = DomainConstants.TYPE_TEST_CASE;
String typeTestExecution = DomainConstants.TYPE_TEST_EXECUTION;
String separator = UnifiedAutonamingServices.getAutonameSeparator(context);


%>
// ++ HAT1 ZUD: IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated. 
require(['DS/RichEditorCusto/Util'], function () {

	var typeTestCase      = "<xss:encodeForJavaScript><%=typeTestCase%></xss:encodeForJavaScript>";
	var typeTestExecution = "<xss:encodeForJavaScript><%=typeTestExecution%></xss:encodeForJavaScript>";
	var autonameSeparator = "<xss:encodeForJavaScript><%=separator%></xss:encodeForJavaScript>";

	//Creation WebForm- populating title field
	$(document).ready(function() 
	{
		var TypeActualElem = document.getElementsByName("TypeActual")[0];
		if(TypeActualElem)
		{
	            var typeActualValue   = document.getElementsByName("TypeActual")[0].value; 		
		if(typeActualValue == typeTestCase || typeActualValue == typeTestExecution)
		{
			autoFillTitleTC_TE();
		}
		}
	});
	
	emxUICore.instrument(window, 'saveCreateChanges',
			RefreshTitleSlideinTC_TE, null);
    
    function RefreshTitleSlideinTC_TE(isForCreate)
    {
    	if(isForCreate && (document.getElementsByName("TypeActual")[0].value == typeTestCase || document.getElementsByName("TypeActual")[0].value == typeTestExecution))
		{
    	                // ++ HAT1 ZUD: IR-445639-3DEXPERIENCER2017x: fix
			jQuery("iframe[name='formCreateHidden']").on("load", function(){
              if(!jQuery("iframe[name='formCreateHidden']")[0].contentWindow.DisplayErrorMsg ) {
                     window.document.location.href = window.document.location.href;
              }
            });     // -- HAT1 ZUD: IR-445639-3DEXPERIENCER2017x: fix
		}
    }
	
	// ++ HAT1 ZUD: Populating title as per autoName value of Name in Web form.
	
	//For Test Case and Test Execution Title
	function autoFillTitleTC_TE()
	{
		var Name_Title       = document.getElementsByName('Name');
	 	var Name = Name_Title[0].value;
		var TitleCount = Name.substring(Name.indexOf(autonameSeparator) + 1); 
		var title = TitleCount.substring(TitleCount.indexOf(autonameSeparator) + 1); 
		var Type       = "";
	
		var titleElementArr  = document.getElementsByName("TypeActualDisplay");
		var titleElementArr1 = document.getElementsByName("TypeActual"); 
		
		if(titleElementArr.length >0)
		{
			Type = titleElementArr[0].value;
		}
		else if(titleElementArr1.length >0) 
		{
			Type = titleElementArr1[0].parentElement.innerText;
		}	
		document.getElementById('Title').value = Type + "" + title;
	
	}
	// -- HAT1 ZUD: Populating title as per autoName value of Name in Web form.
	
	return {};
 });

// -- HAT1 ZUD: IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated. 


//JX5 start : change label for Test Case and Test Execution creation forms
function changeLabels()
{
	var url = document.location.href;
	var formIdx = url.indexOf('form=');
	
	if(formIdx != -1){
	
		var temp = url.substring(formIdx);
		var idxSep = temp.indexOf('&');
		
		if(idxSep != -1){
		
			var formName =  temp.substring(5,idxSep);
			
			if(formName == 'PLCCreateTestCase' || formName == 'PLCCreateTestExecution'){
					$("button", "#divDialogButtons").each(function(index) {
						switch(index){
							case 0: 
								$(this).html("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Button.CreateAndClose")%></xss:encodeForJavaScript>");
								break;
							case 1: 
								$(this).html("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Button.Create")%></xss:encodeForJavaScript>");
								break;
							case 2:
								$(this).html("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Button.Close")%></xss:encodeForJavaScript>");
								}
					});
			}
		}
	}
}
//JX5 end

var varNoOfBuildsLimit = "<xss:encodeForJavaScript><%=Build.MAX_BUILDS_COUNT%></xss:encodeForJavaScript>";
var varNoOfCharLimit = "<xss:encodeForJavaScript><%=strBuildNameMaxLength%></xss:encodeForJavaScript>";
function setRDO() {
    var fieldRDO = document.emxCreateForm.DesignResponsibility;
    if (fieldRDO != undefined) {
    	<!-- XSSOK -->
        document.emxCreateForm.DesignResponsibilityOID.value = "<xss:encodeForHTMLAttribute><%=strDefRDOId %></xss:encodeForHTMLAttribute>";
        <!-- XSSOK -->
        document.emxCreateForm.DesignResponsibilityDisplay.value = "<xss:encodeForHTMLAttribute><%=defaultOrg %></xss:encodeForHTMLAttribute>";
        <!-- XSSOK -->
        document.emxCreateForm.DesignResponsibility.value = "<xss:encodeForHTMLAttribute><%=strDefRDOId %></xss:encodeForHTMLAttribute>";
    }
}

function isAllCaps(string)
{
     var format    = string.match(/([A-Z0-9])/);
    var lowerCase = string.match(/([a-z])/);

   
    if(format && !lowerCase)
    {
      return true;
         
    }
    else
    {
      return false;
    }
    return true;
}
function checkNameField()
{
    var displayForm = window.document.forms[0];
    var varNameFieldValue="";
    var varNoOfBuilds = "";
	var autoNameChk = displayForm.autoNameCheck;
	var varNameField = displayForm.Name;
	var flagAutoName = false; 
	  
	if(varNameField.value==null || varNameField.value=="") {
        flagAutoName = true;
    }
	  
	var varNoOfBuildsField = displayForm.elements["Number Of Builds"];
	   
    if(varNoOfBuildsField) {
        for(var n=0;n<displayForm.length;n++) {
            if(displayForm[n].id=="Name") {
                varNameFieldValue=displayForm[n].value;
            }
		    else if(displayForm[n].id=="Number Of Builds") {
			    varNoOfBuilds=displayForm[n].value;
	
	
                var index=varNoOfBuilds.indexOf(".");			  
                if(index > -1) {
                    alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Create.Build.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
                    varNoOfBuildsField.value="1";
                    return false; 
                }
            }
	    }
	    if( isNaN(varNoOfBuilds) || varNoOfBuilds <= 0)
		{ 	
	       alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Create.Build.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
	       varNoOfBuildsField.value="1";
		   return false;
	    }
	    else if (eval (varNoOfBuilds) > eval(varNoOfBuildsLimit) && varNameFieldValue!="") 
        {
	        alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Create.Build.Alert.NameWithNoOfBuilds</emxUtil:i18nScript>");
	        return false; 
	    }
	    else if(eval(varNoOfBuilds) > eval(varNoOfBuildsLimit) && varNameFieldValue=="")
        {
	        alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Create.Build.Alert.NoOfBuildsLimit</emxUtil:i18nScript>"+varNoOfBuildsLimit);
	        return false; 
	    }
	    else if(varNoOfBuilds!="1" && varNameFieldValue!="")
        {
	        alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Create.Build.Alert.NameWithNoOfBuilds</emxUtil:i18nScript>");
	        return false; 
	    }
	    else if(varNoOfBuilds == 1 && flagAutoName)
		{
		    autoNameChk.checked = false;
	        autoNameChk.disabled = false;
		    varNameField.value = "";
		}

	    if(varNoOfBuilds > 1 && flagAutoName)
		{	
		    autoNameChk.disabled = true;
		    autoNameChk.checked = true;
		    autoNameChk.onclick();
	        autoNameChk.disabled = true;
		}
	}
    return true; 
}

function checkNameforNoOfBuilds(){
 
    if (!checkNameField()) {
        return false;
    }

    var displayForm = window.document.forms[0];
    var varNameFieldValue="";
    var varNoOfBuilds = "";
    var msg="";
    var varNoOfBuildsField = displayForm.elements["Number Of Builds"];
    var flag = true; 
     
    if(varNoOfBuildsField) {
        for(var n=0;n<displayForm.length;n++){
	        if(displayForm[n].id=="Name"){
		        varNameFieldValue=displayForm[n].value;
		        varNameField=displayForm[n];
		        flag = true;
	        }
	        else if(displayForm[n].id=="Number Of Builds")
            {
		        varNoOfBuilds=displayForm[n].value;
		        flag = true;
	        }
	    }

	    if( isNaN(varNoOfBuilds) || varNoOfBuilds <= 0)
		{       	  
	       varNoOfBuildsField.value="1";
		   flag =  false;
	    }

	    if(!CheckBadNameChars(varNameField))
		{
		  flag = false;
	    }

	    if(varNameFieldValue.length > varNoOfCharLimit)
	    {        
	            msg= "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.checkLength</emxUtil:i18nScript>";
	            msg += ' ' + varNoOfCharLimit + ' ';
	            alert(msg);
	            flag = false;
	    }
	  
	    if(eval(varNoOfBuilds) > eval(varNoOfBuildsLimit) && varNameFieldValue!="")
        {
		    msg= "<emxUtil:i18nScript localize='i18nId'>emxProduct.Create.Build.Alert.NoOfBuilds</emxUtil:i18nScript>";
	        alert(msg);
	        flag = false;
	    }
	    else if(eval(varNoOfBuilds) > eval(varNoOfBuildsLimit) && varNameFieldValue=="")
        {
		    msg = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Create.Build.Alert.NoOfBuildsLimit</emxUtil:i18nScript>"+varNoOfBuildsLimit;
            msg += " <emxUtil:i18nScript localize='i18nId'>emxProduct.Create.Build.Alert.NameCheck</emxUtil:i18nScript>";
	        alert(msg);
	        flag = false;
	    }
    }
    return flag;
}


function autonomySearchProductConfiguration(){
    var strProductID = document.forms[0]["ProductOID"].value;
    var strModelContextString = "";
    if(document.forms[0]["modelOID"] != null){
    	var strModelOID = document.forms[0]["modelOID"].value
	    strModelContextString = "&modelOID="+strModelOID;
    }
    var strObjString = "";
    if(document.forms[0]["contextBuildOID"] != null){
       	var strCtxtBldOID = document.forms[0]["contextBuildOID"].value;
    	strObjString = "&buildId="+strCtxtBldOID+"&operation=AsBuilt";
    }
    var url= "../common/emxFullSearch.jsp?field=TYPES=type_ProductConfiguration&excludeOIDprogram=emxBuild:filterRelatedProductConfiguration&table=PLCSearchProductsTable&Registered Suite=ProductLine&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&objectId="+strProductID+"&submitURL=../productline/SearchUtil.jsp&mode=ProductandProductConfigurationChooser&chooserType=ProductConfiguration&fieldNameActual=ProductConfigurationOID&fieldNameDisplay=ProductConfigurationDisplay"+strModelContextString+strObjString;
    showModalDialog(url,850,630);
}

function autonomySearchProduct(){
var strProductID = document.forms[0]["ProductOID"].value;
    var strProductConfigurationID = "";
    if(document.forms[0]["ProductConfigurationOID"] != null)
    {   
    	strProductConfigurationID = document.forms[0]["ProductConfigurationOID"].value;
    }
    var strModelContextString = "";
    if(document.forms[0]["modelOID"] != null){
	    var strModelOID = document.forms[0]["modelOID"].value
    	strModelContextString = "&modelOID="+strModelOID;
    }
   var strObjString = "";
    if(document.forms[0]["contextBuildOID"] != null){
       	var strCtxtBldOID = document.forms[0]["contextBuildOID"].value;
    	strObjString = "&buildId="+strCtxtBldOID+"&operation=AsBuilt";
    }
    var url= "../common/emxFullSearch.jsp?field=TYPES=type_HardwareProduct,type_SoftwareProduct,type_ServiceProduct&excludeOIDprogram=emxBuild:filterRelatedProduct&table=PLCSearchProductsTable&Registered Suite=ProductLine&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&objectId="+strProductConfigurationID+"&submitURL=../productline/SearchUtil.jsp&mode=ProductandProductConfigurationChooser&chooserType=Product&fieldNameActual=ProductOID&fieldNameDisplay=ProductDisplay"+strModelContextString+strObjString;
    showModalDialog(url,850,630);
}

function productCheck(){
    var strProduct = document.forms[0]["ProductOID"].value;
    var strProductConfiguration = document.forms[0]["ProductConfigurationOID"].value;
    var msg = "<emxUtil:i18nScript localize='i18nId'>emxProduct.EditBuild.Product.Check</emxUtil:i18nScript>";
    
    if(strProductConfiguration!="" && strProduct==""){
	    alert(msg);
	    return false;
    } else {
	    return true;
    }
}


function clearProduct()
{
    var strProductID = document.forms[0]["ProductOID"].value;
    var strProductDisplay = document.forms[0]["ProductDisplay"].value;
    
    var strProductConfigurationID = document.forms[0]["ProductConfigurationOID"].value;
    var strProductConfigurationDisplay = document.forms[0]["ProductConfigurationDisplay"].value;
    
    var msg = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Confirm.Product.Clear</emxUtil:i18nScript>";
    
    if(strProductConfigurationDisplay!="" &&strProductConfigurationID!="" ){
	    alert(msg);
	    return;
    } else {
	    document.forms[0]["ProductOID"].value="";
	    document.forms[0]["ProductDisplay"].value="";
	    return;
    }
}



function buildDateValidate(){

    var strActualBuildDate = document.forms[0]["ActualBuildDate"].value;
    var strDateShipped = document.forms[0]["DateShipped"].value;

	if(strActualBuildDate != "") {
	  strActualBuildDate = document.forms[0].ActualBuildDate_msvalue.value;
	}	
		
	if(strDateShipped  != "") {
	  strDateShipped = document.forms[0].DateShipped_msvalue.value;
	}	
	var msg = "";
	var actualBuilddate = false;
	var shippeddate = false;

	if(trimWhitespace(strActualBuildDate) == '') {
	    //Condition Check when Actual Build Date is not entered.
	    actualBuilddate = true;
	}

	if (trimWhitespace(strDateShipped) == '') {
	    //Condition Check when Date Shipped is not entered.
	    shippeddate = true;
	}

	if (actualBuilddate == false && shippeddate == false &&( strActualBuildDate  > strDateShipped)) {
	    //Condition check when Date Shipped is before Actual Build Date.
  	    msg = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidDateShipped</emxUtil:i18nScript>";
	    alert(msg);
	    return false;
	}
	// Validation of date - End
    return true;
}


function ClearDesignResponsibility(fieldName) {

	var formElement= eval ("document.forms[0]['"+ fieldName + "']");

	if (formElement){


	if(formElement.length>1){
		if (formElement[i].value != ""){
			   	var response = window.confirm("<emxUtil:i18nScript localize='i18nId'>emxProduct.Confirm.DesignResponsibility.Clear</emxUtil:i18nScript>");
			if(!response){
				return ;
			}
		}
            for (var i=0; i < formElement.length-1; i++) {
				 formElement[i].value="";
		}
	}else{
			if (formElement.value != ""){
			   	var response = window.confirm("<emxUtil:i18nScript localize='i18nId'>emxProduct.Confirm.DesignResponsibility.Clear</emxUtil:i18nScript>");
				if(!response){
					return ;
				}
			}
		   formElement.value="";
	    }
	 }

	formElement=eval ("document.forms[0]['"+ fieldName + "Display']");

	if (formElement){
	  if(formElement.length>1){
            for (var i=0; i < formElement.length-1; i++) {
			 formElement[i].value="";
		  }
		}else{
		   formElement.value="";
	   }
	 }

	formElement=eval ("document.forms[0]['"+ fieldName + "OID']");

	if (formElement){
	  if(formElement.length>1){
	        for (var i=0; i < formElement.length-1; i++) {
			 formElement[i].value="";
		  }
		}else{
		   formElement.value="";
	   }
	 }
}

function autonomySearchDesignResponsibility(){
    var strDesignResponsibilityID = document.forms[0]["DesignResponsibilityOID"].value;

    var url= "../common/emxFullSearch.jsp?field=TYPES=type_Organization,type_ProjectSpace&table=PLCSearchProductsTable&Registered Suite=ProductLine&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../productline/SearchUtil.jsp&mode=Chooser&chooserType=FormChooser&fieldNameActual=DesignResponsibilityOID&fieldNameDisplay=DesignResponsibilityDisplay";
    showModalDialog(url,850,630);
}

//Ellipsis Button For Owner is not working - Start
function submitAutonomySearchOwner(arrSelectedObjects) {
		var objForm = document.forms[0];
		var hiddenElement = objForm.elements["Owner"];
		var displayElement = objForm.elements["OwnerDisplay"];

	for (var i = 0; i < arrSelectedObjects.length; i++)	{
			var objSelection = arrSelectedObjects[i];
			hiddenElement.value = objSelection.name;
			displayElement.value = objSelection.name;
			break;
      }
}


function showPersonSelector() {
       var objCommonAutonomySearch = new emxCommonAutonomySearch();

	   objCommonAutonomySearch.txtType = "type_Person";
	   objCommonAutonomySearch.selection = "single";
	   objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchOwner";
	   objCommonAutonomySearch.open();
     }
//Ellipsis Button For Owner is not working - End


// Checking for Bad characters in the field
function CheckBadNameChars(fieldname) {
    if( !fieldname ) {
        fieldname=this;
    }
    
    var isBadNameChar=checkForNameBadChars(fieldname,true);
    if ( isBadNameChar.length > 0 ) {
           msg= "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidChars</emxUtil:i18nScript>";
           msg += isBadNameChar;
           alert(msg);
           fieldname.focus();
           return false;
       }
        return true;
}

//Added for IR-031789 - Called as part of 'On Focus Handler' setting on form
function makeReadOnly() {
	this.readOnly = "true";
	this.select();
}

// --------------------------------------------
// Derivations
// --------------------------------------------
//modified for IR-324015-3DEXPERIENCER2016 - all ?create? new revisions the field Name should default to the same name as the Model name 

function setNameValueOnLoad () {
    var derivedFromTxtField = document.forms[0].DerivedName;
    var nameTxtField = document.forms[0].Name;
    if (derivedFromTxtField && derivedFromTxtField.value != "") {
        nameTxtField.value = derivedFromTxtField.value;
    }
    var derivedFromMarkNameField = document.forms[0].DerivedMarkName;
    var markNameTxtField = document.forms[0].MarketingName;
    if (derivedFromMarkNameField && derivedFromMarkNameField.value != "") {
        markNameTxtField.value = derivedFromMarkNameField.value;
    }
}

var mflag;
function updateMarketingName() {
    var txtDisplayName = document.getElementById("MarketingName").value;
    var strFieldValue =document.forms[0].Name.value;
    
    //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(strFieldValue, ARR_NAME_BAD_CHARS, false);
    if(strInvalidChars.length > 0)
    {
         var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
         alert(strAlert);
         document.forms[0].Name.value ='';
         return false;
    }
    if (((txtDisplayName=="")&&(!document.forms[0].autoNameCheck.checked))||(mflag!="true"))
    {
        document.getElementById("MarketingName").value = strFieldValue;
    }
    return true;
}

//This function sets the flag value and calls for updating Marketing Name field.
function setMarketingNameFlag() {    
    mflag="true";
    var txtDisplayName = document.getElementById("MarketingName").value;

    if (txtDisplayName == "") {
        mflag="false";
    } 
    else if (txtDisplayName != "")
    {
        //Check for Bad Name Chars
        var strInvalidChars = checkStringForChars(txtDisplayName, ARR_NAME_BAD_CHARS, false);
        if(strInvalidChars.length > 0)
        {
            var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
            alert(strAlert);
            document.getElementById("MarketingName").value ='';
            return false;
        }
    } 
    else 
    {
        return true; 
    }
    updateMarketingName();
    return true;
}

function checkRevisionForBadChars() {
    var strFieldValue =document.forms[0].Revision.value;
    //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(strFieldValue, ARR_NAME_BAD_CHARS, false);
    
    if(strInvalidChars.length > 0)
    {
         var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
         alert(strAlert);
         document.forms[0].Revision.value ='';
         return false;
    }   

}

// This function will put the validation on Description 
function checkDescriptionForBadChars() {   
    var strFieldValue =document.forms[0].Description.value;
    //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(strFieldValue, ARR_BAD_CHARS, false);
    
    if(strInvalidChars.length > 0)
    {
         var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
         alert(strAlert);
         document.forms[0].Description.value ='';
         return false;
    }
    else
    {
        return true;
    }      
}

// Added for Product Line chooser search in Create Model from Global Actions
function autonomySearchProductLine() {
    var url= "../common/emxFullSearch.jsp?field=TYPES=type_ProductLine&table=PLCSearchProductLinesTable&showInitialResults=false&selection=single&submitAction=refreshCaller&hideHeader=true&submitURL=../productline/SearchUtil.jsp&formName=type_CreateModel&fieldNameActual=ProductLineOID&fieldNameDisplay=ProductLineDisplay&mode=Chooser&chooserType=FormChooser&HelpMarker=emxhelpfullsearch";
    showModalDialog(url,850,630);
}

function validateModelPrefix() {
   var strModelPrefixLength = "<xss:encodeForJavaScript><%=strModelPrefixLength %></xss:encodeForJavaScript>";
   var txtModelPrefix = document.getElementById("ModelPrefix").value;
   var flag = true;

   if (txtModelPrefix.length > strModelPrefixLength) {
       msg= "<emxUtil:i18nScript localize='i18nId'>emxProductLine.Model.ModelPrefixTooLong</emxUtil:i18nScript>";
       msg += ' ' + strModelPrefixLength + ' ';
       alert(msg);
       document.getElementById("ModelPrefix").value = "";
       document.emxCreateForm.ModelPrefix.focus();
       flag = false;
   } else {
	   //change to all caps if needed
	   var bAllCaps = isAllCaps(txtModelPrefix)
	   if (!bAllCaps) {
	      txtModelPrefix = txtModelPrefix.toUpperCase();
	      document.getElementById("ModelPrefix").value = txtModelPrefix;
	   }
   }
   return flag;
}

//Validating for Date Value
function ProductDateValidate(){
        var strSED = document.forms[0].StartEffectivity_msvalue.value;
        var strEED = document.forms[0].EndEffectivity_msvalue.value;
        var msg = "";
        if((trimWhitespace(strSED) == '') && (trimWhitespace(strEED) == ''))
        {
            //Condition Check when both Start Effectivity and End Effectivity are Empty
            var i = 0;
            for(i=0; i < document.forms[0].WebAvailability.length; i++)
            {
                if(document.forms[0].WebAvailability[i].checked)
                {
                    //to check if Released and Effective Products is selected
                    if(document.forms[0].WebAvailability[i].value == "Released and Effective Products")
                    {
                        msg= "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.ReleasedAndEffectiveProducts</emxUtil:i18nScript>";
                        alert(msg);
                        return false;
                    }
                }
            }
        }
        else if(trimWhitespace(strSED) == '')
        {
            //Condition Check when only Start Effectivity is not entered. Start Effectivity is also needed.
            msg= "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.EmptyStartEffectivity</emxUtil:i18nScript>";
            alert(msg);
            return false;
        }
        else if(trimWhitespace(strEED) == '')
        {
            //Condition Check when only End Effectivity is not entered. End Effectivity is also needed.
            msg= "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.EmptyEndEffectivity</emxUtil:i18nScript>";            
            alert(msg);
            return false;
        }
        else
        {
            if (strSED > strEED)
            {
               //Condition check when Start Effectivity Date is after End Effectivity Date. It should be before the End Effectivity //Date
                msg= "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidEffectivityDateEntry</emxUtil:i18nScript>";                
                alert(msg);
                return false;
            }
        }
     return true;
}

function confirmInsertBefore() {
    var strConfirm = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Derivation.InsertBefore.Confirmation</emxUtil:i18nScript>";
    return confirm(strConfirm);
}

function isDuplicateProductName(){
        var prdName = document.getElementById("Name").value;
        var prdType = document.getElementsByName("TypeActual")[0].value;
        var targetLocation = document.getElementsByName("targetLocation")[0].value;
        var isSlideIn = targetLocation == "slidein";
        var url="../productline/ProductLineUtil.jsp?mode=isDuplicateName";
        var queryString = "type="+prdType+"&name="+encodeURIComponent(prdName)+"&revision=*"
        var vRes = emxUICore.getDataPost(url,queryString);
        var iIndex = vRes.indexOf("isDup=");
        var iLastIndex = vRes.indexOf("#");
        var returnStr = vRes.substring(iIndex+"isDup=".length , iLastIndex );
        var isPrdDup = returnStr.split("|");
        if(trim(isPrdDup[0])== "true"){
            var confirmmsg= "<emxUtil:i18nScript localize='i18nId'>emxProduct.Name.AlreadyExists</emxUtil:i18nScript>"; 
	        if(confirm(confirmmsg)){
			 if(isSlideIn){
				getTopWindow().closeSlideInDialog(); //for closing slidein window
			 }else{
				getTopWindow().closeWindow();// only for Popup
             } 
	         var url =  "../common/emxTree.jsp?AppendParameters=true&DefaultCategory=PLCModelDerivationsTreeCategory&objectId=" + isPrdDup[1];                           
	         showNonModalDialog(url,860,600,true, '', 'MediumTall'); 
	        }else{
	        //do nothing
	        }
            return false;            
        }
        return true;
}

//Validating Test Execution date attribute values in Form Edit
function validateTestExecutionFormDate()
{

	var displayframe      = findFrame(parent, "formEditDisplay");
	if(displayframe == '' || displayframe==null){
     	displayframe = findFrame(parent, "detailsDisplay");
	}
    var displayForm       = displayframe.document.forms[0];
    var estimatedStDate   = "";//Field 'Estimate Start Date'
    var estimatedEndDate  = "";//Field 'Estimate End Date'
    eval("estimatedStDate = document.forms[0].EstimatedStartDate_msvalue");
    eval("estimatedEndDate = document.forms[0].EstimatedEndDate_msvalue");
    if( !(trimWhitespace(estimatedStDate.value) == '' || trimWhitespace(estimatedEndDate.value) == '') )
   {
        if(estimatedStDate.value > estimatedEndDate.value)
        {
        	
             msg = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidEstimatedExecutionDate</emxUtil:i18nScript>";
             alert(msg);
             return false;
          }
      }
    return true;
}


//Added For SCC : START
<%
Boolean hasDesignSync =(Boolean)JPO.invoke(context, "emxVCDocumentUI", null, "hasDesignSyncServer", null, Boolean.class);
Boolean hasHDM = (Boolean)FrameworkUtil.isSuiteRegistered(context,"appVersionTeamCollaboration",false,"","");
if(hasDesignSync && hasHDM) {
	String noStoreText = EnoviaResourceBundle.getProperty(context,"Components","emxComponents.CommonDocument.NoStoreGiven",request.getHeader("Accept-Language"));
%>
	function showDSFANavigator()
	{
	    var store = document.getElementsByName("Store");
	    store = store[0];
	    if(store.value){
	        var strURL="../components/emxCommonVCStoreIntermediateProcess.jsp?storeName="+store.value+"&objectAction=connectVCFileFolder&suiteKey=Components&vcDocumentType=file&formName=emxCreateForm&dsfaTag=no";
	        showModalDialog(strURL, 650, 550, true);
	    }else{
	        alert("<xss:encodeForJavaScript><%=noStoreText%></xss:encodeForJavaScript>");
	    }
	}
	
        function showStoreSelector()
        {
            var onclickURL = "../common/emxIndentedTable.jsp?table=SCCHDMSearchStoreTable&"+
                    "program=emxSCCHDMStores:getSearchedStoreList&HelpMarker=emxhelpdsstore&editLink=false&"+
                    "selection=single&header=emxSemiTeamCollab.Header.DesignSyncStores&"+
                    "submitURL=../semiteamcollab/emxSCCHDMDesignSyncStoreSearchUtil.jsp&"+
                    "fieldNameActual=Store&fieldNameDisplay=StoreDisplay&Store&"+
                    "cancelLabel=emxSemiTeamCollab.Button.Cancel&suiteKey=SemiTeamCollab&displayView=details";

            showModalDialog(onclickURL,'1000','600','false');
        }

<%
}%>
//Added For SCC : END

emxUICore.addEventHandler(window, "load", changeLabels);

