
<%--  emxComponentsUpdatedTreeLabel.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@page import="org.owasp.esapi.ESAPI"%>
<%@include file ="../emxUICommonAppInclude.inc"%>
<%@include file ="../components/emxComponentsNoCache.inc"%>
<%@include file ="../common/emxTreeUtilInclude.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.*" %>

<% 
    String objectId         = emxGetParameter(request,"objectId");
    String sLanguage        = request.getHeader("Accept-Language");
    String appDirectory     = emxGetParameter(request,"appDirectory");
    appDirectory = UIUtil.isNullOrEmpty(appDirectory)? "Components": appDirectory;
    String updatedLabel     = UITreeUtil.getUpdatedTreeLabel (application, session, request, context, objectId, "", appDirectory, sLanguage);
    
    updatedLabel = ESAPI.encoder().canonicalize(updatedLabel);
    updatedLabel =     XSSUtil.encodeForXML(context,updatedLabel);
    out.clear();
    out.println("<updatedLabel>" + updatedLabel + "</updatedLabel>");
%>
