<%--  emxRegistrationAdminInclude.inc - The static include file for Admin property registration
    
    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program
    
    static const char RCSID[] = $Id: emxRegistrationAdminInclude.inc.rca 1.6 Wed Oct 22 15:48:28 2008 przemek Experimental przemek $
--%>

<%
    // String Resource file to be used
    String ResFileId                               = "emxFrameworkStringResource";
    
    String STR_ITEM_REGISTERED_ADMINS              = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.StrItemRegisteredAdmins", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_ADMIN_TYPE                     = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.StrItemAdminType ", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_REGISTERED_ADMINS_DELETE       = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.StrItemRegisteredAdminsDelete", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_UNREGISTERED_ADMINS_CREATE     = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.StrItemUnregisteredAdminsCreate", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_REGISTERED_ADMINS_TRANSFER     = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.StrItemRegisteredAdminsTransfer", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_UNREGISTERED_ADMINS_TRANSFER     = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.StrItemUnRegisteredAdminsTransfer", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_REGISTERED_ADMINS_UPDATE       = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.StrItemRegisteredAdminsUpdate", ResFileId, request.getHeader("Accept-Language"));
    String STR_STATE_PROPERTY_FORMAT               = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.StrStatePropertyFormat", ResFileId, request.getHeader("Accept-Language"));
    String STR_RELOAD_CACHE                        = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.StrReloadCache", ResFileId, request.getHeader("Accept-Language"));
    String STR_ITEM_BAD_CHARS                      = UINavigatorUtil.getI18nString("emxFramework.Common.InvalidName", ResFileId, request.getHeader("Accept-Language"));


    String STR_REQUIRED_SYMBOLICNAME               = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.PleaseEnterSymbolicName", ResFileId, request.getHeader("Accept-Language"));
    String STR_REQUIRED_APPLICATION                = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.PleaseEnterApplication", ResFileId, request.getHeader("Accept-Language"));
    String STR_REQUIRED_VERSION                    = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.PleaseEnterVersion", ResFileId, request.getHeader("Accept-Language"));
    String STR_REQUIRED_INSTALLER                  = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.PleaseEnterInstaller", ResFileId, request.getHeader("Accept-Language"));
    String STR_REQUIRED_INSTALLEDDATE              = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.PleaseEnterInstalledDate", ResFileId, request.getHeader("Accept-Language"));
    String STR_REQUIRED_ORIGINALNAME               = UINavigatorUtil.getI18nString("emxFramework.AdminProperty.AdminType.PleaseEnterOriginalName", ResFileId, request.getHeader("Accept-Language"));

    //String[] arrAdminType                        = {"association","att","channel","command","form","format","group","inquiry","menu","person","policy","portal","relationship","role","store","table","type","lattice","wizard"};
    String[][] arrAdminType                        = {{"association","association"},{"att","attribute"},{"channel","channel"},{"command","command"},{"form","form"},{"format","format"},{"group","group"},{"inquiry","inquiry"},{"interface","interface"},{"dimension","dimension"},{"menu","menu"},{"person","person"},{"policy","policy"},{"portal","portal"},{"relationship","relationship"},{"role","role"},{"store","store"},{"table","table"},{"type","type"},{"lattice","vault"},{"wizard","wizard"}};

%>

<script language="javascript">
    //XSSOK
    var STR_ITEM_REGISTERED_ADMINS                 = "<%= STR_ITEM_REGISTERED_ADMINS %> ";
    //XSSOK
    var STR_ITEM_ADMIN_TYPE                        = "<%= STR_ITEM_ADMIN_TYPE %>";
    //XSSOK
    var STR_ITEM_REGISTERED_ADMINS_DELETE          = "<%= STR_ITEM_REGISTERED_ADMINS_DELETE %>";
    //XSSOK
    var STR_ITEM_UNREGISTERED_ADMINS_CREATE        = "<%= STR_ITEM_UNREGISTERED_ADMINS_CREATE %>";
    //XSSOK
    var STR_ITEM_REGISTERED_ADMINS_TRANSFER        = "<%= STR_ITEM_REGISTERED_ADMINS_TRANSFER %>";
    //XSSOK
    var STR_ITEM_UNREGISTERED_ADMINS_TRANSFER      = "<%= STR_ITEM_UNREGISTERED_ADMINS_TRANSFER %>";
    //XSSOK
    var STR_ITEM_REGISTERED_ADMINS_UPDATE          = "<%= STR_ITEM_REGISTERED_ADMINS_UPDATE %>";
    //XSSOK
    var STR_STATE_PROPERTY_FORMAT                  = "<%= STR_STATE_PROPERTY_FORMAT %>";
    //XSSOK
    var STR_RELOAD_CACHE                           = "<%= STR_RELOAD_CACHE %>";
    //XSSOK
    var STR_ITEM_BAD_CHARS                         = "<%= STR_ITEM_BAD_CHARS %>";
    
    //XSSOK
    var STR_REQUIRED_SYMBOLICNAME                  = "<%= STR_REQUIRED_SYMBOLICNAME %>";
    //XSSOK
    var STR_REQUIRED_APPLICATION                   = "<%= STR_REQUIRED_APPLICATION %>";
    //XSSOK
    var STR_REQUIRED_VERSION                       = "<%= STR_REQUIRED_VERSION %>";
    //XSSOK
    var STR_REQUIRED_INSTALLER                     = "<%= STR_REQUIRED_INSTALLER %>";
    //XSSOK
    var STR_REQUIRED_INSTALLEDDATE                 = "<%= STR_REQUIRED_INSTALLEDDATE %>";
    //XSSOK
    var STR_REQUIRED_ORIGINALNAME                  = "<%= STR_REQUIRED_ORIGINALNAME %>";

</script>
