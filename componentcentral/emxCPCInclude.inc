<%--  emxEngrCommonFramesetInclude.jsp - Frameset utility methods for EC
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxEngrFramesetUtil.inc.rca 1.13 Wed Oct 22 15:52:46 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../emxI18NMethods.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.util.*,
                   java.io.*,
                   java.net.*,
                   java.net.URLEncoder,
                   java.text.*" errorPage="../common/eServiceError.jsp"%>

<%@ page import =  "com.matrixone.apps.common.BuyerDesk,
                    com.matrixone.apps.common.BusinessUnit,
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
                    com.matrixone.apps.common.PurchaseClassHolder,
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
                   com.matrixone.apps.componentcentral.*,
                   com.matrixone.apps.library.*,
                   com.matrixone.apps.classification.*,
                   com.matrixone.apps.document.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>

<%
  DomainObject boAccess = DomainObject.newInstance(context);
  String sLanguage = request.getHeader("Accept-Language");
  // set Java variable with browser type.
    String  userAgent = request.getHeader("User-Agent");
    boolean isIE      = (userAgent != null && userAgent.indexOf("MSIE") != -1);  
  
%>

<%!
  static String appDirectory = null;
%>

<%
  //Changed the application.getAttribute() call for Bug 324151
  if (appDirectory == null){
      appDirectory = (String)FrameworkProperties.getProperty(context, "eServiceSuiteComponentCentral.Directory");
  }

 %>
<emxUtil:localize id="i18nId" bundle="emxComponentCentralStringResource" locale='<%= sLanguage %>' />
<%!
  // Call this method to internationalize variables in java.
  // i18nStringNow("stringid", request.getHeader("Accept-Language"));
  static public String i18nStringNow(String sText,String sLanguage)
  {
    i18nNow loc = new i18nNow();
    return (String) loc.GetString("emxComponentCentralStringResource", sLanguage, sText);
  }
%>
