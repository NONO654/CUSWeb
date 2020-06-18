<%--  IEFCommonDocumentInvalidAction.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>

<%
  String languageStr	= request.getHeader("Accept-Language");
  MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(languageStr);

  String errorMessage			= serverResourceBundle.getString("mcadIntegration.Server.Message.InvalidOperationDownload");
  String checkoutDoneMessage	= serverResourceBundle.getString("mcadIntegration.Server.Message.CommonDocumentOperationDone");
%>
<html>
<head>
  <link rel="stylesheet" type="text/css" href="../common/styles/emxUICalendar.css">
  <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDialog.css">
  <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDialog_Unix.css">
</head>
<body class="confirmDownload">

  <script type="text/javascript">
      if(top.opener.top.modalDialog)
      {
          top.opener.top.modalDialog.releaseMouse();
      }
  </script>
   <div id="confirmDownload">
     <p><%=errorMessage%></p>
     <p><%=checkoutDoneMessage%></p>
     <p><a href="javascript:top.close()">&nbsp;&nbsp;Done&nbsp;&nbsp;</a></p>
    </div>

</body>
</html>
