<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<html>	

	<head>
		<title></title>
		
	</head>
	
	
	<body>
	<%
		try {
			String displyVal = emxGetParameter(request,"displayExpression");
			String actualVal = emxGetParameter(request,"actualExpression");
			
			
			%>
			<script language="javascript">
				// Get Filter values
				var displyValue = "<%=XSSUtil.encodeForJavaScript(context,displyVal)%>";
				var actualValue = "<%=XSSUtil.encodeForJavaScript(context,actualVal)%>";
				var urlParams = "mode=getBinary&effExpr="+actualValue+"&filterMode=filter";
				var oidValue = emxUICore.getDataPost("../effectivity/EffectivityUtil.jsp", urlParams);
				
				// Set Filter values
				var topWindow = top.opener.top;
				var vFrame = topWindow.findFrame(topWindow, "CPVExpandMBOMCmd");
				if (vFrame == null)
					vFrame = topWindow.findFrame(topWindow, "detailsDisplay");
				
				if (vFrame != null) {
					vFrame.setCfgFitlerValues(topWindow, "CPVCfgFilterDynamicInput", false, displyValue, actualValue, oidValue);
					vFrame.setCfgFitlerValues(topWindow, "CPVCfgFilterPredefInput" ,  true, "", "", "");
				}
				
				// Close the popup (EffectivityDlg) window
				top.location.href = "../common/emxCloseWindow.jsp";
			</script>
			<%

		}
		catch (Exception e)
		{
			session.putValue("error.message", e.toString());
		}
		%>
	</body>
	
	<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
	
</html>
