<%--
=================================================================
 emxLibraryCentralUIFreezePaneValidation.jsp

 Copyright (c) 1992-2016 Dassault Systemes.
 All Rights Reserved.
 This program contains proprietary and trade secret information of MatrixOne,Inc.
 Copyright notice is precautionary only
 and does not evidence any actual or intended publication of such program
=================================================================
emxLibraryCentralUIFormValidation.jsp
 This file is used to add any validation routines to be used by the Library Central UIForm component
-----------------------------------------------------------------

--%>
<%@include file="../common/emxNavigatorNoDocTypeInclude.inc"%>

<%-- Changes added by PSA11 start(IR-544034-3DEXPERIENCER2018x) --%>
function isBadNameCharsSB(){
	    var fieldValue = arguments[0];
<%
    String languageStr = request.getHeader("Accept-Language");
    String emxNameBadChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.NameBadChars");
	emxNameBadChars = emxNameBadChars.trim();
	String sErrorMsg = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource", new Locale(languageStr),"emxLibraryCentral.Common.InvalidCharacters");
%>
	    var STR_NAME_BAD_CHARS = "<%= emxNameBadChars %>";
		var ARR_NAME_BAD_CHARS = "";
		if (STR_NAME_BAD_CHARS != "") 
		{    
		  ARR_NAME_BAD_CHARS = STR_NAME_BAD_CHARS.split(" ");   
		}
		var strBadChars  = "";
	    for (var i=0; i < ARR_NAME_BAD_CHARS.length; i++) 
        {
            if (fieldValue.indexOf(ARR_NAME_BAD_CHARS[i]) > -1) 
            {
            	strBadChars += ARR_NAME_BAD_CHARS[i] + " ";
            }
        }		
        if (strBadChars.length > 0) 
        {
        	alert("<xss:encodeForJavaScript><%=sErrorMsg%></xss:encodeForJavaScript>" + " " + STR_NAME_BAD_CHARS);
        	return false;
        }                        
		return true;
}
<%-- Changes added by PSA11 end --%>

function reloadDuplicateAttributes(value,rowID,columnName){
    // need to remove this code after AEF code promotion
    /* if(rowID == "undefined"){
        rowID = emxEditableTable.getCurrentCell().rowID;
    } */
    var currentActualValue  = emxEditableTable.getCellValueByRowId(rowID,columnName).value.current.actual;
    var currentDisplayValue = emxEditableTable.getCellValueByRowId(rowID,columnName).value.current.display;
    var columnNameValues    = columnName.split("|");
    if (colMap) {
        var attributeGroups     = colMap.getColumnByName(columnName).getSetting("AttributeGroups");
        var attributeGroupsList = attributeGroups.split("|");
        for(var i = 0; i < attributeGroupsList.length; i++) {
            if(attributeGroupsList[i] != "" && attributeGroupsList[i]!=columnNameValues[0]) {
                emxEditableTable.setCellValueByRowId(rowID,attributeGroupsList[i]+"|"+columnNameValues[1],currentActualValue,currentDisplayValue);
            }
        }
    }
}

function refreshClassificationView(strID, mode) {
    var aId = strID.split("|");
    var id  = aId[1];
    var sbframe	= findFrame(getTopWindow(),"LBCObjectClassificationList");
    sbframe.reloadSBWithGet(sbframe.resetParameter("objectId",id ));
 
}


<%
	String resourceBundle           = "emxLibraryCentralStringResource";
	String language                	= request.getHeader("Accept-Language");
	
	String MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE  = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxLibraryCentral.FormValidate.MustEnterAValidPositiveNumericValueFor");
	String MUST_ENTER_VALID_NUMERIC_VALUE           = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxFramework.FormComponent.MustEnterAValidPositiveNumericValueFor");
	
	String INVALID_ATTRIBUTE_VALUE = EnoviaResourceBundle.getProperty(context, resourceBundle, new Locale(language),"emxLibraryCentral.FormValidate.InvalidValueOfAttribute");
	String INVALID_RANGE_FORMAT = EnoviaResourceBundle.getProperty(context, resourceBundle, new Locale(language),"emxLibraryCentral.FormValidate.InvalidRangeFormat");
	String INVALID_RANGE_VALUE = EnoviaResourceBundle.getProperty(context, resourceBundle, new Locale(language),"emxLibraryCentral.FormValidate.InvalidRangeValue");
	String MINIMUM_NOT_LESS_THAN_MAXIMUM = EnoviaResourceBundle.getProperty(context, resourceBundle, new Locale(language),"emxLibraryCentral.FormValidate.MinimumNotLessThanMaximum");

%>

	var MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE = "<xss:encodeForJavaScript><%=MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE%></xss:encodeForJavaScript>";
	var MUST_ENTER_VALID_NUMERIC_VALUE          = "<xss:encodeForJavaScript><%=MUST_ENTER_VALID_NUMERIC_VALUE%></xss:encodeForJavaScript>";

	var INVALID_ATTRIBUTE_VALUE = "<%=INVALID_ATTRIBUTE_VALUE %>";
 	var INVALID_RANGE_FORMAT = "<%=INVALID_RANGE_FORMAT %>";
  	var INVALID_RANGE_VALUE = "<%=INVALID_RANGE_VALUE %>";
  	var MINIMUM_NOT_LESS_THAN_MAXIMUM = "<%=MINIMUM_NOT_LESS_THAN_MAXIMUM %>";
	
	function isPositiveRealNumber(actualValue,status) 
	{
		var varValue = actualValue;
		if (isNaN(varValue)) 
		{
			alert(MUST_ENTER_VALID_NUMERIC_VALUE + " " + this.lastUpdatedColumn);
			this.focus();
			return false;
		} 
		else if ((Math.abs(varValue)) != (varValue) || varValue == 0) 
		{
			alert(MUST_ENTER_VALID_POSITIVE_NUMERIC_VALUE + " " + this.lastUpdatedColumn);
			this.focus();
			return false;
		} 
		else 
		{
			return true;
		}
	}

function checkRangeValue(value){
	var attributeName = this.lastUpdatedColumn;
	attributeName = attributeName.substring(attributeName.indexOf('|')+1);
	if(value != ''){
		value = value.replace('[','');
		value = value.replace(']','');
	
		if(value.includes("::")){
			var rangeValues = value.split("::");
			var minVal = rangeValues[0];
			var maxVal = rangeValues[1];
			if(isNaN(minVal) || isNaN(maxVal) || (value.match(/::/g)).length>1){
				alert(INVALID_ATTRIBUTE_VALUE+attributeName+". "+INVALID_RANGE_FORMAT);
				return false;
			} else if(Number(minVal) >= Number(maxVal)){
				alert(INVALID_ATTRIBUTE_VALUE+attributeName+". "+MINIMUM_NOT_LESS_THAN_MAXIMUM);
				return false;
			}
		} else if(isNaN(value) || Number(value) <= 0){
			alert(INVALID_ATTRIBUTE_VALUE+attributeName+". "+INVALID_RANGE_VALUE);
			return false;
		}
	}
	return true;
	
	
	function setScopListVal(){
		//var val = document.getElementsByName("name")[0].type;
		alert("44444444444444");
	}
}
