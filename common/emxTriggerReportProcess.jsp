<%--  emxTriggerReportProcess.jsp  -   This is an intermediate page to append header values.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTriggerReportProcess.jsp.rca 1.1.5.4 Wed Oct 22 15:48:08 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%
    String strLanguage  = request.getHeader("Accept-Language");
    String header       = XSSUtil.encodeForHTMLAttribute(context, emxGetParameter(request, "header").trim());
    String subHeader    = XSSUtil.encodeForHTMLAttribute(context, emxGetParameter(request, "subHeader").trim());
    StringBuffer strBuf = new StringBuffer();
    strBuf.append(UINavigatorUtil.getI18nString(header, "emxFrameworkStringResource", strLanguage));
    strBuf.append(":");
    strBuf.append(UINavigatorUtil.getI18nString(subHeader, "emxFrameworkStringResource", strLanguage));
%>
<script language="JavaScript">

function formSubmit()
{
    //XSSOK
    document.triggerForm.header.value="<%=strBuf.toString()%>";
    document.triggerForm.subHeader.value="";
    document.triggerForm.submit();
}
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>


<form name="triggerForm" action="emxIndentedTable.jsp" method="post" target="_top" >
<%
    Enumeration enumParamNames = emxGetParameterNames(request);
    String sParamName = "";
    while (enumParamNames.hasMoreElements())
    {
        sParamName = (String)enumParamNames.nextElement();
%>
        <input type="hidden" name="<xss:encodeForHTMLAttribute><%=sParamName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, sParamName)%></xss:encodeForHTMLAttribute>" />
<%
    }
%>

<SCRIPT LANGUAGE="JavaScript">
    formSubmit();
</SCRIPT>

</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
