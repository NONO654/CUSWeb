<%--  emxRouteActionRequiredProcess.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteActionRequiredProcess.jsp.rca 1.9 Wed Oct 22 16:17:49 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>


<%--      Content begins here    --%>

<%

  DomainRelationship routeNode = null;

  String sAttParallelNodeProcessionRule = Framework.getPropertyValue(session, "attribute_ParallelNodeProcessionRule");

  String sourcePage  = emxGetParameter(request,"sourcePage");

  String sRadioNames = emxGetParameter(request, "radioNames");
  String sRouteNodeSecs = emxGetParameter(request, "routeNodeSecs" );
  String portalMode  = emxGetParameter(request,"portalMode");

  StringTokenizer sTokNodeSecs = new StringTokenizer(sRouteNodeSecs, "|");
  StringTokenizer sTokRadioNames = new StringTokenizer(sRadioNames, "|");

  while(sTokRadioNames.hasMoreElements()) {
    String sRadioValue = emxGetParameter(request, sTokRadioNames.nextToken().trim());
    String sNodeIds[] = emxGetParameterValues(request, sTokNodeSecs.nextToken().trim());
    for(int i=0; i <sNodeIds.length; i++){
      String sRouteNodeId = sNodeIds[i];

      routeNode = DomainRelationship.newInstance(context,sRouteNodeId);

      routeNode.setAttributeValue(context,sAttParallelNodeProcessionRule,sRadioValue);

    }
  }

  if (sourcePage.equals("EditAllTasks")) {
%>
    <html>
    <body>
    <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />    
    <script language="javascript">
      parent.window.getWindowOpener().location.reload();
      window.closeWindow();
    </script>
    </body>
    </html>
<%
  } else {
                context.shutdown();
%>
    <jsp:forward page="emxRouteOptionsDialogFS.jsp">
      <jsp:param name ="portalMode" value ="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />
    </jsp:forward>
<%
  }
%>
