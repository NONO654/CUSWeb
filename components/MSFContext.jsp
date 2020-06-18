<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@page import="java.util.* "%>
<%@page import="matrix.util.* "%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ page import="matrix.db.*" %>
<%@ page import="com.matrixone.servlet.*" %>


<%
		System.out.println("MSFContext");
		
		String objectId =  request.getParameter("objectId");
		
		System.out.println("objectId : " + objectId);
			
		System.out.println(context.getUser());
		
		response.sendRedirect("emxLaunch3DLiveExamine.jsp?objectId=" + objectId);
		
%>
