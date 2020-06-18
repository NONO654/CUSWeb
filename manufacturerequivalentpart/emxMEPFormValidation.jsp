<%--  emxMEPFormValidation.jsp

    Copyright Dassault Systemes, 2007. All rights reserved
  This program is proprietary property of Dassault Systemes and its subsidiaries.
  This documentation shall be treated as confidential information and may only be used by employees or contractors
  with the Customer in accordance with the applicable Software License Agreement
  static const char RCSID[] = $Id: /ENOManufacturerEquivalentPart/CNext/webroot/manufactuerequivalentpart/emxMEPFormValidation.jsp 1.4.2.1.1.1 Wed Oct 29 22:14:50 2008 GMT przemek Experimental$

 --%>
<%-- Common Includes --%>
<%@include file = "../components/emxComponentsCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="matrix.util.*"%>
<%@page import="matrix.db.*"%>
<%@page import="com.matrixone.apps.domain.util.*"%>
<%@page import="java.util.*"%>
<%
    StringList partPoliciesList = com.matrixone.apps.manufacturerequivalentpart.Part.getEquivalentPartPolicies(context);
String strPleaseEnterValidNumber = i18nNow.getI18nString("emxManufacturerEquivalentPart.Alert.checkPositiveNumberForQueryLimit","emxManufacturerEquivalentPartStringResource",context.getSession().getLanguage());
String strLimitReached = i18nNow.getI18nString("emxManufacturerEquivalentPart.Alert.checkQueryLimitCanNotBeMoreThan","emxManufacturerEquivalentPartStringResource",context.getSession().getLanguage());
String strLimitBlank = i18nNow.getI18nString("emxManufacturerEquivalentPart.Alert.checkQueryLimitCanNotBeLeftBlank","emxManufacturerEquivalentPartStringResource",context.getSession().getLanguage());
String strLimitZero = i18nNow.getI18nString("emxManufacturerEquivalentPart.Alert.checkQueryLimitCanNotBeZero","emxManufacturerEquivalentPartStringResource",context.getSession().getLanguage());
String strQueryLimit = "32000";
%>

<SCRIPT LANGUAGE="JavaScript">

function vaultSelection()
{
  var vaultSelected = document.editDataForm.vaultOption[3].checked;
  var selectedVault = document.editDataForm.vaultsDisplay.value;
  if(vaultSelected==true && selectedVault==""){
    alert("<emxUtil:i18nScript localize='i18nId'>emxManufacturerEquivalentPart.Common.selectvault</emxUtil:i18nScript>");
      return false;
  }else{
    return true;
  }
}

function emptyDateField()
{
    var date1= document.editDataForm.RevisionDateFirst.value;
    var date2= document.editDataForm.RevisionDateLast.value;
   
    var startDate = new Date(date1);
    var endDate = new Date(date2);
    var selectedDateFieldIndex = document.editDataForm.DateOption.selectedIndex;
    if((selectedDateFieldIndex!=0 && date1=="") || (selectedDateFieldIndex==4 && date2=="")){
          alert("<emxUtil:i18nScript localize='i18nId'>emxManufacturerEquivalentPart.Common.selectDate</emxUtil:i18nScript>");
        return false;
    }else{
      if(Date.parse(startDate.toGMTString()) >= Date.parse(endDate.toGMTString()))
        {
            alert("<emxUtil:i18nScript localize='i18nId'>emxManufacturerEquivalentPart.Common.selectCorrectDate</emxUtil:i18nScript>");
        return false;
        }
       return true;
    }



}


function clearField(formName,fieldName,idName) 
{
    var operand = "document." + formName + "." + fieldName+".value = \"*\";";
    eval (operand);
    if(idName != null){
        var operand1 = "document." + formName + "." + idName+".value = \"*\";";
        eval (operand1);
    }   
    return;
}

    function loadManufacturerLocation()
    {
        var suppId= document.editDataForm.Manufacturer.value;
        if(suppId!="*"){
        var url ="../components/emxComponentsLocationSearchDialogFS.jsp?selection=multiple&helpMarker=emxhelpsearchcompany&companyId="+suppId+"&fieldOId=ManufacturerLocationOID&fieldName=ManufacturerLocationDisplay&SubmitURL=../materialscompliance/emxMCCChooserProcess.jsp&formName=editDataForm";
        showModalDialog(url, 500, 500);
        }else{
                     alert("<emxUtil:i18nScript localize='i18nId'>emxManufacturerEquivalentPart.Common.selectSupplier</emxUtil:i18nScript>");
        }
    }


var policyStateArray = new Array();
function storeArray(policyName,stateName,stateIntName)
{
    this.policyName = policyName;
    this.stateName = stateName;
    this.stateIntName = stateName;
}

function makePolicyStatesArray()
{

<%  //  to get the Policy and State details, and store into script object array
    HashMap policyMap=new HashMap();
    StringList stateList=new StringList();
    if( partPoliciesList != null)
    {
        Iterator policyItr = partPoliciesList.iterator();
        String policyName = null;
        String state = null;
        int arrayCount = 0;

        
        while(policyItr.hasNext())
        {
            //stateList       = new StringList();
            policyName      = (String)policyItr.next();
            //XSSOK
            out.println("policyStateArray[" + arrayCount++ + "] = new storeArray(\"" + policyName + "\",\"\",\"\");");
            String statesStr = "print policy $1 select $2 dump $3 ";
            String result = MqlUtil.mqlCommand(context, statesStr,policyName,"state","|");
            StringTokenizer statesTok = new StringTokenizer(result, "|");
            while (statesTok.hasMoreTokens()) {
            state = (String)statesTok.nextToken();
            if (!stateList.contains(state)) {
            stateList.add(state);
            //XSSOK
            out.println("policyStateArray[" + arrayCount++ + "] = new storeArray(\"" + policyName + "\",\"" + state + "\",\""+state+"\");");
            }
            }
            policyMap.put (policyName,stateList);
        }
    }

%>
} makePolicyStatesArray();

function showStatesForPolicy()
{
    var selectedPolicyFieldIndex = document.editDataForm.Policy.selectedIndex;
    var selectedPolicy = document.editDataForm.Policy.options[selectedPolicyFieldIndex].value;
    document.editDataForm.State.innerHTML = "";
    var optionValue = "";
    if(selectedPolicy!="")
    {
        var stateIndexCount = 0;
        for(intCount = 0;intCount<policyStateArray.length;intCount++)
        {
            if(selectedPolicy == policyStateArray[intCount].policyName)
            {
                optionValue = policyStateArray[intCount].stateName;
                optionLabel = policyStateArray[intCount].stateName;
                document.editDataForm.State.options[stateIndexCount]=new Option(optionLabel,optionValue);
                stateIndexCount++;
            }
        }
    }
}

function showDateBetweenField()
{
   var selectedDateFieldIndex = document.editDataForm.DateOption.selectedIndex;
   
   if(selectedDateFieldIndex==4){
       //document.getElementById('div_date2').style.visibility='visible';
       document.getElementById('RevisionDateLast').style.visibility='visible';
       document.getElementById('picture').style.visibility='visible';
   }else{
      //document.getElementById('div_date2').style.visibility='hidden';
      document.getElementById('RevisionDateLast').style.visibility='hidden';
      document.getElementById('picture').style.visibility='hidden';
   }
}

//Checking for Positive Real value of the field
function checkPositiveReal(fieldname)
{
    if(!fieldname) 
    {
        fieldname=this;
    }

    var value = fieldname.value;
    if( isNaN(value) || value < 0 )
    {
        msg = "<emxUtil:i18nScript localize="i18nId">emxManufacturerEquivalentPart.Alert.positiveNumeric</emxUtil:i18nScript>";
        alert(msg);
        fieldname.focus();
        return false;
    }
    return true;
}
function validateQueryLimit() {     
	   var editForm = document.forms['editDataForm'];
	   var queryLimit     = editForm.elements["QueryLimit"];
	   queryLimit = trim(queryLimit.value);	   
	   if(!isInteger(queryLimit)){ 
		   //XSSOK
		   alert("<%=strPleaseEnterValidNumber%>");
     return false;	
	     }
	   else if(queryLimit == 0){ 
		   //XSSOK
		   alert("<%=strLimitZero%>");
        return false;	
	     }
	   else if(queryLimit > <%=strQueryLimit%>){		   
		   //XSSOK
		   alert("<%=strLimitReached%>");
     return false;		   
		   }
	   else if(queryLimit.length == 0)
		   {
		   //XSSOK
		   alert("<%=strLimitBlank%>");
     return false;		   
		   }
	   return true;       
	}

	 function isInteger(str)
	 {
	 	var num = "0123456789";
	 	for(var i=0;i<str.length;i++)
	 	{
	 		if(num.indexOf(str.charAt(i))==-1){ 		  
	 		  return false;
	 		}
	 	}
	 	return true;
	 }
	function trim(str){
	       while(str.length != 0 && str.substring(0,1) == ' ')
	       {
	         str = str.substring(1);
	       }
	       while(str.length != 0 && str.substring(str.length -1) == ' ')
	       {
	         str = str.substring(0, str.length -1);
	       }
	       while (str.length != 0 && str.match(/^\s/) != null) {
	       	str = str.replace(/^\s/, '');
	       }
	       return str;
	 }

//-->
</SCRIPT>
