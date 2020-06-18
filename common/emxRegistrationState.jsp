<%--  emxRegistrationState.jsp - This page for display of State property registration dialog
    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program
    
    static const char RCSID[] = $Id: emxRegistrationState.jsp.rca 1.8 Wed Oct 22 15:48:17 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxRegistrationStateInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxJSValidation.inc"%>
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

        String sHelpMarker                  = "emxhelpregisterstate";

        String suiteDir                     = (String) emxGetParameter(request, "SuiteDirectory");
        String languageStr                  = request.getHeader("Accept-Language");

        String strStatePropTitle            = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.StatePropertyTitle","emxFrameworkStringResource",languageStr);
        String strCreatePropRegistration    = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.CreatePropRegistration","emxFrameworkStringResource",languageStr);
        String strUpdatePropRegistration    = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.UpdatePropRegistration","emxFrameworkStringResource",languageStr);
        String strRemovePropRegistration    = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.RemovePropRegistration","emxFrameworkStringResource",languageStr); 
        String strPropertyName              = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.PropertyName","emxFrameworkStringResource",languageStr); 
        String strPropertyState             = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.PropertyState","emxFrameworkStringResource",languageStr); 
        String strStateNames                = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.StateName","emxFrameworkStringResource",languageStr);
        String strPolicy                    = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Policy","emxFrameworkStringResource",languageStr);
        String requiredText                 = UINavigatorUtil.getI18nString("emxFramework.Commom.RequiredText","emxFrameworkStringResource",languageStr);
        String strClose                     = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Close","emxFrameworkStringResource",languageStr);
%>
<head>
	<!-- //XSSOK -->
    <title><%=strStatePropTitle%></title>
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
<body onload="doLoad();turnOffProgress();" onUnload="showConfirmMsg()">
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
             <td class="page-title"  nowrap><h2><%=strStatePropTitle%></h2></td>
             <!-- //XSSOK -->
             <td nowrap="" class="functions"><div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=processingText%></i></div></td>    
            
        </tr>
        </table>        
        <div id="divToolbarContainer" class="toolbar-container"><div class="toolbar-frame" id="divToolbar"></div></div>
    </div>

    
    <div id="divPageBody">
    <div style="background-color: white; padding: 10pt; height: 100%;" >
    <form name="frmChangeState" id="frmChangeState" method="post">
    <input type="hidden" name="hdnMode" name="hdnMode" value="" />
    <input type="hidden" name="hdnPropertyIndex" name="hdnPropertyIndex" value="" />
    <input type="hidden" name="hdnPolicyIndex" name="hdnPolicyIndex" value="" />
    <input type="hidden" name="hdnStateIndex" name="hdnStateIndex" value="" />
    <table border="0" cellpadding="0" cellspacing="0"  width="1%" align="center" />
        <!-- //XSSOK -->
        <tr><td class="requiredNotice" align="center" nowrap ><%=requiredText%></td></tr>
    </table>
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <tr>
        <td><img src="../common/images/utilSpacer.gif" height="1" width="150"/></td>
        <td><img src="../common/images/utilSpacer.gif" height="1" width="100"/></td>
    </tr>
    
    <tr>
        <!-- //XSSOK -->
        <td width="100" class="label"><%=strPolicy%></td>
        <td colspan="2" class="inputField" width="100%"><select name="lstpolicy" id="lstpolicy" onchange="getStates();">
                                                <option value=""></option>
                                                <!-- \\XSSOK -->
                                                <%=adminBean.getPolicyList(context)%>
                                                </select>&nbsp;
        </td>
    </tr>
    <tr>
        <td class="inputField" colspan="2">
            <table border="0" cellspacing="0">
                <tr>
                    <!-- //XSSOK -->
                    <td nowrap><%=strPropertyState%></td>

                    <td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td>

                    <!-- //XSSOK -->
                    <td><%=strStateNames%></td>
                </tr>
                <tr>
                    <td>
                        <div id ="propertystates" name="propertystates">
                            <select name="lstpropertystates" id="lstpropertystates" size="10" style="width:200" width="200"></select>
                        </div>
                    </td>
                    <td><img src="../common/images/utilSpacer.gif" height="5" width="25"/></td>
                    <td>
                        <div id ="statenames" name="statenames">
                            <select name="lststatenames" id="lststatenames" size="10" style="width:200" width="200"></select>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td nowrap>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <!-- //XSSOK -->
                                <td class="labelRequired"><%=strPropertyName%>&nbsp;&nbsp;</td><td style="text-align: left"><input id="txtSymbolicName" name="txtSymbolicName" type="text" value="" size="35" /></td>
                            </tr>
                        </table>
                    </td>

                    <td><img src="../common/images/utilSpacer.gif" height="25" width="25"/></td>

                    <!-- //XSSOK -->
                    <td style="text-align: right;">&nbsp;<input type="button" name="Create" value="<%=strCreatePropRegistration%>" onclick="submitForm('create');" style="font-size: 9pt; width: 90px;" /></td>
                </tr>
    
                <tr>
                    <td nowrap>&nbsp;</td>
                    <td><img src="../common/images/utilSpacer.gif" height="25" width="25"/></td>
                    <!-- //XSSOK -->
                    <td style="text-align: right;">&nbsp;<input type="button" name="Update" value="<%=strUpdatePropRegistration%>" onclick="submitForm('update');" style="font-size: 9pt; width: 90px;" /></td>
                </tr>
    
                <tr>
                    <td nowrap>&nbsp;</td>
                    <td><img src="../common/images/utilSpacer.gif" height="25" width="25"/></td>
                    <!-- //XSSOK -->
                    <td style="text-align: right;">&nbsp;<input type="button" name="Remove" value="<%=strRemovePropRegistration%>" onclick="submitForm('delete');" style="font-size: 9pt; width: 90px;" /></td>
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
