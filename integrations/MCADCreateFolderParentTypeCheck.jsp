<%--  MCADCreateFolderParentTypeCheck.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	Context context			= integSessionData.getClonedContext(session);
	String objectId			= emxGetParameter(request,"objectId");
	BusinessObject busObj	= new BusinessObject(objectId);
	String busType			= "";
	Boolean hasUserCreateAccess = Boolean.FALSE;

	if(busObj.exists(context)) 
	{
		busObj.open(context);
		busType = busObj.getTypeName();
		busObj.close(context);

		HashMap paramMap = new HashMap();
		paramMap.put("objectId", objectId);
		
		String[] init		= new String[] {};
		String jpoName		= "emxWorkspaceFolder";
		String jpoMethod	= "";
		if(busType.equalsIgnoreCase("Workspace"))
		{			
			jpoMethod	= "hasCreateAccess";
		}
		else
		{
			jpoMethod	= "linkAccessCheck";
		}

		hasUserCreateAccess = (Boolean)JPO.invoke(context, 
										jpoName, 
										init, jpoMethod, 
										JPO.packArgs(paramMap),
										Boolean.class);		
	}

	
%>


<script language="JavaScript" src="./scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="./scripts/IEFUIModal.js" type="text/javascript"></script>
  <script>
    //XSSOK
	var busType = "<%=busType%>";
	
	//XSSOK
	if(<%=hasUserCreateAccess%>)
	{
		if(busType=="Workspace")
		{
			showIEFModalDialog("../common/emxCreate.jsp?form=TMCWorkspaceVaultCreate&formHeader=emxTeamCentral.common.CreateNewFolder&HelpMarker=emxhelpcreatenewfolder&createJPO=emxWorkspaceFolder:createWorkspaceFolderProcess&postProcessURL=../teamcentral/emxTeamCreateFolders.jsp&mode=edit&findMxLink=false&showPageURLIcon=false&submitAction=doNothing&type=type_ProjectVault&policy=policy_ProjectVault&showPolicy=false&objectId=" + "<%=XSSUtil.encodeForURL(context,objectId)%>", 575, 575);
		}
		else if (busType=="Workspace Vault")
		{
			showIEFModalDialog("../teamcentral/emxTeamCreateSubFoldersWorkspaceDialogFS.jsp?objectId=" + "<%=XSSUtil.encodeForURL(context,objectId)%>", 575, 575);		
		}
		else
		{
		    //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.PleaseSelectAFolderOrWorkspace")%>");
		}
	}
	else
	{
		if(busType == "")
		{
		    //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.PleaseSelectAFolderOrWorkspace")%>");
		}
		else
		{
		    //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.NoFolderCreateAccess")%>");
		}
	}
	
</script>
