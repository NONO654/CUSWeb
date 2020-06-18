<%--  emxRegistrationViewerInclude.inc - The static include file for Viewer property registration

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRegistrationViewerInclude.inc.rca 1.5 Wed Oct 22 15:48:50 2008 przemek Experimental przemek $
--%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%
// String Resource file to be used
String ResFileId = "emxFrameworkStringResource";

String STR_ITEM_ASSIGN                         = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Viewer.StrItemAssign", ResFileId, request.getHeader("Accept-Language"));
String STR_ITEM_UNASSIGN                       = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Viewer.StrItemUnassign", ResFileId, request.getHeader("Accept-Language"));
String STR_ITEM_CREATE_MODIFY_VIEWER           = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Viewer.StrItemCreateModifyViewer", ResFileId, request.getHeader("Accept-Language"));
String STR_ITEM_DELETE_VIEWER                  = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Viewer.StrItemDeleteViewer", ResFileId, request.getHeader("Accept-Language"));
String STR_ITEM_CREATE_MODIFY_VIEWERTIP        = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Viewer.StrItemCreateModifyViewerTip", ResFileId, request.getHeader("Accept-Language"));
String STR_ITEM_SELECT_FORMAT                  = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Viewer.StrItemSelectFormat", ResFileId, request.getHeader("Accept-Language"));
String STR_ITEM_VIEWER_NAME                    = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.Viewer.StrItemViewerName", ResFileId, request.getHeader("Accept-Language"));
String STR_RELOAD_CACHE                        = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.StrReloadCache", ResFileId, request.getHeader("Accept-Language"));
String STR_ITEM_BAD_CHARS                      = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.BadChars", ResFileId, request.getHeader("Accept-Language"));
String STR_ITEM_ALERT_MAX_CHAR_LENGTH          = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.CheckLength", ResFileId, request.getHeader("Accept-Language"));
String STR_ITEM_MAX_CHAR_LENGTH                = EnoviaResourceBundle.getProperty(context, "emxFramework.MAX_FIELD_LENGTH"); 

%>

    

        <script language="javascript">
            //XSSOK
            var STR_ITEM_ASSIGN                           = "<%= STR_ITEM_ASSIGN %> ";
            //XSSOK
            var STR_ITEM_UNASSIGN                         = "<%= STR_ITEM_UNASSIGN %>";
            //XSSOK
            var STR_ITEM_CREATE_MODIFY_VIEWER             = "<%= STR_ITEM_CREATE_MODIFY_VIEWER %>";
            //XSSOK
            var STR_ITEM_DELETE_VIEWER                    = "<%= STR_ITEM_DELETE_VIEWER %>";
            //XSSOK
            var STR_ITEM_CREATE_MODIFY_VIEWERTIP          = "<%= STR_ITEM_CREATE_MODIFY_VIEWERTIP %>";
            //XSSOK
            var STR_ITEM_SELECT_FORMAT                    = "<%= STR_ITEM_SELECT_FORMAT %>";
            //XSSOK
            var STR_ITEM_VIEWER_NAME                      = "<%= STR_ITEM_VIEWER_NAME %>";
            //XSSOK
            var STR_RELOAD_CACHE                          = "<%= STR_RELOAD_CACHE %>";
            //XSSOK
            var STR_ITEM_BAD_CHARS                        = "<%= STR_ITEM_BAD_CHARS %>";
            //XSSOK
            var STR_ITEM_ALERT_MAX_CHAR_LENGTH            = "<%= STR_ITEM_ALERT_MAX_CHAR_LENGTH %>";
            //XSSOK
            var STR_ITEM_MAX_CHAR_LENGTH                  = "<%= STR_ITEM_MAX_CHAR_LENGTH %>";           
        </script>


