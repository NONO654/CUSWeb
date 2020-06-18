<%--  UIFormValidation.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: /web/productline/UIFormValidation.jsp 1.7.2.10.1.1.1.2 Mon Dec 08 12:55:30 2008 GMT ds-spaul Experimental$";

 --%>
<%-- Common Includes --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import = "com.matrixone.apps.productline.Build"%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<% 
String strModelPrefixLength = EnoviaResourceBundle.getProperty(context,"emxProductLine.Model.ModelPrefixLength");
//Below code as part of fix for BUG : 376215 - Start
String isModelPrefixValidationRequired = "false";

if( com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appInstallTypeUnitTracking",false,null,null)){
	    try{
		    String propVal =EnoviaResourceBundle.getProperty(context,"emxUnitTracking.Model.ModelPrefixMandatoryAndUnique");
			if(propVal!= null && propVal.equalsIgnoreCase("true")) {
		    	isModelPrefixValidationRequired = "true";
		    }
	    }catch (Exception e){}
}
//End of modification
String objId = emxGetParameter(request, "objectId");

boolean productBuild = false;

if(objId!= null || "".equals(objId)){
	Build build = new Build(objId);
	productBuild = build.isProductBuild(context);
}
%>
<script type="text/javascript">
var strModelPrefixLength = "<%=XSSUtil.encodeForJavaScript(context,strModelPrefixLength)%>";
</script>

<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>  
<SCRIPT LANGUAGE="JavaScript">


  // Fix for Bug 295427, removed UIPageUtility.js
  //
  // variable used to detect if a form have been submitted
  //
  var localclicked = false;

  //
  // function jsDblClick() - sets var clicked to true.
  // Used to prevent double click from resubmitting a
  // form in IE
  //
  function localjsDblClick() {
    if (!localclicked) {
      localclicked = true;
      return true;
    }
    else {
      return false;
    }
  }
  strPersonFormFieldName = "Owner";
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
   
      var objForm = document.forms["editDataForm"];

      var displayElement = objForm.elements[strPersonFormFieldName + "Display"];
      var hiddenElement1 = objForm.elements[strPersonFormFieldName];
      var hiddenElement2 = objForm.elements[strPersonFormFieldName + "OID"];

      for (var i = 0; i < arrSelectedObjects.length; i++) 
      { 
         var objSelection = arrSelectedObjects[i];
         
         displayElement.value = objSelection.name;
         hiddenElement1.value = objSelection.name;
         hiddenElement2.value = objSelection.objectId;
 
         break;
      }      

}

//Validating for Date Value
function ProductDateValidate(){

        //Begin of modify by Enovia MatrixOne for Bug# 304697 on 18-May-05
        var strSED = document.forms[0].StartEffectivity_msvalue.value;

        var strEED = document.forms[0].EndEffectivity_msvalue.value;
        //End of modify by Enovia MatrixOne for Bug# 304697 on 18-May-05

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
                        msg = "<%=i18nStringNowUtil("emxProduct.Alert.ReleasedAndEffectiveProducts",bundle,acceptLanguage)%>";
                        alert(msg);
                        return false;
                    }
                }
            }
        }
        else if(trimWhitespace(strSED) == '')
        {
            //Condition Check when only Start Effectivity is not entered. Start Effectivity is also needed.
            msg = "<%=i18nStringNowUtil("emxProduct.Alert.EmptyStartEffectivity",bundle,acceptLanguage)%>";
            alert(msg);
            return false;
        }
        else if(trimWhitespace(strEED) == '')
        {
            //Condition Check when only End Effectivity is not entered. End Effectivity is also needed.
            msg = "<%=i18nStringNowUtil("emxProduct.Alert.EmptyEndEffectivity",bundle,acceptLanguage)%>";
            alert(msg);
            return false;
        }
        else
        {
            //Begin of modify by Enovia MatrixOne for Bug# 304697 on 18-May-05
            if (strSED > strEED)
            {
            //End of modify by Enovia MatrixOne for Bug# 304697 on 18-May-05
                //Condition check when Start Effectivity Date is after End Effectivity Date. It should be before the End Effectivity //Date
                                msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidEffectivityDateEntry",bundle,acceptLanguage)%>";
                alert(msg);
                return false;
            }

        }

     return true;
}

// Begin of Add for Bug # 310342 Date 02 Nov, 2005
//Validating for Date Value for Product Configuration
function ProductConfigurationDateValidate(){

        var strSED = document.forms[0].StartEffectivity_msvalue.value;

        var strEED = document.forms[0].EndEffectivity_msvalue.value;

        var msg = "";

        if(trimWhitespace(strEED) == '')
        {
            //Condition Check when End Effectivity is not entered.
            return true;
        }
        else if (strSED > strEED)
        {

            //Condition check when Start Effectivity Date is after End Effectivity Date. It should be before the End Effectivity //Date
            msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidEffectivityDateEntry",bundle,acceptLanguage)%>";
            alert(msg);
            return false;
        }

     return true;
}
// End of Add for Bug # 310342 Date 02 Nov, 2005

//Checking for Maxlength : 100 for the field
function checkLength(fieldname)
{
    if(!fieldname)
        fieldname=this;
    var maxLength = 100;
  
    if (!isValidLength(fieldname.value,0,maxLength))
    {
            var msg = "<%=i18nStringNowUtil("emxProduct.Alert.checkLength",bundle,acceptLanguage)%>";
            msg += ' ' + maxLength + ' ';
            alert(msg);
            fieldname.focus();
            return false;
    }
    return true;
}

// Checking for Bad characters in the field and Maximum length of field
function CheckBadNameCharsLength() {
       if(!CheckBadNameChars(this))
      		return false;
       else if(!checkLength(this))
            return false;
       else
    	   return true;
}

// Checking for Bad characters in the field
function CheckBadNameChars(fieldname) {
       if(!fieldname)
      fieldname=this;
     var isBadNameChar=checkForNameBadChars(fieldname,true);
       if( isBadNameChar.length > 0 )
       {
                msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidChars",bundle,acceptLanguage)%>";
                msg += isBadNameChar;
             //   msg += "<%=i18nStringNowUtil("emxProduct.Alert.RemoveInvalidChars", bundle,acceptLanguage)%> ";
             //   msg += fieldname.name;
             //   msg += " <%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
                alert(msg);
                fieldname.focus();
                return false;
       }
        return true;
}

//Checking for Bad characters in the Text Area field
function checkBadChars(fieldName)
{
        if(!fieldName)
        fieldName=this;
        var badChars = "";
        badChars=checkForBadChars(fieldName);
        if ((badChars).length != 0)
        {
        msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidChars",bundle,acceptLanguage)%>";
        msg += badChars;
       // msg += "<%=i18nStringNowUtil("emxProduct.Alert.RemoveInvalidChars", bundle,acceptLanguage)%> ";
       // msg += fieldName.name;
       // msg += " <%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
        fieldName.focus();
        alert(msg);
        return false;
    }
    return true;
}


//Checking Image Size depending upon the Unit of Measure
function checkImageSize()
{
  for (i = 0; i < document.forms[0].elements.length; i++ )
      {
      if(document.forms[0].elements[i] == this )
        {
          // Modified to remove dependancy on index of field in form for getting value
          var imgHSize = document.getElementsByName("Image Horizontal Size")[0];
          var imgVSize = document.getElementsByName("Image Vertical Size")[0];
           
        if(imgVSize.value!="" || imgHSize.value!="")
        {
            
          if(imgVSize.value=="" && imgHSize.value!="")
            {
                msg = "<%=i18nStringNowUtil("emxProduct.Alert.ImageVerticalSize",bundle,acceptLanguage)%>";
            alert(msg);
            imgVSize.focus();
            return false;
            }
          if(imgHSize.value=="" && imgVSize.value!="")
            {
                msg = "<%=i18nStringNowUtil("emxProduct.Alert.ImageHorizontalSize",bundle,acceptLanguage)%>";
            alert(msg);
            imgHSize.focus();
            return false;
            }
          if(this.value == "Pixel")
            {
            if(!(checkPositiveInteger(imgHSize) && checkPositiveInteger(imgVSize)))
              return false;
            }
          else
            {
            if(!(checkPositiveReal(imgHSize) && checkPositiveReal(imgVSize)))
              return false;
            }
        }
        break;
        }
      }
  return true;
}


//Checking for Min, Max and Initial values of Fixed Resource
//Removing Duplicate Method CheckMinMaxInitial()


//Checking for Real Positive value of the field
function checkPositiveReal(fieldname)
{
  if(!fieldname)
    fieldname=this;
  if (isNaN(fieldname.value))
    {
    msg = "<%=i18nStringNowUtil("emxProduct.Alert.checkPositiveNumeric",bundle,acceptLanguage)%>";
    //msg += fieldname.name;
    //msg += " <%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    alert(msg);
    fieldname.focus();
    return false;
    }
  if (fieldname.value < 0)
    {
    msg = "<%=i18nStringNowUtil("emxProduct.Alert.checkPositiveInteger",bundle,acceptLanguage)%>";
    //msg += fieldname.name;
    //msg += " <%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    alert(msg);
    fieldname.focus();
    return false;
    }
return true;
}

//Checking for Positive Integer value of the field
function checkPositiveInteger(fieldname)
{
  if(!checkPositiveReal(fieldname))
    return false;

  if (parseInt(fieldname.value) != fieldname.value)
    {
    msg = "<%=i18nStringNowUtil("emxProduct.Alert.checkPositiveInteger",bundle,acceptLanguage)%>";
   // msg += fieldname.name;
   // msg += "<%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    alert(msg);
    fieldname.focus();
    return false;
    }
  return true;
}

 //Checking for the value of Regression Version depending upon the Regression value
function CheckRegressionVersion()
{
   for (i = 0; i < document.forms[0].elements.length; i++ )
   {
    if(document.forms[0].elements[i] == this)
    {
      if( (((document.forms[0].Regression[1].value=="No") && (document.forms[0].Regression[1].checked))||((document.forms[0].Regression[0].value=="No") && (document.forms[0].Regression[0].checked)) )&& (this.value != ""))
        {
                    msg = "<%=i18nStringNowUtil("emxProduct.Alert.RegressionVersionNo",bundle,acceptLanguage)%> ";
                        msg += document.forms[0].elements[i-1].name;
                    msg += " <%=i18nStringNowUtil("emxProduct.Alert.RegressionVersionNoThen", bundle,acceptLanguage)%> ";
                    msg += this.name;
            msg += " <%=i18nStringNowUtil("emxProduct.Alert.RegressionVersionLeaveBlank", bundle,acceptLanguage)%> ";
                        alert(msg);
            this.focus();
        return false
        }
      else
        {
        break;
        }
     }
    }
return true;
}

//function used in search pages to submit to emxTable.jsp to get search results
function doSearch()
{

        //get the form
        var theForm = document.forms[0];
        //set form target
        theForm.target = "searchView";

        // If the page need to do some pre-processing before displaying the results
        // Use the "searchHidden" frame for target

        //assigning the QueryLimit value entered in the footer page to queryLimit parameter in this page
                theForm.queryLimit.value=getTopWindow().frames[0].frames[2].document.forms[0].QueryLimit.value;
                theForm.action = "../common/emxTable.jsp";
      <% //Added scriplet to handle Bug 330006 
         String strToolbar = emxGetParameter(request, "toolbar");
         if(strToolbar == null || "".equals(strToolbar) || "null".equals(strToolbar)){
            strToolbar = PropertyUtil.getSchemaProperty(context,"menu_APPSearchResultToolbar");%>
            theForm.action = "../common/emxTable.jsp?toolbar=<%=XSSUtil.encodeForURL(context,strToolbar)%>";
      <% }  %>
      if (localjsDblClick()) {
              theForm.submit();
        }

    }

function validateEditAllFixedResources()
{
   var MAXIMUM  = "<%=i18nStringNowUtil("emxProduct.Form.Label.FixedResource.Maximum", bundle,acceptLanguage)%> ";
   var MINIMUM  = "<%=i18nStringNowUtil("emxProduct.Form.Label.FixedResource.Minimum", bundle,acceptLanguage)%> ";
   var INITIAL  = "<%=i18nStringNowUtil("emxProduct.Form.Label.FixedResource.Initial", bundle,acceptLanguage)%> ";
   var COMMENT  = "<%=i18nStringNowUtil("emxProduct.Form.Label.Comments", bundle,acceptLanguage)%> ";
   var msg ="";

        var displayframe = findFrame(parent, "formEditDisplay");
        var displayForm = displayframe.document.forms[0];
        var min = "";
        var max = "";
        var init = "";
        var comm = "";
        var cnt = displayForm.objCount.value;

        for(var i=0; i < cnt; i++)
        {
                        eval("min = document.forms[0].Minimum" + i);
                        eval("max = document.forms[0].Maximum" + i);
                        eval("init = document.forms[0].Initial" + i);
                        eval("comm = document.forms[0].Description" + i);
                           if (!checkPositiveRealForEditAll(min,MINIMUM))
                                        {
                                                        return false;
                                        }
                                        if (!checkPositiveRealForEditAll(max,MAXIMUM))
                                        {
                                                        return false;
                                        }
                                        if (!checkPositiveRealForEditAll(init,INITIAL))
                                        {
                                                        return false;
                                        }
                                        if (!checkBadCharsForEditAll(comm,COMMENT))
                                        {
                                                return false;
                                        }
                                        if (parseFloat(min.value)>parseFloat(max.value)){
                                                        msg = "<%=i18nStringNowUtil("emxProduct.Alert.MinMaxConstraint",bundle,acceptLanguage)%>";
                                                        alert(msg);
                                                        min.focus();
                                                        return false;
                                        } else if ((parseFloat(init.value)>parseFloat(max.value))||(parseFloat(init.value)<parseFloat(min.value)))
                                        {
                                                         msg = "<%=i18nStringNowUtil("emxProduct.Alert.InitialConstraint",bundle,acceptLanguage)%>";
                                                         alert(msg);
                                                         init.focus();
                                                         return false;
                                        }
          }
          return true;
}

//Checking for Real Positive value of the field
//Added this to display a proper name when the name are of type inital1, inital2, inital3....
function checkPositiveRealForEditAll(field,fieldname)
{
  if(!field)
    field=this;
  if (isNaN(field.value))
    {
    msg = "<%=i18nStringNowUtil("emxProduct.Alert.checkPositiveNumeric",bundle,acceptLanguage)%>";
   // msg += fieldname;
   // msg += "  <%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    alert(msg);
    field.focus();
    return false;
    }
  if (field.value < 0)
    {
    msg = "<%=i18nStringNowUtil("emxProduct.Alert.checkPositiveInteger",bundle,acceptLanguage)%>";
  //  msg += fieldname;
  //  msg += " <%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    alert(msg);
    field.focus();
    return false;
    }
return true;
}

function validateEditAllResourceUsage()
{
        var USAGE  = "<%=i18nStringNowUtil("emxProduct.Table.Usage", bundle,acceptLanguage)%> ";
        var msg ="";

        var displayframe = findFrame(parent, "formEditDisplay");
        var displayForm = displayframe.document.forms[0];
        var usage = "";
        var cnt = displayForm.objCount.value;

        for(var i=0; i < cnt; i++)
                {

                eval("usage = document.forms[0].Usage"+i);
                                if (!checkPositiveRealForEditAll(usage,USAGE))
                                {
                                                return false;
                                }
          }
                  return true;
}

//Checking for Bad characters in the Text Area field
//Added this to display a proper name when the names are of type Comment1, Comment2, Comment3....
function checkBadCharsForEditAll(field, fieldName)
{
        if(!field)
        field=this;
        var badChars = "";
        badChars=checkForBadChars(field);
        if ((badChars).length != 0)
        {
        msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidChars",bundle,acceptLanguage)%>";
        msg += badChars;
        msg += "<%=i18nStringNowUtil("emxProduct.Alert.RemoveInvalidChars", bundle,acceptLanguage)%> ";
        msg += fieldName;
        msg += " <%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
        field.focus();
        alert(msg);
        return false;
    }
    return true;
}

//Checking for Bad characters and empty string for the name field
//Added this to display a proper name when the names are of type Comment1, Comment2, Comment3....
function checkBadCharsForNameEditAll(field, fieldName) {
	if(!field)
    	field=this;
    var value = trim(field.value);
    if(value == "") {
    	var alertMsg = "<%=i18nStringNowUtil("emxProduct.Alert.checkEmptyString",bundle,acceptLanguage)%>";
		alert(alertMsg);
    	return false;
    }
    var badChars = "";
    badChars=checkForBadChars(field);
	if ((badChars).length != 0) {
		msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidChars",bundle,acceptLanguage)%>";
		msg += badChars;
		msg += "<%=i18nStringNowUtil("emxProduct.Alert.RemoveInvalidChars", bundle,acceptLanguage)%> ";
		msg += fieldName;
		msg += " <%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
     	field.focus();
     	alert(msg);
     	return false;
	}
	return true;
}

//Validating the attribute values of Test Execution during Edit All
function validateEditAllTestExecutions()
{
    var displayframe      = findFrame(parent, "formEditDisplay");
    var displayForm       = displayframe.document.forms[0];
    var estimatedStDate   = "";//Field 'Estimate Start Date'
    var estimatedEndDate  = "";//Field 'Estimate End Date'
    var cnt               = displayForm.objCount.value;

    for(var i=0; i < cnt; i++)
    {
        eval("estimatedStDate = document.forms[0].EstimatedStartDate" + i+"_msvalue");
        eval("estimatedEndDate = document.forms[0].EstimatedEndDate" + i+"_msvalue");
        if( !(trimWhitespace(estimatedStDate.value) == '' || trimWhitespace(estimatedEndDate.value) == '') )
        {
            if(estimatedStDate.value > estimatedEndDate.value)
            {
                msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidEstimatedExecutionDate",bundle,acceptLanguage)%>";
                alert(msg);
                return false;
            }
        }
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
             msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidEstimatedExecutionDate",bundle,acceptLanguage)%>";
             alert(msg);
             return false;
          }
      }
    return true;
}

  //Validating for Date Value
  function productConfigurationDateValidate(){
    var strSED = document.forms[0]["Start Effectivity"].value;
    var strEED = document.forms[0]["End Effectivity"].value;

    var msg = "";

    if(trimWhitespace(strSED) == '' && trimWhitespace(strEED) != '')
    {
      //Condition Check when only Start Effectivity is not entered. Start Effectivity is also needed.
      msg = "<%=i18nStringNowUtil("emxProduct.Alert.EmptyStartEffectivity",bundle,acceptLanguage)%>";
      alert(msg);
      return false;
    }else if(trimWhitespace(strEED) == '' && trimWhitespace(strSED) != '')
    {
      //Condition Check when only End Effectivity is not entered. End Effectivity is also needed.
      msg = "<%=i18nStringNowUtil("emxProduct.Alert.EmptyEndEffectivity",bundle,acceptLanguage)%>";
      alert(msg);
      return false;
    }else
    {
      var fieldSED = new Date(strSED);
      var fieldEED = new Date(strEED);
      if (fieldSED > fieldEED)
      {
        //Condition check when Start Effectivity Date is after End Effectivity Date. It should be before the End Effectivity //Date
        msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidEffectivityDateEntry",bundle,acceptLanguage)%>";
        alert(msg);
        return false;
      }
    }
    return true;
  }


  /*Begin of Add by Enovia MatrixOne for Bug # 303258 on 4/26/2005*/
  //Method to check whether value is positive and less than 100
  function checkPercentageValue(fieldname)
  {
   if(!fieldname) {
          fieldname=this;
      }

      if( isNaN(fieldname.value) || fieldname.value < 0 )
      {
          msg = "<%=i18nStringNowUtil("emxProduct.Alert.checkPositiveNumeric",bundle,acceptLanguage)%>";

          alert(msg);
          fieldname.focus();
          return false;
      }
    if(fieldname.value >100 )
      {
          msg = "<%=i18nStringNowUtil("emxProduct.Alert.checkMaxValueForPercentage ",bundle,acceptLanguage)%>";
          alert(msg);
          fieldname.focus();
          return false;
      }
      return true;
  }
/*End of Add by Enovia MatrixOne for Bug # 303258 on 4/26/2005*/
//
function ClearDesignResponsibility(fieldName) {

   var formElement= eval ("document.forms[0]['"+ fieldName + "']");

   if (formElement){


   if(formElement.length>1){
      
      if (formElement[i].value != ""){
         
               var response = window.confirm("<%=i18nStringNowUtil("emxProduct.Confirm.DesignResponsibility.Clear", bundle,acceptLanguage)%>");
         if(!response){
            return ;
         }
      }
      for(var i=0; i < formElement.length-1; i++)
      {
             formElement[i].value="";
      }
   }else{
         if (formElement.value != ""){
               var response = window.confirm("<%=i18nStringNowUtil("emxProduct.Confirm.DesignResponsibility.Clear", bundle,acceptLanguage)%>");
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
      for(var i=0; i < formElement.length-1; i++)
        {
          formElement[i].value="";
        }
      }else{
         formElement.value="";
      }
    }

   formElement=eval ("document.forms[0]['"+ fieldName + "OID']");

   if (formElement){
     if(formElement.length>1){
      for(var i=0; i < formElement.length-1; i++)
        {
          formElement[i].value="";
        }
      }else{
         formElement.value="";
      }
    }
}


function productCheck(){
    var strProduct = document.forms[0]["ProductOID"].value;
    var strProductConfiguration = document.forms[0]["ProductConfigurationOID"].value;
    var msg = "<emxUtil:i18nScript localize='i18nId'>emxProduct.EditBuild.Product.Check</emxUtil:i18nScript>";
    
    if(strProductConfiguration!="" && strProduct==""){
       alert(msg);
       return false;
    }
    else{
       return true;
    }
}

function autonomySearchProductConfiguration(){
   var strProductID = document.forms[0]["ProductOID"].value;
   var strBuildNumber = "Build Unit Number";
   var strShorNotation = "Build Shorthand Notation";
	   var url= "../common/emxFullSearch.jsp?field=TYPES=type_ProductConfiguration&excludeOIDprogram=emxBuild:filterRelatedProductConfiguration&table=PLCSearchProductsTable&Registered Suite=ProductLine&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&objectId="+strProductID+"&submitURL=../productline/SearchUtil.jsp&mode=ProductandProductConfigurationChooser&chooserType=ProductConfiguration&fieldName=ProductConfiguration&fieldNameActual=ProductConfigurationOID&fieldNameDisplay=ProductConfigurationDisplay&buildNumber="+strBuildNumber+"&shortHandNotation="+strShorNotation+"&buildId="+"<%=XSSUtil.encodeForURL(context,objId)%>";
    	showModalDialog(url,850,630);
}

function autonomySearchProduct(){
	var strProductID = document.forms[0]["ProductOID"].value;
	var strBuildNumber = "Build Unit Number";
	var strShorNotation = "Build Shorthand Notation";
	var strProductConfigurationID= "";
	if(document.forms[0]["ProductConfigurationOID"] != null)
	{
		strProductConfigurationID = document.forms[0]["ProductConfigurationOID"].value;
	}  
	var url= "../common/emxFullSearch.jsp?field=TYPES=type_Products&excludeOIDprogram=emxBuild:filterRelatedProduct&table=PLCSearchProductsTable&Registered Suite=ProductLine&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&objectId="+strProductConfigurationID+"&submitURL=../productline/SearchUtil.jsp&mode=ProductandProductConfigurationChooser&chooserType=Product&fieldNameActual=ProductOID&fieldNameDisplay=ProductDisplay&buildNumber="+strBuildNumber+"&shortHandNotation="+strShorNotation+"&buildId="+"<%=XSSUtil.encodeForURL(context,objId)%>";
	showModalDialog(url,850,630);  
}


function clearProduct()
{
    var strProductID = document.forms[0]["ProductOID"].value;
    var strProductDisplay = document.forms[0]["ProductDisplay"].value;
    
    var strProductConfigurationID = document.forms[0]["ProductConfigurationOID"].value;
    var strProductConfigurationDisplay = document.forms[0]["ProductConfigurationDisplay"].value;
    
    //Fix for Bug 358998  //Added if check for Bug:008577
    if(document.forms[0]["Build Unit Number"] != null && document.forms[0]["Build Unit Number"] != "undefined"){
       document.forms[0]["Build Unit Number"].value    = "0";
    }
    if(document.forms[0]["Build Shorthand Notation"] != null && document.forms[0]["Build Shorthand Notation"] != "undefined"){
     document.forms[0]["Build Shorthand Notation"].value = "";
    }
    var msg = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Confirm.Product.Clear</emxUtil:i18nScript>";
    
    
    if(strProductConfigurationDisplay!="" &&strProductConfigurationID!="" ){
       alert(msg);
       return;
    }
    else{
       document.forms[0]["ProductOID"].value="";
       document.forms[0]["ProductDisplay"].value="";
       return;
    }
}

function buildDateValidate(){

   var strActualBuildDate = document.forms[0].ActualBuildDate_msvalue.value;
    var strDateShipped = document.forms[0].DateShipped_msvalue.value;
   
   var msg = "";
   
   if(trimWhitespace(strActualBuildDate) == '')
   {
       //Condition Check when Actual Build Date is not entered.
       return true;
   }
   if(trimWhitespace(strDateShipped) == '')
   {
       //Condition Check when Date Shipped is not entered.
       return true;
   }  
   else if ( strActualBuildDate  > strDateShipped)
   {
       //Condition check when Date Shipped is before Actual Build Date.
       msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidDateShipped",bundle,acceptLanguage)%>";
       alert(msg);
       return false;
   }
    return true;
}

function checkPrefix() //not used anymore?
{           
     var strObjectId = document.editDataForm.parentOID.value;

     var inputStr = document.editDataForm.ModelPrefix.value;
      
     if(inputStr==null || inputStr=="")
     {
        alert("<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixCantBeBlank",bundle,acceptLanguage)%>")
       return false;
     }
   var url="../productline/BuildUtil.jsp?mode=checkModelPrefix&inputStr="+inputStr+"&productId="+strObjectId;
   
   var resText = emxUICore.getData(url);  
   if(resText.search(/validationMsg=true/) == -1)
   {        
      alert("<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixNotAvailable",bundle,acceptLanguage)%>");
      document.editDataForm.ModelPrefix.value = "";            
      return false;
   }
   return true;

}

//361829, begin
function checkModelPrefix()
{
   //Added for 376215 - Start
   var isValidationRequired = "<xss:encodeForJavaScript><%=isModelPrefixValidationRequired%></xss:encodeForJavaScript>"; 
   if(isValidationRequired == "true") {
	   //End of modification
	   
	   //alert("UIFormValidation.checkModelPrefix()");
	   //rewrite for 361829, first client validate and then server side validate, instead of the other way around
	   var inputStr = document.editDataForm.ModelPrefix.value;
	   
	   //check for blank string
	   if (inputStr == null || inputStr == "")
	   {
	      alert("<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixNotValid",bundle,acceptLanguage)%>")
	      document.editDataForm.ModelPrefix.focus();
	      return false;
	   }
	   
	   //check for alphanumeric
	   var isCorrect = isAlphaNumeric(inputStr)
	   if (!isCorrect)
	   {
	      alert("<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixNotAlphaNumeric",bundle,acceptLanguage)%>");
	      document.editDataForm.ModelPrefix.focus();
	      return false;
	   }
	
	   //check for invalid length
	   if (inputStr.length > strModelPrefixLength)
	   {
	      var msg = "<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixTooLong",bundle,acceptLanguage)%>";
	      alert(msg + " " + strModelPrefixLength);
	      document.editDataForm.ModelPrefix.focus();
	      return false;
	   }
	
	   //change to all caps if needed
	   var bAllCaps = isAllCaps(inputStr)
	   if (!bAllCaps)
	   {
	      //document.forms[0]["ModelPrefix"].value = inputStr.toUpperCase();//code added for Bug No: 359806
	      inputStr = inputStr.toUpperCase();
	      document.editDataForm.ModelPrefix.value = inputStr;
	   }
	
	   //finally sent to server for further validation
	   return checkModelPrefixFromServer(inputStr);
	   //Added for Bug - 376215
   } else {
	   return true;
   }
   //End - 376215
}

function checkModelPrefixFromServer(inputStr) //361829
{
   var strObjectId 
   //Fix for Bug: 372204 -- Added the condition to handle edit from "Where used" page. 
   //					parentOID is null in case of Edit from "Where used". Hence assign the Object Id
   if( document.editDataForm.parentOID != undefined){
   strObjectId = document.editDataForm.parentOID.value ;
   }else{
      strObjectId = "<%=XSSUtil.encodeForJavaScript(context,objId)%>";
   }
   //End of fix.
   var url="../productline/BuildUtil.jsp?mode=checkModelPrefix&inputStr="+inputStr+"&productId="+strObjectId;
   
   var resText = emxUICore.getDataPost(url);  
   if(resText.search(/validationMsg=true/) == -1)
   {        
      alert("<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixNotAvailable",bundle,acceptLanguage)%>");
      document.editDataForm.ModelPrefix.value = "";            
      return false;
   }
   return true;
}
//361829, end

//Added in PLC X+4 for Model Prefix validations-- Start
function validateModelPrefix() //not used anymore?
{
   var inputStr = document.forms[0]["ModelPrefix"].value;
   if(inputStr.length > strModelPrefixLength)
   {
      alert("<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixTooLong",bundle,acceptLanguage)%>");
      return false;
   }
/***** Commented by Enovia MatrixOne:Bug #358893 on 8/19/2008 ******/ 
/*
   var isCorrect = isAlphaNumeric(inputStr)
   if(!isCorrect)
   {
      alert("<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixNotAlphaNumeric",bundle,acceptLanguage)%>");
      return false;
   }
*/    
/******************************************************************/ 
   var bAllCaps = isAllCaps(inputStr)
   
   if(!bAllCaps)
   {
       document.forms[0]["ModelPrefix"].value = inputStr.toUpperCase();//code added for Bug No: 359806
      
      //Following code blocked for Bug No: 359806
        /* alert("<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixCapsOnly",bundle,acceptLanguage)%>");
           return false; */
      //End of code blocked for Bug No: 359806
   }
   return true;
}

function isAlphaNumeric(string)
{
   //corrected for 361829, previous reg expression is incorrect
   var format = /^[a-zA-Z0-9]+$/;
   return format.test(string);

   /* //wrong reg expression!
    var format=string.match(/([a-zA-Z]+[0-9])/);
    if(format)
    {
      return true;
    }
    else
    {
      return false;
    }
    return true;
   */
}

function isAllCaps(string)
{
    
/******* Added by Enovia MatrixOne:Bug #358893 on 8/19/2008*********/
 
  //var format   = string.match(/([A-Z]+[0-9])/);
  
    var format    = string.match(/([A-Z0-9])/);
    var lowerCase = string.match(/([a-z])/);
    
/***** End added by Enovia MatrixOne:Bug #358893 on 8/19/2008******/    
   
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
//Added in PLC X+4 for Model Prefix validations-- End
function isProductBuild()
{
   // var productBuild = "<xss:encodeForJavaScript><%=productBuild%></xss:encodeForJavaScript>";	
    var strBSN = document.forms[0]["Build Shorthand Notation"].value;
    var strModelVersion = document.forms[0]["ProductOID"].value;
	   if(strBSN!="" && strModelVersion=="")
	   {
	      alert("<%=i18nStringNowUtil("emxProduct.Alert.ProductBuild",bundle,acceptLanguage)%>");      
	      return false;
	   }
	   else
	   {
		   return CheckBadNameChars(this);
		   //return true;
	   }
}
function validateActualDate(){  

  for (i = 0; i < document.forms[0].elements.length; i++ )
   {
    if(document.forms[0].elements[i] == this)
    {
     var strActualBuildDate = document.forms[0].elements[i].value;
     var strShippedDate = document.forms[0].elements[i+3].value;
     return validateDates(strActualBuildDate,strShippedDate);break;
    }
   }
}

function validateShippedDate(){

  for (i = 0; i < document.forms[0].elements.length; i++ )
   {
    if(document.forms[0].elements[i] == this)
    { 
     var strActualBuildDate = document.forms[0].elements[i-3].value;
     var strShippedDate = document.forms[0].elements[i].value;
     return validateDates(strActualBuildDate,strShippedDate);break;
    }
   }
}

function validateDates(strdateActualBuildDate,strdateDateShipped){
	
	var msg = "";
	var dateActualBuildDate = new Date(strdateActualBuildDate);
	var dateDateShipped = new Date(strdateDateShipped);
	var actualBuilddate = false;
	var shippeddate = false;
	if(dateActualBuildDate == 'Invalid Date')
	{
	    //Condition Check when Actual Build Date is not entered.
	    actualBuilddate = true;
	}
	if(dateDateShipped == 'Invalid date')
	{
	    //Condition Check when Date Shipped is not entered.
	    shippeddate = true;
	}
	if(actualBuilddate == false && shippeddate == false)
	{
		if (dateActualBuildDate  > dateDateShipped)
		{
		    //Condition check when Date Shipped is before Actual Build Date.
	  	    msg = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidDateShipped</emxUtil:i18nScript>";
		    alert(msg);
		    return false;
		    
		}
	}
	return true;
}


// added by praveen

function autonomySearchDesignResponsibility(){
   var url= "../common/emxFullSearch.jsp?field=TYPES=type_Organization,type_ProjectSpace&table=PLCSearchCompanyTable&selection=single&formName=PLCSearchCompanyForm&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&objectId=<%=XSSUtil.encodeForURL(context,objId)%>&submitURL=../productline/SearchUtil.jsp?&mode=Chooser&chooserType=FormChooser&fieldNameActual=BuildResponsibilityOID&fieldNameDisplay=BuildResponsibilityDisplay&buildId=<%=XSSUtil.encodeForURL(context,objId)%>";
   showModalDialog(url,850,630);
}

//START - Added for bug no. IR-052159V6R2011x
function chkMarketingNameBadChar(fieldname)
{
    if(!fieldname) {
        fieldname=this;
    }
    var val = fieldname.value;
    var charArray = new Array(20);
    charArray = "<%=EnoviaResourceBundle.getProperty(context,"emxFramework.Javascript.NameBadChars")%>".split(" ");
    var charUsed = checkStringForChars(val,charArray,false);

    if(val.length>0 && charUsed.length >=1)
    {       
        msg ="<%=i18nStringNowUtil("emxProduct.Alert.InvalidChars",bundle,acceptLanguage)%>"+" "+charUsed;
        fieldname.focus();
        alert(msg);
        return false;
    }
    return true;
}
function validateRevision(fieldName)
{
if(!fieldName){
    fieldName=this;
    }
    var fieldValue = fieldName.value;
    var fieldActualName = fieldName.name;
    if(fieldValue==""){
        return true;
    }
    var charArray = new Array(20);
    charArray = "<%=EnoviaResourceBundle.getProperty(context,"emxFramework.CustomTable.NameBadChars")%>";
    
     var charUsed = checkStringForChars(fieldValue,charArray,false);
     
      if(fieldValue.length>0 && charUsed.length >=1)
         {
          alert("<%=XSSUtil.encodeForJavaScript(context,com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.RemoveInvalidChars", request.getHeader("Accept-Language"))) %>" + "\t" + fieldActualName + "\n" + charArray );
          return false;
         }
    return true;
}

function checkStringForChars(strText, arrBadChars, blnReturnAll){
        var strBadChars = "";
        for (var i=0; i < arrBadChars.length; i++) {
                if (strText.indexOf(arrBadChars[i]) > -1) {
                        strBadChars += arrBadChars[i] + " ";
                }
        }
        if (strBadChars.length > 0) {
                if (blnReturnAll) {
                        return arrBadChars.join(" ");
                } else {
                        return strBadChars;
                }
        } else {
                return "";
        }
}

//END - Added for bug no. IR-052159V6R2011x

//Added For SCC : START
<%
Boolean hasDesignSync =(Boolean)JPO.invoke(context, "emxVCDocumentUI", null, "hasDesignSyncServer", null, Boolean.class);
Boolean hasHDM = (Boolean)FrameworkUtil.isSuiteRegistered(context,"appVersionTeamCollaboration",false,"","");
if(hasDesignSync && hasHDM) {
        String noStoreText = EnoviaResourceBundle.getProperty(context,"Components","emxComponents.CommonDocument.NoStoreGiven",request.getHeader("Accept-Language"));
%>
        function displayDSFANavigator(allowedTypes,form)
        {
            var store = document.getElementsByName("Store");
            store = store[0];
            if(store.value){
                var strURL="../components/emxCommonVCStoreIntermediateProcess.jsp?storeName="+store.value+"&objectAction=connectVCFileFolder&suiteKey=Components&allowedTypes="+allowedTypes+"&formName="+form+"&dsfaTag=no";
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

</SCRIPT>

