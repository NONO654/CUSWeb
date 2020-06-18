<%--  emxComponentsDesignTopInclude.inc   -  Top Level Include File for Components Suite

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsDesignTopInclude.inc.rca 1.9 Tue Oct 28 23:01:05 2008 przemek Experimental przemek $
--%>
<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.io.*,
                   java.util.*,
                   java.text.*" errorPage="emxComponentsError.jsp"%>

<%@ page import =  "com.matrixone.apps.common.BuyerDesk,
                    com.matrixone.apps.common.BusinessUnit,
                    com.matrixone.apps.common.Company,
                    com.matrixone.apps.common.CertificationHolder,
                    com.matrixone.apps.common.Document,
                    com.matrixone.apps.common.DocumentHolder,
                    com.matrixone.apps.common.VCDocument,
                    com.matrixone.apps.common.FileFormatHolder,
                    com.matrixone.apps.common.InboxTask,
                    com.matrixone.apps.common.Location,
                    com.matrixone.apps.common.MarkupHolder,
                    com.matrixone.apps.common.Message,
                    com.matrixone.apps.common.MessageHolder,
                    com.matrixone.apps.common.MultipleOwner,
                    com.matrixone.apps.common.Organization,
                    com.matrixone.apps.common.OrganizationList,
                    com.matrixone.apps.common.Part,
                    com.matrixone.apps.common.Person,
                    com.matrixone.apps.common.PurchaseClassHolder,
                    com.matrixone.apps.common.Route,
                    com.matrixone.apps.common.RouteHolder,
                    com.matrixone.apps.common.RouteTemplate,
                    com.matrixone.apps.common.SketchHolder,
                    com.matrixone.apps.common.Subscribable,
                    com.matrixone.apps.common.SubscriptionManager,
                    com.matrixone.apps.common.VaultHolder,
                    com.matrixone.apps.common.Workspace,
                    com.matrixone.apps.common.WorkspaceVault,
                    com.matrixone.apps.common.Region" %>

<%@ page import = "com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>


<%@include file = "../emxI18NMethods.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>

<%!
  static String appDirectory = null;

  private static final String DateFrm = (new Integer(java.text.DateFormat.MEDIUM)).toString();

%>

<%//Start Internationalization%>
<%@include file = "../emxTagLibInclude.inc"%>
<!-- //XSSOK -->
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= request.getHeader("Accept-Language") %>'/>

<%!
  // Call this method to internationalize variables in java.
  // i18nStringNowUtil("key", resourceBundle, request.getHeader("Accept-Language"));
    /** 
     * @deprecated V6R2013.
     */
  @Deprecated
  static public String i18nStringNowUtil(String text,String Bundle, String languageStr) {
    i18nNow loc = new i18nNow();
    return (String)loc.GetString(Bundle, languageStr, text);
  }
%>
<%!
  // Call this method to internationalize variables in java.
  // i18nStringNow("stringid", request.getHeader("Accept-Language"));
    /** 
     * @deprecated V6R2013.
     */
  @Deprecated
  static public String i18nStringNow(String text, String languageStr)
  {
    i18nNow loc = new i18nNow();
    return (String) loc.GetString("emxComponentsStringResource", languageStr, text);
  }
%>
<%//End Internationalization%>




<%

  // init. Variables
  matrix.db.Context context = null;
  String eMatrixPropertiesName = null;
  Properties eMatrixProperties = null;

  /** Person Admin Person */
  String personAdminType = "person";

  /** name of preference properties */
  String PREFERENCE_ENC_DEFAULT_VAULT = "preference_ENCDefaultVault";

  // Default Responsibility OID and Name fields
  String defaultRDOId="";
  String defaultRDOName="";
  String defaultVault="";
  String vaultAwarenessString = "";

  context = Framework.getFrameContext(session);
  if (appDirectory == null){
      appDirectory = (String)FrameworkProperties.getProperty(context,"eServiceSuiteComponents.Directory");
  }

  String emxTopIncDirName = Framework.getPagePathURL("");
  String useProxy = Framework.getPropertyValue("ematrix.proxy.server");
  if (useProxy != null && !useProxy.equalsIgnoreCase("null")) {
    emxTopIncDirName = useProxy + emxTopIncDirName;
  }

  if (!Framework.isLoggedIn(request)) {
    //String emxTopIncLoginURL = emxTopIncDirName + "emxLogin.jsp";
    //String loginPage = Framework.getPropertyValue("ematrix.login.page");
    String loginPage = emxTopIncDirName + "emxLogin.jsp";

    String reqURI = request.getRequestURI();
    if (reqURI.indexOf('/') > -1){
      reqURI = reqURI.substring(reqURI.lastIndexOf('/')+1,reqURI.length());
    }
    String pageURL = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(reqURI + "?" + request.getQueryString());
    String hostSite = emxGetParameter(request,"hostSite");
    String cancelPageURL = emxGetParameter(request,"cancelPageURL");

    String fileSite = emxGetParameter(request,"fileSite");
    String sPassedSuiteDir = emxGetParameter(request,"passSuitedir");
    if ( (sPassedSuiteDir != null) && (!sPassedSuiteDir.equals("") ) ) {
      session.setAttribute("passesSuitedir",sPassedSuiteDir);
    }

    if (( hostSite != null ) && ( fileSite != null ) && ( !"".equals(fileSite) )) {
      session.setAttribute("hostSite", hostSite);
      pageURL = Framework.getPagePathURL("components") + "/" + pageURL;
      String FCSLoginPage =  Framework.getPropertyValue("ematrix.fcslogin.page");
      loginPage = FCSLoginPage;
      request.setAttribute("pageURL",pageURL);
      request.setAttribute("cancelPageURL",cancelPageURL);
    }

    String fcsTimeZone = emxGetParameter(request, "fcsTimeZone");
    if ( fcsTimeZone != null ) {
      session.setAttribute("timeZone", fcsTimeZone);
    }
    context.shutdown();
    
     %>
    <jsp:forward page="<%=loginPage%>" />
    <%
    return;
  } else{
    // User is Logged in

    // set caching values
    response.setHeader("Cache-Control","no-store"); //HTTP 1.1
    response.setHeader("Pragma","no-cache"); //HTTP 1.0
    response.setDateHeader("Expires", 0); //prevents caching at the proxy server


    if (context != null){
      //setPageContext(context);

      //get Directory from App. Properties Object
      eMatrixPropertiesName = (String)session.getAttribute("eMatrixPropertiesName");
      String suiteDir ="";
      if(eMatrixPropertiesName != null) {
        suiteDir = FrameworkProperties.getProperty(context,"eServiceSuiteComponents.Directory"); //suite directory name being picked up from properties file
      } else {
        suiteDir = (String)session.getAttribute("passesSuitedir");
      }
    }
    // Get VaultAwareness Property & put it in a session
    vaultAwarenessString = (String)session.getAttribute("vaultawareness");
    if(vaultAwarenessString == null || "null".equals(vaultAwarenessString) || "".equals(vaultAwarenessString)){
      vaultAwarenessString = (String)JSPUtil.getCentralProperty(application, session, "eServiceSuiteComponents", "VaultAwareness");
      if(vaultAwarenessString == null)
      {
        vaultAwarenessString = "false";
      }
      session.setAttribute("vaultawareness",vaultAwarenessString);
    }

    //get the default Vault value from the session
    defaultVault = (String)session.getAttribute("ENCDefaultVault");

    if(defaultVault == null || "null".equals(defaultVault) || "".equals(defaultVault)){
      //get the default Vault value from the current user
      try
      {
         defaultVault  = PropertyUtil.getAdminProperty(context, personAdminType, context.getUser(), PREFERENCE_ENC_DEFAULT_VAULT);
         if(defaultVault == null || "null".equals(defaultVault) || "".equals(defaultVault) )  {
            if(vaultAwarenessString.equalsIgnoreCase("true")){
              // Get Person's Company Vault
              Person vaultAwarePerson = (Person)DomainObject.newInstance(context,DomainConstants.TYPE_PERSON);
              vaultAwarePerson.setToContext(context);
              defaultVault = vaultAwarePerson.getVaultName(context);
            } else if (vaultAwarenessString.equalsIgnoreCase("false")){
              // Get Person Vault
              BusinessObject boPerson = JSPUtil.getPerson(context, session);
              boPerson.open(context);
              defaultVault = boPerson.getVault();
              boPerson.close(context);
            }
         }
         session.setAttribute("ENCDefaultVault", defaultVault);
      }catch(Exception ex){
        throw ex;
      }
    }

  //get the default Responsible Design Organization TNR value from the session
  String sRdoTNR = (String)session.getAttribute("rdoTNR");
  if(sRdoTNR == null || "null".equalsIgnoreCase(sRdoTNR)){
    //get the default Responsible Design Organization TNR value from the current user
    try
    {
      sRdoTNR  = com.matrixone.apps.common.Person.getDesignResponsibility(context);
    }catch(Exception ex){
      throw ex;
    }
  }
  if(sRdoTNR != null && !"null".equals(sRdoTNR) && !"".equals(sRdoTNR)){
    //split the {T}{N}{R} value & get the objectId
    if(sRdoTNR.indexOf("}") > 0) {
      String sType = sRdoTNR.substring(1,sRdoTNR.indexOf("}"));
      sRdoTNR =sRdoTNR.substring(sRdoTNR.indexOf("}")+2);
      defaultRDOName = sRdoTNR.substring(0,sRdoTNR.indexOf("}"));
      String strRev = sRdoTNR.substring(sRdoTNR.indexOf("{")+1,sRdoTNR.length()-1);
	  // Added for bug 357025 to validate whether that Business Unit exists or not.
      if("true".equalsIgnoreCase(MqlUtil.mqlCommand(context,"print bus '" +sType+ "' '" +defaultRDOName+ "' '" +strRev+ "' select exists dump |")))
      {
	      try{
	        defaultRDOId = ComponentsUtil.getBusIdForTNR(context,sType,defaultRDOName,sRdoTNR.substring(sRdoTNR.indexOf("{")+1,sRdoTNR.length()-1));
	      }catch(Exception Ex){
	        throw Ex;
	     }
	  }
	  else
	      defaultRDOName = "";
    }
  }


  }

// long startTime = System.currentTimeMillis();
%>

<%!
  //
  // check for URL appended values if not found, then look in Request Headers and return the string
  //
   static public String emxGetParameter(HttpServletRequest request, String parameter) throws Exception
  {
    return (Request.getParameter(request, parameter));
  }
%>


<%!
  //
  // check for URL appended values if not found, then look in Request Headers and return the string
  //
   static public String[] emxGetParameterValues(HttpServletRequest request, String parameter)
  {
    return (Request.getParameterValues(request, parameter));
   }
%>
<%!
  //
  // return the list of parameter names
  //
  static Enumeration emxGetParameterNames(HttpServletRequest req)
  {
    Enumeration enumParam = req.getParameterNames();
    return (enumParam);
  }
%>
