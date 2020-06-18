<%--  emxTeamCommonUtilAppInclude.inc  --  Supplier Central Include File

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamCommonUtilAppInclude.inc.rca 1.28 Wed Oct 22 16:06:18 2008 przemek Experimental przemek $
--%>
<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.util.*,
                   java.io.*,
                   java.text.*,
                   com.matrixone.apps.framework.taglib.*" errorPage="../common/emxNavigatorErrorPage.jsp"%>

<%@ page import =  "com.matrixone.apps.common.BuyerDesk,
                    com.matrixone.apps.common.BusinessUnit,
                    com.matrixone.apps.common.CommonDocument,
                    com.matrixone.apps.common.CommonDocumentable,
                    com.matrixone.apps.common.Company,
                    com.matrixone.apps.common.Document,
                    com.matrixone.apps.common.DocumentHolder,
                    com.matrixone.apps.common.InboxTask,
                    com.matrixone.apps.common.Location,
                    com.matrixone.apps.common.Message,
                    com.matrixone.apps.common.Meeting,
                    com.matrixone.apps.common.MessageHolder,
                    com.matrixone.apps.common.Organization,
                    com.matrixone.apps.common.Person,
                    com.matrixone.apps.common.Part,
                    com.matrixone.apps.common.Route,
                    com.matrixone.apps.common.RouteHolder,
                    com.matrixone.apps.common.RouteTemplate,
                    com.matrixone.apps.common.Subscribable,
                    com.matrixone.apps.common.SubscriptionManager,
                    com.matrixone.apps.common.UserTask,
                    com.matrixone.apps.common.Workspace,
                    com.matrixone.apps.common.WorkspaceVault"%>

<%@ page import = "com.matrixone.apps.team.*,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*" %>

<%@include file = "../emxTagLibInclude.inc"%>



<%
  final String  appDirectory = (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteTeamCentral" + ".Directory");
  String sLanguage = request.getHeader("Accept-Language");
  String DateFrm = "";
%>

<emxUtil:localize id="i18nId" bundle="emxTeamCentralStringResource" locale='<%=XSSUtil.encodeForJavaScript(context,sLanguage) %>' />
