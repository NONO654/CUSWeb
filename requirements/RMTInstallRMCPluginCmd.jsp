<%-- @fullreview DJH OEP 12:12:05 Creation for R2014HL V6 Installer Support For RMC --%>

<%@ page import="java.io.*" %>
<%@ page import="com.matrixone.apps.requirements.*" %>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>  


<%
		String is32Bit = "false";//emxGetParameter(request,"is32Bit"); 		
		String packagePath = "ENOVIA_RMCInstaller.zip"; //InstallRMCClient.DownloadRMCMedia(Boolean.parseBoolean(is32Bit), request);
		// System.out.println("Package Path Received = " + packagePath);
		String ZipURL = XSSUtil.encodeForJavaScript(context, packagePath);
		
%>
<html>
<head>
<script type="text/javascript">

function OpenNewWindow()
{
	if ("<%=ZipURL%>" != "")
	{
		window.location = "<%=ZipURL%>";
	}
	else
	{
		alert("<emxUtil:i18n  localize='i18nId'>emxFramework.DownloadMOF.PackageNotFound</emxUtil:i18n>");
		closeMe();
	}
}

var howLong = 1000;

function closeMe(){
	setTimeout("self.close()",howLong);
}

    </script>
</head>
<BODY onload="javascript:OpenNewWindow();">

</body>
</html>
