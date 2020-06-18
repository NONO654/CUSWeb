<%--  emxIntegrations.jsp

   Copyright (c) 1992-2008 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /web/integrations/emxIntegrations.jsp 1.1 Wed Jul 16 04:54:09 2008 GMT ds-kmahajan Experimental$
--%>
<%@page import="java.util.ResourceBundle"%>
<%@ page import="java.util.*,javax.servlet.*" %> 
<%@ page import="com.matrixone.apps.framework.*, com.matrixone.servlet.*,com.matrixone.MCADIntegration.server.cache.*,com.matrixone.MCADIntegration.utils.*, com.matrixone.apps.domain.util.*,matrix.db.*,com.matrixone.MCADIntegration.server.beans.*" %> 
<%@ page import="com.matrixone.apps.domain.util.PropertyUtil,com.matrixone.apps.framework.ui.UIMenu,com.matrixone.apps.framework.ui.UIComponent,com.matrixone.apps.domain.util.FrameworkProperties" %>


<html>
<%

String s1= System.getenv("PodDefinitionName");
	Context context	= Framework.getFrameContext(session);
	boolean bEnableAppletFreeUI = MCADMxUtil.IsAppletFreeUI(context);
%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script>	
function getIntegrationFrame(win)
{
	var hldrIntegrationFrame = null;
	var obj = win.getTopWindow();
	if(obj.integrationsFrame != null && obj.integrationsFrame.eiepIntegration != null)
	{
		//Current window has Integration frame.
		hldrIntegrationFrame = obj.integrationsFrame.eiepIntegration;
	}
	else if(obj.opener != null && !obj.opener.closed)
	{
		//Looking in opener...
		hldrIntegrationFrame = getIntegrationFrame(obj.opener);
	}

	return hldrIntegrationFrame;		
}
var integrationFrame = null;
integrationFrame	 = getIntegrationFrame(this);
var cloudLicenseEnvValue = "<%=s1%>";
var vJspName = "ief.jsp";

var vShowAppletFreeUI = "<%=bEnableAppletFreeUI%>";

if(vShowAppletFreeUI == "true"){
vJspName = "initializeIEF.jsp";
}

if(cloudLicenseEnvValue!="null")
vJspName = "";
</script>
<title>blank Document</title>
<script>
if(integrationFrame == null)
{
	document.write("<frameset rows=\"0,0\" name=\"integrationsFrameset\" frameborder=\"no\" border=\"0\" framespacing=\"0\">");
	document.write("<frame name=\"eiepIntegration\" noresize  src="+vJspName+" scrolling=\"no\" marginheight=\"0\" marginwidth=\"0\" frameborder=\"0\"/>");
	document.write("</frameset>");
}
</script>
<body>
</body>
</html>
