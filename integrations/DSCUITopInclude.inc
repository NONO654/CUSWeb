<%--  DSCUITopInclude.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--  

  static const char RCSID[] = "$Id: /ENODesignerCentral/CNext/webroot/integrations/DSCUITopInclude.inc 1.3 Sat Apr 26 10:22:24 2008 GMT ds-mbalakrishnan Experimental$"

--%>

<%@ page import = "matrix.db.*, matrix.util.* ,com.matrixone.servlet.*, java.util.*, java.io.*" %>
<%@include file = "DSCContentTypeInclude.inc"%>
<%@include file = "DSCRequestWrapperMethods.inc"%>

<%!
  // rev and where clause patterns
  static private String wildStr = "*";
  static private String whereStr = "";
  static private String ROLE_LIST = "role.list";
%>

<%
  //check if user is logged in
  //create FCS Variables
  if (!Framework.isLoggedIn(request)) {
    String loginPage =  Framework.getPropertyValue("ematrix.login.page");
    String reqURI = request.getRequestURI();
    String pageURL = java.net.URLEncoder.encode(reqURI + "?" + request.getQueryString());
    String hostSite = emxGetParameter(request,"hostSite");
    String cancelPageURL = emxGetParameter(request,"cancelPageURL");

    String fileSite = emxGetParameter(request,"fileSite");
    if (( hostSite != null ) && ( fileSite != null ) && ( !"".equals(fileSite) )) {
      session.setAttribute("hostSite", hostSite);
      //pageURL = Framework.getPagePathURL("") + "/" + pageURL;
      loginPage =  Framework.getPropertyValue("ematrix.fcslogin.page");

      request.setAttribute("pageURL",pageURL);
      request.setAttribute("cancelPageURL",cancelPageURL);
    }
    %>
	
	<!--XSSOK-->
    <jsp:forward page ="<%=loginPage%>"/>
    <%
    return;
  }
%>

<%
  String acceptLanguage = request.getHeader("Accept-Language");
%>

<%!
    public static final String APPLICATIONPROPERTIES = "emxTestAppProperties";
    /**
     * return back the Image path
     * @param HttpServletContext -
     */
    public static String getImagePath(ServletContext aSContext)
    {
      String sImagePath = (String)(((Properties)aSContext.getAttribute(APPLICATIONPROPERTIES)).get("emxSupplierCentral.Images.Path"));
      if(sImagePath==null)
        return "";
      return sImagePath;
    }
%>

<%!
  //
  //Gets a list of available suites in the database
  //
  public static StringList getAbsUserSuites(HttpSession session) throws MatrixException {
    matrix.db.Context context = null; //Framework.getContext(session);
    StringList slSuites = null;
    try {
      context = Framework.getFrameContext(session);
      MQLCommand getSuiteNames = new MQLCommand();
      getSuiteNames.executeCommand(context,"execute program 'eServiceGetUserAbsSuites.tcl'");
      String sResults = getSuiteNames.getResult();
      if (sResults.substring(0,1).equals("1")) {
        String sError = sResults.substring(sResults.indexOf("|") + 1);
        throw new MatrixException(sError);
      }
      else if (sResults.substring(0,1).equals("0") && sResults.length() == 1) {
        return null;
      }
      else {
        StringTokenizer parser = new StringTokenizer(sResults.substring(2),"|");
        slSuites = new StringList();
        boolean isRegName = true;
        while (parser.hasMoreTokens()) {
          String sSuite = (String)parser.nextElement();
          if (isRegName) {
            slSuites.addElement(sSuite.trim());
            isRegName = false;
          }
          else isRegName = true;
        }
      }
    }
    catch (Exception e) {
      throw new MatrixException(e.toString());
    }
    return slSuites;
  }
%>

<%!
  //Framwork uses 'emxUIFrameworkStringResource'
  // Call this method to internationalize variables in java.
  // i18nStringNowUtil("key", resourceBundle, request.getHeader("Accept-Language"));
  static public String i18nStringNowUtil(String text,String Bundle, String languageStr) {
    com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();
    return (String)loc.GetString(Bundle, languageStr, text);
  }
%>
<%
  //String IMAGEPATH = getImagePath(application);
  //String IMAGEPATH = "images/";
  String IMAGEPATH = "";

  matrix.db.Context context = Framework.getFrameContext(session);

  //Debug info
  String UILevel3Debug =  (String)session.getAttribute("UILevel3Debug");
  boolean useDebug = false;
  if ("true".equalsIgnoreCase(UILevel3Debug)){
    useDebug = true;
  }

%>

<%!
  static String PERSON_OBJECT = "person.object";
  static String COMPANY_HASHTABLE = "company.hashtable";

%>
<%!
  //
  // return the person object of the logged in person
  //
  static public BusinessObject getPerson(matrix.db.Context context, HttpSession session, boolean expand) throws MatrixException
  {
    BusinessObject personObj = (BusinessObject)session.getAttribute(PERSON_OBJECT);
    if (personObj != null) {
      // return a copy of the actual person object
      return new BusinessObject(personObj);
    }

    //matrix.db.Context context = getPageContext();

    // query for the person object
    matrix.db.Query query = new matrix.db.Query();
    query.open(context);

    query.setBusinessObjectType(Framework.getPropertyValue(session, "type_Person"));
    query.setBusinessObjectName(context.getUser());
    query.setBusinessObjectRevision(wildStr);
    query.setOwnerPattern(wildStr);
    query.setVaultPattern(context.getVault().getName());
    query.setSearchText(whereStr);
    query.setWhereExpression(whereStr);
    query.setExpandType(expand);

    //evaluvate the query
    BusinessObjectItr resultSetItr = new BusinessObjectItr(query.evaluate(context));


    // return the person object
    if ( resultSetItr.next() ){
      query.close(context);
      session.setAttribute(PERSON_OBJECT, resultSetItr.obj());
      return resultSetItr.obj();
    } else {
      query.setBusinessObjectType(Framework.getPropertyValue(session, "type_Person"));
      query.setBusinessObjectName(context.getUser());
      query.setBusinessObjectRevision(wildStr);
      query.setOwnerPattern(wildStr);
      query.setVaultPattern(wildStr);
      query.setSearchText(whereStr);
      query.setWhereExpression(whereStr);
      query.setExpandType(expand);

      //evaluvate the query
      resultSetItr = new BusinessObjectItr(query.evaluate(context));
      query.close(context);

      // return the person object
      resultSetItr.next();
      session.setAttribute(PERSON_OBJECT, resultSetItr.obj());
      return resultSetItr.obj();
    }
  }
%>

<%!

  //
  // return the person object of the logged in person
  //
  static public BusinessObject getPerson(matrix.db.Context context, HttpSession session) throws MatrixException
  {
    return getPerson(context, session, false);
  }
%>

<%!
  //
  // Load roles into session
  //
  static public void loadRoles(matrix.db.Context context, HttpSession session) throws MatrixException
  {
    //matrix.db.Context context = getPageContext();

    if (session.getAttribute("ROLE_LIST") == null) {

      //get person obj from context and get assignments
      matrix.db.Person personObject = new matrix.db.Person((String)context.getUser());
      personObject.open(context);
      UserItr userItr = new UserItr(personObject.getAssignments(context));
      personObject.close(context);

      // load roles
      Hashtable rolelist = new Hashtable();
      while(userItr.next())
      {
        rolelist.put(userItr.obj().getName(), userItr.obj());
      }
      //put hashtable of users roles into session
      session.setAttribute("ROLE_LIST", rolelist);
    }
  }
%>

<%!
  //
  // returns true/false based on Person has the specific role or not
  //
  static public boolean hasRole(matrix.db.Context context, HttpSession session,
                                String roleName) throws MatrixException
  {
    //matrix.db.Context context = getPageContext();
    loadRoles(context, session);
    Hashtable roleList = (Hashtable)session.getAttribute("ROLE_LIST");
    return roleList.containsKey(roleName);
  }
%>

<%!
  //
  // return the current state for this object
  //
  static public State getCurrentState(matrix.db.Context context, HttpSession session,
                                      BusinessObject busObj) throws MatrixException
  {
    //matrix.db.Context context = getPageContext();

    // get the current state for this object
    StateItr stateItr = null;
    try {
      stateItr = new StateItr(busObj.getStates(context));
    }
    catch (MatrixException e)
    {
      busObj.open(context);
      stateItr = new StateItr(busObj.getStates(context));
      busObj.close(context);
    }
    finally {
      while(stateItr.next()){
        if (stateItr.obj().isCurrent()) {
          break;
        }
      }
      return stateItr.obj();
    }
  }
%>
