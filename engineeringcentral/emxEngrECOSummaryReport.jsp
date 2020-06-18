<%--  emxEngrECOSummaryReport.jsp - This page displays the ECO summary report
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<html>
<head>
<title>ECO Summary Report</title>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ page import="com.matrixone.apps.engineering.Change"%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<link rel="stylesheet" href="../emxUIDefaultPF.css" type="text/css" />
<link rel="stylesheet" href="../emxUIReportPF.css" type="text/css" />
<style type="text/css">
<!--
table tr td table tr td.label {
    border-bottom: 1px solid rgb(0,0,0);
}

table tr td table tr td.inputField {
    border-bottom: 1px solid rgb(0,0,0);
}


-->
</style>
</head>
<%
   String objectId = emxGetParameter(request,"objectId");
   int IsReportGenerationSuccess = 0;  //success
   StringBuffer errorMessage = new StringBuffer();

   String outputFolder = "";
   String htmlSummary = "";
   i18nNow loc = new i18nNow();
   String[] init = new String[] {};
   String[] methodargs = new String[1];
   methodargs[0] = objectId;
   try {
		com.matrixone.apps.engineering.Change cxBean= new com.matrixone.apps.engineering.Change();
		
		htmlSummary = cxBean.createECOHTMLReport(context, methodargs);     	    
	   }catch(Exception e) {
		   IsReportGenerationSuccess = 1;
	   }
	   if(IsReportGenerationSuccess == 1) {
		   //Multitenant
		   //errorMessage.append(loc.GetString("emxEngineeringCentralStringResource", context.getLocale().toString(), "emxEngineeringCentral.SummaryReport.NoCheckIn.ErrorMessage"));
		   errorMessage.append(EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.SummaryReport.NoCheckIn.ErrorMessage"));
	   }


   %>
   <body>
   <form name="summaryForm" action="">
     <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
   <%
   if(IsReportGenerationSuccess == 1) {
	   //Failure. Display the error message
   %>
   <!-- XSSOK -->
	   <strong><%=errorMessage%></strong>
   <%
   }
   %>
   </form>
      <%
      //if condition commented for html generation.
  %>
  <!-- XSSOK -->
  <%=htmlSummary%>
  <%

  %>
 </body>
</html>

