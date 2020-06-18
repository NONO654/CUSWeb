<%--  MCADChangeOwner.jsp

   Copyright Dassault Systemes, 1992-2012. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ include file = "MCADTopInclude.inc" %>
<%@ include file = "MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*,com.matrixone.MCADIntegration.server.beans.util.DSCOwnershipUtil" %>
<%
	String sRefreshFrame	= Request.getParameter(request,"refreshFrame");
	String actionURL		= "";
	String sObjectId		= "";
	String integrationName  = "";
	String errorMessage		= "";
	StringBuffer sbufObjectIDs 	= new StringBuffer();
	String fieldNameActual 		= Request.getParameter(request,"fieldNameActual");;
	String form 				= Request.getParameter(request,"formName");
	String fieldNameDisp 		= Request.getParameter(request,"fieldNameDisplay");
	String sMultiselect 		= Request.getParameter(request,"multiSelect");
	String isWebFormRequest 	= Request.getParameter(request,"isWebFormRequest");
	String requestURI           = request.getRequestURI();
	String pathWithIEFDir       = requestURI.substring(0, requestURI.lastIndexOf('/'));
	String setOwnerURL         	= pathWithIEFDir + "/MCADSetOwner.jsp?";

	boolean bInValidUser       = false;
	String queryString         = "";

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);

	String errorM           = "";
	String urlAppend		= "";
	Vector failureBusNames  = new Vector();

	String ChangeOwnerErrorMessageKey	= "mcadIntegration.Server.Message.FeatureNotAllowedNonIntegrationObject";
	String ChangeOwnerErrMsg			= "mcadIntegration.Server.Message.ErrorOccuredInChangingOwner";
	String featureName					= integSessionData.getStringResource("mcadIntegration.Server.Feature.ChangeOwner");

	Hashtable messageTokens = new Hashtable();
	messageTokens.put("NAME", featureName);

	String ChangeOwnerErrorMessage= integSessionData.getStringResource(ChangeOwnerErrorMessageKey,messageTokens);
	
	if(sMultiselect == null)
	{
		sMultiselect = "false";
	}

	if(form == null)
	{
		form = "changeOwner";
	}

	if(fieldNameActual == null)
	{
		fieldNameActual = "fieldNameActual";
	}

	if(fieldNameDisp == null)
	{
		fieldNameDisp = "fieldNameDisplay";
	}

	if(isWebFormRequest == null)
	{
		isWebFormRequest = "true";
	}

	if(integSessionData != null)
	{
		String[] objectIds	= emxGetParameterValues(request, "emxTableRowId");

		if (objectIds == null || objectIds.equals("null"))
		{
		    String objectId = (String)Request.getParameter(request,"objectId");
		    if (null != objectId && !objectId.equals("null"))
		    {
				objectIds		= new String[1];
		        objectIds[0]	= objectId;
		    }
		}
		else if(objectIds!=null && objectIds.length>0)
		{
			for(int i=0; i < objectIds.length; i++)
			{
				//emxTableRowId value is obtained in the format relID|objectid Or ObjectId. Need to parse the value
				StringList sList = FrameworkUtil.split(objectIds[i],"|");

				if(sList.size() == 1 || sList.size() == 2)
					objectIds[i] = (String)sList.get(0);
			
				//Structure Browser value is obtained in the format relID|objectID|parentID|additionalInformation
				// if relID is blank in that case size will be 3 need to pick first token
				else if(sList.size() == 3)
					objectIds[i] = (String)sList.get(0);
			
				else if(sList.size() == 4)
					objectIds[i] = (String)sList.get(1);
			}
		}

		MCADMxUtil util		= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(),integSessionData.getGlobalCache());

		HashMap integrationNameGCOTable = null;
		
        String vplmAdminRoleName = MCADMxUtil.getActualNameForAEFData(context, "role_VPLMAdmin");

		if(MCADMxUtil.isSolutionBasedEnvironment(context) && MCADMxUtil.isRoleAssignedToUser(context, vplmAdminRoleName))
			integrationNameGCOTable = integSessionData.getIntegrationNameGCOTableForTEAMEnvironment(context);
		else
			integrationNameGCOTable = integSessionData.getIntegrationNameGCOTable(context);
		
		DSCServerErrorMessageTable errorMessageTable       = new DSCServerErrorMessageTable(context, integrationNameGCOTable, util, integSessionData.getResourceBundle());

		errorMessageTable.setRootId("");

		if (null == objectIds || objectIds.length <= 0)
		{
			 String message	= integSessionData.getStringResource("mcadIntegration.Server.Message.ErrorNoSelection");
			 actionURL		= "./MCADMessageFS.jsp?";
			 actionURL		+= "&message=" + message;
			 errorMessage	= message;
		}
		else
		{			
			MCADGlobalConfigObject globalConfigObject = null;

			DSCOwnershipUtil changeOwner		= new DSCOwnershipUtil(context, request.getHeader("Accept-Language"));
			MCADConfigObjectLoader configLoader	= new MCADConfigObjectLoader(integSessionData.getLogger());

			for(int i=0; i < objectIds.length; i++)
			{
				try
				{
					integrationName		  = util.getIntegrationName(context, objectIds[i]);
					sObjectId			  = objectIds[i];

					String methodName		= "validate";

					BusinessObject busObj	= new BusinessObject(sObjectId);
					busObj.open(context);
					String busType	= busObj.getTypeName();

					String busName = busObj.getName();

					if(null == integrationName || "".equals(integrationName.trim()))
					{
						errorMessageTable.addErrorMessage(context,sObjectId, ChangeOwnerErrorMessage);
						failureBusNames.add(sObjectId);
						continue;
					}

					boolean isSolutionBasedEnvironment = MCADMxUtil.isSolutionBasedEnvironment(context);
					globalConfigObject		= (MCADGlobalConfigObject)integrationNameGCOTable.get(integrationName);

					if(isSolutionBasedEnvironment)
					{
						String locker = "";
						if(!util.isMajorObject(context, sObjectId))//globalConfigObject.isMinorType(busType))
						{
							BusinessObject majorObj = util.getMajorObject(context, busObj);
							locker					= majorObj.getLocker(context).getName();
						}
						else	
							locker = busObj.getLocker(context).getName();

						if(!locker.isEmpty())
						{
							Hashtable messageTable = new Hashtable(2);
							messageTable.put("LOCKERNAME", locker);

							errorMessageTable.addErrorMessage(context, sObjectId, integSessionData.getStringResource("mcadIntegration.Server.Message.LockedByAnotherUser", messageTable));

							failureBusNames.add(sObjectId);
							continue;
						}
					
						
						Boolean checkProject			= changeOwner.checkProject(context, sObjectId);

						if(!checkProject)
						{
							errorMessageTable.addErrorMessage(context, sObjectId, integSessionData.getStringResource("mcadIntegration.Server.Message.UserIsNotAssignedTheProject"));

							failureBusNames.add(sObjectId);
							continue;
						}
					}

					busObj.close(context);

					
					if(globalConfigObject == null && MCADMxUtil.isSolutionBasedEnvironment(context))
					{
						
						String [] integrationaNameargs = new String[1];
						integrationaNameargs[0] = integrationName;

						String registrationDetails  = (String) util.executeJPO(context, "IEFGetRegistrationDetails", "getRegistrationDetails", integrationaNameargs, String.class);

						String gcoName 				= registrationDetails.substring(registrationDetails.lastIndexOf("|")+1);
						
						String typeGlobalConfig		= MCADMxUtil.getActualNameForAEFData(context, "type_MCADInteg-GlobalConfig");


						globalConfigObject					= configLoader.createGlobalConfigObject(context, util, typeGlobalConfig, gcoName);
					}

					if(!util.isMajorObject(context, sObjectId))//!globalConfigObject.isMajorType(busType)) // [NDM] OP6
					{
						methodName	= "validateForMinor";
					}

					//sbufObjectIDs.append(objectIds[i]);
					//sbufObjectIDs.append("|");

					HashMap argumentsMap = new HashMap();

					argumentsMap.put("objectId", sObjectId);
					argumentsMap.put("languageStr", request.getHeader("Accept-Language"));

					String [] packedArguments = JPO.packArgs(argumentsMap);
					Boolean isValid			= (Boolean)util.executeJPO(context, "DSCChangeOwnershipValidate", methodName, packedArguments, Boolean.class);

					if(isValid.booleanValue() == false)
					{
						errorMessageTable.addErrorMessage(context, sObjectId, integSessionData.getStringResource("mcadIntegration.Server.Message.OwnershipChangeAccessDenied"));

						failureBusNames.add(sObjectId);
					}
					else
					{
						sbufObjectIDs.append(objectIds[i]);
						sbufObjectIDs.append("|");
					}

				}
				catch(Exception exception)
				{
					errorMessage	= exception.getMessage();
				}
			}

			try{

				if( failureBusNames.size()>0)
				{
					if(errorMessageTable != null && errorMessageTable.errorsOccured())
				{
						errorM = errorMessageTable.getErrorMessageHTMLTable();

						errorM		   = MCADUtil.replaceString(errorM, "\"","'");
				}

					if(objectIds.length !=  failureBusNames.size())
				{
						errorM = errorM;

						urlAppend ="&showContinueBtn=true";
					}
		}
			}catch(Exception exception)
			{
				errorMessage	= exception.getMessage();
			}
		}
		
		
		if(objectIds.length !=  failureBusNames.size())
		{
			actionURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&type=PERSON_CHOOSER&fieldNameDisplay=" + fieldNameDisp + "&fieldNameActual=" + fieldNameActual + "&fieldNameOID=&selection=single&form=AEFSearchPersonForm&submitURL=../integrations/MCADChangeOwnerSubmit.jsp?methodName=setOwner&table=AEFPersonChooserDetails";			
			
            actionURL 	+= "&integrationName=" + integrationName;
			queryString = "objectIdList=" + sbufObjectIDs.toString() + "&integrationName=" + integrationName;

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
<html>
<head>

<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>

<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="JavaScript" type="text/javascript" src="../emxUIPageUtility.js"></script>
<script language="JavaScript" src="scripts/IEFUIConstants.js"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js"></script>
<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>

<script language="javascript">

var refreshFrame		= getFrameObject(top, '<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),sRefreshFrame)%>');
var integrationFrame	= getIntegrationFrame(this);

if(integrationFrame != null)
	integrationFrame.setActiveRefreshFrame(refreshFrame);

function doContinueButtonAction()
{
	showModalDialog("<%=XSSUtil.encodeForJavaScript(context,actionURL)%>", '', '', false, 'Medium', false);
}
function showDialogPopup(url)
{	
            //XSSOK
         	if ("<%=errorM%>" != "")
		{
		    //XSSOK
			messageToShow = "<%=errorM%>";
			messageToShow = escape(messageToShow);
                        //XSSOK
			var queryString  =  "messageHeader=" + "<%=ChangeOwnerErrMsg%>" +"<%=urlAppend%>";
			showIEFModalDialog("./DSCErrorMessageDialogFS.jsp?showExportIcon=true&"+queryString,500,400,true);
		}
		else
		{
		showModalDialog(url, '', '', false, 'Medium', false);
	}
}
function refreshPage()
{
	var targetFrame		= top.findFrame(top, "listDisplay");

	if (targetFrame)
	{
		var objForm			= targetFrame.document.forms['emxTableForm'];
		var commandName = (objForm && objForm.commandName) ? objForm.commandName.value : "";

		if (targetFrame && commandName!="Navigate")
		{
			if(parent.listDisplay)
			refreshTableContent();
			else
				parent.location.href = parent.location.href;
		}
		else if(commandName == "Navigate")
		{
			parent.reloadNavigateTable();
		}
			}
			else
			{
		var searchContentFrame		= top.findFrame(top,"searchContent");
		var detailsDisplayFrame		= top.findFrame(top,"detailsDisplay");
		var structureBrowserFrame	= top.findFrame(top,"structure_browser");
		var appletReturnHiddenFrame = top.findFrame(top,"appletReturnHiddenFrame");

		if(searchContentFrame)
			searchContentFrame.refreshSearchResultPage();
		else if(detailsDisplayFrame)
					refreshIndentedTable("detailsDisplay");
		else if(structureBrowserFrame)
			refreshIndentedTable("structure_browser");
		else if(appletReturnHiddenFrame)
			parent.parent.location.href = parent.parent.location.href;
	}
}

function setOwner(userID)
{
	/*
		Following code will execute the MCADSetOwner.jsp which is returning the
		<dsc:error><dsc:error> in the output xml format if any error occured in MCADSetOwner.jsp
		it will get added in the above node.
	*/
	//XSSOK
	var setOwnerURL		= "<%=setOwnerURL%>";
	//XSSOK
	var queryString		= "<%=queryString%>&fieldNameActual=" + document.changeOwner.fieldNameActual.value;
	var objXML			= emxUICore.getTextXMLDataPost(setOwnerURL + queryString, "");
	var errorNode		= emxUICore.getElementsByTagName(objXML, "dsc:error");
	var errorMessage	= errorNode[0].childNodes[0].nodeValue;

	if(errorMessage != null && errorMessage != "" && errorMessage != "null" && typeof errorMessage != "undefined")
	{
			messageToShow = errorMessage;
			messageToShow = escape(messageToShow);
			//XSSOK
			var queryString  = "messageHeader=" + "<%=ChangeOwnerErrMsg%>";
			showIEFModalDialog("./DSCErrorMessageDialogFS.jsp?showExportIcon=true&"+queryString,500,400,true);
	}
	else
	{
		refreshPage();
	}
}

</script>

</head>

<%@include file = "MCADBottomErrorInclude.inc"%>
<body onLoad="showDialogPopup('<%=XSSUtil.encodeForHTML(context, actionURL)%>')">

<%@ include file="../iefdesigncenter/DSCIndentedTableInclude.inc" %>

<form name="changeOwner" method="post" action="" target="_self">
<input type="hidden" name="fieldNameActual" value="<xss:encodeForHTMLAttribute><%=fieldNameActual%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="fieldNameDisplay" value="<xss:encodeForHTMLAttribute><%=fieldNameDisp%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="refreshFrame" value="<xss:encodeForHTMLAttribute><%=sRefreshFrame%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="multiSelect" value="<xss:encodeForHTMLAttribute><%=sMultiselect%></xss:encodeForHTMLAttribute>">
</form>
</body>
</html>

