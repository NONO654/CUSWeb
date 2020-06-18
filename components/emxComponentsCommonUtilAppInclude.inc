<%--  emxComponentsCommonUtilAppInclude.inc  --  Components Include File

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxComponentsCommonUtilAppInclude.inc.rca 1.7 Wed Oct 22 16:18:47 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxTagLibInclude.inc"%>

<%@ page import = "matrix.db.*,
                   matrix.util.*,
                   com.matrixone.servlet.*,
                   java.util.*,
                   java.io.*,
                   java.net.*,
                   java.text.*" errorPage="eServiceError.jsp"%>

<%@ page import =  "com.matrixone.apps.common.BusinessUnit,
                    com.matrixone.apps.common.Company,
                    com.matrixone.apps.common.CertificationHolder,
                    com.matrixone.apps.common.Document,
                    com.matrixone.apps.common.VCDocument,
                    com.matrixone.apps.common.DocumentHolder,
                    com.matrixone.apps.common.DiscussionEvent,
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
                    com.matrixone.apps.common.Region,
                    com.matrixone.apps.common.Route,
                    com.matrixone.apps.common.RouteHolder,
                    com.matrixone.apps.common.RouteTemplate,
                    com.matrixone.apps.common.SketchHolder,
                    com.matrixone.apps.common.Subscribable,
                    com.matrixone.apps.common.SubscriptionManager,
                    com.matrixone.apps.common.VaultHolder,
                    com.matrixone.apps.common.Workspace,
                    com.matrixone.apps.common.WorkspaceVault" %>

<%@ page import = "com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>


<%!
  static String appDirectory = null;
 
        private static synchronized void init(HttpSession session) 
                throws matrix.util.MatrixException, com.matrixone.apps.domain.util.FrameworkException, Exception
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
  final String sLanguage = request.getHeader("Accept-Language");
  String DateFrm = (new Integer(java.text.DateFormat.MEDIUM)).toString();
%>
<!-- //XSSOK -->
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= sLanguage %>' />

