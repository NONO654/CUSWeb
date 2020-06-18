<%--
  (c) Dassault Systemes, 2007, 2008

  This JSP page is invoked from the smaJobTable.jsp to query the status
  of the SIMULATION at some specified interval to update the table
  content.
--%>
<%@page import="java.util.HashMap"%>
<%@page import = "java.util.Calendar"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%
    //
    // - Query the status of the SIMULATION
    //
    String  scObjectId = emxGetParameter(request, "objectId");
    String  scRunType  = emxGetParameter(request, "runType");

    String [] azArg    = {scObjectId,scRunType };
    String    scStatus = (String)JPO.invoke(
                               context, "jpo.simulation.SIMULATIONS",
                               null, "getRefreshData", azArg, String.class);
    long timeStart = Calendar.getInstance().getTimeInMillis();
    scStatus = scStatus + "###" + timeStart;
%>
<%=scStatus%>
