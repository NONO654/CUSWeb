<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Frameset page for the Impact Graph.
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<html>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ImpactGraphUI"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.ImpactUtil"%>

<%@page import="matrix.db.JPO" %>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
    String objectId = emxGetParameter(request, "objectId");
    ImpactUtil.checkInputRelationships(context, objectId);
%>

<head>
</head>
<body >
</body>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>

