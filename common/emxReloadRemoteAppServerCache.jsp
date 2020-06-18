<%--  emxReloadRemoteAppServerCache.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxReloadRemoteAppServerCache.jsp.rca 1.5 Wed Oct 22 15:48:59 2008 przemek Experimental przemek $
--%>

<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*, java.util.*, java.io.*"%>

<html>
<head>   
</head>
<%
Context context = null;
boolean isContextPushed = false;
boolean must_shutdown_context = false;
String tenant = "";

DebugUtil.debug("emxReloadRemoteAppServerCache: Remote app server reset starting");
try
{

    context = Framework.getFrameContext(session);
    String adminProperty = request.getHeader("AdminProperty");
    String personCache = request.getHeader("PersonCache");
    tenant = request.getParameter("tenant");

    if (context == null || !context.isInitialized())
    {
        
        context = ContextUtil.getAnonymousContext();
	must_shutdown_context = true;

        DebugUtil.debug("using anonymous context.."); 
        ContextUtil.startTransaction(context, false);
        
        if(personCache!=null && !"".equals(personCache) && !"null".equals(personCache)){
            PersonUtil.clearUserCacheProperty(context, personCache, null);
        }
        else if(adminProperty == null || "".equals(adminProperty))
        {        
	        //need to push and pop context for resetAPPServerCache to work
	        //when some JPO is recompiled.
	        if (!"".equals(tenant)) {
	            String userAgent = PropertyUtil.getSchemaProperty(context, "person_UserAgent");
	            ContextUtil.pushContext(context, userAgent + "@@" + tenant, null, null);
	        } else {
	            ContextUtil.pushContext(context);
	        }
	        
	        //context has been pushed
	        isContextPushed = true;
	
	        // reset the cache in APP server
	        CacheManager.resetAPPServerCache(context);
	        
	        String[] rmiServerList = CacheManager.getRMIServerList(context);
	        if(rmiServerList == null || rmiServerList.length == 0)
	        {
	            // reset the cache in RMI servers specified in the emxReloadCacheServerInfo JPO
	            CacheManager.resetRMIServerCache(context);         
	        }        
        }else
        {
            CacheManager.updateAPPServerAdminCache(context,adminProperty);
        }

        ContextUtil.commitTransaction(context);         
    }
}
catch (Exception ex)
{
    DebugUtil.debug("emxReloadRemoteAppServerCache : " + ex.toString());
    response.setStatus(response.SC_ACCEPTED);    
    ContextUtil.abortTransaction(context);
}
finally
{
    //pop context only if it was pushed
    if(isContextPushed && "".equals(tenant))
    {
        ContextUtil.popContext(context);
    }
    if(must_shutdown_context)
        context.shutdown();
}
%>
<body>
</body>
</html>

