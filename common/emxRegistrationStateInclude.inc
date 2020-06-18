<%--  emxRegistrationStateInclude.inc - The static include file for State property registration

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRegistrationStateInclude.inc.rca 1.5 Wed Oct 22 15:48:05 2008 przemek Experimental przemek $
--%>

<%
    // String Resource file to be used
    String ResFileId                               = "emxFrameworkStringResource";
    
    String STR_ITEM_POLICY                         = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.State.StrItemPolicy", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_PROPERTY_STATE_DELETE          = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.State.StrItemPropertyStateDelete", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_STATE_CREATE                   = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.State.StrItemStateCreate", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_STATE_FORMAT                   = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.State.StrItemStateFormat", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_PROPERTY_STATE_UPDATE          = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.State.StrItemPropertyStateUpdate", ResFileId, request.getHeader("Accept-Language"));
    String STR_RELOAD_CACHE                        = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.StrReloadCache", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_BAD_CHARS                      = UINavigatorUtil.getI18nString("emxFramework.Common.InvalidName", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_STATE_UPDATE                   = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.State.StrItemStateUpdate", ResFileId, request.getHeader("Accept-Language"));

    String STR_REQUIRED_SYMBOLICNAME               = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.PleaseEnterSymbolicName", ResFileId, request.getHeader("Accept-Language"));
%>

<script language="javascript">
    //XSSOK
    var STR_ITEM_POLICY                            = "<%= STR_ITEM_POLICY %> ";
    //XSSOK
    var STR_ITEM_PROPERTY_STATE_DELETE             = "<%= STR_ITEM_PROPERTY_STATE_DELETE %>";
    //XSSOK
    var STR_ITEM_STATE_CREATE                      = "<%= STR_ITEM_STATE_CREATE %>";
    //XSSOK
    var STR_ITEM_STATE_FORMAT                      = "<%= STR_ITEM_STATE_FORMAT %>";
    //XSSOK
    var STR_ITEM_PROPERTY_STATE_UPDATE             = "<%= STR_ITEM_PROPERTY_STATE_UPDATE %>";
    //XSSOK
    var STR_RELOAD_CACHE                           = "<%= STR_RELOAD_CACHE %>";
    //XSSOK
    var STR_ITEM_BAD_CHARS                         = "<%= STR_ITEM_BAD_CHARS %>";
    //XSSOK
    var STR_ITEM_STATE_UPDATE                      = "<%= STR_ITEM_STATE_UPDATE %>";
    //XSSOK
    var STR_REQUIRED_SYMBOLICNAME                  = "<%= STR_REQUIRED_SYMBOLICNAME %>";

</script>


