<%--
   emxNavigatorErrorPage.jsp -- error page referenced by emxNavigatorInclude.jsp

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxNavigatorErrorPage.jsp.rca 1.4 Wed Oct 22 16:11:57 2008 przemek Experimental $";
--%>

<%@ page import = "matrix.db.*,matrix.util.*,com.matrixone.servlet.*" isErrorPage="true"%>

<%
matrix.db.Context context = null;//Framework.getContext(session);
try
{
  context = Framework.getFrameContext(session);
}
catch (Exception ex)
{
}

%>
<html>
<head>
<%@include file = "../emxMQLNotice.inc"%>
</head>

<body>

<%
    //if null exception object, create one to display
    if (exception == null) {
       exception = new Exception("\"Exception Unavailable\"");
    }
%>

<img src="images/utilSpacer.gif" width="1" height="8" />
<TABLE class="error" cellSpacing="0" cellPadding="1" width="95%" border="0" align="center">
  <TBODY>
  <TR>
    <TD>
      <TABLE cellSpacing="0" cellPadding="3" width="100%" border="0">
        <TBODY>
        <TR>
          <TH class="error" align="left">Unexpected Error occured:</TH></TR>
        <TR>
		  <!-- //XSSOK -->
          <TD class="errMsg" align="left"><%=exception.toString()%></TD>
        </TR>
        </TBODY>
      </TABLE>
    </TD>
   </TR>
  </TBODY>
 </TABLE>

<br/>

</body>
</html>


