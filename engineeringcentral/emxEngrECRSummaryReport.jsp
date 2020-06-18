<%--  emxEngrECRSummaryReport.jsp - This page displays the ECR summary
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<html>
<head>
<title>ECR Summary Report</title>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ page import="com.matrixone.apps.engineering.Change"%>
<link rel="stylesheet" href="../emxUIReportPF.css" type="text/css" />
<style type="text/css">

table tr td table tr td.label {
    border-bottom: 1px solid rgb(0,0,0);
}

table tr td table tr td.inputField {
    border-bottom: 1px solid rgb(0,0,0);
}


</style>
</head>

<%String objectId = emxGetParameter(request, "objectId");
   int IsReportGenerationSuccess = 0;  //success
   StringBuffer errorMessage = new StringBuffer();
   String outputFolder = "";
   String htmlSummary = "";

	   String[] methodargs = new String[1];
	   methodargs[0] = objectId;
	   try {
                com.matrixone.apps.engineering.Change cxBean = new com.matrixone.apps.engineering.Change();
                                
             	// Code changes for X-BOM Cost Analytics-START
                boolean isCamInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMCostAnalytics",false,null,null);
                if(isCamInstalled)
                {
                	String[] init = new String[] {};
                	htmlSummary = (String)JPO.invoke(context, "CAECR", init, "createHtmlReport", methodargs,String.class);
                } else {
                htmlSummary = cxBean.createECRHTMLReport(context, methodargs);
                }
              //Code changes for X-BOM Cost Analytics-END
              
	   }catch(Exception e) {
		   IsReportGenerationSuccess = 1;
	   }
	   if(IsReportGenerationSuccess == 1) {
                errorMessage.append(JSPUtil.getCentralProperty(application,
                        session, "emxEngineeringCentralStringResource",
                        "SummaryReport.NoCheckIn.ErrorMessage"));
	   }
   session.setAttribute("ECRSummaryReportObjectId",objectId);
  %>
   <body>
    <table>
   <tr>
		<td></td>
   </tr>
   </table>
<form name="summaryForm" action=""><input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" /> <%if (IsReportGenerationSuccess == 1) {
	   //Failure. Display the error message
				//XSSOK
                %> <strong><%=errorMessage%></strong> <%}

            %></form>
<%if (IsReportGenerationSuccess == 0) {
       //Success. Display the url

  %>
  <!-- XSSOK -->
     <%=htmlSummary%>
<%}

  %>
   </body>
</html>
