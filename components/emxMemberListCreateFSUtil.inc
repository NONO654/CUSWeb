<%--  emxMemberListCreateFSUtil.inc
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.   Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxMemberListCreateFSUtil.inc.rca 1.7 Wed Oct 22 16:17:50 2008 przemek Experimental przemek $";
--%>


<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.domain.util.*"%> 
<%@page import = "com.matrixone.apps.framework.ui.*"%> 
<%@page import ="java.util.ResourceBundle" %>


<%@page errorPage = "../eServiceError.jsp"%>

<%!
  // This method returns the value of the application property
  public static String getApplicationProperty(matrix.db.Context context,ServletContext application,  String sKey){

    String sRetVal = null;
    try
    {
        sRetVal = FrameworkProperties.getProperty(context,sKey);

    }catch(Exception e){ sRetVal=""; }
   
    return sRetVal;
  }
%>


<%!
  // This method returns the value of the system property
  public static String getSystemProperty(matrix.db.Context context,ServletContext application, String sKey){
    String str = null;
    try{
        str = FrameworkProperties.getProperty(context,sKey);
    }
    catch(Exception e){ }
    return str;
  }
%>

