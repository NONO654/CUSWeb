<%--  emxRequirementsComparePostProcess.jsp   -    Post Process JSP for structure compare webform, directs based on user selection to tabular report or visual report jsp.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%-- 
	@fullreview 	KIE1 ZUD 17:06:06  IR-517222-3DEXPERIENCER2018x : There is no Select All option in Requirement Specifications Structure Compare page
    @Quickreview 	     ZUD 18:09:18  IR-621057-3DEXPERIENCER2017x : Not possible to execute "Sync to Right" and "Sync to Left" since no checkboxes available
    @Quickreview 	KIE1 ZUD 18:10:08  IR-619892-3DEXPERIENCER2017x : Requirement structure compare result is different for English & Japanese language
--%>


<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@ page import="com.matrixone.apps.domain.*" %>

<%@ page import="java.lang.reflect.*" %>
<%@ page import="com.matrixone.apps.domain.util.*,com.matrixone.apps.framework.ui.*"%>

<jsp:useBean id="SCTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>

<%
	String language = request.getHeader("Accept-Language");
	String sCompareStructure = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.Heading.StructureCompare");
	String sReportFormatLabel = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.Requirement_Compare.ReportFormat");
	
	String sMatBasedOn = "";
	String sReportFormat = "";

	Map exportSubHeader = new com.matrixone.jsystem.util.MxLinkedHashMap();
	
	String languageStr = request.getHeader("Accept-Language");
	String sTimeStamp 		= emxGetParameter(request, "SCTimeStamp");
	
	try {
		SCTableBean = (com.matrixone.apps.framework.ui.UIStructureCompare)structureCompareBean;
		HashMap sessionValueMap = (HashMap)((com.matrixone.apps.framework.ui.UIStructureCompare)SCTableBean).getSCCriteria(sTimeStamp);
		sessionValueMap.put("CriteriaHeader", exportSubHeader);
		((com.matrixone.apps.framework.ui.UIStructureCompare)SCTableBean).setStructureCompareCriteria(sTimeStamp, sessionValueMap);
	} catch (Exception e) {
		e.printStackTrace();
	}
	
	String sName1			= emxGetParameter(request, "RSP1Name");
	String sObjectId1 		= emxGetParameter(request, "RSP1NameDispOID");
	
	if(sObjectId1==null||sObjectId1.length()==0)
    	sObjectId1 = emxGetParameter(request,"RSP1NameOID");
   	
    String sSCTimeStamp 		= emxGetParameter(request,"SCTimeStamp");
	String sName2		= emxGetParameter(request,"RSP2Name");
	String sObjectId2 	= emxGetParameter(request,"RSP2NameDispOID");
   
    if(sObjectId2==null||sObjectId2.length()==0)
    	sObjectId2 = emxGetParameter(request,"RSP2NameOID");
   
   	String sExpandLevel = emxGetParameter(request,"ExpandLevel");
   	
   	//Start: HAT1 ZUD: IR-634098-3DEXPERIENCER2019x fix
   	String strExpandLevel = sExpandLevel;
   	if("0".equals(sExpandLevel))
   		strExpandLevel = "All";
   	//End: HAT1 ZUD: IR-634098-3DEXPERIENCER2019x fix

    String sFormat = emxGetParameter(request,"Format");
    String sParent				= emxGetParameter(request,"parent");
    String strIsConsolidated= emxGetParameter(request,"isConsolidatedReport");
    String sMatchBasedOnLabel = emxGetParameter(request,"MatchBasedOn");
    String sMatchBasedOnLabel1 = emxGetParameter(request,"MatchBasedOn1");
    String sMatchBasedOnLabel2 = emxGetParameter(request,"MatchBasedOn2");
    
    String sRsp = emxGetParameter(request,"Name");
    
    String sRev = emxGetParameter(request,"Revision");
    
    String sType = emxGetParameter(request,"Type");
    
    String sRelType = emxGetParameter(request,"Relationship_Type");
    
    String sStatus= emxGetParameter(request,"Status");
    
    String sClassification = emxGetParameter(request,"Classification");
    
    String sTitle  = emxGetParameter(request,"Title");
    
    String sDescription  = emxGetParameter(request,"Description");
    
    String sPriority = emxGetParameter(request,"Priority");
    
    String sContextText = emxGetParameter(request,"Content_Text");
    
	String sParaType  = emxGetParameter(request,"Parameter_type");
    
	String sParaValue  = emxGetParameter(request,"Parameter_value");
    
    String sTargetPageURL    = null;
	String pageHeading  = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.Common.Details"); 

   if (sObjectId1 == null || sObjectId1.length() <= 0 || sObjectId1.equals("null"))	{
		sObjectId1 = emxGetParameter(request,"objectId");
	}
	if (sName1 == null || sName1.length() <= 0 || sName1.equals("null"))	{
		sName1 = emxGetParameter(request,"RSP1Name");
	}
	if (sName2 == null || sName2.length() <= 0 || sName2.equals("null"))	{
		sName2 = emxGetParameter(request,"RSP2Name");
	}
	String objectId = sObjectId1+","+sObjectId2;
	String sReportType = emxGetParameter(request, "reportType");
	
	String sColumnName1 = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", new Locale("en"),sMatchBasedOnLabel);
	String sColumnName2 =EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", new Locale("en"),sMatchBasedOnLabel1); 
	String sColumnName3 = "None";
	
	if(null != sMatchBasedOnLabel2)
	{
		sColumnName3 = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", new Locale("en"),sMatchBasedOnLabel2);
	}
		
	String strMatchBasedOn = sColumnName1;

	if (!"None".equals(sColumnName2))
	{
		strMatchBasedOn = strMatchBasedOn + "," + sColumnName2;
	}
	if (!"None".equals(sColumnName3) 
			&& !"null".equalsIgnoreCase(sColumnName3)
			&& null != sColumnName3)
	{
		strMatchBasedOn = strMatchBasedOn + "," + sColumnName3;
	}
	String sCheckBox = "";
	String sRepDffBylabel = "";	
	if (sRsp != null)
	{
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Rsp_Name");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Name,";
	}
	if (sRev != null)
	{
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Revision");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Revision,";
	}
	if (sType != null)
    {
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Type");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
    	sCheckBox = sCheckBox + "Type,";
    }
	
	if (sRelType != null)
	{
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Relation_type");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Relationship Type,";
	}
	if (sStatus != null)
	{
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Status");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Status,";
	}
	if (sClassification != null)
	{
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Calssfication");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Classification,";
	}
	if (sTitle != null)
	{
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Title");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Title,";
	}
	if (sDescription != null)
	{
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Description");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Description,";
	}
	if (sPriority != null)
	{
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Priority");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Priority,";
	}
	if (sContextText != null)
	{
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Content_text");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Content Text,";
	}
  
    if (sParaType != null)
	{
    	String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Para_type");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Parameter type,";
	}
	if (sParaValue != null)
	{
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Para_value");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Parameter value,";
	}
	if(UIUtil.isNotNullAndNotEmpty(sRepDffBylabel)) {
	sRepDffBylabel = sRepDffBylabel.substring(0, sRepDffBylabel.length()-1);
	}
 
	if ("".equals(sCheckBox))
	{
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.TRMCompareForm.Rsp_Name");
		sRepDffBylabel = sRepDffBylabel+sLangValue;
		sCheckBox = "Name,";
	}
	
	String scompareBy = sCheckBox.substring(0,sCheckBox.length() -1);
	
	String reportFrame = ("Difference_Only_Report".equals(sReportType)) ? "AEFSCDifferenceOnlyReport" : ("Common_Report".equals(sReportType)) ? "AEFSCCompareCommonComponents" : ("Unique_toLeft_Report".equals(sReportType)) ? "AEFSCBOM1UniqueComponentsReport" : ("Unique_toRight_Report".equals(sReportType)) ? "AEFSCBOM2UniqueComponentsReport" : "AEFSCCompleteSummaryResults";
	
	
	DomainObject doObj1 = new DomainObject(sObjectId1);
	DomainObject doObj2 = new DomainObject(sObjectId2);
	String sObj1Name = "";
	String sObj2Name = "";
	
	sObj1Name = doObj1.getInfo(context, DomainConstants.SELECT_NAME);
	sObj2Name = doObj2.getInfo(context, DomainConstants.SELECT_NAME);
	
	%>
		
<body>
	<form name="RSPComparePL" method="post" id="RSPComparePL">
				  
	  <input type="hidden" name="table" value="RMTSpecStructureCompare" />
	  <input type="hidden" name="toolbar" value="AEFStructureCompareToolbar" />				  
	  <input type="hidden" name="compareLevel" value="<xss:encodeForHTMLAttribute><%=sExpandLevel%></xss:encodeForHTMLAttribute>" />
	  <input type="hidden" name="connectionProgram" value="emxSpecificationStructureBase:validateStructureCompare" />
  	  <input type="hidden" name="expandProgram" value="emxSpecificationStructure:expandTreeWithParametersPreference" />
	  <input type="hidden" name="compareBy" value="<xss:encodeForHTMLAttribute><%=scompareBy%></xss:encodeForHTMLAttribute>" />
	  <input type="hidden" name="matchBasedOn" value="<xss:encodeForHTMLAttribute><%=strMatchBasedOn%></xss:encodeForHTMLAttribute>" />
	  
	  <input type="hidden" name="SCTimeStamp" value="<xss:encodeForHTMLAttribute><%=sSCTimeStamp%></xss:encodeForHTMLAttribute>" />
	  <input type="hidden" name="IsStructureCompare" value="TRUE" />
      <input type="hidden" name="portalMode" value="false" />
      <input type="hidden" name="hideHeader" value="true" />
      <input type="hidden" name="autoFilter" value="false" /> 
      <input type="hidden" name="expandFilter" value="true" /> 
      <input type="hidden" name="rowGrouping" value="false" />
      <input type="hidden" name="emxExpandFilter" value="<xss:encodeForHTMLAttribute><%=sExpandLevel%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="strExpandLevel" value="<xss:encodeForHTMLAttribute><%=sExpandLevel%></xss:encodeForHTMLAttribute>" />
      		          
      <input type="hidden" name="compare" value="compareBy" />
      <input type="hidden" name="selTypeDisp1" value="<xss:encodeForHTMLAttribute><%=sName1%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="selTypeDisp" value="<xss:encodeForHTMLAttribute><%=sName2%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="matchColumns" value="[Name, Revision, Type, Relationship Type, Status, Classification, Title, Description, Priority, Content Text, Parameter value, Parameter type]" />
      <input type="hidden" name="objectCompare" value="false" />           
      <input type="hidden" name="CompareBy" value="Revision" />
      <input type="hidden" name="objectIds" value="<xss:encodeForHTMLAttribute><%=sObjectId1%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="cbox_Value" value="<xss:encodeForHTMLAttribute><%=sCheckBox%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="uiType" value="StructureBrowser" />
      <input type="hidden" name="firstColumn" value="<xss:encodeForHTMLAttribute><%=sColumnName1%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="suiteKey" value="Requirements" />
      <input type="hidden" name="HelpMarker" value="emxhelpspecificationstructureview" /> 
      <input type="hidden" name="showClipboard" value="false" /> 
      <input type="hidden" name="reportType" value="<xss:encodeForHTMLAttribute><%=sReportType%></xss:encodeForHTMLAttribute>" />		          
      <input type="hidden" name="secondColumn" value="<xss:encodeForHTMLAttribute><%=sColumnName2%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="reportType" value="<xss:encodeForHTMLAttribute><%=sReportType%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="customize" value="false" />
      
      <input type="hidden" name="thirdColumn" value="<xss:encodeForHTMLAttribute><%=sColumnName3%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="isConsolidatedReport" value="<xss:encodeForHTMLAttribute><%=strIsConsolidated%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="expandLevel" value="<xss:encodeForHTMLAttribute><%=strExpandLevel%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="direction" value="from" />
      <input type="hidden" name="relationship" value="*" />
      
      <input type="hidden" name="languageStr" value="en-us" />
      <input type="hidden" name="charSet" value="UTF8" />
      <input type="hidden" name="SuiteDirectory" value="common" />
      <input type="hidden" name="StringResourceFileId" value="emxRequirementsStringResource" />
      <input type="hidden" name="selectHandler" value="highlightCompareItem"/>
  
	  <%
	    	exportSubHeader.put(sCompareStructure+" 1", sObj1Name);
	    	exportSubHeader.put(sCompareStructure+" 2", sObj2Name);
	    	
			    %>
			    	  <input type="hidden" name="toolbar" value="AEFStructureCompareToolbar" />
			          <input type="hidden" name="strObjectId1" value="<xss:encodeForHTMLAttribute><%=sObjectId1%></xss:encodeForHTMLAttribute>" />
			          <input type="hidden" name="strObjectId2" value="<xss:encodeForHTMLAttribute><%=sObjectId2%></xss:encodeForHTMLAttribute>" />
			          <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=sObjectId1%></xss:encodeForHTMLAttribute>,<xss:encodeForHTMLAttribute><%=sObjectId2%></xss:encodeForHTMLAttribute>" />
	          <%
	
	  exportSubHeader.put(sReportFormatLabel, sReportFormat);
	
	  String sMatchBasedOnLabel3 =EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),sMatchBasedOnLabel); 
	
	  exportSubHeader.put(EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.label.MatchBasedOn"), sMatchBasedOnLabel3);
		  if(UIUtil.isNotNullAndNotEmpty(sRepDffBylabel)) {
				exportSubHeader.put(EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),"emxRequirements.label.CompareBy"), sRepDffBylabel);
	  }
	 %>

	</form>
</body>  
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script>
	var resultTargetFrame = getTopWindow().parent.findFrame(getTopWindow(),"<xss:encodeForJavaScript><%=reportFrame%></xss:encodeForJavaScript>");
	
	this.document.forms["RSPComparePL"].target = resultTargetFrame.name;
	this.document.forms["RSPComparePL"].method = "post";
    this.document.forms["RSPComparePL"].action = "../common/emxIndentedTable.jsp?IsStructureCompare=TRUE&displayView=details,thumbnail&hideLifecycleCommand=true&selection=multiple";
    this.document.forms["RSPComparePL"].submit();

</script>
