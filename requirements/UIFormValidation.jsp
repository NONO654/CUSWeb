<%--  UIFormValidation.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: /ENORequirementsManagementBase/CNext/webroot/requirements/UIFormValidation.jsp 1.4.2.1.1.1 Wed Oct 29 22:20:01 2008 GMT przemek Experimental$";

 --%>
 
 <%--
 @quickreview T25 OEP 12:08:17 (IR-168526V6R2013x "STP:Unwanted message is displayed while invoking "Edit Requirement Specification" form.")
 --%>
 <%-- @quickreview T25 OEP 21 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags and tag Lib are included--%>
<%-- Common Includes --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ page import="com.matrixone.apps.framework.ui.*,java.text.*"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>


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
                        msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.ReleasedAndEffectiveProducts")%>";
                        alert(msg);
                        return false;
                    }
                }
            }
        }
        else if(trimWhitespace(strSED) == '')
        {
            //Condition Check when only Start Effectivity is not entered. Start Effectivity is also needed.
            msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.EmptyStartEffectivity")%>";
            alert(msg);
            return false;
        }
        else if(trimWhitespace(strEED) == '')
        {
            //Condition Check when only End Effectivity is not entered. End Effectivity is also needed.
            msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.EmptyEndEffectivity")%>";
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
                msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.InvalidEffectivityDateEntry")%>";
                alert(msg);
                return false;
            }

        }

     return true;
}

// Start:IR:168526V6R2013x:T25
//Review:OEP
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
          alert("<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxProduct.Alert.RemoveInvalidChars")%></xss:encodeForJavaScript>" + "\t" + fieldActualName + "\n" + charArray );
          return false;
         }
    return true;
}

//END:IR:168526V6R2013x:T25

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
            msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.InvalidEffectivityDateEntry")%>";
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
            var msg = "<%=EnoviaResourceBundle.getProperty(context,bundle, context.getLocale(),"emxFramework.CustomTable.NameBadChars")%>";
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
       return checkLength(this);
}

// Checking for Bad characters in the field
function CheckBadNameChars(fieldname) {
       if(!fieldname)
      fieldname=this;
     var isBadNameChar=checkForNameBadChars(fieldname,true);
       if( isBadNameChar.length > 0 )
       {
                msg = "<%=EnoviaResourceBundle.getProperty(context,bundle, context.getLocale(),"emxRequirements.Alert.InvalidChars")%>";
                msg += isBadNameChar;
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
        msg = "<%=EnoviaResourceBundle.getProperty(context,bundle, context.getLocale(),"emxRequirements.Alert.InvalidChars")%>";
        msg += badChars;
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
        if(document.forms[0].elements[i-1].value!="" || document.forms[0].elements[i-2].value!="")
        {
          if(document.forms[0].elements[i-1].value=="" && document.forms[0].elements[i-2].value!="")
            {
                msg = "<%=EnoviaResourceBundle.getProperty(context,bundle, context.getLocale(),"emxRequirements.Alert.ImageVerticalSize")%>";
            alert(msg);
            document.forms[0].elements[i-1].focus();
            return false;
            }
          if(document.forms[0].elements[i-2].value=="" && document.forms[0].elements[i-1].value!="")
            {
                msg = "<%=EnoviaResourceBundle.getProperty(context,bundle, context.getLocale(),"emxRequirements.Alert.ImageHorizontalSize")%>";
            alert(msg);
            document.forms[0].elements[i-2].focus();
            return false;
            }
          if(this.value == "Pixel")
            {
            if(!(checkPositiveInteger(document.forms[0].elements[i-2]) && checkPositiveInteger(document.forms[0].elements[i-1])))
              return false;
            }
          else
            {
            if(!(checkPositiveReal(document.forms[0].elements[i-2]) && checkPositiveReal(document.forms[0].elements[i-1])))
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
      var MaxValue = parseFloat(document.forms[0].elements[i-2].value);
          var MinValue = parseFloat(document.forms[0].elements[i-1].value);
          var InitialValue = parseFloat(this.value);
          if(MaxValue < MinValue)
        {
        msg = "<%=EnoviaResourceBundle.getProperty(context,bundle, context.getLocale(),"emxRequirements.Alert.MinMaxConstraint")%>";
        alert(msg);
        document.forms[0].elements[i-1].focus();
        return false;
        }
      if(InitialValue < MinValue || InitialValue > MaxValue)
        {
        msg = "<%=EnoviaResourceBundle.getProperty(context,bundle, context.getLocale(),"emxRequirements.Alert.InitialConstraint")%>";
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
    msg = "<%=EnoviaResourceBundle.getProperty(context,bundle, context.getLocale(),"emxRequirements.Alert.checkPositiveNumeric")%>";
    alert(msg);
    fieldname.focus();
    return false;
    }
  if (fieldname.value < 0)
    {
    msg = "<%=EnoviaResourceBundle.getProperty(context,bundle, context.getLocale(),"emxRequirements.Alert.checkPositiveInteger")%>";

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
    msg = "<%=EnoviaResourceBundle.getProperty(context,bundle, context.getLocale(),"emxRequirements.Alert.checkPositiveInteger")%>";
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
                    msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.RegressionVersionNo")%> ";
                        msg += document.forms[0].elements[i-1].name;
                    msg += " <%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.RegressionVersionNoThen")%> ";
                    msg += this.name;
            msg += " <%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.RegressionVersionLeaveBlank")%> ";
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
				theForm.action = "../common/emxTable.jsp?toolbar=<xss:encodeForJavaScript><%=strToolbar%></xss:encodeForJavaScript>";
		<%	}	%>
		if (localjsDblClick()) {
              theForm.submit();
        }

    }

function validateEditAllFixedResources()
{
   var MAXIMUM  = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Form.Label.FixedResource.Maximum")%> ";
   var MINIMUM  = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Form.Label.FixedResource.Minimum")%> ";
   var INITIAL  = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Form.Label.FixedResource.Initial")%> ";
   var COMMENT  = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Form.Label.Comments")%> ";
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
                                                        msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.MinMaxConstraint")%>";
                                                        alert(msg);
                                                        min.focus();
                                                        return false;
                                        } else if ((parseFloat(init.value)>parseFloat(max.value))||(parseFloat(init.value)<parseFloat(min.value)))
                                        {
                                                         msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.InitialConstraint")%>";
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
    msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.checkPositiveNumeric")%>";
    alert(msg);
    field.focus();
    return false;
    }
  if (field.value < 0)
    {
    msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.checkPositiveInteger")%>";
    alert(msg);
    field.focus();
    return false;
    }
return true;
}

function validateEditAllResourceUsage()
{
        var USAGE  = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Table.Usage")%> ";
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
        msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.InvalidChars")%>";
        msg += badChars;
        msg += "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.RemoveInvalidChars")%> ";
        msg += fieldName;
        msg += " <%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.Field")%> ";
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
                msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.InvalidEstimatedExecutionDate")%>";
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
             msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.InvalidEstimatedExecutionDate")%>";
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
      msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.EmptyStartEffectivity")%>";
      alert(msg);
      return false;
    }else if(trimWhitespace(strEED) == '' && trimWhitespace(strSED) != '')
    {
      //Condition Check when only End Effectivity is not entered. End Effectivity is also needed.
      msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.EmptyEndEffectivity")%>";
      alert(msg);
      return false;
    }else
    {
      var fieldSED = new Date(strSED);
      var fieldEED = new Date(strEED);
      if (fieldSED > fieldEED)
      {
        //Condition check when Start Effectivity Date is after End Effectivity Date. It should be before the End Effectivity //Date
        msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.InvalidEffectivityDateEntry")%>";
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
          msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.checkPositiveNumeric")%>";

          alert(msg);
          fieldname.focus();
          return false;
      }
  	 if(fieldname.value >100 )
      {
          msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.checkMaxValueForPercentage")%>";
          alert(msg);
          fieldname.focus();
          return false;











      }
      return true;
  }
/*End of Add by Enovia MatrixOne for Bug # 303258 on 4/26/2005*/
//-->
// Added for Bug 347409 to clear Design Responsibility field on 1/3/2008
function ClearDesignResponsibility(fieldName) {

	var formElement= eval ("document.forms[0]['"+ fieldName + "']");

	if (formElement){


	if(formElement.length>1){
		
		if (formElement[i].value != ""){
			
			   	var response = window.confirm("You are removing Design Responsibility for this object. This operation would let all the Requirement Managers and System Engineers to access the object. Do you want to continue? Click 'OK' to remove Design Responsibility, Click 'Cancel' to retain Design Responsibility. ");
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
			   	var response = window.confirm("You are removing Design Responsibility for this object. This operation would let all the Requirement Managers and System Engineers to access the object. Do you want to continue? Click 'OK' to remove Design Responsibility, Click 'Cancel' to retain Design Responsibility. ");
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

//This function is used to prepopulate the RPS2 Part Name field if second object Id is already available
function preProcessInBOMCompare() {
	if(getTopWindow().window.info && getTopWindow().window.info["CompareCriteriaJSON"] && getTopWindow().window.info["CompareCriteriaJSON"].RSP2NameDisplay) {
		reloadCompareCriteria(document.editDataForm);
	} else {
		if(document.editDataForm.RSP2PreloadName.value !="") {
			document.editDataForm.RSP2NameDisplay.value = document.editDataForm.RSP2PreloadName.value;
			document.editDataForm.RSP2NameDispOID.value = document.editDataForm.RSP2PreloadID.value;
			document.editDataForm.RSP2Name.value = document.editDataForm.RSP2PreloadName.value;
		}
		
		if(document.editDataForm.RSP1PreloadName.value !="") {
			document.editDataForm.RSP1NameDisplay.value = document.editDataForm.RSP1PreloadName.value;
			document.editDataForm.RSP1NameDispOID.value = document.editDataForm.RSP1PreloadID.value;
			document.editDataForm.RSP1Name.value = document.editDataForm.RSP1PreloadName.value;
			
			document.editDataForm.RSP1NameOID.value = document.editDataForm.RSP1NameOID.value;
		}
	}
}


function selectAllOptions(elemId) {
	
	var objForm = document.editDataForm;	
 	
 	if(objForm.selectAll.checked)
 	{
 		for (var i=0; i < objForm.elements.length; i++) {
            if ((objForm.elements[i].id.indexOf(elemId) > -1)&& (!objForm.elements[i].disabled))
            {
               objForm.elements[i].checked = true;
            }	       
       }
 	}
 	else
 	{
 		var defaultElemName = elemId+"_default";    
 	   	var objForm = document.editDataForm;
 	
 	   for (var i=0; i < objForm.elements.length; i++) {
 	       if ((objForm.elements[i].id.indexOf(elemId) > -1)&& (!objForm.elements[i].disabled))
 	       {   
 	                      
 	    	   if (objForm.elements[i].id==defaultElemName) {
 	               objForm.elements[i].checked = true;
 	    	   }
 	    	   else {
 	        	   objForm.elements[i].checked = false;  
 	    	   }  
 	       }
 	    }
 	}
        
 }

function onChangeMatchBasedOn(elemId)
{
	var elem  = document.editDataForm.elements[elemId][0].value;
	var column1  = document.editDataForm.MatchBasedOn.options.selectedIndex;
	var column2  = document.editDataForm.MatchBasedOn1.options.selectedIndex;
	column2 = column2 - 1;
	if(column2 > 0)
	{
		document.editDataForm.MatchBasedOn2.disabled = false;
	}else{
		document.editDataForm.MatchBasedOn2.disabled = true;
	}
	var column3  = document.editDataForm.MatchBasedOn2.options.selectedIndex;
	column3 = column3 - 1;
	var i = 0;
	
	var selIndex  = document.editDataForm.elements[elemId].options.selectedIndex;
	if(elem === "None")
	{
		selIndex = selIndex - 1;
	}
		if(document.editDataForm.MatchBasedOn!=undefined) {
			var chkBox = document.editDataForm.repDiffChk;
			for(; i < chkBox.length; i++)
				{
					if(i == selIndex)
					{
						chkBox[selIndex].disabled = true;
					}else{
						if(column1 !== i && column2 !== i && column2 !== i )
							chkBox[i].disabled = false;
					}
				}
	  	}
		else 
			{
				var chkBox = document.editDataForm.repDiffChk[selIndex]
				chkBox.disabled = true;
			}
 }
</SCRIPT>

