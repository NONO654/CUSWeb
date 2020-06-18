<%--  emxEngrCloseWindowProcess.jsp  -  Process page to close the SearchResults Page
                                          based on property from properties file
   Copyright (c) 1992-2017 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

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
  //XSSOK
  var url =  "../common/emxTree.jsp?AppendParameters=true&objectId=<%=XSSUtil.encodeForJavaScript(context,oid)%>&emxSuiteDirectory=<%=XSSUtil.encodeForJavaScript(context,emxSuiteDirectory)%>"; ;
  //var contentFrameObj = getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
  // modified for 017436
  var contentFrameObj = getTopWindow().openerFindFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
  contentFrameObj.document.location.href= url;
<%
  if(!"Show Search".equalsIgnoreCase(CloseSearchResultsOnNameClick))
  {
    if("Close Window".equalsIgnoreCase(CloseSearchResultsOnNameClick))
    {
%>
      // Close search results.
      getTopWindow().closeWindow();
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
