<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<html>
		
	<head>
		<title></title>
		
	</head>
	
	
	<body>
	<%
		try 
		{
			// Identify frameWindow from where the Refinement is clicked
			String sFrmPortalCmdName = emxGetParameter(request,"portalCmdName");
			if (sFrmPortalCmdName==null || sFrmPortalCmdName.isEmpty())
				sFrmPortalCmdName = "detailsDisplay"; // If it is from other than portalPages like WhereUsed, etc
			
			// Now do the action of Submit or Clear
			String mode = emxGetParameter(request,"CPVFilterMode");
			%>
				<script language="javascript">
				
					var filterAction = "<%=XSSUtil.encodeForJavaScript(context, mode)%>";
					var portalCmdName= "<%=XSSUtil.encodeForJavaScript(context, sFrmPortalCmdName)%>";
					var vFrameWindow = top.findFrame(top, portalCmdName);
					
					if (vFrameWindow!=null)
					{
						if (filterAction === "submitCPVFilter")
						{
							vFrameWindow.filterPage();
						} 
				
						if (filterAction === "clearCPVFilter") 
						{				
							vFrameWindow.setCfgFitlerValues(top, "CPVCfgFilterPredefInput" , false, "", "", "");
							//vFrameWindow.setCfgFitlerValues(top, "CPVCfgFilterDynamicInput", false, "", "", "");
						}
					}
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
