<%--  emxNavigatorSideDoorInclude.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxNavigatorSideDoorInclude.inc.rca 1.7 Wed Oct 22 15:48:06 2008 przemek Experimental przemek $
--%>


<%
String fromext = (String) request.getParameter("fromExt");
if(fromext != null && "true".equalsIgnoreCase(fromext)){	
	String strReqURL = request.getServletPath();
	if(!strReqURL.contains("emxNavigator.jsp")) {
		String strQueryStr = com.matrixone.apps.domain.util.FrameworkUtil.findAndReplace(request.getQueryString(), "fromExt=true","");

		request.removeAttribute("fromExt");
		String strURL = "";
		if ( strQueryStr != null && strQueryStr.length() > 0 )
			strURL = strReqURL + "?" + strQueryStr;
		else
			strURL = strReqURL;

		session.setAttribute("ContentURL", strURL);
		matrix.db.Context localContext = Framework.getFrameContext(session);
		try{
			if(localContext != null && !"".equals(localContext.getUser())){
				if(strURL.indexOf("bpsWidget.jsp") > -1 || strURL.indexOf("emxENOCollabSpaceMain.jsp") > -1){
					String isFromIFWE = (String) request.getParameter("fromIFWE");
					if(isFromIFWE != null && "true".equalsIgnoreCase(isFromIFWE)){
						response.sendRedirect("../common/emxNavigator.jsp?fromIFWE=true");
				}else{
						response.sendRedirect("../common/emxNavigator.jsp");
					}				}else{
					request.getRequestDispatcher("emxNavigator.jsp").forward(request, response);	
				}
			}else{			
				//response.sendRedirect("../emxLogin.jsp");
				String strRequestURL2 = "../emxLogin.jsp";
				String strFullURL2 = "";
				if ( strQueryStr != null && strQueryStr.length() > 0 )
				{
					strFullURL2 = strRequestURL2 + "?" + strQueryStr;
				}
				else
				{
					strFullURL2 = strRequestURL2;
				}
				response.sendRedirect(strFullURL2);
				//session.setAttribute("ForwardURL", strFullURL2);
			}
		}finally{
			if(localContext != null)
			{
			localContext.shutdown();
			}
		}

	}	
}
%>
