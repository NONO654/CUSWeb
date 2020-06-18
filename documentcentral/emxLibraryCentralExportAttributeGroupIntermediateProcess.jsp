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
<%@include file = "emxLibraryCentralUtils.inc"%>
<%@page import  = "java.io.File"%>
<%
    try{
    String jobName=null;
    String fileName=null;
    String IsAsynchronous=(String)emxGetParameter(request,"IsAsynchronous");
    String agNames[]=emxGetParameterValues(request,"emxTableRowId");
    agNames = getTableRowIDsArray(agNames);
    
    if(IsAsynchronous!=null && "on".equals(IsAsynchronous)){
        LibraryCentralJobs lcJobs=new LibraryCentralJobs();
        jobName=lcJobs.exportAttributeGroupASync(context,agNames);
%>
        <script>
        alert("<emxUtil:i18nScript localize="i18nId">emxMultipleClassification.Job.JobCreated</emxUtil:i18nScript>" + "  <xss:encodeForJavaScript><%=jobName%></xss:encodeForJavaScript>" + "\n" +" <emxUtil:i18nScript localize="i18nId">emxMultipleClassification.Job.JobCreatedPostMsg</emxUtil:i18nScript>");
        </script>
<%
    }

    else{
        String[] constructor = {null};
        HashMap paramMap = new HashMap();
        paramMap.put("AGNames",agNames);
        String args[]=JPO.packArgs(paramMap);
        File file=(File)JPO.invoke(context,"emxMultipleClassificationAttributeGroup",constructor,"exportAttributeGroup",args,File.class);
        fileName=file.getName();
        String filePath = Framework.getTemporaryFilePath(response,session,fileName,false);
        String clientSideURL = Framework.getFullClientSideURL(request,response,filePath);
        response.sendRedirect(clientSideURL);
    }

}catch(Exception err){
    err.printStackTrace();
}
%>
