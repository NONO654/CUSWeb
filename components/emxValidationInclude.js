


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
    //var msg = fieldName;
    //msg += "<%=i18nStringNowUtil("emxComponents.Alert.ReqFieldsAlert",bundle,acceptLanguage)%>";
    //msg += " " + fieldName ;
   //msg += "<%=i18nStringNowUtil("emxComponents.Alert.Field",bundle,acceptLanguage)%>";
    var msg = ALERT_EMPTYFIELD;
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
    //var msg = fieldName;
    //msg = "<%=i18nStringNowUtil("emxComponents.Alert.MaxLengthAlert1",bundle,acceptLanguage)%>";
    //msg += ' ';
    //msg += fieldName;
    //msg += "<%=i18nStringNowUtil("emxComponents.Alert.MaxLengthAlert2",bundle,acceptLanguage)%>";
    //msg += ' ' + maxLength + ' ';
    //msg += "<%=i18nStringNowUtil("emxComponents.Alert.MaxLengthAlert3",bundle,acceptLanguage)%>";
    //msg += ' ';
    //msg += fieldName;
//msg += "<%=i18nStringNowUtil("emxComponents.Alert.Field",bundle,acceptLanguage)%>";
    var msg = ALERT_CHECK_LENGTH;
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
  if(bBadCharType == checkBadChars)
  badChars=checkForBadChars(field);
  else
  badChars=checkForNameBadChars(field,true);

  if ((badChars).length != 0)
  {
    msg = ALERT_INVALID_CHARS;
    msg += badChars;
   // msg += "<%=i18nStringNowUtil("emxComponents.Alert.RemoveInvalidChars",bundle,acceptLanguage)%> ";
   // msg += fieldName;
   // msg += "<%=i18nStringNowUtil("emxComponents.Alert.Field",bundle,acceptLanguage)%> ";
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
    var msg = ALERT_CHECK_NUMERIC +' '+fieldName;
    //msg = "<%=i18nStringNowUtil("emxComponents.Alert.Numeric",bundle,acceptLanguage)%>";
    //msg += fieldName;
    //msg += "<%=i18nStringNowUtil("emxComponents.Alert.Field", bundle,acceptLanguage)%> ";
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
    var msg = ALERT_CHECK_POSITIVE_NUMERIC+' '+fieldName;;
    //msg = "<%=i18nStringNowUtil("emxComponents.Alert.NumericPositive",bundle,acceptLanguage)%>";
    //msg += fieldName;
    //msg += "<%=i18nStringNowUtil("emxComponents.Alert.Field", bundle,acceptLanguage)%> ";
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
	  
    var msg = ALERT_CHECK_INTEGER+' '+fieldName;;
    //msg = "<%=i18nStringNowUtil("emxComponents.Alert.Integer",bundle,acceptLanguage)%>";
    //msg += fieldName;
    //msg += "<%=i18nStringNowUtil("emxComponents.Alert.Field", bundle,acceptLanguage)%> ";
    field.focus();
    alert(msg);
    return false;
  }
  
  if (trimWhitespace(field.value) != '' && field.value > MAX_INTEGER_VALUE )
  {
	  var msg = ALERT_CHECK_INTEGER+' '+fieldName;;
	    //msg = "<%=i18nStringNowUtil("emxComponents.Alert.Integer",bundle,acceptLanguage)%>";
	    //msg += fieldName;
	    //msg += "<%=i18nStringNowUtil("emxComponents.Alert.Field", bundle,acceptLanguage)%> ";
	    field.focus();
	    alert(msg);
	    
	    return false;
  }
  return true;
}
