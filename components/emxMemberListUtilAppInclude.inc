<%-- emxSpecificationCentralCommonUtilAppInclude.INC  --  Specification Central Include File

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxMemberListUtilAppInclude.inc.rca 1.8 Wed Oct 22 16:17:51 2008 przemek Experimental przemek $
--%>

<%@ page import = "matrix.db.*, 
                   matrix.util.* , 
                   com.matrixone.servlet.*, 
                   java.io.*, 
                   java.util.*, 
                   java.text.*" errorPage="eServiceError.jsp"%> 



<%@ page import = "com.matrixone.apps.domain.*, 
                   com.matrixone.apps.domain.util.*, 
                   com.matrixone.apps.common.util.*, 
                   com.matrixone.apps.framework.ui.*, 
                   com.matrixone.apps.framework.taglib.*" %> 

<%@ include file = "../emxTagLibInclude.inc"%>
<%@ include file = "../emxI18NMethods.inc"%>
<%@ include file = "../emxJSValidation.inc" %>

<%!
  static String appDirectory = null;
  
        private static synchronized void init(HttpSession session) 
                throws matrix.util.MatrixException, FrameworkException, Exception
        {
                if (appDirectory != null ) return;
                matrix.db.Context ctx = Framework.getFrameContext(session);
                try {
                   appDirectory = (String)FrameworkProperties.getProperty(ctx,"eServiceSuiteComponents.Directory");
                } finally {
                                 ctx.shutdown();
                 }
         }
%>

<%
        init(session);
  String sLanguage = request.getHeader("Accept-Language");
  String DateFrm = (new Integer(java.text.DateFormat.MEDIUM)).toString();
%>
<!-- //XSSOK -->
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= sLanguage %>' />


