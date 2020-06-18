
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxJSValidation.inc"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<%
out.clear();
response.setContentType("text/javascript; charset=" + response.getCharacterEncoding());
String accLanguage  = request.getHeader("Accept-Language");
%>

function showPersonSelector()
{
    var objCommonAutonomySearch = new emxCommonAutonomySearch();

	objCommonAutonomySearch.txtType = "type_Person";
	objCommonAutonomySearch.selection = "single";
	objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchOwner";
	objCommonAutonomySearch.open();
}

function submitAutonomySearchOwner(arrSelectedObjects)
{
    var objForm = document.forms[0];
    var hiddenElement = objForm.elements["Owner"];
    var displayElement = objForm.elements["OwnerDisplay"];

    for (var i = 0; i < arrSelectedObjects.length; i++)
    {
        var objSelection = arrSelectedObjects[i];
        hiddenElement.value = objSelection.name;
        displayElement.value = objSelection.name;
        break;
    }
}

// flag keeps track of whether user has modified Marketing Name field.
var mflag;
// This function will put the same value in Marketing Name textbox as that of Name.

function updateMarketName()
{
    var txtDisplayName = document.getElementById("Market Name").value;
    var strFieldValue =document.forms[0].Name.value;
    //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(strFieldValue, ARR_NAME_BAD_CHARS, false);
    
    if(strInvalidChars.length > 0)
    {
         var strAlert = "<emxUtil:i18nScript localize='i18nId'>DMCPlanning.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
         alert(strAlert);
         document.forms[0].Name.value ='';
         return false;
    }
    if (((txtDisplayName=="")&&(!document.forms[0].autoNameCheck.checked))||(mflag!="true"))
    {
        document.getElementById("Market Name").value=strFieldValue;
    }
    return true;
    
    
}

//This function sets the flag value and calls for updating Marketing Name field.
function setMarketNameFlag()
{    
    mflag="true";
    var txtDisplayame = document.getElementById("Market Name").value;
   if (txtDisplayName == "")
   {
       mflag="false";
   }else if (txtDisplayName != "")
   {
   //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(txtDisplayName, ARR_NAME_BAD_CHARS, false);
    if(strInvalidChars.length > 0)
    {
        var strAlert = "<emxUtil:i18nScript localize='i18nId'>DMCPlanning.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
        alert(strAlert);
        document.getElementById("Market Name").value ='';
        return false;
    }
   } 
    else {
       return true; 
     }
   updateMarketName();
   return true;
}

function updatePolicy()
{
    emxFormReloadField("LogicalFeaturesPolicy");
}

// This function will put the validation on Description 
function checkDescriptionForBadChars()
{   
    var strFieldValue =document.forms[0].Description.value;
    //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(strFieldValue, ARR_BAD_CHARS, false);
    
    if(strInvalidChars.length > 0)
    {
         var strAlert = "<emxUtil:i18nScript localize='i18nId'>DMCPlanning.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
         alert(strAlert);
         document.forms[0].Description.value ='';
         return false;
    }else
    {
        return true;
    }      
    
}

// flag keeps track of whether user has modified Marketing Name field.
var sflag;

function updateDisplayName()
{
    var txtDisplayName = document.getElementById("Title").value;
    var strFieldValue =document.forms[0].Name.value;
    //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(strFieldValue, ARR_NAME_BAD_CHARS, false);
    
    if(strInvalidChars.length > 0)
    {
         var strAlert = "<emxUtil:i18nScript localize='i18nId'>DMCPlanning.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
         alert(strAlert);
         document.forms[0].Name.value ='';
         return false;
    }
    if (((txtDisplayName.length==0))||(sflag!=undefined && sflag!="true"))
    {
        document.getElementById("Title").value=strFieldValue;
    }
    return true;
}

function confirmInsertBefore(){
    var strConfirm = "<emxUtil:i18nScript localize='i18nId'>DMCPlanning.InsertBefore.Confirmation</emxUtil:i18nScript>";
    var choice = confirm(strConfirm)
    if(choice){
       return true;
    }else{
       return false;
    }
}

function setDisplayNameFlag()
{    
    sflag="true";
    var txtDisplayName = document.getElementById("Title").value;
    if (txtDisplayName =="")
    {
        sflag="false";
    }
    else if (txtDisplayName != "")
    {
        //Check for Bad Name Chars
        var strInvalidChars = checkStringForChars(txtDisplayName, ARR_NAME_BAD_CHARS, false);
        if(strInvalidChars.length > 0)
        {
            var strAlert = "<emxUtil:i18nScript localize='i18nId'>DMCPlanning.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
            alert(strAlert);
            document.getElementById("Title").value ='';
            return false;
        }
    } 
    else 
    {
        return true; 
    }
    updateDisplayName();
    return true;
}

function populatefieldOnLoad() {
    var derivedFromTxtField = document.getElementById("DerivedFromDisplay");
    var nameTxtField = document.getElementById("Name");
    if (derivedFromTxtField && derivedFromTxtField.value != "") {
    	nameTxtField.value = derivedFromTxtField.value;
    }
}

function updateDerivedType()
{
    var isLastNodeInDerivationChain = document.getElementById("DerivedFromDType").value;
    var nameTxtField = document.getElementById("Name").value;
    var txtDisplayName = document.getElementById("Title").value;
    
    // Get Derivation Level Info
    var strTypeActual = document.getElementsByName("TypeActual")[0].value;
    var derivedFromID = document.getElementById("DerivedFromOID").value;
    var derivationType = document.getElementById("DerivationType").value;
    
    var url = "../dmcplanning/ManufacturingPlanUtil.jsp?mode=getFormDerivationLevelField&strType="+strTypeActual+"&objectID="+derivedFromID+"&derivationType="+derivationType;
    var vRes = emxUICore.getData(url);
    var iIndex = vRes.indexOf("htmlString=");
    var iLastIndex = vRes.indexOf("#");
    var htmlString = vRes.substring(iIndex+"htmlString=".length , iLastIndex );
    
    // Set Derivation Level according to Type
	var DerivationLevelHTML = document.getElementById("DerivationLevel_html");
    DerivationLevelHTML.innerHTML = htmlString;
    
    // Set Name and Title
    var strDerivedFromName = document.getElementById("DerivedFromName").value;
    var strDerivedFromDName = document.getElementById("DerivedFromDName").value;

    if (((txtDisplayName.length==0))||(sflag!=undefined && sflag!="true")) {
        document.getElementById("Title").value=strDerivedFromDName;
    }    

    if (((nameTxtField.length==0) && !(document.forms[0].autoNameCheck.checked))) {
        document.getElementById("Name").value=strDerivedFromName;
    }

    // Set Type and Policy    
    var varDerivedFromType = document.getElementById("DerivedFromType").value;
    var varDerivedFromPolicy = document.getElementById("DerivedFromPolicy").value;
    
    var typeSplit = varDerivedFromType.split("|");
    var typeActualName = typeSplit[0];
    var typeDName = typeSplit[1];

    var policySplit = varDerivedFromPolicy.split("|");
    var policyActualName = policySplit[0];
    var policyDName = policySplit[1];
        
    if(emxFormIsFieldEditable("TypeActual"))
    {
        emxFormSetFieldEditable("TypeActual", false);
    }
    emxFormSetValue("TypeActual", typeActualName,typeDName);
    
    if(emxFormIsFieldEditable("Policy"))
    {
        emxFormSetFieldEditable("Policy", false);
    }
    emxFormSetValue("Policy", policyActualName,policyDName);

    // Set Modality
    var isRetrofitMP = document.getElementById("DerivedFromIntent").value;
    var ModalityId = document.getElementById("ModalityId");

    if(isRetrofitMP=="true") {
        setVals(ModalityId,"Retrofit");
    } else {
        setVals(ModalityId,"Regular");
    }
    return true;
}

function setVals(selectbox,value) {
	for (i=0; i<selectbox.options.length; i++) {
		if (selectbox.options[i].value == value) {
			selectbox.selectedIndex = i;
		}
	}
}

function showDerivedFromSelectorDerivation(strTypes)
{
    var plannedForID = document.getElementById("ContextOID").value;
    var sURL="../common/emxFullSearch.jsp?&includeOIDprogram=ManufacturingPlanSearch:getManufacturingPlansForDerivationCreate&contextObjectId="+plannedForID+"&field=TYPES="+strTypes+"&table=CFPSearchMPTable&sortColumnName=Revision&sortDirection=ascending&Registered Suite=DMCPlanning&selection=single&hideHeader=true&submitURL=../dmcplanning/ManufacturingPlanCreateInsertSearchUtil.jsp?mode=Chooser&chooserType=FormChooser&fieldNameActual=DerivedFromOID&fieldNameDisplay=DerivedFromDisplay&fieldNameDType=DerivedFromDType&fieldNameDName=DerivedFromDName&fieldNameName=DerivedFromName&appendRevision=true&HelpMarker=emxhelpfullsearch&fieldNameIntent=DerivedFromIntent&fieldNameType=DerivedFromType&fieldNamePolicy=DerivedFromPolicy&StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&suiteKey=DMCPlanning";
    showChooser(sURL, 850, 630);
}

function showDerivedFromSelectorRevision(strTypes)
{
	var plannedForID = document.getElementById("ContextOID").value;
	var sURL="../common/emxFullSearch.jsp?&includeOIDprogram=ManufacturingPlanSearch:getManufacturingPlansForRevisionCreate&contextObjectId="+plannedForID+"&field=TYPES="+strTypes+"&table=CFPSearchMPTable&sortColumnName=Revision&sortDirection=ascending&Registered Suite=DMCPlanning&selection=single&hideHeader=true&submitURL=../dmcplanning/ManufacturingPlanCreateInsertSearchUtil.jsp?mode=Chooser&chooserType=FormChooser&fieldNameActual=DerivedFromOID&fieldNameDisplay=DerivedFromDisplay&fieldNameDType=DerivedFromDType&fieldNameDName=DerivedFromDName&fieldNameName=DerivedFromName&appendRevision=true&HelpMarker=emxhelpfullsearch&fieldNameIntent=DerivedFromIntent&fieldNameType=DerivedFromType&fieldNamePolicy=DerivedFromPolicy&StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&suiteKey=DMCPlanning";
	showChooser(sURL, 850, 630);
}

function showPlannedFromSelector(strTypes,strIncludeProgram,plannedForID)
{
	var derivedFromID = document.getElementById("DerivedFromOID").value;
	var sURL="../common/emxFullSearch.jsp?&includeOIDprogram=ManufacturingPlanSearch:"+strIncludeProgram+"&contextObjectId="+plannedForID+"&derivedFromID="+derivedFromID+"&field=TYPES="+strTypes+"&table=CFPSearchProductTable&sortColumnName=Revision&sortDirection=ascending&Registered Suite=DMCPlanning&selection=single&hideHeader=true&submitURL=../dmcplanning/ManufacturingPlanCreateInsertSearchUtil.jsp?mode=Chooser&chooserType=FormChooser&fieldNameActual=ContextOID&fieldNameDisplay=ContextDisplay&appendRevision=true&HelpMarker=emxhelpfullsearch";
	showChooser(sURL, 850, 630);
}

function checkRevisionForBadChars() {
    var strFieldValue =document.forms[0].Revision.value;
    //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(strFieldValue, ARR_NAME_BAD_CHARS, false);
    
    if(strInvalidChars.length > 0)
    {
         var strAlert = "<emxUtil:i18nScript localize='i18nId'>DMCPlanning.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
         alert(strAlert);
         document.forms[0].Revision.value ='';
         return false;
    }   

}

