<%--
 error page.

 This file was originally cloned from components/emxComponentError.jsp

 (c) Dassault Systemes, 2007, 2008
--%>
<%@ page import = "matrix.db.*,matrix.util.*,com.matrixone.servlet.* " isErrorPage="true"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxI18NMethods.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
    //if null exception object, create one to display
    if ( request.getParameter("ErrorMessage") != null )
    {
      exception = new Exception(request.getParameter("ErrorMessage"));
    }

    if (exception == null) {
       exception = new Exception("\"Exception Unavailable\"");
    }
%>

<jsp:include page = "emxMQLNotice.jsp" flush="true" />

<img src="../common/images/utilSpacer.gif" width=1 height=8>
<TABLE cellSpacing=0 cellPadding=1 width="95%" border=0 align=center>
  <TBODY>
  <TR>
    <TD>
      <TABLE cellSpacing=0 cellPadding=3 width="100%" border=0>
        <TBODY>
        <TR>
          <Td class=errorHeader><%=i18nStringNow("emxComponents.Error.Header",request.getHeader("Accept-Language"))%></TH></TR>
        <TR>
          <TD class=errorMessage><%=exception.toString()%></TD>
        </TR>
        </TBODY>
      </TABLE>
    </TD>
   </TR>
  </TBODY>
 </TABLE>

<br>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

<%
  // remove the error message if it was in the session
  session.removeValue("error.message");
%>
<%!
  // Call this method to internationalize variables in java.
  // i18nStringNow("stringid", request.getHeader("Accept-Language"));
  static public String i18nStringNow(String sText,String sLanguage)
  {
    i18nNow loc = new i18nNow();
    return (String) loc.GetString("emxComponentsStringResource", sLanguage, sText);
  }
%>

