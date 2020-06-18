<%@ page import = "matrix.db.*, matrix.util.* , com.matrixone.servlet.*, java.util.*,
                   java.io.BufferedReader, java.io.StringReader" %>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>                   
<%
	response.setHeader("Content-Type", "text/html; charset=UTF-8");
    response.setContentType("text/html; charset=UTF-8");
	
	Context context = Framework.getContext(session);
	String xml = "";
	String filter = "";
	
	if (context != null)
	{
		Enumeration itr = request.getParameterNames(); 
		while(itr.hasMoreElements())
		{ 
			String paramName = (String)itr.nextElement(); 

			if (paramName.startsWith("type_ahead"))
			{
				filter = request.getParameter(paramName);
				break;
			} 
		} 
	
		String program = request.getParameter("program");
		String function = request.getParameter("function");
		String form = request.getParameter("form");
		String field = request.getParameter("field");
		String language = request.getHeader("Accept-Language");
		
		try
		{
			HashMap map = new HashMap();
			map.put("form", form);
			map.put("field", field);
			map.put("language", language);
			FrameworkUtil.validateMethodBeforeInvoke(context, program, function, "Program");
			xml = (String) JPO.invoke(context, program, JPO.packArgs(map), function, JPO.packArgs(filter), String.class);
		}
		catch (Exception e)
		{
			throw (new JspException(e));
		}
	}
//XSSOK%>
<%= xml.trim() %>
