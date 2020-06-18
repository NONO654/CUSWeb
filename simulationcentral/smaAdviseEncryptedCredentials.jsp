<%--  
 * (c) Dassault Systemes, 2013
 *  
--%>
<%@page import = "java.util.*"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "matrix.db.JPO"%>
<%@page import = "matrix.util.MatrixException"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%
   matrix.db.Context context2 = 
    (matrix.db.Context)request.getAttribute("context");
   if (context2 != null)
    context = context2;
   String pubKey = emxGetParameter(request, "pubKey");
   String loginTicket = emxGetParameter(request, "loginTicket");
   HashMap paramMap = new HashMap();
   HashMap programMap = new HashMap();

   paramMap.put("pubKey",pubKey);
   paramMap.put("loginTicket",loginTicket);
   programMap.put("paramMap",paramMap);
   
   String[] methodargs = JPO.packArgs(programMap);
   
   String retStr = (String) JPO.invoke(context, "jpo.simulation.Job", null, 
            "processAdviseCredentials",methodargs, String.class);
   out.clear();
   response.setContentType("text/xml; charset=UTF-8");	   
%>
<%=retStr%>
