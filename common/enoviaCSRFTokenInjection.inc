<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!-- //XSSOK -->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!-- //XSSOK -->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}

%>
