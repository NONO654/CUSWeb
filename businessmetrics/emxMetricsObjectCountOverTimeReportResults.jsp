<%--  emxMetricsObjectCountOverTimeReportResults.jsp - Results page for Object Count Report
   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxMetricsObjectCountOverTimeReportResults.jsp.rca 1.37 Wed Oct 22 16:11:55 2008 przemek Experimental $
--%>

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
String strChartType = "";
String wrapColSize  = "";
String suiteKey     = "";
String strGroupBy   = "";
String strSubGroup  = "";
String strNoResult  = "";
String strType      = "";
String strName      = "";
String strRevision  = "";
String strVault     = "";
boolean bViewNow = false;
String strDateUnit  = "";
String strObjectDetails = "";
String strLabelDirection = "";
String strDraw3D         = "";
String strLanguage  = request.getHeader("Accept-Language");
String strYAxisTitle = EnoviaResourceBundle.getProperty(context, metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE,context.getLocale(), "emxMetrics.label.TotalObjects");
String strConfirmMsg = EnoviaResourceBundle.getProperty(context, metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE,context.getLocale(), "emxMetrics.AlertMsg.ReportGenerationDelay");
String strPolingTime  = EnoviaResourceBundle.getProperty(context, "emxMetrics.Background.Polling.TimeInterval");
String strTimeOut  = EnoviaResourceBundle.getProperty(context, "emxMetrics.Background.Polling.TimeOutLimit");

String strActualContainedIn="";

long lPolingTime = 0;
long lTotalWaitTime = 0;

   String strShowPercentage = emxGetParameter(request,"showPercentage");
     boolean blShowPercentage = false;
     if (!"false".equalsIgnoreCase(strShowPercentage))
     {
         blShowPercentage=true;
     }

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
WebReport webReportObj = null;
com.matrixone.apps.domain.util.BackgroundProcess bgpObj = new com.matrixone.apps.domain.util.BackgroundProcess();

try
{
    String portalMode    = emxGetParameter(request,"portalMode");
    String portalOwner   = emxGetParameter(request,"portalOwner");
    String strOwner      = emxGetParameter(request,"owner", "UTF-8");

    // coming from "Launch" button in Dashboard page ??
    String launched       = emxGetParameter(request, "launched");

    if("true".equalsIgnoreCase(portalMode) || "true".equalsIgnoreCase(launched)){
        if(portalOwner != null && (portalOwner.length() > 0) ){
            strOwner = portalOwner;
        }
    }

    String strRefresh           = emxGetParameter(request,"refreshMode");
    wrapColSize                 = emxGetParameter(request, "wrapColSize");
    suiteKey                    = emxGetParameter(request, "suiteKey");
    String strMode              = emxGetParameter(request,"mode");
    String timeStamp            = emxGetParameter(request,"timeStamp");
    String launchtimeStamp      = emxGetParameter(request,"launchtimeStamp");
    String strReportName        = emxGetParameter(request,"reportName","UTF-8");
    String strDecodedReportName = (String) request.getAttribute("decodedReportName");
    String strFromDisplayFormat = emxGetParameter(request,"fromDisplayFormat");
    strChartType                = emxGetParameter(request,"chartType");
    String strDefaultReport     = emxGetParameter(request,"defaultReport");
    String lastCompletedIn = "";
    String lastRunDetails  = "";
    String subHeader =    "";
    String strBundle       = "emxMetricsStringResource";

    String finalX                 = "";
    StringBuffer sbSearchCriteria = new StringBuffer("");
    StringBuffer sbFirstGroupBy   = new StringBuffer("");
    StringBuffer sbSecondGroupBy  = new StringBuffer("");
    HashMap requestMap         = new HashMap();
    HashMap hmReqFieldsMap     = new HashMap();
    HashMap hmWebReportDataMap = new HashMap();
    Map hmResultsMap = null;
    Map chartDetailsMap    = null;
    hmWebReportDataMap.put("timezone",new Double((String)session.getAttribute("timeZone")) );
    hmWebReportDataMap.put(metricsReportBean.MODE,strMode);
    hmWebReportDataMap.put(metricsReportBean.WEBREPORT_NAME,strReportName);
    if(strMode.equalsIgnoreCase("reportDisplay") && (strReportName==null || strReportName.equals("null") || strReportName.equals("")))
    {
        strReportName = "";
    }
    if ((strMode==null) || strMode.equals("")){
        strMode = metricsReportBean.CRITERIA_UPDATE;
    }
    if(strMode.equals(metricsReportBean.CRITERIA_UPDATE)){
        requestMap = UINavigatorUtil.getRequestParameterMap(request);
    }
    if(strMode.equals(metricsReportBean.REPORT_DISPLAY)){
        if((launchtimeStamp!=null) && (!(launchtimeStamp.equals("")))){
            requestMap = metricsReportBean.getReportDialogData(launchtimeStamp);
        }else{
            requestMap = metricsReportBean.getReportDialogData(timeStamp);
        }
    }
    if ((strChartType==null) || strChartType.equals("")){
        strChartType                = (String)requestMap.get("chartType");
    }
    String whereClause          = metricsReportBean.getAdvanceSearchWhereExpression(context,requestMap);

    strType                     = (String)requestMap.get("txtTypeActual");
    strName                     = (String)requestMap.get("txtName");
    strRevision                 = (String)requestMap.get("txtRev");
    String strLatestRev         = (String)requestMap.get("latestRevision");
	 strActualContainedIn                     = (String)requestMap.get("txtActualContainedIn");


    if("last".equalsIgnoreCase(strLatestRev)){
        StringBuffer sbWhere = new StringBuffer("");
        sbWhere.append(whereClause);
        if(!whereClause.equals("")){
            sbWhere.append(" &&(revision == last)");
        }else{
            sbWhere.append("(revision == last)");
        }
        whereClause = sbWhere.toString();
    }
    if("reportView".equals(strMode)) {

        if(strType == null)
        {
            strType = metricsReportBean.getFormFieldValue(context, strReportName, strOwner, "txtTypeActual", strDefaultReport, timeStamp);
        }

        String strdefaultReport = (String)requestMap.get("defaultReport");
        StringList whichFields = new StringList();
        whichFields.add("chartType");
        whichFields.add("lstGroupBy");
        whichFields.add("lstSubgroup");
        whichFields.add("optDateUnit");
        whichFields.add("labelDirection");
        whichFields.add("draw3D");
        String notesXML = metricsReportBean.getParsedNotes(context, strReportName, strOwner, strdefaultReport, timeStamp);
        wrapColSize = metricsReportBean.getParamDataFromNotesXML(notesXML, "wrapColSize");
        hmReqFieldsMap = metricsReportBean.readNotesXML(context, strReportName, strOwner, strdefaultReport, timeStamp, whichFields);
        strDateUnit = (String)hmReqFieldsMap.get("optDateUnit");
        strGroupBy     = (String) hmReqFieldsMap.get("lstGroupBy");
        strSubGroup  = (String) hmReqFieldsMap.get("lstSubgroup");
        strLabelDirection = (String) hmReqFieldsMap.get("labelDirection");
        strDraw3D         = (String) hmReqFieldsMap.get("draw3D");
        strGroupBy   = metricsReportBean.getRequiredVal(strGroupBy);
        strSubGroup    = metricsReportBean.getRequiredVal(strSubGroup);        
        if(strSubGroup == null || "null".equalsIgnoreCase(strSubGroup) || "".equalsIgnoreCase(strSubGroup)){
            strSubGroup = "";
        }

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
            //initiate the background process with a separate context
            try{
                Context frameContext = Framework.getFrameContext(session);
                Object objectArray[] = {frameContext,hmWebReportDataMap,strOwner};
                Class objectTypeArray[] = {frameContext.getClass(),hmWebReportDataMap.getClass(),strOwner.getClass()};
                bgpObj.submitJob(frameContext,metricsReportBean,"processWebReportInBackGround",objectArray,objectTypeArray);
            } catch (Exception ex){
                ContextUtil.startTransaction(context, true);
                //remove the webreport InUse property when there is some problem
                metricsReportBean.removeWebReportProperty(context,webReportObj.getName(),webReportObj.getOwner(),metricsReportBean.PROPERTY_IN_USE);
                ContextUtil.commitTransaction(context);
                throw new Exception (ex.toString());
            }

            long startTime = System.currentTimeMillis();
            long actualEndTime = startTime+lTotalWaitTime;
            //initiate the polling process to ping the webreport for archived results
            while(System.currentTimeMillis()<=actualEndTime)
            {
                hmResultsMap = metricsReportBean.checkForArchiveCreation(context,webReportObj,metricsReportBean.DOT_EMX_PREFIX + timeStamp);
                Thread.sleep(lPolingTime);
                if(hmResultsMap!=null)
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
                    var msg = "<%=strConfirmMsg%>"//XSSOK
                    alert(msg);
                    if(parent.getTopWindow() && "<xss:encodeForJavaScript><%=portalMode%></xss:encodeForJavaScript>"!="true")
                    {
                        parent.getTopWindow().closeWindow();
                    }
                </script>
<%
            } else {
                metricsReportBean.setWebReportProperty(context,strReportName,strOwner,"metrics_" + metricsReportBean.DOT_EMX_PREFIX + timeStamp + "Grabbed","true");
            }
        }
        else if(!"true".equals(strFromDisplayFormat))// if reportView mode, get the results and show
        {
            hmResultsMap = metricsReportBean.processWebReport(context,hmWebReportDataMap,strOwner);
            bViewNow = true;
        }
    }

    if (!"reportView".equals(strMode)){
        String userName          = context.getUser();
        strType                  = (String)requestMap.get("txtTypeActual");
        strName                  = (String)requestMap.get("txtName");
        strRevision              = (String)requestMap.get("txtRev");
        strVault                 = (String)requestMap.get("vaults");
        String strVaultSelction  = (String)requestMap.get("vaultSelction");
        strGroupBy               = (String)requestMap.get("lstGroupBy");
        strSubGroup              = (String)requestMap.get("lstSubgroup");
        strDateUnit              = (String)requestMap.get("optDateUnit");
        String strWebReportName  = (String)requestMap.get("reportName");
        strLabelDirection        = (String)requestMap.get("labelDirection");
        strDraw3D                = (String)requestMap.get("draw3D");
        
		strActualContainedIn     = (String)requestMap.get("txtActualContainedIn");
		HashMap searchList = new HashMap();
        
        if(strVaultSelction != null && strVaultSelction.equalsIgnoreCase("DEFAULT_VAULT")){
            strVault = (String)PersonUtil.getDefaultVault(context);
        }
        else if(strVaultSelction != null && strVaultSelction.equalsIgnoreCase("ALL_VAULTS")){
            strVault = "*";
        }
        else if(strVaultSelction != null && strVaultSelction.equalsIgnoreCase("LOCAL_VAULTS")){
            strVault = OrganizationUtil.getLocalVaults(context, PersonUtil.getUserCompanyId(context));
        }
        else if(strVaultSelction != null && strVaultSelction.equalsIgnoreCase("SELECTED_VAULT")){
            strVault = (String)requestMap.get("vaults");
        }
        if(strType == null || "null".equalsIgnoreCase(strType) || "".equalsIgnoreCase(strType)){
            strType = "";
        }
        if(strName == null || "null".equalsIgnoreCase(strName) || "".equalsIgnoreCase(strName)){
            strName = "*";
        }
        if(strRevision == null || "null".equalsIgnoreCase(strRevision) || "".equalsIgnoreCase(strRevision)){
            strRevision = "*";
        }
        if(strVault == null || "null".equalsIgnoreCase(strVault)){
            strVault = "";
        }
        if(strVaultSelction == null || "null".equalsIgnoreCase(strVaultSelction) || "".equalsIgnoreCase(strVaultSelction)){
            strVaultSelction = "";
        }


	    if(strActualContainedIn == null || "null".equalsIgnoreCase(strActualContainedIn) || "".equalsIgnoreCase(strActualContainedIn)){
            strActualContainedIn = "";
        }

        if(strGroupBy == null || "null".equalsIgnoreCase(strGroupBy) || "".equalsIgnoreCase(strGroupBy)){
            strGroupBy = "";
        }
        if(strSubGroup == null || "null".equalsIgnoreCase(strSubGroup) || "".equalsIgnoreCase(strSubGroup)){
            strSubGroup = "";
        }
        if(strDateUnit == null || "null".equalsIgnoreCase(strDateUnit) || "".equalsIgnoreCase(strDateUnit)){
            strDateUnit = "";
        }
        if(strChartType == null || "null".equalsIgnoreCase(strChartType) || "".equalsIgnoreCase(strChartType)){
            strChartType = "";
        }
        if(strDefaultReport == null || "null".equalsIgnoreCase(strDefaultReport) || "".equalsIgnoreCase(strDefaultReport)){
            strDefaultReport = "";
        }
        if(strWebReportName == null || "null".equalsIgnoreCase(strWebReportName) || "".equalsIgnoreCase(strWebReportName)){
            strWebReportName = "";
        }

        sbSearchCriteria.append("temp query bus '");
        sbSearchCriteria.append(strType);
        sbSearchCriteria.append("' ");
        sbSearchCriteria.append(strName);
        sbSearchCriteria.append(" ");
        if("last".equalsIgnoreCase(strLatestRev)){
            sbSearchCriteria.append("*");
        }
        else{
            sbSearchCriteria.append(strRevision);
        }
        if(!strVault.equals("")){
            sbSearchCriteria.append(" vault '");
            sbSearchCriteria.append(strVault);
            sbSearchCriteria.append("'");
        }
        if(!whereClause.equals("")){
            sbSearchCriteria.append(" where '");
            sbSearchCriteria.append(whereClause);
            sbSearchCriteria.append("'");
        } 
		sbSearchCriteria = null;


		String reportType = "ObjectCountOverTime";
		searchList.put("strContainedIn",strActualContainedIn);
		searchList.put("strType",strType);
		searchList.put("strName",strName);
		searchList.put("strLatestRev",strLatestRev);
		searchList.put("strRevision",strRevision);
		searchList.put("strVault",strVault);
		searchList.put("whereClause",whereClause);
		sbSearchCriteria = metricsReportBeanUI.formContainedInCriteria(context,searchList,reportType);
        if(strGroupBy.equalsIgnoreCase("Originated") || strGroupBy.equalsIgnoreCase("Modified")) {
            sbFirstGroupBy.append("dateperiod y");
            sbFirstGroupBy.append(strDateUnit.toLowerCase());
            sbFirstGroupBy.append(" ");
            sbFirstGroupBy.append(strGroupBy);
        }
        else {
            sbFirstGroupBy.append("dateperiod y");
            sbFirstGroupBy.append(strDateUnit.toLowerCase());
            sbFirstGroupBy.append(" attribute[");
            sbFirstGroupBy.append(strGroupBy);
            sbFirstGroupBy.append("]");        
        }

        ExpressionList groupByExprList = new ExpressionList();
        Expression groupByExpr1 = new Expression();
        groupByExpr1.setValue(sbFirstGroupBy.toString());
        groupByExprList.addElement(groupByExpr1);

        if(strSubGroup != null && !"".equals(strSubGroup)){
            sbSecondGroupBy.append("attribute[");
            sbSecondGroupBy.append(strSubGroup);
            sbSecondGroupBy.append("]");
            Expression groupByExpr2 = new Expression();
            groupByExpr2.setValue(sbSecondGroupBy.toString());
            groupByExprList.addElement(groupByExpr2);
        }
        hmWebReportDataMap.put(metricsReportBean.SEARCH_CRITERIA,sbSearchCriteria.toString());
        hmWebReportDataMap.put(metricsReportBean.WEBREPORT_TYPE,strDefaultReport);
        hmWebReportDataMap.put(metricsReportBean.TIME_STAMP,timeStamp);
        hmWebReportDataMap.put(metricsReportBean.GROUPBY_EXPRRESSION_LIST,groupByExprList);
        hmWebReportDataMap.put(metricsReportBean.DISPLAY_FORMAT,strChartType);
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
                    webReportObj = new WebReport(sbemxWebReport.toString(), context.getUser());
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
                //initiate the background process with a separate context
                try{
                    //use new context
                    Context frameContext = Framework.getFrameContext(session);
                    Object objectArray[] = {frameContext,hmWebReportDataMap,strOwner};
                    Class objectTypeArray[] = {frameContext.getClass(),hmWebReportDataMap.getClass(),strOwner.getClass()};
                    bgpObj.submitJob(frameContext, metricsReportBean,"processWebReportInBackGround",objectArray,objectTypeArray);
                } catch (Exception ex){
                    ContextUtil.startTransaction(context, true);
                    //remove the webreport InUse property when there is some problem
                    metricsReportBean.removeWebReportProperty(context,webReportObj.getName(),webReportObj.getOwner(),metricsReportBean.PROPERTY_IN_USE);
                    ContextUtil.commitTransaction(context);
                    throw new Exception (ex.toString());
                }

                long startTime = System.currentTimeMillis();
                long actualEndTime = startTime+lTotalWaitTime;
                //initiate the polling process to ping the webreport for archived results
                while(System.currentTimeMillis()<=actualEndTime)
                {
                    hmResultsMap = metricsReportBean.checkForArchiveCreation(context,webReportObj,metricsReportBean.DOT_EMX_PREFIX + timeStamp);

                    if(hmResultsMap!=null)
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
                        if(parent.getTopWindow() && "<xss:encodeForJavaScript><%=portalMode%></xss:encodeForJavaScript>"!="true")
                        {
                            parent.getTopWindow().closeWindow();
                        }
                    </script>
<%
                } else {
                    metricsReportBean.setWebReportProperty(context,webReportObj.getName(),webReportObj.getOwner(),"metrics_" + metricsReportBean.DOT_EMX_PREFIX + timeStamp + "Grabbed","true");
                }
            }
            else //if criteriaUpdate mode, update the notes
            {
                hmWebReportDataMap.put(metricsReportBean.WEBREPORT_NAME,strDecodedReportName);
                hmResultsMap = metricsReportBean.processWebReport(context,hmWebReportDataMap,strOwner);
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
        if(hmResultsMap != null && hmResultsMap.size()>=0 && strMode.equals("reportDisplay")){
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
        else if(hmResultsMap != null && hmResultsMap.size()>=0 && strMode.equals("reportView") && ("true".equals(strRefresh) || metricsReportBean.hasResult(context,strReportName,strOwner)) || ("true".equals(strFromDisplayFormat)))
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
        if(((hmResultsMap==null) || (hmResultsMap!=null && hmResultsMap.size() == 0)) && (strMode.equals("reportDisplay") || "true".equalsIgnoreCase(strRefresh))){
            strNoResult = EnoviaResourceBundle.getProperty(context, "emxMetricsStringResource",context.getLocale(), "emxMetrics.ErrorMsg.NoData");
            //To add the NoResult message to the session Map to display in Printer friendly page
            metricsReportBean.setResultString(timeStamp,strNoResult);
%>
            <table border="0" cellpadding="3" cellspacing="2" width="100%">
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
        } else if(hmResultsMap!=null && hmResultsMap.size() == 0 && strMode.equals("reportView") && (!"true".equalsIgnoreCase(strRefresh)) && (!"true".equals(strFromDisplayFormat))){
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
                if ((hmResultsMap!=null) && (hmResultsMap.size()>0) || ("true".equals(strFromDisplayFormat))){
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
                            chartDetailsMap = metricsReportBean.getObjectCountValuesMap(context,strType,strGroupBy,strSubGroup,hmResultsMap,strDateUnit);
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

      if ((chartDetailsMap!=null) && (chartDetailsMap.size()>0)) {
          metricsReportBean.setResultsData(timeStamp,chartDetailsMap);
      }
%>
<body>
<%


            if(!"Tabular".equalsIgnoreCase(strChartType))
            {
                String subGroupByAttrType = "Attribute";
                String strSubGroupDataType = "";
                StringList attrRanges = new StringList();
                if(strSubGroup!=null && !"".equals(strSubGroup))
                {
                    try
                    {
                        AttributeType attrType = new AttributeType(strSubGroup);
                        attrType.open(context);
                        strSubGroupDataType = attrType.getDataType();
                        if("boolean".equalsIgnoreCase(strSubGroupDataType))
                        {                           
                           attrRanges = FrameworkUtil.getRanges(context, strSubGroup);
                           attrRanges.sort();
                        }                        
                        StringList strChoiceList = attrType.getChoices(context);
                        if(strChoiceList!=null && strChoiceList.size()>0)
                        {
                            subGroupByAttrType = "Range";
                        }                        
                    }
                    catch(Exception e)
                    {
                        if(e.toString() != null && (e.toString().trim()).length()>0)
                        {
                            emxNavErrorObject.addMessage("Object Count Report Results Failed :" + e.toString().trim());
                        }                        
                    }
                }
                HashMap xValuesMap = new HashMap();
                HashMap yValuesMap = new HashMap();
                HashMap tempYValMap = new HashMap();
                ArrayList xValList = new ArrayList();
                ArrayList yValList = new ArrayList();
                ArrayList xTitleList = new ArrayList();
                ArrayList yTitleList = new ArrayList();
                String attributeType= "";
                if("Originated".equalsIgnoreCase(strGroupBy) || "Modified".equalsIgnoreCase(strGroupBy)){
                    attributeType = "basic";
                }else{
                    attributeType = "Attribute"; 
                }                
                if(chartDetailsMap != null && chartDetailsMap.size()> 0){
                    Iterator keyItr = (chartDetailsMap.keySet()).iterator();
                    while(keyItr.hasNext())
                    {
                        String key = (String)keyItr.next();
                        if(!key.equalsIgnoreCase("CellNumber") && !key.equalsIgnoreCase(metricsReportBean.SUMMARY_RESULT_LIST))
                        {
                            String value = (String) chartDetailsMap.get(key);
                            if(strGroupBy.equalsIgnoreCase(key)){
                                //xValuesMap.put(key,value);
                                xValList.add(value);                      
                                key = metricsReportBeanUI.internationalizedValue(context,strType,"",strGroupBy,key,attributeType);
                                xTitleList.add(key);
                            }else{
                                //yValuesMap.put(key,value);
                                if(strSubGroup!=null && !"".equals(strSubGroup))
                                {
                                    if("boolean".equalsIgnoreCase(strSubGroupDataType))
                                    {
                                        //If the ranges are given as Yes/No(2 Values) 
                                        // or True/False(2 Values), they will be internationationalized
                                        if(attrRanges!=null && attrRanges.size()==2)
                                        {
                                            if(key.equalsIgnoreCase("True"))
                                            {
                                                key = (String)attrRanges.get(1);
                                            }
                                            else
                                            {
                                                key = (String)attrRanges.get(0);
                                            }
                                        }
                                    }                                    
                                }
                                else
                                {
                                    key = strYAxisTitle;
                                }                                
                                yValList.add(value);
                                if("integer".equalsIgnoreCase(strSubGroupDataType))
                                {
                                    try
                                    {
                                        yTitleList.add(new Integer(key));
                                        tempYValMap.put(key,value);
                                    }
                                    catch(Exception e)
                                    {
                                        yTitleList.add(key);
                                        tempYValMap.put(key,value);
                                    }
                                }
                                else if("real".equalsIgnoreCase(strSubGroupDataType))
                                {
                                    try
                                    {
                                        yTitleList.add(new Double(key));
                                        tempYValMap.put(key,value);
                                    }
                                    catch(Exception e)
                                    {
                                        yTitleList.add(key);
                                        tempYValMap.put(key,value);
                                    }
                                }
                                else
                                {
                                    key = metricsReportBeanUI.internationalizedValue(context,strType,"",strSubGroup,key,subGroupByAttrType);
                                    yTitleList.add(key);
                                }
                            }
                        }
                    }
                }
                if("integer".equalsIgnoreCase(strSubGroupDataType))
                {
                    Collections.sort(yTitleList);
                    ArrayList tempList = new ArrayList();
                    ArrayList tempValList = new ArrayList();
                    Iterator yTitleIter = yTitleList.iterator();
                    while(yTitleIter.hasNext())
                    {
                        Integer yTitle = (Integer) yTitleIter.next();
                        String strKey = yTitle.toString();
                        tempList.add(metricsReportBeanUI.internationalizedValue(context,strType,"",strSubGroup,strKey,subGroupByAttrType));
                        String strValue = (String)tempYValMap.get(strKey);
                        tempValList.add(strValue);
                    }
                    yTitleList = tempList;
                    yValList = tempValList;
                }
                if("real".equalsIgnoreCase(strSubGroupDataType))
                {
                    Collections.sort(yTitleList);
                    ArrayList tempList = new ArrayList();
                    ArrayList tempValList = new ArrayList();
                    Iterator yTitleIter = yTitleList.iterator();
                    while(yTitleIter.hasNext())
                    {
                        Double yTitle = (Double) yTitleIter.next();
                        String strKey = yTitle.toString();
                        tempList.add(metricsReportBeanUI.internationalizedValue(context,strType,"",strSubGroup,strKey,subGroupByAttrType));
                        String strValue = (String)tempYValMap.get(strKey);
                        tempValList.add(strValue);
                    }
                    yTitleList = tempList;
                    yValList = tempValList;
                }
                if(strChartType.equalsIgnoreCase("LineChart"))
                {
                   strChartType = "LabelLineChart";
                }
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
                HashMap reportDetails = new HashMap();
                reportDetails.put("Bundle",strBundle);
                reportDetails.put("Language",strLanguage);
                reportDetails.put("Report Name",strReportName);
                reportDetails.put("Owner",strOwner);
                reportDetails.put("Default Report",strDefaultReport);
                reportDetails.put("Time Stamp",timeStamp);
                reportDetails.put("Sub Group",strSubGroup);
                reportDetails.put("Mode",strMode);
                String strMessageText = "";
                if(strSubGroup !=null && !"".equals(strSubGroup)){
                    strMessageText = metricsReportBean.substituteMacroValue(context,"emxMetrics.label.ObjectCountOverTimeTabularFormatMessageWithSubGroup",reportDetails);
                }
                StringList colHeaders  = metricsReportBeanUI.prepareObjectCountColumnHeaders(context, chartDetailsMap, strGroupBy, strSubGroup, strLanguage);
                StringList rowHeaders  = metricsReportBeanUI.prepareObjectCountRowHeaders(chartDetailsMap, strGroupBy);
                Map rowWiseDataMap = metricsReportBeanUI.prepareObjectCountRowWiseDataMap(chartDetailsMap, rowHeaders, colHeaders);
                Map hrefMap        = metricsReportBeanUI.prepareObjectCountRowWiseDataHrefMap(context,chartDetailsMap, rowHeaders, colHeaders, strDefaultReport, strReportName, strOwner, strType, strLanguage, timeStamp);
                metricsReportBeanUI.setMetricsTabularFormatRowHeaders(rowHeaders);
                metricsReportBeanUI.setMetricsTabularFormatColHeaders(colHeaders);
                metricsReportBeanUI.setCustomHrefsForData(hrefMap);
                if(blShowPercentage) {
                metricsReportBeanUI.setMessageText(strMessageText);
                }
                metricsReportBeanUI.showTotalHrefLink(true);
                metricsReportBeanUI.showDataHrefLink(true);
                metricsReportBeanUI.showTotalRow(true);
                metricsReportBeanUI.showRowSeparator(false);
                metricsReportBeanUI.showDiffInPercentage(blShowPercentage);
                metricsReportBeanUI.setRowLimit(EnoviaResourceBundle.getProperty(context, "emxMetrics.Configuration.RowLimitResultsDisplay"));
                metricsReportBeanUI.setColumnLimit(EnoviaResourceBundle.getProperty(context, "emxMetrics.Configuration.ColumnLimitResultsDisplay"));
                metricsReportBeanUI.setWrapColumnSize(wrapColSize);
                metricsReportBeanUI.setTotalOutputType(metricsReportBeanUI.TOTAL_OUTPUT_INTEGER);
                metricsReportBeanUI.showTotalColumn(true);
                metricsReportBeanUI.setTotalRowHeader(EnoviaResourceBundle.getProperty(context, metricsReportBeanUI.METRICS_STRING_RESOURCE_BUNDLE,context.getLocale(), "emxMetrics.label.TotalNoOfObjects"));
                metricsReportBeanUI.setTabularFormatDataMap(rowWiseDataMap);
                metricsReportBeanUI.setMetricsTabularFormatData(timeStamp);
                if((strReportName!=null && strReportName.length() != 0) ||  "true".equals(strFromDisplayFormat)){
                    strObjectDetails = metricsReportBeanUI.getObjectDetails(context,strReportName,strOwner,timeStamp);
                }
%>
				<!-- XSSOK -->
                <jsp:include page = "emxMetricsResultsTabularFormatDisplay.jsp" flush="true"><jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/><jsp:param name="wrapColSize" value="<%=XSSUtil.encodeForURL(context, wrapColSize)%>"/><jsp:param name="objectDetails" value="<%=strObjectDetails%>"/><jsp:param name="refresh" value="<%=XSSUtil.encodeForURL(context, strRefresh)%>"/></jsp:include>
<%
            }

          }

        }
    }
}
catch(Exception ex) {

    if(ex.toString() != null && (ex.toString().trim()).length()>0){
        emxNavErrorObject.addMessage("Object Count Report Over Time Results Failed :" + ex.toString().trim());
    }
}
%>
<form name="MetricsObjectCountOverTime">
<input type="hidden" name="chartType" id="chartType" value="<xss:encodeForHTMLAttribute><%=strChartType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="wrapColSize" id="wrapColSize" value="<xss:encodeForHTMLAttribute><%=wrapColSize%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="suiteKey" id="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="strYAxisTitle" id="strYAxisTitle" value="<%=strYAxisTitle%>" />
</form>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </body>

 </html>
