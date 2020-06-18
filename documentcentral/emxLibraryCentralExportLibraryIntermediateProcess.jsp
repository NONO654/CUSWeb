<%--  Page Name   emxLibraryCentralExportLibraryIntermediateProcess.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc"%>
<%@page import  = "java.io.File"%>

<%
	String jobName=null;
    String isAsynchronous   = emxGetParameter(request,"IsAsynchronous");
    String libraryId        = emxGetParameter(request,"emxTableRowId");
    try{

	HashMap paramMap = new HashMap();
	//Export command can be launched from summary page and also from properties
	//page, if its coming from Properties page, emxTableRowId would be null,
	//hence using ObjectId request parameter
        if(libraryId != null) {
            //R2013, emxIndentedtable returns the emxTableRowId with | seperated values, hence
            //splitting it. The first element will be the objectId
            StringList libIdList    = FrameworkUtil.split(libraryId,"|");
            libraryId   =(String)libIdList.get(0);
        } else {
            libraryId   =(String)emxGetParameter(request,"objectId");
	}
        if(isAsynchronous != null && "on".equals(isAsynchronous)) {
            LibraryCentralJobs lcJobs   = new LibraryCentralJobs(libraryId);
            jobName                     = lcJobs.exportLibraryASync(context,libraryId);
        } else{
		String[] constructor = {null};
            paramMap.put("LibraryObjectId",libraryId);
            DomainObject domObj     = new DomainObject(libraryId);
            String libraryName      = domObj.getInfo(context,DomainConstants.SELECT_NAME);
		String args[]=JPO.packArgs(paramMap);
            File file               = (File)JPO.invoke(context,"emxMultipleClassificationClassification",constructor,"exportLibrary",args, File.class);
            String fileName         = file.getName();
		String filePath = Framework.getTemporaryFilePath(response,session,fileName,false);
		String clientSideURL = Framework.getFullClientSideURL(request,response,filePath);
		response.sendRedirect(clientSideURL);
	}
    } catch(Exception err) {
        err.printStackTrace();
    }
%>
<script>
        if("<xss:encodeForJavaScript><%=isAsynchronous%></xss:encodeForJavaScript>" =="on") {
alert("<emxUtil:i18nScript localize="i18nId">emxMultipleClassification.Job.JobCreated</emxUtil:i18nScript>" + " <xss:encodeForJavaScript><%= jobName%></xss:encodeForJavaScript>" +"\n"+ "<emxUtil:i18nScript localize="i18nId">emxMultipleClassification.Job.JobCreatedPostMsg</emxUtil:i18nScript>");
        }
getTopWindow().refreshTablePage();
</script>

