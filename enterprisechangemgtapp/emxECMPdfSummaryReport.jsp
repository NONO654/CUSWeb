<%--  emxEngrECOPdfSummaryReport.jsp   -  This page displays the ECO Pdf Summary Report
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file = "ECMDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@ page import="com.matrixone.apps.common.Change"%>
<html>

<%
    String languageStr = request.getHeader("Accept-Language");

   String objectId = emxGetParameter(request,"objectId");
   String strCategoryTreeName = emxGetParameter(request, "categoryTreeName");
   
   int IsReportGenerationSuccess = 0;  //success
   StringBuffer errorMessage = new StringBuffer();
   String generateSummary = emxGetParameter(request,"generateSummary");
   String outputFolder = "";
            String[] methodargs = new String[3];
            com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeReport ecoBean = new com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeReport();
            com.matrixone.apps.common.Change cxBean = new com.matrixone.apps.common.Change();
            methodargs[0] = objectId;
  
   if ("true".equalsIgnoreCase(generateSummary)) {
	   try {
                    IsReportGenerationSuccess = ecoBean.createPDFReport(
                            context, methodargs);
	   }catch(Exception e) {
		   IsReportGenerationSuccess = 1;
	   }
	   if(IsReportGenerationSuccess == 1) {
        errorMessage.append(EnoviaResourceBundle.getProperty(context, "emxEnterpriseChangeMgtStringResource", context.getLocale(),
                                    "EnterpriseChangeMgt.SummaryReport.NoCheckIn.ErrorMessage"));
                }
            }
   if(IsReportGenerationSuccess == 0) {

		  DomainObject dom = DomainObject.newInstance(context,objectId);
                String objName = dom.getInfo(context,DomainConstants.SELECT_NAME); //dom.getName();
		  String objRev = dom.getRevision(context);
                String checkOutDirectory = FrameworkProperties
                        .getProperty(context,"EnterpriseChangeMgt.PDF.CheckOutputFolder");
                
                outputFolder = checkOutDirectory + "/" + objName + "-Rev"
                        + objRev + ".pdf";
                
		  ServletContext sc = getServletConfig().getServletContext();
		  String appDirectory = (String)EnoviaResourceBundle.getProperty(context, "eServiceSuiteEnterpriseChangeMgt.Directory");
		  String path = sc.getRealPath(appDirectory); //java.io.File.separator+appDirectory
                methodargs[1] = path;
                methodargs[2] = checkOutDirectory;
                
                
                try {
                    IsReportGenerationSuccess = cxBean.checkOutPdf(context,
                            methodargs);
	   }catch(Exception e) {
		  IsReportGenerationSuccess = 1;
                    errorMessage
                            .append(EnoviaResourceBundle.getProperty(context, "emxEnterpriseChangeMgtStringResource", context.getLocale(),
                                    "EnterpriseChangeMgt.SummaryReport.NoCheckOut.ErrorMessage"));
		  //Check is PDF Render Software installed
		  String propertyFile = "EnterpriseChangeMgt";
                    String renderSoftwareInstalled = JSPUtil
                            .getCentralProperty(application, session,
                                    "EnterpriseChangeMgt", "RenderPDF");
                    if (renderSoftwareInstalled != null
                            && renderSoftwareInstalled.equalsIgnoreCase("TRUE")) {                        
                        errorMessage
                                .append(EnoviaResourceBundle.getProperty(context, "emxEnterpriseChangeMgtStringResource", context.getLocale(),
                                        "EnterpriseChangeMgt.SummaryReport.NoCheckOut.RenderMessage"));
                    }
                }
            }
            
   session.setAttribute("ECOSummaryReportObjectId",objectId);
   session.setAttribute("ECOSummaryReportCategoryTreeMenu", strCategoryTreeName);

   %>
 
   <body style="height:100%">
<form style="display:none" name="summaryForm"><input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"> <%if (IsReportGenerationSuccess == 1) {
	 
				//XSSOK
                %> <strong><%=errorMessage%></strong> <%}

            %></form>
<%//if condition commented for html generation.
if(IsReportGenerationSuccess == 0) {
       //Success. Display the url

  %>
  <!-- XSSOK -->
<iframe src="<%=outputFolder%>" width="100%" height="100%"
	SCROLLING=AUTO frameborder="0"></iframe>
  <%
 }

  %>
 </body>
</html>

