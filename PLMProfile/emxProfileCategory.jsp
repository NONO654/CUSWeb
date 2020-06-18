<%@include file="../common/emxNavigatorInclude.inc"%>

<%
	System.out.println("START emxProfileCategory.jsp");
	HashMap requestMap 		= UINavigatorUtil.getRequestParameterMap(request);
	JPO.invoke(context, "emxProfileCheck", null, "loadStructureCategory", JPO.packArgs(requestMap));
	System.out.println("END emxProfileCategory.jsp");
%>
