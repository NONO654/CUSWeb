<%--
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@include file = "../emxI18NMethods.inc"%>
<%@include file = "../emxRequestWrapperMethods.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%@ page import = "com.matrixone.apps.domain.util.*,java.text.*,com.matrixone.apps.framework.ui.*" %>

<emxUtil:localize id="i18nId" bundle="emxFrameworkStringResource" locale='<%= request.getHeader("Accept-Language") %>' />

<%
	String lStr = request.getHeader("Accept-Language");
    String fromPageHistoryProcessPage = (String)request.getAttribute("fromPageHistoryProcessPage");
    String langStr = i18nStringNow("emxFramework.HelpDirectory", lStr);
    String langOnlineStr = i18nStringNow("emxFramework.OnlineXML.HelpDirectory", lStr);
    
    matrix.db.Context context = Framework.getFrameContext(session);
    
    
    if(context == null || (context != null && "".equals(context.getUser()))){
        String loginPage = getServletConfig().getServletContext().getInitParameter("ematrix.login.page");
        String pagePath = getServletConfig().getServletContext().getInitParameter("ematrix.page.path");
        if (loginPage == null || loginPage.length() == 0)
        {
            loginPage = "/emxLogin.jsp";
        }
        loginPage = pagePath+loginPage;
        //JPA+
        String sPreferred = emxGetParameter(request,"preferred");
        boolean bPreferred = (sPreferred!=null);
        String sTenantId = emxGetParameter(request,"tenant");
        
		if(UIUtil.isNullOrEmpty(sTenantId) && context != null) {
        	sTenantId = context.getTenant();
        	System.out.println(">>>>>>>>>>sTenantId:"+sTenantId);
        }
		
		if (bPreferred) {
            loginPage = loginPage + "?preferred="+XSSUtil.encodeForURL(context, sPreferred);
        }
        
		if (sTenantId != null) {
		    if (bPreferred) {
                loginPage = loginPage + "&tenant=" + XSSUtil.encodeForURL(context, sTenantId);
            }else{
				loginPage = loginPage + "?tenant=" + XSSUtil.encodeForURL(context, sTenantId);
            }
        }
        //JPA-
        
        //Start Fix for IR-033113V6R2011
        MatrixServletException servletException = Framework.getError(request);
        if (servletException != null) 
        {
             session.setAttribute("error.message", servletException.getMessage());
        }
        //End Fix for IR-033113V6R2011
        
        /*if condition added for IR-025019V6R2011*/
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
        <script language="javascript" src="<%=Framework.getClientSideURL(response, "common/scripts/emxUICore.js")%>"></script>
        <script language="javascript">
		  var sessionError = "Error|:Session|:TimeOut";
          getTopWindow().document.location.href = "<%=loginPage%>";
        </script>
        <%
        }
        
        return;
    }

    if(langStr == null || "".equals(langStr))
    {
        langStr = "en";
    }
    
    String sUserDefinedLanguages = EnoviaResourceBundle.getProperty(context, "emxFramework.UserDefined.Language");
    StringList sUserDefLanguages = FrameworkUtil.split(sUserDefinedLanguages, "|");
    String sBrowserLang = request.getHeader("Accept-Language");
	sBrowserLang = UIUtil.getLanguage(sBrowserLang);
    for(int i = 0; i < sUserDefLanguages.size(); i++) {
    	String strLanguage = (String)sUserDefLanguages.get(i);
    	if(strLanguage.equalsIgnoreCase(sBrowserLang)) {
    		langOnlineStr = "English";
    		break;
    	}
    }
    
   //To display Application property Key as ENOVIA

    String sAppName = EnoviaResourceBundle.getProperty(context, "emxFramework.Application.Name");

   //To display Application Login Image

    String sLoginImage = EnoviaResourceBundle.getProperty(context, "emxFramework.Application.LoginImage");

   //To display Password Login Image

    String sPasswordImage = EnoviaResourceBundle.getProperty(context, "emxFramework.Application.PasswordImage");

   //To display HomeSplashBGD 

    String sHomeSplashBGD = EnoviaResourceBundle.getProperty(context, "emxFramework.Application.HomeSplashBGD");

   //To display Header Logo

    String sHeaderLogo = EnoviaResourceBundle.getProperty(context, "emxFramework.Application.HeaderLogo");

    // Check if external authentication is turned on
    String sExternalAuth = EnoviaResourceBundle.getProperty(context, "emxFramework.External.Authentication");
    if (sExternalAuth == null || sExternalAuth.length() == 0)
    {
        sExternalAuth = "false";
    }
    if ("TRUE".equalsIgnoreCase(sExternalAuth))
    {
        // If Authentication JPO not compiled then compile it.
        Boolean bIsAuthenticationJPOCompiled = (Boolean)application.getAttribute("bIsAuthenticationJPOCompiled");
        if (bIsAuthenticationJPOCompiled == null || !bIsAuthenticationJPOCompiled.booleanValue())
        {
            try
            {
            	// get()/run in Anonymous context as context doesn't exists at this point.
            	ContextUtil.runInAnonymousContext(new ContextUtil.Callable() {
					public Object call(Context context) {
						try {
							// get MX_PAM_AUTHENTICATE_CLASS setting
			                String sMxPamSetting = PropertyUtil.getEnvironmentProperty(context, "MX_PAM_AUTHENTICATE_CLASS");
	
			                // get JPO name
			                sMxPamSetting = sMxPamSetting.replace('{', '<');
			                sMxPamSetting = sMxPamSetting.replace('}', '>');
			                MessageFormat mf = new MessageFormat("$<CLASS:{0}>");
			                Object obj[] = mf.parse(sMxPamSetting);
			                String sJPOName = (String)obj[0];
	
			                // compile program
			                StringList JPOs = new StringList();
			                JPOs.addElement(sJPOName);
			                ProgramUtil.compile(context, JPOs, false);
						} catch (Exception ex) {
							System.err.println("Error: emxNavigatorBaseInclude.inc, Unable to compile MX_PAM_AUTHENTICATE_CLASS configured JPOs!");
						}
		                return null;
					}});
            }
            catch (Exception ex)
            {
                // do nothing
            }

            application.setAttribute("bIsAuthenticationJPOCompiled", Boolean.valueOf(true));
        }
    }

    if (!Framework.isLoggedIn(request))
    {
        String loginPage = null;
        if ("TRUE".equalsIgnoreCase(sExternalAuth))
        {
        	final String strUsr = request.getRemoteUser();
            String sDBUser = (String) ContextUtil.runInAnonymousContext(new ContextUtil.Callable() {
				public Object call(Context context) throws MatrixException {
					return MqlUtil.mqlCommand(context, "list person $1" , strUsr);
				}});
            if (sDBUser == null || !(sDBUser.equals(request.getRemoteUser()))) {
                loginPage = EnoviaResourceBundle.getProperty(context, "emxFramework.ExternalAuthetication.MatrixUserNotFound.TargetJSP");
            }
        }

        if (loginPage == null || loginPage.length() == 0)
        {
            // loginPage = Framework.getPagePathURL("") + EnoviaResourceBundle.getProperty(context, "emxLogin.LoginPage");
            loginPage = Framework.getClientSideURL(response, EnoviaResourceBundle.getProperty(context, "emxLogin.LoginPage"));

            if (loginPage == null || loginPage.length() == 0)
            {
                loginPage = "/emxLogin.jsp";
            }
        }

        // Incase of login failure, the error message needs to be available in session for login page
        MatrixServletException servletException = Framework.getError(request);
        if (servletException != null) {
            session.setAttribute("error.message", servletException.getMessage());
        }

%>
<script language="javascript">
if (emxUIConstants.CHECK_NEW_TAB_TIME && emxUIConstants.CHECK_NEW_TAB_TIME >= 0) {
    window.open("<%=loginPage%>");
    window.open("about:blank", '_self', '');
    window.close();

} else {
  document.location.href = "<%=loginPage%>";
}
</script>
<%
        return;
        //Framework.serverSideRedirect(loginPage, request,response);
    } else {

        // In case of external authentication
        if ("TRUE".equalsIgnoreCase(sExternalAuth))
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
                String sRedirectMessage = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SSO.NoSession" , request.getLocale());
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
                        if (getTopWindow().childWindows[i] && !getTopWindow().childWindows[i].closed) {
                                getTopWindow().childWindows[i].close();
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

<%!
    // Call this method to internationalize variables in java.
  @Deprecated
    static public String i18nStringNow(String text, String languageStr) throws MatrixException
    {
        com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();

        String returnString = text;
        try{
            String I18NreturnString = (String) loc.GetString("emxFrameworkStringResource", languageStr, text);
            if ((!"".equals(I18NreturnString)) && (I18NreturnString != null)){
                returnString = I18NreturnString;
            }

        } catch(Exception e) {

        // String must not have been in Property File or another Exception
        // Return the string id.
        }
        return returnString;
    }
%>
