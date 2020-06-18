<%@ page buffer="100kb" autoFlush="false" %>
<%--  emxMetricsNotesSaveProcess.jsp - This is the processing page for saving XML data into the  webreport

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsNotesSaveProcess.jsp.rca 1.17 Wed Oct 22 16:11:56 2008 przemek Experimental $
--%>

<%@ page import="com.matrixone.jdom.*,
                 com.matrixone.jdom.Document,
                 com.matrixone.jdom.input.*,
                 com.matrixone.jdom.output.*"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%
String strMode = emxGetParameter(request,"mode");
if(strMode.equalsIgnoreCase("reportDisplay")){
%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%} %>	 
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="session"/>

<%
    //get request parameters
    String strSaveType = emxGetParameter(request,"saveType");
    String strReportName = emxGetParameter(request,"reportName");
    String strReportTitle = emxGetParameter(request,"reportTitle");
    String strDefaultReport = emxGetParameter(request,"defaultReport");
    String timeStamp = emxGetParameter(request,"timestamp");
    String strOwner       = emxGetParameter(request, "owner","");
    String strSharedAndNotOwned = emxGetParameter(request,"sharedAndNotOwned");
    String existingReportName = emxGetParameter(request,"existingReportName");
    String strViewDef         = emxGetParameter(request, "viewdef");
    SAXBuilder builder = new SAXBuilder();
    builder.setFeature("http://apache.org/xml/features/disallow-doctype-decl", false);
    builder.setFeature("http://xml.org/sax/features/external-general-entities", false);
    builder.setFeature("http://xml.org/sax/features/external-parameter-entities", false);

    XMLOutputter outputter = new XMLOutputter();
    StringWriter sw = new StringWriter();
    String strTempTest = "";
    if(!"UTF-8".equalsIgnoreCase(request.getCharacterEncoding())){
        strReportName = emxGetParameter(request,"reportName","UTF-8");
        strReportTitle = emxGetParameter(request,"reportTitle","UTF-8");
        existingReportName = emxGetParameter(request,"existingReportName","UTF-8");
        strOwner = emxGetParameter(request,"owner","UTF-8");
    }
    //close window or refresh?
    boolean bCloseWindow = false;
    boolean bRefreshWindow = false;
    boolean boolSaveSuccess = true;
    WebReport webReport = null;
    if((timeStamp==null) || ("".equals(timeStamp))){
        timeStamp = Long.toString(System.currentTimeMillis());
    }
    try
    {
       //create DOM with incoming XML stream
       Document doc = builder.build(new java.io.BufferedInputStream(request.getInputStream()));
       //string writer to hold XML string
       outputter.output(doc, sw);
       //outputter.output(doc,System.out);
       //perform save, update based on saveType
       ContextUtil.startTransaction(context, true);
       //saveType will be save or saveas when inputs are given through text boxes
       if(strSaveType.equals("save") || strSaveType.equals("saveas")){
          metricsReportBean.saveReport(context,strReportName, strOwner, strReportTitle, strDefaultReport, FrameworkUtil.encodeURL(sw.toString(),"UTF-8"), timeStamp, existingReportName);
       }else if((strSaveType.equals("update")) || (strSaveType.equals("updateNotes"))){
          //saveType will be update when clicked on done,
          //saveType will be updateNotes when opened a webreport in the dialog and
          //clicked on save or when selecting an existing webreport in the Save As dialog
          metricsReportBean.updateReport(context, strReportName, strOwner, strSharedAndNotOwned, strSaveType, strReportTitle, strDefaultReport, FrameworkUtil.encodeURL(sw.toString(),"UTF-8"), timeStamp, existingReportName);
       }

    }
    catch (Exception ex) {
        boolSaveSuccess = false;
        ContextUtil.abortTransaction(context);
        if (ex.toString() != null && (ex.toString().trim()).length() > 0){
            emxNavErrorObject.addMessage(ex.toString().trim());
        }
    } finally {
        ContextUtil.commitTransaction(context);
    }
    //clear the output buffer
    out.clear();
%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
    if(bRefreshWindow){ %>
        <script language="javascript">
            var contentWindow = getTopWindow().findFrame(getTopWindow(), "metricsReportContent");
            contentWindow.document.location.href = contentWindow.document.location.href;
        </script>
    <%}
    else if(strMode.equals("criteriaUpdate")){
        // saving from save as or save
        if (strSaveType.equals("save") || strSaveType.equals("saveas")){
    %>
        <script language="javascript">
        	//XSSOK
            var saveSuccess = "<%=boolSaveSuccess%>";
            var saveType = "<xss:encodeForJavaScript><%=strSaveType%></xss:encodeForJavaScript>";
            //set Saved report Name for not displaying saveDialog
            //while saving for the second time
            var reportName = "<xss:encodeForJavaScript><%=strReportName%></xss:encodeForJavaScript>";
            var contentFrame = getTopWindow().findFrame(getTopWindow(), "metricsReportContent");
            if(contentFrame==null)
            {
                contentFrame = getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "metricsReportContent");
            }

            if(saveSuccess=="true" && reportName !="")
            {
                //if saving from save dialog then only update the pageControl values
                //otherwise dont update this would prevent setting the saved report
                //in the save as to be current webreport in the dialog
                if(saveType=="save")
                {
                    contentFrame.getTopWindow().pageControl.setOpenedLast(false);
                    contentFrame.getTopWindow().pageControl.setSavedReportName(reportName);
                    contentFrame.getTopWindow().pageControl.setLatestSavedReportName(reportName);
                    contentFrame.getTopWindow().enableFunctionality(contentFrame.getTopWindow().STR_METRICS_DELETE_COMMAND,true);
                }

                contentFrame.getTopWindow().submitFunction(saveType,encodeURI("<%=strReportName%>"),encodeURI("<%=strOwner%>"),encodeURI("<%=strReportTitle%>"),encodeURI("<%=strDefaultReport%>"),'<xss:encodeForJavaScript><%=strMode%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>');

                if(getTopWindow().findFrame(getTopWindow(),"reportSaveHidden") || getTopWindow().findFrame(getTopWindow(),"metricsReportSaveAsHidden"))
                {
                   getTopWindow().closeWindow();
                }
            }else
            {
            		//XSSOK
                    alert("<%=emxNavErrorObject.toString().trim()%>");
            }
        </script>
    <%  }else if (strSaveType.equals("update") || strSaveType.equals("updateNotes")){
         //case introduced newly for distingushing update notes & update search criteria
         //also this will resolve the archive overriding problem
    %>
        <script language="javascript">
        	//XSSOK
            var saveSuccess = "<%=boolSaveSuccess%>";
            //set Saved report Name for not displaying saveDialog
            //while saving for the second time
            var reportName = "<xss:encodeForJavaScript><%=strReportName%></xss:encodeForJavaScript>";
            var contentFrame = getTopWindow().findFrame(getTopWindow(), "metricsReportContent");
            if(contentFrame==null)
            {
                contentFrame = getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "metricsReportContent");
            }

            if(saveSuccess=="true" && reportName !="")
            {
                contentFrame.getTopWindow().submitFunction('<xss:encodeForJavaScript><%=strSaveType%></xss:encodeForJavaScript>',encodeURI("<%=strReportName%>"),encodeURI("<%=strOwner%>"),encodeURI("<%=strReportTitle%>"),encodeURI('<%=strDefaultReport%>'),'<xss:encodeForJavaScript><%=strMode%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>');
                if(getTopWindow().findFrame(getTopWindow(),"reportSaveHidden") || getTopWindow().findFrame(getTopWindow(),"metricsReportSaveAsHidden"))
                {
                   getTopWindow().closeWindow();
                }
            }
        </script>
    <%
        }
    }else if(strMode.equals("reportDisplay")){ %>
        <script language="javascript">
            getTopWindow().pageControl.setTimeStamp("<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>");
            getTopWindow().openResultsDialog('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>',"<xss:encodeForJavaScript><%=strViewDef%></xss:encodeForJavaScript>");
        </script>
    <% } %>
