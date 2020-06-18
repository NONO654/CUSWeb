<%--  UIFormValidation.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

 --%>
<%-- Common Includes --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "ValidationInclude.inc" %>

<%@page import="com.matrixone.apps.domain.DomainConstants" %>
<%@page import="com.matrixone.apps.domain.DomainRelationship" %>
<%@page import="com.matrixone.apps.domain.DomainObject" %>
<%@page import="com.matrixone.apps.dmcplanning.MasterFeature" %>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle" %>
    
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>
<script language="javascript" src="../dmcplanning/ValidationInclude.js"></script>

<SCRIPT LANGUAGE="JavaScript">
//Checking for Bad characters in the field and Maximum length of field
function CheckBadNameCharsLength() {
       if(!CheckBadNameChars(this))
           return false;
       else
           return true;
       //return checkLength(this);
}
//Checking for Bad characters in the field
function CheckBadNameChars(fieldname) {
	if(!fieldname)
		fieldname=this;
	return basicValidation(document.editDataForm,fieldname,fieldname.name,true,false,true,false,false,false,false); 
}
//Checking for Maxlength : 100 for the field
function checkLength(fieldname)
{
    if(!fieldname)
        fieldname=this;
    var maxLength = 100;
    if (!isValidLength(fieldname.value,0,maxLength))
    {
            var msg = "<%=i18nStringNowUtil("DMCPlanning.Alert.checkLength",bundle,acceptLanguage)%>";
            msg += ' ' + maxLength + ' ';
            alert(msg);
            fieldname.focus();
            return false;
    }
    return true;
}
//Added for IR-030474V6R2011
strPersonFormFieldName = "Owner";
function showPersonSelector()
{
        var objCommonAutonomySearch = new emxCommonAutonomySearch();

       objCommonAutonomySearch.txtType = "type_Person";
       objCommonAutonomySearch.selection = "single";
       objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchForPerson"; 
       objCommonAutonomySearch.open();
}

//Added for IR-030474V6R2011
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
        msg ="<%=i18nStringNowUtil("DMCPlanning.Alert.InvalidChars",bundle,acceptLanguage)%>"+" "+charUsed;
        fieldname.focus();
        alert(msg);
        return false;
    }
    return true;
}
//END - Added for bug no. IR-052159V6R2011x
</SCRIPT>
