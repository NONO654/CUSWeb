<%--  emxEngrECOSummaryReport.jsp - This page displays the ECO summary report
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<html>
<head>
<%@include file = "ECMDesignTopInclude.inc"%>
<%@include file = "../components/emxComponentsVisiblePageInclude.inc"%>
<%@ page import="com.matrixone.apps.common.Change"%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%
	String sTitle = EnoviaResourceBundle.getProperty(context, "emxEnterpriseChangeMgtStringResource", context.getLocale(),"EnterpriseChangeMgt.Common.SummaryReportTitle"); 
%>
<!--XSS OK -->
<title><%=sTitle%></title>
<link rel="stylesheet" href="../emxUIDefaultPF.css" type="text/css">
<link rel="stylesheet" href="../emxUIReportPF.css" type="text/css">
<style type="text/css">
<!--
table tr td table tr td.label {
    border-bottom: 1px solid rgb(0,0,0);
}

table tr td table tr td.inputField {
    border-bottom: 1px solid rgb(0,0,0);
    border-collapse: collapse;
    empty-cells: show;
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
   String[] init = new String[] {};
   String[] methodargs = new String[1];
   methodargs[0] = objectId;
   try {
	   com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeReport cxBean= new com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeReport();
		
		htmlSummary = cxBean.createHTMLReport(context, methodargs);     	    
	   }catch(Exception e) {
		   IsReportGenerationSuccess = 1;
	   }
	   if(IsReportGenerationSuccess == 1) {
		   
		   errorMessage.append(EnoviaResourceBundle.getProperty(context ,"emxEnterpriseChangeMgtStringResource", context.getLocale(), "EnterpriseChangeMgt.SummaryReport.NoCheckIn.ErrorMessage"));
	   }


   %>
   <body>
   <form name="summaryForm" action="">
     <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
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
     
  <!-- XSSOK -->
  <%=htmlSummary%>
  <%

  %>
 </body>
</html>

