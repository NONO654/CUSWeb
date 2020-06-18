<%--  emxQuoteCommonUtilAppInclude.inc  --  Supplier Central Include File

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralCommonUtilAppInclude.inc.rca 1.13 Wed Oct 22 15:50:30 2008 przemek Experimental przemek $"
--%>
<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.io.*,
                   java.util.*,
                   java.text.*" errorPage="../common/eServiceError.jsp"%>

<%@ page import = "com.matrixone.apps.program.*,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>

<%@ page import =  "com.matrixone.apps.common.BusinessUnit,
                    com.matrixone.apps.common.Company,
                    com.matrixone.apps.common.Document,
                    com.matrixone.apps.common.DocumentHolder,
                    com.matrixone.apps.common.FileFormatHolder,
                    com.matrixone.apps.common.InboxTask,
                    com.matrixone.apps.common.Location,
                    com.matrixone.apps.common.Message,
                    com.matrixone.apps.common.MessageHolder,
                    com.matrixone.apps.common.Person,
                    com.matrixone.apps.common.Route,
                    com.matrixone.apps.common.RouteHolder,
                    com.matrixone.apps.common.RouteTemplate,
                    com.matrixone.apps.common.Subscribable,
                    com.matrixone.apps.common.VaultHolder,
                    com.matrixone.apps.common.VCDocument,
                    com.matrixone.apps.common.Workspace,
                    com.matrixone.apps.common.WorkspaceVault" %>

<%@include file = "../emxTagLibInclude.inc"%>

<%!
  static String appDirectory = null;
%>

<%
  if (appDirectory == null ){
  	matrix.db.Context _ctx = Framework.getFrameContext(session);
  	appDirectory = EnoviaResourceBundle.getProperty(_ctx, "eServiceSuiteProgramCentral.Directory");
  	_ctx.shutdown();
	_ctx = null;
  }
%>

<%

  String sLanguage = request.getHeader("Accept-Language");
%>

<emxUtil:localize id="i18nId" bundle="emxProgramCentralStringResource" locale='<%= sLanguage %>' />   <%-- XSSOK --%>

