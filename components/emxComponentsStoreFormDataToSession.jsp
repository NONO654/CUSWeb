<%--  
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@  include file = "../emxUICommonAppInclude.inc"%>
<%
java.util.Enumeration eNumParameters = emxGetParameterNames(request);
java.util.Map paramMap = new java.util.HashMap();
while( eNumParameters.hasMoreElements() ) {
    String strParamName = (String)eNumParameters.nextElement();
    String[] strParamValues = emxGetParameterValues(request,strParamName);
    if(strParamValues == null || strParamValues.length == 0) {
        continue;
    } else if(strParamValues.length == 1) {
        paramMap.put(strParamName, strParamValues[0]);
    } else {
        paramMap.put(strParamName, strParamValues);
    }
}
String sessionKey = "key:" + System.currentTimeMillis();
session.setAttribute(sessionKey, paramMap);
String result = "<mxFormData><sessionKey>"+ sessionKey+"</sessionKey></mxFormData>";
out.clear();
out.println(result);
%>
