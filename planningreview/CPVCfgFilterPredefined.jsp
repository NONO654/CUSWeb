<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@ page import = "com.dassault_systemes.vplm.DELJTypeNAttServices"%>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<html>
	<head>
		<title></title>	
	</head>
	
	
	<body>
	<%
		try {
			String mode = emxGetParameter(request,"CPVFilterMode");
			
			if (mode==null || mode.isEmpty())
			{
				
			}
			else if (mode.startsWith("openPredefFilter"))
			{
				String objectId = emxGetParameter(request, "objectId");
				String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
				String fieldNameActual = emxGetParameter(request, "fieldNameActual") + "_actualValue";
				
				HashMap reqMap = indentedTableBean.getRequestMap(emxGetParameter(request,"timeStamp"));
				String sPortalCmdName = "detailsDisplay";
				if (reqMap != null) {
					objectId = (String) reqMap.get("objectId");
					sPortalCmdName = (String) reqMap.get("portalCmdName");
				}
				
				%>
				<script language="javascript" type="text/javaScript">
					var sURL = "../common/emxIndentedTable.jsp?objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&submitURL=../planningreview/CPVCfgFilterPredefined.jsp&submitAction=none&portalCmdName=<%=XSSUtil.encodeForURL(context,sPortalCmdName)%>&CPVFilterMode=choosenPredefFilter&selection=single&fieldNameActual=<%=XSSUtil.encodeForURL(context,fieldNameActual)%>&fieldNameDisplay=<%=XSSUtil.encodeForURL(context,fieldNameDisplay)%>&table=VPLMCfgConfiguration&program=DELJPlanningUtil:getAllConfigurations&CancelButton=true&cancelLabel=Cancel";
					window.location.href = sURL;
				</script>
				<%
			}
			else if (mode.startsWith("choosenPredefFilter"))
			{
				String[] emxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
				String emxTableRowId = emxTableRowIds[0];
				StringList emxTableRowIdList = FrameworkUtil.split(emxTableRowId, "|");
				if (emxTableRowIdList.size() > 0)
				{
					String sObjId = (String)emxTableRowIdList.get(0);
					String sFrmPortalCmdName = emxGetParameter(request,"portalCmdName"); // We expect valid portalCmdName from caller
					Hashtable attValues = DELJTypeNAttServices.getVPLMObjectAttValues(context, sObjId);
					String sObjName = (String) attValues.get("PLM_ExternalID");
					
					%>
					<script language="javascript" type="text/javaScript">
						// Get Filter values
						
						var displyValue = "<%=XSSUtil.encodeForJavaScript(context, sObjName)%>";
						var actualValue = "<%=XSSUtil.encodeForJavaScript(context, sObjId)%>";
						var oidValue = "";
						
						// Set Filter values
						var topWindow = top.opener.top;
						var frameWndw = topWindow.findFrame(topWindow, "<%=XSSUtil.encodeForJavaScript(context, sFrmPortalCmdName)%>");
						
						if (frameWndw != null) {
							frameWndw.setCfgFitlerValues(topWindow, "CPVCfgFilterPredefInput", false, displyValue, actualValue, oidValue);
							//frameWndw.setCfgFitlerValues(topWindow, "CPVCfgFilterDynamicInput", true, "", "", "");
						}
						
						// Close the popup (CfgFilter search) window
						top.location.href = "../common/emxCloseWindow.jsp";
					</script>
					<%
				}
				else
				{
					%>
					<script language="javascript" type="text/javaScript">
						top.location.href = "../common/emxCloseWindow.jsp";
					</script>
					<%
				}
			}			
		}
		catch (Exception e)
		{
			session.putValue("error.message", e.toString());
		}
		%>
	</body>
	
	<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
	
</html>

