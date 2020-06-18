<%--  emxRoleGroupFilter.jsp   -  
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
	
   To Filter Role and Group
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%
    try {
        String strnameMatches       = emxGetParameter(request,"APPNameMatchesTextbox");
        String strTopLevelFilter        = emxGetParameter(request,"APPFilterTopLevelCheckbox");
        String strSublevelFilter          = emxGetParameter(request,"APPFilterSubLevelCheckbox");
        String sTableName           = emxGetParameter(request,"table");
%>
<html>
<head></head>
<body>
    
    <script language="JavaScript">
        parent.resetParameter("APPNameMatchesTextbox", "<%=XSSUtil.encodeForJavaScript(context, strnameMatches)%>");
        parent.resetParameter("APPFilterTopLevelCheckbox","<%=XSSUtil.encodeForJavaScript(context, strTopLevelFilter)%>");
        parent.resetParameter("APPFilterSubLevelCheckbox","<%=XSSUtil.encodeForJavaScript(context, strSublevelFilter)%>");
        parent.refreshSBTable("<%=XSSUtil.encodeForJavaScript(context, sTableName)%>","Name","ascending");
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

