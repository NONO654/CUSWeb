<%--  emxComponentsTopInclude.inc   -  Top Level Include File for AppsCommon

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsTopInclude.inc.rca 1.5 Wed Oct 22 16:18:41 2008 przemek Experimental przemek $
--%>
<%@ page import = "matrix.db.*, 
                   matrix.util.* ,
                   com.matrixone.servlet.*, 
                   java.io.*, 
                   java.util.*,
                   java.text.*" errorPage="eServiceError.jsp"%>

<%@ page import =  "com.matrixone.apps.common.BaseManager,
                    com.matrixone.apps.common.BuyerDesk, 
                    com.matrixone.apps.common.BusinessUnit, 
                    com.matrixone.apps.common.Company,  
                    com.matrixone.apps.common.CertificationHolder,        
                    com.matrixone.apps.common.Document, 
                    com.matrixone.apps.common.Documentable, 
                    com.matrixone.apps.common.DocumentHolder, 
                    com.matrixone.apps.common.DocumentManager, 
                    com.matrixone.apps.common.ECRable, 
                    com.matrixone.apps.common.ECRManager, 
                    com.matrixone.apps.common.ECOable, 
                    com.matrixone.apps.common.ECOManager, 
                    com.matrixone.apps.common.FileFormatHolder,    
                    com.matrixone.apps.common.InboxTask, 
                    com.matrixone.apps.common.Location, 
                    com.matrixone.apps.common.Markupable, 
                    com.matrixone.apps.common.MarkupHolder, 
                    com.matrixone.apps.common.MarkupManager,     
                    com.matrixone.apps.common.Message, 
                    com.matrixone.apps.common.Messageable, 
                    com.matrixone.apps.common.MessageHolder, 
                    com.matrixone.apps.common.MessageManager, 
                    com.matrixone.apps.common.MultipleOwners,     
                    com.matrixone.apps.common.MultipleOwnerManager, 
                    com.matrixone.apps.common.Organization, 
                    com.matrixone.apps.common.OrganizationList, 
                    com.matrixone.apps.common.Person, 
                    com.matrixone.apps.common.PurchaseClassHolder, 
                    com.matrixone.apps.common.Route, 
                    com.matrixone.apps.common.RouteHolder, 
                    com.matrixone.apps.common.RouteTemplate,     
                    com.matrixone.apps.common.Sketchable, 
                    com.matrixone.apps.common.SketchHolder, 
                    com.matrixone.apps.common.SketchManager,    
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

<%@include file = "../emxI18NMethods.inc"%>


<%!
  //
  // check for URL appended values if not found, then look in Request Headers
  // and return the string
  //
   static public String emxGetParameter(HttpServletRequest request,
                                        String parameter) throws Exception
  {
    return (Request.getParameter(request, parameter));
  }
%>


<%!
  //
  // check for URL appended values if not found, then look in Request Headers
  // and return the string
  //
   static public String[] emxGetParameterValues(HttpServletRequest request,
                                                String parameter)
  {
    return (Request.getParameterValues(request, parameter));
   }
%>
<%!
  //
  // return the list of parameter names
  //
  static Enumeration emxGetParameterNames(HttpServletRequest req)
  {
    Enumeration enum = req.getParameterNames();
    return (enum);
  }
%>

<%
  // init. Variables
  matrix.db.Context context = null;
  context = Framework.getFrameContext(session);
%>
