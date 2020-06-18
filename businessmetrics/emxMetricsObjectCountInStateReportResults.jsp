<%--  emxMetricsObjectCountInStateReportResults.jsp - The results page for Object Count in State Over Time report

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsObjectCountInStateReportResults.jsp.rca 1.42 Wed Oct 22 16:11:58 2008 przemek Experimental $
--%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="chartBean" class="com.matrixone.apps.framework.ui.UIChart" scope="request"/>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="session"/>
<jsp:useBean id="metricsReportBeanUI" class="com.matrixone.apps.metrics.ui.UIMetricsReports" scope="request"/>

<head>
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" language="JavaScript">
    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIMenu");
</script>
</head>
<body onload="turnOffProgress();">
<%
    java.util.Date fromDateObj = null;
    java.util.Date toDateObj = null;
    String strFromDate = "";
    String strToDate = "";
    String strChartType             = "";
    String suiteKey                 = "";
    String wrapColSize              = "";
    String strNoResult              = "";
    String strDateUnit              = "";
    String strObjectDetails         = "";
    String strLanguage          = request.getHeader("Accept-Language");
    String strYAxisTitle = EnoviaResourceBundle.getProperty(context, metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE,context.getLocale(), "emxMetrics.label.TotalObjects");
    boolean bViewNow = false;
    String strConfirmMsg = EnoviaResourceBundle.getProperty(context, metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE,context.getLocale(), "emxMetrics.AlertMsg.ReportGenerationDelay");
    String strPolingTime  = EnoviaResourceBundle.getProperty(context, "emxMetrics.Background.Polling.TimeInterval");
    String strTimeOut  = EnoviaResourceBundle.getProperty(context, "emxMetrics.Background.Polling.TimeOutLimit");
    String strPortalMode = emxGetParameter(request,"portalMode");

    String strActualContainedIn = "";
     String strShowPercentage = emxGetParameter(request,"showPercentage");
     boolean blShowPercentage = false;
     if (!"false".equalsIgnoreCase(strShowPercentage))
     {
         blShowPercentage=true;
     }

    long lPolingTime = 0;
    long lTotalWaitTime = 0;
    try
    {
        lPolingTime = (Long.parseLong(strPolingTime)) *1000;
    }
    catch(Exception e)
    {
        lPolingTime = 0;
    }
    if(lPolingTime<0)
    {
        lPolingTime = 0;
    }
    try
    {
        lTotalWaitTime = (Long.parseLong(strTimeOut)) *1000;
    }
    catch(Exception e)
    {
        lTotalWaitTime = 0;
    }
    if(lTotalWaitTime<0)
    {
        lTotalWaitTime = 0;
    }
    com.matrixone.apps.domain.util.BackgroundProcess bgpObj = new com.matrixone.apps.domain.util.BackgroundProcess();
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), request.getLocale());
    try
    {
        String finalX               = "";
        String finalY               = "";
        String strReportState       = "";
        String strRepState          = "";
        String strLabelDirection    = "";
        String strDraw3D            = "";
        wrapColSize                 = emxGetParameter(request, "wrapColSize");
        suiteKey                    = emxGetParameter(request, "suiteKey");
        String strMode              = emxGetParameter(request,"mode");
        String timeStamp            = emxGetParameter(request,"timeStamp");
        String launchtimeStamp      = emxGetParameter(request,"launchtimeStamp");
        String strFromDisplayFormat = emxGetParameter(request,"fromDisplayFormat");
        String strReportName        = emxGetParameter(request,"reportName","UTF-8");
        String strDecodedReportName = (String) request.getAttribute("decodedReportName");
        String strRefresh           = emxGetParameter(request,"refreshMode");
        String strDefaultReport     = emxGetParameter(request,"defaultReport");
        String strType              = emxGetParameter(request,"txtTypeActual");
        String portalMode      = emxGetParameter(request,"portalMode");
        String portalOwner     = emxGetParameter(request,"portalOwner");
        String strOwner        = emxGetParameter(request,"owner", "UTF-8");
        String strContextUser  = context.getUser();
        String strBundle       = "emxMetricsStringResource";
        String lastCompletedIn = "";
        String lastRunDetails  = "";
        String subHeader       =    "";
        WebReport webReportObj = null;
        if(strMode.equalsIgnoreCase("reportDisplay") && (strReportName==null || strReportName.equals("null") || strReportName.equals("")))
        {
            strReportName = "";
        }

        // coming from "Launch" button in Dashboard page ??
        String launched       = emxGetParameter(request, "launched");

        if("true".equalsIgnoreCase(portalMode) || "true".equalsIgnoreCase(launched)){
            if(portalOwner != null && (portalOwner.length() > 0) ){
                strOwner = portalOwner;
            }
        }

        StringBuffer strTitle   = new StringBuffer("");
        HashMap xValuesMap          = new HashMap();
        HashMap yValuesMap          = new HashMap();
        HashMap hmReqFieldsMap      = new HashMap();
        HashMap requestMap          = new HashMap();
        HashMap hmWebReportDataMap  = new HashMap();
        Map hmResultTable       = new TreeMap();
        Map chartDetailsMap     = null;
        hmWebReportDataMap.put("timezone",new Double((String)session.getAttribute("timeZone")) );
        hmWebReportDataMap.put(metricsReportBean.MODE,strMode);
        hmWebReportDataMap.put(metricsReportBean.WEBREPORT_NAME,strReportName);
		 strActualContainedIn  = (String)requestMap.get("txtActualContainedIn");

        if (strMode == null || "null".equals(strMode) || "".equals(strMode)) {
            strMode = metricsReportBean.CRITERIA_UPDATE;
        }

        if ("reportView".equals(strMode) || "true".equalsIgnoreCase(launched)) {
            StringList strDatesList = metricsReportBean.getFromAndToDates(context,strReportName,strOwner);
            strFromDate = (String) strDatesList.get(0);
            fromDateObj = new java.util.Date(strFromDate);
            strFromDate = sdf.format(fromDateObj);
            strToDate = (String) strDatesList.get(1);
            toDateObj = new java.util.Date(strToDate);
            strToDate = sdf.format(toDateObj);
            if(strType == null)
            {
                strType = metricsReportBean.getFormFieldValue(context, strReportName, strOwner, "txtTypeActual", strDefaultReport, timeStamp);
            }

            StringList whichFields = new StringList();
            whichFields.add("chartType");
            whichFields.add("liststate");
            whichFields.add("optDateUnit");
            whichFields.add("labelDirection");
            whichFields.add("draw3D");
            //hmReqFieldsMap = metricsReportBean.readNotesXML(context, strReportName, whichFields);
            hmReqFieldsMap = metricsReportBean.readNotesXML(context, strReportName, strOwner, strDefaultReport, timeStamp, whichFields);
            strDateUnit = (String)hmReqFieldsMap.get("optDateUnit");
            String notesXML = metricsReportBean.getParsedNotes(context, strReportName, strOwner, strDefaultReport, timeStamp);
            wrapColSize = metricsReportBean.getParamDataFromNotesXML(notesXML, "wrapColSize");
            strReportState = (String) hmReqFieldsMap.get("liststate");
            strLabelDirection = (String) hmReqFieldsMap.get("labelDirection");
            strDraw3D         = (String) hmReqFieldsMap.get("draw3D");
            strChartType = emxGetParameter(request,"chartType");
            strReportState = metricsReportBean.getRequiredVal(strReportState);
            // WHEN MODE = REPORTVIEW CHARTTYPE WILL BE NULL
            if("true".equalsIgnoreCase(launched)){
                strMode = "reportView";
                hmWebReportDataMap.put(metricsReportBean.MODE,strMode);
            }

            if (strChartType == null && (!"reportDisplay".equals(strMode))){
                strChartType = (String) hmReqFieldsMap.get("chartType");
                strChartType = metricsReportBean.getRequiredVal(strChartType);
            }
            if((strRefresh != null) &&(!strRefresh.equals("")) && (strRefresh.equals("true"))){
                hmWebReportDataMap.put("refreshMode",strRefresh);
            }
            hmWebReportDataMap.put(metricsReportBean.TIME_STAMP,timeStamp);
            hmWebReportDataMap.put(metricsReportBean.WEBREPORT_TYPE,strDefaultReport);
            try{
                ContextUtil.startTransaction(context,true);
                webReportObj = new WebReport(strReportName, strOwner);
                if(hmWebReportDataMap!=null) {
                    hmWebReportDataMap.put("WebReportObject",webReportObj);
                }
                ContextUtil.commitTransaction(context);
            }catch (Exception ex){
                ContextUtil.abortTransaction(context);
            }


            if((strRefresh != null) &&(!strRefresh.equals("")) && (strRefresh.equals("true"))){
                strConfirmMsg+= webReportObj.getName();
                //start a separate transaction to set the InUse property
                try
                {
                    ContextUtil.startTransaction(context, true);
                    metricsReportBean.setWebReportProperty(context,webReportObj.getName(),webReportObj.getOwner(),metricsReportBean.PROPERTY_IN_USE,"true");
                    ContextUtil.commitTransaction(context);
                }
                catch(Exception e)
                {
                    ContextUtil.abortTransaction(context);
                    throw new FrameworkException("Can not set the InUse Property, contact your administrator");
                }
                try{
                    Context frameContext = Framework.getFrameContext(session);
                    Object objectArray[] = {frameContext,hmWebReportDataMap,strOwner};
                    Class objectTypeArray[] = {frameContext.getClass(),hmWebReportDataMap.getClass(),strOwner.getClass()};
                    bgpObj.submitJob(frameContext,metricsReportBean,"processWebReportInBackGround",objectArray,objectTypeArray);
                } catch (Exception ex){
                    ContextUtil.startTransaction(context, true);
                    metricsReportBean.removeWebReportProperty(context,webReportObj.getName(),webReportObj.getOwner(),metricsReportBean.PROPERTY_IN_USE);
                    ContextUtil.commitTransaction(context);
                    throw new Exception (ex.toString());
                }

                long startTime = System.currentTimeMillis();
                long actualEndTime = startTime+lTotalWaitTime;
                while(System.currentTimeMillis()<=actualEndTime)
                {
                    hmResultTable = metricsReportBean.checkForArchiveCreation(context,webReportObj,metricsReportBean.DOT_EMX_PREFIX + timeStamp);
                    Thread.sleep(lPolingTime);
                    if(hmResultTable!=null)
                    {
                        bViewNow = true;
                        break;
                    }
                }

                if(!bViewNow)
                {
                    metricsReportBean.setWebReportProperty(context,strReportName,strOwner,"metrics_" + metricsReportBean.DOT_EMX_PREFIX + timeStamp + "Grabbed","false");
    %>
                    <script language="javascript">
                        alert("<%=strConfirmMsg%>");//XSSOK
                        if(parent.getTopWindow() && "<xss:encodeForJavaScript><%=strPortalMode%></xss:encodeForJavaScript>"!="true")
                        {
                            parent.getTopWindow().closeWindow();
                        }
                    </script>
    <%
                } else {
                    metricsReportBean.setWebReportProperty(context,strReportName,strOwner,"metrics_" + metricsReportBean.DOT_EMX_PREFIX + timeStamp + "Grabbed","true");
                }
            }
            else if(!"true".equals(strFromDisplayFormat))
            {
                hmResultTable = metricsReportBean.processWebReport(context,hmWebReportDataMap,strOwner);
                bViewNow = true;
            }
        }

        if (!"reportView".equals(strMode)) {
            if(strMode.equals(metricsReportBean.CRITERIA_UPDATE)){
                requestMap = UINavigatorUtil.getRequestParameterMap(request);
            }
            else if(strMode.equals(metricsReportBean.REPORT_DISPLAY)){
                if((launchtimeStamp!=null) && (!(launchtimeStamp.equals("")))){
                    requestMap = metricsReportBean.getReportDialogData(launchtimeStamp);
                }else{
                    requestMap = metricsReportBean.getReportDialogData(timeStamp);
                }
            }
            String userName          = context.getUser();
            strType                  = (String)requestMap.get("txtTypeActual");
            String strPolicy         = (String)requestMap.get("listpolicy");
            strReportState           = (String)requestMap.get("liststate");
            strFromDate              = (String)requestMap.get("txtFromDate_msvalue");
            strToDate                = (String)requestMap.get("txtToDate_msvalue");
            String strPeriod         = (String)requestMap.get("txtPeriod");
            String strPeriodOption   = (String)requestMap.get("optPeriod");
            strDateUnit              = (String)requestMap.get("optDateUnit");
            String strWebReportName  = (String)requestMap.get("reportName");
            strLabelDirection        = (String)requestMap.get("labelDirection");
            strDraw3D                = (String)requestMap.get("draw3D");
    
			  strActualContainedIn     = (String)requestMap.get("txtActualContainedIn");
			  String whereClause   = metricsReportBean.getAdvanceSearchWhereExpression(context,requestMap);

			  HashMap searchList = new HashMap();
    
            if("true".equals(strFromDisplayFormat)) {
                strChartType = emxGetParameter(request,"chartType");
            }
            else{
                strChartType = (String)requestMap.get("chartType");
            }

            if(strChartType == null || strChartType.equals("null") || strChartType.equals("")){
                strChartType = "";
            }

            if(strType == null || strType.equals("null") || strType.equals("")){
                strType = "";
            }

            if(strPolicy == null || strPolicy.equals("null") || strPolicy.equals("")){
                strPolicy = "";
            }

            if(strReportState == null || strReportState.equals("null") || strReportState.equals("")){
                strReportState = "";
            }

			 if(strActualContainedIn == null || "null".equalsIgnoreCase(strActualContainedIn) || "".equalsIgnoreCase(strActualContainedIn)){
            strActualContainedIn = "";
            }

            if(strFromDate == null || strFromDate.equals("null") || strFromDate.equals("")){
                strFromDate = "";
            }

            if(strToDate == null || strToDate.equals("null") || strToDate.equals("")){
                strToDate = "";
            }

            if(strPeriodOption == null || strPeriodOption.equals("null") || strPeriodOption.equals("")){
                strPeriodOption = "";
            }

            if(strPeriod == null || strPeriod.equals("null") || strPeriod.equals("")){
                strPeriod = "";
            }

            if(strDateUnit == null || strDateUnit.equals("null") || strDateUnit.equals("")){
                strDateUnit = "";
            }

            if(strWebReportName == null || strWebReportName.equals("null") || strWebReportName.equals("")){
                strWebReportName = "";
            }

            if(strPeriodOption.equalsIgnoreCase("DateWise")){
                fromDateObj = new java.util.Date(Long.parseLong(strFromDate));
                strFromDate = sdf.format(fromDateObj);
                toDateObj = new java.util.Date(Long.parseLong(strToDate));
                strToDate = sdf.format(toDateObj);
            } else {
                // From Date and To Date handling
                java.util.Date currentDateObj = new java.util.Date(System.currentTimeMillis());
                Date dtFromDate    =  metricsReportBean.computeFromDate(strDateUnit, Integer.parseInt(strPeriod));
                strFromDate        =  sdf.format(dtFromDate);
                strToDate          =  sdf.format(currentDateObj);
                fromDateObj = dtFromDate;
                toDateObj = currentDateObj;
            }

            strFromDate = strFromDate.substring(0,strFromDate.indexOf(" "));
            strToDate = strToDate.substring(0,strToDate.indexOf(" "));
            StringBuffer sbSearchCriteria  = new StringBuffer("");
			
			sbSearchCriteria=null;

			String reportType = "CountInStateOverTime";
			searchList.put("strContainedIn",strActualContainedIn);
			searchList.put("strType",strType);
			searchList.put("strPolicy",strPolicy);
			searchList.put("strReportState",strReportState);
			searchList.put("strFromDate",strFromDate);
			searchList.put("strToDate",strToDate);
			searchList.put("whereClause",whereClause);
			sbSearchCriteria = metricsReportBeanUI.formContainedInCriteria(context,searchList,reportType);

            StringBuffer sbGroupBy = new StringBuffer();
            sbGroupBy.append("dateperiod y");
            sbGroupBy.append(strDateUnit.toLowerCase());
            sbGroupBy.append(" current.actual");
            ExpressionList groupByExprList = new ExpressionList();
            Expression groupByExpr = new Expression();
            groupByExpr.setValue(sbGroupBy.toString());
            groupByExprList.addElement(groupByExpr);

            hmWebReportDataMap.put(metricsReportBean.SEARCH_CRITERIA,sbSearchCriteria.toString());
            hmWebReportDataMap.put(metricsReportBean.WEBREPORT_TYPE,strDefaultReport);
            hmWebReportDataMap.put(metricsReportBean.TIME_STAMP,timeStamp);
            hmWebReportDataMap.put(metricsReportBean.GROUPBY_EXPRRESSION_LIST,groupByExprList);
            hmWebReportDataMap.put(metricsReportBean.DISPLAY_FORMAT,strChartType);
            if("criteriaUpdate".equalsIgnoreCase(strMode))
            {
                hmWebReportDataMap.put(metricsReportBean.WEBREPORT_NAME,strDecodedReportName);
                hmResultTable = metricsReportBean.processWebReport(context,hmWebReportDataMap,strOwner);
            }

            try
            {
                StringBuffer sbemxWebReport = new StringBuffer();
                sbemxWebReport.append(metricsReportBean.DOT_EMX_PREFIX);
                sbemxWebReport.append(strDefaultReport);
                sbemxWebReport.append(timeStamp);

                try
                {
                    ContextUtil.startTransaction(context,false);
                    if(strReportName == null || "".equals(strReportName) || "null".equalsIgnoreCase(strReportName))
                    {
                        webReportObj = new WebReport(sbemxWebReport.toString(), strContextUser);
                    }
                    else if(strReportName != null && !strReportName.equals("") && !"null".equalsIgnoreCase(strReportName))
                    {
                        webReportObj = new WebReport(strReportName, strOwner);
                    }
                    ContextUtil.commitTransaction(context);

                    if(hmWebReportDataMap!=null)
                    {
                         hmWebReportDataMap.put("WebReportObject",webReportObj);
                    }
                    ContextUtil.commitTransaction(context);
                }
                catch(Exception ex)
                {
                    ContextUtil.abortTransaction(context);
                    throw new Exception(ex.toString());
                }

                if(!"criteriaUpdate".equalsIgnoreCase(strMode))
                {
                    String tempName = "";
                    String wbReportName = webReportObj.getName();
                    if(webReportObj != null && ((webReportObj.getName()).indexOf(metricsReportBean.DOT_EMX_PREFIX)==-1) ){
                        tempName = webReportObj.getName();
                    } else {
                        tempName = strDefaultReport+"_"+timeStamp;
                    }
                    strConfirmMsg+=tempName;
                    //start a separate transaction to set the InUse property
                    try
                    {
                        ContextUtil.startTransaction(context, true);
                        metricsReportBean.setWebReportProperty(context,webReportObj.getName(),webReportObj.getOwner(),metricsReportBean.PROPERTY_IN_USE,"true");
                        ContextUtil.commitTransaction(context);
                    }
                    catch(Exception e)
                    {
                        ContextUtil.abortTransaction(context);
                        throw new FrameworkException("Can not set the InUse Property, contact your administrator");
                    }
                    try{
                        //use new context
                        Context frameContext = Framework.getFrameContext(session);
                        Object objectArray[] = {frameContext,hmWebReportDataMap,strOwner};
                        Class objectTypeArray[] = {frameContext.getClass(),hmWebReportDataMap.getClass(),strOwner.getClass()};
                        bgpObj.submitJob(frameContext, metricsReportBean,"processWebReportInBackGround",objectArray,objectTypeArray);
                    } catch (Exception ex){
                        ContextUtil.startTransaction(context, true);
                        metricsReportBean.removeWebReportProperty(context,webReportObj.getName(),webReportObj.getOwner(),metricsReportBean.PROPERTY_IN_USE);
                        ContextUtil.commitTransaction(context);
                        throw new Exception (ex.toString());
                    }

                    long startTime = System.currentTimeMillis();
                    long actualEndTime = startTime+lTotalWaitTime;
                    while(System.currentTimeMillis()<=actualEndTime)
                    {
                        hmResultTable = metricsReportBean.checkForArchiveCreation(context,webReportObj,metricsReportBean.DOT_EMX_PREFIX + timeStamp);

                        if(hmResultTable!=null)
                        {
                            bViewNow = true;
                            break;
                        }

                        Thread.sleep(lPolingTime);
                    }

                    if(!bViewNow)
                    {
                        metricsReportBean.setWebReportProperty(context,webReportObj.getName(),webReportObj.getOwner(),"metrics_" + metricsReportBean.DOT_EMX_PREFIX + timeStamp + "Grabbed","false");
    %>
                        <script language="javascript">
                            alert("<%=XSSUtil.encodeForJavaScript(context, strConfirmMsg)%>");
                            if(parent.getTopWindow() && "<xss:encodeForJavaScript><%=strPortalMode%></xss:encodeForJavaScript>"!="true")
                            {
                                parent.getTopWindow().closeWindow();
                            }
                        </script>
    <%
                    } else {
                        metricsReportBean.setWebReportProperty(context,webReportObj.getName(),webReportObj.getOwner(),"metrics_" + metricsReportBean.DOT_EMX_PREFIX + timeStamp + "Grabbed","true");
                    }
                }
            }
            catch(Exception ex)
            {

                if(ex.toString() != null && (ex.toString().trim()).length()>0)
                {
                     emxNavErrorObject.addMessage("Object Count Report Results Failed :" + ex.toString().trim());
                }
            }
        }

    //======================The logic to display the chart==========================

        if(!(strMode.equals("criteriaUpdate"))) {
            if(hmResultTable != null && hmResultTable.size()>=0 && strMode.equals("reportDisplay")){
                lastCompletedIn = metricsReportBean.getCompletedInDuration(context,strReportName,strOwner,strDefaultReport,timeStamp);
                lastRunDetails = metricsReportBean.getLastRunDetails(context,strReportName,strOwner,strDefaultReport,strMode,timeStamp);
                //DisplayTime
                boolean bDisplayTime = PersonUtil.getPreferenceDisplayTimeValue(context);

                //DateFormat
                int iDateFormat = PersonUtil.getPreferenceDateFormatValue(context);

                //ClientTimeOffset
                String timeZone = (String)session.getValue("timeZone");
                double iClientTimeOffset   = (new Double(timeZone)).doubleValue();

                //Formatting Date to Ematrix Date Format
                String formattedDisplayDateValue = eMatrixDateFormat.getFormattedDisplayDateTime(context, lastRunDetails, bDisplayTime,
                                                    iDateFormat, iClientTimeOffset,request.getLocale());

                //Creation of the SubHeader String
                subHeader = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.SubHeadingLastRun") + formattedDisplayDateValue + " | "
                            + EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.SubHeadingCompletedIn") + " " + lastCompletedIn +
                            EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.SubHeadingHrsMinSecs");
                //Setting the SubHeader to the Session Map for printer friendly
                metricsReportBean.setSubHeader(timeStamp,subHeader);
            }
            else if(hmResultTable != null && hmResultTable.size()>=0 && strMode.equals("reportView") && ("true".equals(strRefresh) || metricsReportBean.hasResult(context,strReportName,strOwner)) || ("true".equals(strFromDisplayFormat)))
            {
                lastCompletedIn = metricsReportBean.getCompletedInDuration(context,strReportName,strOwner,strDefaultReport,timeStamp);
                lastRunDetails = metricsReportBean.getLastRunDetails(context,strReportName,strOwner,strDefaultReport,strMode,timeStamp);

                //DisplayTime
                boolean bDisplayTime = PersonUtil.getPreferenceDisplayTimeValue(context);

                //DateFormat
                int iDateFormat = PersonUtil.getPreferenceDateFormatValue(context);

                //ClientTimeOffset
                String timeZone = (String)session.getValue("timeZone");
                double iClientTimeOffset   = (new Double(timeZone)).doubleValue();

                //Formatting Date to Ematrix Date Format
                String formattedDisplayDateValue = eMatrixDateFormat.getFormattedDisplayDateTime(context, lastRunDetails, bDisplayTime, iDateFormat,
                                                   iClientTimeOffset,request.getLocale());

                //Creation of the SubHeader String
                subHeader = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.SubHeadingLastRun") + formattedDisplayDateValue + " | "
                            + EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.SubHeadingCompletedIn") + " " + lastCompletedIn +
                            EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.SubHeadingHrsMinSecs");

                //Setting the SubHeader to the Session Map for printer friendly
                metricsReportBean.setSubHeader(timeStamp,subHeader);
            }
%>
        <script type="text/javascript" language="JavaScript">
            var heading = getTopWindow().document.getElementById("pageSubTitle");
            if(heading && (heading != "" || heading != null || heading != "null"))
            {
            	//XSSOK
                heading.innerHTML = "<%=subHeader%>";
            }
        </script>
<%
            if(((hmResultTable==null) || (hmResultTable!=null && hmResultTable.size() == 0)) && (strMode.equals("reportDisplay") || "true".equalsIgnoreCase(strRefresh))) {
                strNoResult = EnoviaResourceBundle.getProperty(context, "emxMetricsStringResource",context.getLocale(), "emxMetrics.ErrorMsg.NoData");
                //To add the NoResult message to the session Map to display in Printer friendly page
                metricsReportBean.setResultString(timeStamp,strNoResult);
%>
            <table>
                <tr>
                    <td>&nbsp;&nbsp;</td><td>&nbsp;&nbsp;</td>
                    <td style="text-align:center">
                        <b><%=strNoResult%></b>
                    </td>
                </tr>
            </table>
            <script type="text/javascript" language="JavaScript">
                parent.enableFunctionality(parent.STR_METRICS_SAVE_COMMAND,false);
                parent.enableFunctionality(parent.STR_METRICS_SAVE_AS_COMMAND,false);
                parent.enableFunctionality(parent.STR_METRICS_DISPLAYFORMAT,false);
            </script>
<%
            }
            else if((hmResultTable!=null && hmResultTable.size() == 0 && strMode.equals("reportView") && (!"true".equalsIgnoreCase(strRefresh))) && (!"true".equals(strFromDisplayFormat))) {
                if(metricsReportBean.hasResult(context,strReportName,strOwner))
                {
                    strNoResult = EnoviaResourceBundle.getProperty(context, "emxMetricsStringResource",context.getLocale(), "emxMetrics.ErrorMsg.NoData");
                }
                else
                {
                    strNoResult = EnoviaResourceBundle.getProperty(context, "emxMetricsStringResource",context.getLocale(), "emxMetrics.ErrorMsg.NoResultSet");
                }
                //To add the NoResult message to the session Map to display in Printer friendly page
                metricsReportBean.setResultString(timeStamp,strNoResult);
%>
                <table>
                    <tr>
                        <td>&nbsp;&nbsp;</td><td>&nbsp;&nbsp;</td>
                        <td>
                            <b><%=strNoResult%></b>
                        </td>
                    </tr>
                </table>
                <script type="text/javascript" language="JavaScript">
                    parent.enableFunctionality(parent.STR_METRICS_SAVE_COMMAND,false);
                    parent.enableFunctionality(parent.STR_METRICS_SAVE_AS_COMMAND,false);
                    parent.enableFunctionality(parent.STR_METRICS_DISPLAYFORMAT,false);
                </script>
<%
            }
            else
            {
                if(strMode.equals(metricsReportBean.REPORT_DISPLAY) || strMode.equals("reportView")){
                    if ((hmResultTable!=null) && (hmResultTable.size()>0) || ("true".equals(strFromDisplayFormat))){
                        if("true".equalsIgnoreCase(strRefresh)){
                            StringList strList = new StringList();
                            strList.add("chartType");
                            HashMap chartDetails = metricsReportBean.readNotesXML(context, strReportName, strOwner, strDefaultReport, "", strList);
                            String strChartDetails = (String)chartDetails.get("chartType");
                            StringList strChartList = FrameworkUtil.split(strChartDetails,",");
                            for(int l=0; l < strChartList.size(); l++) {
                                String basicStr = (String) strChartList.get(l);
                                if(basicStr.indexOf("true")>0){
                                    strChartType = basicStr.substring(1,basicStr.indexOf(":"));
                                    break;
                                }
                            }
%>
                            <script type="text/javascript" language="JavaScript">
                                parent.enableFunctionality(parent.STR_METRICS_SAVE_COMMAND,true);
                            </script>
<%
                        }
                        try {
                            if(!"true".equals(strFromDisplayFormat)){
                            chartDetailsMap = metricsReportBean.getObjectCountInStateValuesMap(context, hmResultTable, strDateUnit, fromDateObj, toDateObj);
                            }else{
                                throw new FrameworkException("Changing display format");
                            }
                        }
                        catch(Exception e) {
                            if("true".equals(strFromDisplayFormat)){
                                Map resultsData = metricsReportBean.getResultsData(timeStamp);
                                if(resultsData != null && resultsData.size()>0) {
                                    chartDetailsMap = resultsData;
                                }
                            }
                        }
                    }

                    if ((chartDetailsMap!=null) && (chartDetailsMap.size()>0)){
                        metricsReportBean.setResultsData(timeStamp,chartDetailsMap);
                    }
%>
<body>
<%
                    if(!"Tabular".equalsIgnoreCase(strChartType))
                    {
                        ArrayList xValList = new ArrayList();
                        ArrayList xTitleList = new ArrayList();
                        ArrayList yTitleList = new ArrayList();
                        ArrayList yValList = new ArrayList();
                    
                        if(chartDetailsMap != null && chartDetailsMap.size()> 0){
                            ArrayList yAxisValues = (ArrayList) chartDetailsMap.get("YAxisValues");
                            ArrayList xAxisValues = (ArrayList) chartDetailsMap.get("XAxisValues");
                            for(int x=0; x<xAxisValues.size();x++){
                                finalX += (String) xAxisValues.get(x)+",";
                            }
                            for(int y=0; y<yAxisValues.size();y++){
                                finalY += (String) yAxisValues.get(y)+",";
                            }
                        }
                        //yValuesMap.put(strRepState,finalY);
                        if(strChartType.equalsIgnoreCase("LineChart"))
                        {
                           strChartType = "LabelLineChart";
                        }
                        if(strChartType.equalsIgnoreCase("PieChart")){
                            chartBean.setShowPercentage(false);
                            chartBean.setShowValues(true);
                        }
                        //xValuesMap.put("Periods",finalX);
                        xValList.add(finalX);
                        String xLabel = i18nNow.getI18nString("emxMetrics.label.Periods", metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE, strLanguage);
                        xTitleList.add(xLabel);
                        yValList.add(finalY);
                        yTitleList.add(metricsReportBeanUI.internationalizedValue(context,strType,"","",strReportState,"state"));
                        xValuesMap.put("Titles", xTitleList);
                        xValuesMap.put("Values", xValList);
                        yValuesMap.put("Titles", yTitleList);
                        yValuesMap.put("Values", yValList);
                        
                        chartBean.setChartType(strChartType);
                        chartBean.setDelimiter(",");
                        chartBean.setXAxis(xValuesMap);
                        chartBean.setYAxis(yValuesMap);
                        chartBean.setYAxisTitle(strYAxisTitle);
                        if("Horizontal".equalsIgnoreCase(strLabelDirection)){
                            chartBean.setLabelDirection("");
                        }else{
                            chartBean.setLabelDirection("Vertical");
                        }    
                        chartBean.setChartTitle("");
                        if("true".equalsIgnoreCase(strDraw3D)){
                            chartBean.set3D(true);
                        }else{
                            chartBean.set3D(false);
                        }    
                        //To add the XAxis and YAxis values of Chart to session Map for Printer Friendly
                        metricsReportBean.setXAxis(timeStamp,xValuesMap);
                        metricsReportBean.setYAxis(timeStamp,yValuesMap);
                        
                        //To add the LabelDirection and RenderOption values of Chart to session Map for Printer Friendly
                        metricsReportBean.setLabelDirection(timeStamp,strLabelDirection);
                        metricsReportBean.setRenderOption(timeStamp,strDraw3D);
%>
                        <jsp:include page = "../common/emxChartInclude.jsp" flush="true"></jsp:include>
<%
                }
                else
                {
                    //chartDetailsMap = metricsReportBean.getObjectCountInStateValuesMapForTabularFormat(context, chartDetailsMap, strDateUnit);
                    StringList rowHeaders = new StringList();
                    rowHeaders = metricsReportBeanUI.prepareObjectCountInStateRowHeaders(context, chartDetailsMap, requestMap);
                    StringList colHeaders = metricsReportBeanUI.prepareObjectCountInStateColumnHeaders(chartDetailsMap,requestMap);
                    Map hrefMap       = metricsReportBeanUI.prepareObjectCountInStateRowWiseHrefsMap(context, chartDetailsMap, rowHeaders.size(), colHeaders.size(), strDefaultReport, strReportName, strOwner, strType, strLanguage, timeStamp);
                    metricsReportBeanUI.setMetricsTabularFormatRowHeaders(rowHeaders);
                    metricsReportBeanUI.setMetricsTabularFormatColHeaders(colHeaders);
                    metricsReportBeanUI.setCustomHrefsForData(hrefMap);
                   if(blShowPercentage) { metricsReportBeanUI.setMessageText(EnoviaResourceBundle.getProperty(context, metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE,context.getLocale(), "emxMetrics.label.ObjectCountInStateTabularFormatMessage"));
                   }
                    metricsReportBeanUI.showTotalRow(false);
                    metricsReportBeanUI.showObjectCount(false);
                    metricsReportBeanUI.showDataHrefLink(true);
                    metricsReportBeanUI.showRowSeparator(false);
                    metricsReportBeanUI.showDiffInPercentage(blShowPercentage);
                    metricsReportBeanUI.setRowLimit(EnoviaResourceBundle.getProperty(context, "emxMetrics.Configuration.RowLimitResultsDisplay"));
                    metricsReportBeanUI.setColumnLimit(EnoviaResourceBundle.getProperty(context, "emxMetrics.Configuration.ColumnLimitResultsDisplay"));
                    metricsReportBeanUI.setWrapColumnSize(wrapColSize);
                    metricsReportBeanUI.setTabularFormatDataMap(metricsReportBeanUI.prepareObjectCountInStateRowWiseDataMap(chartDetailsMap));
                    metricsReportBeanUI.setMetricsTabularFormatData(timeStamp);
                    if((strReportName!=null && strReportName.length() != 0) || "true".equals(strFromDisplayFormat)){
                        strObjectDetails = metricsReportBeanUI.getObjectDetails(context,strReportName,strOwner,timeStamp);
                    }
%>
					<!-- XSSOK -->
                    <jsp:include page = "emxMetricsResultsTabularFormatDisplay.jsp" flush="true"><jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/><jsp:param name="wrapColSize" value="<%=XSSUtil.encodeForURL(context, wrapColSize)%>"/><jsp:param name="objectDetails" value="<%=strObjectDetails%>"/><jsp:param name="refresh" value="<%=XSSUtil.encodeForURL(context, strRefresh)%>"/></jsp:include>
<%
                }
            } // End of if condition
        } // End of else condition
    }
}
catch(Exception ex) {
    if(ex.toString() != null && (ex.toString().trim()).length()>0){
        emxNavErrorObject.addMessage("Object Count InState Report Results Failed :" + ex.toString().trim());
    }
}
%>
<form name ="ObjInStateResults">
    <input type="hidden" name="chartType" id="chartType" value="<xss:encodeForHTMLAttribute><%=strChartType%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="wrapColSize" id="wrapColSize" value="<xss:encodeForHTMLAttribute><%=wrapColSize%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="suiteKey" id="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="strYAxisTitle" id="strYAxisTitle" value="<%=strYAxisTitle%>" />
</form>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
