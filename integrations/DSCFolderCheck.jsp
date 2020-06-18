<%--  DSCFolderCheck.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>

<html>
<head>
<script language="JavaScript">

<%@include file = "IEFTreeTableInclude.inc"%>


</script>
<%
        String nodeId = emxGetParameter(request,"nodeId");
        String workspaceVaultId = emxGetParameter(request,"objectId");
        String folderId = workspaceVaultId;
		String fullPath = emxGetParameter(request,"fullPath");
        String applyToChild = emxGetParameter(request,"applyToChild");
	    String folderType = "";			
		
		// Object Id of project vault contains "p_" prefix
        boolean toConnectAccess = true;
        
        if (null != workspaceVaultId && workspaceVaultId.startsWith("p_"))
        {
           folderId = workspaceVaultId.substring(2, workspaceVaultId.length());
        }
        else
        {
           folderId = workspaceVaultId;
        }
		
	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String acceptLanguage = request.getHeader("Accept-Language");
	boolean hasReadWriteAccess = false;
	boolean hasReadAccess = false;
	String strAssignFolderErrorMessage = ""; 
	MCADServerResourceBundle serverResourceBundle = null;
    Context context = null;
		
	if(integSessionData == null)
	{
	     serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);
             String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	     emxNavErrorObject.addMessage(errorMessage);
	}
	else
	{		
             serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);
	     MCADMxUtil util	= new MCADMxUtil(integSessionData.getClonedContext(session), integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	     context = integSessionData.getClonedContext(session);
	}
        
        try
        {
            context =  Framework.getFrameContext(session);
			BusinessObject folder = new BusinessObject(folderId);
			
			if(! folder.exists(context))
			{
				folderType = "Collection";				
			}
			else
			{
            folder.open(context);
	        folderType = folder.getTypeName();			
			folder.close(context);			
	        
			DomainObject domainObject        = DomainObject.newInstance(context,folderId);
            Access contextAccess = domainObject.getAccessMask(context);
            // Checks the user contains Write access.
            toConnectAccess = AccessUtil.hasAddAccess(contextAccess);
            
            if (toConnectAccess == false)
            {
               strAssignFolderErrorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.NoFolderWritePermission");
            }
            else
            {
               strAssignFolderErrorMessage = "";
            }
        }
        }
        catch (Exception e)
        {
          System.out.println("DSCFolderAssigned: " + e.toString());
        }	
      
%>

<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<style type=text/css > 
  body { background-color: #fffff0  } body, th, td, p { font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt; }a { color: #003366; } a:hover { } a.object { font-weight: bold; } a.object:hover { } span.object {  font-weight: bold; } a.button { } a.button:hover { } td.pageHeader {  font-family: Arial, Helvetica, Sans-Serif; font-size: 13pt; font-weight: bold; color: #990000; } td.pageBorder {  background-color: #003366; } th { text-align: left; color: white; background-color: #336699; } th.sub { text-align: left; color: white; background-color: #999999; } tr.odd { background-color: #ffffff; } tr.even { background-color: #eeeeee; } 
</style>
<%
   if (false == toConnectAccess) { 
%>
<script language="JavaScript">
      //XSSOK
      javascript:alert("<%=strAssignFolderErrorMessage%>");
</script>
<%
   }
   
%>
<script language="Javascript">
     
	 //XSSOK
     var nodeId = "<%=nodeId%>";
	 //XSSOK
     var fullPath = "<%=fullPath%>";
	 //XSSOK
     var objectId = "<%=workspaceVaultId%>";
	 //XSSOK
     var applyToChild = "<%=applyToChild%>";
	 //XSSOK
     var folderType = "<%=folderType%>";
	     //XSSOK
     if ('' == "<%=strAssignFolderErrorMessage%>")
     {
		if(folderType == "Workspace")
		 {
		    //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.WorkspaceCannotBeSelected")%>");
		 }
		else if (folderType == "Workspace Vault" || folderType == "Collection" )
		 {
			 document.location.href="./MCADFolderSearchDialogFooter.jsp?doSelect=true";
			 if(nodeId != null && nodeId != "null" && nodeId != "")
			 {
			 parent.window.opener.doSelect(objectId,fullPath, nodeId, applyToChild);
			 }
			 else
			 {	
			 parent.window.opener.doGlobalSelect(objectId,fullPath,applyToChild);			
		     }		  
    	 }
		 parent.window.close();
	 }
     else
     {
         document.location.href="./MCADFolderSearchDialogFooter.jsp?doSelect=false";
     }
</script>
</head>


<body>

</body>
</html>

