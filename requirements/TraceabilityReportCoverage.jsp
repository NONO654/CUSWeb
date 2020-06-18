<%--  TraceabilityReportCoverage.jsp
   FrameSet page for Create Requirement Specification dialog

   Copyright (c) 2008-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview T25 OEP 21 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags and tag Lib are included
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="java.util.StringTokenizer, com.matrixone.apps.domain.util.*"%>
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
String options = emxGetParameter(request, "options");
StringTokenizer sourceToken = new StringTokenizer(options, ";");
String baselineObject = null;
String targetChapterRequirement = null;
String reportCount = null;
while(sourceToken.hasMoreTokens()){
    String strParameter = sourceToken.nextToken();
    if(strParameter != null){
		StringTokenizer sourceTokenTemp = new StringTokenizer(strParameter, ":");
		while(sourceTokenTemp.hasMoreTokens()){
		    String strParaName  =  sourceTokenTemp.nextToken();
		    	if(strParaName != null && strParaName.equals("baselineObject")){
		    		baselineObject= sourceTokenTemp.nextToken();
		    		
		    	}
		    	else if(strParaName!= null && strParaName.equals("targetChapterRequirement")){
		    		targetChapterRequirement =  sourceTokenTemp.nextToken();
		    	}
		    	if(strParaName != null && strParaName.equals("reportCount"))
		    	{
		    	reportCount = sourceTokenTemp.nextToken();
		    	}
		}
    }
}
String specObjectIds = ""+session.getAttribute("sourceIDs");
String targetObjectIds = emxGetParameter(request, "baselineObject");
String selType = ""+session.getAttribute("selType");
String repType = ""+session.getAttribute("repType");

String reportTypeKey = "emxRequirements.TraceabilityReport." + selType + "." + repType + ".Report" + reportCount;
String reportNameKey = getSettingProperty(context, reportTypeKey + ".Name");
String reportProgram = getSettingProperty(context, reportTypeKey + ".Program");
%>

<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<html>
<head>

<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" type="text/javaScript">
function loadPage(){
	var url="../common/emxTable.jsp?table=RMTTraceabilityCoverageReportTable&program=emxTraceabilityReport:getTraceabilityCoverage"
	url +="&sourceObjectIDs=<xss:encodeForJavaScript><%=specObjectIds%></xss:encodeForJavaScript>";
	url +="&targetObjectIds=<xss:encodeForJavaScript><%=baselineObject%></xss:encodeForJavaScript>";
	url +="&targetChapterRequirement=<xss:encodeForJavaScript><%=targetChapterRequirement%></xss:encodeForJavaScript>";
	url +="&reportProgram=<xss:encodeForJavaScript><%=reportProgram%></xss:encodeForJavaScript>";
	url +="&sortColumnName=none";
	url +="&header=emxRequirements.TraceabilityReport.TraceabilityCoverage";
	url +="&suiteKey=Requirements&StringResourceFileId=emxRequirementsStringResource&SuiteDirectory=requirements";
	//url +="&CancelButton=true&CancelLabel=Close";
	url +="&HelpMarker=emxhelpTraceabilityCoverage";
	url +="&customize=false";
  var frame = findFrame(getTopWindow(),"RMTSpecificationsBlankTraceabilityCommandForPowerView");
  frame.location.href = encodeURI(url);
}
</script>
</head>
<body onload="loadPage();">
</body>
</html>

