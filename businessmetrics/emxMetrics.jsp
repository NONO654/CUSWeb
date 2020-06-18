<%--  emxMetrics.jsp - This JSP holds the frames for dialog display

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetrics.jsp.rca 1.18 Wed Oct 22 16:11:56 2008 przemek Experimental $
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file="emxMetricsConstantsInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<jsp:useBean id="metricsReportUIBean" class="com.matrixone.apps.metrics.ui.UIMetricsReports" scope="request"/>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="request"/>
<%@page import="com.matrixone.apps.metrics.WebreportException"%>
<%
    //Get requestParameters for searchContent
    StringBuffer queryString  = new StringBuffer("");
    String url                = "";
    String title              = "";
    String helpMarker         = "";
    String strSuiteKey        = "";
    String resultsURL         = "";
    String showAdvanced       = emxGetParameter(request, "showAdvanced");
    String defaultReport      = emxGetParameter(request, "defaultReport");
    String strReportName      = emxGetParameter(request, "reportName");
    String strFromPortalMode  = emxGetParameter(request, "portalMode");
    String strViewDef         = emxGetParameter(request, "viewdef");
    String reportOwner        = emxGetParameter(request, "reportOwner");
    String timeStamp          = emxGetParameter(request, "timeStamp");
    String strMode            = emxGetParameter(request, "mode");
    // introduced for Launch -> View Defn from portalmode
    String launched           = emxGetParameter(request, "launched");
    
    if(strReportName == null || "".equals(strReportName)){
        strReportName = "";
    }

    // cleanup operation starts..
    String strNamePattern = ".emx"+defaultReport+"*";
    StringList namepatternList = new StringList();
    namepatternList.add(strNamePattern);

    WebReportList webReportList = WebReport.getWebReports(context,namepatternList,true);
    String strTimeStamp = Long.toString(System.currentTimeMillis());

    Iterator reportItr = webReportList.iterator();
    while(reportItr.hasNext()){
        WebReport webreport = (WebReport) reportItr.next();
        String webreportName = webreport.getName();
        int stringLength = (".emx"+defaultReport).length();
        String tempTimeStamp = webreportName.substring(stringLength,webreportName.length());
        
        try{
        if(metricsReportBean.checkReportTimeStampValidity(strTimeStamp,tempTimeStamp)){
            webreport.remove(context);
        }
        } catch (WebreportException wre){
        	//do nothing
        	continue;
        }
    }
    // cleanup operation ends

    String reportToolbar = emxGetParameter(request, "toolbar");

    if (reportToolbar == null || reportToolbar.trim().length() == 0)
    {
        reportToolbar = PropertyUtil.getSchemaProperty(context,"menu_MetricsGlobalToolbar");
    }

    String errMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource",context.getLocale(), "emxFramework.GlobalReport.ErrorMsg.NoDefaultReport");
    try{

        WebReportList webReports = WebReport.getWebReports(context, true, false);
        Iterator iter = webReports.iterator();
        while(iter.hasNext())
        {
            WebReport webreport = (WebReport)iter.next();
        }

        HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
        ContextUtil.startTransaction(context,true);
        HashMap metricsRelatedSettings = metricsReportUIBean.getMetricsRelatedSettingsOfCommand(context,
                                                                                              defaultReport,
                                                                                              reportToolbar,
                                                                                              paramMap,
                                                                                              lStr);
        url = (String)metricsRelatedSettings.get(metricsReportUIBean.SETTING_LINK_HREF);
        title = (String)metricsRelatedSettings.get(metricsReportUIBean.COMMAND_TITLE);
        helpMarker = (String)metricsRelatedSettings.get(metricsReportUIBean.HELP_MARKER);
        strSuiteKey = (String)metricsRelatedSettings.get(metricsReportUIBean.SETTING_REGISTERED_SUITE);
        resultsURL = (String)metricsRelatedSettings.get(metricsReportUIBean.SETTING_REPORT_RESULTS_URL);

        if (url == null || url.trim().length() == 0) {
            emxNavErrorObject.addMessage("emxReport: " + errMsg);
            url = "../common/emxBlank.jsp";
        }

        if (resultsURL == null || resultsURL.trim().length() == 0) {
            emxNavErrorObject.addMessage("emxReport: Report Results URL is empty");
            resultsURL = "../common/emxBlank.jsp";
        }

        if(url != null && queryString.length() > 1){
            url += (url.indexOf("?") == -1 ? "?" : "&") + queryString.toString();
        }

        if(showAdvanced == null || "".equals(showAdvanced)){
            showAdvanced = "false";
        }

        if(title == null || "".equals(title)){
            title = "";
        }

        if(helpMarker == null || "".equals(helpMarker)){
            helpMarker = "";
        }

    }
    catch (Exception ex){
         if(ex.toString() != null && (ex.toString().trim()).length()>0){
                ContextUtil.abortTransaction(context);
                emxNavErrorObject.addMessage("emxReport:" + ex.toString().trim());
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }

    String toolbar = emxGetParameter(request, "toolbar");
    String objectId = null;
    String relId = null;
    String strHelpMarker = emxGetParameter(request, "HelpMarker");
    if(strHelpMarker == null){
    	strHelpMarker = helpMarker;
    } 

    if (toolbar == null || toolbar.trim().length() == 0)
    {
        toolbar = PropertyUtil.getSchemaProperty(context,"menu_MetricsCommonReportsToolbar");
    }
    String languageStr = request.getHeader("Accept-Language");

    String wrapColSize = "";
    String suiteKey = emxGetParameter(request,"suiteKey");
    String suiteDirectory = emxGetParameter(request,"suiteDirectory");
    String strContextUser = context.getUser();
    try{
        wrapColSize = EnoviaResourceBundle.getProperty(context, "emxMetrics.MetricsReport.WrapSize");
        if( (wrapColSize == null) || (wrapColSize.equals("null")) || (wrapColSize.equals(""))) {
            wrapColSize="10";
        }
                
    }
    catch (Exception ex){
        if(ex.toString() != null && (ex.toString().trim()).length()>0){
                emxNavErrorObject.addMessage("emxMetricsFooter :" + ex.toString().trim());
        }
    }
%>


<html>
    <head>
        <title>Report</title>
        <script language="javascript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="emxMetrics.js"></script>
        <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
        <script language="javascript" src="../common/scripts/emxUIPopups.js"></script>
        <script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIActionbar.js"></script>
        <script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIMetricsDialog.css"/>
        <script type="text/javascript">
           
            
            //addStyleSheet("emxUIForm");
            //addStyleSheet("emxUISearch");
            //addStyleSheet("emxUIList");
            addStyleSheet("emxUIDefault");
            //addStyleSheet("emxUIDOMLayout.css");
            //addStyleSheet("emxUIDialog");
            addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIMenu");
            
            function doDone() {
                turnOnProgress("utilProgressBlue.gif");
                setTimeout("getTopWindow().closeWindow()", 500);
            }
            
            function trimWhitespace(strString) {
                strString = strString.replace(/^[\s\u3000]*/g, "");
                return strString.replace(/[\s\u3000]+$/g, "");
            }

            function loadContentFrame(){
                var reportPageURL = getTopWindow().pageControl.getReportContentURL();
                var reportPageFrame = findFrame(this,"metricsReportContent");
                reportPageFrame.location.href = reportPageURL;
            }
           
            function disableCommands(){            
                 setTimeout( function() {                   
                    getTopWindow().enableFunctionality(getTopWindow().STR_METRICS_DELETE_COMMAND,false);
                    getTopWindow().enableFunctionality(getTopWindow().STR_METRICS_SAVE_COMMAND,true);
                },200);
            }
        
            if(getTopWindow().getWindowOpener())
            {
                pageControl.setOpenerWindow(getTopWindow().getWindowOpener().getTopWindow());
            }
            pageControl.setTopWindow(getTopWindow());
            pageControl.setReportContentURL("<%= XSSUtil.encodeForJavaScript(context, url) %>");
            pageControl.setShowingAdvanced("<xss:encodeForJavaScript><%= showAdvanced %></xss:encodeForJavaScript>");
            pageControl.setTitle("<%=XSSUtil.encodeForJavaScript(context, title)%>");
            pageControl.setSavedReportName("<xss:encodeForJavaScript><%= strReportName %></xss:encodeForJavaScript>");
            //added for View Definition case
            pageControl.setTimeStamp("<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>");
            pageControl.setMode("<xss:encodeForJavaScript><%=strMode%></xss:encodeForJavaScript>");

            // added for CommandName used to pass to results page in the generate function
            pageControl.setCommandName("<xss:encodeForJavaScript><%= defaultReport %></xss:encodeForJavaScript>");
            pageControl.setReportResultsURL("<%= XSSUtil.encodeForJavaScript(context, resultsURL) %>");
            var strViewDef = "<xss:encodeForJavaScript><%= strViewDef %></xss:encodeForJavaScript>";
             // added for portal mode
            var fromPortalMode = "<xss:encodeForJavaScript><%= strFromPortalMode %></xss:encodeForJavaScript>";
            var reportOwner = "<xss:encodeForJavaScript><%= reportOwner %></xss:encodeForJavaScript>";

<%          if( (strFromPortalMode != null && strFromPortalMode.equalsIgnoreCase("true")) ){
                if(!context.getUser().equals(reportOwner)){
%>
                    pageControl.setSharedAndNotOwned(true);
<%
                }
            }
            else if("true".equals(launched)){
                if(!context.getUser().equals(reportOwner)){
%>                
                    pageControl.setSharedAndNotOwned(true);
            
<%              }
            }
%>


        </script>
       
    </head>
    <body class="dialog" onload="adjustBody();loadContentFrame();return false;" onresize="resizeContentIFrame('metricsReportContent','divPageBody');">
	    <div id="divPageHead">
			<form method="post">
			    <table border="0" cellspacing="0" cellpadding="0" width="100%">
			       <tr>
			          <td width="99%">
			            <table border="0" width="100%" cellspacing="0" cellpadding="0">
			              <tr>
			                <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
			              </tr>
			            </table>
			            <table border="0" cellspacing="0" cellpadding="0" width="100%">
			              <tr>
			                <td nowrap><span class="pageHeader" id="pageHeader"></span></td>
			                  <%
			                      String progressImage = "../common/images/utilProgressBlue.gif";
			                      String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
			                   %>
							   <!-- //XSSOK-->
			                <td nowrap><div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=processingText%></i></div></td>
			                <td><img src="../common/images/utilSpacer.gif" alt="" width="4" height="33" />
			                </td>
			              </tr>
			            </table>
						<!-- //XSSOK -->
			            <jsp:include page = "../common/emxToolbar.jsp" flush="true"><jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/><jsp:param name="objectId" value="<%=objectId%>"/><jsp:param name="relId" value="<%=relId%>"/><jsp:param name="export" value="false"/><jsp:param name="PrinterFriendly" value="false"/><jsp:param name="portalMode" value="false"/><jsp:param name="HelpMarker" value="<%=XSSUtil.encodeForURL(context, strHelpMarker)%>"/></jsp:include>
			          </td>
			            <td><img src="../common/images/utilSpacer.gif" alt="" width="4" />
			            </td>
			       </tr>
			    </table>
			</form>
			<script language="JavaScript">
			     //set window Title
			     getTopWindow().pageControl.setWindowTitle();
			
			     //set window Title
			     getTopWindow().pageControl.setPageHeaderText();

			</script>
	    </div>
	    <div id="divPageBody">
	      <iframe id="metricsReportContent" height="100%" class="contentIFrame" src="../common/emxBlank.jsp" name="metricsReportContent" onload="resizeContentIFrame('metricsReportContent','divPageBody');"></iframe>
	    </div>
	    <div id="divPageFoot">
	       <form name="footerForm" method="post" onsubmit="javascript:getTopWindow().generateReport('<%=strContextUser%>'); return false;">
		      <table width="100%" border="0" align="center" cellspacing="0" cellpadding="0">
		        <tr>
		          <td class="functions">
		            <table border="0">
		              <tr>
		                <td><%=STR_METRICS_WRAP_SIZE%></td>
		                <td><input type="textbox" name= "WrapColSize" id="WrapColSize" value="<%= wrapColSize %>" size="5" />
		                </td>
		                <td><%=STR_METRICS_RESULTS%></td>
		                <td>&nbsp;&nbsp;</td>                
		              </tr>
		            </table>
		          </td>
		          <td class="buttons" align="right">
		            <table border="0" cellspacing="0" cellpadding="0">
		              <tr>
		                <td><a href="javascript:;" onclick="javascript:getTopWindow().generateReport('<%=strContextUser%>');" class="button"><button class="btn-primary" alt="Generate Report" type="button"><%=STR_METRICS_DONE%></button></a></td>
		                <td>&nbsp;&nbsp;</td>
		                <td><a href="javascript:;" onclick="javascript:getTopWindow().closeWindow();" class="button"><button class="btn-default" alt="Cancel" type="button"><%=STR_METRICS_CANCEL%></button></a></td>
		                <td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;&nbsp;</td>
		              </tr>
		            </table>
		          </td>
		        </tr>
		      </table>
		      <input type="image" height="1" width="1" border="0" name="inputImage" value=""/>
		    </form>
	    </div>
        <iframe class="hidden-frame" src="../common/emxBlank.jsp" name="metricsReportHidden" id="metricsReportHidden" frameborder="0" scrolling="no" height="0" width="0"></iframe>
    </body>
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
