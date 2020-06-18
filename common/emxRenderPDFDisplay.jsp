<%--  emxRenderPDFDisplay.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRenderPDFDisplay.jsp.rca 1.6 Wed Oct 22 15:48:13 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<html>
<head>
<title> 
 <emxUtil:i18n localize="i18nId">emxFramework.RenderPDF.Tooltip</emxUtil:i18n>
</title>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
  <script language="javascript" src="../emxUIPageUtility.js"></script>
  <script type="text/javascript">
      addStyleSheet("emxUIDefault");
  </script>
</head>

<%
  String queryString = request.getQueryString();
  String url = "emxRenderPDF.jsp?" + XSSUtil.encodeURLwithParsing(context, queryString);
%>

<!-- //XSSOK -->
<body class="confirmDownload" onload="location='<%=url%>'" >
   <div id="confirmDownload">
     <p><emxUtil:i18n localize="i18nId">emxFramework.RenderPDF.RenderPDFProcessingMessage</emxUtil:i18n></p>
     <p><emxUtil:i18n localize="i18nId">emxFramework.RenderPDF.RenderPDFMessage</emxUtil:i18n></p>
     <p><emxUtil:i18n localize="i18nId">emxFramework.RenderPDF.RenderPDFDoneMessage</emxUtil:i18n></p>
     <p><a href="javascript:getTopWindow().closeWindow()"><emxUtil:i18n localize="i18nId">emxFramework.RenderPDF.Close</emxUtil:i18n></a></p>
    </div>
</body>
</html>
