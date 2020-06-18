<%--
  TraceabilityOptions.jsp

  Copyright (c) 2007-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program.
--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet--%>
<%--
@quickreview OEP DJH 24-DEC-2012(HF-203808V6R2012x_-Target Specifications field is not visible on Traceability Report Options)
@quickreview OEP DJH 15-JAN-2012(IR-203808V6R2014 -Target Specifications field is not visible on Traceability Report Options)
@Changes made for IR-203808V6R2014 are same as changes done for IR HF-203808V6R2012x_
@quickreview JX5 Correct NLS issue
@quickreview HAT1 ZUD 28-JUN-2017   IR-528929-3DEXPERIENCER2018x: R420-FUN067990: "Target Specification" option from Requirement Traceability window, should not be Mandatory.
@quickreview HAT1 ZUD 28-JUN-2017   IR-528931-3DEXPERIENCER2018x: R420-FUN067990: Requirement Traceability option is KO.  
@quickreview KIE1 ZUD 23-AUG-2017 : IR-541446-3DEXPERIENCER2018x: Submit button from Tractability window is not translated.  
@quickreview HAT1 ZUD 17:12:22 : IR-531745-3DEXPERIENCER2018x: R20-NLS: Name and Revision on the Traceability windows is No Translated.
@quickreview HAT1 ZUD 16-FEB-2018 : IR-579219-3DEXPERIENCER2018x: When select Derivation Traceability Matrix - Next button is not displayed. 
--%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxTagLibInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>

<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
	var reportCount = "";
	function validateForm(reportCount)
	{
		var fullHref = "";
		if (document.myForm.reportHref.length)
		{
			for (ii = 0; ii < document.myForm.reportHref.length; ii++) 
			{
				if (document.myForm.reportHref[ii].checked) 
					fullHref = document.myForm.reportHref[ii].value;
			}
		}
		else
		{
			fullHref = document.myForm.reportHref.value;
		}

		var baseline = "";
		var baselineName = "";
		var nonBaselineNames = "";
		var sourceNames = "";
		
		if (document.myForm.baseline != null && document.myForm.baseline != "undefined")
		{
			if (document.myForm.baseline.length)
			{
				for (ii = 0; ii < document.myForm.baseline.length; ii++) 
				{
					if (document.myForm.baseline[ii].checked) 
					{
						baseline = document.myForm.baseline[ii].value;
						baselineName = document.myForm.baseline[ii].title;
					}
					else
					{
						if (nonBaselineNames == "")
							nonBaselineNames = document.myForm.baseline[ii].title;
						else
							nonBaselineNames = nonBaselineNames + ", " + document.myForm.baseline[ii].title;
					}
				}
			}
			else
			{
				baseline = document.myForm.baseline.value;
				baselineName = document.myForm.baseline.title;
				sourceNames = document.myForm.sourceNames.value;
			}
		}

		if (baselineName == "")
		{
			if (nonBaselineNames == "" || nonBaselineNames.indexOf(",") > 0)
				subHeader = "<%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.SubHeader.MulitSelectReqs")%>";
			else
				subHeader = nonBaselineNames;
		}
		else
		{
			if (nonBaselineNames == "")
				subHeader = baselineName;
			else
				subHeader = baselineName + " vs (" + nonBaselineNames + ")";
		}

		if(sourceNames)
		{
			var targetIds = document.myForm.baselineDisplay.value;
			var targetChapReq = document.myForm.chapreqId.value;
			if(targetIds == "")
			{
				subHeader = sourceNames;
			}
			else
			{
				if(targetIds != null && targetChapReq == "")
				{	
					subHeader = "(" + sourceNames + ") vs (" + targetIds + ")";	
				}
				else
				{
					subHeader = sourceNames + " vs (" + targetChapReq + ")";
				}
			}
		}
		
		var chapreq ="";
		if(document.myForm.chapreq.value == "")
		{
			chapreq = "";
		}
		else
		{
			chapreq= document.myForm.chapreq.value;
		}
		
		// baseline is targetspecID's
		//reportObjects is sourceSpecID's
		fullHref += "&subHeader=" + subHeader + "&baselineObject=" + baseline + 
					"&reportObjects=<xss:encodeForJavaScript><%=emxGetParameter(request,"emxTableRowId")%></xss:encodeForJavaScript>" + 
					"&selectedType=<xss:encodeForJavaScript><%=emxGetParameter(request, "selectedType")%></xss:encodeForJavaScript>";

		var selType = "<xss:encodeForJavaScript><%=emxGetParameter(request, "selectedType")%></xss:encodeForJavaScript>";
		var repType = "<xss:encodeForJavaScript><%=emxGetParameter(request, "reportType")%></xss:encodeForJavaScript>";
		var forNext = "<xss:encodeForJavaScript><%=emxGetParameter(request, "forNext")%></xss:encodeForJavaScript>";
		 
		//OEP:HF-203808V6R2012x_ - Added a condition for selectable type for Requirement
		if((("Specification" == selType) || ("Requirement" == selType))&& "Requirement" == repType){
			fullHref +=	"&targetChapterRequirement="+chapreq;
			fullHref += "&submitURL=../requirements/TraceabilityReportCoverage.jsp?options=";
			if(!baseline == ""){	
				fullHref += "baselineObject:"+baseline+";";
			}
			if(!chapreq == ""){
				fullHref += "targetChapterRequirement:"+chapreq+";";
			}
			fullHref += "reportCount:"+reportCount;
		}
		// ++ HAT1 ZUD: IR-579219-3DEXPERIENCER2018x fix. ++
		if(fullHref.indexOf("emxTable.jsp") != -1)
		{
			fullHref = fullHref.replace("submitURL", "SubmitURL");
			fullHref = fullHref.replace("submitLabel", "SubmitLabel");
		}
		// -- HAT1 ZUD: IR-579219-3DEXPERIENCER2018x fix. --
		
		var frame = findFrame(getTopWindow(),"RMTSpecificationsBlankTraceabilityCommandForPowerView");
		frame.location = fullHref;
	}	
	function showTargetSpecification()
	{
	var sURL = 
	'../common/emxFullSearch.jsp?formName=myForm&field=TYPES=type_SoftwareRequirementSpecification&relationship=relationship_RequirementSpecification&table=RMTTargetSpecificationsTable&selection=multiple&suiteKey=Requirements&cancelButton=true&cancelLabel=emxRequirements.Button.Cancel&showSavedQuery=True&searchCollectionEnabled=True&HelpMarker=emxhelpfullsearch&submitURL=../requirements/MultiObjectSelect.jsp?frameName=searchPane&fieldNameActual=baseline&fieldNameDisplay=baselineDisplay'
	showChooser(sURL, 700,500)
	}
	
	function showTargetChaptersRequirements()
	{
	var baseline = document.myForm.baseline.value;
	var sURL = '../common/emxIndentedTable.jsp?formName=myForm&table=RMTSpecDetailTable&freezePane=Name,Revision&selection=multiple&direction=from&autoFilter=false&objectCompare=false&Export=false&PrinterFriendly=false&showClipboard=false&customize=false&editLink=false&sortColumnName=none&editRelationship=relationship_SpecificationStructure&resequenceRelationship=relationship_SpecificationStructure&connectionProgram=emxSpecificationStructureBase:processXMLMessage&suiteKey=Requirements&StringResourceFileId=emxRequirementsStringResource&SuiteDirectory=requirements&objectId='+baseline+'&submitURL=../requirements/MultiObjectSelect.jsp?frameName=searchPane&fieldNameActual=chapreq&fieldNameDisplay=chapreqId&header=emxRequirements.Heading.StructureBrowser&mode=forTraceability';
	showChooser(sURL, 700,500)
	
	
	}	
	function clearAndRefresh() {
		  var specdiv = document.getElementById("spec");
		  specdiv.style.visibility="hidden";
	}
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%!
   // This method returns the setting property value:
   private static String getSettingProperty(Context context, String settingKey)
   {
      String settingVal = "";
      try {
         settingVal = EnoviaResourceBundle.getProperty(context, settingKey);
      } catch (Exception e) {
         // Missing property - do nothing
      }
      return(settingVal);
   }
%>
<%
String emxTableRowId = emxGetParameter(request,"emxTableRowId");
StringTokenizer stok = new StringTokenizer(emxTableRowId,",",false);
String selType = emxGetParameter(request, "selectedType");
String repType = emxGetParameter(request, "reportType");
String forNext = emxGetParameter(request,"forNext");
String objectId = emxGetParameter(request,"objectId"); //HAT1 ZUD IR-531745-3DEXPERIENCER2018x fix.

session.setAttribute("sourceIDs",emxTableRowId);
session.setAttribute("selType",selType);
session.setAttribute("repType",repType);
session.setAttribute("forNext",forNext);
String lang = request.getHeader("Accept-Language");
String ReportName = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.ReportName"); 
String ReportDesc = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.ReportDesc"); 
String TargetSpecification = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.TargetSpecification"); 
String TargetChapterRequirements = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.TargetChapterRequirements"); 
String Clear = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.MissingSelection"); 

//CFF support on traceability reports: 
String CFFFilterExpr = emxGetParameter(request,"CFFExpressionFilterInput_OID");

%>

<form name="myForm" method="post" enctype="multipart/form-data" onsubmit="return validateForm();">

<table border="0" width="100%">
<%
// For Req-Req traceability only, add form field(s) for the selected Baseline Specifications
// String Baseline = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.Baseline"); 
//Start Pawan
String TargetScope = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.TargetScope"); 
//Start:IR-025903V6R2011
//OEP:HF-203808V6R2012x_ - Added a condition for selectable type for Requirement
if (repType.equals("Requirement") && (selType.equals("Specification") || (selType.equals("Requirement"))))
//END:IR-025903V6R2011
{
%>
	<tr>
			<th width="20"></th>
			<th><xss:encodeForHTML><%=TargetScope%></xss:encodeForHTML></th>
	</tr>
	
<%
    int rowCount = 1;
	StringBuffer strAllItemIds = new StringBuffer(); 
	StringBuffer strAllItemNames = new StringBuffer(); 
   while (stok.hasMoreTokens())
   {
      String itemId = stok.nextToken();
      if(! strAllItemIds.equals("")){
	  	strAllItemIds.append(",");
      }
      strAllItemIds.append(itemId);
      
      DomainObject domObj = DomainObject.newInstance(context, itemId);
      String itemName = domObj.getInfo(context, DomainConstants.SELECT_NAME) +
                 " (" + domObj.getInfo(context, DomainConstants.SELECT_REVISION) + ")";
      
      
      strAllItemNames.append(itemName);
      if(stok.hasMoreTokens())
      {
	 	 strAllItemNames.append(",");
      }
      else
      {
	  strAllItemNames.append("");
      }
        rowCount++;
   }
%>
<tr>
			<td><input name="sourceIds" type="hidden" value="<xss:encodeForHTMLAttribute><%=strAllItemIds.toString()%></xss:encodeForHTMLAttribute>" /></td>
			<td><input name="sourceNames" type="hidden" value="<xss:encodeForHTMLAttribute><%=strAllItemNames.toString()%></xss:encodeForHTMLAttribute>"/></td>			
</tr>
</table>	
<table border="0" width="100%">

	<!--TargetSpecification Field -->
	<tr>
		<td width="150" nowrap="nowrap" class="label"><xss:encodeForHTML><%=TargetSpecification%></xss:encodeForHTML>
			</td>
		<td nowrap="nowrap" class="field">
		<input type="text" name="baselineDisplay" size="20" readonly="readonly" /> 
		<input class="button" type="button"	name="btnRequirementSpecification" size="200" value="..." alt=""
			onClick="javascript:showTargetSpecification();" /> 
		<input type="hidden" name="baseline" value="" />
			&nbsp; <a name="ancClear1"
			href="#ancClear1" class="dialogClear"
			onclick="document.myForm.baselineDisplay.value='';document.myForm.baseline.value='';clearAndRefresh();" /><%=Clear%></a>
		</td>
	</tr>	
	
	<!-- Target Chapters/Requirements -->
	<tr style="visibility:hidden;" id="spec"> 
	<td width="150" nowrap="nowrap" class="label">
		<xss:encodeForHTML><%=TargetChapterRequirements%></xss:encodeForHTML>
						</td>
			<td nowrap="nowrap" class="field">
		<input type="text" name="chapreqId" size="20" readonly="readonly" /> 
		<input class="button" type="button"	name="btnChapterRequirement" size="200" value="..." alt=""
			onClick="javascript:showTargetChaptersRequirements()" /> 
		<input type="hidden" name="chapreq" value="" />
			&nbsp; <a name="ancClear1"
			href="#ancClear1" class="dialogClear"
			onclick="document.myForm.chapreqId.value='';document.myForm.chapreq.value=''" /><%=Clear%></a>
		</td>			
	</tr>
		</table>
<%
}
else
{
   while (stok.hasMoreTokens())
   {
      String itemId = stok.nextToken();
      DomainObject domObj = DomainObject.newInstance(context, itemId);
      String itemName = EnoviaResourceBundle.getTypeI18NString(context, domObj.getInfo(context, DomainConstants.SELECT_TYPE), context.getLocale().toLanguageTag()) +
                 ": " + domObj.getInfo(context, DomainConstants.SELECT_NAME) +
                 " (" + domObj.getInfo(context, DomainConstants.SELECT_REVISION) + ")";

      if (!repType.equals("Requirement"))
         itemId = "";
%>
	<input name="baseline" type="hidden" value='' title="<xss:encodeForHTMLAttribute><%=itemName%></xss:encodeForHTMLAttribute>"/>
 	<input name="chapreq" type="hidden" value=''/>
 	<input name="sourceNames" type="hidden" value="" />
 	<input name="forNext" type="hidden" value=''/>
<%
   }
}
%>

	<table class="list" border="0" width="100%">
		<tr>
			<th width="20"></th>
			<th><xss:encodeForHTML><%=ReportName%></xss:encodeForHTML></th>
			<th><xss:encodeForHTML><%=ReportDesc%></xss:encodeForHTML></th>
		</tr>  

<%
int reportCount = 1;
String reportTypeKey = "emxRequirements.TraceabilityReport." + selType + "." + repType + ".Report" + reportCount;
String reportNameKey = getSettingProperty(context, reportTypeKey + ".Name");

while (reportNameKey != null && !reportNameKey.equals(""))
{
   String reportName = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), reportNameKey); 
   String reportDescKey = getSettingProperty(context, reportTypeKey + ".Desc");
   String reportDesc = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), reportDescKey); 
   String reportHeadKey = getSettingProperty(context, reportTypeKey + ".Header");
   String reportHeader = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), reportHeadKey); 

   String reportProgram = getSettingProperty(context, reportTypeKey + ".Program");
   String reportTable = getSettingProperty(context, reportTypeKey + ".Table");
   String reportSortColumn = getSettingProperty(context, reportTypeKey + ".SortColumn");
   String reportSortDirection = getSettingProperty(context, reportTypeKey + ".SortDirection");

   String HelpMarker = emxGetParameter(request, "HelpMarker2");
   if(HelpMarker == null || HelpMarker.equals(""))
   {
	  HelpMarker = "emxhelptraceabilityreportfinal";
   }

   String reportHref = "../common/emxIndentedTable.jsp?customize=false";
   reportHref += "&traceabilityreport=true";
   reportHref += "&objectId=" + objectId;  //HAT1 ZUD IR-531745-3DEXPERIENCER2018x fix.
   reportHref += "&program=" + reportProgram;
   reportHref += "&table=" + reportTable;
   reportHref += "&submitLabel=emxRequirements.Button.Next";
   if(reportTable.equalsIgnoreCase("RMTTraceabilityDerivedRequirementsOnlyTable")){
	   reportHref = reportHref.replace("emxIndentedTable", "emxTable");
   }else{
	   /* reportHref += "&header=" + reportHeadKey;
	   reportHref += "&direction=from";
	   reportHref += "&fromImportStructure=false";
	   reportHref += "&editLink=false";
	   reportHref += "&showClipboard=false";
	   reportHref += "&multiColumnSort=false";
	   reportHref += "&objectCompare=false";  */
   }
   
   if (reportSortColumn.length() > 0)
      reportHref += "&sortColumnName=" + reportSortColumn;
   if (reportSortDirection.length() > 0)
      reportHref += "&sortDirection=" + reportSortDirection;
   if (reportProgram.indexOf("HelpMarker=") < 0)
      reportHref += "&HelpMarker=" + HelpMarker;
   if(CFFFilterExpr != null && CFFFilterExpr.length() != 0)
   	reportHref +="&CFFExpressionFilterInput_OID="+CFFFilterExpr;
   	reportHref +="&suiteKey=Requirements";
   	//reportHref += "&cancelButton=true&cancelLabel=emxCommonButton.Close";
%>
<script language="javascript" type="text/javascript">
	if(reportCount == "")
	{
		reportCount = <xss:encodeForJavaScript><%=reportCount%></xss:encodeForJavaScript>;
	}
</script>
<!--  For Four Report Type's -->
		<tr class="<xss:encodeForHTMLAttribute><%=((reportCount-1)%2 == 0? "even": "odd")%></xss:encodeForHTMLAttribute>">
			<td><input name="reportHref" type="radio" <%=(reportCount == 1? "checked": "")%> value="<xss:encodeForHTMLAttribute><%=reportHref%></xss:encodeForHTMLAttribute>" onClick="validateForm('<%=reportCount%>')""/></td>
			<td><xss:encodeForHTML><%=reportName%></xss:encodeForHTML></td>
			<td><xss:encodeForHTML><%=reportDesc%></xss:encodeForHTML></td>
		</tr>
<%
   reportCount++;
   reportTypeKey = "emxRequirements.TraceabilityReport." + selType + "." + repType + ".Report" + reportCount;
   reportNameKey = getSettingProperty(context, reportTypeKey + ".Name");
}
%>
	</table> 
	
</form>
<script type="text/javascript">
//display default report
validateForm(1);
</script type="text/javascript">
<%@include file="../emxUICommonEndOfPageInclude.inc"%>

