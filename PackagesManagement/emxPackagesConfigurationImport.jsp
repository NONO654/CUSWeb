<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<head>
	<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
	<link rel="stylesheet" type="text/css" href="../common/styles/emxUIForm.css">	
	<%
		/* String ImportTitle = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.PackageImportFile");
		String SubmitTitle = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.PackageImportFileSubmit");
		String ErrorImportFile = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.Msg.PackageImportFileSubmitBadFile"); */
		String ImportTitle = EnoviaResourceBundle.getProperty(context,"emxPackagesManagementStringResource",context.getLocale(),"emxPackagesManagement.label.PackageImportFile");
		String SubmitTitle = EnoviaResourceBundle.getProperty(context,"emxPackagesManagementStringResource",context.getLocale(),"emxPackagesManagement.label.PackageImportFileSubmit");
		String ErrorImportFile = EnoviaResourceBundle.getProperty(context,"emxPackagesManagementStringResource",context.getLocale(),"emxPackagesManagement.Msg.PackageImportFileSubmitBadFile");
		String headerWarning = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Commom.RequiredText");
		String importingWaitMsg = EnoviaResourceBundle.getProperty(context,"emxPackagesManagementStringResource",context.getLocale(),"emxPackagesManagement.label.ImportingPleaseWait");
	%>
</head>
<BODY > 
	<FORM  name=ImportForm ENCTYPE="multipart/form-data" ACTION="emxPackagesConfigurationImportProcess.jsp" METHOD=POST>
		<table width="100%" border="4" cellspacing="25" >
			<tr><td class="requiredNotice" ><%=headerWarning%> </td></tr>
			<tr>
				<td class="labelRequired" ><%=ImportTitle%> <br> <INPUT NAME="ImportFile" TYPE="file" SIZE="40" ></td>
			</tr>
		</table>
		<p id="ImportLoading" hidden=true>
			<b><%=importingWaitMsg%></b>
			<img  src="../common/images/utilProgressGray.gif">
		</p>
	</FORM>
</BODY>
</html>
<script language="javascript" type="text/javaScript">
    function isAuthorizedFile(filename) 
    {
        var regex = new RegExp("^\\s*\\S.+\\.(metadata|zip)$", "i");
		/*if (regex.test(filename))
			return true;
        regex = new RegExp("^\\s*\\S.+\\.zip$", "i");*/
		if (regex.test(filename))
			return true;
		else
			return false;
	}
	function submitForm()
	{
		var selectedFile = ImportForm.ImportFile.value;
		var loadingElement = document.getElementById("ImportLoading");
		if (isAuthorizedFile(selectedFile)) {
			if(loadingElement!=null){
				loadingElement.hidden=false;
			}
			ImportForm.submit();
		}
		else {
			alert ("<%=ErrorImportFile%>");
		}
	}

</script>
