<%--  UIFormValidation.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/UIFormValidation.jsp 1.8.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

 --%>
<%-- Common Includes --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%
String accLanguage  = request.getHeader("Accept-Language");
%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<SCRIPT LANGUAGE="JavaScript">
<!--

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
                        msg = "<%=i18nNow.getI18nString("emxProduct.Alert.ReleasedAndEffectiveProducts",bundle,acceptLanguage)%>";
                        alert(msg);
                        return false;
                    }
                }
            }
        }
        else if(trimWhitespace(strSED) == '')
        {
            //Condition Check when only Start Effectivity is not entered. Start Effectivity is also needed.
            msg = "<%=i18nNow.getI18nString("emxProduct.Alert.EmptyStartEffectivity",bundle,acceptLanguage)%>";
            alert(msg);
            return false;
        }
        else if(trimWhitespace(strEED) == '')
        {
            //Condition Check when only End Effectivity is not entered. End Effectivity is also needed.
            msg = "<%=i18nNow.getI18nString("emxProduct.Alert.EmptyEndEffectivity",bundle,acceptLanguage)%>";
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
                                msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidEffectivityDateEntry",bundle,acceptLanguage)%>";
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
            msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidEffectivityDateEntry",bundle,acceptLanguage)%>";
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
            var msg = "<%=i18nNow.getI18nString("emxProduct.Alert.checkLength",bundle,acceptLanguage)%>";
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
     // Added for special character issue -- Bug No. 361962
     if(fieldname.name!="" && fieldname.name=="Marketing Name")
     {               
        return chkMarketingNameBadChar(fieldname);
     }
     // Start - Modified for special character issue -- Bug No. 361962
     if( isBadNameChar.length > 0 && fieldname.name!="Marketing Name")
       {
    	    
           msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidChars",bundle,acceptLanguage)%>";
                msg += isBadNameChar;
             //   msg += "<%=i18nNow.getI18nString("emxProduct.Alert.RemoveInvalidChars", bundle,acceptLanguage)%> ";
             //   msg += fieldname.name;
             //   msg += " <%=i18nNow.getI18nString("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
             fieldname.focus();
             alert(msg);
             return false;             
       }
     // End - Modification 
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
        msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidChars",bundle,acceptLanguage)%>";
        msg += badChars;
       // msg += "<%=i18nNow.getI18nString("emxProduct.Alert.RemoveInvalidChars", bundle,acceptLanguage)%> ";
       // msg += fieldName.name;
       // msg += " <%=i18nNow.getI18nString("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
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
                msg = "<%=i18nNow.getI18nString("emxProduct.Alert.ImageVerticalSize",bundle,acceptLanguage)%>";
            alert(msg);
            imgVSize.focus();
            return false;
            }
          if(imgHSize.value=="" && imgVSize.value!="")
            {
                msg = "<%=i18nNow.getI18nString("emxProduct.Alert.ImageHorizontalSize",bundle,acceptLanguage)%>";
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
function CheckMinMaxInitial()
{
   if(!checkPositiveReal(this))
      return false;
   for (i = 0; i < document.forms[0].elements.length; i++ )
    {
    if(document.forms[0].elements[i] == this)
      {
        // Modified to remove dependancy on index of field in form for getting value.
      	 var MaxValue = parseFloat(document.getElementsByName("Resource Maximum")[0].value);
         var MinValue = parseFloat(document.getElementsByName("Resource Minimum")[0].value);
          var InitialValue = parseFloat(this.value);
          if(MaxValue < MinValue)
        {
        msg = "<%=i18nNow.getI18nString("emxProduct.Alert.MinMaxConstraint",bundle,acceptLanguage)%>";
        alert(msg);
        document.getElementsByName("Resource Minimum")[0].focus();
        return false;
        }
      if(InitialValue < MinValue || InitialValue > MaxValue)
        {
        msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InitialConstraint",bundle,acceptLanguage)%>";
        alert(msg);
        this.focus();
        return false;
        }
      break;
      }
    }
return true;
}

//Checking for Real Positive value of the field
function checkPositiveReal(fieldname)
{
  if(!fieldname)
    fieldname=this;
  if (isNaN(fieldname.value))
    {
    msg = "<%=i18nNow.getI18nString("emxProduct.Alert.checkPositiveNumeric",bundle,acceptLanguage)%>";
    //msg += fieldname.name;
    //msg += " <%=i18nNow.getI18nString("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    alert(msg);
    fieldname.focus();
    return false;
    }
  if (fieldname.value <= 0)
    {
    msg = "<%=i18nNow.getI18nString("emxProduct.Alert.checkPositiveInteger",bundle,acceptLanguage)%>";
    //msg += fieldname.name;
    //msg += " <%=i18nNow.getI18nString("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
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
    msg = "<%=i18nNow.getI18nString("emxProduct.Alert.checkPositiveInteger",bundle,acceptLanguage)%>";
   // msg += fieldname.name;
   // msg += "<%=i18nNow.getI18nString("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
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
                    msg = "<%=i18nNow.getI18nString("emxProduct.Alert.RegressionVersionNo",bundle,acceptLanguage)%> ";
                        msg += document.forms[0].elements[i-1].name;
                    msg += " <%=i18nNow.getI18nString("emxProduct.Alert.RegressionVersionNoThen", bundle,acceptLanguage)%> ";
                    msg += this.name;
            msg += " <%=i18nNow.getI18nString("emxProduct.Alert.RegressionVersionLeaveBlank", bundle,acceptLanguage)%> ";
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
        <%  }   %>
        if (localjsDblClick()) {
              theForm.submit();
        }

    }

function validateEditAllFixedResources()
{
   var MAXIMUM  = "<%=i18nNow.getI18nString("emxProduct.Form.Label.FixedResource.Maximum", bundle,acceptLanguage)%> ";
   var MINIMUM  = "<%=i18nNow.getI18nString("emxProduct.Form.Label.FixedResource.Minimum", bundle,acceptLanguage)%> ";
   var INITIAL  = "<%=i18nNow.getI18nString("emxProduct.Form.Label.FixedResource.Initial", bundle,acceptLanguage)%> ";
   var COMMENT  = "<%=i18nNow.getI18nString("emxProduct.Form.Label.Comments", bundle,acceptLanguage)%> ";
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
                                                        msg = "<%=i18nNow.getI18nString("emxProduct.Alert.MinMaxConstraint",bundle,acceptLanguage)%>";
                                                        alert(msg);
                                                        min.focus();
                                                        return false;
                                        } else if ((parseFloat(init.value)>parseFloat(max.value))||(parseFloat(init.value)<parseFloat(min.value)))
                                        {
                                                         msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InitialConstraint",bundle,acceptLanguage)%>";
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
    msg = "<%=i18nNow.getI18nString("emxProduct.Alert.checkPositiveNumeric",bundle,acceptLanguage)%>";
   // msg += fieldname;
   // msg += "  <%=i18nNow.getI18nString("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    alert(msg);
    field.focus();
    return false;
    }
  if (field.value < 0)
    {
    msg = "<%=i18nNow.getI18nString("emxProduct.Alert.checkPositiveInteger",bundle,acceptLanguage)%>";
  //  msg += fieldname;
  //  msg += " <%=i18nNow.getI18nString("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    alert(msg);
    field.focus();
    return false;
    }
return true;
}

function validateEditAllResourceUsage()
{
        var USAGE  = "<%=i18nNow.getI18nString("emxProduct.Table.Usage", bundle,acceptLanguage)%> ";
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
        msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidChars",bundle,acceptLanguage)%>";
        msg += badChars;
        msg += "<%=i18nNow.getI18nString("emxProduct.Alert.RemoveInvalidChars", bundle,acceptLanguage)%> ";
        msg += fieldName;
        msg += " <%=i18nNow.getI18nString("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
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
                msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidEstimatedExecutionDate",bundle,acceptLanguage)%>";
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
    var displayForm       = displayframe.document.forms[0];
    var estimatedStDate   = "";//Field 'Estimate Start Date'
    var estimatedEndDate  = "";//Field 'Estimate End Date'
    eval("estimatedStDate = document.forms[0].EstimatedStartDate_msvalue");
    eval("estimatedEndDate = document.forms[0].EstimatedEndDate_msvalue");
    if( !(trimWhitespace(estimatedStDate.value) == '' || trimWhitespace(estimatedEndDate.value) == '') )
    {
        if(estimatedStDate.value > estimatedEndDate.value)
         {
             msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidEstimatedExecutionDate",bundle,acceptLanguage)%>";
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
      msg = "<%=i18nNow.getI18nString("emxProduct.Alert.EmptyStartEffectivity",bundle,acceptLanguage)%>";
      alert(msg);
      return false;
    }else if(trimWhitespace(strEED) == '' && trimWhitespace(strSED) != '')
    {
      //Condition Check when only End Effectivity is not entered. End Effectivity is also needed.
      msg = "<%=i18nNow.getI18nString("emxProduct.Alert.EmptyEndEffectivity",bundle,acceptLanguage)%>";
      alert(msg);
      return false;
    }else
    {
      var fieldSED = new Date(strSED);
      var fieldEED = new Date(strEED);
      if (fieldSED > fieldEED)
      {
        //Condition check when Start Effectivity Date is after End Effectivity Date. It should be before the End Effectivity //Date
        msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidEffectivityDateEntry",bundle,acceptLanguage)%>";
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
          msg = "<%=i18nNow.getI18nString("emxProduct.Alert.checkPositiveNumeric",bundle,acceptLanguage)%>";

          alert(msg);
          fieldname.focus();
          return false;
      }
     if(fieldname.value >100 )
      {
          msg = "<%=i18nNow.getI18nString("emxProduct.Alert.checkMaxValueForPercentage ",bundle,acceptLanguage)%>";
          alert(msg);
          fieldname.focus();
          return false;

      }
      return true;
  }
/*End of Add by Enovia MatrixOne for Bug # 303258 on 4/26/2005*/
//-->

// Added by Praveen V for Structure Compare Dialog

function disableCheckBoxForCompareBy()
{
     var formObject = document.editDataForm;
     var matchBasedOn = formObject.MatchBasedOn;
     var compareBy = formObject.CompareBy;
     
     for (var i=0;i<matchBasedOn.length; i++)
     {
         if (matchBasedOn[i].checked)
         {
             compareBy[i].disabled = true;
             compareBy[i].checked = false;
         }
         else
         {
            compareBy[i].disabled = false;
         }
     }

}

function checkMatchBasedOnAndDisableCheckBoxForCompareBy(fieldPos)
{
     var formObject = document.editDataForm;
     var matchBasedOn = formObject.MatchBasedOn;
     var compareBy = formObject.CompareBy;
     var isChecked = 0;
     var checkPos = fieldPos;
    
     for(var j = 0; j<matchBasedOn.length; j++){
         
        if(matchBasedOn[j].checked){
            checkPos = j;
            isChecked++;
        }
        
     }  
        if(isChecked >= 1)
        {
        for (var i=0;i<matchBasedOn.length; i++)
            {
            if (matchBasedOn[i].checked)
                {
                compareBy[i].disabled = true;
                compareBy[i].checked = false;
                }
            else
                {
                 compareBy[i].disabled = false;
                 }
            }
        }
  else
      {
	   msg = "<%=i18nNow.getI18nString("emxProduct.Alert.NoMatchBasedOnSelected",bundle,acceptLanguage)%>";
       alert(msg);
       matchBasedOn[checkPos].checked = true;
      }
}

function disableCheckBoxForMatchBasedOn()
{
     var formObject = document.editDataForm;
     var matchBasedOn = formObject.MatchBasedOn;
     var compareBy = formObject.CompareBy;
     
     for (var i=0;i<compareBy.length; i++)
     {
         if (compareBy[i].checked)
         {
	         if(matchBasedOn[i]!=null){
	             matchBasedOn[i].disabled = true;
	             matchBasedOn[i].checked = false;
             }
         }
         else
         {
	         if(matchBasedOn[i]!=null){
	            matchBasedOn[i].disabled = false;
	         }
         }
     }
}

function disableCheckBoxForMatchBasedOnAndCompareBy()
{
     var formObject = document.editDataForm;
     var matchBasedOn = formObject.MatchBasedOn;
     var compareBy = formObject.CompareBy;
     //Disabling Compare By section
     for (var i=0;i<compareBy.length; i++)
     {
         compareBy[i].disabled = true;
         compareBy[i].checked = false;
     }
     //Disabling Match Based On section  
     for (var i=0;i<matchBasedOn.length; i++)
     {
     	if(matchBasedOn[i]!=null){
	         matchBasedOn[i].disabled = true;
    	     matchBasedOn[i].checked = false;
         }
     }
}

function enableCheckBoxForMatchBasedOnAndCompareBy()
{
     var formObject = document.editDataForm;
     var matchBasedOn = formObject.MatchBasedOn;
     var compareBy = formObject.CompareBy;
     //enabling Compare By section
     for (var i=0;i<compareBy.length; i++)
     {
         compareBy[i].disabled = false;
     }
     //enabling Match Based On section  
     for (var i=0;i<matchBasedOn.length; i++)
     {
         matchBasedOn[i].disabled = false;
     }
}
function ClearDesignResponsibility(fieldName) {

	var formElement= eval ("document.forms[0]['"+ fieldName + "']");

	if (formElement){


	if(formElement.length>1){
		
		if (formElement[i].value != ""){
			
			   	var response = window.confirm("You are removing Design Responsibility for this object. This operation would let all the Product Managers and System Engineers to access the object. Do you want to continue? Click 'OK' to remove Design Responsibility, Click 'Cancel' to retain Design Responsibility. ");
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
			   	var response = window.confirm("You are removing Design Responsibility for this object. This operation would let all the Product Managers and System Engineers to access the object. Do you want to continue? Click 'OK' to remove Design Responsibility, Click 'Cancel' to retain Design Responsibility. ");
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

function ClearPartFamily(fieldName) {

    var formElement= eval ("document.forms[0]['"+ fieldName + "']");

    if (formElement){


    if(formElement.length>1){
        
        if (formElement[i].value != ""){
            
                var response = window.confirm("You are removing Part Family for this object");
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
                var response = window.confirm("You are removing Design Responsibility for this object");
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
</SCRIPT>


<!-- TEST Code for Autonomy Search Integration -->
<SCRIPT LANGUAGE="JavaScript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></SCRIPT>

<script language="javascript">

	strPersonFormFieldName = "Owner";

 function showPersonSelector()
{
	    var objCommonAutonomySearch = new emxCommonAutonomySearch();

	   objCommonAutonomySearch.txtType = "type_Person";
	   objCommonAutonomySearch.selection = "single";
	   objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchForPerson"; 
	   objCommonAutonomySearch.open();
}
function submitAutonomySearchForPerson(arrSelectedObjects) 
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
        msg ="<%=i18nNow.getI18nString("emxProduct.Alert.InvalidChars",bundle,acceptLanguage)%>"+" "+charUsed;
        fieldname.focus();
        alert(msg);
        return false;
    }
    return true;
}
//END - Added for bug no. IR-052159V6R2011x

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
	  	    msg = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidDateShipped","emxProductLineStringResource",acceptLanguage)%>";
		    alert(msg);
		    return false;
		    
		}
	}
	return true;
}

function validateKeyInType()
{
    var keyInValue = emxFormGetValue("Key-In Type");
    var crtKeyInObj = keyInValue.current;
    var curActualKeyInVal = crtKeyInObj.actual;
    
    var SelTpValue = emxFormGetValue("Selection Type");
    var crtSelTpObject = SelTpValue.current;
    var curActualSelTpVal = crtSelTpObject.actual;
    
    var kBlank = "<%=i18nNow.getI18nString("emxProduct.Range.KeyIn_Type.Blank","emxConfigurationStringResource",accLanguage)%>";
    var sMultiple = "<%=i18nNow.getI18nString("emxConfiguration.SelectionType.Multiple","emxConfigurationStringResource",accLanguage)%>";
    var sSingle = "<%=i18nNow.getI18nString("emxConfiguration.SelectionType.Single","emxConfigurationStringResource",accLanguage)%>";
    var Alert = "<%=i18nNow.getI18nString("emxConfiguration.Form.Alert.KeyInTypeValidationFailed","emxConfigurationStringResource",accLanguage)%>";
    
    if(curActualKeyInVal != kBlank && curActualSelTpVal == sMultiple)
    {
        alert(Alert);
        document.getElementById("Selection TypeId").value = sSingle;
        return false;
    }
    return true;
}


function checkPositiveRealForMax()
{
  var maxValField = document.getElementsByName("Resource Maximum")[0];
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
	        var ruleName = document.forms[0].Name.value;
	        var ruleOldName = document.forms[0].NamefieldValue.value;
	        
	        var url="../configuration/RuleDialogValidationUtil.jsp?mode=isDuplicateName&type="+ruleType+"&name="+encodeURIComponent(ruleName)+"&revision=-";
	        var vRes = emxUICore.getData(url);
	        var iIndex = vRes.indexOf("isDup=");
	        var iLastIndex = vRes.indexOf("#");
	        var bcrExp = vRes.substring(iIndex+"isDup=".length , iLastIndex );
	        if(trim(bcrExp)== "true"){
	            alert("<emxUtil:i18nScript localize='i18nId'>emxProduct.Rule.AlreadyExists</emxUtil:i18nScript>");
	            document.forms[0].Name.value=ruleOldName; 
	            return false;            
	        }
	        return true;
}

//-->
</SCRIPT>
<!-- TEST Code for Autonomy Search Integration -->
