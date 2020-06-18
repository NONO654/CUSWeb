<%--  emxReloadCache.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxReloadCache.jsp.rca 1.23 Wed Oct 22 15:49:03 2008 przemek Experimental przemek $
--%>

<html>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<head> 
</head>
<%
String accessUsers = "role_AdministrationManager,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}


try
{                                                              
	ContextUtil.startTransaction(context, false);

	//clear the Admin property cache
	PropertyUtil.clearAdminPropertyCache();
	
	// Update the current user roles in session variable
	UICache.loadUserRoles(context, session);		        
    
	//clear the tenant properties cache
	UICache.clearTenantCache(context);
	
    // reset the cache in the remote APP servers (incl. RMI gateway), if configured
    StringList errAppSeverList = CacheManager.resetRemoteAPPServerCache(context, pageContext);     
    
	// reset the cache in RMI servers specified in the emxReloadCacheServerInfo JPO
	CacheManager.resetRMIServerCache(context);    	
    
    StringBuffer sCacheResetMsg = new StringBuffer();
    if(errAppSeverList != null && errAppSeverList.size() > 0)    
    {
        sCacheResetMsg.append(i18nNow.getI18nString("emxNavigator.UIMenu.ResetRemoteCacheFailedMessage", "emxFrameworkStringResource",request.getHeader("Accept-Language")));
        for(int i=0; i < errAppSeverList.size(); i++)
        {
            if(i > 0)
            {
                sCacheResetMsg.append(",");   
            }
            
            sCacheResetMsg.append(" ");
            sCacheResetMsg.append(errAppSeverList.get(i));
        }              
        
    }
    else
    {
        sCacheResetMsg.append(i18nNow.getI18nString("emxNavigator.UIMenu.ResetCacheMessage", "emxFrameworkStringResource", request.getHeader("Accept-Language")));    	    
    }
    
    emxNavErrorObject.addMessage(sCacheResetMsg.toString());
	
	ContextUtil.commitTransaction(context);

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
    {
        emxNavErrorObject.addMessage(ex.toString().trim());
    }
} 
 
%>
<body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

