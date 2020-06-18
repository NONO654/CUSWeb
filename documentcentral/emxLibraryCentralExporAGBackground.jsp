<%--  Page Name  emxLibraryCentralExporAGBackground.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "$Id: emxLibraryCentralExportAttributeGroupIntermediateProcess.jsp.rca 1.2.3.2 Wed Oct 22 16:02:42 2008 przemek Experimental przemek $";
   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc"%>

<%
	String agNames[] = emxGetParameterValues(request,"emxTableRowId");
	LibraryCentralJobs lcJobs=new LibraryCentralJobs();
	String jobName=lcJobs.exportAttributeGroupASync(context,agNames);
%>
<script>
var jobName="<xss:encodeForJavaScript><%=jobName%></xss:encodeForJavaScript>";
alert("<emxUtil:i18nScript localize="i18nId">emxMultipleClassification.Job.JobCreated</emxUtil:i18nScript> " +jobName +"\n"+ "<emxUtil:i18nScript localize="i18nId">emxMultipleClassification.Job.JobCreatedPostMsg</emxUtil:i18nScript>");
getTopWindow().refreshTablePage();
</script>

