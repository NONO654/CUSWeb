 <%--  smaAdvisePostprocessDatasetImport.jsp - this jsp completes the file upload transaction.
 * (c) Dassault Systemes, 2013
 *
--%>
<%-- Common Includes --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.ExecutionServiceUtil"%>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<%
     matrix.db.Context context2 = 
         (matrix.db.Context)request.getAttribute("context");
     if (context2 != null)
         context = context2;
	
     String fileName = (String)request.getParameter("fname");
     String FCSReceipt = (String)request.getParameter("receipt");
     FCSReceipt=FCSReceipt.replaceAll("__","+");
     FCSReceipt=FCSReceipt.replaceAll(" ","+");
     String status = "ok";
 	try{
 		ExecutionServiceUtil.commitStream(context, fileName, FCSReceipt);
	
    } catch(Exception e) {
    	status = "error";
    	e.printStackTrace();
    }
%>
</head>
<body>
<%=status%>
</body>
