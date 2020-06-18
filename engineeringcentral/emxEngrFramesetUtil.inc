<%--  emxEngrCommonFramesetInclude.jsp - Frameset utility methods for EC
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.util.*,
                   java.io.*,
                   java.net.URLEncoder,
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
                   com.matrixone.apps.engineering.Part,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>

<%
  DomainObject boAccess = DomainObject.newInstance(context);
%>

<%!
  static String appDirectory = null;
%>

<%
  //Changed the application.getAttribute() call for Bug 324151
  if (appDirectory == null){
	//Multitenant
	  //appDirectory = (String)FrameworkProperties.getProperty("eServiceSuiteEngineeringCentral.Directory");
	appDirectory = (String)EnoviaResourceBundle.getProperty(context, "eServiceSuiteEngineeringCentral.Directory");
  }

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
          <link rel="stylesheet" href="../emxUITemp.css" type="text/css" />
        </head>
          <body>
            &nbsp;
            <table width="90%" border="0"  cellspacing="0" cellpadding="3"  class="formBG" align="center" >
              <tr >                           
			  //XSSOK         
                <td class="errorHeader"><%=EnoviaResourceBundle.getProperty(context, "emxUIFrameworkStringResource", context.getLocale(),"emxFramework.Error.Header")%></td>
              </tr>
              <tr align="center">
              <!-- XSSOK -->
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

