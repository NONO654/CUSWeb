<%--  emxPackagesConfigurationPortalProxy.jsp   -   page for Data Customization tool
   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
   Wk40 2011 - JPI - Creation - 
--%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.HashMap"%>
<%@ page import = "java.util.Set" %>
<%@ page import = "matrix.db.*" %>
<%@include file = "../emxUIFramesetUtil.inc"%>


<%
// System.out.println("Session Id = " + session.getId() + " created on " + session.getCreationTime() + " IsNew :" + session.isNew());
    String sCacheIndex = "DataCustoCacheIndex";
	String CacheIndexStr = (String)session.getAttribute(sCacheIndex);
	System.out.println("CacheIndex = " + CacheIndexStr);
	if (CacheIndexStr == null ) { // first time, set it to 0
		session.setAttribute(sCacheIndex, "0");
	}	
	CacheIndexStr = (String)session.getAttribute(sCacheIndex);	
// redirect the URL    
	StringBuffer url = new StringBuffer(200);
	url.append("../common/emxPortal.jsp?");
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    	Iterator keyItr = requestMap.keySet().iterator();
    	while (keyItr.hasNext()) {
    		String key = (String) keyItr.next();
    		url.append("&");
    		url.append(key);
    		url.append("=");
    		url.append(requestMap.get(key)); 
    	}
		//System.out.println("URL =" + url.toString());
	response.sendRedirect(url.toString());

%>
