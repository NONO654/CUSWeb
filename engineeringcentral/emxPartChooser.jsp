
<%--  emxPartChooser.jsp  - This page selects the parts
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="../components/emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>


<%!
  private static final String COMPONENT_FRAMEWORK_BUNDLE = "emxComponentsStringResource";
  private static final String ALERT_MSG = "emxComponents.Search.Error.24";
%>

<%
	String objectId = (String)emxGetParameter(request, "objectId");
	String strMode = (String)emxGetParameter(request, "addFunction");

	if(strMode == null)
	strMode = "chooser";

	String strFrameName = XSSUtil.encodeForJavaScript(context,(String)emxGetParameter(request, Search.REQ_PARAM_FRAME_NAME));
	String strFormName = XSSUtil.encodeForJavaScript(context,(String)emxGetParameter(request, Search.REQ_PARAM_FORM_NAME));
	String strFieldNameDisplay = XSSUtil.encodeForJavaScript(context,(String)emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_DISPLAY));
	String strFieldNameActual = XSSUtil.encodeForJavaScript(context,(String)emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_ACTUAL));
	String sRevisionDisplay = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"RevDisplay"));
	String sHiddenRevision = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"hiddenField"));
	String sHiddenName = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"hiddenNameField"));
	String strTableRowId[] = emxGetParameterValues(request,"emxTableRowId");
	String sid = "";

	//R212 changes
	String typeAhead = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "typeAhead"));
	String frameName = emxGetParameter(request, "frameName");
	
	// Changes for ECC Reports .st
	String languageStr     = request.getHeader("Accept-Language");
	String sParentPolicyClass  ="";
	boolean sConfigFlag = false;
		
	boolean isMBOMInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMManufacturing",false,null,null);
	boolean isECCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionEngineeringConfigurationCentral",false,null,null);
	//Multitenant
	/* String sLatest     = i18nNow.getI18nString("emxEngineeringCentral.RevisionFilterOption.Latest", "emxEngineeringCentralStringResource", languageStr);
	String sLatestValue    = i18nNow.getI18nString("emxEngineeringCentral.RevisionFilterOption.Latest", "emxEngineeringCentralStringResource", "en");
	String sAsStored   = i18nNow.getI18nString("emxEngineeringCentral.RevisionFilterOption.As_Stored", "emxEngineeringCentralStringResource", languageStr); */
	
	
	String sLatest     = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.RevisionFilterOption.Latest");
	String sLatestValue    = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", new Locale("en"),"emxEngineeringCentral.RevisionFilterOption.Latest");
	String sAsStored   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.RevisionFilterOption.As_Stored");

	//Language conversion should be for display value and actual name should always be in english
	//Fix for IR-066285V6R2011x-starts
	//String sAsStoredValue =sAsStored;
	//String sAsStoredValue = i18nNow.getI18nString("emxEngineeringCentral.RevisionFilterOption.As_Stored", "emxEngineeringCentralStringResource", "en");
	String sAsStoredValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", new Locale("en"),"emxEngineeringCentral.RevisionFilterOption.As_Stored");
	//sAsStoredValue = sAsStoredValue.replace(' ','_');
	//Fix for IR-066285V6R2011x-Ends
	
	/* String strCurrent = i18nNow.getI18nString("emxMBOM.RevisionOptions.Current", "emxMBOMStringResource",languageStr);
	String strPending = i18nNow.getI18nString("emxMBOM.RevisionOptions.Pending", "emxMBOMStringResource",languageStr);
	String strHistory = i18nNow.getI18nString("emxMBOM.MBOMCustomFilter.History", "emxMBOMStringResource",languageStr);
	String strMBOMLabel = i18nNow.getI18nString("emxMBOM.ComparisionReport.MBOM","emxMBOMStringResource", languageStr); */
	
	String strCurrent = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.RevisionOptions.Current");
	String strPending = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.RevisionOptions.Pending");
	String strHistory = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.MBOMCustomFilter.History");
	String strMBOMLabel = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.ComparisionReport.MBOM");
	
	String sPolicy = "";

	// Changes for ECC Reports .en	

	String error = "false";
	String strRetMsg = "";
	String selIds = "";
	String strObjname = "";
	String sRev  = "";

	if (strTableRowId == null)
	{
		i18nNow i18nInstance = new i18nNow();
		String strLang = request.getHeader("Accept-Language");
		
		//Multitenant
		//strRetMsg = i18nInstance.GetString(COMPONENT_FRAMEWORK_BUNDLE, acceptLanguage,ALERT_MSG);
		strRetMsg = EnoviaResourceBundle.getProperty(context, COMPONENT_FRAMEWORK_BUNDLE, context.getLocale(),ALERT_MSG);
		error = "true";
	}
	else
	{

		int iTableRow = strTableRowId.length;
		for(int i=0 ; i<strTableRowId.length ;i++)
		{
			StringTokenizer strTokens = new StringTokenizer(strTableRowId[i],"|");
			if (strTokens.hasMoreTokens())
			{
				selIds = strTokens.nextToken();
				Search search = new Search();
				strObjname = search.getObjectName(context, selIds);
				DomainObject dObj = null;
				dObj = new DomainObject(selIds);
				sRev = dObj.getInfo(context,DomainConstants.SELECT_REVISION);
			
				// Changes for ECC Reports .en
                                if (isECCInstalled) {
				sPolicy = dObj.getInfo(context, DomainConstants.SELECT_POLICY);
				
				DomainObject dPart1 = null;
				String policyClassification 	= "policy.property[PolicyClassification].value";
				sParentPolicyClass 		= dObj.getInfo(context,policyClassification);
				// if the policy of the select object is Un-resolved, do the followign checks
				/* if (sParentPolicyClass.equals("Unresolved")) {
					String sLastid = (String)dObj.getInfo(context, DomainConstants.SELECT_LAST_ID);
					
					dPart1 = new DomainObject(sLastid);
					sRev = dPart1.getInfo(context, DomainConstants.SELECT_REVISION);
					sConfigFlag = true;
				} else {
					sRev = dObj.getInfo(context,DomainConstants.SELECT_REVISION);
					sConfigFlag = false;
				} */ 
				sRev = dObj.getInfo(context,DomainConstants.SELECT_REVISION);
				sConfigFlag= sParentPolicyClass.equals("Unresolved")? true: false;
                               } // EC Installed Check..
                 }
		}
	}
%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" type="text/javaScript">
//XSSOK
var typeAhead = "<%=typeAhead%>";

var targetWindow = null;
if(typeAhead == "true") {
    if("<xss:encodeForJavaScript><%=frameName%></xss:encodeForJavaScript>" != "")
           targetWindow = getTopWindow().findFrame(window.parent, "<xss:encodeForJavaScript><%=frameName%></xss:encodeForJavaScript>");
    else
        targetWindow = window.parent;
} else {
    targetWindow = getTopWindow().getWindowOpener();
}

function setAndRefresh()
{
	//XSSOK
	var formName = "<%=strFormName%>";
	//XSSOK
	var fieldDisplay = "<%=strFieldNameDisplay%>";
	//XSSOK
	var fieldActual = "<%=strFieldNameActual%>";
	//XSSOK
	var sPartName = "<%=strObjname%>";
	//XSSOK
	var sPartId = "<%=selIds%>"
		//XSSOK
	var RevDisplay = "<%=sRevisionDisplay%>";
	//XSSOK
	var strRev = "<%=sRev%>";
	//XSSOK
	var RevActual = "<%=sHiddenRevision%>";
	//XSSOK
	var NameActual = "<%=sHiddenName%>";


	// Changes for ECC Reports .st
	//XSSOK
	var sConfigFlag = "<%=sConfigFlag%>";
	//XSSOK
	var isMBOMInstalled = "<%=isMBOMInstalled%>";
	//XSSOK
	var isECCInstalled  = "<%=isECCInstalled%>";
	//XSSOK
    var strLatest          ="<%=sLatest%>";
  //XSSOK
    var strLatestValue     ="<%=sLatestValue%>";
  //XSSOK
    var strAsStored        ="<%=sAsStored%>";
  //XSSOK
    var strAsStoredVal     ="<%=sAsStoredValue%>";
  //XSSOK
	var sCurrent           ="<%=strCurrent%>";
	//XSSOK
	var sPending           ="<%=strPending%>";
	//XSSOK
	var sHistory           ="<%=strHistory%>";
	//XSSOK
	var sMBOMLabel         ="<%=strMBOMLabel%>";
		
	var elementCount;
	var txtTypeDisplay;
	var txtTypeActual;
	var txtRevDisplay;
	var txtRevActual;
	var txtNameActual;
	//XSSOK
	var targetFrame = findFrame(targetWindow, "<%=strFrameName%>");
	for(var i=0;i<targetWindow.document.forms.length;i++)
	{
		if(targetWindow.document.forms[i].name == formName)
		{
			elementCount = i;
		}
	}
	if(targetFrame !=null)
	{
		txtTypeDisplay=targetFrame.document.forms[elementCount].elements[fieldDisplay];
		txtTypeActual=targetFrame.document.forms[elementCount].elements[fieldActual];
	}
	else
	{
		txtTypeDisplay=targetWindow.document.forms[elementCount].elements[fieldDisplay];
		txtTypeActual=targetWindow.document.forms[elementCount].elements[fieldActual];
		txtRevDisplay=targetWindow.document.forms[elementCount].elements[RevDisplay];
		txtRevActual=targetWindow.document.forms[elementCount].elements[RevActual];
		txtNameActual=targetWindow.document.forms[elementCount].elements[NameActual];
	}
	txtTypeDisplay.value = sPartName;
	txtTypeActual.value = sPartId;
	txtRevDisplay.value= strRev;
	txtRevActual.value = strRev;
	txtNameActual.value = sPartName;


	
         if (isECCInstalled == "true" ) {
	    var sType2 ="";
	// Changes for ECC Reports .st
			if(NameActual=="BOM1NameDispOID") {	
			sType2 =  targetWindow.document.getElementsByName("Type1").item(0);
			} else {
       		sType2 =  targetWindow.document.getElementsByName("Type2").item(0);
			}

	
	// Check for Part Name
	var sConfigType1 =  targetWindow.document.getElementsByName("BOM1CofigPart").item(0);	
	var sConfigType2 =  targetWindow.document.getElementsByName("BOM2CofigPart").item(0);	
	
	
	sConfigType2.value = sConfigFlag;
	// Check for Rev Option
		if(NameActual=="BOM1NameDispOID") {	
	Revisionoption2 = targetWindow.document.getElementsByName("RevisionOption1").item(0);
		} else {
	Revisionoption2 = targetWindow.document.getElementsByName("RevisionOption2").item(0);
		}
	
	var sLen = Revisionoption2.length;	
	for(i=0; i < sLen ; i++){
		Revisionoption2.options[0] = null;
	}
	var Effectivity2 = "";
	var editeffectivity = "";	
	var pcEffectivity = "";
	// Check for Effectivity	
			if(NameActual=="BOM1NameDispOID") {	
                     Effectivity2 = targetWindow.document.getElementById("EffectivityPart1_html");
                     editeffectivity = targetWindow.document.getElementById("editeffectivity1");
                     
                     pcEffectivity = targetWindow.document.getElementById("editPCFilter");
                    
			} else {
             Effectivity2 = targetWindow.document.getElementById("EffectivityPart2_html");
             editeffectivity = targetWindow.document.getElementById("editeffectivity");
             
             pcEffectivity = targetWindow.document.getElementById("editPCFilter12");
             
			}

	// Check for Match based on
	reportMatchbasedon = targetWindow.document.getElementsByName("MatchBasedOn").item(0);

	// Check for Report Format
	//reportFormat = targetWindow.document.getElementsByName("Format").item(0);
	reportType= targetWindow.document.getElementsByName("isConsolidatedReport").item(0);
	
	var sCompSummary = targetWindow.document.getElementsByName("CS").item(0);
	var sDiffOnlySummary =  targetWindow.document.getElementsByName("DOS").item(0);
	
	if(sConfigFlag == "true") 
	{
		// For Type1 and Type 2 validations
		
		if (isMBOMInstalled == 'true') 
		{
				if (sType2.options.value == "MBOM")
			{			if(NameActual=="BOM1NameDispOID") {	
				  targetWindow.document.getElementsByName("Deviation1")[0].disabled=true;
	              targetWindow.document.getElementsByName("Deviation1")[1].disabled=true;
	              targetWindow.document.getElementsByName("Plant1Display")[0].style.visibility="hidden";
	              targetWindow.document.getElementsByName("btnPlant1")[0].style.visibility="hidden";
	              targetWindow.document.getElementById("As1").style.visibility="hidden";
	              targetWindow.document.getElementById("AsOn1").style.visibility="hidden";

			} else {
				  targetWindow.document.getElementsByName("Deviation2")[0].disabled=true;
	              targetWindow.document.getElementsByName("Deviation2")[1].disabled=true;
	              targetWindow.document.getElementsByName("Plant2Display")[0].style.visibility="hidden";
	              targetWindow.document.getElementsByName("btnPlant2")[0].style.visibility="hidden";
	              targetWindow.document.getElementById("As2").style.visibility="hidden";
	              targetWindow.document.getElementById("AsOn2").style.visibility="hidden";
				
			}
			}
			sType2.options[1] = null;
		}

    	// For Rev Option
		
		var newOption = targetWindow.document.createElement('OPTION'); 
		newOption.text = strAsStored;
		newOption.value = "As Stored";		

		Revisionoption2.options[Revisionoption2.options.length] = newOption;
		   
		//Check for Effectivity	
		if(Effectivity2 != null && typeof Effectivity2!="undefined") { 
			Effectivity2.style.visibility="visible";
			}
			if(editeffectivity != null && typeof editeffectivity!="undefined") { 
			editeffectivity.style.visibility="visible";
			}
			if(pcEffectivity != null && typeof pcEffectivity!="undefined") { 
				pcEffectivity.style.visibility="visible";
			} 

		//Match based on check
		
		if (reportMatchbasedon.options[0].value == 'Part_Name')
		{
			reportMatchbasedon.options[0]=null;
			reportMatchbasedon.value=reportMatchbasedon.options[0].value;
		}

		// Report Format selection
// 		if(reportFormat.value = "Tabular") {
// 			reportFormat.value = reportFormat.options[0].value;
// 		}
		
	} else {
		// check for Rev Option
		var currRevOpt = Revisionoption2.value;
		var sTypeSelected = sType2.value;

		
		// If EBOM is installed.
		if ( sTypeSelected == "EBOM") {
		var newOption = targetWindow.document.createElement('OPTION'); 
		newOption.text = strLatest;
	    	newOption.value = "Latest";
		Revisionoption2.options[Revisionoption2.options.length] = newOption;

		var newOption1 = targetWindow.document.createElement('OPTION'); 
                newOption1.text = strAsStored;
		newOption1.value = "As Stored";
		Revisionoption2.options[Revisionoption2.options.length] = newOption1;
		}
		
		// IF MBOM is installed
		if (isMBOMInstalled == 'true') {
		
			if (sTypeSelected == "MBOM" ) {
	
			var newOption3 = targetWindow.document.createElement('OPTION'); 
			newOption3.text = sCurrent;
			newOption3.value = "Current";
			Revisionoption2.options[Revisionoption2.options.length] = newOption3;
		
			var newOption4 = targetWindow.document.createElement('OPTION'); 
			newOption4.text = sPending;
			newOption4.value = "Pending";
			Revisionoption2.options[Revisionoption2.options.length] = newOption4;
			
			var newOption5 = targetWindow.document.createElement('OPTION'); 
			newOption5.text = sHistory;
			newOption5.value = "History";
			Revisionoption2.options[Revisionoption2.options.length] = newOption5;
                       }			
			// New option for Type..
			if (sType2.options.length < 2)
			{
				var sType2Option = targetWindow.document.createElement('OPTION'); 
				sType2Option.text = "MBOM";
				sType2Option.value = "MBOM";
	
				sType2.options[sType2.options.length] = sType2Option;
			}
		}
		
		if (currRevOpt != ''){	
			Revisionoption2.value = currRevOpt
		} else {
			Revisionoption2.value = Revisionoption2.options[1].value;
		}
		
		//Check for Effectivity
		if(Effectivity2 != null && typeof Effectivity2!="undefined") { 
		Effectivity2.style.visibility="hidden";
		}
		if(editeffectivity != null && typeof editeffectivity!="undefined") { 
		editeffectivity.style.visibility="hidden";
		}
		if(pcEffectivity != null && typeof pcEffectivity!="undefined") { 
			pcEffectivity.style.visibility="hidden";
		} 

		

		//Match based on check
		reportMatchbasedon.options[0].style.visibility="visible";
		
	}
        // ECC Installed Check    
	}
    if(typeAhead != "true")
             getTopWindow().closeWindow();
}

</script>
<html>
<body onload=setAndRefresh()>
</body>
</html>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


