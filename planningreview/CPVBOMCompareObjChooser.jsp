<%-- 
 ** history:
 *  @fullreview  fl3 gh4 2016/09/19: Creation (3DEXP R2017x)
 *  @quickreview jmm1 gh4 2017/07/04: IR-533290: PPV_FUN070920_VNLS issues with PPV app
 *  @quickreview spl7 gh4 2017/07/26: IR-533599 : Fixed issue of XSS encoding feature
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../components/emxSearchInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<%@page import="com.dassault_systemes.vplm.DELJTypeNAttServices"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>

<html>

<head>
	<title></title>
</head>

<body onload=setAndRefresh()>

	<%
	try {
		String COMPONENT_FRAMEWORK_BUNDLE = "emxComponentsStringResource";
		String ALERT_MSG = "emxComponents.Search.Error.24";
		
		String sFrameName = emxGetParameter(request, Search.REQ_PARAM_FRAME_NAME);
		String sFormName  = emxGetParameter(request, Search.REQ_PARAM_FORM_NAME);
		String sTypeAhead = emxGetParameter(request, "typeAhead");
		
		String sFieldNameDisplay= emxGetParameter(request,"fieldNameDisplay");
		String sFieldNameActual = emxGetParameter(request,"fieldNameActual");
		
		// TODO: In TypeAhead fieldNameOID comes as NULL, reason has to be figured out. But anyways, below workaround can be used
		// since for a given fieldNameActual, say 'Field1' its OID will be always 'Field1OID'. 
		//String sFieldNameOID = XSSUtil.encodeForJavaScript(context, emxGetParameter(request,"fieldNameOID"));
		String sFieldNameOID = sFieldNameActual + "OID";
		
		// We shall not pass 'fieldRevision' from NameURL, instead calculate it based on the 'fieldNameActual' that is selected.
		//String sFieldRevnDisplay = XSSUtil.encodeForJavaScript(context, emxGetParameter(request,"fieldRevision"));
		String sFieldRevnDisplay = "", sFieldPredefActual = "";
		if (sFieldNameActual.contains("BOM1"))
		{
			sFieldRevnDisplay  = "BOM1Revision";
			sFieldPredefActual = "BOM1PredefCfgFilter";
		} 
		else if (sFieldNameActual.contains("BOM2"))
		{
			sFieldRevnDisplay  = "BOM2Revision";
			sFieldPredefActual = "BOM2PredefCfgFilter";
		}
		
		String strTableRowId[] = emxGetParameterValues(request,"emxTableRowId");
		String languageStr = request.getHeader("Accept-Language");
		
		String error = "false";
		String strRetMsg = "";
		String sObjPhysicalId = "";
		String sObjNameDisplay= "";
		String sObjNameActual = "";
		String sObjRevision   = "";
		
		Locale locale = new Locale((String)request.getHeader("Accept-Language"));
		if (strTableRowId == null)
		{
			i18nNow i18nInstance = new i18nNow();
			String strLang = request.getHeader("Accept-Language");
			
			strRetMsg = EnoviaResourceBundle.getProperty(context, COMPONENT_FRAMEWORK_BUNDLE, locale,ALERT_MSG);
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
					String sObjId  = strTokens.nextToken();
					sObjPhysicalId = DELJTypeNAttServices.getPhysicalId(context, sObjId);
					
					Hashtable attValues = DELJTypeNAttServices.getVPLMObjectAttValues(context, sObjPhysicalId);
					sObjNameDisplay = (String) attValues.get("V_Name");
					sObjNameActual = (String) attValues.get(DomainConstants.SELECT_NAME);
					sObjRevision  = (String) attValues.get(DomainConstants.SELECT_REVISION);
					
					/*
					List<String> refAttName = new ArrayList<String>();
					refAttName.add("V_Name");
					refAttName.add(DomainConstants.SELECT_REVISION);
					Map attMap1 = DELJTypeNAttServices.getAttributeValuesByEnoviaID(context, sObjPhysicalId, refAttName);
					
					sObjName = (String) attMap1.get("V_Name");
					sObjRev  = (String) attMap1.get(DomainConstants.SELECT_REVISION);
					*/
				}
			}
		} // Else: if (strTableRowId == null)
	
		%>
		<script language="javascript" type="text/javaScript">
			var typeAhead = "<%=XSSUtil.encodeForJavaScript(context,sTypeAhead)%>";
			
			var targetWindow = null;
			if (typeAhead == "true") 
			{
				var frameName = "<%=XSSUtil.encodeForJavaScript(context, sFrameName)%>";
			    if (frameName != "")
			        targetWindow = getTopWindow().findFrame(window.parent, "<xss:encodeForJavaScript><%=sFrameName%></xss:encodeForJavaScript>");
			    else
			        targetWindow = window.parent;
			}
			else
			{
			    targetWindow = getTopWindow().getWindowOpener();
			}
			
			function setAndRefresh()
			{
				var strFormName = "<%=XSSUtil.encodeForJavaScript(context, sFormName)%>";
				var strFieldNameDisplay= "<%=XSSUtil.encodeForJavaScript(context, sFieldNameDisplay)%>";
				var strFieldNameActual = "<%=XSSUtil.encodeForJavaScript(context, sFieldNameActual)%>";
				var strFieldNameOID    = "<%=XSSUtil.encodeForJavaScript(context, sFieldNameOID)%>";
				var strFieldRevDisplay = "<%=XSSUtil.encodeForJavaScript(context, sFieldRevnDisplay)%>";
								
				var sNameDisplayValue  = "<%=XSSUtil.encodeForJavaScript(context, sObjNameDisplay)%>";
				var sNameActualValue   = "<%=XSSUtil.encodeForJavaScript(context, sObjNameActual)%>";
				var sNameOIDValue      = "<%=XSSUtil.encodeForJavaScript(context, sObjPhysicalId)%>"
				var sRevDisplayValue   = "<%=XSSUtil.encodeForJavaScript(context, sObjRevision)%>";
				
				var strFieldPredefActual = "<%=XSSUtil.encodeForJavaScript(context, sFieldPredefActual)%>";
				var strFieldPredefOID    = "<%=XSSUtil.encodeForJavaScript(context, sFieldPredefActual)%>" + "OID";
				var strFieldPredefDisplay= "<%=XSSUtil.encodeForJavaScript(context, sFieldPredefActual)%>" + "Display";
				
				var elementCount;
				for (var i=0; i < targetWindow.document.forms.length; i++)
				{
					if (targetWindow.document.forms[i].name == strFormName)
					{
						elementCount = i;
						break;
					}
				}
				
				{
					// Get Name field controls
					var vFieldNameDisplay= targetWindow.document.forms[elementCount].elements[strFieldNameDisplay];
					var vFieldNameActual = targetWindow.document.forms[elementCount].elements[strFieldNameActual];
					var vFieldNameOID    = targetWindow.document.forms[elementCount].elements[strFieldNameOID];
					
					// Set value for Name field controls
					vFieldNameDisplay.value= sNameDisplayValue;
					vFieldNameActual.value = sNameActualValue;
					vFieldNameOID.value    = sNameOIDValue;
					
					
					// Get Revn Field control & set its value
					var vFieldRevDisplay   = targetWindow.document.forms[elementCount].elements[strFieldRevDisplay];
					vFieldRevDisplay.value = sRevDisplayValue;					
					
					
					// Get PredefCfgFilter field controls
					var vFieldPreDefDisplay= targetWindow.document.forms[elementCount].elements[strFieldPredefDisplay];
					var vFieldPreDefActual = targetWindow.document.forms[elementCount].elements[strFieldPredefActual];
					var vFieldPreDefOID    = targetWindow.document.forms[elementCount].elements[strFieldPredefOID];
					
					// Set value for PredefCfgFilter field controls
					vFieldPreDefDisplay.value = "";
					vFieldPreDefActual.value  = "";
					vFieldPreDefOID.value = "";
					
					
					// Enable Swap button when both Name feilds are populated.
					var displayValue1 = targetWindow.document.forms[elementCount].elements["BOM1NameDisplay"].value;
					var displayValue2 = targetWindow.document.forms[elementCount].elements["BOM2NameDisplay"].value;
					if (!(displayValue1 == null || displayValue1 == "") && !(displayValue2 == null || displayValue2 == ""))
						 targetWindow.document.forms[elementCount].elements["swapPPRObjects"].disabled = false;
					
				}
					
				
				if (typeAhead != "true")
			       getTopWindow().closeWindow();
				
				
			} // fun: setAndRefresh
		
		</script>
	<%
	} // try block
	catch (Exception e)
	{
		session.putValue("error.message", e.toString());
	}	
	%>
</body>
	
</html>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
