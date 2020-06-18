<!-- ImportXMLStructureProcess.jsp  --  

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

 -->
 <%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
       respective scriplet
      @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
 --%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import="com.matrixone.apps.domain.Job"%>
<%@page import="matrix.db.Command"%>
<%@page import="java.io.File"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript">
</script>

<jsp:useBean id="formBean" scope="page" class="com.matrixone.apps.common.util.FormBean"/>
<%
   try
   {
      // Extracting parameters from request object
      formBean.processForm(session, request);

      String fileEncoding = UINavigatorUtil. getFileEncoding (context, request);
      String userAction = (String) formBean.getElementValue("mode");
      String description = (String) formBean.getElementValue("description");
      File importFile = (File) formBean.getElementValue("file");
      String jobTitle = importFile.getName();

      String[] args = new String[2];
      args[0] = importFile.getAbsolutePath();
      args[1] = userAction;

      Job bgImport = new Job("emxImportXMLStructure", "importStructureFromJob", args);
      bgImport.setTitle(jobTitle);
      bgImport.setJobType("type_Job");
      bgImport.createAndSubmit(context);
      bgImport.setStartDate(context);
//      if (description != null && description.length() > 0)
//        bgImport.setDescription(context, description);

//      bgImport.start(context);
//      bgImport.startMonitorThread(context);

      Command bgJobCmd = new Command(context, "AEFBackgroundRequests");
      String bgJobHref = bgJobCmd.getHref();
      if (bgJobHref.startsWith("${"))
      {
         int close = bgJobHref.indexOf("}/") + 1;
         bgJobHref = "../common" + bgJobHref.substring(close);
      }
%>
<script language="javascript">
   //document.location.href = "<%=bgJobHref%>"
   document.location.href = "../common/emxJobProcessFS.jsp?objectId=<xss:encodeForJavaScript><%=bgImport.getId()%></xss:encodeForJavaScript>";
</script>
<%
   }
   catch(Exception ex)
   {
      session.setAttribute("error.message", ex.toString());
%>
<script language="javascript">
   alert("<xss:encodeForJavaScript><%=ex.toString()%></xss:encodeForJavaScript>");
</script>
<%
   }
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
