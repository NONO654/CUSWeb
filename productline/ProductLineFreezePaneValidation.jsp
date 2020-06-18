<%--  ProductLineFreezePaneValidation.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

 --%>

 <%--
  @quickreview T25 DJH 13:10:03 : IR IR-248491V6R2014x : " Edit all functionality for Test Execution is KO".
 --%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxDesignTopInclude.inc"%>

<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
String languageStr = request.getHeader("Accept-Language");
String emxNameBadChars = EnoviaResourceBundle.getProperty(context,"emxFramework.Javascript.BadChars");
String invalidCharsMsg = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.InvalidChars", languageStr);
String referer = request.getHeader("Referer");
%>

var referer = "<%=XSSUtil.encodeForJavaScript(context, referer)%>";
var sBadCharInName	= "<xss:encodeForJavaScript><%=emxNameBadChars%></xss:encodeForJavaScript>";
function checkBadChars()
{
	var fieldValue = trim(arguments[0]);
	var ARR_FOR_BAD_CHARS = "";
	
	if (sBadCharInName != "") 
  	{    
  		ARR_FOR_BAD_CHARS = sBadCharInName.split(" ");
  	}
  	var namebadCharName = checkStringForChars(fieldValue,ARR_FOR_BAD_CHARS);
  	if (namebadCharName.length != 0){
    	alert("<xss:encodeForJavaScript><%=invalidCharsMsg%></xss:encodeForJavaScript>" + namebadCharName);
		return false;
	}
	return true;
}

function checkStringForChars(strText, arrBadChars) {
	var strBadChars = "";
	for (var i=0; i < arrBadChars.length; i++) {
		if (strText.indexOf(arrBadChars[i]) > -1 && arrBadChars[i] != " ") {
			strBadChars += arrBadChars[i] + " ";
		}
	}
	        
	if (eval(strBadChars.length) > 0) {
		return strBadChars;
	} else {
		return "";
	}
}

function validateActualDate(val){
	var strActualBuildDate = getDateFromUIVal(val);
	var strShippedDate = getDateFromUIVal(getValueForColumnForUPV("DateShipped"));
	return validateDates(strActualBuildDate,strShippedDate);
}
function validateShippedDate(val){
	var strShippedDate = getDateFromUIVal(val);
	var strActualBuildDate = getDateFromUIVal(getValueForColumnForUPV("ActualBuildDate"));
	return validateDates(strActualBuildDate,strShippedDate);
}
function validateDates(dateActualBuildDate, dateDateShipped){
	
	var msg = "";
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
	if (actualBuilddate == false && shippeddate == false &&( dateActualBuildDate  > dateDateShipped))
	{
	    //Condition check when Date Shipped is before Actual Build Date.
  	    msg = "<emxUtil:i18nScript localize='i18nId'>emxProduct.Alert.InvalidDateShipped</emxUtil:i18nScript>";
	    alert(msg);
	    return false;
	    
	}
	return true;
}

function getDateFromUIVal(val) {
	var strDate;
	if(val!=null && val!=undefined && val.length>0){
		if(isNaN(val)){
			strDate = new Date(val);
			strDate.setHours(12);
		} else {
			strDate = new Date(parseInt(val));
		}
	}
	return strDate
}

function getValueForColumnForUPV(colName){
   var val= getMSDateValueForColumn(colName);
   return val;
}

//Added to get MS value for the date
function getMSDateValueForColumn(colName){
    var aRows = new Array();
    aRows[0] = currentRow;
    fillupColumns(aRows, 0, aRows.length);

    var objColumn = colMap.getColumnByName(colName);
    var colIndex = objColumn.index;
   var msvalue = emxUICore.selectSingleNode(currentRow, "c[" + colIndex + "]").getAttribute("msValue");
   var msvalueNew = emxUICore.selectSingleNode(currentRow, "c[" + colIndex + "]").getAttribute("msValueNew");
    var retVal  = msvalue;	
    if(msvalueNew != undefined && msvalueNew != null && msvalueNew!="") {
	retVal = msvalueNew;
    }
   return retVal;
}

//Start T25 : DJH :IR-248491V6R2014x
  // Functions called from PLCTestExecutionList Table
  function checkPercentageValue(fieldname)
  {
    if(!fieldname) {
          fieldname=this;
      }
      
      fieldname = parseFloat(fieldname);
      if( isNaN(fieldname) || fieldname < 0 )
      {
          msg = "<%=i18nStringNowUtil("emxProduct.Alert.checkPositiveNumeric","emxProductLineStringResource",languageStr)%>";

          alert(msg);
          return false;
      }
     if(fieldname >100 )
      {
          msg = "<%=i18nStringNowUtil("emxProduct.Alert.checkMaxValueForPercentage ","emxProductLineStringResource",languageStr)%>";
          alert(msg);
          return false;

      }
      return true;
  }
  
    function validateStartDateTestExecutions(fieldname)
{  
    var estimatedStDate   = fieldname;//Field 'Estimate Start Date'
    var estimatedEndDate  = getValueForColumn("EstimatedEndDate");//Field 'Estimate End Date
    estimatedEndDate=new Date(estimatedEndDate).getTime();
    estimatedStDate=parseFloat(estimatedStDate);
    estimatedEndDate=parseFloat(estimatedEndDate);
    if( !(estimatedStDate == '' || estimatedEndDate == '') )
        {
            if(estimatedStDate > estimatedEndDate)
            {
                msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidEstimatedExecutionDate","emxProductLineStringResource",languageStr)%>";
                alert(msg);
                return false;
            }
        }
    return true;
}

    function validateEndDateTestExecutions(fieldname)
{  
    var estimatedStDate   = getValueForColumn("EstimatedStartDate");//Field 'Estimate Start Date'
    var estimatedEndDate  = fieldname;//Field 'Estimate End Date
    estimatedStDate=new Date(estimatedStDate).getTime();
    estimatedStDate=parseFloat(estimatedStDate);
    estimatedEndDate=parseFloat(estimatedEndDate);
    if( !(estimatedStDate == '' || estimatedEndDate == '') )
        {
            if(estimatedStDate > estimatedEndDate)
            {
                msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidEstimatedExecutionDate","emxProductLineStringResource",languageStr)%>";
                alert(msg);
                return false;
            }
        }
    return true;
}
//END :T25 DJH
