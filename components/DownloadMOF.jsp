
<%@ page import="java.io.*" %>
<%@ page import="com.enovia.smarteam.smb.*" %>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>


<%
		String isHotfix = emxGetParameter(request,"isHotfix");

		String packagePath = CreateMOFClientPackage.DownloadMSFMedia(Boolean.parseBoolean(isHotfix), request);

		String ZipURL = packagePath;
		
%>
<HTML>
<HEAD>
<script type="text/javascript">

function OpenNewWindow()
{
	if ("<%=ZipURL%>" != "")
	{
		window.open("<%=ZipURL%>", "Download","status=1,toolbar=1");
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
</HEAD>
<BODY onload="javascript:OpenNewWindow();">

</BODY>
</HTML>
