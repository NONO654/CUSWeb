<%--
=================================================================
 emxLibraryCentralUIFormValidation.jsp

 Copyright (c) 1992-2016 Dassault Systemes.
 All Rights Reserved.
 This program contains proprietary and trade secret information of MatrixOne,Inc.
 Copyright notice is precautionary only
 and does not evidence any actual or intended publication of such program
=================================================================
emxLibraryCentralUIFormValidation.jsp
 This file is used to add any validation routines to be used by the Library Central UIForm component
-----------------------------------------------------------------

static const char RCSID[] = $Id: emxLibraryCentralUIFormValidation.jsp.rca 1.5 Wed Oct 22 16:02:27 2008 przemek Experimental przemek $

--%>
<%@include file="../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil" %>

<script language="javascript" type="text/javascript" src="../documentcentral/emxMultipleClassificationUIFormValidation.js"></script>


<%
    String resourceBundle           = "emxLibraryCentralStringResource";
    String objectId                 = (String)emxGetParameter(request, "objectId");
    String classificationMode       = (String)emxGetParameter(request, "classificationMode");
    String language                = request.getHeader("Accept-Language");
    String formName = (String)emxGetParameter(request, "form");//bae3

    String MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE  = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.FormValidate.MustEnterAValidPositiveNumericValueFor");
    String MUST_ENTER_VALID_NUMERIC_VALUE           = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxFramework.FormComponent.MustEnterAValidPositiveNumericValueFor");
    String MUST_SELECT_VALID_OPTION = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.FormValidate.MustSelectAValidOptionFor");
    String INVALID_INPUT_MSG        = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxDocumentCentral.ErrorMsg.InvalidInputMsg");
    String INVALID_CHAR_MSG         = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxDocumentCentral.ErrorMsg.InvalidCharMsg");
    String DESRIPTION_TOO_LONG      = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxDocumentCentral.ErrorMsg.DescriptionTooLong");
    String MAX_DESCRIPTION_LENGTH   = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"eServiceDocumentCentral.TextArea.MaxLength");
    String AG_ALREADY_EXISTS        = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxMultipleClassification.AttributeGroup.AttributeGroupAlreadyExists");
%>

<script>
    var MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE = "<xss:encodeForJavaScript><%=MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE%></xss:encodeForJavaScript>";
    var MUST_ENTER_VALID_NUMERIC_VALUE          = "<xss:encodeForJavaScript><%=MUST_ENTER_VALID_NUMERIC_VALUE%></xss:encodeForJavaScript>";
    var MUST_SELECT_VALID_OPTION = "<xss:encodeForJavaScript><%=MUST_SELECT_VALID_OPTION%></xss:encodeForJavaScript>";
    var INVALID_INPUT_MSG        = "<xss:encodeForJavaScript><%=INVALID_INPUT_MSG%></xss:encodeForJavaScript>";
    var INVALID_CHAR_MSG         = "<xss:encodeForJavaScript><%=INVALID_CHAR_MSG%></xss:encodeForJavaScript>";
    var DESRIPTION_TOO_LONG      = "<xss:encodeForJavaScript><%=DESRIPTION_TOO_LONG%></xss:encodeForJavaScript>";
    var MAX_DESCRIPTION_LENGTH   = "<xss:encodeForJavaScript><%=MAX_DESCRIPTION_LENGTH%></xss:encodeForJavaScript>"
    var AG_ALREADY_EXISTS        = "<xss:encodeForJavaScript><%=AG_ALREADY_EXISTS%></xss:encodeForJavaScript>";

    // following javascript if there are any positive integer or real fields
    function isPositiveRealNumber()
    {
        var varValue    = this.value;
        if (isNaN(varValue)) {
            alert(MUST_ENTER_VALID_NUMERIC_VALUE + " "+this.fieldLabel);
            this.focus();
            return false;
        } else if((Math.abs(varValue)) !=(varValue)|| varValue==0) {
            alert(MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE+" "+this.fieldLabel);
            this.focus();
            return false;
        } else{
            return true;
        }
    }

    // IP Management Accelerator:
    // this method is used to ensure that user selects a valid
    // option from a combo box, when one is required.
    function isValidSelection()
    {
        var strValue    = this.value;
        var strWarning  = MUST_SELECT_VALID_OPTION + " " + this.fieldLabel;

        if (strValue == "" || strValue == "Unassigned") {
            alert(strWarning);
            this.focus();
            return false;
        }
        return true;
    }

    function validateForBadCharacters()
    {
        return (checkForSpecialChars(this,INVALID_INPUT_MSG, "\n"+INVALID_CHAR_MSG));
    }

    function checkDescriptionLength()
    {
        if( checkMaxLength(this,MAX_DESCRIPTION_LENGTH)) {
            alert(DESRIPTION_TOO_LONG);
            return false;
        }
        return true;
    }

    function reloadAttributes()
    {
        emxFormReloadField("Attributes");
        modifyRedundantFields();
    }
    
    function reloadClass()
    {
        emxFormSetValue("Class","","");
        emxFormSetValue("Attributes","","");  
    }

    function currentFieldValue(fieldName) {
        var oldValueFieldName   = fieldName.name +"fieldValue";
        var oldValueField       = getTopWindow().document.getElementsByName(oldValueFieldName)[0];
        oldValueField = oldValueField == null ? document.forms[0][oldValueFieldName] : oldValueField;
        return oldValueField.value;
    }
    
    function validateAGNameInCreate()
    {
        if (!checkForSpecialCharsInAGName(this,INVALID_INPUT_MSG, "\n"+INVALID_CHAR_MSG, true, false)) 
            return false;
        return (isAGNameExists(this.value));
    }

    function validateAGNameInEdit()
    {
        if (!checkForSpecialCharsInAGName(this,INVALID_INPUT_MSG, "\n"+INVALID_CHAR_MSG, true, false)) 
            return false;
        if(currentFieldValue(this) == this.value) 
            return true;  
        return (isAGNameExists(this.value));
    }

    function isAGNameExists(attributeName) 
    {
        var url             = "../documentcentral/emxLibraryCentralAtrributeGroupNameValidation.jsp?AGName="+encodeURIComponent(attributeName) ;
        var xmlResult       = emxUICore.getXMLData(url);
        var root            = xmlResult.documentElement;
        var isAGNameExists  = emxUICore.getText(emxUICore.selectSingleNode(root, "/isAGNameExists"));
        if (isAGNameExists == "true") {
            alert(AG_ALREADY_EXISTS);
            return false;
        }
        return true;
    }
  
    var originalSaveChanges = this.saveChanges;
    this.saveChanges = function saveChanges_()
    {
        if("reClassification" == "<xss:encodeForJavaScript><%=classificationMode%></xss:encodeForJavaScript>")
        {
            var editFormObject = this;
            if (this.formEditDisplay) {
                editFormObject = this.formEditDisplay;
            }
            var url = "../documentcentral/emxMultipleClassificationReclassifyPreProcess.jsp";
            editFormObject.document.forms["editDataForm"].action = url;
            editFormObject.document.forms["editDataForm"].target = "formEditHidden";
            editFormObject.document.forms["editDataForm"].submit();
        }
        else
        {
            originalSaveChanges.apply(this, arguments);
        }
    }

    this.callSaveChanges = function callSaveChanges()
    {
        originalSaveChanges.apply(this, arguments);
    }
	
 // Changes added by PSA11 start(IR-544034-3DEXPERIENCER2018x).   
 // Checking for Bad characters in the field
    function checkBadNameChars(fieldName) 
    {
    	if(!fieldName)
        {
        	fieldName=this;
        }
        if(fieldName.value!=null && fieldName.value!="" )
        {
          var isBadNameChar=checkForNameBadChars(fieldName,true);
          var fieldValue=fieldName.value;
          var orgLen = fieldValue.replace(/[.]/g, '');
      	  var name;
      	  
          if(fieldName.title!="undefined" && fieldName.title!="" && fieldName.title!="null"){
        	  	name = fieldName.title;
        	  }
          else {
        	  	name = fieldName.name;
        	  }
      
          if(( isBadNameChar.length > 0 || orgLen.length==0)&& isBadNameChar!="")
          {
        	//XSSOK
        	  var nameAllBadCharName = getAllNameBadChars(fieldName);
        	  msg = "<%=i18nNow.getI18nString("emxLibraryCentral.FormErrorMsg.InvalidInputMsg",resourceBundle,language)%>";
            msg += isBadNameChar;
            msg += "<%=i18nNow.getI18nString("emxLibraryCentral.FormErrorMsg.AlertInvalidInput", resourceBundle,language)%>";
            msg += nameAllBadCharName;
            msg += " in the " + name;
            msg += "  <%=i18nNow.getI18nString("emxLibraryCentral.FormErrorMsg.Field", resourceBundle,language)%> ";
            fieldName.focus();
            alert(msg);
            return false;
          }
        }
        return true;
     }    
   // Changes added by PSA11 end.
   // for classification attributes form - bae3
</script>
   <% if(formName != null && formName.equals("LBCAttributeCreationForm")){ %>
<script>
   //for classification attribute creation
   function reloadDimensionUnits()
   {
	   	emxFormReloadField("PreferredUnit");
   }
   
   function lbcAttributeMinMaxValidation(){
	   try{
		   var type = emxFormGetValue("Type").current.actual;
		   var Minimum = emxFormGetValue("Minimum").current.actual;
		   var Maximum = emxFormGetValue("Maximum").current.actual;
		   var Default = emxFormGetValue("Default").current.actual;
		   var Choices = emxFormGetValue("Choices").current.actual;
		   var multiVal = emxFormGetValue("IsMultivalue").current.actual;
		   if(Maximum){
			   Maximum = Maximum.trim();
		   }
		   if((!Choices || Choices.trim().length == 0) && (type == 'integer' || type == 'real')){
			   if(type == 'integer'){
				   if(Minimum && !isStringAnIntegerValue(Minimum)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.MinimumNotAnInteger")%></xss:encodeForJavaScript>");
					   this.focus();
					   return false;
				   }else if(isIntegerOutOfLimit(Minimum)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.MinimumOutOfLimitInt")%></xss:encodeForJavaScript>");
					   this.focus();
					   return false;
				   }
				   if(Maximum && !isStringAnIntegerValue(Maximum)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.MaximumNotAnInteger")%></xss:encodeForJavaScript>");
					   document.forms[0]['Maximum'].focus();
					   return false;
				   }else if(isIntegerOutOfLimit(Maximum)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.MaximumOutOfLimitInt")%></xss:encodeForJavaScript>");
					   document.forms[0]['Maximum'].focus();
					   return false;
				   }
			   }else if(type == 'real'){
				   if(Minimum && !isStringReal(Minimum)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.MinimumNotNumber")%></xss:encodeForJavaScript>");
					   this.focus();
					   return false;
				   }else if(isRealOutOfLimit(Minimum)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.MinimumOutOfLimitReal")%></xss:encodeForJavaScript>");
					   this.focus();
					   return false;
				   }
				   if(Maximum && !isStringReal(Maximum)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.MaximumNotNumber")%></xss:encodeForJavaScript>");
					   document.forms[0]['Maximum'].focus();
					   return false;
				   }else if(isRealOutOfLimit(Maximum)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.MaximumOutOfLimitReal")%></xss:encodeForJavaScript>");
					   document.forms[0]['Maximum'].focus();
					   return false;
				   }
			   }
			   if(Minimum && !Maximum){
				   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.MaximumCannotBeEmpty")%></xss:encodeForJavaScript>");
				   document.forms[0]['Maximum'].focus();
				   return false;
			   }
			   if(!Minimum && Maximum){
				   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.MinimumCannotBeEmpty")%></xss:encodeForJavaScript>");
				   this.focus();
				   return false;
			   }
			   var min = parseFloat(Minimum);
			   var max = parseFloat(Maximum);
			   if(min > max){
				   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.MinimumGreaterThanMaximum")%></xss:encodeForJavaScript>");
				   this.focus();
				   return false;
			   }
			   if(multiVal == 'false'){
				   if(Minimum && Maximum && (!Default || Default.trim().length == 0)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.DefaultNotSet")%></xss:encodeForJavaScript>");
					   document.forms[0]['Default'].focus();
					   return false;
				   }else{
					   var def = parseFloat(Default);
					   if(min > def){
						   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.DefaultLessThanMinimum")%></xss:encodeForJavaScript>");
						   document.forms[0]['Default'].focus();
						   return false;
					   }
					   if(def > max){
						   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.DefaultGreaterThanMaximum")%></xss:encodeForJavaScript>");
						   document.forms[0]['Default'].focus();
						   return false;
					   }
				   }
			   }
		   }
		   return true;
	   }catch(err){
		   console.log(err);
	   }
   }
   
   function lbcAttributeDescriptionValidation(){
	   var Description = emxFormGetValue("Description").current.actual;
	   if(Description && Description.trim().length > 0){
		   var descrNoSpace = Description.split(' ').join('');
		   if(!descrNoSpace.test(/^[a-zA-Z0-9_]*$/)){
			   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.DescriptionContainsSpecialChar")%></xss:encodeForJavaScript>");
			   this.focus();
			   return false;
		   }
	   }
	   return true;
   }
   
   function lbcAttributeChoicesValidation(){
	   var type = emxFormGetValue("Type").current.actual;
	   var Default = emxFormGetValue("Default").current.actual;
	   var Choices = emxFormGetValue("Choices").current.actual;
	   var multiVal = emxFormGetValue("IsMultivalue").current.actual;
	   var ieBrowser = Browser.IE;
	   if(Choices && Choices.trim().length > 0 && (type == 'string' || type == 'integer' || type == 'real')){
		   var choicesArray = Choices.split(/\r\n|\r|\n/);
		   var newArray = [];
		   for (var i = 0; i < choicesArray.length; i++) {
			   var value = choicesArray[i].trim();
			   if(value.length > 0){
				   if(type == 'integer'){
					   if(!isStringAnIntegerValue(value)){
						   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.ChoicesNotInteger")%></xss:encodeForJavaScript>");
						   this.focus();
						   return false;
					   }else if(isIntegerOutOfLimit(value)){
						   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.ChoicesOutOfLimitInt")%></xss:encodeForJavaScript>");
						   this.focus();
						   return false;
					   }
				   }else if(type == 'real'){
					   if(!isStringReal(value)){
						   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.ChoicesNotNumber")%></xss:encodeForJavaScript>");
						   this.focus();
						   return false;
					   }else if(isRealOutOfLimit(value)){
						   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.ChoicesOutOfLimitReal")%></xss:encodeForJavaScript>");
						   this.focus();
						   return false;
					   }
				   }else if(type == 'string'){
					   var valueNoSpace = value.split(' ').join('');
					   if(!valueNoSpace.test(/^[a-zA-Z0-9_]*$/)){
						   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.ChoicesContainsSpecialChar")%></xss:encodeForJavaScript>");
						   this.focus();
						   return false;
					   }
				   }
				   newArray.push(value);
			   }
		   }
		   if(multiVal == 'false'){
			   Default = Default.trim();
			   if(ieBrowser){
				   if(newArray.indexOf(Default) == -1){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.DefaultNotAmongChoices")%></xss:encodeForJavaScript>");
					   this.focus();
					   return false;
				   }
			   }else{
				   if(!newArray.includes(Default)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.DefaultNotAmongChoices")%></xss:encodeForJavaScript>");
					   this.focus();
					   return false;
				   }
			   }
		   }
	   }
	   return true;
   }
   
   function lbcAttributeDefaultValidation(){
	   try{
		   var type = emxFormGetValue("Type").current.actual;
		   var Default = emxFormGetValue("Default").current.actual;
		   var multiVal = emxFormGetValue("IsMultivalue").current.actual;
		   if(multiVal == 'false' && Default && Default.trim().length > 0){
			   if(type == 'string' || type == 'multiline'){
				   var defaultNoSpace = Default.split(' ').join('');
				   if(!defaultNoSpace.test(/^[a-zA-Z0-9_]*$/)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.DefaultContainsSpecialChar")%></xss:encodeForJavaScript>");
					   this.focus();
					   return false;
				   }
			   }else if(type == 'integer'){
				   if(!isStringAnIntegerValue(Default)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.DefaultNotAnInteger")%></xss:encodeForJavaScript>");
					   this.focus();
					   return false;
				   }else if(isIntegerOutOfLimit(Default)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.DefaultOutOfLimitInt")%></xss:encodeForJavaScript>");
					   this.focus();
					   return false;
				   }
			   }else if(type == 'real'){
				   if(!isStringReal(Default)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.DefaultNotNumber")%></xss:encodeForJavaScript>");
					   this.focus();
					   return false;
				   }else if(isRealOutOfLimit(Default)){
					   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.DefaultOutOfLimitReal")%></xss:encodeForJavaScript>");
					   this.focus();
					   return false;
				   }
			   }
		   }
		   return true;
	   }catch(err){
		   console.log(err);
	   }
   }
   
   function isIntegerOutOfLimit(value){
	   var input = parseFloat(value);
	   if(input > 2147483647 || input < -2147483648)
		   return true;
	   else
		   return false;
   }
   
   function isRealOutOfLimit(value){
	   var input = parseFloat(value);
	   if(input > 1e125 || input < -1e125)
		   return true;
	   else
		   return false;
   }
   
   function isStringAnIntegerValue(value){
	   value = value.trim();
       return (/^-?[0-9]+$/).test(value);
   }
   
   function isStringReal(value) {
       return ("." != value && "-" != value && "-." != value && /^-{0,1}\d*\.{0,1}\d*$/.test(value));
   }
   
   function lbcAttrPredicateValidation(){
	   var predi = bossPredi.value;
	   if(!predi || predi.length == 0){
		   bossPredi.value = "";
	   }else{
		   var selectArray = sixwTagAutoSelect.selectedItems;
		   if(selectArray.length == 0){
			   bossPredi.value = "";
		   }else{
			   var prediVal = selectArray[0].value;
			   if(!prediVal || prediVal.length == 0){
				   bossPredi.value = "";
			   }
		   }
	   }
	   return true;
   }
      
	function lbcAttrNameValidation()
	{
	   try{
		   var Name = emxFormGetValue("Name").current.actual;
		   if(Name)
			   Name = Name.trim();
		   if(Name.length == 0){
			   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.NoName")%></xss:encodeForJavaScript>");
			   this.focus();
			   return false;
		   }
		   if(Name.length > 127){
			   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.TitleTooLong")%></xss:encodeForJavaScript>");
			   this.focus();
			   return false;
		   }
		   if(!isNaN(Name.charAt(0))){
			   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.FirstLetterNumeric")%></xss:encodeForJavaScript>");
			   this.focus();
			   return false;
		   }
		   var nameNoSpace = Name.split(' ').join('');
		   if(!nameNoSpace.match(/^[a-zA-Z0-9]*$/)){
			   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.TitleBadChars")%></xss:encodeForJavaScript>");
			   this.focus();
			   return false;
		   }
		   var url             = "../documentcentral/emxLibraryCentralAttributeValidationUtil.jsp?Name="+encodeURIComponent(Name);
	       var xmlResult       = emxUICore.getXMLData(url);
	       var root            = xmlResult.documentElement;
	       var nameExists  = emxUICore.getText(emxUICore.selectSingleNode(root, "/ValidationError"));
	       if (nameExists != "") {
	    	   alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attribute.NonUniqueAttributeName")%></xss:encodeForJavaScript> "+nameExists);
	    	   this.focus();
	    	   return false;
	       }
	       return true;
	   }catch(err){
		   console.log(err);
	   }
	}
	
var bossPredi;
var bossTest;
var sixwTagAutoSelect;
var tenant = "<xss:encodeForJavaScript><%=context.getTenant()%></xss:encodeForJavaScript>";
var clntlangboss = "<%=XSSUtil.encodeForJavaScript(context,language)%>";
if(clntlangboss)clntlangboss = clntlangboss.substr(0,2);
var myAppsURLboss = "<%=FrameworkUtil.getMyAppsURL(context, request, response)%>";
var curUserIdboss = "<%=XSSUtil.encodeForJavaScript(context,context.getUser())%>";

var AttrUtilsView;
'use strict';
require(['DS/UIKIT/Autocomplete','DS/FedDictionaryAccess/FedDictionaryAccessAPI'], function(Autocomplete, Dico){
		AttrUtilsView ={
				selectedType : 'string',
				listOf6Wpredicates : null,
				PredicateDataTypeAttributeMatch : function (iDataType, iAttributeType){
					if (iDataType.toUpperCase().indexOf(iAttributeType.toUpperCase()) >= 0){
						return true;
					}
					if ((iDataType.toUpperCase().indexOf("DOUBLE") >= 0) && (iAttributeType === "Real")){
						return true;
					}
					return false;
				},
				FilterPredicatesListbyType : function (attrType, listofsixWTags, sixwTagSelector){
					var dataItems, newObject, predicatesList, propt;
					dataItems = {name : "Avaliable_ds6w_tag", items: []};
					sixwTagSelector.removeDataset(dataItems.name);
					for (propt in listofsixWTags){
						if (listofsixWTags[propt].properties.length > 0){
							newObject = {'label' : listofsixWTags[propt].label, 'items': []};
							predicatesList = listofsixWTags[propt].properties;
							if (predicatesList !== undefined && predicatesList.length > 0){
								predicatesList.forEach(function (item){
									if (AttrUtilsView.PredicateDataTypeAttributeMatch(item.dataType, attrType) === true){
										newObject.items.push({
											value : item.curi,
											label : item.label
										});
									}
								});
								if (newObject.items.length > 0){
									newObject.items.sort(function (tagOne, tagTwo){
										if (tagOne.label !== undefined && tagTwo.label !== undefined){
											return tagOne.label.localeCompare(tagTwo.label);
										}
										return false;
									});
									dataItems.items.push(newObject);
								}
							}
						}
					}
					sixwTagSelector.addDataset(dataItems);
				},
				filter6WRootPredicates : function (listofsixWTags) {
	                var predicatesList, propt = "ds6w";
	                if (listofsixWTags[propt].properties.length > 0) {
	                    predicatesList = listofsixWTags[propt].properties;
	                    if (predicatesList !== undefined && predicatesList.length > 0) {
	                        listofsixWTags[propt].properties = predicatesList.filter(AttrUtilsView.isThisNotARootPredicates);
	                    }
	                }
	                return listofsixWTags;
	            },
	            isThisNotARootPredicates : function  (item) {
	                return ((item.subPropertyOf === "") ? false : true);
	            },
				fetchAndPopulate6WPredicates : function (sixWTagControl, attributeType, tenant){
					var tenantName = 'OnPremise';
					if(tenant && tenant.trim().length > 0){
						tenantName = tenant.trim();
					}
					if (AttrUtilsView.listOf6Wpredicates === null) {
	                    	var ontologyServiceObj =  {
	                                onComplete: function(result) {
	                                	AttrUtilsView.listOf6Wpredicates = AttrUtilsView.filter6WRootPredicates(result);
	                                	AttrUtilsView.FilterPredicatesListbyType(attributeType, AttrUtilsView.listOf6Wpredicates, sixWTagControl);
										emxFormDisableField("Type", true);
	                                },
	                                onFailure: function(errorMessage) {
	                                    console.log("predicates service request Fail!" + errorMessage);
	                                },
	                                tenantId: tenantName,
	                                lang: navigator.language,
	    							onlyMappable: true 							
	                            };
	                            var config = {
									myAppsBaseUrl: myAppsURLboss,
									userId: curUserIdboss,
									lang: clntlangboss
								}
								if(typeof Dico.setConfigForMyApps !== 'undefined')
									Dico.setConfigForMyApps(config);
	                            Dico.getFedProperties(ontologyServiceObj);

	                    } else {
	                        if (sixWTagControl !== undefined && sixWTagControl !== null) {
	                            AttrUtilsView.FilterPredicatesListbyType(attributeType, AttrUtilsView.listOf6Wpredicates, sixWTagControl);
	                        }
	                    }
				},
				buildAutoComplete : function (){
					var sixwTagAutoSelect = new Autocomplete({
						closableItems: false,
						showSuggestsOnFocus: true,
						filterEngine: function (suggestions) { 
							return suggestions;
						},
						events:{
							onKeyDown: function(e){
								if (e.keyCode === 32){
									e.preventDefault();
								}else if (e.keyCode === 13){
									e.stopImmediatePropagation();
									return false;
								}
							},
							onKeyUp: function(e){
								if (e.keyCode === 32){
									sixwTagAutoSelect.showAll();
								}
								if(sixwTagAutoSelect.selectedItems.length == 0){
									emxFormSetValue("Parametric", "false", "False");			
									emxFormDisableField("Parametric");
								}
							},
							onUnselect : function (item){
								emxFormSetValue("Parametric", "false", "False");			
								emxFormDisableField("Parametric");
								sixwTagAutoSelect.showAll();
								bossPredi.value = '';
								return item;
							},
							onSelect : function (item){
								var selected6wTagValue = sixwTagAutoSelect.selectedItems[0].value;
								bossPredi.value = selected6wTagValue;
								var type = emxFormGetValue("Type").current.actual;
								if(type == 'string' || type == 'multiline' || type == 'boolean'){
									emxFormSetFieldEditable("Parametric", true);
								}
								return item;
							},
							onShowSuggests : function(item){
								return item;
							}
						}
					});
					return sixwTagAutoSelect;
				}
		};
		if(bossTest){
			sixwTagAutoSelect = AttrUtilsView.buildAutoComplete().inject(bossTest);
			AttrUtilsView.fetchAndPopulate6WPredicates(sixwTagAutoSelect, 'String', tenant);
		}
	});
	
	function lbcAttributePreProcess()
	{
		emxFormDisableField("Type");
		emxFormDisableField("Dimensions");
		emxFormDisableField("PreferredUnit");
		emxFormDisableField("Minimum");
		emxFormDisableField("Maximum");
		emxFormDisableField("Parametric");
		document.forms[0]['DefaultBoolean'].parentNode.parentNode.style.display = "none";
		document.forms[0]['DefaultDate'].parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.style.display = "none";
		bossTest = document.getElementById('BossPredicate_html');
		if(AttrUtilsView){
			sixwTagAutoSelect = AttrUtilsView.buildAutoComplete().inject(bossTest);
			AttrUtilsView.fetchAndPopulate6WPredicates(sixwTagAutoSelect, 'String', tenant);
		}
		bossPredi = document.getElementsByName("BossPredicate")[0];
		document.forms[0]['Description'].placeholder = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attributes.DescriptionPlaceHolder")%></xss:encodeForJavaScript>";
		document.forms[0]['Choices'].placeholder = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attributes.ChoicesPlaceHolderString")%></xss:encodeForJavaScript>";
	}
	
	function lbcAttributeOnTypeChange()
	{
		var type = emxFormGetValue("Type").current.actual;
		var multiVal = emxFormGetValue("IsMultivalue").current.actual;
		if(type == 'timestamp'){
			document.forms[0]['Default'].parentNode.parentNode.style.display = "none";
			document.forms[0]['DefaultBoolean'].parentNode.parentNode.style.display = "none";
			document.forms[0]['DefaultDate'].parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.style.display = "";
			basicClear('DefaultDate');
			if(multiVal == 'false'){
				emxFormDisableField("DefaultDate", true);
			}else{
				emxFormDisableField("DefaultDate", false);
			}
		}else if(type == 'boolean'){
			document.forms[0]['Default'].parentNode.parentNode.style.display = "none";
			document.forms[0]['DefaultBoolean'].parentNode.parentNode.style.display = "";
			document.forms[0]['DefaultDate'].parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.style.display = "none";
			emxFormSetValue("DefaultBoolean", "false", "False");
			if(multiVal == 'false'){
				emxFormDisableField("DefaultBoolean", true);
			}else{
				emxFormDisableField("DefaultBoolean", false);
			}
		}else{
			document.forms[0]['Default'].parentNode.parentNode.style.display = "";
			document.forms[0]['DefaultBoolean'].parentNode.parentNode.style.display = "none";
			document.forms[0]['DefaultDate'].parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.style.display = "none";
			basicClear('Default');
			if(multiVal == 'false'){
				emxFormDisableField("Default", true);
			}else{
				emxFormDisableField("Default", false);
			}
		}
		if(type == 'real'){
			emxFormSetFieldEditable("Dimensions", true);
			emxFormSetFieldEditable("PreferredUnit", true);
		}else{
			emxFormSetValue("Dimensions", "BLANK_DIMENSION", "--Select a Dimension--");
			emxFormSetValue("PreferredUnit", "BLANK_UNIT", "--Select a Unit--");
			emxFormDisableField("Dimensions");
			emxFormDisableField("PreferredUnit");
		}
		
		if(type == 'multiline'){
			emxFormSetValue("IsMultivalue", "false", "False");
			emxFormDisableField("IsMultivalue", false);
			emxFormDisableField("Default", false);
		}else{
			emxFormSetValue("IsMultivalue", "false", "False");
			emxFormDisableField("IsMultivalue", true);
		}
		basicClear('Minimum');
		basicClear('Maximum');
		basicClear('Choices');
		basicClear('BossPredicate');
		emxFormSetValue("Parametric", "false", "False");			
		emxFormDisableField("Parametric");
		
		if(type == 'real' || type == 'integer'){
			emxFormSetFieldEditable("Minimum", true);
			emxFormSetFieldEditable("Maximum", true);
		}else{
			emxFormDisableField("Minimum");
			emxFormDisableField("Maximum");
		}
		
		if(type == 'real' || type == 'integer' || type == 'string'){
			emxFormSetFieldEditable("Choices", true);
		}else
			emxFormDisableField("Choices");
		
		var sendType = '';
		if(type == 'timestamp')
			sendType = 'Date';
		else if(type == 'string')
			sendType = 'String';
		else if(type == 'multiline')
			sendType = 'String';
		else if(type == 'boolean')
			sendType = 'Boolean';
		else if(type == 'integer')
			sendType = 'Integer';
		else if(type == 'real')
			sendType = 'Real';
		AttrUtilsView.FilterPredicatesListbyType(sendType, AttrUtilsView.listOf6Wpredicates, sixwTagAutoSelect);
		if(type == 'real' || type == 'integer'){
			document.forms[0]['Choices'].placeholder = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attributes.ChoicesPlaceHolderNumber")%></xss:encodeForJavaScript>";
		}else if(type == 'string'){
			document.forms[0]['Choices'].placeholder = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.Attributes.ChoicesPlaceHolderString")%></xss:encodeForJavaScript>";
		}else{
			document.forms[0]['Choices'].placeholder = "";
		}
	}
	
	function lbcAttributeOnMultiValChange()
	{
		var type = emxFormGetValue("Type").current.actual;
		var multiVal = emxFormGetValue("IsMultivalue").current.actual;
		if(type == 'timestamp'){
			if(multiVal == 'false'){
				emxFormDisableField("DefaultDate", true);
			}else{
				emxFormDisableField("DefaultDate", false);
			}
			basicClear('DefaultDate');
		}else if(type == 'boolean'){
			if(multiVal == 'false'){
				emxFormDisableField("DefaultBoolean", true);
			}else{
				emxFormSetValue("DefaultBoolean", "false", "False");
				emxFormDisableField("DefaultBoolean", false);
			}
		}else{
			if(multiVal == 'false'){
				emxFormDisableField("Default", true);
			}else{
				emxFormDisableField("Default", false);
			}
			basicClear('Default');
		}
	}
	
	function lbcAttributeOnChoicesChange()
	{
		var type = emxFormGetValue("Type").current.actual;
		if(type == 'real' || type == 'integer'){
			var choices = emxFormGetValue("Choices").current.actual;
			if(choices && choices.trim().length > 0){
				basicClear('Minimum');
				basicClear('Maximum');
				emxFormDisableField("Minimum", false);
				emxFormDisableField("Maximum", false);
			}else{
				emxFormDisableField("Minimum", true);
				emxFormDisableField("Maximum", true);
			}
		}
	}
	
	function lbcAttributeOnMinMaxChange()
	{
		var type = emxFormGetValue("Type").current.actual;
		if(type == 'real' || type == 'integer'){
			var choices = emxFormGetValue("Choices").current.actual;
			var Minimum = emxFormGetValue("Minimum").current.actual;
			var Maximum = emxFormGetValue("Maximum").current.actual;
			if(Minimum && Minimum.trim().length > 0 || Maximum && Maximum.trim().length > 0){
				emxFormDisableField("Choices", false);
				basicClear('Choices');
			}else{
				emxFormDisableField("Choices", true);
			}
		}
	}
	
	
	function setScopListVal(){
		//var val = document.getElementsByName("name")[0].type;
		alert("222222222222222222");
	}
</script>
<%} %>
