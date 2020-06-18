<%--  emxMetricsResults.jsp

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsResults.jsp.rca 1.34 Wed Oct 22 16:11:57 2008 przemek Experimental $
--%>

<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxMetricsConstantsInclude.inc"%>

<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="session"/>
<jsp:useBean id="metricsReportUIBean" class="com.matrixone.apps.metrics.ui.UIMetricsReports" scope="request"/>

<%
    String portalMode     = emxGetParameter(request,"portalMode");
    String showRefresh    = emxGetParameter(request,"showRefresh");
    String reportName     = emxGetParameter(request, "reportName","UTF-8");
    String portalOwner    = emxGetParameter(request, "portalOwner");
    String resultsTitle   = emxGetParameter(request, "resultsTitle","UTF-8");
    String strOwner       = emxGetParameter(request,"owner","UTF-8");
    String strViewDef     = emxGetParameter(request, "viewdef");
    String refreshMode    = emxGetParameter(request,"refreshMode");
    String isSharedAndNotOwned = emxGetParameter(request,"isSharedAndNotOwned");
    String strShowPercentage = emxGetParameter(request,"showPercentage");
    
   
    boolean isIE = EnoviaBrowserUtility.is(request,Browsers.IE);

    // for all purposes, the name "portalOwner" will be the same as "owner"
    if(portalOwner == null || "".equals(portalOwner) || "null".equalsIgnoreCase(portalOwner)){
        portalOwner = strOwner;
    }
    
    // coming from "Launch" button in Dashboard page ??
    String launched       = emxGetParameter(request, "launched");    
    
    boolean isWorkSpaceObjectExists = true;
    
    // Check visibility of webreports in portal mode
    if("true".equalsIgnoreCase(portalMode) && (portalOwner != null && portalOwner.length() > 0) && (!"true".equals(strViewDef)) && (!"true".equals(refreshMode)) ){
        reportName = FrameworkUtil.decodeURL(reportName,"UTF-8");
        resultsTitle = FrameworkUtil.decodeURL(resultsTitle,"UTF-8");
        isWorkSpaceObjectExists = metricsReportBean.checkWorkSpaceObject(context,reportName,portalOwner);
    }

    if(isWorkSpaceObjectExists == false){
                context.shutdown();
%>        
        <jsp:forward page="../common/emxTreeNoDisplay.jsp" />
<%  }

    String defaultReport  = emxGetParameter(request, "defaultReport");
    
    String wrapColSize    = emxGetParameter(request, "wrapColSize");
    String strMode        = emxGetParameter(request,"mode");
    String viewDefMode    = strMode;
    String timeStamp      = emxGetParameter(request,"timestamp");
    
    // This is to handle the use case: Dashboard -> View Defn -> Done -> Launch,
    // The mode will become 'reportDisplay' when the user clicks on "Done"
    // in the View Defn page. Now if the user clicks on Launch, mode should be changed to 
    // "reportView". Anyhow, on click of Launch, portalMode will be "false" and Launched will be "true"
        
    // identify the portal mode + launched mode
    if("false".equalsIgnoreCase(portalMode) && "true".equalsIgnoreCase(launched)){
        strMode = "reportView";
        showRefresh = "true";
        // if you are coming from View Def --> Done, then strViewDef will be true.
        // Hence don't decode the report name. similarly for refresh case also
        // dont decode the report name
        if(!("true".equals(strViewDef) || "true".equals(refreshMode)) ){
            reportName = FrameworkUtil.decodeURL(reportName,"UTF-8");
            resultsTitle = FrameworkUtil.decodeURL(resultsTitle,"UTF-8");
        }
    }

    if(reportName == null || reportName.equals("null")){
        reportName = "";
    }
    if(resultsTitle == null || resultsTitle.equals("null")){
        resultsTitle = "";
    }     
    
    String reportToolbar = emxGetParameter(request, "toolbar");
    String helpMarker = emxGetParameter(request, "helpMarker");
    String strDateUnit     = emxGetParameter(request, "optDateUnit");
    String strGroupBy      =  emxGetParameter(request, "lstGroupBy");
    String strSubGroup     =  emxGetParameter(request, "lstSubgroup");
    String chartType     =  emxGetParameter(request, "chartType");

    String txtActualContainedIn     =  emxGetParameter(request, "txtActualContainedIn");
    HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
    if (reportToolbar == null || reportToolbar.trim().length() == 0)
    {
        reportToolbar = PropertyUtil.getSchemaProperty(context,"menu_MetricsGlobalToolbar");
    }

    HashMap metricsRelatedSettings = new HashMap();
    try
    {
        ContextUtil.startTransaction(context,true);
        metricsRelatedSettings = metricsReportUIBean.getMetricsRelatedSettingsOfCommand(context,
                                                                                          defaultReport,
                                                                                          reportToolbar,
                                                                                          paramMap,
                                                                                          lStr);
    }
    catch(Exception ex)
    {
        if(ex.toString() != null && (ex.toString().trim()).length()>0){
            ContextUtil.abortTransaction(context);            
            emxNavErrorObject.addMessage("emxMetricsResults.jsp: Cannot get Command Settings: Exception: "+ex.toString());
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }                                                                                          
    String strResultsURL = (String)metricsRelatedSettings.get(metricsReportUIBean.SETTING_REPORT_RESULTS_URL);

    if (strResultsURL == null || strResultsURL.trim().length() == 0){
        emxNavErrorObject.addMessage("emxReport: Report Results URL is empty");
        strResultsURL = "../common/emxBlank.jsp";
    }

    if(strMode.equalsIgnoreCase("criteriaUpdate"))
    {
        //get request parameters
        String strSaveType = emxGetParameter(request,"saveType");
        timeStamp      = emxGetParameter(request,"timestamp");
        strResultsURL += "?timeStamp="+XSSUtil.encodeForURL(context, timeStamp);
        request.setAttribute("decodedReportName",reportName);
%>
        <!-- //XSSOK -->
        <jsp:include page="<%=strResultsURL%>" flush="true" />
<%  } else {
        // Generate a new timestamp when the user clicks on "Refresh" button
        // and associate this timestamp with the pageControl Object (done at bottom)
        // The timestamp generated here will be set as the archive label on the 
        // webreport, which should be used while doing "Save" after "Refresh"
        if(strMode != null && strMode.equalsIgnoreCase("reportView") && !"true".equals(refreshMode)){
            timeStamp = Long.toString(System.currentTimeMillis());
            
            // skip the following in case when portalmode=true
            if(portalMode == null || "".equals(portalMode) || "null".equalsIgnoreCase(portalMode)){
                //Coming from view results in the dialog page there won't be any 
                //chart type in the request has to be taken from notes field this done in
                //order to check whether the user has changed any display format
                StringList strList = new StringList();
                strList.add("chartType");
                HashMap hm = metricsReportBean.readNotesXML(context, reportName,portalOwner,defaultReport,timeStamp, strList);
                String strChartDetails = (String)hm.get("chartType");
                StringList strList1 = FrameworkUtil.split(strChartDetails,",");
                for(int l=0; l < strList1.size(); l++) {
                    String basicStr = (String) strList1.get(l);
                    if(basicStr.indexOf("true")>0){
                        chartType = basicStr.substring(1,basicStr.indexOf(":"));
                        break;
                    }
                }
            }    
        }
        else if(strMode != null && strMode.equalsIgnoreCase("reportView") && "true".equals(refreshMode)){
            timeStamp = emxGetParameter(request,"timeStamp");
        }

        HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
        metricsReportBean.setReportDialogData(context,requestMap,timeStamp);

        //Get requestParameters for searchContent
        StringBuffer queryString = new StringBuffer("");
        if("MetricsObjectCountInStateReport".equalsIgnoreCase(defaultReport) || "MetricsLifecycleDurationReport".equalsIgnoreCase(defaultReport) ){
            Enumeration eNumParameters = emxGetParameterNames(request);
            // weblogic9.1 fix
            // using emxGetParameterNames and emxGetParameter with UTF-8, corrupts enumeration returned by
            // emxGetParameterNames possibly by the concurrent use of same enumeration
            // Below cade is used to make List out of enumeration and then using it.
            ArrayList aNumParameters = new ArrayList();
            while( eNumParameters.hasMoreElements() ) {
                String strParamName = (String)eNumParameters.nextElement();
                aNumParameters.add(strParamName);
            }
            int paramCounter = 0;
            for(int i = 0; aNumParameters != null && i < aNumParameters.size(); i++) {
                String strParamName = (String)aNumParameters.get(i);
                String strParamValue = emxGetParameter(request, strParamName);
                
                if(strParamName.equals("reportName") || strParamName.equals("resultsTitle") || strParamName.equals("owner") ){
                    strParamValue = emxGetParameter(request, strParamName, "UTF-8");
                }
                
                // Fix for the chinese/hk characters issue which was existing only in Portal mode
                // Use the decoded values of both name and title 
                
                if("true".equalsIgnoreCase(portalMode) && (portalOwner != null && portalOwner.length() > 0) && (!"true".equals(strViewDef)) && (!"true".equals(refreshMode)) ){
                    if(strParamName.equals("reportName") || strParamName.equals("resultsTitle")){
                        strParamValue=FrameworkUtil.decodeURL(strParamValue,"UTF-8");
                    }
                }
                else if("false".equalsIgnoreCase(portalMode) && "true".equalsIgnoreCase(launched) && (!"true".equals(strViewDef)) && (!"true".equals(refreshMode))){
                    if(strParamName.equals("reportName") || strParamName.equals("resultsTitle")){
                        strParamValue=FrameworkUtil.decodeURL(strParamValue,"UTF-8");
                    }
                }

                //do not pass showAdvanced or url on
                if(!"url".equals(strParamName)){
                    paramCounter++;
                    if (strParamValue != null && !"".equals(strParamValue) && !"*".equals(strParamValue))
                    {
						queryString.append("&");
						queryString.append(strParamName);
						queryString.append("=");
						queryString.append(strParamValue);
					}
            }
        }
        }
        else{
            queryString.append("&");
            queryString.append("optDateUnit");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, strDateUnit));
            queryString.append("&");
            queryString.append("lstGroupBy");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, strGroupBy));
            queryString.append("&");
            queryString.append("lstSubgroup");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, strSubGroup));
            queryString.append("&");
            queryString.append("reportName");
            queryString.append("=");
            queryString.append(reportName);
            queryString.append("&");
            queryString.append("defaultReport");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, defaultReport));
            queryString.append("&");
            queryString.append("mode");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, strMode));
            queryString.append("&");
            queryString.append("portalMode");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, portalMode));
            queryString.append("&");
            queryString.append("showRefresh");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, showRefresh));            
            queryString.append("&");
            queryString.append("portalOwner");
            queryString.append("=");
            queryString.append(portalOwner);
            queryString.append("&");
            queryString.append("resultsTitle");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, resultsTitle));
            queryString.append("&");
            queryString.append("launched");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, launched));
            queryString.append("&");
            queryString.append("chartType");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, chartType));
            queryString.append("&");
            queryString.append("wrapColSize");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, wrapColSize));

            // added as a fix for bug # 301001
            if(refreshMode != null && refreshMode.equalsIgnoreCase("true")){
                queryString.append("&");
                queryString.append("refreshMode");
                queryString.append("=");
                queryString.append(XSSUtil.encodeForURL(context, refreshMode));        
            }            
            queryString.append("&");
            queryString.append("showPercentage");
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, strShowPercentage));
        }
        
         String strHelpMarker    = "";

        if(queryString.length() > 1){
            queryString.append("&timeStamp=");
            queryString.append(XSSUtil.encodeForURL(context, timeStamp));
            queryString.append("&owner=");
            queryString.append(strOwner);
            strResultsURL += "?" + queryString.toString();            
        }

        
        // The supported report display formats for the report are passed to the header page.
        String strSupportedReportFormats = "";
        if("MetricsLifecycleDurationReport".equalsIgnoreCase(defaultReport)){
            strSupportedReportFormats="tabular,bar,stackbar,line";
            strHelpMarker = "emxhelpcommonlifecyclereportresults";
        }
        else if("MetricsObjectCountReport".equalsIgnoreCase(defaultReport)){
            strSupportedReportFormats="tabular,bar,stackbar,line";
            strHelpMarker = "emxhelpcommonobjectcountreportresults";
        }
        else if("MetricsObjectCountInStateReport".equalsIgnoreCase(defaultReport)){
            strSupportedReportFormats="tabular,bar,pie,line";
            strHelpMarker = "emxhelpobjectcountstatetimereportresults";
        }
        else if("MetricsObjectCountOverTimeReport".equalsIgnoreCase(defaultReport)){
            strSupportedReportFormats="tabular,bar,stackbar,line";
            strHelpMarker = "emxhelpobjectcountovertimereportresults";
        }
        else{
            strSupportedReportFormats = "tabular,bar,stackbar,pie,line";
        }
        
        
        //Coming from view results in the dialog page there won't be any chart type in the request so need to append explicitly
        if(strMode != null && strMode.equalsIgnoreCase("reportView") && !"true".equals(refreshMode) && !"true".equalsIgnoreCase(portalMode)){
            strResultsURL = strResultsURL +"&chartType="+chartType;
        }
        
        strResultsURL = FrameworkUtil.encodeURL(strResultsURL, "UTF-8");
        
        // for portal - Refresh - Save
        String displayFormat = "";
        if("true".equalsIgnoreCase(portalMode) && (portalOwner != null && portalOwner.length() > 0) ){
            if(refreshMode != null){
                StringList getList = new StringList();
                getList.add("chartType");

                HashMap strNotes = metricsReportBean.readNotesXML(context,reportName,portalOwner,defaultReport,timeStamp, getList);
                String strChartType = (String)strNotes.get("chartType");
                StringList attrList = FrameworkUtil.split(strChartType, "|");
                for (int i = 0; i < attrList.size()-1; i++)
                {
                    String sAttrib = (String)attrList.elementAt(i);
                    if(sAttrib.indexOf("true") != -1){
                        displayFormat = sAttrib.substring(sAttrib.indexOf(",")+2,sAttrib.indexOf(":"));
                    }               
                 }
            }
            else{
                // Handling the use case of: Dashboard -> View Defn -> Done -> Save in tab
                // pickup the display format from the request
                displayFormat = chartType;
            }
        }      
        
%>

    <head>
        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
        <script language="javascript" src="../common/scripts/emxUIPopups.js"></script>
        <script language="javascript" src="emxMetrics.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIActionbar.js"></script>
        <script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIMetricsDialog.css" />
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIMenu.css" />
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIToolbar.css" />
        
        <script>
        function loadContentFrame(){
        	//XSSOK
            var resultsPageURL="<%=strResultsURL%>";
            if (getTopWindow().getWindowOpener()){
                if(getTopWindow().getWindowOpener().parent){
                    if(getTopWindow().getWindowOpener().parent.timeStamp){
                        resultsPageURL =resultsPageURL+"&launchtimeStamp=" + getTopWindow().getWindowOpener().parent.timeStamp;
                    }
                }    
            }
            var resultsPageFrame = findFrame(this,"metricsReportResultsContent");
            if(resultsPageFrame)
            {
            	submitWithCSRF(resultsPageURL,resultsPageFrame);
            }
        }
        var strCommandName = "<xss:encodeForJavaScript><%= defaultReport %></xss:encodeForJavaScript>";
        var strSavedReportName = "<xss:encodeForJavaScript><%= reportName %></xss:encodeForJavaScript>";
        //XSSOK
		var strResultsPageURL="<%=strResultsURL%>"; 
        var fromPortalMode="<xss:encodeForJavaScript><%=portalMode%></xss:encodeForJavaScript>";
        STR_FROM_PORTAL_MODE = fromPortalMode;
        var fromReportView="<xss:encodeForJavaScript><%=strMode%></xss:encodeForJavaScript>";
        var timeStamp   = "<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>";
        var reportOwner   = "<xss:encodeForJavaScript><%=portalOwner%></xss:encodeForJavaScript>";
        STR_REPORT_OWNER = reportOwner;
        var isPageLaunched = "<xss:encodeForJavaScript><%=launched%></xss:encodeForJavaScript>";        
     
        // don't call the setPageControlValuesFromDialog() in case of click
        // of "Launch" button in dashboard as there will be no dialog page
        if(isPageLaunched == "null"){
            if(fromPortalMode!="null" && fromPortalMode=="false")
            {
               setPageControlValuesFromDialog(null,parent,false);
            }
            
            pageControl.setTopWindow(getTopWindow());
            if(getTopWindow().getWindowOpener())
            {
                pageControl.setOpenerWindow(getTopWindow().getWindowOpener().getTopWindow());
                if(getTopWindow().getWindowOpener().getTopWindow().getWindowOpener())
                {
                    pageControl.setOpenersOpenerWindow(getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow());
                }
            }
        }

        //setting the value of timestamp to the page control, if setPageControlValuesFromDialog does'nt 
        //set any values in View Results Case, here the values will be set  
        pageControl.setTimeStamp("<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>");
        pageControl.setCommandName("<xss:encodeForJavaScript><%= defaultReport %></xss:encodeForJavaScript>");
        pageControl.setSavedReportName("<xss:encodeForJavaScript><%= reportName %></xss:encodeForJavaScript>");
        pageControl.setOwner(reportOwner);
        pageControl.setTitle("<xss:encodeForJavaScript><%=resultsTitle%></xss:encodeForJavaScript>");
<%
        if(strMode.equalsIgnoreCase("reportView") || strMode.equalsIgnoreCase("reportDisplay")){
%>            
            pageControl.setSharedAndNotOwned("<xss:encodeForJavaScript><%=isSharedAndNotOwned%></xss:encodeForJavaScript>");
<%
        }
        if("true".equalsIgnoreCase(portalMode) || "true".equalsIgnoreCase(launched)){
            if(!portalOwner.equalsIgnoreCase(context.getUser())){
%>
                pageControl.setSharedAndNotOwned(true); 
<%        
            }
            else{
%>
                pageControl.setSharedAndNotOwned(false); 
<%
            }     
        }       

        if("true".equalsIgnoreCase(portalMode) && (portalOwner != null && portalOwner.length() > 0) ){
%>
            pageControl.setDisplayFormat("<xss:encodeForJavaScript><%=displayFormat %></xss:encodeForJavaScript>");
            pageControl.setBooleanDisplayFormat("true");
<%
        }
        
        if("true".equals(portalMode))
        {
            if("true".equals(refreshMode)){
%>            
                pageControl.setChangedDisplayFormat("<xss:encodeForJavaScript><%=displayFormat %></xss:encodeForJavaScript>");
<%
            }
            if(viewDefMode.equals("reportDisplay"))
            {
                viewDefMode = "reportView";
            }
        }
%>
        pageControl.setMode("<xss:encodeForJavaScript><%=viewDefMode%></xss:encodeForJavaScript>");        
<%
        if(strMode != null && strMode.equalsIgnoreCase("reportView"))
        {
            if(metricsReportBean.hasResult(context,reportName,portalOwner) && !"true".equals(refreshMode))
            {
%>

                setTimeout("enableFunctionality(STR_METRICS_SAVE_COMMAND,false)",1500);
<%
            }
        }
%>              
        </script>
        
        
    </head>

<%
    String toolbar = emxGetParameter(request, "toolbar");
    String metricsToolbar = PropertyUtil.getSchemaProperty(context,"menu_MetricsGlobalToolbar");
    String objectId = null;
    String relId = null;
    String lastCompletedIn = "";
    String lastRunDetails  = "";
    String subHeader       = "";
    String strBundle       = "emxMetricsStringResource";
    String languageStr     = request.getHeader("Accept-Language");
    String strTargetState  = emxGetParameter(request, "lstTargetState");
    String strlistpolicy   = emxGetParameter(request, "listpolicy");
    String strPolicyActual = emxGetParameter(request, "txtPolicyActual");
    String strListState    = emxGetParameter(request, "liststate");
    String strDateWise     = "";
    String strActualContainedIn   = emxGetParameter(request, "txtActualContainedIn");
    String suiteKeyStr     = "";
    int index = 1;
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
        paramMap = metricsReportBean.getReportDialogData(timeStamp);
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
        <script type="text/javascript">
<%
            if(portalMode == null || "".equals(portalMode) || "null".equals(portalMode)){
%>
                getTopWindow().pageControl.setTitle("<xss:encodeForJavaScript><%=resultsTitle%></xss:encodeForJavaScript>");
                getTopWindow().pageControl.setWindowTitle();
<%
            }
            if(defaultTitle && (portalMode == null || "".equals(portalMode) || "null".equals(portalMode))){
%>
                getTopWindow().pageControl.setTitle("");
<%
            }
%>
           /* function openPrinterFriendlyPage(){
                parent.openPrinterFriendlyPage();
            }*/

        </script>
    
    <body class="dialog" onunload="javascript:cleanupSession('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=defaultReport%></xss:encodeForJavaScript>')" onload="adjustBody();loadContentFrame();" onresize="resizeContentIFrame('metricsReportResultsContent','divPageBody');">
        <div id="divPageHead">
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
                                    <span id="pageHeader" class="pageHeader">&nbsp;<xss:encodeForHTML><%=resultsTitle%></xss:encodeForHTML></span>
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
                        <jsp:include page = "../common/emxToolbar.jsp" flush="true"><jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/><jsp:param name="objectId" value="<%=objectId%>"/><jsp:param name="relId" value="<%=relId%>"/><jsp:param name="export" value="false"/><jsp:param name="PrinterFriendly" value="true"/><jsp:param name="HelpMarker" value="<%=strHelpMarker%>"/><jsp:param name="suiteKey" value="<%= XSSUtil.encodeForURL(context, suiteKeyStr)%>" /><jsp:param name="supportedReportFormats" value="<%=strSupportedReportFormats%>"/></jsp:include>
                   </td>
                   <td><img src="images/utilSpacer.gif" width="2" alt="" /></td>
                 </tr>
               </table>
        </form>
        </div>
        <div id="divPageBody" <%if(isIE){%> style="top:70px;" <%}%>>
            <iframe class="contentIFrame" id="metricsReportResultsContent" src="../common/emxBlank.jsp" name="metricsReportResultsContent" height="100%" onload="resizeContentIFrame('metricsReportResultsContent','divPageBody');"></iframe>
        </div>

<%      if(portalMode == null || "".equals(portalMode) || "null".equals(portalMode) || ("true".equalsIgnoreCase(launched)) ){
        // normal mode
		    String pagination = "";
		    String paginationRange = "";
		    wrapColSize = "";
		    String upperWrapColSize = "";
		
		    try{
		        wrapColSize = "100";//FrameworkProperties.getProperty(context, "emxMetrics.label.WrapSize");
		        if( (wrapColSize == null) || (wrapColSize.equals("null")) || (wrapColSize.equals(""))) {
		            wrapColSize="100";
		        }
		
		    }catch (Exception ex){
		        if(ex.toString() != null && (ex.toString().trim()).length()>0){
		                emxNavErrorObject.addMessage("emxMetricsResultsFooter.jsp:" + ex.toString().trim());
		        }
		    }
%>
        <div id="divPageFoot">
	    <form name="frmFooter" method="post">
	      <table width="100%" border="0" align="center" cellspacing="0" cellpadding="0">
	        <tr>
	          <td>
	            <table border="0">
	              <tr>
	                <td></td>
	                <td></td>
	                <td></td>
	                <td>&nbsp;&nbsp;</td>
	              </tr>
	            </table>
	          </td>
	          <td align="right">
	            <table border="0" cellspacing="0" cellpadding="0">
	              <tr>
	                <td>&nbsp;&nbsp;</td>
	                <td></td>
	                <td nowrap></td>
	                <td>&nbsp;&nbsp;</td>
	                <td nowrap>&nbsp;<a class="button" onclick="javascript:getTopWindow().closeWindow()">
	                <button class="btn-default" type="button"><%=STR_METRICS_CLOSE%></button></a></td>
	                <td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;&nbsp;</td>
	              </tr>
	            </table>
	          </td>
	        </tr>
	      </table>
	      <input type="image" height="1" width="1" border="0" name="inputImage" value=""/>
	    </form>
        </div>
         <script type="text/javascript" language="JavaScript">
            function doDone() {
                turnOnProgress("utilProgressBlue.gif");
                setTimeout("getTopWindow().close()", 500);
            }


            function trimWhitespace(strString) {
                strString = strString.replace(/^[\s\u3000]*/g, "");
                return strString.replace(/[\s\u3000]+$/g, "");
            }
        </script>
        <script language="JavaScript" src="emxMetricsUtils.js" type="text/javascript"></script>
<%      }
%>
<iframe src="../common/emxBlank.jsp" name="metricsReportResultsHidden" id="metricsReportResultsHidden" frameborder="0" scrolling="no" width="0" height="0"></iframe>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
 </body>        
</html>
<%}%>
