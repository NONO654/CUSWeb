<%--  emxDynamicAttributes.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@include file = "/emxRequestWrapperMethods.inc"%>
<% 
 	StringBuffer contentURL = new StringBuffer(100);
	contentURL.append("emxForm.jsp?form=AEFDynamicAttributesForm&Export=false");	
	Enumeration enumParamNames = request.getParameterNames();
	while (enumParamNames.hasMoreElements())
	{
	String paramName = (String) enumParamNames.nextElement();
	String paramValue = request.getParameter(paramName);
		if(paramValue != null && !"null".equals(paramValue) && !"".equals(paramValue)) {
			contentURL.append("&" + paramName + "=");  
    		contentURL.append(XSSUtil.encodeForURL(paramValue));
		}
  }

    String forwardUrl = contentURL.toString();

%> 
	<!-- //XSSOK -->
    <jsp:forward page="<%=forwardUrl%>"/>
