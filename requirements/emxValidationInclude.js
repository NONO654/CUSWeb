/*** emxValidationInclude.js
 * @quickreview HAT1 ZUD 14:06:25 :  ReCorrection IR-158681V6R2015 - ST: Special character in "Revision" field are allowed on "Copy Requirement" and "Edit Requirement Specification" form.
 * 
 * */

function basicValidation(formName,field,fieldName,bCheckEmptyString,bCheckLength,bBadChar,bCheckNumeric,bCheckPositive,bCheckInteger,bBadCharType)
{
  var bFlag = true;
  if (bCheckEmptyString)
  {
    //alert("Empty Check");
    bFlag = checkEmptyString(formName,field,fieldName);
  }

  if (bFlag && bCheckLength)
  {
    //alert("Length check");
    bFlag = checkLength(formName,field,fieldName);
  }

  if (bFlag && bBadChar)
  {
    //alert("BadChar check");
    bFlag = checkBadChar(formName,field,fieldName,bBadCharType)
  }

  if (bFlag && bCheckNumeric)
  {
    //alert("Numeric Check");
    bFlag = checkNumeric(formName,field,fieldName)
  }

  if (bFlag && bCheckPositive)
  {
    //alert("Positive Numeric Check");
    bFlag = checkPositiveNumeric(formName,field,fieldName)
  }

  if (bFlag && bCheckInteger)
  {
    //alert("Integer Check");
    bFlag = checkInteger(formName,field,fieldName)
  }

  return bFlag;
}

function checkEmptyString(formName,field,fieldName)
{
  if (trimWhitespace(field.value) == '')
  {
   // var msg = fieldName;
   var msg = ALERT_EMPTYFIELD;
   // msg += " " + fieldName ;
   //msg += "<%=i18nStringNowUtil("emxProduct.Alert.Field",bundle,acceptLanguage)%>";
    field.focus();
    alert(msg);
    return false;
  }
  return true;
}

function checkLength(formName,field,fieldName)
{
  var maxLength= MAX_LENGTH;
  if (!isValidLength(field.value,0,maxLength))
  {
  //  var msg = fieldName;


    //msg = "<%=i18nStringNowUtil("emxProduct.Alert.MaxLengthAlert1",bundle,acceptLanguage)%>";
    //msg += ' ';
    //msg += fieldName;
    //msg += "<%=i18nStringNowUtil("emxProduct.Alert.MaxLengthAlert2",bundle,acceptLanguage)%>";
    //msg += ' ' + maxLength + ' ';
    //msg += "<%=i18nStringNowUtil("emxProduct.Alert.MaxLengthAlert3",bundle,acceptLanguage)%>";
    //msg += ' ';
    //msg += fieldName;
 var msg =ALERT_CHECK_LENGTH;
msg += ' ' + maxLength + ' ';
    field.focus();
    alert(msg);
    return false;
  }
  return true;
}

// The following function  was modified for bug no.281645. Illegal characters and restricted bad characters have now been merged into BadChars now.The function  and the function call has also been modified accordingly now.

function checkBadChar(formName,field,fieldName,bBadCharType)
{
  var badChars = "";
  if(bBadCharType == "BadChars")
  badChars=checkForBadChars(field);
  else
  badChars=checkForNameBadChars(field,true);

  if ((badChars).length != 0)
  {
    msg =ALERT_INVALID_CHARS;
    msg += badChars;
   // msg += "<%=i18nStringNowUtil("emxProduct.Alert.RemoveInvalidChars", bundle,acceptLanguage)%> ";
   // msg += fieldName;
   // msg += "<%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    field.focus();
    alert(msg);
    return false;
  }
  return true;
}

function checkNumeric(formName,field,fieldName)
{
  if (!(isNumeric(field.value, true)))
  {
   var msg =ALERT_CHECK_NUMERIC;
   // msg += fieldName;
   // msg += "<%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    field.focus();
    alert(msg);
    return false;
  }
  return true;
}

function checkPositiveNumeric(formName,field,fieldName)
{
  if (field.value < 0)
  {
   var msg = ALERT_CHECK_POSITIVE_NUMERIC;
  //  msg += fieldName;
  //  msg += "<%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    field.focus();
    alert(msg);
    return false;
  }
  return true;
}

function checkInteger(formName,field,fieldName)
{
  if (trimWhitespace(field.value) != '' && parseInt(field.value) != field.value)
  {
   var msg =ALERT_CHECK_INTEGER;
   // msg += fieldName;
   // msg += "<%=i18nStringNowUtil("emxProduct.Alert.Field", bundle,acceptLanguage)%> ";
    field.focus();
    alert(msg);
    return false;
  }
  return true;
}

//This method is being called in the create/edit pages of Rules
function checkForExpBadChar(formName,field,fieldName)
{
  //Begin of add by Enovia MatrixOne, for bug 302675 dated 10 May 2005
  //check for empty parenthesis
  var openCount = 0;
  var emptyString = 0
  for (var i=0 ; i < field.value.length ; i++)
  {
	  // Modified by Enovia MatrixOne for Bug # 306380 Date 06/21/2005
	  if (field.value.charAt(i) == "(")
	  {
		  openCount = 1;
		  emptyString = 1;
	  }
	  // Modified by Enovia MatrixOne for Bug # 306380 Date 06/21/2005
	  else if (openCount != 0 && field.value.charAt(i) == ")" && emptyString == 1)
	  {
		  openCount = 0;
		  message = ALERT_INVALID_PARENTHESIS;
		  alert(message);
		  return false;
	  }
	  else if (openCount != 0 && field.value.charAt(i) != " ")
	  {
		  emptyString = 0;
	  }
  }
  //End of add by Enovia MatrixOne, for bug 302675 dated 10 May 2005
  var badChars = "";
  badChars = checkForNameBadChars(field,true);
  badChars = badChars.replace("\"", "");
  // Begin of modify by Enovia MatrixOne for Bug # 306380 Date 06/21/2005
  badChars = badChars.replace("(", "");
  badChars = badChars.replace(")", "");
  // End of modify by Enovia MatrixOne for Bug # 306380 Date 06/21/2005
  badChars = badChars.replace("~", "");
  badChars = trimWhitespace(badChars);
  if ((badChars).length != 0)
  {
    msg =ALERT_INVALID_CHARS;
	badChars = badChars.replace("\"", "");
    msg += badChars;
    field.focus();
    alert(msg);
    return false;
  }
  return true;
}

/*Start IR-158681V6R2015  HAT1 ZUD validationRevision() in added for REQ Duplicate->Revision.*/
function validateRevision(field, fieldName, alertBadChar, charArray)
{
	if(!field){
	  field=this;
	}
    var fieldValue = field.value;
    if(fieldValue==""){
	   var msg = ALERT_EMPTYFIELD;
	   // msg += " " + fieldName ;
	   //msg += "<%=i18nStringNowUtil("emxProduct.Alert.Field",bundle,acceptLanguage)%>";
	   field.focus();
	   alert(msg);
	   return false;
    }
    var charUsed = checkStringForChars(fieldValue,charArray,false);
    
    if(fieldValue.length>0 && charUsed.length >=1)
    {   
    	alert(alertBadChar+"\t"+fieldName+"\n"+charArray);
    	return false;
    }
    return true;
}

/*End IR-158681V6R2015  HAT1 ZUD*/
