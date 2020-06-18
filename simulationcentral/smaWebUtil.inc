<%-- (c) Dassault Systemes, 2010 --%>
<%--
  SCE JSP utility code.
--%>

<%@page import="com.dassault_systemes.smaslm.matrix.web.URLBuilder"%>
<%@page import="javax.servlet.http.HttpServletRequest"%>

<%!

/**
 * @param request The {@link javax.servlet.http.HttpServletRequest}.
 * @return A new {@link com.dassault_systemes.smaslm.matrix.web.URLBuilder}
 * with a default capacity and encoding based on the specified
 * {@link javax.servlet.http.HttpServletRequest}.
 */
public static URLBuilder getURLBuilder(HttpServletRequest request)
{
     /* allocate a buffer roughly large enough to hold the current
      * request, excluding the query string
      */
    return new URLBuilder(
        request.getRequestURI().length(),
        request.getCharacterEncoding());
}

%>
