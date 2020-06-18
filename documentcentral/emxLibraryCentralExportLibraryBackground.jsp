<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "$Id: emxLibraryCentralExportAttributeGroupIntermediateProcess.jsp.rca 1.2.3.2 Wed Oct 22 16:02:42 2008 przemek Experimental przemek $";
   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxMultipleClassificationUtils.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ page import="com.matrixone.servlet.Framework,com.matrixone.fcs.mcs.McsBase" %>
<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript">
</script>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>
<%
	String LibraryId=emxGetParameter(request,"emxTableRowId");
	//System.out.println("Inside the export Background:LIB "+LibraryId);
	//R2013, emxIndentedtable returns the emxTableRowId with | seperated values, hence
	//splitting it. The first element will be the objectId
	StringList libIdList=FrameworkUtil.split(LibraryId,"|");
	LibraryId=(String)libIdList.get(0);
	LibraryCentralJobs lcJobs=new LibraryCentralJobs(LibraryId);
	String jobName=lcJobs.exportLibraryASync(context,LibraryId);
%>
 // ------------------------ Page content above here  ---------------------
  //----------------- Do Not Edit Below ------------------------------
<script>
var jobName="<xss:encodeForJavaScript><%=jobName%></xss:encodeForJavaScript>";
alert("<emxUtil:i18nScript localize="i18nId">emxMultipleClassification.Job.JobCreated</emxUtil:i18nScript> " +jobName+ "\n"+ "<emxUtil:i18nScript localize="i18nId">emxMultipleClassification.Job.JobCreatedPostMsg</emxUtil:i18nScript>");
getTopWindow().closeSlideInDialog();
getTopWindow().refreshTablePage();
</script>



<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
