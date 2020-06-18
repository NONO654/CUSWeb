<%--  emxLibraryCentralJobsDownloadFile.jsp  -  This page exports the  line items.

    (c) Dassault Systemes, 1993 - 2016.  All rights reserved.

  static const char RCSID[] = "$Id: /ENOSourcingCentral/CNext/webroot/documentcentral\emxLibraryCentralJobsDownloadFile.jsp.jsp 1.3.2.2.1.1 Wed Oct 29 22:23:58 2008 GMT przemek Experimental$"
--%>

<%@ include file  = "../emxUICommonAppInclude.inc" %>
<%@  include file = "emxMultipleClassificationUtils.inc" %>
<%@ page import = "java.lang.reflect.*" %>

<script language="JavaScript">
    /*function windowClose(){
      parent.window.getWindowOpener().parent.frames[1].location.reload();
      getTopWindow().close();
    }*/
</script>

<%
String url=null;
String clientSideURL=null;
matrix.db.File fileName = null;
try
{
 String jobId = emxGetParameter(request,"objectId");
 Job job=new Job(jobId);
 matrix.db.FileList filesList=job.getFiles(context);
 String logFormat = PropertyUtil.getSchemaProperty(context, "format_Log");
 logFormat ="Output";
 String workspace = context.createWorkspace() + java.io.File.separator + filesList.get(0) ;
 workspace = context.createWorkspace() ;
  fileName = (matrix.db.File)filesList.get(0);
 java.io.File file = new java.io.File(workspace);
 if ( !file.exists() && !file.mkdir() )
 {
 	workspace = context.createWorkspace();
 }
 file = new java.io.File(workspace + java.io.File.separator + fileName.getName());

 job.checkoutFile(context, false, logFormat, fileName.getName(), workspace);

    //fileName = (matrix.db.File)filesList.get(0);
	String filePath = Framework.getTemporaryFilePath(response,session,fileName.getName(),false);
	clientSideURL = Framework.getFullClientSideURL(request,response,filePath);

  }catch(Exception e)
  {
	  e.printStackTrace();
  }
  response.sendRedirect(clientSideURL);

%>


