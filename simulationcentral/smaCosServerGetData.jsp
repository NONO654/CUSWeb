<%-- (c) Dassault Systemes, 2010 --%>
<%--
  trying to display on the link on the RHS
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import = "matrix.db.*, matrix.util.*"%>
<%@page import="matrix.db.Context" %>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<html>
<%
	String sError =  SimulationUtil.getI18NString(context,
        "smaSimulationCentral.StationAdmin.HasMoved" );
        emxNavErrorObject.addMessage(sError);

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</html>
		


