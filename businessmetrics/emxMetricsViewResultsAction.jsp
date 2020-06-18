<%-- emxMetricsViewResultsAction.jsp - This JSP will be invoked wthen the user
                                        clicks on the "Done" link in View Results dialog page
   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsViewResultsAction.jsp.rca 1.5 Wed Oct 22 16:11:55 2008 przemek Experimental $
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<html>
<%
  String strURL = emxGetParameter(request,"strURL");
%>
<head><title>MatrixOne</title>
<script language="JavaScript" src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript" src="emxMetrics.js"></script>

<script language="javascript">
var strURL="<%=XSSUtil.encodeURLwithParsing(context, strURL)%>";
function submitSpecialForm(){
    showNonModalDialog(strURL, 700, 600,false);
}
</script>
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</head>
<body topmargin="0" marginheight="0" leftmargin="0" marginwidth="0" onload="submitSpecialForm()">
</body>
</html>
