<%-- (c) Dassault Systemes, 2008 --%>
<%--

--%>

<%@ include file = "../common/emxNavigatorInclude.inc" %>
<%
  String action = emxGetParameter(request, "mxRootAction");
  String message = emxGetParameter(request, "mxRootMessage");

  StringBuilder xmlBuf = new StringBuilder().
     append("<mxRoot>");

  if (action != null)
  {
      xmlBuf.append("<action><![CDATA[").
          append(action).
          append("]]></action>");
  }
  
  if (message != null)
  {
      xmlBuf.append("<message><![CDATA[").
          append(message).
          append("]]></message>");
  }
  
  xmlBuf.append("</mxRoot>");
    
  out.clear();
  response.setContentType("text/xml; charset=UTF-8");
%>
<%= xmlBuf.toString() %>
