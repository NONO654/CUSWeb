<%-- 
 ** history:
 *  @fullreview  fl3 gh4 2016/09/19: Creation (3DEXP R2017x)
 *  @quickreview gh4 gh4 2017/06/15: FUN070920: BOMCompare changes for 'Instance' MatchBasedOn criteria
 *  @quickreview jmm1 gh4 2017/07/04: IR-533290: PPV_FUN070920_VNLS issues with PPV app
--%>

<%--  CPVBOMCompareSubmit.jsp   -    Post Process JSP for structure compare webform, directs based on user selection to tabular report or visual report jsp.
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@ page import="com.matrixone.apps.domain.*" %>

<%@ page import="java.lang.reflect.*" %>
<%@ page import="com.matrixone.apps.domain.util.*,com.matrixone.apps.framework.ui.*"%>
<%@ page import="com.dassault_systemes.vplm.DELJConstants"%>

<jsp:useBean id="SCTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>

<%
	String sResBundle = "emxVPLMProcessEditorStringResource";
	Map exportSubHeader = new com.matrixone.jsystem.util.MxLinkedHashMap();
	
	Locale locale = new Locale((String)request.getHeader("Accept-Language"));
		
	// Get TimeStamp value
	String sSCTimeStamp = emxGetParameter(request, "SCTimeStamp");
	try {
		SCTableBean = (UIStructureCompare) structureCompareBean;
		HashMap sessionValueMap = (HashMap) ((UIStructureCompare) SCTableBean).getSCCriteria(sSCTimeStamp);
		sessionValueMap.put("CriteriaHeader", exportSubHeader);
		((UIStructureCompare) SCTableBean).setStructureCompareCriteria(sSCTimeStamp, sessionValueMap);
	} catch (Exception e) {
		e.printStackTrace();
	}
	
	// Get object Type value
	//String sPPRObjTypeDisplay = emxGetParameter(request, DELJConstants.PPR_OBJECT_TYPE);
	String sPPRObjTypeActual = emxGetParameter(request, DELJConstants.PPR_OBJECT_TYPE);
	sPPRObjTypeActual = sPPRObjTypeActual.substring(0, sPPRObjTypeActual.indexOf("?"));
	
	String sSystemLabel = "emxVPLMProcessEditor.CommandLabel.System";
	String sManItemLabel = "emxVPLMProcessEditor.CommandLabel.ManufItem";	
	String sSystemLabelLocale = EnoviaResourceBundle.getProperty(context, sResBundle, locale, sSystemLabel);
	String sManItemLabelLocale = EnoviaResourceBundle.getProperty(context, sResBundle, locale, sManItemLabel);
	
	String sNameLabel = "";
	if (DELJConstants.PPR_OBJECT_PROCESS.equals(sPPRObjTypeActual)) {
		sNameLabel = sManItemLabelLocale;
	}
	else if (DELJConstants.PPR_OBJECT_SYSTEM.equals(sPPRObjTypeActual)) {
		sNameLabel = sSystemLabelLocale;
	}
	
	
	// Get object's other values
	String sName1 = emxGetParameter(request, "BOM1NameDisplay");
	String sObjectId1 = emxGetParameter(request, "BOM1NameOID");
	String sPreCfgFilter1 = emxGetParameter(request, "BOM1PredefCfgFilter");
	
	String sName2 = emxGetParameter(request, "BOM2NameDisplay");
	String sObjectId2 = emxGetParameter(request, "BOM2NameOID");
	String sPreCfgFilter2 = emxGetParameter(request, "BOM2PredefCfgFilter");
	
	String sObjectId = sObjectId1 + "," + sObjectId2;
	
	
	// Get Report n Match criteria
	String sExpandMode = emxGetParameter(request, "ExpandMode");
	String sExpandLevel = emxGetParameter(request, "ExpandLevel");
	
	String sSelectedReportFormat = emxGetParameter(request, "ReportFormat");
	String sSelectedReportFormatEnglish = EnoviaResourceBundle.getProperty(context, sResBundle, new Locale("en"), sSelectedReportFormat);
	String sSelectedReportFormatLocale = EnoviaResourceBundle.getProperty(context, sResBundle, locale, sSelectedReportFormat);
	String sReportFormatLabelLocale = EnoviaResourceBundle.getProperty(context, sResBundle, locale,"emxVPLMProcessEditor.BOMCompare.ReportFormat");
	
	String sSelectedMatchBasedOn = emxGetParameter(request, "MatchBasedOn");
	String sSelectedMatchBasedOnEnglish = EnoviaResourceBundle.getProperty(context, sResBundle, new Locale("en"), sSelectedMatchBasedOn);
	String sSelectedMatchBasedOnLocale = EnoviaResourceBundle.getProperty(context, sResBundle, locale, sSelectedMatchBasedOn);
	String sMatchBasedOnLabelLocale = EnoviaResourceBundle.getProperty(context, sResBundle, locale,"emxVPLMProcessEditor.BOMCompare.MatchBasedOn");
	
	String sReportDiffByLabelLocale = EnoviaResourceBundle.getProperty(context, sResBundle, locale,"emxVPLMProcessEditor.BOMCompare.ReportDifferencesBy");
	String str3dPlayEnabled = EnoviaResourceBundle.getProperty(context, "emxComponents.Toggle.3DViewer");
	String sReportType = emxGetParameter(request, "reportType");
	String reportFrame = ("Difference_Only_Report".equals(sReportType)) ? 
					"AEFSCDifferenceOnlyReport" : ("Common_Report".equals(sReportType)) ? 
					"AEFSCCompareCommonComponents" : ("Unique_toLeft_Report".equals(sReportType)) ? 
					"AEFSCBOM1UniqueComponentsReport" : ("Unique_toRight_Report".equals(sReportType)) ? 
					"AEFSCBOM2UniqueComponentsReport" : "AEFSCCompleteSummaryResults";
	
	
	// Prepare ReportFormat Values
	String sIsConsolidated = "Yes";
	if (sSelectedReportFormat.equalsIgnoreCase("emxVPLMProcessEditor.BOMCompare.StructuredReport"))
		sIsConsolidated = "No";
	
	
	// Prepare MatchBasedOn Values
	String sVal = sSelectedMatchBasedOnEnglish.replace(' ', '_');
	sVal = StringUtils.replace(sVal, "_+_", "_");
	sSelectedMatchBasedOnEnglish = sVal;
	
	// Note1: Coulmn values assigned below should be those values defined for 'name' field in the
	// Basics section of corresponding columns in expand table. In our case, table is CPVBOMCompareExpandTable
	// Note2: The spaces and plus signs of MatchBasedOn label are replaced with underscore. Thus, for ex
	// "Instance + Reference Name" should be treated as "Instance_Reference_Name"
	String sColumnName1 = "None";
	String sColumnName2 = "None";
	if ("Reference_Title".equals(sSelectedMatchBasedOnEnglish)) 
	{
		sColumnName1 = "ReferenceTitle";
		sColumnName2 = "None";
	} 
	else if ("Reference_Name".equals(sSelectedMatchBasedOnEnglish)) 
	{
		sColumnName1 = "ReferenceName";
		sColumnName2 = "None";
	}	
	else if ("Instance_Name".equals(sSelectedMatchBasedOnEnglish)) 
	{
		sColumnName1 = "InstanceName";
		sColumnName2 = "None";
	}
	else if( "Instance".equals(sSelectedMatchBasedOnEnglish))
	{
		sColumnName1 = "InstanceLID";
		sColumnName2 = "None";
	}
	else if("Instance_Reference_Name".equals(sSelectedMatchBasedOnEnglish))
	{
		sColumnName1 = "InstanceLID";
		sColumnName2 = "ReferenceName";
	}
	
	String selectedMatchBasedInternal = sColumnName1;
	if (!"None".equals(sColumnName2)) 
	{
		selectedMatchBasedInternal = selectedMatchBasedInternal + ", " + sColumnName2;
	}
	
	
	// Prepare Report Differences By values
	String sReference_Title = emxGetParameter(request, "Reference_Title");
	String sReference_Name = emxGetParameter(request, "Reference_Name");
	String sInstanceName = emxGetParameter(request, "Instance_Name");
	String sEstimatedTime= emxGetParameter(request, "Estimated_Time");
	String sMeasuredTime = emxGetParameter(request, "Measured_Time");
	
	String sType = emxGetParameter(request, "Type");
	String sRevn = emxGetParameter(request, "Revision");
	String sQty  = emxGetParameter(request, "Quantity");
		
	String sCheckBox = "";
	String sRepDffBylabel = "";
	if (sReference_Title != null) {
		String sLangValue = EnoviaResourceBundle.getProperty(context, sResBundle, locale, "emxVPLMProcessEditor.BOMCompare.ReferenceTitle");
		sRepDffBylabel = sRepDffBylabel + sLangValue + ", ";
		sCheckBox = sCheckBox + "ReferenceTitle,";
	}
	if (sReference_Name != null) {
		String sLangValue = EnoviaResourceBundle.getProperty(context, sResBundle, locale, "emxVPLMProcessEditor.BOMCompare.ReferenceName");
		sRepDffBylabel = sRepDffBylabel + sLangValue + ", ";
		sCheckBox = sCheckBox + "ReferenceName,";
	}
	if (sInstanceName != null) {
		String sLangValue = EnoviaResourceBundle.getProperty(context, sResBundle, locale, "emxVPLMProcessEditor.BOMCompare.InstanceName");
		sRepDffBylabel = sRepDffBylabel + sLangValue + ", ";
		sCheckBox = sCheckBox + "InstanceName,";
	}
	
	if (sRevn != null) {
		String sLangValue = EnoviaResourceBundle.getProperty(context, sResBundle, locale, "emxVPLMProcessEditor.Common.Rev");
		sRepDffBylabel = sRepDffBylabel + sLangValue + ", ";
		sCheckBox = sCheckBox + "Rev,";
	}
	if (sType != null) {
		String sLangValue = EnoviaResourceBundle.getProperty(context, sResBundle, locale, "emxVPLMProcessEditor.Common.Type");
		sRepDffBylabel = sRepDffBylabel + sLangValue + ", ";
		sCheckBox = sCheckBox + "Type,";
	}
	if (sQty != null) {
		String sLangValue = EnoviaResourceBundle.getProperty(context, sResBundle, locale, "emxVPLMProcessEditor.Common.Qty");
		sRepDffBylabel = sRepDffBylabel + sLangValue + ", ";
		sCheckBox = sCheckBox + "Qty,";
	}

	if (sEstimatedTime != null) {
		String sLangValue = EnoviaResourceBundle.getProperty(context, sResBundle, locale, "emxVPLMProcessEditor.Common.EstimatedTime");
		sRepDffBylabel = sRepDffBylabel + sLangValue + ", ";
		sCheckBox = sCheckBox + "EstimatedTime,";
	}
	if (sMeasuredTime != null) {
		String sLangValue = EnoviaResourceBundle.getProperty(context, sResBundle, locale, "emxVPLMProcessEditor.Common.MeasuredTime");
		sRepDffBylabel = sRepDffBylabel + sLangValue + ", ";
		sCheckBox = sCheckBox + "MeasuredTime,";
	}
	
	if (UIUtil.isNotNullAndNotEmpty(sRepDffBylabel)) {
		sRepDffBylabel = sRepDffBylabel.substring(0, sRepDffBylabel.length() - 2);
	}
	
	// Default value for compareBy, if None selected
	if ("".equals(sCheckBox)) {
		String sLangValue = EnoviaResourceBundle.getProperty(context, sResBundle, locale, "emxVPLMProcessEditor.BOMCompare.ReferenceTitle");
		sRepDffBylabel = sRepDffBylabel + sLangValue;
		sCheckBox = "ReferenceTitle";
	}
	String sCompareBy = sCheckBox.substring(0, sCheckBox.length() - 1);
	
	
	// Add the labels & corresponding values to the Report header\sub-header 
	exportSubHeader.put(sNameLabel + "-1", sName1);
	exportSubHeader.put(sNameLabel + "-2", sName2);		
	
	exportSubHeader.put(sMatchBasedOnLabelLocale, sSelectedMatchBasedOnLocale);
	exportSubHeader.put("| " + sReportFormatLabelLocale, sSelectedReportFormatLocale);
	
	if(UIUtil.isNotNullAndNotEmpty(sRepDffBylabel)) {
		exportSubHeader.put(sReportDiffByLabelLocale, sRepDffBylabel);
  	}
	
%>
	
	
<body>
	<form name="BOMComparePL" method="post" id="BOMComparePL">
		
		<input type="hidden" name="table"   		value="CPVBOMCompareExpandTable" />
		<input type="hidden" name="expandProgram" 	value="DELJPlanningExpandUtil:expandPPRItemForBOMCompare" />
		<input type="hidden" name="SuiteDirectory" 	value="planningreview" />
		<input type="hidden" name="suiteKey" 		value="VPLMProcessEditor" />
		<input type="hidden" name="StringResourceFileId" value="emxVPLMProcessEditorStringResource" />
				
		<input type="hidden" name="languageStr" value="en-us"/>
		<input type="hidden" name="charSet" 	value="UTF8" />
		<input type="hidden" name="portalMode"  value="false"/>
		<input type="hidden" name="hideHeader"  value="true" />
		<input type="hidden" name="autoFilter" 	value="false"/> 
		<input type="hidden" name="rowGrouping" value="false"/>
		<input type="hidden" name="customize" 	value="true" />
		<input type="hidden" name="viewMode" 	value="true" />  <!-- To hide Save\Cancel btns (CompareApplyButton\CompareResetButton -> in emxUIFreezePane.js)  -->
		<input type="hidden" name="selection" 	value="none" />  <!-- To hide check-box or radio in rows -->
		<input type="hidden" name="uiType" 		value="StructureBrowser" />
		<input type="hidden" name="HelpMarker" 	value="emxhelp_structurecomparereport" />
		
		<input type="hidden" name="objectCompare" 	value="false" />
		<input type="hidden" name="showClipboard" 	value="false" />
		<input type="hidden" name="SCTimeStamp" 	value="<xss:encodeForHTMLAttribute><%=sSCTimeStamp%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="isConsolidatedReport" value="<xss:encodeForHTMLAttribute><%=sIsConsolidated%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="IsStructureCompare"   value="TRUE" />
		
		<input type="hidden" name="compareBy"   	value="<xss:encodeForHTMLAttribute><%=sCompareBy%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="matchBasedOn" 	value="<xss:encodeForHTMLAttribute><%=selectedMatchBasedInternal%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="compareLevel" 	value="<xss:encodeForHTMLAttribute><%=sExpandLevel%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="expandLevel" 	value="<xss:encodeForHTMLAttribute><%=sExpandLevel%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="emxExpandFilter" value="<xss:encodeForHTMLAttribute><%=sExpandLevel%></xss:encodeForHTMLAttribute>" />
		
		<input type="hidden" name="reportType" 		value="<xss:encodeForHTMLAttribute><%=sReportType%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="cbox_Value" 		value="<xss:encodeForHTMLAttribute><%=sCheckBox%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="firstColumn" 	value="<xss:encodeForHTMLAttribute><%=sColumnName1%></xss:encodeForHTMLAttribute>" />		          
		<input type="hidden" name="secondColumn" 	value="<xss:encodeForHTMLAttribute><%=sColumnName2%></xss:encodeForHTMLAttribute>" />
		
		<input type="hidden" name="objectId"     	value="<xss:encodeForHTMLAttribute><%=sObjectId%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="PPRObjectType" 	value="<xss:encodeForHTMLAttribute><%=sPPRObjTypeActual%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="expandMode" 		value="<xss:encodeForHTMLAttribute><%=sExpandMode%></xss:encodeForHTMLAttribute>" />		
		<input type="hidden" name="Left_PredefCfgFilter" 	value="<xss:encodeForHTMLAttribute><%=sPreCfgFilter1%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="Right_PredefCfgFilter" 	value="<xss:encodeForHTMLAttribute><%=sPreCfgFilter2%></xss:encodeForHTMLAttribute>" />
		
		<% 
		if("true".equalsIgnoreCase(str3dPlayEnabled)){
			%>
			<input type="hidden" name="selectHandler" 	value="highlightCompareItem3dPlay"/>
			<%  
		} else {
			%>
			<input type="hidden" name="selectHandler" 	value="highlightCompareItem"/>
			<% 
		}
		%>
		
	</form>
</body>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<script>
	var resultTargetFrame = getTopWindow().findFrame(getTopWindow(),"<xss:encodeForJavaScript><%=reportFrame%></xss:encodeForJavaScript>");
	
	this.document.forms["BOMComparePL"].target = resultTargetFrame.name;
	this.document.forms["BOMComparePL"].method = "post";
    this.document.forms["BOMComparePL"].action = "../common/emxIndentedTable.jsp?IsStructureCompare=TRUE&displayView=details,thumbnail&hideLifecycleCommand=true";
    this.document.forms["BOMComparePL"].submit();

</script>

