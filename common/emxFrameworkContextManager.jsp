<%--  emxFrameworkContextManager.jsp - Establish context and forward request.

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@include file = "../emxRequestWrapperMethods.inc"%>

<%!
    //static variables.
    String SECURITY_CONTEXT = "SecurityContext";  //passed from 6W Foundation as part of every URL.
    String SECURITY_CONTEXT_PATH = "/e6wcontext/";  //defined by ContextResolver class.
%>

<%
    Framework.isLoggedIn(request);
    Context context = Framework.getFrameContext(session);
    if (context != null) {
        session.setAttribute("emxSessionExist", Boolean.valueOf(true));  //required for downstream BPS code.
        session.setAttribute("timeZone", "0");  //required for SB.

    String forwardUrl = emxGetParameter(request, "forwardUrl");
    String fromIFWE = emxGetParameter(request, "fromIFWE");
	if(fromIFWE == null || fromIFWE.isEmpty()) {
        fromIFWE = "true";
	}
	if(forwardUrl == null || forwardUrl.isEmpty()) {
            forwardUrl = "/common/emxNavigator.jsp?fromIFWE=" + XSSUtil.encodeForURL(context,fromIFWE);
	} else {
		forwardUrl = java.net.URLDecoder.decode(forwardUrl);
	}

        //if SC is passed, it means we need to manage it as widget-specific.
        String securityContext = emxGetParameter(request, SECURITY_CONTEXT);
        if (securityContext != null && "true".equals(request.getParameter("SCMode"))) {
            //pass SC context as part of the URL.
            forwardUrl = SECURITY_CONTEXT_PATH + XSSUtil.encodeForURL(context,securityContext) + forwardUrl;
        } else if (securityContext != null) {
            PersonUtil.setSecurityContext(session, securityContext);
            PersonUtil.setDefaultSecurityContext(context, securityContext);
        } else if (context.getRole() == null || context.getRole().length() == 0) {
			session.setAttribute("ForwardURL", forwardUrl);
			forwardUrl = "../common/emxSecurityContextSelection.jsp?fromIFWE=" + XSSUtil.encodeForURL(context,fromIFWE);
        }

        if(forwardUrl.startsWith("/")) {
            forwardUrl = ".." + forwardUrl;
        }

        String queryString = "";
        Enumeration en = request.getParameterNames();
        while (en.hasMoreElements()) {
            String paramName = (String) en.nextElement();
            if (!"forwardUrl".equals(paramName) && !SECURITY_CONTEXT.equals(paramName) && !"SCMode".equals(paramName)) {
                queryString += "&" + XSSUtil.encodeForURL(context,paramName) + "=" + XSSUtil.encodeForURL(context,request.getParameter(paramName));
            }
        }
        if (!"".equals(queryString)) {
            if (forwardUrl.indexOf("?") == -1) {
                forwardUrl += "?" + queryString.substring(1);
            } else {
                forwardUrl += queryString;
            }
        }
        out.clear();
%>
        <script>
            window.location.href="<%=forwardUrl%>";
        </script>
<%
    } else {
        //it should never reach here the way this JSP page is used.
        System.out.println("emxFrameworkContextManager - user is not logged in or system is not configured with DS Passport.");
        out.clear();
%>
        Unexpected error has occurred.  Please ensure you are logged in and refresh the widget or browser.
<%
    }
%>
