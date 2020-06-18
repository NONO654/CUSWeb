<%-- emxProgramCentralResourcePoolReportDateFilter.jsp

  Displays a window for creating a Calendar event.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

--%>

<%@include file = "emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@include file = "emxProgramCentralVaultSupport.inc" %>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>


<%@page import="java.util.Map"%><jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>


<%

try
{
    String strTimeStamp = emxGetParameter(request, "timeStamp");
    Map requestMap = indentedTableBean.getRequestMap(strTimeStamp);
    Map requestValuesMap = (Map)requestMap.get("RequestValuesMap");
    
    long lStartDateMS_Value = 0;
    long lEndDateMS_Value = 0;
    String strStartDateValue 	= emxGetParameter(request, "PMCCustomFilterFromDateBox");
    String strEndDateValue 		= emxGetParameter(request, "PMCCustomFilterToDateBox"); 
    String strMode 				= emxGetParameter(request, "mode"); 
    String strTableRowIds		= emxGetParameter(request, "emxParentIds");
    String[] strResourcePoolIds = emxGetParameterValues(request, "ResourcePoolId");
    String strReportMode        = emxGetParameter(request, "ReportMode");
    String strHeader            = ((String[])requestValuesMap.get("header"))[0];
    String strHelpmarker        = emxGetParameter(request, "helpmarker");
    String strXaxistitle        = emxGetParameter(request, "xaxistitle");
    String strYaxistitle        = emxGetParameter(request, "yaxistitle");
    String strCharttype         = emxGetParameter(request, "charttype");
    String strSuiteKey          = emxGetParameter(request, "suiteKey");
    String strChartingRequired  = emxGetParameter(request, "chartingrequired");
    String programName          = emxGetParameter(request, "program");
    String tableName            = emxGetParameter(request, "table");
    String strToolbar           = emxGetParameter(request, "toolbar");
    String strThreshholdvalue   = emxGetParameter(request, "threshholdvalue");
    String strDisplayMode       = emxGetParameter(request, "displaymode");
    String strPMCReportPeopleProjectAssignementFilter = emxGetParameter(request, "PMCReportPeopleProjectAssignementFilter"); 
    if(null==strChartingRequired || "".equals(strChartingRequired) || "null".equals(strChartingRequired))
    {
    	strChartingRequired = "true";
    }
    
    matrix.util.StringList slTableRowIds = com.matrixone.apps.domain.util.FrameworkUtil.split(strTableRowIds,"~");
    double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();

    if(strStartDateValue!=null && !"null".equals(strStartDateValue) && !"".equals(strStartDateValue))
    {
    	//IR-014562V6R2011 change for IR
    	strStartDateValue =eMatrixDateFormat.getFormattedInputDate(context,strStartDateValue,clientTZOffset,(Locale)requestMap.get("localeObj"));
        lStartDateMS_Value = java.util.Date.parse(strStartDateValue);
    }
    if(strEndDateValue!=null && !"null".equals(strEndDateValue) && !"".equals(strEndDateValue))
    {
    	//IR-014562V6R2011 change for IR
    	strEndDateValue =eMatrixDateFormat.getFormattedInputDate(context,strEndDateValue,clientTZOffset,(Locale)requestMap.get("localeObj"));
        lEndDateMS_Value = java.util.Date.parse(strEndDateValue);
    }
  	
    if(lStartDateMS_Value==0 || lEndDateMS_Value==0)
    {
	%>
	<script language="javascript">
		alert("<emxUtil:i18nScript localize="i18nId2">emxProgramCentral.ResourcePoolDate.EnterFromToDate</emxUtil:i18nScript>");
	</script>
	<%
    }
    else if(lStartDateMS_Value > lEndDateMS_Value)
    {
    %>
    <script language="javascript">
	    alert("<emxUtil:i18nScript localize="i18nId2">emxProgramCentral.ResourcePoolDate.FromDateIsGreaterThanToDate</emxUtil:i18nScript>");   
    </script>
	<%
    }
    else
    {
    %>
	<form name="ResourcePoolDateFilter" action="../common/emxIndentedTable.jsp" method = "post" target="_parent">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
		<input type="hidden" name="PMCCustomFilterFromDate" value="<xss:encodeForHTMLAttribute><%=lStartDateMS_Value%></xss:encodeForHTMLAttribute>" />
	    <input type="hidden" name="PMCCustomFilterToDate" value="<xss:encodeForHTMLAttribute><%=lEndDateMS_Value%></xss:encodeForHTMLAttribute>" />
    	<input type="hidden" name="mode" value="<xss:encodeForHTMLAttribute><%=strMode%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="program" value="<xss:encodeForHTMLAttribute><%=programName%></xss:encodeForHTMLAttribute>" />
	    <input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=tableName%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="toolbar" value="<xss:encodeForHTMLAttribute><%=strToolbar%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="ReportMode" value="<xss:encodeForHTMLAttribute><%=strReportMode%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%=strHeader%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="helpmarker" value="<xss:encodeForHTMLAttribute><%=strHelpmarker%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="xaxistitle" value="<xss:encodeForHTMLAttribute><%=strXaxistitle%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="yaxistitle" value="<xss:encodeForHTMLAttribute><%=strYaxistitle%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="charttype" value="<xss:encodeForHTMLAttribute><%=strCharttype%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=strSuiteKey%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="chartingrequired" value="<xss:encodeForHTMLAttribute><%=strChartingRequired%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="sortColumnName" value="none" />
      	<input type="hidden" name="PMCReportPeopleProjectAssignementFilter" value="<xss:encodeForHTMLAttribute><%=strPMCReportPeopleProjectAssignementFilter%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="threshholdvalue" value="<xss:encodeForHTMLAttribute><%=strThreshholdvalue%></xss:encodeForHTMLAttribute>" />
      	<input type="hidden" name="displaymode" value="<xss:encodeForHTMLAttribute><%=strDisplayMode%></xss:encodeForHTMLAttribute>" />
      	<%
      	for (int i = 0; i < strResourcePoolIds.length; i++)
        {
        %>
            <input type="hidden" name="ResourcePoolId" value="<xss:encodeForHTMLAttribute><%=strResourcePoolIds[i]%></xss:encodeForHTMLAttribute>" />
      	<%
      	}
      	%>
    </form>
    
    <script language="javascript" type="text/javaScript">
	   var objSubmitForm = document.forms["ResourcePoolDateFilter"];
	   objSubmitForm.submit();
	</script>
    
	<%
    }
}
catch (Exception e)
{
    e.printStackTrace();
}
    
    
%>
 
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
