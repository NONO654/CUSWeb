<%--  emxPortalBrowserCheck.inc

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPortalBrowserCheck.inc.rca 1.7 Wed Oct 22 15:48:49 2008 przemek Experimental przemek $
--%>

<%
/*
	String userAgent = request.getHeader("User-Agent");
	// Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0) - for I.E 6
	// Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.4) Gecko/20030624 Netscape/7.1 (ax) - for NS 7.1
	// Mozilla/4.78 [en] (Windows NT 5.0; U) - for NS4.78
*/
	if(!UINavigatorUtil.isBrowserDOM(context, request)) {
		String alternateURL = "";

		String alternateCMD = emxGetParameter(request, "alternateCmd");
		String portal = emxGetParameter(request, "portal");
		String objectId = emxGetParameter(request, "objectId");
		String suiteKey = emxGetParameter(request, "suiteKey");

		if(alternateCMD != null && !"null".equals(alternateCMD) && !"".equals(alternateCMD)) {
			alternateURL = UIPortal.getAlternateCommandHref(context, alternateCMD, UINavigatorUtil.getRequestParameterMap(request), suiteKey);
		} else {
			alternateURL = UIPortal.getFirstPortalTab(context, portal, UINavigatorUtil.getRequestParameterMap(request), PersonUtil.getAssignments(context), request.getHeader("Accept-Language"));
		}

		if(alternateURL == null || "null".equals(alternateURL) || "".equals(alternateURL)) {
			alternateURL = "emxPortalNotSupportedPage.jsp";
		}
                context.shutdown();
%>
<!-- //XSSOK -->
		<jsp:forward page ="<%=alternateURL%>" />
<%
	}
%>
