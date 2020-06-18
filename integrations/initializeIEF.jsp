<%-- ief.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@ page import="java.util.*,javax.servlet.*" %> 
<%@ page import="com.matrixone.apps.framework.*, com.matrixone.servlet.*,com.matrixone.MCADIntegration.server.cache.*,com.matrixone.MCADIntegration.utils.*, com.matrixone.apps.domain.util.*,matrix.db.*,com.matrixone.MCADIntegration.server.beans.*" %> 
<%@ page import="com.matrixone.apps.domain.util.PropertyUtil,com.matrixone.apps.framework.ui.UIMenu,com.matrixone.apps.framework.ui.UIComponent,com.matrixone.apps.domain.util.FrameworkProperties" %>



<html>

<head>

<script language="JavaScript">
</script>

</head>

<body>

<%

	//System.out.println("Entering NEW init jsp..");
	Context context	= Framework.getFrameContext(session);
	//System.out.println("ENDIng NEW Jsp..");

	ServletContext scObj = session.getServletContext();
					
	Hashtable htData = new Hashtable();
	htData.put("ServletContext", scObj);
	//htData.put("ctxtfromsession", secondaryContext);

	//System.out.println("ENDIng NEW Jsp.htData."+htData);

	MCADMxUtil.initializeDEC(context, request, response, session,htData);
	//System.out.println("NEW init JSP .. calling initializeDEC method...");
%>

</body>
</html>

