<%--  emxDesignTopInclude.inc   -  Top Level Include File for Engineering Central Suite
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.io.*,
                   java.net.URLEncoder,
                   java.util.*,
                   java.text.*" errorPage="../common/eServiceError.jsp"%>

<%@ page import =  "com.matrixone.apps.common.BusinessUnit,
                    com.matrixone.apps.common.Company,
                    com.matrixone.apps.common.CertificationHolder,
                    com.matrixone.apps.common.Document,
                    com.matrixone.apps.common.DocumentHolder,
                    com.matrixone.apps.common.FileFormatHolder,
                    com.matrixone.apps.common.InboxTask,
                    com.matrixone.apps.common.Location,
                    com.matrixone.apps.common.MarkupHolder,
                    com.matrixone.apps.common.Message,
                    com.matrixone.apps.common.MessageHolder,
                    com.matrixone.apps.common.MultipleOwner,
                    com.matrixone.apps.common.Organization,
                    com.matrixone.apps.common.OrganizationList,
                    com.matrixone.apps.common.Person,
                    com.matrixone.apps.common.Route,
                    com.matrixone.apps.common.RouteHolder,
                    com.matrixone.apps.common.RouteTemplate,
                    com.matrixone.apps.common.Subscribable,
                    com.matrixone.apps.common.SubscriptionManager,
                    com.matrixone.apps.common.VaultHolder,
                    com.matrixone.apps.common.Workspace,
                    com.matrixone.apps.common.WorkspaceVault" %>

<%@ page import = "com.matrixone.apps.engineering.Part,
                   com.matrixone.apps.engineering.*,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%@include file = "../emxRequestWrapperMethods.inc"%>

<%@include file = "../emxTagLibInclude.inc"%>


<%//Start Button Servlet%>
<%!

  static String appDirectory = null;

%>



<%//End Button Servlet%>

<%//Start Internationalization%>
<%-- XSSOK --%>
<emxUtil:localize id="i18nId" bundle="emxEngineeringCentralStringResource" locale='<%= request.getHeader("Accept-Language") %>'/>

<%!
matrix.db.Context ctx = null;

  // Call this method to internationalize variables in java.
  // i18nStringNowUtil("key", resourceBundle, request.getHeader("Accept-Language"));
   public String i18nStringNowUtil(String text,String Bundle, String languageStr) throws Exception {
    //return i18nNow.getI18nString(text,Bundle,languageStr);    
      return EnoviaResourceBundle.getProperty(ctx, Bundle,ctx.getLocale(),text);
  }
%>
<%!
  // Call this method to internationalize variables in java.
  // i18nStringNow("stringid", request.getHeader("Accept-Language"));
   public String i18nStringNow(String text, String languageStr) throws Exception
  {
    //return i18nNow.getI18nString(text,"emxEngineeringCentralStringResource",languageStr);
	  return EnoviaResourceBundle.getProperty(ctx,"emxEngineeringCentralStringResource",ctx.getLocale(),text);
  }
%>
<%//End Internationalization%>




<%

  // init. Variables
  matrix.db.Context context = null;

  /** Person Admin Person */
  final String personAdminType = "person";

  /** name of preference properties */
  String PREFERENCE_ENC_DEFAULT_VAULT = "preference_ENCDefaultVault";

  // Default Responsibility OID and Name fields
  String defaultRDOId="";
  String defaultRDOName="";
  String defaultVault="";
  String vaultAwarenessString = "";

  Locale locale = request.getLocale();
      session.setAttribute("locale",locale);
      context = Framework.getFrameContext(session);
      ctx=context;
  if (!Framework.isLoggedIn(request)) {

    String emxTopIncDirName = Framework.getPagePathURL("");
    String useProxy = Framework.getPropertyValue("ematrix.proxy.server");
    if (useProxy != null && !useProxy.equalsIgnoreCase("null")) {
       emxTopIncDirName = useProxy + emxTopIncDirName;
    }

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
      pageURL = Framework.getPagePathURL("engineeringcentral") + "/" + pageURL;
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
    <jsp:forward page="<%=loginPage%>" />
    <%
    return;
  } else{
    // User is Logged in

    // set caching values
    response.setHeader("Cache-Control","no-store"); //HTTP 1.1
    response.setHeader("Pragma","no-cache"); //HTTP 1.0
    response.setDateHeader("Expires", 0); //prevents caching at the proxy server
    

    // Get VaultAwareness Property & put it in a session
    vaultAwarenessString = (String)session.getAttribute("vaultawareness");
    if(vaultAwarenessString == null || "null".equals(vaultAwarenessString) || "".equals(vaultAwarenessString)){
      vaultAwarenessString = (String)JSPUtil.getCentralProperty(application, session, "eServiceEngineeringCentral", "VaultAwareness");
      session.setAttribute("vaultawareness",vaultAwarenessString);
    }

      //get the default Vault value from the current user
              // Get Person's Company Vault
              Person vaultAwarePerson = (Person)DomainObject.newInstance(context,DomainConstants.TYPE_PERSON);
              vaultAwarePerson.setToContext(context);
              defaultVault = vaultAwarePerson.getVaultName(context);

  //get the default Responsible Design Organization TNR value from the session
  String sRdoTNR = (String)session.getAttribute("rdoTNR"); 
  
  //Added for RDO Convergence Start	  
	  	defaultRDOName = EngineeringUtil.getDefaultOrganization(context);  	  	          		    				      	  	
	    try {	            
	         defaultRDOId = MqlUtil.mqlCommand(context, "temp query bus $1 $2 $3 select $4 dump $5",DomainConstants.TYPE_ORGANIZATION,defaultRDOName,"*","id","|");	         
	         defaultRDOId = defaultRDOId.substring(defaultRDOId.lastIndexOf("|")+1);	               
	    } catch(Exception Ex){        	 
	         sRdoTNR = "";
	         defaultRDOId = "";
	         defaultRDOName = "";
	    }    		  	
//Added for RDO Convergence End

  }

  if (appDirectory == null){
      appDirectory = (String)FrameworkProperties.getProperty(context,"eServiceSuiteEngineeringCentral.Directory");
  }

%>
