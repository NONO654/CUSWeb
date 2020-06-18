<%--  emxProgramCentralNavigatorBaseInclude.inc

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxNavigatorBaseInclude.inc.rca 1.13 Wed Oct 22 15:48:44 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../emxRequestWrapperMethods.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%@ page import = "com.matrixone.apps.domain.util.*,java.text.*" %>

<emxUtil:localize id="i18nId" bundle="emxFrameworkStringResource" locale='<%= request.getHeader("Accept-Language") %>' />

<%

    matrix.db.Context context = Framework.getFrameContext(session);
    /* Here we have to redirect to login page if context is null or we may get some context (may be core bug) even when use is not logged in, so, need to check the username before proceeding */
    if(context == null || (context != null && "".equals(context.getUser()))){
        String loginPage = getServletConfig().getServletContext().getInitParameter("ematrix.login.page");
        String pagePath = getServletConfig().getServletContext().getInitParameter("ematrix.page.path");
        if (loginPage == null || loginPage.length() == 0)
        {
            loginPage = "/emxLogin.jsp";
        }
        loginPage = pagePath+loginPage;
        
        //Start Fix for IR-033113V6R2011
        MatrixServletException servletException = Framework.getError(request);
        if (servletException != null) 
        {
             session.setAttribute("error.message", servletException.getMessage());
        }
        //End Fix for IR-033113V6R2011
        
        /*if condition added for IR-025019V6R2011*/
        String fromPageHistoryProcessPage = (String)request.getAttribute("fromPageHistoryProcessPage");
        if("TRUE".equals(fromPageHistoryProcessPage)){
        %>
            {            
                run:function(){
                    document.location.href = "<%=loginPage%>"; 
                } 
            }            
        <%
        }
        else{
        %>
        <script language="javascript">
          document.location.href = "<%=loginPage%>";
        </script>
        <%
        }
        
        return;
    }

    String lStr = request.getHeader("Accept-Language");
    String langStr = FrameworkUtil.i18nStringNow("emxFramework.HelpDirectory", lStr);
    if(langStr == null || "".equals(langStr))
    {
        langStr = "en";
    }
    final boolean sExternalAuth = com.matrixone.apps.domain.util.LoginUtil.checkExternalAuth(application, session, request);

    if (!Framework.isLoggedIn(request))
    {
        String loginPage = com.matrixone.apps.domain.util.LoginUtil.getLoginPage(request, response, context, sExternalAuth) ;

        // Incase of login failure, the error message needs to be available in session for login page
        MatrixServletException servletException = Framework.getError(request);
        if (servletException != null) {
            session.setAttribute("error.message", servletException.getMessage());
        }

%>
<script language="javascript">
  document.location.href = "<%=loginPage%>";
</script>
<%
        return;
        //Framework.serverSideRedirect(loginPage, request,response);
    } else {

        // In case of external authentication
        if (sExternalAuth)
        {
            // Check if session exists.
            Boolean bSessionExists = (Boolean)session.getAttribute("emxSessionExist");
            if (bSessionExists == null || !bSessionExists.booleanValue())
            {
                String loginPage = Framework.getClientSideURL(response, EnoviaResourceBundle.getProperty(context, "emxLogin.LoginPage"));

                if (loginPage == null || loginPage.length() == 0)
                {
                    loginPage = "/emxLogin.jsp";
                }

                // Incase of login failure, the error message needs to be available in session for login page
                MatrixServletException servletException = Framework.getError(request);
                if (servletException != null) {
                    session.setAttribute("error.message", servletException.getMessage());
                }
                String sRedirectMessage = EnoviaResourceBundle.getProperty(context, "Framework", "emxFramework.SSO.NoSession", request.getHeader("Accept-Language"));
                Boolean bNoSessionAlert = (Boolean)session.getAttribute("emxNoSessionAlert");
                if (bNoSessionAlert == null || !bNoSessionAlert.booleanValue())
                {
%>
<script language="javascript">
//! Public Function closeAllChildWindows()
//!     This function closes all registered child windows.
//!     This function is considered public and may be used
//!     by developers.
function closeAllChildWindows() {
        if (getTopWindow().childWindows){
                for (var i=0; i < getTopWindow().childWindows.length; i++) {
                        if (getTopWindow().childWindows[i] && !top.childWindows[i].closed) {
                                getTopWindow().childWindows[i].closeWindow();
                        }
                }
        }
}
  closeAllChildWindows();
  alert("<%=sRedirectMessage%>");
</script>
<%
                }
%>
<script language="javascript">
  if (getTopWindow().getWindowOpener() == null) {
      getTopWindow().document.location.href = "<%=loginPage%>";
  }
</script>
<%
                session.setAttribute("emxNoSessionAlert", Boolean.valueOf(true));
                return;

            }
        }

	}
%>
