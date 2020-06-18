

function basicValidation(formName,field,fieldName,bCheckEmptyString,bCheckLength,bBadChar,bCheckNumeric,bCheckPositive,bCheckInteger,bBadCharType)
{
  var bFlag = true;
  if (bCheckEmptyString)
  {
    bFlag = checkEmptyString(formName,field,fieldName);
  }

  if (bFlag && bCheckLength)
  {
    bFlag = checkLength(formName,field,fieldName);
  }

  if (bFlag && bBadChar)
  {
    bFlag = checkBadChar(formName,field,fieldName,bBadCharType)
  }

  if (bFlag && bCheckNumeric)
  {
    bFlag = checkNumeric(formName,field,fieldName)
  }

  if (bFlag && bCheckPositive)
  {
    bFlag = checkPositiveNumeric(formName,field,fieldName)
  }

  if (bFlag && bCheckInteger)
  {
    bFlag = checkInteger(formName,field,fieldName)
  }

  return bFlag;
}

function checkEmptyString(formName,field,fieldName)
{
  if (trimWhitespace(field.value) == '')
  {
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
 var msg =ALERT_CHECK_LENGTH;
msg += ' ' + maxLength + ' ';
    field.focus();
    alert(msg);
    return false;
  }
  return true;
}


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
    field.focus();
    alert(msg);
    return false;
  }
  return true;
}

function checkForExpBadChar(formName,field,fieldName)
{
  var openCount = 0;
  var emptyString = 0
  for (var i=0 ; i < field.value.length ; i++)
  {
	  if (field.value.charAt(i) == "(")
	  {
		  openCount = 1;
		  emptyString = 1;
	  }
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
  var badChars = "";
  badChars = checkForNameBadChars(field,true);
  badChars = badChars.replace("\"", "");
  badChars = badChars.replace("(", "");
  badChars = badChars.replace(")", "");
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

function checkModelPrefix()
{
	var inputStr = formName.txtModelPrefix.value;
	var msg;
	if(inputStr == null ||inputStr == "")
	 return true;
	if(inputStr.length > strModelPrefixLength)
	{
	    msg = ALERT_CHECK_MODELPREFIX_LENGTH;
		alert(msg + "" +strModelPrefixLength);
		return false;
	}

	
	var bAllCaps = isAllCaps(inputStr)
	if(!bAllCaps)
	{
	    msg = ALERT_CHECK_MODELPREFIX_NOT_VALID;
		alert(msg);
		formName.txtModelPrefix.focus();
		return false;
	}
	return true;
}
function isAlphaNumeric(string)
{
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
}

 var numb = '0123456789';
 var upr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

function isAllCaps(string)
{
	return isValid(string,upr);
}


function isValid(string,upr)
{
  var i; 
  if (string == "")
    {
    return false;
    }
  for (i=0; i<string.length; i++) 
  {    
	if(numb.indexOf(string.charAt(i),0) == -1)
	  {		
		if (upr.indexOf(string.charAt(i),0) == -1)
    {
      return false;
    }
	  }
  }
    return true;
}

//START - Added for bug no. IR-052159V6R2011x
function chkMarketingNameBadChar(field)
{
	var val = field.value;
	var charArray = new Array(20);
    charArray = BAD_CHAR_MARKETING_NAME.split(" ");
    var charUsed = checkStringForChars(val,charArray,false);
	
	if(val.length>0 && charUsed.length >=1)
	{		
		msg =ALERT_INVALID_CHARS+" "+charUsed;
		field.focus();
    	alert(msg);
		return false;
	}
	return true;
}
//END - Added for bug no. IR-052159V6R2011x


