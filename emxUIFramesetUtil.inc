<%--  emxUIFramesetUtil.inc   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxUIFramesetUtil.inc.rca 1.32 Wed Oct 22 16:09:36 2008 przemek Experimental przemek $"
--%>

<%@ page import = "com.matrixone.apps.framework.ui.*" %>

<%@include file = "emxUITopInclude.inc"%>
<%
  String topActionBar = emxGetParameter(request,"topActionBar");
  String bottomActionBar = emxGetParameter(request,"bottomActionBar");
%>



