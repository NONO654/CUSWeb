<%--  emxMetricsPolicyChooser.jsp  -  This page displays the Policy(s) and the associated states of the chosen Type

  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
  
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxMetricsPolicyChooser.jsp.rca 1.10 Wed Oct 22 16:11:58 2008 przemek Experimental $
--%>
<!DOCTYPE html>
<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxMetricsConstantsInclude.inc"%>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="request"/>
<%
    String fieldNameDisplay         = emxGetParameter(request,"fieldNameDisplay");
    String fieldNameActual          = emxGetParameter(request,"fieldNameActual");
    String action                   = emxGetParameter(request,"action");
    String multiSelect              = emxGetParameter(request,"multiSelect");
    String formName                 = emxGetParameter(request,"formName");
    String frameName                = emxGetParameter(request,"frameName");
    String allowNoSelection         = emxGetParameter(request,"allowNoSelection");
    String languageStr              = request.getHeader("Accept-Language");
    String emxType                  = emxGetParameter(request, "selectedType");
    String strConsPolicy            = "Policy";
    String suiteDirStr              = "";
    String sHelpMarker              = "emxhelppolicychooser";
    String selectType               = "";
    String strCancel                = "";
    String strSelect                = "";
    String pageHeading              = "";
    HashMap hmDetailsMap            = null;
    String strTransPolicyNames      = "";
    MapList mpList                  = null;
    String strDisplayPolicyNames    = "";

        suiteDirStr = (String)session.getAttribute("passesSuitedir");

    if(suiteDirStr == null || "null".equals(suiteDirStr) || !(suiteDirStr.length() > 0)) {
        suiteDirStr = "businessmetrics";
    }

    if(multiSelect == null || "null".equalsIgnoreCase(multiSelect) || "".equalsIgnoreCase(multiSelect)){
        multiSelect = "true";
    }

    if(allowNoSelection == null || "null".equalsIgnoreCase(allowNoSelection) || "".equalsIgnoreCase(allowNoSelection)){
        allowNoSelection = "false";
    }

    try {
        String I18NResourceBundle = "emxFrameworkStringResource";
        String I18NResourceBundle1 = "emxMetricsStringResource";
        strCancel = EnoviaResourceBundle.getProperty(context, I18NResourceBundle,context.getLocale(), "emxFramework.Button.Cancel");
        strSelect = EnoviaResourceBundle.getProperty(context, I18NResourceBundle,context.getLocale(), "emxFramework.IconMail.Common.Select");
        pageHeading = EnoviaResourceBundle.getProperty(context, I18NResourceBundle1,context.getLocale(), "emxMetrics.label.SelectPolicy");
        hmDetailsMap = metricsReportBean.getPolicyAndStateNames(context, emxType, languageStr);
        mpList = (MapList) hmDetailsMap.get(metricsReportBean.DETAILS_POLICY_KEY);
        strTransPolicyNames = (String) hmDetailsMap.get(metricsReportBean.TRANSLATED_POLICY_NAMES);
        strDisplayPolicyNames = FrameworkUtil.findAndReplace(strTransPolicyNames+"","'","\\\'");
    }
    catch(Exception ex){
        if(ex.toString() != null && (ex.toString().trim()).length() > 0) {
            emxNavErrorObject.addMessage(ex.toString().trim());
        }
    }

    // Assign the style sheet to be used based on the input
    String cssFile = EnoviaResourceBundle.getProperty(context, "emxNavigator.UITable.Style.List");
    boolean useDefaultCSS=false;
    if(cssFile == null || cssFile.equals("") || cssFile.equals("null") || cssFile.trim().length() == 0){
        useDefaultCSS=true;
    }
%>
<head>
    <title><%=pageHeading%></title>
    <script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>    
    <script language="javascript" src="../common/scripts/emxUIToolbar.js"></script>
    <script type="text/javascript" src="emxMetricsPolicyChooserUtils.js"></script>
    <script src="../common/scripts/emxNavigatorHelp.js" type="text/javascript"></script>

    <script language="JavaScript">
        addStyleSheet("emxUIToolbar");
        addStyleSheet("emxUIMetricsDialog");
        var strPageIDs = "~";
    </script>
    <script>
        var COMMON_HELP     = "<emxUtil:i18n localize="i18nId">emxFramework.Common.Help</emxUtil:i18n>";
        //XSSOK
        var HELP_MARKER     = "<%=sHelpMarker%>";
        var SUITE_DIR       = "<xss:encodeForJavaScript><%=suiteDirStr%></xss:encodeForJavaScript>";
        var LANGUAGE_STRING = "<%=langStr%>";
        objToolbar = new emxUIToolbar(emxUIToolbar.MODE_NORMAL);
        objToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionHelp.gif", COMMON_HELP, "javascript:openHelp(\"" + HELP_MARKER + "\", \"" + SUITE_DIR + "\", \"" + LANGUAGE_STRING + "\")"));

        function doLoad() {
            toolbars.init("divToolbar");
        }
    </script>
    <%
        if(useDefaultCSS)
        {
    %>
            <%@include file = "../emxStyleListInclude.inc"%>
    <%
        } else { %>
             <script>
                 addStyleSheet("<%=cssFile%>");
             </script>
        <% } %>
</head>

<body onload="doLoad();turnOffProgress();" class="dialog">
    <form name="policyForm" method="post" action="">
    <div id="divPageHead">
        <table border="0" cellspacing="2" cellpadding="0" width="100%">
        <tr>
            <td width="100%">
                <table border="0" cellspacing="0" cellpadding="0" width="100%">
                <tr>
                    <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
                </tr>
                </table>
            </td>
        </table>
        <table border="0">
        <tr>
            <td width="1%" nowrap><span class="pageHeader">&nbsp;<%=pageHeading%></span></td>
            <%
                String progressImage    = "../common/images/utilProgressBlue.gif";
                String processingText   = UINavigatorUtil.getProcessingText(context, languageStr);
            %>
            <td>
            <!-- //XSSOK -->
               <div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=processingText%></i></div>
            </td>
        </tr>
        </table>
        <div class="toolbar-container"><div class="toolbar-frame" id="divToolbar"></div></div>
    </div>
    <div id="divPageBody">
        <div style="padding: 10pt; height: 100%;" >
        <!-- //XSSOK -->
            <framework:sortInit defaultSortKey="Policy" defaultSortType="string" resourceBundle="emxFrameworkStringResource" mapList="<%= mpList %>" ascendText="SortAscending.Common.SortAscending" descendText="SortAscending.Common.SortDescending"/>

            <table width="100%" border="0" cellpadding="3" cellspacing="2">
            <!-- Table Column Headers -->
                <tr>
                    <%
                        if(multiSelect.equalsIgnoreCase("true"))
                        {
                            selectType = "checkbox";
                    %>
                    <th width="5%" ><input type="checkbox" name="chkList" id="chkList" onclick="getTopWindow().doCheck()" /></th>
                    <%
                        }
                    %>
                    <th nowrap="nowrap">
                        <framework:sortColumnHeader
                            title="emxFramework.Basic.Policy"
                            sortKey="Policy"
                            sortType="string"
                            anchorClass="sortMenuItem" />
                    </th>
                    <th nowrap="nowrap">
                        <framework:sortColumnHeader
                            title="emxFramework.History.State"
                            sortKey="States"
                            sortType="string"
                            anchorClass="sortMenuItem" />
                    </th>
                </tr>

                <framework:mapListItr mapList="<%= mpList %>" mapName="policyMap"><!-- XSSOK -->
                    <tr class='<framework:swap id="1"/>'>
                        <%
                            String strDisplayPolicy = (String) policyMap.get("Policy");
                            String strDisplayState = (String)policyMap.get("States");
                            StringBuffer strPlyStaName = new StringBuffer();
                            StringTokenizer stDispState = new StringTokenizer(strDisplayState,"|");
                            while (stDispState.hasMoreTokens()){
                                String preParseTkn = stDispState.nextToken();
                                String strTranslatedForm = i18nNow.getStateI18NString(strDisplayPolicy, preParseTkn, languageStr);
                                strPlyStaName.append(strTranslatedForm);
                                strPlyStaName.append(":");
                            }
                            String strPolicyStatesNameSap = strPlyStaName.toString().substring(0,strPlyStaName.toString().length()-1);
                            if(action == null || "".equals(action) || "null".equals(action))
                            {
                                %>
                                <!-- //XSSOK -->
                                <td><input type="<%=selectType%>" name="policy" value="<%=strDisplayPolicy + "|" + strDisplayState+ ";"+strPolicyStatesNameSap %>" onclick="getTopWindow().updateCheck('<%=selectType%>')" /></td>
                                <%
                            }
                        %>
                        <td><%=i18nNow.getAdminI18NString("Policy", strDisplayPolicy, languageStr)%></td>
                        <input type="hidden" name="translatedPolicy" value="<%=i18nNow.getAdminI18NString(strConsPolicy, strDisplayPolicy, languageStr)%>" />
                        <td>
                            <%
                                try{
                                    StringTokenizer token = new StringTokenizer(strDisplayState,"|");
                                    while (token.hasMoreTokens()){
                                        String preParse = token.nextToken();
                                        String strTranslatedForm = i18nNow.getStateI18NString(strDisplayPolicy, preParse, languageStr);
                            %>
                                        <%=strTranslatedForm%><br/>
                                <%
                                    }
                                %>
                                    <input type="hidden" name="<%=strDisplayPolicy%>" value="<%=strDisplayState%>" />
                                <%
                                    }
                                    catch(Exception e){
                                        e.printStackTrace();
                                    }
                                %>
                        </td>
                    </tr>
                </framework:mapListItr>
            </table>
        </div>
    </div>

    <div id="divPageFoot">
        <div id="divDialogButtons">
            <table border="0" cellspacing="0">
                <tr>
                    <td width="80%">&nbsp;&nbsp;</td>
                    <td><a onclick="javascript:checkPolicy(document.forms[0],'<%=strDisplayPolicyNames%>','<xss:encodeForJavaScript><%=fieldNameDisplay%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=fieldNameActual%></xss:encodeForJavaScript>')" class="button">
                    <button class="btn-primary" type="button"><%=strSelect%></button></a></td>
                    <td>&nbsp;&nbsp;</td>
                    <td><a onclick="javascript:doCancel()" class="button">
                    <button class="btn-default" type="button"><%=strCancel%></button></a></td>
                    <td>&nbsp;&nbsp;</td><td>&nbsp;&nbsp;</td>
                </tr>
            </table>
        </div>
    </div>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </form>
</body>
</html>
