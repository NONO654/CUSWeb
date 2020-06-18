<%--  CreateFormValidation.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
 --%>

<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxJSValidation.inc"%>

<%
out.clear();
response.setContentType("text/javascript; charset=" + response.getCharacterEncoding());
%>

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
        var objForm = document.forms[0];
        var hiddenElement = objForm.elements["Owner"];
        var displayElement = objForm.elements["OwnerDisplay"];

        for (var i = 0; i < arrSelectedObjects.length; i++)
        {
            var objSelection = arrSelectedObjects[i];
            hiddenElement.value = objSelection.name;
            displayElement.value = objSelection.name;
            break;
        }
    }
    
// flag keeps track of whether user has modified Marketing Name field.
var sflag;
// This function will put the same value in Marketing Name textbox as that of Name.
function updateDisplayName()
{
    var txtDisplayName = document.getElementById("Display Name").value;
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
    if (((txtDisplayName=="")&&(!document.forms[0].autoNameCheck.checked))||(sflag!="true"))
    {
        document.getElementById("Display Name").value=strFieldValue;
    }
    return true;
}

//This function sets the flag value and calls for updating Marketing Name field.
function setDisplayNameFlag()
{    
   sflag="true";
   var txtDisplayName = document.getElementById("Display Name").value;
   if (txtDisplayName =="")
   {
       sflag="false";
   }else if (txtDisplayName != "")
   {
   //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(txtDisplayName, ARR_NAME_BAD_CHARS, false);
    if(strInvalidChars.length > 0)
    {
    	document.getElementById("Display Name").value ='';
        var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
        alert(strAlert);
        
        return false;
    }
   } 
    else {
       return true; 
     }
   updateDisplayName();
   return true;
}

function showDesignResponsibilitySelector()
{
    var sURL=
     "../common/emxFullSearch.jsp?field=TYPES=type_Organization:CURRENT=state_Active&table=PLCDesignResponsibilitySearchTable&showInitialResults=false&selection=single&submitAction=refreshCaller&hideHeader=true&submitURL=../configuration/SearchUtil.jsp&srcDestRelName=relationship_DesignResponsibility&formName=type_ConfigurationFeatureCreate&fieldNameActual=DesignResponsibilityOID&fieldNameDisplay=DesignResponsibilityDisplay&mode=Chooser&chooserType=FormChooser&HelpMarker=emxhelpfullsearch";
     showChooser(sURL, 850, 630);
}

function updateRevision()
{
    emxFormReloadField("Revision");
}

function clearConfigurationFeature()
{
    var strProductID = document.forms[0]["ConfigurationFeatureOID"].value;
    var strProductDisplay = document.forms[0]["ConfigurationFeatureDisplay"].value;
   
    document.forms[0]["ConfigurationFeatureOID"].value="";
    document.forms[0]["ConfigurationFeature"].value="";
    document.forms[0]["ConfigurationFeatureDisplay"].value="";
    return;   
}

function autonomySearchConfigurationFeature()
{
    var strConfigurationFeatureID = document.forms[0]["ConfigurationFeatureOID"].value;
    var url= "../common/emxFullSearch.jsp?field=TYPES=type_ConfigurationFeature&table=FTRConfigurationFeaturesSearchResultsTable&showInitialResults=false&selection=single&formInclusionList=PARENT_CONFIGURATION_FEATURE,DISPLAY_NAME&submitAction=refreshCaller&hideHeader=true&submitURL=../productline/SearchUtil.jsp&srcDestRelName=relationship_ConfigurationOption&formName=type_ConfigurationOptionCreate&fieldNameActual=ConfigurationFeatureOID&fieldNameDisplay=ConfigurationFeatureDisplay&mode=Chooser&chooserType=FormChooser&HelpMarker=emxhelpfullsearch";
    showModalDialog(url,850,630);
}

function checkPositiveReal()
{
  var minValField = document.getElementById("Resource Minimum");
  if (isNaN(minValField.value))
    {
     alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
     minValField.focus();
     return false;
    }
  
  if (minValField.value <= 0)
    {
      alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.checkPositiveInteger</emxUtil:i18nScript>");
      minValField.focus();
      return false;
    }
   return true;
}

function checkPositiveRealForMax()
{
  var maxValField = document.getElementById("Resource Maximum");
  if (isNaN(maxValField.value))
    {
     alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
     maxValField.focus();
     return false;
    }
  
  if (maxValField.value <= 0)
    {
      alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.checkPositiveInteger</emxUtil:i18nScript>");
      maxValField.focus();
      return false;
    }
   return true;
}


function CheckMinMaxInitial()
{
    var msg = "";
    
    var minVal = document.getElementById("Resource Minimum").value;
    var maxVal = document.getElementById("Resource Maximum").value;
    var initialVal = document.getElementById("Initial Resource").value;
    
    var minValField = document.getElementById("Resource Minimum");
    var initialValField = document.getElementById("Initial Resource");
    var maxValField = document.getElementById("Resource Maximum");
    
    var initialValField = document.getElementById("Initial Resource");
    if (isNaN(initialValField.value))
    {
     alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
     initialValField.focus();
     return false;
    }
  
    if (initialValField.value <= 0)
    {
      alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.checkPositiveInteger</emxUtil:i18nScript>");
      initialValField.focus();
      return false;
    }
 
    if (parseFloat(minVal)>parseFloat(maxVal)){
            alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.MinMaxConstraint</emxUtil:i18nScript>");
            minValField.focus();
            return false;
       }
    
    if (((parseFloat(initialVal)> parseFloat(maxVal))||(parseFloat(initialVal)< parseFloat(minVal))))
    {
           alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InitialConstraint</emxUtil:i18nScript>");
           initialValField.focus();
           return false;
    }
    
    return true;
}

function checkBadCharForName()
{
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
    
    return true;
}

function checkForSplChar()
{
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

 function trim( value )
 {
   return LTrim(RTrim(value));
 }
  
 function LTrim( value )
 {
   var re = /\s*((\S+\s*)*)/;
   return value.replace(re, "$1");
 }

 // Removes ending whitespaces
 function RTrim( value ) 
 {
    var re = /((\s*\S+)*)\s*/;
    return value.replace(re, "$1");
 }
function checkBadCharForNameFixedReource(){
   var badChar=checkBadCharForName();
   if(badChar){
    badChar=isDuplicateRuleName("ResourceRule");
   }
   return badChar;
}
function checkBadCharForNameRuleExtension(){
    var badChar=checkBadCharForName();
    if(badChar){
     badChar=isDuplicateRuleName("RuleExtension");
    }
    return badChar;
}
function isDuplicateRuleName(ruleType){
        var ruleName = document.getElementById("Name").value;
        
        var url="../configuration/RuleDialogValidationUtil.jsp?mode=isDuplicateName&type="+ruleType+"&name="+encodeURIComponent(ruleName)+"&revision=-";
        var vRes = emxUICore.getData(url);
        var iIndex = vRes.indexOf("isDup=");
        var iLastIndex = vRes.indexOf("#");
        var bcrExp = vRes.substring(iIndex+"isDup=".length , iLastIndex );
        if(trim(bcrExp)== "true"){
            alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Rule.AlreadyExists</emxUtil:i18nScript>");
            document.getElementById("Name").value=""; 
            return false;            
        }
        return true;
}

// This function will put the validation on Description 
function checkDescriptionForBadChars()
{   
    var strFieldValue =document.forms[0].Description.value;
    //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(strFieldValue, ARR_BAD_CHARS, false);
    
    if(strInvalidChars.length > 0)
    {
         var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
         alert(strAlert);
         document.forms[0].Description.value ='';
         return false;
    }else
    {
        return true;
    }      
    
}

// This function will put the validation on Display Text

function checkDisplayTextForBadChars()
{   
    var strFieldValue =document.forms[0]["Display Text"].value;
    //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(strFieldValue, ARR_BAD_CHARS, false);
    
    if(strInvalidChars.length > 0)
    {
         var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
         alert(strAlert);
         document.forms[0]["Display Text"].value ='';
         return false;
    }else
    {
        return true;
    }      
    
}
function checkLength()
{
   
    var fieldname=this;
    var maxLength = 100;
    if (!isValidLength(fieldname.value,0,maxLength))
    {
            var msg = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.checkLength</emxUtil:i18nScript>";
            msg += ' ' + maxLength + ' ';
            alert(msg);
            fieldname.focus();
            return false;
    }
    return true;
}

function setMandatory()
{
	var varMandatoryRule = document.getElementById("Mandatory RuleId").options;
	for(var i=0; i<varMandatoryRule.length ; i++){
		if(varMandatoryRule[i].value=="No"){
			varMandatoryRule[i].selected = true;
		}
	}
}

function validatePartFamilyBaseNumber() {
    var createForm = document.forms['emxCreateForm'];
    var partFamilyBaseNumberField = createForm.elements["PartFamilyBaseNumber"];
    var partFamilyBaseNumber = partFamilyBaseNumberField.value;
    if(partFamilyBaseNumber !='' && (isNaN(partFamilyBaseNumber) || partFamilyBaseNumber < 0 || parseInt(partFamilyBaseNumber) != partFamilyBaseNumber) ) {
         alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.NonNegitivePartFamilyBaseNumber</emxUtil:i18nScript>");
         partFamilyBaseNumberField.value = "";
         partFamilyBaseNumberField.focus();
         return false;
    }
    return true;
}
function validatePatternSeparator() {       
    var patternSeparator= document.forms[0].elements["PartFamilyPatternSeparator"];
    var patternSeparatorVal=document.forms[0].elements["PartFamilyPatternSeparator"].value;
    var separatorCheckValue = checkForNameBadChars(patternSeparatorVal,false);
    if (separatorCheckValue == false) {    
      alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.PartFamily.InvalidSeparator</emxUtil:i18nScript>");
      patternSeparator.focus();
      return false;
    }
    else
    {
      return true;
    }         
}
