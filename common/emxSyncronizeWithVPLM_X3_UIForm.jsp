<%-- @quickreview SBM1 17:09:25 : IR-550969-3DEXPERIENCER2018x Fix to prevent XSS attacks --%>
<%-- @quickreview VKY 19:01:23 : IR-656495 Get the NLS Type Name from emxFrameworkStringResource and use it to display in the dialog --%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page	import="com.matrixone.apps.domain.DomainObject"%>

<html>

	<head>
		<title></title>

		<script language="javascript">
			addStyleSheet("emxUIDefault","../common/styles/");
			addStyleSheet("emxUIForm","../common/styles/");
		</script>
	</head>

	<%
  	String sProdID = emxGetParameter(request, "id");
		String nlsTypeName = "";
		try {
			DomainObject obj = new DomainObject(sProdID);
			obj.open(context);
			String sTypeName = obj.getType(context);
			nlsTypeName = UINavigatorUtil.getI18nString("emxFramework.Type." + sTypeName.replace(" ","_"), "emxFrameworkStringResource", request.getHeader("Accept-Language"));
		} catch(FrameworkException e) { }
		String targetLocation = emxGetParameter(request, "targetLocation");	
  	String mode = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.Mode", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
		String Product = nlsTypeName;
  	//String Product = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.InputProduct", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
		String prodConfLog = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.ConfLogicalGBOM", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  %>
  
	<body>
		<form name="frmSync" method="post" action="../common/emxSyncronizeWithVPLM_X3.jsp?objectId=<%=XSSUtil.encodeForURL(context,sProdID)%>&targetLocation=<%=XSSUtil.encodeForURL(context,targetLocation)%>">
			<table>

				<tr>
					<td class="inputField">
						<input type="CheckBox" name="chkProduct" value="Product" checked disabled><%=Product%>
						<br>
						<input type="CheckBox" name="chkCLF" value="ProdConfLog" checked disabled><%=prodConfLog%>
					</td> 
				</tr>
			</table>
		</form>
	</body>
</html>
