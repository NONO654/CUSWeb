<html>
<%@ include file = "../emxUICommonAppInclude.inc"%>

<%@ page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<head>
	<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
	<link rel="stylesheet" type="text/css" href="../common/styles/emxUIForm.css">	
	<%
		String headerWarning = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Commom.RequiredText");
  		String CancelLabel = EnoviaResourceBundle.getProperty(context, "emxQualificationStringResource", context.getLocale(), "emxQualification.label.Cancel");
  		String SubmitLabel = EnoviaResourceBundle.getProperty(context, "emxQualificationStringResource", context.getLocale(), "emxQualification.label.Submit");
		String nlsType = EnoviaResourceBundle.getProperty(context, "emxQualificationStringResource", context.getLocale(), "emxQualification.Type");
  		String nlsExtension = EnoviaResourceBundle.getProperty(context, "emxQualificationStringResource", context.getLocale(), "emxQualification.Extension");
  		String TableHeader = EnoviaResourceBundle.getProperty(context, "emxQualificationStringResource", context.getLocale(), "emxQualification.label.AddExtensionTableHeader");
		
		// YI3 - bug correction IR-212280 
		//String objectId = emxGetParameter(request, "strfile");
		String objectId = emxGetParameter(request, "objectId");
		//System.out.println("YI3 - objectID : "+objectId);
		DomainObject BaseObject   = DomainObject.newInstance(context,objectId);
		BaseObject.setId(objectId);
		String strType = (String)BaseObject.getInfo(context,BaseObject.SELECT_TYPE);
		String typeNls = EnoviaResourceBundle.getTypeI18NString(context,strType,context.getLocale().getLanguage());
		if(!typeNls.isEmpty() && !typeNls.contains("emxFramework")){
			strType = typeNls;
		}
		/*Enumeration eNumParameters = emxGetParameterNames(request);

		while( eNumParameters.hasMoreElements() ) {
			String parmName  = (String)eNumParameters.nextElement();
			System.out.println("YI3 - param : " + parmName + " - value : " + emxGetParameter(request, parmName));
		}*/
		
		String Url = "'../common/emxIndentedTable.jsp?table=ExtensionToAddListTable&toolbar=none&program=emxQualificationProgram:getAvailableExtensions&freezePane=extName&selection=single&suiteKey=Qualification&HelpMarker=emxhelpcustomerextlist&cancelLabel="+CancelLabel+"&submitLabel="+SubmitLabel+"&header=" + TableHeader + "&submitURL=../Qualification/emxQualificationSubmitExtensionForObject.jsp&showPageURLIcon=false&customize=false&showClipboard=false&objectCompare=false&objectId="+objectId+"'";
		
	%>
</head>
<BODY > 
	<FORM  name=AddExtForm ACTION="emxQualificationAddExtensionProcess.jsp" METHOD=POST>
		<INPUT type="hidden" name="objectId" value="<%=objectId%>">
		<table width="100%" border="4" cellspacing="25" >
			<tr><td class="requiredNotice" ><%=headerWarning%> </td></tr>
			<tr>
				<td class="labelRequired" ><%=nlsType%> <br> <INPUT NAME="typeObj" TYPE="text" SIZE="20" VALUE="<%=strType%>" readonly></td>
			</tr>
			<tr>
				<td class="labelRequired" ><%=nlsExtension%> <br><INPUT NAME="extension" TYPE="hidden" SIZE="20" readonly><INPUT NAME="extension_display" TYPE="text" SIZE="20" readonly><INPUT NAME="selectExt" TYPE="button" VALUE="..." OnClick="javascript:window.open(<%=Url%>, 'extensionAttribute', 'height=500, width=1200, top=200, left=200, toolbar=no, menubar=no, location=no, resizable=yes, scrollbars=no, status=no'); return false;" ></td>
			</tr>
		</table>
	</FORM>
</BODY>
</html>
<script language="javascript" type="text/javaScript">

	function submitForm()
	{
		AddExtForm.submit();
	}

</script>

