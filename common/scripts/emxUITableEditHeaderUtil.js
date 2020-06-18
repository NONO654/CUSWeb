//=================================================================
// JavaScript emxUITableEditHeaderUtil
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================


//Handles both whitespaces around the text entered and 'Enter Key'(CRLF)
function trimString(strString) {
    strString = strString.replace(/^\s*/g, "");
    return strString.replace(/\s+$/g, "");
}

//validate numeric field
function isFieldNumeric(columnName, field){

    var varValue = field.value;   
    
    if (varValue == "" || varValue == null || isNaN(varValue))
    {
        alert(MUST_ENTER_VALID_NUMERIC_VALUE +" "+columnName);
        field.focus();
        return false;
    } else {
        return true;
    }
}

//validate required field
function isZeroLength(columnName, field) {
    var sField = columnName;
    var sFieldValue = "";
    if (field.type == "select-one")
    {
        sFieldValue = field.options[field.selectedIndex].value;
    } else {
        field.value = trimString(field.value);
        sFieldValue = field.value;
    }

    if (sFieldValue.length > 0)
    {
        return true;
    } else {
        alert(MUST_ENTER_VALID_VALUE +" "+ sField);
        if (field.focus)
        {
           if(field.type =="text" || field.type == "textarea" || field.type=="select-one")
            field.focus();
        }
        return false;
    }
}

//validate bad character(s)
function isBadChars(field) {
  var isBadChar=checkForBadChars(field);
       if( isBadChar.length > 0 )
       {
         alert(BAD_CHARS + isBadChar);
         field.focus();
         return false;
       }
        return true;
}

//validate bad name
function isBadNameChars(field) {
        var isBadNameChar=checkForNameBadCharsList(field);
       if( isBadNameChar.length > 0 )
       {
         alert(BAD_NAME_CHARS + isBadNameChar);
         field.focus();
         return false;
       }
        return true;
}

//validate bad restricted character(s)
function isBadRestrictedChars(field) {
        var isBadResChar=checkForRestrictedBadChars(field);
       if( isBadResChar.length > 0 )
       {
         alert(RESTRICTED_BAD_CHARS + isBadResChar);
         field.focus();
         return false;
       }
        return true;
}

//validate integer field
function isValidInteger(columnName, field){
   var index;
   var iValue=field.value;
   
    if (iValue == "" || iValue == null)
    {
        alert(MUST_ENTER_VALID_INTERGER_VALUE + columnName);
        field.focus();
        return false;
    }
   
    for (index = 0; index < iValue.length; index++){
        var digit = iValue.charAt(index);
        if (((digit < "0") || (digit > "9")))
        {
          alert(MUST_ENTER_VALID_INTERGER_VALUE + columnName);
          field.focus();
          return false;
        }
    }
    return true;
}

//validate the field based upon the validation type
function validateColumn(columnName)
{
   var formObj = document.forms[0];
   
    //validate required field
    if(formObj.isFieldRequired)
    {    
        if(formObj.isFieldRequired.value == "true")
        {
           if(!isZeroLength(columnName, formObj.valueField))
           {
               return false;
           }
        }   
    }
   
    //validate numeric field
 	var isNumericField = getElement("isNumericField");        
    if(isNumericField != null && isNumericField.value == "true")
    {
       if(!isFieldNumeric(columnName, formObj.valueField))
       {
           return false;
       }
    } 
    
    //validate integer field
    if(formObj.isIntegerField)
    {   
        if(formObj.isIntegerField.value == "true")
        {
           if(!isValidInteger(columnName, formObj.valueField))
           {
               return false;
           }
        }   
    }        

    //validate bad character(s) field
    if(formObj.badcharValidate)
    {
        if(formObj.badcharValidate.value == "true")
        {
           if(!isBadChars(formObj.valueField))
           {
               return false;
           }
        }   
    }

    //validate bad name character(s) field
    if(formObj.badnamecharValidate)
    {    
        if(formObj.badnamecharValidate.value == "true")
        {         
           if(!isBadNameChars(formObj.valueField))
           {
               return false;
           }
        }   
    }

    //validate bad restricted character(s) field
    if(formObj.badrestrictedValidate)
    {    
        if(formObj.badrestrictedValidate.value == "true")
        {
           if(!isBadRestrictedChars(formObj.valueField))
           {
               return false;
           }
        }   
    }                   
    
    return true;
}

function getElement(name)
{
	var elements = document.getElementsByName(name);
	return elements.length > 0 ? elements[0] : null;
}


