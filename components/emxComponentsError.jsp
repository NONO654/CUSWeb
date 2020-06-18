<%--
   emxComponentError.jsp -- error page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsError.jsp.rca 1.9 Wed Oct 22 16:17:58 2008 przemek Experimental przemek $"
--%>
<%@ page import = "matrix.db.*,matrix.util.*,com.matrixone.servlet.* " isErrorPage="true"%>
<%@ page import="com.matrixone.apps.common.util.ComponentsUtil" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
if ("true".equals(emxGetParameter(request,"requestPopup"))) {

%>
<script>
	getTopWindow().showModalDialog('emxComponentsError.jsp?ErrorMessage=<%=XSSUtil.encodeForURL(context,emxGetParameter(request,"ErrorMessage"))%>');
</script>
<%
}
else {
    //if null exception object, create one to display
    if ( emxGetParameter(request,"ErrorMessage") != null )
    {
      exception = new Exception(emxGetParameter(request, "ErrorMessage"));
    }

    if (exception == null) {
       exception = new Exception("\"Exception Unavailable\"");
    }
%>

<jsp:include page = "emxMQLNotice.jsp" flush="true" />

<img src="../common/images/utilSpacer.gif" width="1" height="8" />
<TABLE cellSpacing="0" cellPadding="1" width="95%" border="0" align="center">
  <TBODY>
  <TR>
    <TD>
      <TABLE cellSpacing="0" cellPadding="3" width="100%" border="0">
        <TBODY>
        <TR>
          <Td class=errorHeader><%=XSSUtil.encodeForHTMLAttribute(context, ComponentsUtil.i18nStringNow("emxComponents.Error.Header",request.getHeader("Accept-Language")))%></TH></TR>
        <TR>
          <TD class=errorMessage><%=XSSUtil.encodeForHTMLAttribute(context, exception.toString())%></TD>
        </TR>
        </TBODY>
      </TABLE>
    </TD>
   </TR>
  </TBODY>
 </TABLE>

<br/>

<%
}
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

<%
  // remove the error message if it was in the session
  session.removeValue("error.message");
%>

