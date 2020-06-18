<%--  emxPrefLanguage.jsp -
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxPrefLanguageProcessing.jsp.rca 1.3.1.1 Mon Aug  6 15:28:51 2007 przemek Experimental $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@ page import = "com.matrixone.vplmintegrationitf.util.*" %>

<%
	String personRole = emxGetParameter(request, "vplmContext");
	PropertyUtil.setAdminProperty(context, "person", context.getUser(), VPLMIntegrationConstants.PREFERENCE_VPLMINTEG_VPLMCONTEXT , personRole);
%>


<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

