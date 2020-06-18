
<%--  emxProgramCentralCommonFSUtil.inc
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.   Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxProgramCentralCommonFSUtil.inc.rca 1.1.1.2.3.4 Wed Oct 22 15:49:25 2008 przemek Experimental przemek $
--%>

<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.domain.util.*"%>
<%@page import = "com.matrixone.apps.framework.ui.*"%>

<%!
  // This method returns the value of the application property
  public static String getApplicationProperty(ServletContext application,  String sKey){
    ResourceBundle appProps=ResourceBundle.getBundle("emxProgramCentral");
    String sRetVal = null;
    if (appProps != null) {
      try{
        sRetVal = appProps.getString(sKey);
      }
      catch(Exception e){
        sRetVal="";
      }
    }
    return sRetVal;
  }
%>


<%!
  // This method returns the value of the system property
  public static String getSystemProperty(ServletContext application, String sKey) throws FrameworkException{
  final String strKey = sKey;
  	ContextUtil.Callable callable = new ContextUtil.Callable() {
		public Object call(Context ctx) throws MatrixException{
			return EnoviaResourceBundle.getProperty(ctx, strKey);
		}
	};
	String keyValue = (String) ContextUtil.runInAnonymousContext(callable);
    return keyValue;
  }
%>

