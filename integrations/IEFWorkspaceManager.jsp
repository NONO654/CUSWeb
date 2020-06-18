 <%--  IEFWorkspaceManager.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

  <%@ page import="java.io.PrintWriter" %>
  <%@ page import="java.util.Enumeration" %>
  <%@ page import="javax.servlet.http.Cookie"%>
 
  <%@ page import="com.matrixone.servlet.Framework"%>
  <%@ page import="com.matrixone.MCADIntegration.utils.MCADUrlUtil"%>
  
  
  <%
	try
	{
		String initialDirectory = request.getParameter("initialDirectory");
    	String initialFolderId = request.getParameter("initialFolderId");

    	session.putValue("initialDirectory", initialDirectory);
    	session.putValue("initialFolderId", initialFolderId);
		
		session.putValue("forwardToLWSM", "true");
		
		String sProtocol, sPort, sHost, sCtxPath, sRealURL;

		//check for forwarded first
		sProtocol = request.getHeader("X-Forwarded-Proto");
		sPort     = request.getHeader("X-Forwarded-Port");
		sHost     = request.getHeader("X-Forwarded-Host");

		//if not forwarded use regular
		if (sProtocol == null)
		{
			sProtocol = request.getScheme();
		}
		if (sPort == null)
		{
			sPort = "" + request.getLocalPort();
		}
		if (sHost == null)
		{
			sHost = request.getServerName();
		}
		else
		{ //port sometimes comes thru in the X-Forwarded-Host, so clean up
			int portIndex = sHost.indexOf(':');
			if (portIndex != -1) 
			{
				 sPort = sHost.substring(portIndex + 1);
				 sHost = sHost.substring(0, portIndex);
			}
		}
		//standard context path and querystring
		sCtxPath = request.getContextPath();
		sRealURL = sProtocol + "://" + sHost;
		if (sPort.length() > 0) 
		{
			sRealURL += ":"+ sPort;
		}
		sRealURL += sCtxPath;
		String sForward =  sRealURL + "/common/emxNavigator.jsp?appName=ENOXCAD_AP";
		response.sendRedirect(sForward);	
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
	  
%>
  
