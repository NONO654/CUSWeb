<%--  emxAEFSubmitJPO.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxAEFSubmitJPO.jsp.rca 1.1.5.4 Wed Oct 22 15:48:55 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%

String submitFunction = emxGetParameter(request,"submitFunction");
String submitProgram = emxGetParameter(request,"submitProgram");
String timeStamp = emxGetParameter(request,"timeStamp");
System.out.println("query string"+emxGetQueryString(request));
System.out.println("test"+emxGetParameter(request,"ENCSearchGeneral"));
StringBuffer sfb = new StringBuffer();
String errorMessage="";
HashMap paramMap = new HashMap();
Enumeration enumParamNames = emxGetParameterNames(request);
while(enumParamNames.hasMoreElements()) {
    String paramName = (String) enumParamNames.nextElement();
    String paramValue = emxGetParameter(request,paramName);
            paramMap.put(paramName,paramValue);
}
HashMap tableData = tableBean.getTableData(timeStamp);
paramMap.put("tableData",tableData);

String[] methodargs = JPO.packArgs(paramMap);

     try {
   	  FrameworkUtil.validateMethodBeforeInvoke(context, submitProgram, submitFunction, "Program");
      Object tempObject = JPO.invoke(context, submitProgram, null, submitFunction, methodargs,
                                        Object.class);
     } catch (Exception exJPO) {
        errorMessage=exJPO.toString();
}
errorMessage = errorMessage.trim();
%>
<script language="Javascript" type="text/javascript" >
//XSSOK
if("<%=XSSUtil.encodeForJavaScript(context, errorMessage)%>"!="")
{
    alert("<%=XSSUtil.encodeForJavaScript(context, errorMessage)%>");
}
</script>
