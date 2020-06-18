<%-- emxChartHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxChartHeader.jsp.rca 1.4 Wed Oct 22 15:48:33 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<head>
        <title></title>
        <%@include file = "emxUIConstantsInclude.inc"%>
        <%@include file = "../emxStyleDefaultInclude.inc"%>
        <script type="text/javascript">
        	addStyleSheet("emxUIChannelDefault");
            addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIMenu");
        </script>

        <script language="JavaScript" src="scripts/emxUICore.js"></script>
        <script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
</head>

<body>
<form name="chartHeaderForm" method="post">
<div class="filter-row"></div>

<jsp:include page = "emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value=""/>
    <jsp:param name="helpMarker" value="false"/>
    <jsp:param name="PrinterFriendly" value="false"/>
    <jsp:param name="export" value="false"/>
    <jsp:param name="portalMode" value="true"/>
</jsp:include>
</form>
</body>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>
