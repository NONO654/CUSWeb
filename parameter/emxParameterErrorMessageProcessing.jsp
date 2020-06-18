<%@page	import="com.dassault_systemes.parameter_modeler.PlmParameterPrivateServices"%>
<%@page import="java.net.URLDecoder"%>

<%
	String key = emxGetParameter(request, "key");

	response.setContentType("text/xml");
	response.setContentType("charset=UTF-8");
	response.setHeader("Content-Type", "text/xml");
	response.setHeader("Cache-Control", "no-cache");
	response.getWriter().write("<?xml version='1.0' encoding='UTF-8'?>");
%>

<%@include file="../common/emxNavigatorNoDocTypeInclude.inc"%>


<%
	try
	{
		if (!key.isEmpty())
		{
			String language = context.getSession().getLanguage();
			if (language != null && !language.isEmpty())
			{
				String error = EnoviaResourceBundle.getProperty(context, PlmParameterPrivateServices.stringResourceFile, new Locale(language), key);
				if (error != null && !error.isEmpty())
				{
					String xmlReturn = "<root><error>" + error + "</error></root>";
					response.getWriter().write(xmlReturn);
				}
			}
		}
	}
	catch (Exception e)
	{
		e.printStackTrace();
		throw e;
	}
%>
