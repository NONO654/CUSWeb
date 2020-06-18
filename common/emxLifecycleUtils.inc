<%--
  $Archive: emxLifecycleUtils.jsp $
  $Revision: 1.14 $
  $Author: przemek $

  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
--%>

<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../emxI18NMethods.inc"%>
<%@include file = "../emxRequestWrapperMethods.inc"%>

<%@ page import="com.matrixone.apps.domain.*"%>
<%@ page import="com.matrixone.apps.domain.util.*"%>
<%@ page import = "matrix.db.*,matrix.util.*"%>						
<%@ page import = "java.util.*,java.io.*"%>						
<%@ page import = "com.matrixone.servlet.*"%>
<%@ page import = "com.matrixone.apps.framework.ui.*"%>
<! page import = "com.matrixone.framework.util.*" >
<! page import="com.matrixone.apps.teamcentral.i18n.*">

<%!

    static final String DateFrm = (new Integer(java.text.DateFormat.MEDIUM)).toString();
    static String appDirectory = null;
	static final String sInfoCentralSuite = "eServiceSuiteInfoCentral";

        private static synchronized void init(HttpSession session) 
                throws matrix.util.MatrixException, FrameworkException, Exception
        {
                if (appDirectory != null ) return;
                matrix.db.Context ctx = Framework.getFrameContext(session);
                try {
                      appDirectory = (String)EnoviaResourceBundle.getProperty(ctx,"eServiceSuiteFramework.Directory");
                 } finally {
                                 ctx.shutdown();
                 }
         }
%>

<%//Start Internationalization%>
<!-- //XSSOK -->
<emxUtil:localize id="i18nId" bundle="emxFrameworkStringResource" locale='<%= request.getHeader("Accept-Language") %>'/>

<%
        init(session);
    String lStr = request.getHeader("Accept-Language");
    String langStr = FrameworkUtil.i18nStringNow("emxFramework.HelpDirectory", lStr);
    if(langStr == null || "".equals(langStr))
        langStr = "en";
%>

<!page import="com.matrixone.apps.teamcentral.i18n.i18nNow" >
<%!
    // SnehalB: why do need to copy this method to a local file of our own. 
	// it's available as a common resource in file \EMATRIX\emxUICommonAppInclude.inc 

    // Call this method to internationalize variables in java.
    // i18nStringNowUtil("key", resourceBundle, request.getHeader("Accept-Language"));
    /** 
     * @deprecated V6R2013.
     */
  @Deprecated
    static public String i18nStringNowUtil( String text, String Bundle, String languageStr) throws Exception
    {

        return (String) i18nNow.getI18nString(text, Bundle, languageStr);
    }
%>

<%
    // init. Variables
    matrix.db.Context context = null;

    String emxTopIncDirName = Framework.getPagePathURL("");
    {
        String useProxy = Framework.getPropertyValue("ematrix.proxy.server");
        if (useProxy != null && !useProxy.equalsIgnoreCase("null")) {
           emxTopIncDirName = useProxy + emxTopIncDirName;
        }
    }

    if (!Framework.isLoggedIn(request)) {

        //String emxTopIncLoginURL = emxTopIncDirName + "emxLogin.jsp";
        //String loginPage = Framework.getPropertyValue("ematrix.login.page");
        String loginPage = emxTopIncDirName + "emxLogin.jsp";

        String reqURI = request.getRequestURI();
        if (reqURI.indexOf('/') > -1){
            reqURI = reqURI.substring(reqURI.lastIndexOf('/')+1,reqURI.length());
        }

        String pageURL = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(reqURI + "?" + emxGetQueryString(request));
        String hostSite = emxGetParameter(request,"hostSite");
        String cancelPageURL = emxGetParameter(request,"cancelPageURL");

        String fileSite = emxGetParameter(request,"fileSite");
        String sPassedSuiteDir = emxGetParameter(request,"passSuitedir");
        if ( (sPassedSuiteDir != null) && (!sPassedSuiteDir.equals("") ) ) {
          session.setAttribute("passesSuitedir",sPassedSuiteDir);
        }

        if (( hostSite != null ) && ( fileSite != null ) && ( !"".equals(fileSite) )) {
            session.setAttribute("hostSite", hostSite);
            pageURL = Framework.getPagePathURL("infocentral") + "/" + pageURL;
            String FCSLoginPage =  Framework.getPropertyValue("ematrix.fcslogin.page");
            loginPage = FCSLoginPage;
            request.setAttribute("pageURL",pageURL);
            request.setAttribute("cancelPageURL",cancelPageURL);
        }

        String fcsTimeZone = emxGetParameter(request, "fcsTimeZone");
        if ( fcsTimeZone != null ) {
            session.setAttribute("timeZone", fcsTimeZone);
        }
%>
<!-- //XSSOK -->
<jsp:forward page="<%=loginPage%>" />
<%
    return;
    } else{
        // User is Logged in

        // set caching values
        response.setHeader("Cache-Control","no-store"); //HTTP 1.1
        response.setHeader("Pragma","no-cache"); //HTTP 1.0
        response.setDateHeader("Expires", 0); //prevents caching at the proxy server

        context = Framework.getFrameContext(session);

        //set the Vault Awareness property
        String vaultAware = (String)session.getAttribute("vaultAware");
        if (vaultAware == null)
        {
            String vaString = (String)getInfoCentralProperty(application, session, "eServiceInfoCentral", "VaultAwareness");
            if (vaString != null)
            {
                 session.setAttribute("vaultAware", vaString);
                 if (vaString.equalsIgnoreCase("true"))
                 {
                      String companyVault = context.getVault().getName();  //get the vault
                      session.setAttribute("emxFramework.companyVault", companyVault);
                 }
            }
            else
            {
                 session.setAttribute("vaultAware", "false");
            }
        }
    }

%>


<%!
/*************************************************************************
* This method returns StringList of the infocentral properties requested
**************************************************************************/

    public static StringList getInfoCentralProperties(ServletContext servletcontext, 
        HttpSession httpsession, String strGroup, String strKey) throws matrix.util.MatrixException, Exception
	    // this is heavily used in ENODesignerCentral exclusively!
    {
        String strPropertyVal = getInfoCentralProperty(servletcontext, httpsession, strGroup, strKey);
        if(strPropertyVal == null || strPropertyVal.equals(""))
            return null;
        StringList stringlist = new StringList();
        
		String strToken;
        for( StringTokenizer stringtokenizer = new StringTokenizer(strPropertyVal, ",");
		    stringtokenizer.hasMoreTokens(); stringlist.addElement( strToken.trim()) )
        {
            strToken = stringtokenizer.nextToken();
            if(strToken == null)
                strToken = "";
        }
        return stringlist;
    }

/**********************************************************************
*  This method returns String of the infocentral property requested
***********************************************************************/

    public static String getInfoCentralProperty(ServletContext servletcontext, 
	    HttpSession httpsession, String strGroup, String strKey) throws matrix.util.MatrixException, Exception
	    // this is heavily used in ENODesignerCentral & in /sourcing/lifecycleProcess.jsp /common/emxPasswordPopup.jsp /common/emxPasswordPopupFS.jsp
    {
        String strPropFile = (String) servletcontext.getAttribute("eServiceSuiteInfoCentral.PropertyFileAlias");
        String strPropertyValue = null;

        matrix.db.Context lifeCycleUtilcontext = Framework.getFrameContext(httpsession);    
        try { 
        if(strPropFile == null || strPropFile.equals(""))
        {
            strPropertyValue = EnoviaResourceBundle.getProperty(lifeCycleUtilcontext,strGroup + "." + strKey);
        } else
        {
            Properties properties1 = (Properties)servletcontext.getAttribute(strPropFile);
            if(properties1 == null)
                return null;
            String strCompleteKey = "";
            if(strGroup == null || strGroup.equals(""))
            {
                if(strKey == null || strKey.equals(""))
                    strCompleteKey = "";
                else
                    strCompleteKey = strKey;
            } else
            if(strKey == null || strKey.equals(""))
                strCompleteKey = strGroup;
            else
                strCompleteKey = strGroup + "." + strKey;
            strPropertyValue = properties1.getProperty(strCompleteKey);
            if(strPropertyValue == null || strPropertyValue.equals(""))
            {
                strPropertyValue = EnoviaResourceBundle.getProperty(lifeCycleUtilcontext,strCompleteKey);
            }
        }
    } catch(Exception e) {}
    finally { lifeCycleUtilcontext.shutdown(); }
    if(strPropertyValue == null || strPropertyValue.equals(""))
            return null;
        else
            return strPropertyValue;
    }
%>

<%!
  //
  // Get the I18N Translated String for the given Policy Name
  //
  static public String getPolicyI18NString(String typeString, String languageStr) throws MatrixException
  {
    return i18nNow.getMXI18NString(typeString ,"",languageStr,"Policy");
  }
%>

<%!
  //
  // Get the I18N Translated String for the given Vault Name
  //
  static public String getVaultI18NString(String typeString, String languageStr) throws MatrixException
  {
    return i18nNow.getMXI18NString(typeString ,"",languageStr,"Vault");
  }
%>



<%!

//
  // Get the I18N Translated String for the given RelationshipName Value
  //
  static public String getRelationshipNameI18NString(String relationshipString, String languageStr) throws MatrixException
  {
    return i18nNow.getMXI18NString(relationshipString,"",languageStr,"Relationship");
  }
%>

<%!
  //
  // Get the I18N Translated String for the given Format Name
  //
  static public String getFormatI18NString(String formatString,String languageStr) throws MatrixException
  {
    return i18nNow.getMXI18NString(formatString,"",languageStr,"Format");
  }
%>

<%!
  // For enter-key press.
  // This variable is used in the text field on which if you hit the enter key the form will be submitted.
  // It will call the doSearch function. This is implemented only in search pages.

  public static final String sKeyPress = " onkeypress=\"javascript:if((event.keyCode == 13) || (event.keyCode == 10) || (event.which == 13) || (event.which == 10)) doSearch()\"";
%>

