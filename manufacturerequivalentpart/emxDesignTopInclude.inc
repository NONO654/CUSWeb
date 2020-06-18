<%--  emxDesignTopInclude.inc   -  Top Level Include File for Engineering Central Suite

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxDesignTopInclude.inc.rca 1.97 Wed Oct 22 15:52:20 2008 przemek Experimental przemek $
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

<%@ page import = "com.matrixone.apps.engineering.*,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>

<%@include file = "../emxRequestWrapperMethods.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%//Start Internationalization%>
<emxUtil:localize id="i18nId" bundle="emxManufacturerEquivalentPartStringResource" locale='<%= request.getHeader("Accept-Language") %>'/>

<%!
  // Call this method to internationalize variables in java.
  // i18nStringNow("stringid", request.getHeader("Accept-Language"));
  static public String i18nStringNow(String text, String languageStr)
  {
    return i18nNow.getI18nString(text,"emxManufacturerEquivalentPartStringResource",languageStr);
  }
%>
<%//End Internationalization%>
