<%--  emxComponentsFramesetUtil.inc - Frameset utility methods for Components
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsFramesetUtil.inc.rca 1.6 Wed Oct 22 16:17:50 2008 przemek Experimental przemek $
--%>


<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.util.*,
                   java.io.*,
                   java.text.*" errorPage="emxComponentsError.jsp"%>

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
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>

<%
  DomainObject boAccess = DomainObject.newInstance(context);
%>

<%
      String appDirectory = (String)FrameworkProperties.getProperty(context, "eServiceSuiteComponents.Directory");

  matrix.db.Access acc = null;

  // Set id of bean
  //
  String oid = emxGetParameter(request,"objectId");

  if (oid != null && !oid.equals("") && !oid.equals("null")) {

    try {

      boAccess.setId(oid);

      // Get access mask so that it can be used by
      // pages that include this page
      //
      acc = boAccess.getAccessMask(context);
    }
    catch (Exception ex) {
      String error = ex.toString();
%>
      <html>
        <head>
          <script>addStyleSheet("emxUITemp","../");</script>
        </head>
          <body>
            &nbsp;
            <table width="90%" border="0"  cellspacing="0" cellpadding="3"  class="formBG" align="center" >
              <tr >
                <td class="errorHeader"><%=i18nNow.getI18nString("emxFramework.Error.Header","emxUIFrameworkStringResource",request.getHeader("Accept-Language"))%></td>
              </tr>
              <tr align="center">
                <td class="errorMessage" align="center"><%=error%></td>
              </tr>
            </table>
        </body>
      </html>
<%
      return;
    }
  }
  else {
    acc = matrix.db.Person.getAccessMask(context);
  }
%>

