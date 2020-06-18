<%--  emxMetricsLifecycleDurationReportResults.jsp - Results page for Lifecycle Duration Report

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsLifecycleDurationReportResults.jsp.rca 1.44 Wed Oct 22 16:11:55 2008 przemek Experimental $
--%>


<%@page import="com.matrixone.apps.metrics.WebreportException"%>
<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
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

String strChartType = "";
String wrapColSize  = "";
String suiteKey     = "";
String strObjectDetails = "";
String strLanguage     = request.getHeader("Accept-Language");
String strYAxisTitle = EnoviaResourceBundle.getProperty(context, metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE,context.getLocale(), "emxMetrics.label.AvgDuration");
boolean bViewNow = false;
String strConfirmMsg = EnoviaResourceBundle.getProperty(context, metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE,context.getLocale(), "emxMetrics.AlertMsg.ReportGenerationDelay");
String strPolingTime  = EnoviaResourceBundle.getProperty(context, "emxMetrics.Background.Polling.TimeInterval");
String strTimeOut  = EnoviaResourceBundle.getProperty(context, "emxMetrics.Background.Polling.TimeOutLimit");
String strPortalMode = emxGetParameter(request,"portalMode");
long lPolingTime = 0;
long lTotalWaitTime = 0;
int decimalPrecision = 1;

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

try
{
	String strActualContainedIn="";
    String strFromDate = "";
    String strToDate = "";
    String portalMode    = emxGetParameter(request,"portalMode");
    String portalOwner    = emxGetParameter(request,"portalOwner");
    String strContextUser = context.getUser();
    String strBundle       = "emxMetricsStringResource";
    String strOwner        = emxGetParameter(request,"owner","UTF-8");

    // coming from "Launch" button in Dashboard page ??
    String launched       = emxGetParameter(request, "launched");

    if("true".equalsIgnoreCase(portalMode) || "true".equalsIgnoreCase(launched)){
        if(portalOwner != null && (portalOwner.length() > 0) ){
            strOwner = portalOwner;
        }
    }

    String strRefresh       = emxGetParameter(request,"refreshMode");
    wrapColSize             = emxGetParameter(request, "wrapColSize");
    suiteKey                = emxGetParameter(request, "suiteKey");
    String strMode          = emxGetParameter(request,"mode");
    String timeStamp        = emxGetParameter(request,"timeStamp");
    String launchtimeStamp  = emxGetParameter(request,"launchtimeStamp");
    String strReportName    = emxGetParameter(request,"reportName", "UTF-8");
    
    String strDecodedReportName = (String) request.getAttribute("decodedReportName");
    String strFromDisplayFormat = emxGetParameter(request,"fromDisplayFormat");
    strChartType            = emxGetParameter(request,"chartType");
    String strDefaultReport  = emxGetParameter(request,"defaultReport");
    String strType           = emxGetParameter(request,"txtTypeActual");
    String strLabelDirection   = "";
    String strDraw3D           = "";
    String finalX           = "";
    String strTargetState   = "";
    String strFromState     = "";
    String strToState       = "";
    String remainingString  = "";
    String strFinalStates   = "";
    String strDateUnit      = "";
    String strNoResult      = "";
    String strPolicyfield   = "txtPolicyActual";
    String strPolicyValue   = emxGetParameter(request,strPolicyfield);
    StringBuffer strTitle   = new StringBuffer("");
    HashMap xValuesMap         = new HashMap();
    HashMap yValuesMap         = new HashMap();
    HashMap requestMap         = new HashMap();
    HashMap hmReqFieldsMap     = new HashMap();
    HashMap hmWebReportDataMap = new HashMap();
    Map hmResulttable      = new TreeMap();
    Map chartDetailsMap    = null;
    StringList eachStateName   = new StringList();
    StringList strListPolicy  = new StringList();
    StringList archives = null;
    String lastCompletedIn = "";
    String lastRunDetails  = "";
    String subHeader =    "";
    WebReport webReportObj = null;
	strActualContainedIn       = (String)requestMap.get("txtActualContainedIn");

     String strShowPercentage = emxGetParameter(request,"showPercentage");
     boolean blShowPercentage = false;
     if (!"false".equalsIgnoreCase(strShowPercentage))
     {
         blShowPercentage=true;
     }

    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);

    if(strMode.equalsIgnoreCase("reportDisplay") && (strReportName==null || strReportName.equals("null") || strReportName.equals("")))
    {
        strReportName = "";
    }
    hmWebReportDataMap.put("timezone",new Double((String)session.getAttribute("timeZone")) );
    hmWebReportDataMap.put(metricsReportBean.MODE,strMode);
    hmWebReportDataMap.put(metricsReportBean.WEBREPORT_NAME,strReportName);

    if (strMode == null || "null".equals(strMode) || "".equals(strMode)) {
        strMode = "criteriaUpdate";
    }
    if(strPolicyValue == null)
    {
        strPolicyValue = metricsReportBean.getFormFieldValue(context, strReportName, strOwner, strPolicyfield, strDefaultReport, timeStamp);
    }
    strListPolicy = FrameworkUtil.split(strPolicyValue,",");
    if(strMode.equals("criteriaUpdate")) {
        requestMap = UINavigatorUtil.getRequestParameterMap(request);
    }
    if(strMode.equals("reportDisplay")) {
        if((launchtimeStamp!=null) && (!(launchtimeStamp.equals("")))){
            requestMap = metricsReportBean.getReportDialogData(launchtimeStamp);
        }else{
            requestMap = metricsReportBean.getReportDialogData(timeStamp);
        }
    }
    else if("reportView".equals(strMode) && strPolicyValue != null && !"null".equals(strPolicyValue)) {
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
        whichFields.add("lstTargetState");
        whichFields.add("lstFromState");
        whichFields.add("lstToState");
        whichFields.add("optDateUnit");
        whichFields.add("labelDirection");
        whichFields.add("draw3D");
        String notesXML = metricsReportBean.getParsedNotes(context, strReportName, strOwner, strDefaultReport, timeStamp);
        wrapColSize = metricsReportBean.getParamDataFromNotesXML(notesXML, "wrapColSize");
        hmReqFieldsMap = metricsReportBean.readNotesXML(context, strReportName, strOwner, strDefaultReport, timeStamp, whichFields);
        strDateUnit    = (String) hmReqFieldsMap.get("optDateUnit");
        strLabelDirection = (String) hmReqFieldsMap.get("labelDirection");
        strDraw3D         = (String) hmReqFieldsMap.get("draw3D");
        strTargetState = (String) hmReqFieldsMap.get("lstTargetState");
        strFromState   = (String) hmReqFieldsMap.get("lstFromState");
        strToState     = (String) hmReqFieldsMap.get("lstToState");
        strFromState   = metricsReportBean.getRequiredVal(strFromState);
        strToState     = metricsReportBean.getRequiredVal(strToState);
        StringBuffer stateNameBuffer = new StringBuffer();
        StringTokenizer strStatTokenizer = new StringTokenizer(strTargetState,"|");
        while(strStatTokenizer.hasMoreTokens()) {
            String strStateVal = (String) strStatTokenizer.nextToken();
            String requiredValue = strStateVal.substring(strStateVal.indexOf("\"")+1,strStateVal.indexOf(":"));
            stateNameBuffer.append(requiredValue);
            stateNameBuffer.append(",");
        }
        String totalStates = stateNameBuffer.toString();
        if(totalStates != null) {
            totalStates = FrameworkUtil.decodeURL(totalStates,"UTF-8");
            remainingString = totalStates.substring(totalStates.indexOf(strFromState), totalStates.length());
            strFinalStates = remainingString.substring(0,remainingString.indexOf(strToState)+strToState.length());
        }
        eachStateName = FrameworkUtil.split(strFinalStates,",");
        // WHEN MODE = REPORTVIEW CHARTTYPE WILL BE NULL
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
                hmResulttable = metricsReportBean.checkForArchiveCreation(context,webReportObj,metricsReportBean.DOT_EMX_PREFIX + timeStamp);
                Thread.sleep(lPolingTime);
                if(hmResulttable!=null)
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
            hmResulttable = metricsReportBean.processWebReport(context,hmWebReportDataMap,strOwner);
        }
    }
         String whereClause   = metricsReportBean.getAdvanceSearchWhereExpression(context,requestMap);
    if (!"reportView".equals(strMode)){
        String userName          = context.getUser();
        strType                  = (String)requestMap.get("txtTypeActual");
        strPolicyValue           = (String)requestMap.get("txtPolicyActual");
        strTargetState           = (String)requestMap.get("lstTargetState");
        strFromState             = (String)requestMap.get("lstFromState");
        strToState               = (String)requestMap.get("lstToState");
        String allStates         = (String)requestMap.get("hdnAllStates");
        strFromDate       = (String)requestMap.get("txtFromDate_msvalue");
        strToDate         = (String)requestMap.get("txtToDate_msvalue");
        String strPeriod         = (String)requestMap.get("txtPeriod");
        String strPeriodOption   = (String)requestMap.get("optPeriod");
        strDateUnit              = (String)requestMap.get("optDateUnit");
        String strWebReportName  = (String)requestMap.get("reportName");
        strDefaultReport         = (String)requestMap.get("defaultReport");
        strLabelDirection        = (String)requestMap.get("labelDirection");
        strDraw3D                = (String)requestMap.get("draw3D");
        strActualContainedIn     = (String)requestMap.get("txtActualContainedIn");
        whereClause   = metricsReportBean.getAdvanceSearchWhereExpression(context,requestMap); //1
		HashMap searchList = new HashMap();
        if(!("true".equals(strFromDisplayFormat))){
            strChartType         = (String)requestMap.get("chartType");
        }

        if(strType == null || strType.equals("null") || strType.equals("")){
            strType = "";
        }
		 if(strActualContainedIn == null || "null".equalsIgnoreCase(strActualContainedIn) || "".equalsIgnoreCase(strActualContainedIn)){
            strActualContainedIn = "";
        }

        if(strPolicyValue == null || strPolicyValue.equals("null") || strPolicyValue.equals("")){
            strPolicyValue = "";
        }

        if(strTargetState == null || strTargetState.equals("null") || strTargetState.equals("")){
            strTargetState = "";
        }

        if(strFromState == null || strFromState.equals("null") || strFromState.equals("")){
            strFromState = "";
        }

        if(strToState == null || strToState.equals("null") || strToState.equals("")){
            strToState = "";
        }

        if(strFromDate == null || strFromDate.equals("null") || strFromDate.equals("")){
            strFromDate = "";
        }

        if(strToDate == null || strToDate.equals("null") || strToDate.equals("")){
            strToDate = "";
        }

        if(strPeriod == null || strPeriod.equals("null") || strPeriod.equals("")){
            strPeriod = "";
        }

        if(strDateUnit == null || strDateUnit.equals("null") || strDateUnit.equals("")){
            strDateUnit = "";
        }

        if(strChartType == null || strChartType.equals("null") || strChartType.equals("")){
            strChartType = "";
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
        strFromDate        = strFromDate.substring(0,strFromDate.indexOf(" "));
        strToDate          = strToDate.substring(0,strToDate.indexOf(" "));
        strListPolicy = FrameworkUtil.split(strPolicyValue,",");

        StringBuffer sbSearchCriteria  = new StringBuffer("");
       

		/* Start of Adding a new method for adding ContainedIn functionality in BPM Reports */
		sbSearchCriteria=null;
				
		String reportType = "LifeCycleDurationOverTime";
		searchList.put("strContainedIn",strActualContainedIn);
		searchList.put("strType",strType);
		searchList.put("strPolicy",strPolicyValue);
		searchList.put("strTargetState",strTargetState);
		searchList.put("strFromDate",strFromDate);
		searchList.put("strToDate",strToDate);
		searchList.put("strListPolicy",strListPolicy);
		searchList.put("whereClause",whereClause);
		sbSearchCriteria = metricsReportBeanUI.formContainedInCriteria(context,searchList,reportType);
			/* end of Adding a new method for adding ContainedIn functionality in BPM Reports */

        // Group by expression is specific to individual pages so build it here only and
        //send it to bean For setting group by
        StringBuffer sbFirstGroupBy = new StringBuffer();
        sbFirstGroupBy.append("current");
        StringBuffer sbSecondGroupBy = new StringBuffer();
        sbSecondGroupBy.append("dateperiod y");
        sbSecondGroupBy.append(strDateUnit.toLowerCase());
        sbSecondGroupBy.append(" current.actual");
        ExpressionList groupByExprList = new ExpressionList();
        Expression groupByExpr1 = new Expression();
        Expression groupByExpr2 = new Expression();
        groupByExpr1.setValue(sbFirstGroupBy.toString());
        groupByExpr2.setValue(sbSecondGroupBy.toString());
        groupByExprList.addElement(groupByExpr1);
        groupByExprList.addElement(groupByExpr2);

        // For setting data expression
        // Since "allStates" will be a comma separated values of all the states, filter
        // out the data value the states from "from state" and "to state" and add it to
        if(allStates != null && !"null".equals(allStates) && !"".equals(allStates)){
            remainingString = allStates.substring(allStates.indexOf(strFromState), allStates.length());
            strFinalStates = remainingString.substring(0,remainingString.indexOf(strToState)+strToState.length());
        }

        ExpressionList dataExprList = new ExpressionList();
        StringTokenizer stStates = new StringTokenizer(strFinalStates,",");
        int stateCount = 1;
        HashMap stateMap = new HashMap();
        while(stStates != null && stStates.hasMoreTokens()){
            Expression dataExpr = new Expression();
            StringBuffer sbDataValue = new StringBuffer();
            String eachState = stStates.nextToken();
            sbDataValue.append("average state[");
            sbDataValue.append(eachState);
            sbDataValue.append("].duration ");
            dataExpr.setValue(sbDataValue.toString());
            dataExprList.addElement(dataExpr);
            stateMap.put(new Integer(stateCount),eachState);
            eachStateName.add(eachState);
            stateCount++;
        }
        hmWebReportDataMap.put(metricsReportBean.SEARCH_CRITERIA,sbSearchCriteria.toString());
        hmWebReportDataMap.put(metricsReportBean.WEBREPORT_TYPE,strDefaultReport);
        hmWebReportDataMap.put(metricsReportBean.TIME_STAMP,timeStamp);
        hmWebReportDataMap.put(metricsReportBean.GROUPBY_EXPRRESSION_LIST,groupByExprList);
        hmWebReportDataMap.put(metricsReportBean.DATA_EXPRRESSION_LIST,dataExprList);
        hmWebReportDataMap.put(metricsReportBean.DISPLAY_FORMAT,strChartType);
        if("criteriaUpdate".equalsIgnoreCase(strMode))
        {
            hmWebReportDataMap.put(metricsReportBean.WEBREPORT_NAME,strDecodedReportName);
            hmResulttable = metricsReportBean.processWebReport(context,hmWebReportDataMap,strOwner);
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
                    hmResulttable = metricsReportBean.checkForArchiveCreation(context,webReportObj,metricsReportBean.DOT_EMX_PREFIX + timeStamp);

                    if(hmResulttable!=null)
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
                        alert("<%=strConfirmMsg%>");
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
        if(hmResulttable != null && hmResulttable.size()>=0 && strMode.equals("reportDisplay")){
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
        else if(hmResulttable != null && hmResulttable.size()>=0 && strMode.equals("reportView") && ("true".equals(strRefresh) || metricsReportBean.hasResult(context,strReportName,strOwner)) || ("true".equals(strFromDisplayFormat)))
        {
            try {
            lastCompletedIn = metricsReportBean.getCompletedInDuration(context,strReportName,strOwner,strDefaultReport,timeStamp);
            }catch(FrameworkException wr){
            	if(wr instanceof WebreportException){
            		lastCompletedIn ="";
            	} else {
            		throw new FrameworkException(wr);
            	}
            }
            try {
            lastRunDetails = metricsReportBean.getLastRunDetails(context,strReportName,strOwner,strDefaultReport,strMode,timeStamp);
            }catch(FrameworkException wr){
            	if(wr instanceof WebreportException){
            		lastRunDetails ="";
            	} else {
            		throw new FrameworkException(wr);
            	}
            }
            
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
%>
        <script type="text/javascript" language="JavaScript">
            var heading = getTopWindow().document.getElementById("pageSubTitle");
            if(heading && (heading != "" || heading != null || heading != "null"))
            {
                heading.innerHTML = "<%=subHeader%>";
            }
        </script>
<%
        if(((hmResulttable==null) || (hmResulttable!=null && hmResulttable.size() == 0)) && (strMode.equals("reportDisplay") || "true".equalsIgnoreCase(strRefresh))){
            strNoResult = EnoviaResourceBundle.getProperty(context, "emxMetricsStringResource",context.getLocale(), "emxMetrics.ErrorMsg.NoData");
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
        } else if(hmResulttable!=null && hmResulttable.size() == 0 && strMode.equals("reportView") && (!"true".equalsIgnoreCase(strRefresh)) && (!"true".equals(strFromDisplayFormat))){
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
        else
        {
            if(strMode.equals(metricsReportBean.REPORT_DISPLAY) || strMode.equals("reportView")){
                if ((hmResulttable!=null) && (hmResulttable.size()>0) || ("true".equals(strFromDisplayFormat))){
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
                        chartDetailsMap = metricsReportBean.getLifeCycleValuesMap(context, hmResulttable, strDateUnit, fromDateObj, toDateObj, decimalPrecision);
                        }else{
                            throw new FrameworkException("Changing display format");
                        }
                    } catch(Exception e) {
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
                            //yValuesMap.put(FrameworkUtil.decodeURL((String) eachStateName.get(y),"UTF-8"),yAxisValues.get(y));
                            yTitleList.add(metricsReportBeanUI.internationalizedValue(context,strType,"","",(String) eachStateName.get(y),"state"));
                            yValList.add(yAxisValues.get(y));

                        }
                    }
                    if(strChartType.equalsIgnoreCase("LineChart"))
                    {
                       strChartType = "LabelLineChart";
                    }
                    //xValuesMap.put("Periods",finalX);
                    xValList.add(finalX);
                    String xLabel = i18nNow.getI18nString("emxMetrics.label.Periods", metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE, strLanguage);
                    xTitleList.add(xLabel);
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
                    //out.flush();
                    //To add the XAxis and YAxis values of Chart to session Map for Printer Friendly
                    metricsReportBean.setXAxis(timeStamp,xValuesMap);
                    metricsReportBean.setYAxis(timeStamp,yValuesMap);
                    
                    //To add the LabelDirection and RenderOption values of Chart to session Map for Printer Friendly
                    metricsReportBean.setLabelDirection(timeStamp,strLabelDirection);
                    metricsReportBean.setRenderOption(timeStamp,strDraw3D);
%>
                    <jsp:include page = "../common/emxChartInclude.jsp" flush="false"></jsp:include>
<%
                }
                else
                {
                    StringList rowHeaders = metricsReportBeanUI.internationalizeValues(context,
                                            eachStateName, null, "State",
                                            (String) strListPolicy.get(0));
                    StringList colHeaders = metricsReportBeanUI.prepareLifeCycleDurationColumnHeaders(context,
                                            chartDetailsMap, requestMap);

                    Map hrefMap       = metricsReportBeanUI.prepareLifeCycleDurationRowWiseHrefsMap(context, chartDetailsMap, eachStateName,
                                            rowHeaders.size(),colHeaders.size(),strDefaultReport,strReportName,strOwner,strType,strLanguage,timeStamp);
                    metricsReportBeanUI.setMetricsTabularFormatRowHeaders(rowHeaders);
                    metricsReportBeanUI.setMetricsTabularFormatColHeaders(colHeaders);
                    metricsReportBeanUI.setCustomHrefsForData(hrefMap);
                   if(blShowPercentage) { metricsReportBeanUI.setMessageText(EnoviaResourceBundle.getProperty(context, metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE,context.getLocale(), "emxMetrics.label.LifecycleDurationTabularFormatMessage"));
                   }
                    metricsReportBeanUI.showDataHrefLink(true);
                    metricsReportBeanUI.showTotalHrefLink(true);
                    metricsReportBeanUI.showTotalRow(true);
                    metricsReportBeanUI.showObjectCount(true);
                    metricsReportBeanUI.showRowSeparator(true);
                    metricsReportBeanUI.showDiffInPercentage(blShowPercentage);
                    metricsReportBeanUI.setRowLimit(EnoviaResourceBundle.getProperty(context, "emxMetrics.Configuration.RowLimitResultsDisplay"));
                    metricsReportBeanUI.setColumnLimit(EnoviaResourceBundle.getProperty(context, "emxMetrics.Configuration.ColumnLimitResultsDisplay"));
                    metricsReportBeanUI.setWrapColumnSize(wrapColSize);
                    metricsReportBeanUI.setObjectCountRowHeader(EnoviaResourceBundle.getProperty(context, metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE,context.getLocale(), "emxMetrics.label.ObjectCount"));
                    metricsReportBeanUI.setTotalRowHeader(EnoviaResourceBundle.getProperty(context, metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE,context.getLocale(), "emxMetrics.label.TotalDuration"));
                    metricsReportBeanUI.setTabularFormatDataMap(metricsReportBeanUI.prepareLifeCycleDurationRowWiseDataMap(context, chartDetailsMap,rowHeaders.size(),colHeaders.size(), decimalPrecision));
                    metricsReportBeanUI.setMetricsTabularFormatData(timeStamp);
                    if((strReportName!=null && strReportName.length() != 0) || "true".equals(strFromDisplayFormat)){
                        strObjectDetails = metricsReportBeanUI.getObjectDetails(context,strReportName,strOwner,timeStamp);
                    }
%>
                    <jsp:include page = "emxMetricsResultsTabularFormatDisplay.jsp" flush="false">
                       <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>
                       <jsp:param name="wrapColSize" value="<%=XSSUtil.encodeForURL(context, wrapColSize)%>"/>
                       <jsp:param name="objectDetails" value="<%=strObjectDetails%>"/>
                       <jsp:param name="refresh" value="<%=XSSUtil.encodeForURL(context, strRefresh)%>"/>
                    </jsp:include>
<%
                }
            }
        }
    }
}
catch(Exception ex) {
    if(ex.toString() != null && (ex.toString().trim()).length()>0){
        emxNavErrorObject.addMessage("Exception in Lifecycle Duration Results page:" + ex.toString().trim());
    }
}
%>
<form name ="LifecycleDurationReportResults">
<input type="hidden" name="chartType" id="chartType" value="<xss:encodeForHTMLAttribute><%=strChartType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="wrapColSize" id="wrapColSize" value="<xss:encodeForHTMLAttribute><%=wrapColSize%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="suiteKey" id="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="strYAxisTitle" id="strYAxisTitle" value="<%=strYAxisTitle%>" />
</form>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
