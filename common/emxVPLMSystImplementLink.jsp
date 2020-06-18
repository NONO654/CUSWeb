<%--  emxVPLMImplementLink.jsp   -   FS page for Create CAD Drawing dialog
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxVPLMImplementLink.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $
--%>

<%@ page import = "java.util.HashMap" %>
<%@ page import = "matrix.db.*" %>

<%@include file="../emxUIFramesetUtil.inc"%>
 
 <HEAD> 
 <%@include  file="../emxUICommonHeaderBeginInclude.inc"%> 
  </HEAD> 

<%
    framesetObject fs = new framesetObject();

	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	String role = (String) requestMap.get("role");
	if (role == null) role = (String) session.getAttribute("role");
	String lang = (String)context.getSession().getLanguage();
	
	Iterator keyItr = requestMap.keySet().iterator();
if (role != null) {
	StringBuffer url = new StringBuffer("");
	url.append("emxNavigator.jsp?");

	while (keyItr.hasNext()) {
		String key = (String) keyItr.next();
		if (key.equals("objectId")){
			HashMap programMap = new HashMap();
			programMap.put("systemId", requestMap.get(key));
			programMap.put("returnId", "true");
			String[] methodargs =JPO.packArgs(programMap);				
			Object processIdArray = JPO.invoke(context, "emxVPLMtypPLMSystemDSExpand",null,"getImplementedProcess", methodargs, Object.class);
			if (processIdArray!=null){
				String temp = processIdArray.toString();
				String processId = temp.substring(1,temp.length()-1);
				url.append("objectId=");
				url.append(processId.toString()); 
			}
		}
	}

	session.setAttribute("role", role);
	try {
		RequestDispatcher rd = request.getRequestDispatcher(url.toString());
		rd.forward(request, response);
	}
	catch (Exception e) {
		e.printStackTrace();
	}
}

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>

