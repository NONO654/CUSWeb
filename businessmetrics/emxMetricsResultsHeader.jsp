<%-- emxMetricsResultsHeader.jsp - The header section of the Results page

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsResultsHeader.jsp.rca 1.25 Wed Oct 22 16:11:55 2008 przemek Experimental $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="session"/>
<jsp:useBean id="metricsReportUIBean" class="com.matrixone.apps.metrics.ui.UIMetricsReports" scope="request"/>

<%
    String resultsTitle = "";
    String toolbar = emxGetParameter(request, "toolbar");
    String metricsToolbar = PropertyUtil.getSchemaProperty(context,"menu_MetricsGlobalToolbar");
    String reportName = emxGetParameter(request, "reportName");
    String defaultReport = emxGetParameter(request, "defaultReport");
    String timeStamp = emxGetParameter(request, "timeStamp");
    String objectId = null;
    String relId = null;
    String lastCompletedIn = "";
    String lastRunDetails  = "";
    String subHeader       = "";
    String strBundle       = "emxMetricsStringResource";
    String languageStr     = request.getHeader("Accept-Language");
    String strDateUnit     = emxGetParameter(request, "optDateUnit");
    String strGroupBy      = emxGetParameter(request, "lstGroupBy");
    String strSubGroup     = emxGetParameter(request, "lstSubgroup");
    String strTargetState  = emxGetParameter(request, "lstTargetState");
    String strlistpolicy   = emxGetParameter(request, "listpolicy");
    String strPolicyActual = emxGetParameter(request, "txtPolicyActual");
    String strListState    = emxGetParameter(request, "liststate");
    String strMode         = emxGetParameter(request, "mode");
    String portalMode      = emxGetParameter(request, "portalMode");
    String strOwner        = emxGetParameter(request, "owner");
    String strDateWise     = "";
    String strHelpMarker   = emxGetParameter(request, "HelpMarker");
    String strActualContainedIn   = emxGetParameter(request, "txtActualContainedIn");
    String suiteKeyStr     = "";
    int index = 1;
    String portalOwner     = emxGetParameter(request,"portalOwner");
    // coming from "Launch" button in Dashboard page ??
    String launched       = emxGetParameter(request, "launched");
    HashMap hmReqFieldsMap      = new HashMap();
    boolean defaultTitle = false;

    // for the use case of portal mode
    if("true".equalsIgnoreCase(portalMode) || "true".equalsIgnoreCase(launched)){
        if(portalOwner != null && (portalOwner.length() > 0) ){
            strOwner = portalOwner;
        }
    }
    StringBuffer sbResultsTitle = new StringBuffer("");
    try{
        HashMap paramMap = metricsReportBean.getReportDialogData(timeStamp);
        HashMap metricsSettingsMap = metricsReportUIBean.getMetricsRelatedSettingsOfCommand(context, defaultReport,
                                                                     metricsToolbar, paramMap,lStr);
        suiteKeyStr = (String)metricsSettingsMap.get(metricsReportUIBean.SETTING_REGISTERED_SUITE);
        if(reportName==null){
            reportName ="";
        }
        if(strDateUnit==null || "null".equals(strDateUnit)){
            strDateUnit="";
        }
        if(strTargetState==null || "null".equals(strTargetState)){
            strTargetState="";
        }
        if(strListState==null || "null".equals(strListState)){
            strListState="";
        }
        if(strGroupBy==null || "null".equals(strGroupBy)){
            strGroupBy="";
        }
        if(strSubGroup==null || "null".equals(strSubGroup)){
            strSubGroup="";
        }
        if (toolbar == null || toolbar.trim().length() == 0)
        {
            toolbar = PropertyUtil.getSchemaProperty(context,"menu_MetricsCommonReportsResultsToolbar");
        }

        if((!reportName.equalsIgnoreCase("last")) && (!("".equals(reportName))))
        {
            resultsTitle = metricsReportBean.getResultsTitle(context,reportName,strOwner);
            resultsTitle = metricsReportBean.escapeSlashes(resultsTitle);
        }
        if ((resultsTitle == null) || "".equals(resultsTitle) || "null".equals(resultsTitle)){
            defaultTitle = true;
            resultsTitle = (String)metricsSettingsMap.get(metricsReportUIBean.COMMAND_TITLE);
            HashMap titleDetails = new HashMap();
            titleDetails.put("Date Unit",strDateUnit);
            titleDetails.put("Bundle",strBundle);
            titleDetails.put("Language",languageStr);
            titleDetails.put("Title",resultsTitle);
            titleDetails.put("Target State",strTargetState);
            titleDetails.put("Report Name",reportName);
            titleDetails.put("Owner",strOwner);
            titleDetails.put("Default Report",defaultReport);
            titleDetails.put("Time Stamp",timeStamp);
            titleDetails.put("Sub Group",strSubGroup);
            titleDetails.put("Group By",strGroupBy);
            titleDetails.put("Mode",strMode);
            titleDetails.put("List State",strListState);
            titleDetails.put("List Policy",strlistpolicy);
            titleDetails.put("PolicyActual",strPolicyActual);
            titleDetails.put("txtActualContainedIn",strActualContainedIn);
            String strPropertyKey = metricsReportBean.getStringResourcePropertyKey(context,titleDetails);
            resultsTitle = metricsReportBean.substituteMacroValue(context,strPropertyKey,titleDetails);
        }
        //Setting the Title to the Session Map for printer friendly
        metricsReportBean.setTitle(timeStamp,resultsTitle);
    }
    catch(Exception e){
        System.out.println("Exception in Results Header page "+e);
    }

%>

<html>
    <head>
        <script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIActionbar.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIPopups.js"></script>
        <script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIMenu.css" />
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIForm.css" />
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIToolbar.css" />
        <script type="text/javascript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIMenu");
            addStyleSheet("emxUIForm");
            addStyleSheet("emxUISearch");
<%
            if(portalMode == null || "".equals(portalMode) || "null".equals(portalMode)){
%>
				//XSSOK
                getTopWindow().pageControl.setTitle("<%=resultsTitle%>");
                getTopWindow().pageControl.setWindowTitle();
<%
            }
            if(defaultTitle && (portalMode == null || "".equals(portalMode) || "null".equals(portalMode))){
%>
                getTopWindow().pageControl.setTitle("");
<%
            }
%>

            function openPrinterFriendlyPage(){
                parent.openPrinterFriendlyPage();
            }

        </script>
    </head>
    <body>
        <form method="post">
            <table border="0" cellspacing="2" cellpadding="0" width="100%">
                <tr>
                    <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
                </tr>
                <%
                    String progressImage = "../common/images/utilProgressBlue.gif";
                    String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
                %>
                <tr>
                    <td width="1%" nowrap>
                        <table border="0" width="100%" cellspacing="0" cellpadding="0">
                            <tr>
                                <td nowrap>
                                <!-- //XSSOK -->
                                    <span id="pageHeader" class="pageHeader">&nbsp;<%=resultsTitle%></span>
                                      <!-- //XSSOK -->
                                    <br/><span class="pageSubTitle" id="pageSubTitle">&nbsp;<%=subHeader%></span>
                                </td>
                                <td nowrap>
                                <!-- //XSSOK -->
                                    <div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=processingText%></i></div></td>
                                    <td width="1%"><img src="images/utilSpacer.gif" width="1" height="25" border="0" alt="" vspace="6" /></td>
                            </tr>
                        </table>
                     </td>
                </tr>
                </table>
                <table border="0" width="100%" cellspacing="0" cellpadding="0">
                  <tr>
                    <td>
					 <!-- //XSSOK -->
                        <jsp:include page = "../common/emxToolbar.jsp" flush="true"><jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/><jsp:param name="objectId" value="<%=objectId%>"/><jsp:param name="relId" value="<%=relId%>"/><jsp:param name="export" value="false"/><jsp:param name="PrinterFriendly" value="true"/><jsp:param name="HelpMarker" value="<%=XSSUtil.encodeForURL(context, strHelpMarker)%>"/><jsp:param name="suiteKey" value="<%=XSSUtil.encodeForURL(context, suiteKeyStr)%>" /></jsp:include>
                   </td>
                   <td><img src="images/utilSpacer.gif" width="2" alt="" /></td>
                 </tr>
               </table>
        </form>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </body>
</html>
