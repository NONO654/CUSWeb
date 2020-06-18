<% response.setContentType("text/xml; charset=UTF-8"); %><?xml version="1.0" encoding="UTF-8"?>
<%--  MCADSetOwner.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ page import="java.util.*,java.io.*, java.net.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.utils.customTable.*,matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*, com.matrixone.apps.domain.util.*"%>
<%
	String objIDList	= Request.getParameter(request,"objectIdList");	
	String sUserID		= Request.getParameter(request,"fieldNameActual");
	String sRefreshFrame	= Request.getParameter(request,"refreshFrame");
	String errorMessage		= null;
	String sDump		= "|";
	Vector failureBusNames  = new Vector();

	String type 	= "Type";
	String name 	= "Name";
	String revision = "Revision";
	String title 	= "Title";
	String eMessage = "Message";

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	String unSupportedCommandErrorMessage		= null;
				
	if(integSessionData != null)
	{
		Context context = integSessionData.getClonedContext(session);
		MCADMxUtil util		= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(),integSessionData.getGlobalCache());
		ENOCsrfGuard.validateRequest(context, session, request, response);	
		HashMap integrationNameGCOTable = null;
		
        String vplmAdminRoleName = MCADMxUtil.getActualNameForAEFData(context, "role_VPLMAdmin");
		String vplmViewer 			= MCADMxUtil.getActualNameForAEFData(context, "role_VPLMViewer");
        String vplmExperimenter 	= MCADMxUtil.getActualNameForAEFData(context, "role_VPLMExperimenter");
		String vplmProjectAdministrator 	= MCADMxUtil.getActualNameForAEFData(context, "role_VPLMProjectAdministrator");
		
		StringList slRolesThatCannotAuthor = new StringList(3);
		slRolesThatCannotAuthor.addElement(vplmViewer);
		slRolesThatCannotAuthor.addElement(vplmExperimenter);
		slRolesThatCannotAuthor.addElement(vplmProjectAdministrator);
		
		boolean b1 = MCADMxUtil.isSolutionBasedEnvironment(context);
		boolean b2 =  MCADMxUtil.isRoleAssignedToUser(context, vplmAdminRoleName);

		
		if(b1 && b2){
			integrationNameGCOTable = integSessionData.getIntegrationNameGCOTableForTEAMEnvironment(context);
		}else{
			integrationNameGCOTable = integSessionData.getIntegrationNameGCOTable(context);
			}
		DSCServerErrorMessageTable errorMessageTable       = new DSCServerErrorMessageTable(context, integrationNameGCOTable, util, integSessionData.getResourceBundle());

		errorMessageTable.setRootId("");

		try
		{
				
			//Update the owner of all the selected business objects.
			StringTokenizer idTokenizer = new StringTokenizer(objIDList, "|");
			while(idTokenizer.hasMoreTokens()) 
			{
				boolean isSuccess	= false; 
				String sObjId = idTokenizer.nextToken();

				if(sObjId != null && !"".equalsIgnoreCase(sObjId))
				{
					HashMap argumentsMap = new HashMap();
					argumentsMap.put("objectId", sObjId);
					argumentsMap.put("languageStr", request.getHeader("Accept-Language"));
					argumentsMap.put("New Value", sUserID);
					String validateNewUser = "false";
					argumentsMap.put("validateNewOwner", validateNewUser);

					if(MCADMxUtil.isSolutionBasedEnvironment(context))
					{
						String sCommandStatementProject = "print bus $1 select $2 $3 dump $4";
						String projectAndOrg 			= MqlUtil.mqlCommand(context, sCommandStatementProject, sObjId, "organization", "project", sDump);
						Vector prjAndOrg 				= MCADUtil.getVectorFromString(projectAndOrg, sDump);

						String org						= (String)prjAndOrg.get(0);
						String prj						= (String)prjAndOrg.get(1);
			   
						String sCommandStatementRole = "print role $1 select $2 dump $3";
						String userList 				=  MqlUtil.mqlCommand(context, sCommandStatementRole, prj, "person", sDump);
						StringList sUserList 			= FrameworkUtil.split(userList, sDump);

						if(!sUserList.contains(sUserID))
						{
							errorMessageTable.addErrorMessage(context, sObjId, integSessionData.getStringResource("mcadIntegration.Server.Message.ProjectofSelectedUserAndObjectNotSame"));
						
							continue;
						}

						String sCommandStatement1	= "print person $1 select  assignment dump $2";
						String newOwnerRolesString	=	MqlUtil.mqlCommand(context, sCommandStatement1,sUserID,sDump);
						StringTokenizer ownersRoles = 	new StringTokenizer(newOwnerRolesString, sDump);

						while(ownersRoles.hasMoreTokens())
						{
							String ownerRole = ownersRoles.nextToken();		

							if(ownerRole.startsWith("ctx::"))
							{
								ownerRole 			= ownerRole.substring(5);
								String[] result 	= ownerRole.split("\\.");
								String roleName 	= result[0];
								String orgName		= result[1];
								String projectName 	= result[2];

								//if(!roleName.equals(vplmViewer) && !roleName.equals(vplmExperimenter) && prj.equals(projectName) && org.equals(orgName))
								if(!slRolesThatCannotAuthor.contains(roleName) && prj.equals(projectName))
								{
									isSuccess = true;
									break;
								}
								else
									isSuccess = false;
							}
						}

						if(!isSuccess)
						{
							errorMessageTable.addErrorMessage(context, sObjId, integSessionData.getStringResource("mcadIntegration.Server.Message.UserNotHaveAuthourityToAuthor"));
							continue;
					     }
					}
					HashMap paramMap = new HashMap();
					paramMap.put("paramMap", argumentsMap);

					String [] packedArguments = JPO.packArgs(paramMap);
					
					try
					{
							context.start(true);
					Boolean bResp = (Boolean)util.executeJPO(context, "DSCChangeOwnershipValidate", "updateOwner", packedArguments, Boolean.class);
							context.commit();
					}
					catch(Exception e)
					{
				
							System.out.println("Exception occured in MCADSetOwner.jsp " + e.getMessage());
			     }

			}
			}
		}
		catch(Exception e)
		{
			try
			{
				if(context.isTransactionActive())
					context.abort();
		        }  
			catch (Exception transactionEx)
			{
				errorMessage = transactionEx.getMessage();
			}
			errorMessage	= integSessionData.getStringResource("mcadIntegration.Server.Message.OwnershipChangeAccessDenied");
		}


		try{

				if (MCADMxUtil.isSolutionBasedEnvironment(context) && errorMessageTable != null && errorMessageTable.errorsOccured())
				{

					java.util.Vector ColumnLableList = new java.util.Vector();
					ColumnLableList.add(type);
					ColumnLableList.add(name);
					ColumnLableList.add(title);
					ColumnLableList.add(revision);
					ColumnLableList.add(eMessage);
					errorMessage	= errorMessageTable.getErrorMessageHTMLTable(ColumnLableList);
					errorMessage	= MCADUtil.replaceString(errorMessage, "\"","'");
				}
			}
catch(Exception exception)
			{
				errorMessage	= exception.getMessage();
		}
		
	}
	else
	{
		String acceptLanguage							= request.getHeader("Accept-Language");
		MCADServerResourceBundle serverResourceBundle	= new MCADServerResourceBundle(acceptLanguage);
		
		String message	= serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		errorMessage	= message;
	}

%>
<dsc:message xmlns:dsc="http://www.matrixone.com/dsc">
    <!--XSSOK-->
	<dsc:error><![CDATA[<%=errorMessage%>]]></dsc:error>
</dsc:message>
