<%-- 
 ** history:
 *  @fullreview  fl3 gh4 2016/09/19: Creation (3DEXP R2017x)
 *  @quickreview gh4 gh4 2017/06/15: FUN070920: Not much changes, just code realignment
 *  @quickreview jmm1 gh4 2017/07/04: IR-533290: PPV_FUN070920_VNLS issues with PPV app
 *  @quickreview spl7 gh4 2017/07/26: IR-533599 : Fixed issue of XSS encoding feature
--%>

<%--  CPVFormValidation.jsp
   (c) Dassault Systemes, 1993-2017.  All rights reserved.
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.UIForm"%>
<%@ page import = "com.dassault_systemes.vplm.DELJConstants"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%@ page import = "com.matrixone.apps.domain.util.PersonUtil"%>

<script language="Javascript">

<%
String sLanguage             = request.getHeader("Accept-Language");
String sPPRObjectType        = emxGetParameter(request,"PPRObjectType");

// Resource file to be used
String ResFileId      = "emxVPLMProcessEditorStringResource";

//TO BE CHANGED USING THE PREPOERTUES FILE
Locale strLocale = new Locale((String)request.getHeader("Accept-Language"));

String sNoOfDaysCheck          = EnoviaResourceBundle.getProperty(context, ResFileId, strLocale, "emxVPLMProcessEditor.Alert.NoOfDaysCheck");
String sFromDateFeildCheck     = EnoviaResourceBundle.getProperty(context, ResFileId, strLocale, "emxVPLMProcessEditor.Alert.FromDateFeildCheck");
String sToDateFeildCheck       = EnoviaResourceBundle.getProperty(context, ResFileId, strLocale, "emxVPLMProcessEditor.Alert.ToDateFeildCheck");
String sNoOfDaysLabel          = EnoviaResourceBundle.getProperty(context, ResFileId, strLocale, "emxVPLMProcessEditor.Label.NoOfDays");
String sFromDate               = EnoviaResourceBundle.getProperty(context, ResFileId, strLocale, "emxVPLMProcessEditor.Label.FromDate");
String MUST_ENTER_VALID_VALUE  = EnoviaResourceBundle.getProperty(context, ResFileId, strLocale, "emxVPLMProcessEditor.Alert.EmptyField");

String sQueryLimitLabel        = EnoviaResourceBundle.getProperty(context, ResFileId, strLocale, "emxVPLMProcessEditor.FeildLabel.QueryLimit");
String sQueryLimitFieldCheck1  = EnoviaResourceBundle.getProperty(context, ResFileId, strLocale, "emxVPLMProcessEditor.Label.QueryLimit");
String sQueryLimitFieldCheck2  = EnoviaResourceBundle.getProperty(context, ResFileId, strLocale, "emxVPLMProcessEditor.Alert.QueryLimitFieldCheck");
%>

function doLoad()
{

}

function isNullOREmpty(value)
{
	if (value == null || value == "" || value == "undefined" || value == "null")
		return true;
	else
		return false;
}

//////////////////////////////////////////////////     BOMCompare Functions - Start      //////////////////////////////////////////////////

function preProcessInBOMCompare() 
{
	var BOMCompareForm = document.editDataForm;
	
	BOMCompareForm.BOM1Revision.readOnly = true;
	BOMCompareForm.BOM2Revision.readOnly = true;
	
	BOMCompareForm.BOM1NameDisplay.value = BOMCompareForm.BOM1PreloadNameDisplay.value;
	BOMCompareForm.BOM1Name.value    = BOMCompareForm.BOM1PreloadNameActual.value;
	BOMCompareForm.BOM1NameOID.value = BOMCompareForm.BOM1PreloadNameOID.value;
	
	BOMCompareForm.BOM2NameDisplay.value = BOMCompareForm.BOM2PreloadNameDisplay.value;
	BOMCompareForm.BOM2Name.value    = BOMCompareForm.BOM2PreloadNameActual.value;
	BOMCompareForm.BOM2NameOID.value = BOMCompareForm.BOM2PreloadNameOID.value;

	BOMCompareForm.getElementsByClassName("swapObjects")[0].disabled=true;
}

function onChangeBOM1Name()
{
	var BOMCompareForm = document.editDataForm;
	
	if (isNullOREmpty(BOMCompareForm.BOM1NameDisplay.value))
		BOMCompareForm.BOM1Revision.value = "";
}

function onChangeBOM2Name()
{
	var BOMCompareForm = document.editDataForm;
	
	if (isNullOREmpty(BOMCompareForm.BOM2NameDisplay.value))
		BOMCompareForm.BOM2Revision.value = "";
}

function selectAllOptionsInBomCompReportDiffBy(elemId) 
{
	var BOMCompareForm = document.editDataForm;
	
	if (BOMCompareForm.selectAll.checked) 
	{
		for (var i = 0; i < BOMCompareForm.elements.length; i++) {
			if (BOMCompareForm.elements[i].id.indexOf(elemId) > -1)
				BOMCompareForm.elements[i].checked = true;
		}
	} 
	else 
	{
		var defaultElemName = elemId + "_default";

		for (var i = 0; i < BOMCompareForm.elements.length; i++)  
		{
			if (BOMCompareForm.elements[i].id.indexOf(elemId) > -1) {
				if (BOMCompareForm.elements[i].id == defaultElemName)
					BOMCompareForm.elements[i].checked = true;
				else
					BOMCompareForm.elements[i].checked = false;
		}
	}
	}

}

function setCfgFitlerValuesInBOMCompare(topWindow, sCfgFilterName, sDispValue, sActualValue, sOIDValue) 
{	
	// Set values of input control
	topWindow.opener.document.getElementsByName(sCfgFilterName)[0].value = sActualValue;  
	topWindow.opener.document.getElementsByName(sCfgFilterName + "Display")[0].value = sDispValue;  
	topWindow.opener.document.getElementsByName(sCfgFilterName + "OID")[0].value = sOIDValue;
}
	
//function for swap button 
function swapValuesOfPPRObjects()
{
	var BOMCompareForm = document.editDataForm;

	// Swap values of Name field
	swapValues(BOMCompareForm.BOM1NameDisplay, BOMCompareForm.BOM2NameDisplay);
	swapValues(BOMCompareForm.BOM1Name,     BOMCompareForm.BOM2Name);
	swapValues(BOMCompareForm.BOM1NameOID,  BOMCompareForm.BOM2NameOID);

	// Swap values of Revn field
	swapValues(BOMCompareForm.BOM1Revision, BOMCompareForm.BOM2Revision);
	
	// Swap values of PredefCfgFilter field
	swapValues(BOMCompareForm.BOM1PredefCfgFilterDisplay, BOMCompareForm.BOM2PredefCfgFilterDisplay);
	swapValues(BOMCompareForm.BOM1PredefCfgFilter,    BOMCompareForm.BOM2PredefCfgFilter);
	swapValues(BOMCompareForm.BOM1PredefCfgFilterOID, BOMCompareForm.BOM2PredefCfgFilterOID);
	}

function swapValues(BOM1Field, BOM2Field)
{
	var tempValue   = BOM1Field.value;
	BOM1Field.value = BOM2Field.value;
	BOM2Field.value = tempValue;
}

///////////////////////////////////////////////////    BOMCompare Functions - Ends     ////////////////////////////////////////////////////
	
//////////////////////////////////////////////////   CPVPreference Functions - Starts   ///////////////////////////////////////////////////
	
//variables to store value of date and noofdays when respective values are selected
var noofdaysTemp = "";
var fromDateTemp = "", toDateTemp = "" ;
var fromDateTemp_msValue = "", toDateTemp_msValue = "";
	
//enable and disable No Of days and from and to date field in pref form
function  enableDateFieldsAccordingToChoice(elemClassName)
{
	var lastModifiedElements = this.document.getElementsByName("LastModified");
	var checkedField = "";

	for (var i = 0; i < lastModifiedElements.length; i++) {
		if(lastModifiedElements[i].checked == true) {
			checkedField = lastModifiedElements[i].value;
			break;
		}
	}
	
	if ("<%=XSSUtil.encodeForJavaScript(context, DELJConstants.No_of_Days)%>" == checkedField) {
		//when user selects the value of fromdate and todate and then again selects noofdays.
		//fromdate and todate values are stored in these variables.
		fromDateTemp = this.document.getElementsByName("FromDate")[0].value;
		fromDateTemp_msValue = this.document.getElementsByName("FromDate_msvalue")[0].value;
		toDateTemp	= this.document.getElementsByName("ToDate")[0].value;
		toDateTemp_msValue = this.document.getElementsByName("ToDate_msvalue")[0].value;
		
		//enabling the noofdays field with pre-inserted value
		this.document.getElementById("NoOfDays").disabled=false;
		this.document.getElementsByName("NoOfDays")[0].value = noofdaysTemp;
		
		//disabling the date fields
		this.document.getElementsByName("ToDate_date")[0].href="#";
		this.document.getElementsByName("FromDate_date")[0].href="#";
		
		this.document.getElementsByName("FromDate")[0].value = "";
		this.document.getElementsByName("ToDate")[0].value = "";
		this.document.getElementsByName("ToDate_msvalue")[0].value = "";
		this.document.getElementsByName("FromDate_msvalue")[0].value = "";
	}
	else if ("<%=XSSUtil.encodeForJavaScript(context, DELJConstants.Range_Of_Dates)%>" == checkedField) {
		//when user selects the value RangeOfDates noofdays value is stored in it
		noofdaysTemp = this.document.getElementsByName("NoOfDays")[0].value;
		
		//disabling the noofdays field 
		this.document.getElementById("NoOfDays").disabled=true;
		this.document.getElementsByName("NoOfDays")[0].value = "";
		
		//enabling the the date fields with pre-inserted value
		this.document.getElementsByName("FromDate")[0].value = fromDateTemp;
		this.document.getElementsByName("FromDate_msvalue")[0].value = fromDateTemp_msValue;
		this.document.getElementsByName("ToDate")[0].value = toDateTemp;
		this.document.getElementsByName("ToDate_msvalue")[0].value = toDateTemp_msValue;
		setValueOfToDateField();
		var date = new Date();
	    var currTime = date.getTime();
		this.document.getElementsByName("FromDate_date")[0].href="javascript:showCalendar('editDataForm', 'FromDate', '', saveFieldObjByName('FromDate'),'','','','{\"mode\":\"edit\",\"componentType\":\"form\",\"calBeanTimeStamp\":\""+currTime+"\",\"CalendarFunction\":null,\"InputType\":\"textbox\",\"CalendarProgram\":null,\"format\":\"date\",\"columnName\":\"FromDate\"}');"
		this.document.getElementsByName("ToDate_date")[0].href="javascript:showCalendar('editDataForm', 'ToDate', '', saveFieldObjByName('ToDate'),'','','','{\"mode\":\"edit\",\"componentType\":\"form\",\"calBeanTimeStamp\":\""+currTime+"\",\"CalendarFunction\":null,\"InputType\":\"textbox\",\"CalendarProgram\":null,\"format\":\"date\",\"columnName\":\"ToDate\"}');"
	}
}


//////////////////////////////////////////////  Validation Methods - Starts  ////////////////////////////////////////////////////

function validateLastModifiedFieldForPreferenceForm()
{
	var lastModifiedElements = this.document.getElementsByName("LastModified");
	var checkedField = "";
	var StartHref  = "";
	var ToDateHref = "";
	
	// Determine if NoOfDays or RangeOfDates is checked
	for (var i = 0; i < lastModifiedElements.length; i++) {
		if (lastModifiedElements[i].checked == true) {
			checkedField = lastModifiedElements[i].value;
			break;
		}
	}
	
	if ("<%=XSSUtil.encodeForJavaScript(context, DELJConstants.No_of_Days)%>" == checkedField) 
	{
		var days = this.document.getElementById("NoOfDays").value;
	    if (isNullOREmpty(days))
		{
	    	 alert ("<%=XSSUtil.encodeForJavaScript(context, MUST_ENTER_VALID_VALUE +" "+sNoOfDaysLabel)%>"); //alert :if no of days is checked from last modified and noofdays field is empty.
	    	 return false;
	    }
	
		if ( days === "-0" || isNaN(days) || days < 0 || days > 999 )
		{
	    	alert ("<%=XSSUtil.encodeForJavaScript(context, sNoOfDaysCheck)%>"); //alert :if noofdays field is less than 0 and greater than 999 or not a nmbr.
			return false;
		}
	} 
	else if ("<%=XSSUtil.encodeForJavaScript(context, DELJConstants.Range_Of_Dates)%>" == checkedField) 
	{
		var date = new Date();
	    var currTime = date.getTime();
		var ToDateMsValue = this.document.getElementsByName("ToDate_msvalue")[0].value;
		var FromDateMsValue = this.document.getElementsByName("FromDate_msvalue")[0].value;
		if (isNullOREmpty(FromDateMsValue))
		{
			alert ("<%=XSSUtil.encodeForJavaScript(context, MUST_ENTER_VALID_VALUE +" "+sFromDate)%>"); //alert :if Between RangeOfDates is checked from last modified and From date field is empty.
	    	return false;
		}
		else if (ToDateMsValue < FromDateMsValue || FromDateMsValue > currTime)
		{
			alert ("<%=XSSUtil.encodeForJavaScript(context, sFromDateFeildCheck)%>"); //alert :if FromDate is less than ToDate or FRom date is greater than current Time
			return false;
		}
		else if (ToDateMsValue > currTime)
	{	
			alert ("<%=XSSUtil.encodeForJavaScript(context, sToDateFeildCheck)%>"); //alert :if ToDate is greater than current Time
	        return false;
		}
	}
	
	return true;
}

function validationForPreferenceForm()
{
	// Validate last modified Fields
	var checkDatesValues =validateLastModifiedFieldForPreferenceForm();
	if (!checkDatesValues)
		return false;
	
	// Validate Query Limit Field
	if (this.name === "<%=XSSUtil.encodeForJavaScript(context, sQueryLimitLabel)%>")
   	{
	 	if (isNullOREmpty(this.value))
	    {
	    	 alert ("<%=XSSUtil.encodeForJavaScript(context, MUST_ENTER_VALID_VALUE +" "+sQueryLimitFieldCheck1)%>"); //alert :if query Limit field is empty.
	        return false;
	    }
	 	else if ( this.value === "-0" || isNaN(this.value)  || this.value <= 0)
        {
           	alert("<%=XSSUtil.encodeForJavaScript(context, sQueryLimitFieldCheck2)%>");
            return false;
        }
	}
    
	return true; 
}

//////////////////////////////////////////////  Validation Methods - Ends  ////////////////////////////////////////////////////

function onSelectPreferredType()
{
	var perfForm = document.editDataForm;
	var prefType = "";
	<%
	if(DELJConstants.PPR_OBJECT_PROCESS.equals(sPPRObjectType))
	{
		%>
		prefType = perfForm.ManufType.value;
		<%
	}
	else if(DELJConstants.PPR_OBJECT_SYSTEM.equals(sPPRObjectType))
	{
		%>
		prefType = perfForm.SystemType.value;
		<%
	}
	else if(DELJConstants.PPR_OBJECT_OPERATION.equals(sPPRObjectType))
	{
		%>
		prefType = perfForm.OperationType.value;
		<%
	}
	%>
	
	jQuery.ajax({
        url: "../planningreview/CPVTypesDisplay.jsp?values="+prefType+"&languageStr="+"<%=XSSUtil.encodeForJavaScript(context, sLanguage)%>",
        type: 'GET',
        dataType: 'json',
		error: function(error, status) 
			{
				if(error.status == 401){
					getTopWindow().location.href = "../common/emxNavigatorErrorPage.jsp?errorCode=401";
				}
			}
	}).done(function(data1){
		var preferredTypes = data1.displayTypes.split(",");
		var preferredListName = "";
		for(var count = 0; count<preferredTypes.length; count++)
		{
			preferredListName = preferredListName+"<li>"+preferredTypes[count]+"</li>";
		}  
		//putting the actualTypes and displayTypes AS Hidden field so that we can get the value in request map while saving
		var originalTypes = "<input id=\"OriginalTypes\" type=\"hidden\" name=\"OriginalTypes\" value=\""+prefType+"\">";
		var displayTypes = "<input id=\"DisplayTypes\" type=\"hidden\" name=\"DisplayTypes\" value=\""+data1.displayTypes+"\">"
		document.getElementsByName("PreferredTypes_html")[0].innerHTML = preferredListName + originalTypes + displayTypes;
	}); 
}

//To dispaly the current time and date in Pref form To Feild
function  setValueOfToDateField()
{
	var preferenceForm = document.editDataForm;
	
    var date        = new Date();
    var currTime    = date.getTime();
	
   	<%
	HashMap agrsMapDisplayDate = new HashMap();	
	HashMap paramMapLangStr = new HashMap();
	paramMapLangStr.put("languageStr", (String)request.getHeader("Accept-Language"));			
	agrsMapDisplayDate.put("paramMap", paramMapLangStr);
	
	String sToDateValue = (String) JPO.invoke(context, "DELJMyDeskUtil", null, "displayToDate", JPO.packArgs(agrsMapDisplayDate), String.class);
	%>
   	
   	preferenceForm.elements['ToDate'].value         = "<%=XSSUtil.encodeForJavaScript(context, sToDateValue)%>";
  	preferenceForm.elements['ToDate_msvalue'].value = currTime; 
}

//Function to set default last modified feild values
function setLastModifiedFieldValuesFromUserPreferences() 
{
	<%
	HashMap argsMap = new HashMap();
	argsMap.put("type", sPPRObjectType);
	
	String sOwnerActualValue = context.getUser();
	String sOwnerDisplayValue = PersonUtil.getFullName(context, sOwnerActualValue);

	Map mapUserPref = (Map) JPO.invoke(context, "DELJMyDeskUtil", null, "getUserPrefFromDBForUI", JPO.packArgs(argsMap), Map.class);
	
	if (!(mapUserPref.isEmpty()) && (mapUserPref != null)) 
	{
		String sDays = (String)mapUserPref.get("noofdays");	
		if (!(UIUtil.isNullOrEmpty(sDays))) 
		{
			%>
			this.document.getElementsByName("ToDate_date")[0].href="#";
			this.document.getElementsByName("FromDate_date")[0].href="#";
			this.document.getElementsByName("FromDate")[0].value = "";
			this.document.getElementsByName("ToDate")[0].value = "";
			<%
		} 
		else 
		{
			%>
			this.document.getElementById("NoOfDays").disabled=true;
			this.document.getElementsByName("NoOfDays")[0].value = "";	
			setValueOfToDateField();
			<%
		}
		sOwnerActualValue = (String)mapUserPref.get("owner");
		sOwnerDisplayValue = PersonUtil.getFullName(context, sOwnerActualValue);
	}
	%>
	this.document.getElementsByName("OwnerDisplay")[0].value = "<%=XSSUtil.encodeForJavaScript(context, sOwnerDisplayValue)%>";
} 

function reloadPnOCollaborativeSpaceField()
{
	emxFormReloadField("CollaborativeSpace");
}

function reloadFormFields()
{
	 var url = document.location.href;
	 document.location.href =url;
}
//////////////////////////////////////////////////   CPVPreference Functions - Ends   /////////////////////////////////////////////////////

</script>
