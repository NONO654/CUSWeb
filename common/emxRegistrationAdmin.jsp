<%--  emxRegistrationAdmin.jsp - This page for display of Admin property registration dialog
    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program
    
    static const char RCSID[] = $Id: emxRegistrationAdmin.jsp.rca 1.8 Wed Oct 22 15:47:46 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxRegistrationAdminInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>

<html>
<jsp:useBean id="adminBean" class="com.matrixone.apps.domain.util.RegistrationUtil"/>
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

    //format dates
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);

    // get today's date as the installed date
    long InstalledDate = 0;
    Date date = new Date();
    String installedDate  = sdf.format(date);
    InstalledDate         = sdf.parse(installedDate).getTime();
    // Define the date format.
    String dateFormat     = (new Integer(eMatrixDateFormat.getEMatrixDisplayDateFormat())).toString();
    // Set the time zone.
    String timeZone       = (String) session.getAttribute("timeZone");

    String sHelpMarker              = "emxhelpregisteradmin";
    String suiteDir                 = (String) emxGetParameter(request, "SuiteDirectory");
    String languageStr              = request.getHeader("Accept-Language");

    String strAdminPropTitle        = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.TypePropertyTitle","emxFrameworkStringResource",languageStr);
    String strRegisteredAdmins      = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.RegisteredAdmins","emxFrameworkStringResource",languageStr);
    String strUnRegisteredAdmins    = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.UnRegisteredAdmins","emxFrameworkStringResource",languageStr);
    String strSymbolicName          = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.SymbolicName","emxFrameworkStringResource",languageStr);
    String strApplication           = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Application","emxFrameworkStringResource",languageStr);
    String strVersion               = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Version","emxFrameworkStringResource",languageStr);
    String strInstaller             = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Installer","emxFrameworkStringResource",languageStr);
    String strInstalledDate         = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.InstalledDate","emxFrameworkStringResource",languageStr);
    String strOriginalName          = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.OriginalName","emxFrameworkStringResource",languageStr);
    String strAdminType             = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType","emxFrameworkStringResource",languageStr);

    String strRetrieveRegistration  = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.RetrieveRegistration","emxFrameworkStringResource",languageStr);
    String strTransferRegistration  = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.TransferRegistration","emxFrameworkStringResource",languageStr);
    String strCreateRegistration    = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.CreateRegistration","emxFrameworkStringResource",languageStr);
    String strUpdateRegistration    = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.UpdateRegistration","emxFrameworkStringResource",languageStr);
    String strDeleteRegistration    = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.DeleteRegistration","emxFrameworkStringResource",languageStr);
    String requiredText             = UINavigatorUtil.getI18nString("emxFramework.Commom.RequiredText","emxFrameworkStringResource",languageStr);
    String strClose                 = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Close","emxFrameworkStringResource",languageStr);
    %>

<head>
    <!-- //XSSOK -->
    <title><%=strAdminPropTitle%></title>
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
        objToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionHelp.png", COMMON_HELP, "javascript:openHelp(\"" + HELP_MARKER + "\", \"" + SUITE_DIR + "\", \"" + LANGUAGE_STRING + "\")"));
        function doLoad() {
            toolbars.init("divToolbar");
        }
    </script>
</head>
<body onload="doLoad();turnOffProgress();" action="emxChangeAdminPropertyProcess.jsp" onsubmit="doSubmit();" onUnload="showConfirmMsg()">
    <div id="pageHeadDiv">
        <table border="0" cellspacing="2" cellpadding="0" width="100%" style="display:none">
        <tr>
            <td width="100%">
                <table border="0" cellspacing="0" cellpadding="0" width="100%">
                <tr>
                    <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
                </tr>
                </table>
            </td>
        </table>
        <%
            String progressImage    = "../common/images/utilProgressBlue.gif";
            String processingText   = UINavigatorUtil.getProcessingText(context, languageStr);
        %>
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <!-- //XSSOK -->
            <td class="page-title"  nowrap><h2><%=strAdminPropTitle%></h2>
            <!-- //XSSOK -->
            <td nowrap class="functions"><div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=processingText%></i></div></td>
        </tr>
        </table>
        <div id="divToolbarContainer" class="toolbar-container"><div class="toolbar-frame" id="divToolbar"></div></div>
    </div>

    <div id="divPageBody">
    <div style="background-color: white; padding: 10pt; height: 100%;" >
    <form name="frmChangeAdmin" id="frmChangeAdmin" method="post">
    <input type="hidden" name="hdnMode" id="hdnMode" value="" />
    <input type="hidden" name="hdnAdminTypeIndex" id="hdnAdminTypeIndex" value="" />
    <input type="hidden" name="hdnRegListIndex" id="hdnRegListIndex" value="" />
    <input type="hidden" name="hdnUnRegListIndex" id="hdnUnRegListIndex" value="" />
    <input type="hidden" name="hdnregisteredadmins" id="hdnregisteredadmins" value="" />
    <!-- //XSSOK -->
    <input type="hidden" name="hdnCurrentDate" id="hdnCurrentDate" value="<framework:lzDate localize='i18nId' tz='<%=XSSUtil.encodeForHTMLAttribute(context, timeZone) %>' format='<%= dateFormat %>' displaydate='true' displaytime='false'><%=installedDate%></framework:lzDate>" />
    <table border="0" cellpadding="0" cellspacing="0"  width="1%" align="center">
        <!-- //XSSOK -->
        <tr><td class="requiredNotice" align="center" nowrap ><%=requiredText%></td></tr>
    </table>

    <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
        <!-- //XSSOK -->
        <td width="150" class="label"><%=strAdminType%></td>
        <td class="inputField" width="100%">
        <select name="lstAdminType" tabindex="1" onchange="getLists();" id="lstAdminType">
            <option value=""></option>
            <%
                StringBuffer sbOptions = new StringBuffer("");
                for(int i=0;i<arrAdminType.length;i++){
                   sbOptions.append("<option value=\""+arrAdminType[i][0]+"\">"+arrAdminType[i][1]+"</option>");
                }
            %>
            <%=sbOptions.toString()%>
        </select>
        </td>
        </tr>
        <tr>
        <td class="inputField" colspan="2">
        <table border="0" cellspacing="0">
        <tr>
            <!-- //XSSOK -->
            <td nowrap><%=strRegisteredAdmins%>&nbsp;<input type="button" tabindex="2" name="RetrieveRegistration" value="<%=strRetrieveRegistration%>" onclick="getProperties();" style="font-size: 9pt; width: 140px; padding: 6px 10px; float: left;" class="btn-default;”> /></td>
            <td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td>
            <!-- //XSSOK -->
            <td><%=strUnRegisteredAdmins%></td>
        </tr>
        <tr><td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td></tr>
        <tr><td>
        <div id ="lstreg" name="lstreg">
            <select name="lstregisteredadmins" id="lstregisteredadmins" tabindex="3" onselect="disablefields();"  onchange="disablefields();" size="10" style="width:250px" width="250"></select>
        </div>
        </td>
        <td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td>
        <td>
        <div id ="lstunreg" name="lstunreg">
            <select name="lstunregisteredadmins" id="lstunregisteredadmins" tabindex="4" size="10" style="width:250px" width="250"></select>
        </div>
        </td>
        </tr>
        <tr><td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td></tr>
        <tr>
        <td nowrap>
        <table width="100%" border="0" cellspacing="0">
            <!-- //XSSOK -->
            <tr><td width="100" class="labelRequired"><%=strSymbolicName%></td><td style="text-align: left"><input type="text" id="txtSymbolicName" name="txtSymbolicName" tabindex="5" value="" size="15" /></td></tr></table>
        </td>
        <td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td>
        <!-- //XSSOK -->
        <td style="text-align: right;"><input type="button" name="btnTransferRegistration" value="<%=strTransferRegistration%>" tabindex="11"  onclick="transferSubmit();" style="font-size: 9pt; width: 140px;" /></td>
    </tr>
    <tr>
    <td nowrap>
    <table width="100%" border="0" cellspacing="0">
    <!-- //XSSOK -->
    <tr><td width="100" class="labelRequired"><%=strApplication%></td><td style="text-align: left"><input type="text" id="txtApplication" name="txtApplication" tabindex="6" value="" size="15" maxlength="30; width: 140px;" /></td></tr></table>
    </td>
    </td>

    <td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td>
    <!-- //XSSOK -->
    <td style="text-align: right;"><input type="button" name="btnCreateRegistration" value="<%=strCreateRegistration%>" tabindex="12" onclick="createSubmit();" style="font-size: 9pt; width: 140px;" /></td>
    </tr>
    <tr>
        <td nowrap>
        <table width="100%" border="0" cellspacing="0">
        <!-- //XSSOK -->
        <tr><td width="100" class="labelRequired"><%=strVersion%></td><td style="text-align: left"><input type="text" id="txtVersion" name="txtVersion" tabindex="7" value="" size="15" maxlength="30" /></td></tr></table>
        </td>

        <td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td>
        <!-- //XSSOK -->
        <td style="text-align: right;"><input type="button" name="btnUpdateRegistration" value="<%=strUpdateRegistration%>" tabindex="13" onclick="updateSubmit();" style="font-size: 9pt; width: 140px;" /></td>
        </tr>

    <tr>
        <td nowrap>
        <table width="100%" border="0" cellspacing="0">
        <!-- //XSSOK -->
        <tr><td width="100" class="labelRequired"><%=strInstaller%></td><td style="text-align: left"><input type="text" id="txtInstaller" name="txtInstaller" tabindex="8" value="" size="15" maxlength="30" /></td></tr></table>
        </td>
        </td>

        <td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td>
        <!-- //XSSOK -->
        <td style="text-align: right;"><input type="button" name="btnDeleteRegistration" value="<%=strDeleteRegistration%>" tabindex="14" onclick="deleteSubmit();" style="font-size: 9pt ; width: 140px;" /></td>
        </tr>

    <tr>
        <td nowrap>
        <table width="100%" border="0" cellspacing="0">
        <!-- //XSSOK -->
        <tr><td width="100" class="labelRequired"><%=strInstalledDate%></td><td style="text-align: left"><input type="text"  id="txtInstalledDate" name="txtInstalledDate" tabindex="9" value="<framework:lzDate localize='i18nId' tz='<%=XSSUtil.encodeForHTMLAttribute(context, timeZone) %>' format='<%= dateFormat %>' displaydate='true' displaytime='false'><%=installedDate%></framework:lzDate>" size="15" readonly="readonly" maxlength="30">
        <a href="javascript:showCalendar('frmChangeAdmin','txtInstalledDate','')">
                    <img src="../common/images/iconSmallCalendar.gif" border="0" valign="absmiddle" name="img5" />
                </a>
        </td></tr></table>
        </td>
        </td>
        <td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td>
        <td>&nbsp;</td>
        </tr>

    <tr>
        <td nowrap>
        <table width="100%" border="0" cellspacing="0">
        <!-- //XSSOK -->
        <tr><td width="100" class="labelRequired"><%=strOriginalName%></td><td style="text-align: left"><input type="text" id="txtOriginalName" name="txtOriginalName" tabindex="10" value="" size="15" /></td></tr></table>
        </td>
        </td>
        <td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td>
        <td>&nbsp;</td>
        </tr>
    </table>
    </td>
    </tr>

    <tr>
        <td class=""><img src="../common/images/utilSpacer.gif" height="5" width="150"/></td>
        <td class="">&nbsp;</td>
    </tr>
    </table>
    </form>
    </div>
    </div>
    <div id="divPageFoot">
    <div id="divDialogButtons">
        <table border="0" cellspacing="0">
        <tr>
        <td class="buttons"><a href="javascript:showConfirmMsg()" class="footericon"><img src="../common/images/buttonDialogCancel.gif" border="0" alt="Close" /></a></td>
        <!-- //XSSOK -->
        <td class="buttons"><a href="javascript:showConfirmMsg()" class="button"><button class="btn-default"><%=strClose%></button></a></td>
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
