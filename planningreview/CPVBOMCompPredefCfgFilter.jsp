<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@ page import="com.dassault_systemes.vplm.DELJTypeNAttServices"%>


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
				String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
				String fieldNameActual  = emxGetParameter(request, "fieldNameActual");
				String fieldNameOID  = emxGetParameter(request, "fieldNameActual");
				String sObjectIDField = emxGetParameter(request, "BOMObjIDField");
				
				%>
				<script language="javascript" type="text/javaScript">
					var nameOIDField = top.opener.document.getElementsByName("<%=XSSUtil.encodeForURL(context,sObjectIDField)%>");
					var sObjectID = nameOIDField[0].value;
					var sURL = "../common/emxIndentedTable.jsp?objectId="+ sObjectID+ "&submitURL=../planningreview/CPVBOMCompPredefCfgFilter.jsp&submitAction=none&CPVFilterMode=choosenPredefFilter&selection=single&fieldNameActual=<%=XSSUtil.encodeForURL(context,fieldNameActual)%>&fieldNameDisplay=<%=XSSUtil.encodeForURL(context,fieldNameDisplay)%>&fieldNameOID=<%=XSSUtil.encodeForURL(context,fieldNameOID)%>&table=VPLMCfgConfiguration&program=DELJPlanningUtil:getAllConfigurations&CancelButton=true&cancelLabel=Cancel";
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
					Hashtable attValues = DELJTypeNAttServices.getVPLMObjectAttValues(context, sObjId);
					String sObjName = (String) attValues.get("PLM_ExternalID");
					
					String sFieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
					String sFieldNameActual = emxGetParameter(request, "fieldNameActual");					
					String sFieldNameOID  = emxGetParameter(request, "fieldNameOID");
					%>
					<script language="javascript" type="text/javaScript">
						// Get Filter values
						var displyValue = "<%=XSSUtil.encodeForJavaScript(context, sObjName)%>";
						var actualValue = "<%=XSSUtil.encodeForJavaScript(context, sObjId)%>";
						
						// setCfgFitlerValues(top, fieldNameActual, false, displyValue, actualValue, oidValue);
						
						// Get Filter Field & its hidden fields
						var fieldNameActual="<%=XSSUtil.encodeForURL(context,sFieldNameActual)%>";
						var fieldNameDisplay="<%=XSSUtil.encodeForURL(context,sFieldNameDisplay)%>";
						var fieldNameOID="<%=XSSUtil.encodeForURL(context,sFieldNameOID)%>";
						
						// Set value for Filter Field & its hidden fields
						top.opener.document.getElementsByName(fieldNameDisplay)[0].value = displyValue;  
						top.opener.document.getElementsByName(fieldNameActual)[0].value = actualValue;
						top.opener.document.getElementsByName(fieldNameOID)[0].value = actualValue;
						
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
