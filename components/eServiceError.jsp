<%--
   error.jsp -- error page referenced by eServiceBegin

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: eServiceError.jsp.rca 1.1.2.1 Wed Oct 22 16:18:29 2008 przemek Experimental przemek $";
--%>

<%@ page import = "matrix.db.*,matrix.util.*,com.matrixone.servlet.*" isErrorPage="true"%>
<jsp:useBean id="documentFormBean" scope="session"
                                   class="com.matrixone.apps.common.util.FormBean" />
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
<body>
<%
    //if null exception object, create one to display
    if (exception == null) {
       exception = new Exception("\"Exception Unavailable\"");
    }
%>
<%  
try{
  String formKeyValue = documentFormBean.getFormKey();
  documentFormBean.removeFormInstance(session,request);

  if(formKeyValue != null)
  {
    session.removeAttribute(formKeyValue);
  }
}
catch(Exception e){}

  
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
          <TD class="errMsg" align="left"><%= com.matrixone.apps.domain.util.XSSUtil.encodeForHTML(context, exception.toString())%></TD>
        </TR>
        </TBODY>
      </TABLE>
    </TD>
   </TR>
  </TBODY>
 </TABLE>

<br/>

</body>
<script language="javascript">
function closeWindow()
{
	window.closeWindow();
}
</script>
</html>
