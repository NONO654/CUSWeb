<%--  emxDataSpecializationTableValidation.jsp
   Copyright (c) 1999-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program
 --%>

// This validation file should not contain any HTML or JavaScript tags.

<%@page contentType="text/javascript; charset=UTF-8"%>
<%@ page import="matrix.db.Context"%>
<%@page import="com.matrixone.servlet.Framework"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>

<%
  //create context variable for use in pages
  matrix.db.Context context = Framework.getFrameContext(session);

%>
<%
//NLS Messages
String nlsTrue = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanTrue");
String nlsFalse = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanFalse");
String nlsAttribute = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.Attribute");
String nlsDefaultValue = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AttributeDefaultValue");
String nlsAttrNotInteger = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.AttributeNotInteger",nlsDefaultValue);
String nlsAttrNotReal = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.AttributeNotReal",nlsDefaultValue);
String nlsAttrDefaultValueBoolean = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.AttributeNotBoolean");
String nlsAttrExceedMaxLength = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.DefaultValueExceedMaxLength");    
%>

var nlsTrue = "<%=nlsTrue%>";
var nlsFalse = "<%=nlsFalse%>";
var nlsAttribute = "<%=nlsAttribute%>";
var nlsDefaultValue = "<%=nlsDefaultValue%>";
var nlsAttrNotInteger = "<%=nlsAttrNotInteger%>";
var nlsAttrNotReal = "<%=nlsAttrNotReal%>";
var nlsAttrDefaultValueBoolean = "<%=nlsAttrDefaultValueBoolean%>";
var nlsAttrExceedMaxLength = "<%=nlsAttrExceedMaxLength%>";

var reg_Double = /^[-]?[0-9]+((\.[0-9]+)|(\,[0-9]+))?$/;

/*
* BMN2 02/12/2015 :
* Function use to check the default value of each cell modified from the attribute table
* Return a empty string to valid the value or return a string with the error message to display to the user.
*/
function checkDefaultValueFromTable(value,rowId){
	var attributeNameCell = emxEditableTable.getCellValueByRowId(rowId,"attrName"); 
	var attrName = attributeNameCell.value.current.actual;
	var cellType = emxEditableTable.getCellValueByRowId(rowId,"attrType"); 
	var s = cellType.value.current.actual;
	var jsonStr = s.slice(s.indexOf("{"),s.lastIndexOf("}")+1);
	var elem = JSON.parse(jsonStr);
	var type = elem.attribute[0].type;

	var attrNameMsg = nlsAttribute +" \""+attrName+"\" : "; 
	if(type == "String"){
	var maxLength = elem.attribute[0].maxLength;
		if(parseInt(maxLength)!=0 && value.length > parseInt(maxLength) )
		{
			return attrNameMsg + nlsAttrExceedMaxLength + "\n";
		}
	}
	else if (type == "Integer"){
		
		if(isNaN(value)){
		
			return attrNameMsg + nlsAttrNotInteger +"\n";
		}
	
	}
	else if (type == "Real"){
	
		if(!reg_Double.test(value)){
		
			return attrNameMsg + nlsAttrNotReal +"\n";
		}
	
	}
	else if (type =="Boolean"){
	
		if(trim(value).toLowerCase() != "true" && trim(value).toLowerCase() != "false"  && trim(value).toLowerCase() != trim(nlsTrue).toLowerCase() && trim(value).toLowerCase() != trim(nlsFalse).toLowerCase()){
			return attrNameMsg + nlsAttrDefaultValueBoolean +"\n";
		}
	
	}
	return "";
}

function trim(str){
	while(str.substring(0,1)==' ')
	{
		str=str.substring(1,str.length);
	}

	while(str.length > 0 && str.substring(str.length-1,str.length)==' ')
	{
		str=str.substring(0,str.length-1);
	}
	return str;
}



