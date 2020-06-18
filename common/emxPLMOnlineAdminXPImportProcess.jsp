<!-- 
@fullReview ZUR 11/03/22 V6R2012x HL ENOVIA TEAM Parameterization Import/Export

Copyright (c) 1992-2011 Dassault Systemes.
All Rights Reserved.
Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

 -->

<%@page import ="com.matrixone.vplm.ParameterizationImportExport.ParameterizationImportExport"%>
<%@page import="java.io.File"%>
<%@page import="matrix.db.Command"%>

<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript">
</script>

<jsp:useBean id="formBean" scope="page" class="com.matrixone.apps.common.util.FormBean"/>
<%
   try
   {
      // Extracting parameters from request object
      formBean.processForm(session, request);

    //  String fileEncoding = UINavigatorUtil. getFileEncoding (context, request);
      String userAction = (String) formBean.getElementValue("mode");
      String description = (String) formBean.getElementValue("description");
      File importFile = (File) formBean.getElementValue("file");

      String[] args = new String[1];
      args[0] = importFile.getAbsolutePath();	  
      
      ParameterizationImportExport importObj = new ParameterizationImportExport(context);
      if (importObj.importParam(context,args[0]) != ParameterizationImportExport.S_SUCCESS)
		{
%>
<script language="javascript">  
   document.location.href = "../common/emxPLMOnlineAdminXPImportExportParams.jsp?importResult=ERROR";  
</script>
<%
		}
	  else
		{
	    
%>
<script language="javascript">  
   document.location.href = "../common/emxPLMOnlineAdminXPImportExportParams.jsp?importResult=SUCCESS";  
</script>
<%
		}
   }
   catch(Exception ex)
   {
      session.setAttribute("error.message", ex.toString());
%>
<script language="javascript">
alert(parent.document.getElementByName("APPXPParamImportExport").src);
alert("<%=ex.toString()%>");
  document.location.href = "../common/emxPLMOnlineAdminXPImportExportParams.jsp?importResult=ERROR";

</script>
<%
   }
%>


        
