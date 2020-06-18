<%--  emxEngrCloseWindowProcess.jsp  -  Process page to close the SearchResults Page
                                          based on property fro properties file
  (c) Dassault Systemes, 1993-2016.  All rights reserved.
--%>

<%@ include file  ="../emxUIFramesetUtil.inc"%>
<%@include file  ="emxCPCInclude.inc"%>
<%
  String emxSuiteDirectory = emxGetParameter(request, "emxSuiteDirectory");
  String oid = emxGetParameter(request, "objectId");

  String CloseSearchResultsOnNameClick = JSPUtil.getCentralProperty(application,session,"emxFramework","Search.OnSelect.Action");
  if (CloseSearchResultsOnNameClick == null || CloseSearchResultsOnNameClick.equals("null")) {
    CloseSearchResultsOnNameClick = "";
  }
  CloseSearchResultsOnNameClick = CloseSearchResultsOnNameClick.trim();
%>

<script language="Javascript">

  var url =  "../common/emxTree.jsp?AppendParameters=true&objectId=<xss:encodeForJavaScript><%=oid%></xss:encodeForJavaScript>&emxSuiteDirectory=<xss:encodeForJavaScript><%=emxSuiteDirectory%></xss:encodeForJavaScript>"; ;
  var contentFrameObj = getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
  contentFrameObj.document.location.href= url;
<%
  if(!"Show Search".equalsIgnoreCase(CloseSearchResultsOnNameClick))
  {
    if("Close Window".equalsIgnoreCase(CloseSearchResultsOnNameClick))
    {
%>
      // Close search results.
      getTopWindow().window.close();
<%
    } else {
%>
      // Show Content Frame, minimize the search results.
      contentFrameObj.window.focus();
<%
    }
  }
%>
</script>
