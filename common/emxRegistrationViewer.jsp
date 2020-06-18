<%--  emxRegistrationViewer.jsp - This page for display of Viewer property registration dialog
    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program
    
    static const char RCSID[] = $Id: emxRegistrationViewer.jsp.rca 1.9 Wed Oct 22 15:48:04 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxRegistrationViewerInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<jsp:useBean id="adminBean" class="com.matrixone.apps.domain.util.RegistrationUtil"/>
<html>
<%
String accessUsers = "role_AdministrationManager,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}
    boolean blnAccess = false;
    try{
        //access check for the Business Admin privilege
        blnAccess = adminBean.checkAccess(context);
        if(!(blnAccess)){
            String errorMsg = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.BusinessAdminCheck", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
            throw new FrameworkException(errorMsg);
        }
        
        String sHelpMarker              = "emxhelpregisterviewer";
        String suiteDir                 = (String) emxGetParameter(request, "SuiteDirectory");
        String languageStr              = request.getHeader("Accept-Language");

        String strViewerPropTitle       = UINavigatorUtil.getI18nString("emxFramework.ViewerProperty.TypePropertyTitle","emxFrameworkStringResource",languageStr);
        String strFormats               = UINavigatorUtil.getI18nString("emxFramework.ViewerProperty.Formats","emxFrameworkStringResource",languageStr);
        String strAssignedViewers       = UINavigatorUtil.getI18nString("emxFramework.ViewerProperty.AssignedViewers","emxFrameworkStringResource",languageStr);
        String strUnassignedViewers     = UINavigatorUtil.getI18nString("emxFramework.ViewerProperty.UnassignedViewers","emxFrameworkStringResource",languageStr);
        String strViewerServlet         = UINavigatorUtil.getI18nString("emxFramework.ViewerProperty.ViewerServlet","emxFrameworkStringResource",languageStr);
        String strViewerTip             = UINavigatorUtil.getI18nString("emxFramework.ViewerProperty.ViewerTip","emxFrameworkStringResource",languageStr);

        String strAssign                = UINavigatorUtil.getI18nString("emxFramework.ViewerProperty.Assign","emxFrameworkStringResource",languageStr);
        String strUnassign              = UINavigatorUtil.getI18nString("emxFramework.ViewerProperty.Unassign","emxFrameworkStringResource",languageStr);
        String strCreateViewer          = UINavigatorUtil.getI18nString("emxFramework.ViewerProperty.CreateViewer","emxFrameworkStringResource",languageStr);
        String strModifyViewer          = UINavigatorUtil.getI18nString("emxFramework.ViewerProperty.ModifyViewer","emxFrameworkStringResource",languageStr);
        String strDeleteViewer          = UINavigatorUtil.getI18nString("emxFramework.ViewerProperty.DeleteViewer","emxFrameworkStringResource",languageStr); 
        String requiredText             = UINavigatorUtil.getI18nString("emxFramework.Commom.RequiredText","emxFrameworkStringResource",languageStr);
        String strClose                 = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Close","emxFrameworkStringResource",languageStr);
%>
<head>
    <!-- //XSSOK -->
    <title><%=strViewerPropTitle%></title>
    <script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
    <script type="text/javascript" src="../common/scripts/emxUICoreMenu.js"></script>
    <script type="text/javascript" src="../common/scripts/emxUIToolbar.js"></script>
    <script type="text/javascript" src="../common/scripts/emxAdminUtils.js"></script>

    <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />
    <link rel="stylesheet" type="text/css" href="../common/styles/emxUIMenu.css" />
    <link rel="stylesheet" type="text/css" href="../common/styles/emxUIForm.css" />
    <link rel="stylesheet" type="text/css" href="../common/styles/emxUIToolbar.css" />
    <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDOMLayout.css" />
    <script> 
        var COMMON_HELP     = "<emxUtil:i18n localize="i18nId">emxFramework.Common.Help</emxUtil:i18n>";
        //XSSOK
        var HELP_MARKER     = "<%=sHelpMarker%>";
        var SUITE_DIR       = "<xss:encodeForJavaScript><%=suiteDir%></xss:encodeForJavaScript>";
        var LANGUAGE_STRING = "<%=langStr%>"; 

        objToolbar = new emxUIToolbar(emxUIToolbar.MODE_NORMAL);        
        objToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionHelp.gif", COMMON_HELP, "javascript:openHelp(\"" + HELP_MARKER + "\", \"" + SUITE_DIR + "\", \"" + LANGUAGE_STRING + "\")"));

        function doLoad() {
            toolbars.init("divToolbar");
        }
    </script>
</head>
<body onload="doLoad();turnOffProgress();" onUnload="showConfirmMsg()">
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
            <td width="1%" nowrap><span class="pageHeader">&nbsp;<%=strViewerPropTitle%></span></td>
            <%
                String progressImage    = "../common/images/utilProgressSummary.gif";
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
    <div style="background-color: white; padding: 10pt; height: 100%;" >

    <form name="frmChangeViewer" id="frmChangeViewer" method="post">
        <input type="hidden" name="hdnMode" name="hdnMode" value="" />
        <input type="hidden" name="hdnAssignedIndex" name="hdnAssignedIndex" value="" />
        <input type="hidden" name="hdnAssignedValues" name="hdnAssignedValues" value="" />
        <input type="hidden" name="hdnFormatIndex" name="hdnFormatIndex" value="" />
        <input type="hidden" name="hdnViewerServletIndex" name="hdnViewerServletIndex" value="" />
        <input type="hidden" name="hdnViewerServlet" name="hdnViewerServlet" value="" />
        
        <table border="0" cellpadding="0" cellspacing="0"  width="1%" align="center">
            <!-- //XSSOK -->
            <tr><td class="requiredNotice" align="center" nowrap ><%=requiredText%></td></tr>
        </table>

        <table border="0" cellpadding="5" cellspacing="2" width="100%">
            <tr>
                <td><img src="../common/images/utilSpacer.gif" height="1" width="150"/></td>
                <td><img src="../common/images/utilSpacer.gif" height="1" width="150"/></td>
            </tr>
            <tr>
                <!-- //XSSOK -->
                <td width="150" class="label"><%=strFormats%></td>
                <td class="inputField" width="100%"><select name="lstformats" id="lstformats" tabindex="1" onchange="getViewers();">
                                                    <option value=""></option>
                                                    <!-- \\XSSOK -->
                                                    <%=adminBean.getFormatsList(context)%>
                                                </select>
                    &nbsp;<!--<input type="submit" name="RetrieveViewer" value="Retrieve Registered Viewers" style="font-size: 9pt; width: 160px;" />-->
                </td>
            </tr>
            <tr>
                <td class="inputField" colspan="3">
                    <table border="0" cellspacing="2">
                        <tr>
                            <!-- //XSSOK -->
                            <td nowrap><%=strAssignedViewers%></td>
                            <td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td>
                            <!-- //XSSOK -->
                            <td><%=strUnassignedViewers%></td>
                        </tr>
                        <tr>
                            <td>
                                <div id ="assignedviewers" name="assignedviewers">
                                    <select name="lstassignedviewers" id="lstassignedviewers" tabindex="2" size="10" multiple  style="width:100%"></select>
                                </div>
                            </td>
                            <td align="center">
                                <!-- //XSSOK -->
                                <input type="button" name="AssignViewers" value="<%=strAssign%>" tabindex="3" onclick="assignViewer('assign');" style="font-size: 9pt; width: 90px;" /><br/>
                                <!-- //XSSOK -->
                                <input type="button" name="UnassignViewers" value="<%=strUnassign%>" tabindex="4" onclick="assignViewer('unassign');" style="font-size: 9pt; width: 90px;" />
                            </td>
                            <td>
                                <div id ="unassignedviewers" name="unassignedviewers">
                                <!-- //XSSOK -->
                                    <select name="lstunassignedviewers" id="lstunassignedviewers" tabindex="5" size="10" multiple style="width:100%"><%=adminBean.getViewerServlets(context)%></select>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td nowrap colspan="3">
                                <table border="0" width="100%">
                                    <tr>
                                        <!-- //XSSOK -->
                                        <td><%=strViewerServlet%></td>
                                        <td><select name="lstviewerservlet" id="lstviewerservlet" tabindex="6" onchange="getViewerTip();">
                                                                    <option value=""></option>
                                                                    <!-- //XSSOK -->
                                                                    <%=adminBean.getViewerServlets(context)%>
                                                                  </select>&nbsp;<!--<input type="submit" name="RetrieveViewer" value="Retrieve Registered Viewers" style="font-size: 9pt; width: 160px;" />-->
                                        </td>
                                        <td rowspan="2" style="text-align: right;">  
                                            <table border="0" cellspacing="2">
                                                <tr>
                                                    <!-- //XSSOK -->
                                                    <td>&nbsp;<input type="button" name="Create" value="<%=strCreateViewer%>" tabindex="8" onclick="submitViewerForm('create');" style="font-size: 9pt; width: auto;" /></td>
                                                </tr>
                                                <tr>
                                                    <!-- //XSSOK -->
                                                    <td>&nbsp;<input type="button" name="Modify" value="<%=strModifyViewer%>" tabindex="9" onclick="submitViewerForm('update');" style="font-size: 9pt; width: auto;" /></td>
                                                </tr>
                                                <tr>
                                                    <!-- //XSSOK -->
                                                    <td>&nbsp;<input type="button" name="Delete" value="<%=strDeleteViewer%>" tabindex="10" onclick="submitViewerForm('delete');" style="font-size: 9pt; width: auto;" /></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td rowspan="2" style="text-align: left;">  
                                            <table border="0" width="100%" cellspacing="0">
                                                <tr>
                                                    <td >&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <!-- //XSSOK -->
                                                    <td class="labelRequired"><%=strViewerTip%></td>
                                                </tr>
                                                <tr>
                                                    <td>&nbsp;</td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td><input type="text" name="txtViewerTip" id="txtViewerTip"  tabindex="7" value="" size="15" maxlength="30" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr> 
                    </table>
                </td>
            </tr>
        </table>
    </form>
    </div>
    </div>
    <div id="divPageFoot">
        <div id="divDialogButtons">
            <table border="0" cellspacing="0">
              <tr>
                <td><a href="javascript:showConfirmMsg()"><img src="../common/images/buttonDialogCancel.gif" border="0" alt="Close" /></a></td>
                <!-- //XSSOK -->
                <td><a href="javascript:showConfirmMsg()" class="button"><%=strClose%></a></td>
              </tr>
            </table>
        </div>
    </div>
<%  
    } catch (Exception ex) {
        emxNavErrorObject.addMessage(ex.toString().trim());
    }
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
<%
    if(!(blnAccess)){
%>
        <script language="javascript">
            window.closeWindow();
        </script>
<%
    }
%>
<iframe src="emxBlank.jsp" name="AdminHidden" id="AdminHidden" width="0" height="0" frameborder="0" scrolling="no">
</html>
