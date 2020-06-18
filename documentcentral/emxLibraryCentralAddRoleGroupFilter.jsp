<%--  emxLibraryCentralAddRoleGroupFilter.jsp   -  
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
    
   To Filter Role and Group
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%
    try {
        String strnameMatches       = emxGetParameter(request,"LBCNameMatchesTextboxFilter");
        String strTopLevelFilter    = emxGetParameter(request,"LBCTopLevelCheckboxFilter");
        String strSublevelFilter    = emxGetParameter(request,"LBCSublevelCheckBoxFilter");
        String sTableName           = emxGetParameter(request,"table");
        String sAction              = emxGetParameter(request,"useMode");
%>
<html>
<head></head>
<body>
    
    <script language="JavaScript">
        parent.resetParameter("LBCNameMatchesTextboxFilter", "<xss:encodeForJavaScript><%=strnameMatches%></xss:encodeForJavaScript>");
        parent.resetParameter("LBCTopLevelCheckboxFilter","<xss:encodeForJavaScript><%=strTopLevelFilter%></xss:encodeForJavaScript>");
        parent.resetParameter("LBCSublevelCheckBoxFilter","<xss:encodeForJavaScript><%=strSublevelFilter%></xss:encodeForJavaScript>");
        parent.resetParameter("useMode","<xss:encodeForJavaScript><%=sAction%></xss:encodeForJavaScript>");
        parent.refreshSBTable("<xss:encodeForJavaScript><%=sTableName%></xss:encodeForJavaScript>","Name","ascending");
    </script>
<%
    } catch (Exception ex){
         if (ex.toString() != null && ex.toString().length() > 0){
            emxNavErrorObject.addMessage(ex.toString());
         }
         ex.printStackTrace();
    }
%>
</body>
</html>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
