<%@include file = "../common/emxNavigatorInclude.inc"%>

<html>
	<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
	
	<head>
		<title></title>
		
		<%@include file = "../common/emxUIConstantsInclude.inc"%>
		
		<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
		<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
		<%@page import= "com.matrixone.apps.domain.util.XSSUtil"%>
		

		<%@ page import="matrix.db.*"%>
		<%@ page import="com.dassault_systemes.vplm.modeler.PLMCoreModelerSession"%>
		<%@ page import="com.dassault_systemes.vplm.fctProcessNav.interfaces.IVPLMFctProcessNav"%>
		<%@ page import="com.dassault_systemes.vplm.fctProcessAdvNav.interfaces.IVPLMFctProcessAdvNav"%>
		<%@ page import="com.dassault_systemes.vplm.modeler.entity.PLMxEntityDef"%>
		
		<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
		<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
		<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
		<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
		
	</head>
	
	
	<body>
		<%
		try {
			String mode = emxGetParameter(request,"mode");
			
			if (!(mode!=null && !mode.isEmpty()))
			{
				%>
				<script language="javascript">
				top.opener.location.href = top.opener.location.href;
				top.location.href = "../common/emxCloseWindow.jsp";
				</script>
				<%	
			}
			else if (mode.equalsIgnoreCase("searchForFilter"))
			{
				String objectId = emxGetParameter(request, "objectId");
				String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
				String fieldNameActual = emxGetParameter(request, "fieldNameActual") + "_actualValue";
				
				String type = "VPMCfgConfiguration";
				%>
				<script language="javascript">
				var sURL = "../common/emxIndentedTable.jsp?objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&table=VPLMCfgConfiguration&mode=submitFilter&selection=single&submitURL=../common/emxVPLMProcCfgFilter.jsp&submitAction=none&fieldNameActual=<%=XSSUtil.encodeForURL(context,fieldNameActual)%>&fieldNameDisplay=<%=XSSUtil.encodeForURL(context,fieldNameDisplay)%>&program=emxVPLMtypPLMProcessDSExpand:getAllConfigurationFeatures&CancelButton=true&cancelLabel=emxFramework.Button.Cancel&submitLabel=emxFramework.Button.Submit ";
				window.location.href = sURL;
				</script>
				<%	
			}
			else if (mode.equalsIgnoreCase("submitFilter"))
			{			
				String fieldNameActual = emxGetParameter(request,"fieldNameActual");
				String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
				
				String objectId = emxGetParameter(request, "objectId");
				String[] emxTableRowIds = emxGetParameterValues(request, "emxTableRowId");				
				String emxTableRowId = emxTableRowIds[0];
				StringList emxTableRowIdList = FrameworkUtil.split(emxTableRowId, "|");
				if (emxTableRowIdList.size() > 0)
				{
					String strTempObjId = (String)emxTableRowIdList.get(0);

					Context myCtx = Framework.getMainContext(session);
					myCtx.resetVault("vplm");
					String myApp = myCtx.getApplication();
					if (myApp == null || !myCtx.getApplication().contains("VPLM"))
					{
						myCtx.setApplication("VPLM");
					}
					if (!myCtx.isTransactionActive())
					{
						myCtx.start(false);
					}
					
					PLMCoreModelerSession plmSession = PLMCoreModelerSession.getPLMCoreModelerSessionFromContext(myCtx);
					plmSession.openSession();
					
					IVPLMFctProcessNav processModeler = (IVPLMFctProcessNav)plmSession.getModeler("com.dassault_systemes.vplm.fctProcessNav.implementation.VPLMFctProcessNav");
					IVPLMFctProcessAdvNav processAdvModeler = (IVPLMFctProcessAdvNav)plmSession.getModeler("com.dassault_systemes.vplm.fctProcessAdvNav.implementation.VPLMFctProcessAdvNav");
					ArrayList M1IDs = new ArrayList();
					M1IDs.add(strTempObjId);
					String[] PLMIDs = processModeler.getPLMObjectIdentifiers(M1IDs);
					PLMxEntityDef filterEntity = processAdvModeler.openEntity(PLMIDs[0]);
					String strTempObjName = filterEntity.getAttributes().get("PLM_ExternalID").toString();
					%>
					<script language="javascript" type="text/javaScript">
						var vfieldNameActual = top.opener.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
						var vfieldNameDisplay = top.opener.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
						vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strTempObjName)%>";
						vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strTempObjId)%>";
						top.opener.filterPage();
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
			else if (mode.equalsIgnoreCase("clearFilter"))
			{
				String fieldNameActual = emxGetParameter(request,"fieldNameActual");
				String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
				%>
				<script language="javascript" type="text/javaScript">
					var vfieldNameActual = top.opener.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
					var vfieldNameDisplay = top.opener.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
					vfieldNameDisplay[0].value ="" ;
					vfieldNameActual[0].value ="" ;
					top.opener.filterPage();
					top.location.href = "../common/emxCloseWindow.jsp";
				</script>
				<%
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
