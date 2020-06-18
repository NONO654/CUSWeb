<%--  emxEngrValidation.jsp   - page to include the custom webform validation functions.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@ page import   = "com.matrixone.apps.framework.ui.UIForm"%>
<%@ page import   = "java.util.HashMap"%>


<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>
<!-- <script language="javascript" type="text/javascript" src="../emxUIPageUtility.js"></script> -->

<%
//tjx
String sProductValidation1 =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Form.ValidateProductField1");
String sProductValidation2 =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Form.ValidateProductField2");

String sPRNoToYes =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.PR.NoToYes");


String msgRawMaterialErrorMsg =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Form.ValidateDesignCollabForRawMaterial");

matrix.util.StringList slMfgPolicy = EngineeringUtil.getManuPartPolicy(context);
String strMfgPolicy = slMfgPolicy.toString();
//tjx
String strLanguage    = request.getHeader("Accept-Language");
String strMBOMResFileId = "emxMBOMStringResource";

String contextUser = context.getUser();
String objOwner = "";
String _objectID = emxGetParameter(request, "objectId");
String objectId2 = emxGetParameter(request, "objectId2");
String strPolicy ="";
String strState="";

String strType = "";
String strPolicy2="";
String prevPlanningRequired = "";
String planningRequired = "";
String isMRAttached = "";
//Added for Planning MBOM-Planning Required-Start
String strCurrRev= ""; 
boolean isMBOMInstalled = EngineeringUtil.isMBOMInstalled(context);
String planningRequiredDefOption = "";
if(isMBOMInstalled)
{ 		
	planningRequiredDefOption = EnoviaResourceBundle.getProperty(context, "emxMBOM.PlanningMBOM.Planning_Required.DefaultValue");
}
//Added for Planning MBOM-Planning Required-End
if(_objectID != null) {

            DomainObject dom = new DomainObject(_objectID);
            StringList sl = new StringList(8);
            sl.add(DomainConstants.SELECT_TYPE);
            sl.add(DomainConstants.SELECT_OWNER);
            sl.add(DomainConstants.SELECT_POLICY);
            sl.add(DomainConstants.SELECT_CURRENT);
            sl.add(DomainConstants.SELECT_REVISION);
	     if(isMBOMInstalled) {
            sl.add("previous."+EngineeringConstants.SELECT_PLANNING_REQUIRED);
            sl.add(EngineeringConstants.SELECT_PLANNING_REQUIRED);
            sl.add("last."+EngineeringConstants.SELECT_END_ITEM);
            sl.add("to["+EngineeringConstants.RELATIONSHIP_MANUFACTURING_RESPONSIBILITY+"]");
            }           
            Map map = dom.getInfo(context, sl);
            objOwner = (String) map.get(DomainConstants.SELECT_OWNER);
            strType = (String) map.get(DomainConstants.SELECT_TYPE);
            strPolicy = (String) map.get(DomainConstants.SELECT_POLICY);
            strState = (String)map.get(DomainConstants.SELECT_CURRENT);
            strCurrRev = (String)map.get(DomainConstants.SELECT_REVISION);
            if(isMBOMInstalled) {
	    prevPlanningRequired = (String)map.get("previous."+EngineeringConstants.SELECT_PLANNING_REQUIRED);
	    planningRequired = (String)map.get(EngineeringConstants.SELECT_PLANNING_REQUIRED);
	    isMRAttached = (String)map.get("to["+EngineeringConstants.RELATIONSHIP_MANUFACTURING_RESPONSIBILITY+"]");
		  }           
}
if(UIUtil.isNotNullAndNotEmpty(objectId2)) {
	 DomainObject dom = new DomainObject(objectId2);
	 strPolicy2 = dom.getInfo(context, DomainConstants.SELECT_POLICY);
}
boolean canModifyRDO = contextUser.equals(objOwner);
String msgSelectCO = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.SelectCO", context.getSession().getLanguage());
String msgSelectRDO = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.SelectRDO", context.getSession().getLanguage()); //Added for RDO Convergence
String msgSelectECO = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.SelectECO", context.getSession().getLanguage());
/* if (EngineeringUtil.isENGSMBInstalled(context)) {
    msgSelectECO = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.SelectTeamECO",context.getSession().getLanguage());
} */ //Commented for IR-213006
//Added for Planning MBOM-Planning Required-Start

String planningRequiredYesOption = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource",  new Locale("en"), "emxFramework.Range.Planning_Required.Yes");
String planningRequiredNoOption = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale("en"), "emxFramework.Range.Planning_Required.No");
String planningRequiredAlert = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.PLBOM.PLReqAlert");
String endItemYesOption = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale("en"), "emxFramework.Range.End_Item.Yes" );
String endItemNoOption = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", new Locale("en"), "emxFramework.Range.End_Item.No");
//Added for Planning MBOM-Planning Required-End
//Added for common component--
String strPleaseEnterValidNumber     = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Alert.checkPositiveNumberForQueryLimit");
String strLimitReached = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Alert.checkQueryLimitCanNotBeMoreThan");
String strLimitBlank = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Alert.checkQueryLimitCanNotBeLeftBlank");
String strZeroQueryLimit = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Alert.checkQueryLimitCanNotBeZero");
String strQueryLimit = "32000";
String BAD_CHAR_SET = EnoviaResourceBundle.getProperty(context, "emxNavigator.UIMenuBar.FullSearchBadCharList");

%>

              
<script language="Javascript">
var STR_DEC_SYM = "<%=FrameworkProperties.getProperty(context, "emxFramework.DecimalSymbol")%>";
var prModified = false;
String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
}
function isNumericGeneric(fieldObj)
{
	var decSymb 	= STR_DEC_SYM;
	var varValue = fieldObj;
	var isDot 		= varValue.indexOf(".") != -1;
  	var isComma 	= varValue.indexOf(",") != -1;
  	var result		= false;
  	if(decSymb == "," && isComma && !isDot){
  			result= !isNaN( varValue.replace(/,/, '.') );
	} 
  	if(decSymb == "." && isDot && !isComma){
  			result= !isNaN( varValue );
	} 
  	if (decSymb == "." && !isComma && !isDot){
  			result= !isNaN( varValue );
  	}
  	if (decSymb == "," && !isComma && !isDot){
  			result= !isNaN( varValue );
  	}
  	return result;	
}

function clearRelatedFields()
{
      basicClear('ResponsibleDesignEngineer');
      basicClear('ResponsibleManufacturingEngineer');
      basicClear('RDEngineer');         
}

function clearRDO()
{
      basicClear('RDO');
      basicClear('ChangeResponsibility');
      basicClear('ResponsibleDesignEngineer');
      basicClear('ResponsibleDesignEngineerDisplay');      
      basicClear('ResponsibleManufacturingEngineer');
      basicClear('RDEngineer');       
}

//following is javascript , if there is null entry in some of the fields while editing ECO, ECR . It will reset the field to Unassigned instead of blank
function isAssignValue() {

   if(this.value == "" )
    {
        this.value="Unassigned";
        return this.value;
    }
    else
    {
        return this.value;
    }
}

function validateSelector() {
<%
    String emxSelectorBadChars = JSPUtil.getCentralProperty(application, session,"emxComponents","VCFileFolder.SelectorBadChars");
%>  

    if(this.value == "" )
    {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.SelectorEmpty</emxUtil:i18nScript>");
       return false;        
    }
    //XSSOK
    var STR_SELECTOR_BAD_CHARS = "<%= emxSelectorBadChars.trim() %>";
    var ARR_SELECTOR_BAD_CHARS = "";
    if (STR_SELECTOR_BAD_CHARS != "") 
    {
      ARR_SELECTOR_BAD_CHARS = STR_SELECTOR_BAD_CHARS.split(" ");   
    }
    var strSelectorResult = checkStringForChars(this.value,ARR_SELECTOR_BAD_CHARS,false);
    if (strSelectorResult.length > 0) {
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertInValidChars</emxUtil:i18nScript>\n"
            + STR_SELECTOR_BAD_CHARS + "\n<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>\n"
            + "\n<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.Selector</emxUtil:i18nScript>");
     return false;
    }
    return true;
}

///////////////////////// Added for Structure Compare Dialog Validation START /////////////////////////

// Script to control the section options available based on format selection and Match Based On Selection

function verifyCheckboxOptions(ctrlStr) { 
    // Assigning format field variables
   
    var vSelected           = document.editDataForm.Format.selectedIndex;
    var vSelectedValue      = document.editDataForm.Format.options[vSelected].value;
    // Assigning Match Based On field variables
    var vMBOSelected        = document.editDataForm.MatchBasedOn.selectedIndex;
    var vMBOSelectedValue   = document.editDataForm.MatchBasedOn.options[vMBOSelected].value;

	// Added by PL for PUE Reports - This is the first validation which needs to happen

	var BOM1CofigPart = document.editDataForm.BOM1CofigPart.value;
	var BOM2CofigPart = document.editDataForm.BOM2CofigPart.value;

	if ((BOM1CofigPart == 'true' || BOM2CofigPart == 'true') && vSelectedValue == "Tabular")
	{
		alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ECCBOMCompare.FormatCannotBeTabularIfEitherPartConfigured</emxUtil:i18nScript>");
		document.editDataForm.Format.value = document.editDataForm.Format.options[0].value;
		return false;
	}

	 //IR-040863V6R2011 -Starts
    if (vSelectedValue == "Visual") {
    	if(document.editDataForm.DOS.checked == true && document.editDataForm.CS.checked == true){
    		alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BOMCompare.CanNotSelectBoth</emxUtil:i18nScript>");
    		return false;
    	}
    }
    //IR-040863V6R2011 -Ends


	//if (vMBOSelected == 0 && ctrlStr == "MatchBasedOn") {
	if (vMBOSelectedValue == "Part_Name" && ctrlStr == "MatchBasedOn") {
		document.editDataForm.Format.options.selectedIndex = 1;
		vSelectedValue = document.editDataForm.Format.options[1].value;
		//Added for 360279-Starts
		document.editDataForm.Format.disabled = true;
		document.editDataForm.DOS.checked  =false;
        document.editDataForm.CS.checked   =false;
	}else{
		document.editDataForm.Format.disabled = false;
	}
		//Added for 360279 -Ends
		
     // Performing check and Enabling/Disabling options
    if (vSelectedValue == "Visual") {
	document.editDataForm.isConsolidatedReport[0].disabled=false;
	document.editDataForm.isConsolidatedReport[1].disabled=false;
        document.editDataForm.O2UC.disabled =true;
        document.editDataForm.CC.disabled   =true;
        document.editDataForm.O1UC.disabled =true;
        //Added for 360279-Starts
        document.editDataForm.O2UC.checked =false;
        document.editDataForm.CC.checked =false;
        document.editDataForm.O1UC.checked =false;
        //Added for 360279-Ends
    } else {
	document.editDataForm.isConsolidatedReport[0].disabled=true;
	document.editDataForm.isConsolidatedReport[1].disabled=true;
        document.editDataForm.O2UC.disabled =false;
        document.editDataForm.CC.disabled   =false;
        document.editDataForm.O1UC.disabled =false;
    }
    
    //if (vMBOSelected == 0) {
      if(vMBOSelectedValue == "Part_Name") {   
        document.editDataForm.DOS.disabled  =true;
        document.editDataForm.CS.disabled   =true;
    } else {
        document.editDataForm.DOS.disabled  =false;
        document.editDataForm.CS.disabled   =false;
    }
    //modified for 374620
    if (document.editDataForm.CC.checked == false && document.editDataForm.CS.checked == false && document.editDataForm.O2UC.checked == false && document.editDataForm.O1UC.checked == false && document.editDataForm.DOS.checked == false)
     {
		 alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BOMCompare.ReportSectionEmpty</emxUtil:i18nScript>");
		 return false;
     }

    return true;
}

///////////////////////// Added for Structure Compare Dialog Validation END /////////////////////////

function validateProductLine() {

    if(this.value == "" )
    {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ECR.SelectProductLine</emxUtil:i18nScript>");
        return false;        
    }
    else
    {
        return true;
    }
}
/////////////////////////////////////////////////////MBOM Structure Compare Validations starts////////////////////////////////////////////////////
//////////////////Script for Type1 Field//////////////////
<% if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)) { %>
function checkTarDate()
{
	
	<%--Multitenant--%>
	<%--var dateMessage = "<%=i18nNow.getI18nString("emxMBOM.TargetDate.Validate",strMBOMResFileId,strLanguage)%>";
    var dateMessage1 = "<%=i18nNow.getI18nString("emxMBOM.TargetDate.CheckTargetStartDate",strMBOMResFileId,strLanguage)%>";
    var valMessage = "<%=i18nNow.getI18nString("emxMBOM.TargetDatePriority.Priority3",strMBOMResFileId,strLanguage)%>";--%>
    //XSSOK
    var dateMessage = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.TargetDate.Validate")%>";
   //XSSOK
    var dateMessage1 = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.TargetDate.CheckTargetStartDate")%>";
    //XSSOK
    var valMessage = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.TargetDatePriority.Priority3")%>";
    var date = document.forms[0].elements['Target Start Date'].value;
    var sPriority = document.forms[0].elements['Target Start Date Priority'].value;
    var targetdt = new Date();
    targetdt = Date.parse(date);
    var curntdate = new Date();
    curntdate = Date.parse(curntdate);
    if((sPriority!=valMessage) && (date == ""))
    {
        alert(dateMessage1);
        return false;
    }else if((date != "") && (targetdt <=curntdate))
    {
        alert(dateMessage);
        return false;
    }else{
        return true;
    }
    return true;
}

// JavaScript validation method for end item override enabled in part edit page.
function checkEndItemOverride()
{
	
	<%--Multitenant--%>
	<%--var msg = "<%=i18nNow.getI18nString("emxMBOM.ECPartEdit.EndItemOverride.ValidMsg",strMBOMResFileId,strLanguage)%>";--%>
	//XSSOK
	var msg = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.ECPartEdit.EndItemOverride.ValidMsg")%>";
    var enditem = document.forms[0].elements["EndItem"].value;
    var eio= document.forms[0].elements["EndItemOverrideEnabled"].value;
    if(enditem == "Yes")
    {
        if(eio== "Yes")
        {
            alert(msg);
            return false;
        }
    }
    return true;
}

<%--Multitenant--%>
<%--var EBOM = "<%=i18nNow.getI18nString("emxMBOM.ComparisionReport.EBOM",strMBOMResFileId,strLanguage)%>";
  var MBOM = "<%=i18nNow.getI18nString("emxMBOM.ComparisionReport.MBOM",strMBOMResFileId,strLanguage)%>";

  var AsStored = "<%=i18nNow.getI18nString("emxMBOM.RevisionOptions.AsStored",strMBOMResFileId,strLanguage)%>";
  var Latest = "<%=i18nNow.getI18nString("emxMBOM.RevisionOptions.Latest",strMBOMResFileId,strLanguage)%>";

  var AsStoredEN = "<%=i18nNow.getI18nString("emxMBOM.RevisionOptions.AsStored",strMBOMResFileId,"en")%>";
  var LatestEN = "<%=i18nNow.getI18nString("emxMBOM.RevisionOptions.Latest",strMBOMResFileId,"en")%>";

  var Current = "<%=i18nNow.getI18nString("emxMBOM.RevisionOptions.Current",strMBOMResFileId,strLanguage)%>";
  var Pending = "<%=i18nNow.getI18nString("emxMBOM.RevisionOptions.Pending",strMBOMResFileId,strLanguage)%>";
  var History = "<%=i18nNow.getI18nString("emxMBOM.MBOMCustomFilter.History",strMBOMResFileId,strLanguage)%>";
  
  var CurrentVal = "<%=i18nNow.getI18nString("emxMBOM.RevisionOptions.Current",strMBOMResFileId,"en")%>";
  var PendingVal = "<%=i18nNow.getI18nString("emxMBOM.RevisionOptions.Pending",strMBOMResFileId,"en")%>";
  var HistoryVal = "<%=i18nNow.getI18nString("emxMBOM.MBOMCustomFilter.History",strMBOMResFileId,"en")%>";
--%>
//XSSOK
var EBOM = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.ComparisionReport.EBOM")%>";
//XSSOK
var MBOM = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.ComparisionReport.MBOM")%>";
//XSSOK
var AsStored = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.RevisionOptions.AsStored")%>";
//XSSOK
var Latest = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.RevisionOptions.Latest")%>";
//XSSOK
var AsStoredEN = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, new Locale("en"),"emxMBOM.RevisionOptions.AsStored")%>";
//XSSOK
var LatestEN = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, new Locale("en"),"emxMBOM.RevisionOptions.Latest")%>";
//XSSOK
var Current = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.RevisionOptions.Current")%>";
//XSSOK
var Pending = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.RevisionOptions.Pending")%>";
//XSSOK
var History = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.MBOMCustomFilter.History")%>";
//XSSOK
var CurrentVal = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, new Locale("en"),"emxMBOM.RevisionOptions.Current")%>";
//XSSOk
var PendingVal = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, new Locale("en"),"emxMBOM.RevisionOptions.Pending")%>";
//XSSOK
var HistoryVal = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, new Locale("en"),"emxMBOM.MBOMCustomFilter.History")%>";
function disableType1Fields() 
{

var selIndex = document.editDataForm.Type1.selectedIndex;
var selValue = document.editDataForm.Type1[selIndex];

if(selValue.value==EBOM || selValue.text==EBOM) 
     {
                    document.editDataForm.Deviation1[0].disabled=true;
                    document.editDataForm.Deviation1[1].disabled=true;
                    document.editDataForm.Plant1Display.style.visibility="hidden";
                   
                   document.editDataForm.btnPlant1.style.visibility="hidden";
                    document.getElementById("As1").style.visibility="hidden";
                    document.editDataForm.AsOn1.style.visibility="hidden";
                   if (document.editDataForm.Make_Buy.value=="true" || document.editDataForm.S_Type.value=="true" || document.editDataForm.Substitute_For.value=="true")
                    {
                       document.editDataForm.Make_Buy.disabled=true;
                       document.editDataForm.S_Type.disabled=true;
                       document.editDataForm.Substitute_For.disabled=true;
                   }
                    var revision = document.editDataForm.RevisionOption1;
                    var a=0;
					var length = revision.length;
					while(a<length)
					{
						
						revision.removeChild(revision.options[a]);
						length--;
					}
					
                  document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length] = new Option( AsStored , AsStoredEN );
                  //XSSOK
                  if("<%=strPolicy%>"== "" || "<%=strPolicy%>" !=  "<%=PropertyUtil.getSchemaProperty(context, "policy_ConfiguredPart")%>"){
                  document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length] = new Option( Latest, LatestEN);}
                  if(document.editDataForm.RevisionOption1.length > 4)
                  {
    	          document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length - 5]=null;
		          document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length - 4]=null;
                  document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length - 3]=null;
                  }
     } 
    else if(selValue.value==MBOM || selValue.text==MBOM) 
    {
                    document.editDataForm.Deviation1[0].disabled=false;
                    document.editDataForm.Deviation1[1].disabled=false;
                    document.editDataForm.Plant1Display.disabled=false;
                   
                   document.editDataForm.btnPlant1.style.visibility="visible";
                    document.getElementById("As1").style.visibility="visible";
                    document.editDataForm.AsOn1.style.visibility="visible";
                    document.editDataForm.Plant1Display.style.visibility="visible";
                    var selIndex = document.editDataForm.Type2.selectedIndex;
                     
                    if(document.editDataForm.Type2[selIndex].value==MBOM || document.editDataForm.Type2[selIndex].text==MBOM)
                    { 
                       if (document.editDataForm.Make_Buy.value=="true" || document.editDataForm.S_Type.value=="true" || document.editDataForm.Substitute_For.value=="true")
                         {
                              document.editDataForm.Make_Buy.disabled=false;
                              document.editDataForm.S_Type.disabled=false;
                              document.editDataForm.Substitute_For.disabled=false;
                         }
                   }
                   
                   document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length - 2]=null;
                   document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length - 1]=null;
                   document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length] = new Option(Pending, PendingVal);
                   document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length] = new Option(Current,CurrentVal);
                   document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length] = new Option(History,HistoryVal);
                    

                   if(document.editDataForm.RevisionOption1.value == Current)
                   {
                    document.getElementById("As1").style.visibility ="hidden";
                    document.editDataForm.AsOn1.style.visibility ="hidden";
                }
        }
   }

//////////////////Script for Type2 Field//////////////////
function disableType2Fields()
{
         var selIndex = document.editDataForm.Type2.selectedIndex;
         var selValue = document.editDataForm.Type2[selIndex];
         if(selValue.value==EBOM || selValue.text==EBOM) 
         {
              document.editDataForm.Deviation2[0].disabled=true;
              document.editDataForm.Deviation2[1].disabled=true;
              document.editDataForm.Plant2Display.style.visibility="hidden";
            
             document.editDataForm.btnPlant2.style.visibility="hidden";
              document.getElementById("As2").style.visibility="hidden";
              document.editDataForm.AsOn2.style.visibility="hidden";
               if (document.editDataForm.Make_Buy.value=="true" || document.editDataForm.S_Type.value=="true" || document.editDataForm.Substitute_For.value=="true")
               {
                     document.editDataForm.Make_Buy.disabled=true;
                     document.editDataForm.S_Type.disabled=true;
                     document.editDataForm.Substitute_For.disabled = true;
                }
              var revision1 = document.editDataForm.RevisionOption2;
              var b=0;
			  var length1 = revision1.length;
			  while(b<length1)
			  {
					revision1.removeChild(revision1.options[b]);
					length1--;
			  }
              document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length] = new Option(AsStored, AsStoredEN);
              //XSSOK
              if("<%=strPolicy2%>"== "" || "<%=strPolicy2%>" !=  "<%=PropertyUtil.getSchemaProperty(context, "policy_ConfiguredPart")%>"){
              document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length] = new Option(Latest, LatestEN);}
              if(document.editDataForm.RevisionOption2.length > 4)//IR-071016V6R2012 -added if condition
              {
              document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length - 5]=null;
              document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length - 4]=null;
              document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length - 3]=null;
              }
       } 
       else if(selValue.value==MBOM || selValue.text==MBOM) 
       {
   
                document.editDataForm.Deviation2[0].disabled=false;
                document.editDataForm.Deviation2[1].disabled=false;
                document.editDataForm.Plant2Display.style.visibility="visible";
               
               document.editDataForm.btnPlant2.style.visibility="visible";
                document.getElementById("As2").style.visibility="visible";
                document.editDataForm.AsOn2.style.visibility="visible";
                var selIndex = document.editDataForm.Type1.selectedIndex;
                
                if(document.editDataForm.Type1[selIndex].value==MBOM || document.editDataForm.Type1[selIndex].text==MBOM)
                   {
                     if (document.editDataForm.Make_Buy.value=="true" || document.editDataForm.S_Type.value=="true" || document.editDataForm.Substitute_For.value=="true")
                        {
                        
                           document.editDataForm.Make_Buy.disabled=false;
                           document.editDataForm.S_Type.disabled=false;
                           document.editDataForm.Substitute_For.disabled = false;
                        }
                  }
                document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length - 2]=null;
                document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length - 1]=null;
                document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length] = new Option(Pending, PendingVal);
                document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length] = new Option(Current, CurrentVal);
                document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length] = new Option(History, HistoryVal);

               if(document.editDataForm.RevisionOption2.value == Current)
                {
                    document.getElementById("As2").style.visibility ="hidden";
                    document.editDataForm.AsOn2.style.visibility ="hidden";
                }
        }
}
function RevisionOption1Fields()
{
    if(document.editDataForm.RevisionOption1.value == PendingVal || document.editDataForm.RevisionOption1.value == HistoryVal)
    {
        document.getElementById("As1").style.visibility="Visible";
        document.editDataForm.AsOn1.style.visibility="Visible";
    }
    else
    {
        document.getElementById("As1").style.visibility="hidden";
        document.editDataForm.AsOn1.style.visibility="hidden";
    }
}
function RevisionOption2Fields()
{
    if(document.editDataForm.RevisionOption2.value == PendingVal || document.editDataForm.RevisionOption2.value == HistoryVal)
    {
        document.getElementById("As2").style.visibility="Visible";
        document.editDataForm.AsOn2.style.visibility="Visible";
    }
    else
    {
        document.getElementById("As2").style.visibility="hidden";
        document.editDataForm.AsOn2.style.visibility="hidden";
    }
}
//////////////////When WebForm is Loaded//////////////////
function doLoad()
{
<%
        String sform = emxGetParameter(request,"form");
       String sENCEBOMCompareWebform = PropertyUtil.getSchemaProperty(context,"form_ENCEBOMCompareWebform");

        if(sENCEBOMCompareWebform.equals(sform))
    {
%>
         document.editDataForm.Deviation1[0].disabled=true;
         document.editDataForm.Deviation1[1].disabled=true;

          
          document.editDataForm.btnPlant1.style.visibility="hidden";
         document.getElementById("As1").style.visibility="hidden";

         document.editDataForm.AsOn1.style.visibility="hidden";
         document.editDataForm.Plant1Display.style.visibility="hidden";
         document.editDataForm.Plant2Display.style.visibility="hidden";

		//Below condition added during x+8 PUE Report release
                if (document.editDataForm.RevisionOption1.length > 1)
		{
		document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length - 1]=null;
		document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length - 2]=null;
		document.editDataForm.RevisionOption1.options[document.editDataForm.RevisionOption1.length - 1]=null;
		}


         document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length - 1]=null;
		document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length - 2]=null;
         document.editDataForm.RevisionOption2.options[document.editDataForm.RevisionOption2.length - 1]=null;
		//Modified for BUG: 360271
		//Desc: MakeBuy, SType and SubstituteFor have been replaced by Make_Buy, S_Type and Substitute_For respectively.
         document.editDataForm.Make_Buy.disabled=true;
         document.editDataForm.S_Type.disabled=true;
         document.editDataForm.Substitute_For.disabled=true;

         document.editDataForm.Deviation2[0].disabled=true;
         document.editDataForm.Deviation2[1].disabled=true;

          
          document.editDataForm.btnPlant2.style.visibility="hidden";
         document.getElementById("As2").style.visibility="hidden";

         document.editDataForm.AsOn2.style.visibility="hidden";
<%
}
%>
}

/////////////////////Plant Field (for Plant1) fieldis mandatory when MBOM is selected
function isPlant1() 
{
	
	<%--Multitenant--%>
	<%--var Plant1Msg = "<%=i18nNow.getI18nString("emxMBOM.CompareBOM.PlantName1Msg",strMBOMResFileId,strLanguage)%>";--%>
	//XSSOK
	var Plant1Msg = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.CompareBOM.PlantName1Msg")%>";

     var selIndex = document.editDataForm.Type1.selectedIndex;
     var selValue = document.editDataForm.Type1[selIndex];
     var val = document.editDataForm.Plant1Display.value
     if(selValue.value== MBOM || selValue.text==MBOM)
     {
         
         if(val == "" )
         {
           alert(Plant1Msg);
           document.editDataForm.Plant1Display.focus();
        }
       else
       {
           return val;
       }
    }
    else
     {
          return true;
     }
}
/////////////////////AsOn(for AsOn1 field) is mandatory when MBOM is selected
function isAsOn1() 
{
     
	 <%--Multitenant--%>
	 <%-- var AsOn1Msg = "<%=i18nNow.getI18nString("emxMBOM.CompareBOM.AsOn1Msg ",strMBOMResFileId,strLanguage)%>";
     var HistoryMsg = "<%=i18nNow.getI18nString("emxMBOM.History.msg ",strMBOMResFileId,strLanguage)%>";
     var PendingMsg = "<%=i18nNow.getI18nString("emxMBOM.Pending.msg ",strMBOMResFileId,strLanguage)%>"; --%>
     //XSSOK
     var AsOn1Msg = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.CompareBOM.AsOn1Msg")%>";
    //XSSOK
     var HistoryMsg = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.History.msg")%>";
     //XSSOK
     var PendingMsg = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.Pending.msg")%>";


     var selIndex = document.editDataForm.Type1.selectedIndex;
     var selValue = document.editDataForm.Type1[selIndex];
     if((selValue.value== MBOM || selValue.text== MBOM) && (document.editDataForm.RevisionOption1.value == PendingVal || document.editDataForm.RevisionOption1.text == PendingVal || document.editDataForm.RevisionOption1.value == HistoryVal || document.editDataForm.RevisionOption1.text == HistoryVal))
     {
         if(this.value == "" )
         {
           alert(AsOn1Msg);
	   return false;
        }
    }
     if((selValue.value== MBOM || selValue.text== MBOM) && (document.editDataForm.RevisionOption1.value == HistoryVal || document.editDataForm.RevisionOption1.text == HistoryVal))
	{
		var AsOn1Date = document.editDataForm.AsOn1_msvalue.value;
		var AsOn1   = new Date();
		AsOn1.setTime(AsOn1Date);
		var currentDate = new Date();
		
		if(parseInt(AsOn1.getTime()) >= parseInt(currentDate.getTime()))
		{
		alert(HistoryMsg);
		return false;
		}
		else
			return true;
	}
	if((selValue.value== MBOM || selValue.text== MBOM) && (document.editDataForm.RevisionOption1.value == PendingVal || document.editDataForm.RevisionOption1.text == PendingVal))
	{
		var AsOn1Date = document.editDataForm.AsOn1_msvalue.value;
		var AsOn1   = new Date();
		AsOn1.setTime(AsOn1Date);
		var currentDate = new Date();		
		
		if(parseInt(AsOn1.getTime()) <= parseInt(currentDate.getTime()))
		{
			alert(PendingMsg);
			return false;
	        }
                else
                       return true;
     }
		return true;
}
/////////////////////Plant Field (for Plant2) fieldis mandatory when MBOM is selected
function isPlant2()
{
	
	<%--Multitenant--%>
	<%--var Plant2Msg = "<%=i18nNow.getI18nString("emxMBOM.CompareBOM.PlantName2Msg",strMBOMResFileId,strLanguage)%>";--%>
	//XSSOK
	var Plant2Msg = "<%=EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.CompareBOM.PlantName2Msg")%>";

     var selIndex = document.editDataForm.Type2.selectedIndex;
     var selValue = document.editDataForm.Type2[selIndex];
     var val = document.editDataForm.Plant2Display.value
     if(selValue.value== MBOM || selValue.text== MBOM)
     {
         if(val == "" )
         {
           alert(Plant2Msg);
           document.editDataForm.Plant2Display.focus();
        }
       else
       {
           return val;
       }
    }
    else
     {
             return true;
     }
}

/////////////////////AsOn (for AsOn2 field) fieldis mandatory when MBOM is selected
function isAsOn2() 
{
    
	<%--Multitenant--%>
	<%-- var AsOn2Msg = "<%=i18nNow.getI18nString("emxMBOM.CompareBOM.AsOn2Msg ",strMBOMResFileId,strLanguage)%>";
     var HistoryMsg = "<%=i18nNow.getI18nString("emxMBOM.History.msg ",strMBOMResFileId,strLanguage)%>";
     var PendingMsg = "<%=i18nNow.getI18nString("emxMBOM.Pending.msg ",strMBOMResFileId,strLanguage)%>"; --%>
     //XSSOK
     var AsOn2Msg = "<%= EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.CompareBOM.AsOn2Msg")%>";
     //XSSOK
     var HistoryMsg = "<%= EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.History.msg")%>";
     //XSSOK
     var PendingMsg = "<%= EnoviaResourceBundle.getProperty(context, strMBOMResFileId, context.getLocale(),"emxMBOM.Pending.msg")%>";

     var selIndex = document.editDataForm.Type2.selectedIndex;
     var selValue = document.editDataForm.Type2[selIndex];
     if((selValue.value== MBOM || selValue.text== MBOM)&& (document.editDataForm.RevisionOption2.value == PendingVal || document.editDataForm.RevisionOption2.text == PendingVal || document.editDataForm.RevisionOption1.value == HistoryVal || document.editDataForm.RevisionOption1.text == HistoryVal))
     {
         if(this.value == "" )
         {
           alert(AsOn2Msg);
	   return false;
        }
    }
     if((selValue.value== MBOM || selValue.text== MBOM) && (document.editDataForm.RevisionOption2.value == HistoryVal || document.editDataForm.RevisionOption2.text == HistoryVal))
	{
		var AsOn2Date = document.editDataForm.AsOn2_msvalue.value;
		var AsOn2   = new Date();
		AsOn2.setTime(AsOn2Date);
		var currentDate = new Date();
		
		if(parseInt(AsOn2.getTime()) >= parseInt(currentDate.getTime()))
		{
		alert(HistoryMsg);
		return false;
		}
		else
			return true;
	}
	if((selValue.value== MBOM || selValue.text== MBOM) && (document.editDataForm.RevisionOption2.value == PendingVal || document.editDataForm.RevisionOption2.text == PendingVal))
	{
		var AsOn2Date = document.editDataForm.AsOn2_msvalue.value;
		var AsOn2   = new Date();
		AsOn2.setTime(AsOn2Date);
		var currentDate = new Date();
		if(parseInt(AsOn2.getTime()) < parseInt(currentDate.getTime()))
		{
			alert(PendingMsg);
			return false;
	    }
        else
             return true;
    }
		return true;
}

/******************************************************************************/
/* function checkEffectivityDates()       																	  */
/* Validates the Effectivity Dates For ECR/DCR.        											  */
/* X3                                       																	*/
/******************************************************************************/
//Validating for Date Values
function checkEffectivityDates() {

	var strStartDate = document.forms[0].StartDate_msvalue.value;
	var strEndDate   = document.forms[0].EndDate_msvalue.value;
	
  var msg = "";
  //start 375997 
  var dateValue="false";
<%
String objId = emxGetParameter(request, "objectId");
String startDateValue = "";
if(objId!=null){
DomainObject domobjId=new DomainObject(objId);
startDateValue=domobjId.getInfo(context,"attribute["+(String)PropertyUtil.getSchemaProperty(context,"attribute_StartDate")+"]");
if(!startDateValue.equals(""))
{
Date dt=new Date(startDateValue);
}
}
%>
  var startDate   = new Date(parseInt(strStartDate));
  //XSSOK
  if("<%=startDateValue%>"!=""){
	  //XSSOK
  var sStartDate=new Date("<%=startDateValue%>");
  if(startDate.getDate()==sStartDate.getDate() && startDate.getMonth()==sStartDate.getMonth()){
    dateValue="true";
  }
  }
  
 //end of 375997 
   var endDate     = new Date(parseInt(strEndDate));
  var currentDate = new Date();
   
	var sf = 0;
	var ef = 0;
	var iStatus = -1 ;
	
	if ((trimWhitespace(strStartDate) != '')) {
		sf = 1;
	}
	if ((trimWhitespace(strEndDate) != '')) {
		ef = 1;
	}
	
	
	<%--Multitenant--%>
	<%-- var INVALID_DATES               = "<%=i18nNow.getI18nString("emxMBOM.Deviation.Error.InvalidDates","emxMBOMStringResource",strLanguage)%>";
	var INVALID_DCR_START_DATE_1    = "<%=i18nNow.getI18nString("emxMBOM.Deviation.Error.DCRStartDate1","emxMBOMStringResource",strLanguage)%>";
	var INVALID_DCR_END_DATE_1      = "<%=i18nNow.getI18nString("emxMBOM.Deviation.Error.DCREndDate1","emxMBOMStringResource",strLanguage)%>";
	var INVALID_DCR_DATES_1         = "<%=i18nNow.getI18nString("emxMBOM.Deviation.Error.DCRDates1","emxMBOMStringResource",strLanguage)%>";
	var INVALID_DCR_DATES_2         = "<%=i18nNow.getI18nString("emxMBOM.Deviation.Error.DCRDates2","emxMBOMStringResource",strLanguage)%>";
	var INVALID_DCR_START_DATE_2    = "<%=i18nNow.getI18nString("emxMBOM.Deviation.Error.DCRStartDate2","emxMBOMStringResource",strLanguage)%>";
	var INVALID_DCR_END_DATE_2      = "<%=i18nNow.getI18nString("emxMBOM.Deviation.Error.DCREndDate2","emxMBOMStringResource",strLanguage)%>";
	var INVALID_DCR_DATES_3         = "<%=i18nNow.getI18nString("emxMBOM.Deviation.Error.DCRDates3","emxMBOMStringResource",strLanguage)%>"; --%>
	//XSSOK
	var INVALID_DATES               = "<%=EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Deviation.Error.InvalidDates")%>";
	//XSSOK
	var INVALID_DCR_START_DATE_1    = "<%=EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Deviation.Error.DCRStartDate1")%>";
	//XSSOK
	var INVALID_DCR_END_DATE_1      = "<%=EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Deviation.Error.DCREndDate1")%>";
	//XSSOK
	var INVALID_DCR_DATES_1         = "<%=EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Deviation.Error.DCRDates1")%>";
	//XSSOK
	var INVALID_DCR_DATES_2         = "<%=EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Deviation.Error.DCRDates2")%>";
	//XSSOK
	var INVALID_DCR_START_DATE_2    = "<%=EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Deviation.Error.DCRStartDate2")%>";
	//XSSOK
	var INVALID_DCR_END_DATE_2      = "<%=EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Deviation.Error.DCREndDate2")%>";
	//XSSOK
	var INVALID_DCR_DATES_3         = "<%=EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Deviation.Error.DCRDates3")%>";
	
	if(sf == 1 && ef == 0) {
		if(startDate <= currentDate) {
			msg = INVALID_DATES+"\n"+INVALID_DCR_START_DATE_1+"\n"+INVALID_DCR_START_DATE_2;
			iStatus = 0;
		}
	}
	else if(sf == 0 && ef == 1) {
		if(endDate <= currentDate) {
			msg = INVALID_DATES+"\n"+INVALID_DCR_START_DATE_2+"\n"+INVALID_DCR_END_DATE_1+"\n"+INVALID_DCR_END_DATE_2;
			iStatus = 0;
		}
		else if(endDate > currentDate) {
			msg = INVALID_DATES+"\n"+INVALID_DCR_START_DATE_2;
			iStatus = 0;
		}
	}
	else if(sf == 1 && ef == 1) {
	
		if(startDate <= currentDate && dateValue=="false")
			iStatus = 1;
		else if(startDate > currentDate)
			iStatus = 10;
		if(endDate <= currentDate)
			iStatus = 2;
		if(startDate <= currentDate && iStatus == 2)
			iStatus = 3;
		if(iStatus == 10 && endDate > startDate)
			iStatus = 100;
		
		if(iStatus == 1 && startDate >= endDate)
			msg = INVALID_DATES+"\n"+INVALID_DCR_START_DATE_1+"\n"+INVALID_DCR_DATES_2+"\n"+INVALID_DCR_START_DATE_2;
		else if(iStatus == 1 && startDate <= endDate)
			msg = INVALID_DATES+"\n"+INVALID_DCR_START_DATE_1+"\n"+INVALID_DCR_START_DATE_2;
		else if(iStatus == 2 && startDate > endDate)
			msg = INVALID_DATES+"\n"+INVALID_DCR_END_DATE_1+"\n"+INVALID_DCR_DATES_2+"\n"+INVALID_DCR_END_DATE_2;
		else if(iStatus == 2 && startDate <= endDate)
			msg = INVALID_DATES+"\n"+INVALID_DCR_END_DATE_1+"\n"+INVALID_DCR_END_DATE_2;
		else if(iStatus == 3 && startDate > endDate)
			msg = INVALID_DATES+"\n"+INVALID_DCR_DATES_1+"\n"+INVALID_DCR_DATES_2+"\n"+INVALID_DCR_DATES_3;
		else if(iStatus == 3 && startDate <= endDate)
			msg = INVALID_DATES+"\n"+INVALID_DCR_DATES_1+"\n"+INVALID_DCR_DATES_3;
		else if(iStatus == 10 && startDate >= endDate)
			msg = INVALID_DATES+"\n"+INVALID_DCR_DATES_2+"\n"+INVALID_DCR_DATES_3;
	}
	if(iStatus >= 0 && iStatus != 100) {
		alert(msg);
		return false;
	}
	return true;
} // End Of checkEffectivityDates()
<%}%>
function validateName() {
<%
  emxSelectorBadChars = JSPUtil.getCentralProperty(application, session,"emxComponents","VCFileFolder.SelectorBadChars");
%>  

    if(this.value == "" )
    {
   alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.SelectorNameEmpty</emxUtil:i18nScript>");
       return false;        
    }
    //XSSOK
     STR_SELECTOR_BAD_CHARS = "<%= emxSelectorBadChars.trim() %>";
     ARR_SELECTOR_BAD_CHARS = "";
    if (STR_SELECTOR_BAD_CHARS != "") 
    {
      ARR_SELECTOR_BAD_CHARS = STR_SELECTOR_BAD_CHARS.split(" ");   
    }
     strSelectorResult = checkStringForChars(this.value,ARR_SELECTOR_BAD_CHARS,false);
    if (strSelectorResult.length > 0) {
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertInValidChars</emxUtil:i18nScript>\n"
            + STR_SELECTOR_BAD_CHARS + "\n<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>\n"
            + "\n<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.Selector</emxUtil:i18nScript>");
     return false;
    }
    return true;
}
 //Added for Full Search configuration 
strFormFieldName = "";
function showPersonSelector()
{
      strFormFieldName = "txtOwner";
      var objCommonAutonomySearch = new emxCommonAutonomySearch();
	  objCommonAutonomySearch.txtType = "type_Person";
      objCommonAutonomySearch.selection = "single";
      objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearch"; 
      objCommonAutonomySearch.open();

}
function submitAutonomySearch(arrSelectedObjects){
   
      var objForm = document.forms["editDataForm"];
	  var displayElement = objForm.elements[strFormFieldName + "Display"];
      var hiddenElement1 = objForm.elements[strFormFieldName];
      var hiddenElement2 = objForm.elements[strFormFieldName + "OID"];

      for (var i = 0; i < arrSelectedObjects.length; i++){ 
         var objSelection = arrSelectedObjects[i];
         displayElement.value = objSelection.name;
         hiddenElement1.value = objSelection.name;
         hiddenElement2.value = objSelection.objectId;
 		 break;
      }      

}
function showECOToRelease(){
     var rdoId = document.editDataForm.RDOOID.value;
	 strFormFieldName = "ECO";
	  var objCommonAutonomySearch = new emxCommonAutonomySearch();
      //364525 - Starts
      if (rdoId == "") {
      //364525 - Ends
	  objCommonAutonomySearch.txtType = "type_ECO:CURRENT=policy_ECO.state_Create,policy_ECO.state_DefineComponents,policy_ECO.state_DesignWork";
      //364525 - Starts
      } else {
          objCommonAutonomySearch.txtType =      "type_ECO:CURRENT=policy_ECO.state_Create,policy_ECO.state_DefineComponents,policy_ECO.state_DesignWork:REL_DESIGN_RESPONSIBILITY="+rdoId;
      }
      //364525 - Ends
      objCommonAutonomySearch.selection = "single";
      objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearch"; 
      objCommonAutonomySearch.open();

}
function showPartFamily(){
	  strFormFieldName = "partFamily";
	  var objCommonAutonomySearch = new emxCommonAutonomySearch();
	  objCommonAutonomySearch.txtType = "type_PartFamily";
      objCommonAutonomySearch.selection = "single";
      objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearch"; 
      objCommonAutonomySearch.open();
}
function showECR(){
	 strFormFieldName = "ECR";
	  var objCommonAutonomySearch = new emxCommonAutonomySearch();
	  objCommonAutonomySearch.txtType = "type_ECR";
      objCommonAutonomySearch.selection = "single";
      objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearch"; 
      objCommonAutonomySearch.open();

}
function showPersonSelectorForECR(){
	  strFormFieldName = "Owner";
      var objCommonAutonomySearch = new emxCommonAutonomySearch();
	  objCommonAutonomySearch.txtType = "type_Person";
      objCommonAutonomySearch.selection = "single";
      objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearch"; 
      objCommonAutonomySearch.open();
}
//364525 - Starts
function updateRDO() {
    var RDOFieldValue = document.editDataForm.RDOOID.value;
    var ECOFieldValue = document.editDataForm.ECO.value;
    if (RDOFieldValue == "" && ECOFieldValue != "") {
        emxFormReloadField("RDO");
    }
}
//364525 - Ends

// ADDED BY PL FOR PUE REPORTS

function BOMTypeValidate() {
  
     var selIndex1 = document.editDataForm.Type1.selectedIndex;
     var selValue1 = document.editDataForm.Type1[selIndex1];
	
     var selIndex2 = document.editDataForm.Type2.selectedIndex;
     var selValue2 = document.editDataForm.Type2[selIndex2];
     
     
     var sConfigPart1= document.editDataForm.BOM1CofigPart.value;
     var sConfigPart2= document.editDataForm.BOM2CofigPart.value;
	
	 if (sConfigPart1 == 'true' || sConfigPart2 == 'true') {	
		if(selValue1.value == "MBOM" || selValue2.value == "MBOM") {
	          alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ECCBOMCompare.BOMTypeCheck</emxUtil:i18nScript>");
	          return false;
		} else {
	          return true;
		}
	} 
   
	return true;
}

function openReportedAgainstSearch() { 
    //XSSOK
    showModalDialog("../common/emxFullSearch.jsp?field=TYPES=type_Part,type_Builds,type_CADDrawing,type_CADModel,type_DrawingPrint,type_PartSpecification,type_Products<%=EngineeringUtil.getAltOwnerFilterString(context)%>&table=APPECReportedAgainstSearchList&selection=single&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/SearchUtil.jsp&srcDestRelName=relationship_ReportedAgainstChange&formName=editDataForm&fieldNameActual=ReportedAgainst&fieldNameDisplay=ReportedAgainstDisplay&mode=Chooser&chooserType=FormChooser&isTo=true&hdnType=Part&HelpMarker=emxhelpfullsearch&suiteKey=EngineeringCentral",850,630); 
}

function disableRDOField(fieldName) {
	formElement=eval ("document.forms[0]['" + fieldName + "Display']");
	if (formElement){
	    //XSSOK   
	       formElement.disabled = <%=!canModifyRDO%>;
	}

	formElement=eval ("document.forms[0]['btn" + fieldName + "']");
	if (formElement){
	    //XSSOK   
	       formElement.disabled = <%=!canModifyRDO%>;
	}
	
}

function getClearAnchorTagElement(formElement) {
	if(formElement.nextSibling) {
		return (formElement.nextSibling.tagName == "A") ? formElement.nextSibling : getClearAnchorTagElement(formElement.nextSibling);
	}
}

//Start for Next Gen UI-this function will be loaded in Edit ECO page which enables RDE,RME fields if RDO field is not empty else disables.
function preProcessInEditPart() {
	var editForm = document.forms["editDataForm"];
	var uomValue;
	if(editForm.Uom != null){
		uomValue = editForm.Uom.value;
	}
	reloadUOMField(); //UOM Management: To reload the UOM field as per page object settings
	if(uomValue != null && uomValue != ""){
		editForm.Uom.value = uomValue;
	}
	 preProcessInEditMFGPart();
	if(editForm.RDOfieldValueOID != null) {
		editForm.RDOOID.value = editForm.RDOfieldValueOID.value;
	}
	disableRDOField('RDO');
	//Added for Planning MBOM-Planning Required-Start
	//Use the policy value retrieved from DomainObject.
	if(editForm.EndItem != undefined) {
		//XSSOK	
			if(editForm.EndItem.value == "<%=endItemYesOption%>")
			{
				setDisabledProductOption(false);
			}
			else
			{
				setDisabledProductOption(true);
			}
		}
	//XSSOK
	if((editForm.PlanningRequired !=  undefined) && ("<%=strPolicy%>"/* editForm.elements["PolicyDisplay"] */ != undefined) )
	{  
		//XSSOK
		var partPolicy = "<%=strPolicy%>" ;
		//XSSOK
		var currRevision = "<%=strCurrRev%>";
		//XSSOK
		var prevPlanningRequired = "<%=prevPlanningRequired%>";
		//XSSOK
		var isMRAttached = "<%=isMRAttached%>";
		//If the Part is not the first revision, then check for the previous revision's PR value.
		//XSSOK
		if(currRevision > 1 && prevPlanningRequired !=  "" && prevPlanningRequired== "<%= planningRequiredYesOption %>" )
		{	//if previous revision's Planning Required value is Yes, disable the "Planning Required" field in the edit page
			setDisabledPlanningRequiredOption(true);
		}
		else if(currRevision > 1 && isMRAttached !=  "" && isMRAttached == "True" )
		{   //if previous revision's OR current has MR attached disable Planning required K8I
			setDisabledPlanningRequiredOption(true);
		}
		//XSSOK
		else if(partPolicy=="<%=DomainConstants.POLICY_EC_PART%>" && editForm.EndItem != undefined && editForm.EndItem != "")
		{   
			//XSSOK
			setDisabledPlanningRequiredOption((editForm.EndItem.value == "<%=endItemNoOption%>")?true:false);
		}
		//XSSOK
		else if(partPolicy!="<%=DomainConstants.POLICY_EC_PART%>")
		{
			setDisabledPlanningRequiredOption(true); 
		}
		else
	    {   
			setDisabledPlanningRequiredOption(false);
	    }
		
		
		//if(partPolicy=="<%=DomainConstants.POLICY_EC_PART%>" && editForm.EndItem != undefined) {
			
		//Added for Planning MBOM-Planning Required-End
	}else{
		//XSSOK
		if(editForm.PlanningRequired == undefined && "<%=planningRequired%>" == "<%=planningRequiredYesOption%>"){
			if(editForm.EndItem != undefined){
				for(var i=0;i < editForm.EndItem.length; i++)
				{	
					//XSSOK
					if(editForm.EndItem.options[i].value == "<%=endItemNoOption%>")
					{
						editForm.EndItem.options[i].disabled = true;
						
					}
				}	
			}
		}
	}
	if($('input[name=WorkUnderfieldValue]').val() !=''){	
			$('#calc_WorkUnder table').find('td').attr('disabled','true');
			$('input[name=WorkUnderDisplay]').attr('readonly','true');	
			$('input[name=btnWorkUnder]').attr('disabled','true');
			$('#calc_WorkUnder a').removeAttr('href');
	}
}
//Added for Planning MBOM-Planning Required-Start
function onChangeEndItem()
{
	//var editForm = findFrame(getTopWindow(), "formEditDisplay").document.forms["editDataForm"];	
	var editForm = document.forms["editDataForm"];
	if(editForm.PlanningRequired !=  undefined){
		//XSSOK
		var prevPlanningRequired = "<%=prevPlanningRequired%>";
		//XSSOK
		var currRevision = "<%=strCurrRev%>";
		//XSSOK
		var prPropValue = "<%=planningRequiredDefOption%>";
		//Added for Planning MBOM-Planning Required-Start
		//XSSOK
		if(currRevision > 1 && prevPlanningRequired !=  "" && prevPlanningRequired== "<%= planningRequiredYesOption %>" )
		{
			//If previous revision's Planning Required value is Yes, disable the "Planning Required" field in the edit page.
			setDisabledPlanningRequiredOption(true);
		}
		//Added for Planning MBOM-Planning Required-Start
		//XSSOK
		else if(document.editDataForm.EndItem.value == "<%= planningRequiredYesOption %>")
		{	
			var policy = "<%=strPolicy%>";
			setDisabledProductOption(false);
			//XSSOK
			if(policy != undefined && policy=="<%=DomainConstants.POLICY_EC_PART%>")
			{
				setDisabledPlanningRequiredOption(false); 
				//XSSOK
				if(prPropValue == "<%=planningRequiredYesOption%>")
	       		{
					//XSSOK
					document.editDataForm.PlanningRequired.value = "<%=planningRequiredYesOption%>";
	       		}
	       		else
	       		{
	       			//XSSOK
	       			document.editDataForm.PlanningRequired.value = "<%=planningRequiredNoOption%>";
	       		}
			}
			//XSSOK
			else if(!(policy=="<%=DomainConstants.POLICY_EC_PART%>"))//A64+ If policy is not EC Part, set PR as No, and disable the PR field
			{
			 ///XSSOK
				document.editDataForm.PlanningRequired.value = "<%= planningRequiredNoOption %>";
				setDisabledPlanningRequiredOption(true);
			}
		}
		
		else
		{
			//XSSOK
			document.editDataForm.PlanningRequired.value = "<%= planningRequiredNoOption %>";
			setDisabledPlanningRequiredOption(true); 
			if(document.editDataForm.ProductEditDisplay !=  undefined){
				setDisabledProductOption(true);
				document.editDataForm.ProductEditDisplay.value = "";
			}

		}
	}else{
		//XSSOK
		if(document.editDataForm.EndItem.value == "<%= planningRequiredYesOption %>"){
			setDisabledProductOption(false);
		}else{
			setDisabledProductOption(true);	
		}
		
	}
}
//Added for Planning MBOM-Planning Required-Start
function setDisabledPlanningRequiredOption(optionEnableOrDisable){
  var elePL = document.editDataForm.PlanningRequired; 
   if(elePL!=undefined) {   
	var elePLValue=document.editDataForm.PlanningRequired.value;

   for(var i=0;i < elePL.length; i++)
   {
		if(optionEnableOrDisable) {
			if(elePL.options[i].value != elePLValue) {
				elePL.options[i].disabled = optionEnableOrDisable;
			}
		//XSSOK
		}  else   if(elePL.options[i].value == "<%= planningRequiredYesOption %>") {
           elePL.options[i].disabled = optionEnableOrDisable;
       }
   }
  }
}	
function preProcessInEditSpec() {
	disableRDOField('RDO');
}

function preProcessInEditECO(update){
	var editForm = document.forms["editDataForm"];
    var fieldRDO      = editForm.RDODisplay.value
    var displayField  = fieldRDO != "" ? false : true;
	if(!update) {
		if(editForm.RDOfieldValueOID != null)
			editForm.RDOOID.value = editForm.RDOfieldValueOID.value;
		disableRDOField('RDO');
	}
	
   	editForm.ResponsibleManufacturingEngineerDisplay.disabled=displayField;
   	editForm.btnResponsibleManufacturingEngineer.disabled=displayField;
   	editForm.ResponsibleDesignEngineerDisplay.disabled=displayField;
   	editForm.btnResponsibleDesignEngineer.disabled=displayField;
}

//this function was the onChange handler for RDO field in edit ECO page,which enables RDE,RME fields if RDO field is changed and not empty else disables.
function updateRDOForEditECO() {
	preProcessInEditECO(true);
	var editForm = document.forms["editDataForm"];
    if(editForm.ResponsibleDesignEngineer.value != "" 
    	&& editForm.ResponsibleDesignEngineer.value != "Unassigned") {
    	basicClear('ResponsibleDesignEngineer');
    }
	
	if(editForm.ResponsibleManufacturingEngineer.value != "" 
		&& editForm.ResponsibleManufacturingEngineer.value != "Unassigned") {
    	basicClear('ResponsibleManufacturingEngineer');
    }

}

function preProcessInEditECR(update){
	var editForm = document.forms["editDataForm"];
    var fieldChangeResponsibility      = editForm.ChangeResponsibilityDisplay.value
    var displayField  = fieldChangeResponsibility != "" ? false : true;
//XSSOK
    if("<%=strState%>"== "" || "<%=strState%>" !=  "<%=PropertyUtil.getSchemaProperty(context, "policy",DomainConstants.POLICY_ECR, "state_Create")%>"){

    	editForm.ChangeResponsibilityDisplay.disabled = true;
    	editForm.btnChangeResponsibility.disabled = true;
    }
    else if(!update) {
		if(editForm.ChangeResponsibilityfieldValueOID != null)
			editForm.ChangeResponsibilityOID.value = editForm.ChangeResponsibilityfieldValueOID.value;
   	
	   	disableRDOField('ChangeResponsibility');
	}
		
   	editForm.RDEngineerDisplay.disabled=displayField;
   	editForm.btnRDEngineer.disabled=displayField;
}

//this function was the onChange handler for RDO field in edit ECO page,which enables RDE,RME fields if RDO field is changed and not empty else disables.
function updateRDOForEditECR() {
	preProcessInEditECR(true);
	var editForm = document.forms["editDataForm"];
    if(editForm.RDEngineer.value != "" 
    	&& editForm.RDEngineer.value != "Unassigned") {
    	basicClear('RDEngineer');
    }

}
//This function opens CFF dialog page in for BOM2 effectivity field IR-071690
function showEffectivityExpressionDialog2() { 
	 var bom2PartObjId = document.getElementsByName("BOM2NameOID").item(0).value;
     showModalDialog("../effectivity/EffectivityDefinitionDialog.jsp?modetype=filter&invockedFrom=fromForm&formName=editDataForm&parentOID=&fieldNameEffExprDisplay=EffectivityExpression1&fieldNameEffExprActual=EffectivityExpressionActual1&fieldNameEffExprActualList=EffectivityExpressionOIDList1&fieldNameEffExprActualListAc=EffectivityExpressionOIDListAc1&fieldNameEffExprOID=EffectivityExpressionOID1&fieldNameEffTypes=effTypes&objectId="+bom2PartObjId);
 }
//End for Next Gen UI

function showPCFilterDialog1() { 
	var EFFECTIVITY_PC_SINGLE_SELECT = "<%=EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOMStringResource", context.getLocale(),
					"emxUnresolvedEBOM.Confirm.PCFilterSelectedMessage")%>";
	var effectivity1 = document.getElementsByName("EffectivityExpression");
	var effectivityValue =(effectivity1 != null && effectivity1 != undefined && effectivity1 != "") ? effectivity1.item(0).value : "";
	var sURL = "../common/emxFullSearch.jsp?mode=Chooser&field=TYPES=type_ProductConfiguration:CURRENT=policy_ProductConfiguration.state_Preliminary,policy_ProductConfiguration.state_Active&HelpMarker=emxhelpfullsearch&table=ENCEngineeringView&selection=single&hideHeader=true&form=ENCBOMCompareWebform&fieldNameActual=PCFilterId1&hiddenNameField=PUEUEBOMProductConfigurationFilter1OID&submitURL=../unresolvedebom/SearchUtil.jsp&chooserType=PCFilter";
	if(effectivityValue!= ""){
		if(confirm(EFFECTIVITY_PC_SINGLE_SELECT)){
			effectivity1.item(0).value="";
		}else{
			sURL = "";
		}
	}
	if(sURL !="")
		showModalDialog(sURL);
}

function showPCFilterDialog2() { 
	var EFFECTIVITY_PC_SINGLE_SELECT = "<%=EnoviaResourceBundle.getProperty(context ,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.Confirm.PCFilterSelectedMessage")%>";
	var effectivity2 = document.getElementsByName("EffectivityExpression1");
	var effectivityValue=(effectivity2 != null && effectivity2 != undefined && effectivity2 != "") ? effectivity2.item(0).value : "";
	var sURL = "../common/emxFullSearch.jsp?mode=Chooser&field=TYPES=type_ProductConfiguration:CURRENT=policy_ProductConfiguration.state_Preliminary,policy_ProductConfiguration.state_Active&HelpMarker=emxhelpfullsearch&table=ENCEngineeringView&selection=single&hideHeader=true&form=ENCBOMCompareWebform&fieldNameActual=PCFilterId2&hiddenNameField=PUEUEBOMProductConfigurationFilter2OID&submitURL=../unresolvedebom/SearchUtil.jsp&chooserType=PCFilter"
	if(effectivityValue!= ""){
		if(confirm(EFFECTIVITY_PC_SINGLE_SELECT)){
			effectivity2.item(0).value="";
		}else{
			sURL = "";
		}
	}
	if(sURL !="")
		showModalDialog(sURL);
 }
 
 function validateCancelECO() {     
     var editForm = document.forms["editDataForm"];
     var reason=editForm.Reason.value;
       
     if(reason!="") { 
            if (confirm("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.CancelECODialog.CancelECOConfirm</emxUtil:i18nScript>")){
                return true;        
                } else {
                return false;
    }
    } else {
         return true;
     }
     }
 function validatePlanningRequired() {
	 
	 if(prModified) {
		 //XSSOK
		 alert("<%=sPRNoToYes%>");
		 
     		return false;  	
	 }
 
	 var editForm = document.forms["editDataForm"];
	   	if(editForm.PlanningRequired !=  undefined) {
	 		//XSSOK
	 		if(editForm.EndItem!=undefined && editForm.EndItem.value == "<%= endItemNoOption %>") {
	 	       		var prPropValue = editForm.PlanningRequired.value;
	 	       		//XSSOK
	 	       		if(prPropValue == "<%=planningRequiredYesOption%>")
	 	       		{
	 	       		//XSSOK
	 	       		alert("<%=planningRequiredAlert%>");
	 	       		return false;  	
	 	       		}	       		
	   	  }	         
	      }
	       return true;
	 }
 function preProcessInCancel() {
    var editForm = document.forms["editDataForm"];    
    //XSSOK
        if("<%=strType%>"== "DCR") {
            editForm.Warning2.disabled=true;
        }   else {
            editForm.Warning.disabled=true; 
        }    
    }

 
 function validateCancelECR() { 
     var editForm = document.forms["editDataForm"];
     var reason=editForm.Reason.value;  
     
     if(reason!="")  {
         var confirmmessage=""; 
			//XSSOK
            if("<%=strType%>"== "ECR") {
              confirmmessage="<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.CancelECRDialog.CancelECRConfirm</emxUtil:i18nScript>";
            //XSSOK
	     }
	     //XSSOK
	     else  if("<%=strType%>"== "DCR") {
               var confirmmessage="<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.CancelECRDialog.CancelDCRConfirm</emxUtil:i18nScript>";
            }
   
            if (confirm(confirmmessage)){
                return true;        
             } else {
                return false;
             }
                     
     } else {
            return true;
     }
     
 }

 function validateMarkup() {    

	 	var reference     = findFrame(getTopWindow(), "portalDisplay") == null?findFrame(getTopWindow(), "content"): findFrame(getTopWindow(), "ENCBOM");
        if(reference == null || reference == undefined ){
	        reference = findFrame(getTopWindow(), "portalDisplay") == null?findFrame(getTopWindow(), "content"): findFrame(getTopWindow(), "ENCWhereUsed");
        }
        
        if(!isValidFrame(reference)) {
        	var portalFrame = findFrame(getTopWindow(),"detailsDisplay");
        	reference 		= findFrame(portalFrame,"ENCBOM");
        	if(!isValidFrame(reference)) {
        		reference = findFrame(portalFrame,"ENCWhereUsed");
        	}
        }
        
        var callback    = eval(reference.emxEditableTable.prototype.getMarkUpXML);
        var oxmlstatus  = callback();
        var editForm = document.forms["editDataForm"];
        var inputXML = oxmlstatus.xml;
        editForm.markupXML.value = inputXML;     
        return true;

     }
 
 function isValidFrame(frameEle) {
	return (frameEle == null || frameEle == undefined || frameEle.location.href.indexOf("about:blank")>-1) ? false : true;
 }
 
 function validateEndItem()
{

     var editForm = document.editDataForm;
     var endItemVal = editForm.EndItem.value;
   //XSSOK
    var policyVal = "<%=strPolicy%>";
  //XSSOK
   var MANU_PART = "<%=EngineeringConstants.POLICY_MANUFACTURING_PART%>";
 //XSSOK
  	if((("<%=strMfgPolicy%>".indexOf(policyVal)) != -1  || policyVal == MANU_PART) && ((endItemVal=="Yes"))){
  		
  		<%--Multitenant--%>
  		<%--var error_msg = "<%=i18nNow.getI18nString("emxEngineeringCentral.Part.Edit.EndItem","emxEngineeringCentralStringResource",strLanguage)%>";--%>
  		//XSSOK
  		var error_msg = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.Edit.EndItem")%>";
	alert(error_msg);
	return false;
      }
 return true;
}

    function validateProductionMakeBuy()
{

     var editForm = document.editDataForm;
     var productionMakeBuyCodeVal = editForm.ProductionMakeBuyCode.value;
   //XSSOK
     var policyVal = "<%=strPolicy%>";
   //XSSOK
     var MANU_PART = "<%=EngineeringConstants.POLICY_MANUFACTURING_PART%>";
   //XSSOK
  	if((("<%=strMfgPolicy%>".indexOf(policyVal)) != -1 || policyVal == MANU_PART) && ((productionMakeBuyCodeVal!="Unassigned"))){
  		
  		<%--Multitenant--%>
  		<%--var error_msg = "<%=i18nNow.getI18nString("emxEngineeringCentral.Part.Edit.ProductionMakeBuyCode","emxEngineeringCentralStringResource",strLanguage)%>";--%>
  		//XSSOK
  		var error_msg = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.Edit.ProductionMakeBuyCode")%>";
		alert(error_msg);
		return false;
      }
 return true;
}
   
// This function is used to select all options from the Report Differences and Sections fields

function selectAllOptions(elemId) {
	
	var objForm = document.editDataForm;	
 	
 	if(objForm.selectAll.checked)
 	{
 		for (var i=0; i < objForm.elements.length; i++) {
            if ((objForm.elements[i].id.indexOf(elemId) > -1)&& (!objForm.elements[i].disabled))
            {
               objForm.elements[i].checked = true;
            }	       
       }
 	}
 	else
 	{
 		var defaultElemName = elemId+"_default";    
 	   	var objForm = document.editDataForm;
 	
 	   for (var i=0; i < objForm.elements.length; i++) {
 	       if ((objForm.elements[i].id.indexOf(elemId) > -1)&& (!objForm.elements[i].disabled))
 	       {   
 	                      
 	    	   if (objForm.elements[i].id==defaultElemName) {
 	               objForm.elements[i].checked = true;
 	    	   }
 	    	   else {
 	        	   objForm.elements[i].checked = false;  
 	    	   }  
 	       }
 	    }
 	}
        
 }

//This function is used to Reset all options from the Report Differences and Sections fields
function resetOptions(elemId) {
    var defaultElemName = elemId+"_default";    
   	var objForm = document.editDataForm;           
    for (var i=0; i < objForm.elements.length; i++) {
       if ((objForm.elements[i].id.indexOf(elemId) > -1)&& (!objForm.elements[i].disabled))
       {   
                      
    	   if (objForm.elements[i].id==defaultElemName) {
               objForm.elements[i].checked = true;
    	   }
    	   else {
        	   objForm.elements[i].checked = false;  
    	   }  
       }
    }
		
}
                     
//This function is used to prepopulate the BOM2 Part Name field if second object Id is already available
function preProcessInBOMCompare() {
	if(getTopWindow().window.info && getTopWindow().window.info["CompareCriteriaJSON"] && getTopWindow().window.info["CompareCriteriaJSON"].BOM2NameDisplay) {
		reloadCompareCriteria(document.editDataForm);
	} else {
		if(document.editDataForm.BOM2PreloadName.value !="") {
			document.editDataForm.BOM2NameDisplay.value = document.editDataForm.BOM2PreloadName.value;
			document.editDataForm.BOM2NameDispOID.value = document.editDataForm.BOM2PreloadName.value;
			document.editDataForm.BOM2Name.value = document.editDataForm.BOM2PreloadID.value;
		}
		
		if(document.editDataForm.BOM1PreloadName.value !="") {
			document.editDataForm.BOM1NameDisplay.value = document.editDataForm.BOM1PreloadName.value;
			document.editDataForm.BOM1NameDispOID.value = document.editDataForm.BOM1PreloadName.value;
			document.editDataForm.BOM1Name.value = document.editDataForm.BOM1PreloadID.value;
			
			document.editDataForm.BOM1NameOID.value = document.editDataForm.BOM1NameOID.value;
		}
	}
<%      
	    if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)) {
%>
		    if(document.editDataForm.Type1.value == "EBOM") { 
			    disableType1Fields();
			}
			if(document.editDataForm.Type2.value == "EBOM") {
				disableType2Fields();
			}
<%
	    }
%>
if(document.editDataForm.MatchBasedOn!=undefined && !(document.editDataForm.MatchBasedOn.options[0].value == "emxEngineeringCentral.label.PartNameRefDesignatorClassCode")) {
	var radioButtons = document.editDataForm.parent; 
	for (var j=0, jLen=radioButtons.length; j<jLen; j++) {
		radioButtons[j].disabled = true;
	} 
	}
	//}
}

 function preProcessInEditMFGPart(){
    //XSSOK
    var MANU_PART = "<%=EngineeringConstants.POLICY_MANUFACTURING_PART%>";
    var editForm = document.forms['editDataForm'];
    //XSSOK
    var mfgPolicy = "<%=strPolicy%>";
    var editForm = document.forms["editDataForm"];
	var uomValue;
	if(editForm.Uom != null){
		uomValue = editForm.Uom.value;
	}
	reloadUOMField(); //UOM Management: To reload the UOM field as per page object settings
	if(uomValue != null && uomValue != ""){
		editForm.Uom.value = uomValue;
	}
    if(mfgPolicy == MANU_PART) {
	    
	var eleProdMakeBuy = editForm.elements["ProductionMakeBuyCodeId"];    
	
	if(!isNullOrEmpty(eleProdMakeBuy)) {
	    for(var i=0;i < eleProdMakeBuy.length; i++)
	    {
	   
	    	 if(eleProdMakeBuy.options[i].value == "Make" || eleProdMakeBuy.options[i].value == "Buy"){
	             eleProdMakeBuy.remove(i);
	             eleProdMakeBuy.remove(i);
	           }
	    }
	}
    var eleEI = editForm.elements["EndItemId"];
    //IR-216531V6R2014( only adding the if condition for the "for" loop as eleEI is coming as undefiened/null )
    if(eleEI){
	    for(var i=0;i < eleEI.length; i++)
	    {
	        if(eleEI.options[i].value == "Yes") {
	            eleEI.remove(i);
	        }
	    }
    }
    
  }
  
   
}

 function isNullOrEmpty(str) {
		return (str == null || str == "null" || str == "undefined" || str.length == 0) ? true : false;
	}

 
 function validateWeight() {
	    var editForm = document.forms['editDataForm'];
	    var weight     = editForm.elements["Weight"];
	    if (weight != null) {
	        var weightValue = weight.value;
	        weightValue = weightValue.trim();
	        if(!isNumericGeneric(weightValue)){
				alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.WeightHasToBeANumber</emxUtil:i18nScript>");
				return false;
	      	}
	        if ((weightValue.substring(0,1) == "-")) {
	            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.WeightHasToBeGreaterThanZero</emxUtil:i18nScript>");
	            weight.value = '';
	            weight.focus();
	            return false;
	        }
	    }
	    return true;
	}

 function validateEffectivityDate() {
	    var editForm      = document.forms['editDataForm'];
	    var effectivityDate = editForm.elements["EffectivityDate_msvalue"];	    
	    var newEffectivityDate = document.forms[0].EffectivityDate.value; 
   
	    var eDate = new Date();
	    eDate.setTime(effectivityDate.value);
	   	   	   
	    var currentDate = new Date();	   
	    if(newEffectivityDate != "") {	   
	    	if(effectivityDate.value != "") {
		    if((parseInt(eDate.getTime()))<=(parseInt(currentDate.getTime()))) {	        
		        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.TargetRelDateHasToBeGreaterThanPresentDate</emxUtil:i18nScript>");
		        return false;
		    }
	    }
	    }
	    return true;
	}
 function validateEffectivityDateForItemMarkup() {
	 
	    var createItemMarkupForm      = document.forms['editDataForm'];
	    var effectivityDate = createItemMarkupForm.elements["txt_Effectivity Date"];
	    
	    var currentDate = new Date();

	    var eDate = new Date();
	    eDate.setTime(Date.parse(effectivityDate.value));
	    if(effectivityDate.value != "") {
		    if((parseInt(eDate.getTime()))<(parseInt(currentDate.getTime()))) { 
		    //if(eDate.getFullYear()<currentDate.getFullYear() || eDate.getMonth()<currentDate.getMonth() || eDate.getDate()<currentDate.getDate()) { 
		        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.TargetRelDateHasToBeGreaterThanPresentDate</emxUtil:i18nScript>");
		        effectivityDate.value="";
		        return false;
		    }
	    }
	    
	    return true;
	}
 function validateEstimatedCost() {
	    var editForm      = document.forms['editDataForm'];
	    var estimatedCost = editForm.elements["EstimatedCost"];    
	    if (estimatedCost != null) {
		    
	        var estimatedCostValue = estimatedCost.value;
	        estimatedCostValue = estimatedCostValue.trim();	        
	        if(!isNumericGeneric(estimatedCostValue)){
				alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.EstimatedCostHasToBeANumber</emxUtil:i18nScript>");
				return false;
			}
	        if((estimatedCostValue.substring(0,1) == "-")) {
	            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.EstimatedCostHasToBeGreaterThanZero</emxUtil:i18nScript>");
	            estimatedCost.value = '';
	            estimatedCost.focus();
	            return false;
	        }
	    }
	    return true;
	}

     function validateTargetCost() {
    	var editForm   = document.forms['editDataForm'];
	    var targetCost = editForm.elements["TargetCost"];
	    if (targetCost != null) {
	        var targetCostValue = targetCost.value;
	        targetCostValue = targetCostValue.trim();
        	if(!isNumericGeneric(targetCostValue)){
    			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.TargetCostHasToBeANumber</emxUtil:i18nScript>");
    			return false;
    		}
	        if ((targetCostValue.substring(0,1) == "-")) {
	            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.TargetCostHasToBeGreaterThanZero</emxUtil:i18nScript>");
	            targetCost.value = '';
	            targetCost.focus();
	            return false;
	        }
	    }
	    return true;
	}	
     function clearEditAffectedPlants() 
     {
     var f = document.editDataForm;
     var plantNames = f.AffectedPlantsDisplay.value;
     var plantIds = f.AffectedPlants.value;
     var index = plantNames.indexOf(',');
     f.AffectedPlantsDisplay.value = plantNames.substring(0, index + 1);
     index = plantIds.indexOf(',');
     f.AffectedPlants.value = plantIds.substring(0, index + 1);
     }

     function disableFieldsInBOMGotoProduction() {
         document.editDataForm.btnECOToRelease.disabled = true;
		 document.editDataForm.ECOToReleaseDisplay.disabled = true;
		 
		 if (document.editDataForm.btnDesignResponsiblity) {
			 document.editDataForm.btnDesignResponsiblity.disabled = true;
			 document.editDataForm.DesignResponsiblityDisplay.disabled = true;         
		 }
     }

     function validateChangeForAddExiting() {
         //Added for RDO Convergence start
    	 if (document.editDataForm.ecoOptions[1].checked && document.editDataForm.DesignResponsiblityDisplay.value == "") {
        	//XSSOk
        	 alert("<%=msgSelectRDO%>");
             return false;
         }
    	//Added for RDO Convergence End
		 if (document.editDataForm.ecoOptions[1].checked && document.editDataForm.ECOToReleaseDisplay.value == "") {
        	 //XSSOK
        	 alert("<%=msgSelectECO%>");
             return false;
         }
         
         return true;
     }
	 
	 //Added for RDO Convergence start
     function resetECO() {
    	 if (document.editDataForm.ECO != undefined) {    
    			document.editDataForm.ECODisplay.value = "";	
    			document.editDataForm.ECO.value = "";
    			document.editDataForm.ECOOID.value = "";
    	} else if (document.editDataForm.ECOToRelease != undefined) { 				
    	 	document.editDataForm.ECOToReleaseOID.value = "";
        	document.editDataForm.ECOToReleaseDisplay.value = "";
        	document.editDataForm.ECOToRelease.value = "";
    	}
    	 
     }
   //Added for RDO Convergence End
      
   
   //Added for ENG Convergence start
   function validateCOForAddExiting() {      
		 //if (document.editDataForm.ecoOptions[1].checked && document.editDataForm.COToReleaseDisplay.value == "") {
   	     if (document.editDataForm.ecoOptions[2].checked && document.editDataForm.COToReleaseDisplay.value == "") {	
		//XSSOK
        	 alert("<%=msgSelectCO%>");
             return false;
         }
         
         return true;
     }
   
   function disableFieldsInENCBOMGotoProduction() {
       if(document.editDataForm.COToReleaseDisplay != undefined){
	   	document.editDataForm.btnCOToRelease.disabled = true;
		 document.editDataForm.COToReleaseDisplay.disabled = true;
       }
   }
 //Added for ENG Convergence END
  function onChangeMatchBasedOn()
{
	 var selIndex  =document.editDataForm.MatchBasedOn.options.selectedIndex;
	 var selOptionVal = document.editDataForm.MatchBasedOn.options[selIndex].value;
		if(document.editDataForm.MatchBasedOn!=undefined && !(selOptionVal == "emxEngineeringCentral.label.PartNameRefDesignatorClassCode")) {
			var radioButtons = document.editDataForm.parent; 
			for (var j=0, jLen=radioButtons.length; j<jLen; j++) {
				radioButtons[j].disabled = true;
			} 
	  	}
		else 
			{
			var radioButtons = document.editDataForm.parent; 
			for (var j=0, jLen=radioButtons.length; j<jLen; j++) {
				radioButtons[j].disabled = false;
			} 
			}
 }
 
  function validateProductRequired() {
		 var editForm = document.forms["editDataForm"];
		   	if(editForm.ProductEditDisplay  !=  undefined && editForm.PlanningRequired  !=  undefined) {
		 		//XSSOK
		 		if(editForm.ProductEditDisplay !=undefined && editForm.ProductEditDisplay .value == "" && editForm.PlanningRequired.value == "<%= endItemYesOption %>") {
			       	//XSSOK	
			       		alert("<%=sProductValidation1%>");
			       		return false;  	
		   	  }
		 		//XSSOK
		 		if(editForm.EndItem.value != "<%= endItemYesOption %>" && editForm.ProductEditDisplay!=undefined && editForm.ProductEditDisplay.value != "") {
					//XSSOK
					alert("<%=sProductValidation2%>");
					return false;
				}
	      }else{
	    	 //XSSOK
	    	  if(editForm.PlanningRequired == undefined && "<%=planningRequired%>" == "<%=planningRequiredYesOption%>"){
	    			  if(editForm.ProductEditDisplay !=undefined && editForm.ProductEditDisplay .value == "") {
				       		//XSSOK
				       		alert("<%=sProductValidation1%>");
				       		return false;  	
			   	  	  }
	    	  }
	      }
		       return true;
		 }
  function setDisabledProductOption(optionEnableOrDisable){
		 var eleProduct = document.editDataForm.ProductEditDisplay;
		 
		  var btnProductEdit = document.editDataForm.btnProductEdit;
		  if(eleProduct!=undefined){
	        eleProduct.disabled = optionEnableOrDisable;
	          }
		  if(btnProductEdit!=undefined){
	        btnProductEdit.disabled = optionEnableOrDisable;}

	}
  
  function onChangePR()
  {
  if(document.editDataForm.PlanningRequired !=  undefined) {
	  prModified = false;
  ///XSSOk
  			if(document.editDataForm.PlanningRequired.value == "<%= planningRequiredYesOption %>" && "True" == "<%=isMRAttached%>") {
  				//XSSOK
  				alert("<%=sPRNoToYes%>");
  				prModified = true;
	       		return false;  	
  	         }
  			else
  			{
  				return true;  	
  			}
  	   	
    	}
  return true;
  }
  function loadFilteredValue()
  {
	var a = sessionStorage.getItem('sName');
	if(sessionStorage.getItem('searchForm')!=document.editDataForm.formId.defaultValue){
		//sessionStorage.clear();
		sessionStorage.removeItem("sName");
		sessionStorage.removeItem("sQueryLimit");
		sessionStorage.removeItem("sDesc");
		sessionStorage.removeItem("sType");
		sessionStorage.removeItem("MEPName");
		sessionStorage.removeItem("MEPType");
		sessionStorage.removeItem("MEPState");
		sessionStorage.removeItem("MEPDescription");
		sessionStorage.removeItem("MEPStatus");
		sessionStorage.removeItem("MEPManufacturer");
		sessionStorage.removeItem("MEPPreference");
		sessionStorage.removeItem("searchPolicy");
		sessionStorage.removeItem("searchState");
		sessionStorage.removeItem("searchPhase");
		sessionStorage.removeItem("searchOwner");
		sessionStorage.removeItem("searchTitle");
		sessionStorage.removeItem("formName");
	}
	  if(sessionStorage.getItem('sName') != null){
		  if(document.editDataForm.Name != undefined)
		  	document.editDataForm.Name.value = sessionStorage.getItem('sName');
	  }
	  if(sessionStorage.getItem('sQueryLimit') != null){
		  if(document.editDataForm.QueryLimit != undefined)	
		  	document.editDataForm.QueryLimit.value = sessionStorage.getItem('sQueryLimit');
	  }
	  if(sessionStorage.getItem('sDesc') != null){
		  if(document.editDataForm.Description != undefined)	
		  	document.editDataForm.Description.value = sessionStorage.getItem('sDesc');
	  }
	  if(sessionStorage.getItem('sType') != null){
		  if (document.editDataForm.Type != undefined) {	
		  	  document.editDataForm.Type.value = sessionStorage.getItem('sType');
		  }
		  
		  if (document.editDataForm.TypeDisplay != undefined) {	
		  	  document.editDataForm.TypeDisplay.value = sessionStorage.getItem('sType');
		  }
	  }
		  	
	  if(sessionStorage.getItem('MEPName') != null){
		  if(document.editDataForm.MEPName != undefined)	
		  	document.editDataForm.MEPName.value = sessionStorage.getItem('MEPName');
	  }
	  if(sessionStorage.getItem('MEPType') != null){
		  if(document.editDataForm.MEPType != undefined)	
		  	document.editDataForm.MEPType.value = sessionStorage.getItem('MEPType');
	  }
	  if(sessionStorage.getItem('MEPState') != null){
		  if(document.editDataForm.MEPState != undefined)	
		  	document.editDataForm.MEPState.value = sessionStorage.getItem('MEPState');
	  }
	  if(sessionStorage.getItem('MEPDescription') != null){
		  if(document.editDataForm.MEPDescription != undefined)	
		  	document.editDataForm.MEPDescription.value = sessionStorage.getItem('MEPDescription');
	  }
	  if(sessionStorage.getItem('MEPStatus') != null){
		  if(document.editDataForm.MEPStatus != undefined)	
		  	document.editDataForm.MEPStatus.value = sessionStorage.getItem('MEPStatus');
	  }
	  if(sessionStorage.getItem('MEPManufacturer') != null){
		  if(document.editDataForm.MEPManufacturer != undefined)	
		  	document.editDataForm.MEPManufacturer.value = sessionStorage.getItem('MEPManufacturer');
	  }
	  if(sessionStorage.getItem('MEPPreference') != null){
		  if(document.editDataForm.MEPPreference != undefined)	
		  	document.editDataForm.MEPPreference.value = sessionStorage.getItem('MEPPreference');
	  }
	  if(sessionStorage.getItem('searchPolicy') != null){
		  if(document.editDataForm.Policy != undefined)	
		  	document.editDataForm.Policy.value = sessionStorage.getItem('searchPolicy');
	  }
	  
	  /* if(sessionStorage.getItem('searchState') != null){
		  if(document.editDataForm.State != undefined)	
		  	document.editDataForm.State.value = sessionStorage.getItem('searchState');
	  } */
	 	  var states = JSON.parse(sessionStorage.getItem("searchState"));
		  if(states != null){
			var checkbox = document.editDataForm.State;
			  for(var i = 0; i<states.length; i++){
				
				for(var j=0;j<checkbox.length;j++){
					if(checkbox[j].value == states[i]){
						checkbox[j].checked = true;
						break;
					}
				}
			}
	  }
	  if(sessionStorage.getItem('searchPhase') != null){
		  if(document.editDataForm.ReleasePhase != undefined)	
		  	document.editDataForm.ReleasePhase.value = sessionStorage.getItem('searchPhase');
	  }
	  if(sessionStorage.getItem('searchOwner') != null){
		  if(document.editDataForm.Owner != undefined){	
		  	document.editDataForm.Owner.value = sessionStorage.getItem('searchOwner');
	  	  }
		  if (document.editDataForm.OwnerDisplay != undefined){	
		  	  document.editDataForm.OwnerDisplay.value = sessionStorage.getItem('ownerDisplay');
		  }
	  }
	  if(sessionStorage.getItem('searchTitle') != null){
		  if(document.editDataForm.Title != undefined)	
		  	document.editDataForm.Title.value = sessionStorage.getItem('searchTitle');
	  }
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
		   alert("<%=strZeroQueryLimit%>");
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
    function validateWorkUnderChange() {
			if($('input[name=WorkUnderfieldValue]').val() !='' ){
				return true;
			}else if($('input[name=changeControlled]').val() != "NONE" &&  $('input[name=WorkUnderOID]').val()=='' && $('input[name=WorkUnderfieldValue]').val() ==''){
				alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.WorkUnderChangeRequired</emxUtil:i18nScript>");
			}else{
				return true;
			}
		}
  
	//UOM management - start
	function reloadUOMField()
	{
	      emxFormReloadField("Uom");
	}
	//UOM management - end

        // For VPMVisible (Design collaboration) validation in Edit pages     
	function validateDesignCollaboration() 
	{
		var editForm = document.forms['editDataForm'];
	   	var vpmvisible     = editForm.elements["VPMVisible"];
		//XSSOK
		var stype = "<%=strType%>";
	    
	   	if (stype== "Raw Material" && vpmvisible.checked == 1) {
	        //XSSOK	
	        	alert("<%=msgRawMaterialErrorMsg%>");
	        	vpmvisible.checked =  false;
	        	return false;
	    } 
		return true;
	}
	//My ENG View changes
	function reloadMaturityStates(){
	 	emxFormReloadField("State");
		if(document.editDataForm.formId.defaultValue == "EngineeringDashboardFilter"){
		 	if(document.editDataForm.Policy != undefined){
			  	if(document.editDataForm.Policy.value != "EC Part"){
			  		document.editDataForm.ReleasePhase.disabled = true;
			  	}else{
			  		document.editDataForm.ReleasePhase.disabled = false;
			  	}
		 	}
		}
	}
	
	function updateReleasePhase(){
		emxFormReloadField("ReleasePhase");
		/* if(document.editDataForm.Policy != undefined || document.editDataForm.Policy != null){
		  	if(document.editDataForm.Policy.value != "EC Part"){
		  		document.editDataForm.ReleasePhase.disabled = true;
		  	}else{
		  		document.editDataForm.ReleasePhase.disabled = false;
		  	}
	 	} */
		emxFormReloadField("Policy");
		
	}
	function reloadStatesOnPolicySelection(){
		emxFormReloadField("State");
		if(document.editDataForm.formId.defaultValue == "EngineeringDashboardFilter"){
			if(document.editDataForm.Policy != undefined || document.editDataForm.Policy != null){
		  	if(document.editDataForm.Policy.value == "Manufacturer Equivalent"){
		  		document.editDataForm.ReleasePhase.disabled = true;
		  	}
		  	else{
		  		document.editDataForm.ReleasePhase.disabled = false;
			  	}
		  	}
	 	}
	}
	function validateCheckedStates(){
		var checked = document.editDataForm.State[0].checked;
		if(checked){
			for(var i=1;i<document.editDataForm.State.length;i++){
				document.editDataForm.State[i].checked = false;
				document.editDataForm.State[i].disabled = true;
			}
		}else{
			for(var i=1;i<document.editDataForm.State.length;i++){
				document.editDataForm.State[i].disabled = false;
			}
		}
	}
	
	/*
	*Validate bad characters entered for Name/Title in My ENG View Search Criteria forms
	*/
	//XSSOK
	
	function validateBadCharinSearch(fieldObj){
		if(fieldObj == null || fieldObj == "undefined" || fieldObj == "null" || fieldObj == "")
		    {
		    	fieldObj = this;
		    }
		var BAD_CHAR = '<%=BAD_CHAR_SET %>';
		var BAD_CHAR_ARRAY = BAD_CHAR.split(" ");
		
		var isBadNameChar = checkFieldForChars(fieldObj, BAD_CHAR_ARRAY, false);
		if( isBadNameChar.length > 0 )
	    {
			var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxEngineeringCentral.Alert.InvalidChars</emxUtil:i18nScript>"+isBadNameChar;
	        alert(strAlert);
	        return false;
	    }
	    return true;
	}

   // Changes added by PSA11 start(IR-643895-3DEXPERIENCER2018x).   
   // Checking for Bad characters in the field
   function checkBadNameChars(fieldName) 
   {
	if(!fieldName)
	   {
		fieldName=this;
	   }
	   if(fieldName.value!=null && fieldName.value!="" )
	   {
		 var isBadNameChar=checkForNameBadChars(fieldName,true);
		 var fieldValue=fieldName.value;
		 var orgLen = fieldValue.replace(/[.]/g, '');
		  var name;
		  
		 if(fieldName.title!="undefined" && fieldName.title!="" && fieldName.title!="null"){
			name = fieldName.title;
		 }
		 else {
			name = fieldName.name;
		 }
	 
		 if(( isBadNameChar.length > 0 || orgLen.length==0)&& isBadNameChar!="")
		 {
		   var nameAllBadCharName = getAllNameBadChars(fieldName);
		   msg = "<%=i18nNow.getI18nString("emxComponents.ErrorMsg.InvalidInputMsg","emxComponentsStringResource", request.getHeader("Accept-Language"))%>";
		   msg += isBadNameChar;
		   msg += "<%=i18nNow.getI18nString("emxComponents.Common.AlertInvalidInput", "emxComponentsStringResource", request.getHeader("Accept-Language"))%>";
		   msg += nameAllBadCharName;
		   msg += " in the " + name;
		   msg += " <%=i18nNow.getI18nString("emxComponents.Alert.Field", "emxComponentsStringResource", request.getHeader("Accept-Language"))%>";
		   fieldName.focus();
		   alert(msg);
		   return false;
		 }
	   }
	   return true;
   }    
  // Changes added by PSA11 end.
</script>


