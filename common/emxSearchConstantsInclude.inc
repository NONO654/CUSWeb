<%--  emxSearchConstantsInclude.inc

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchConstantsInclude.inc.rca 1.7 Wed Oct 22 15:48:28 2008 przemek Experimental przemek $
--%>

<%
// String Resource file to be used
String ResFileId = "emxFrameworkStringResource";

String STR_SEARCH_TITLE             = UINavigatorUtil.getI18nString("emxFramework.GlobalSearch.SearchTitle", ResFileId, request.getHeader("Accept-Language"));
String STR_SEARCH_RESAVE_FORM_DATA  = UINavigatorUtil.getI18nString("emxFramework.GlobalSearch.ErrorMsg.ReSaveFormData", ResFileId, request.getHeader("Accept-Language"));
String STR_SEARCH_EMPTY_NAME        = UINavigatorUtil.getI18nString("emxFramework.GlobalSearch.ErrorMsg.EmptyNameField", ResFileId, request.getHeader("Accept-Language"));
String STR_SEARCH_SELECT_TYPE       = UINavigatorUtil.getI18nString("emxFramework.GlobalSearch.ErrorMsg.SelectType", ResFileId, request.getHeader("Accept-Language"));
String STR_SEARCH_SELECT_VAULT      = UINavigatorUtil.getI18nString("emxFramework.Common.ErrorMsg.SelectVault", ResFileId, request.getHeader("Accept-Language"));
String STR_SEARCH_EMPTY_OPTION      = UINavigatorUtil.getI18nString("emxFramework.GlobalSearch.ErrorMsg.SelectSearch", ResFileId, request.getHeader("Accept-Language"));
String STR_SEARCH_LOGIN_TITLE      = UINavigatorUtil.getI18nString("emxFramework.Login.Title", ResFileId, request.getHeader("Accept-Language"));
%>

        <script language="javascript">
            //XSSOK
            var STR_SEARCH_TITLE            = "<%= STR_SEARCH_LOGIN_TITLE%>" + " <%= STR_SEARCH_TITLE %> ";
            //XSSOK
            var STR_SEARCH_RESAVE_FORM_DATA = "<%= STR_SEARCH_RESAVE_FORM_DATA %>";
            //XSSOK
            var STR_SEARCH_EMPTY_NAME       = "<%= STR_SEARCH_EMPTY_NAME %>";
            //XSSOK
            var STR_SEARCH_SELECT_TYPE      = "<%= STR_SEARCH_SELECT_TYPE %>";
            //XSSOK
            var STR_SEARCH_LANG             = "<%= langStr %>";
            //XSSOK
            var STR_SEARCH_LANG_ONLINE      = "<%= langOnlineStr %>";
            //XSSOK
            var STR_SEARCH_SELECT_VAULT     = "<%= STR_SEARCH_SELECT_VAULT %>";
            //XSSOK
            var STR_SEARCH_EMPTY_OPTION     = "<%= STR_SEARCH_EMPTY_OPTION %>";            
        </script>


