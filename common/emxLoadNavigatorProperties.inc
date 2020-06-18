<%--  emxLoadNavigatorProperties.inc

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLoadNavigatorProperties.inc.rca 1.14 Wed Oct 22 15:48:00 2008 przemek Experimental przemek $
--%>

<% 
try{
	
    if ( !(ContextUtil.isTransactionActive(context)) )
    {
        ContextUtil.startTransaction(context, false);
	}
	
    if (session.getAttribute("emxRoleList") == null)
    {
      	UICache.loadUserRoles(context, session);
    }

	// HashMap directorySuiteMap = (HashMap)application.getAttribute("emxDirectorySuiteMap");

	// Load the App server specific cache if not loaded.
	CacheManager.loadAPPServerCache(context, directorySuiteMap);
        
} catch (Exception ex) {

	ContextUtil.abortTransaction(context);
  
	String emxExceptionString = (ex.toString()).trim();
	// set the error string in the Error object
	if ( (emxExceptionString != null) && (emxExceptionString.trim().length() > 0) )
	{
  		emxNavErrorObject.addMessage(emxExceptionString);
  	}
  	 
} finally {

	ContextUtil.commitTransaction(context);
}

%>
