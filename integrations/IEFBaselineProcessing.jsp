<%--  IEFBaselineProcessing.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ page import="java.util.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*"  %>
<%@ page import="matrix.db.*"  %>
<%@ page import="matrix.util.StringList"  %>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%@ page import="com.matrixone.json.JSONArray" %>
<%@ page import="com.matrixone.json.JSONObject" %>
<%@ page import="com.matrixone.MCADIntegration.server.modeler.impl.ENODECSnapshotImpl" %>
<%@ page import="com.matrixone.apps.domain.DomainObject" %>

<%
	String parentObjectId	=Request.getParameter(request,"objectId");
	String objectIds		=Request.getParameter(request,"objectIdList");
	String baselineName		=Request.getParameter(request,"baselineName");
	String baselineDesc		=Request.getParameter(request,"baselineDesc");
	String baselineView		=Request.getParameter(request,"baselineView");
	String integrationName	=Request.getParameter(request,"integrationName");
	String selectedProgram	=Request.getParameter(request,"selectedProgram");
	String errorMessage		=Request.getParameter(request,"errorMessage");
	String sIsOverwriteVal = Request.getParameter(request,"isOverWrite");

	boolean  isOverWrite	=Request.getParameter(request,"isOverWrite") == null ? false:true;

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
    Context context								= integSessionData.getContext();
    MCADServerLogger logger						= integSessionData.getLogger();
    MCADMxUtil util								= new MCADMxUtil(context, logger, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	String baselineTypeName 	 				= util.getActualNameForAEFData(context,"type_DECBaseline");

	try
	{
		String  baselineRelName  		= util.getActualNameForAEFData(context,"relationship_DesignBaseline");
		String  rootNodeDetailAttName 	= util.getActualNameForAEFData(context,"attribute_RootNodeDetails");				
		IEFBaselineHandler  handler		= new IEFBaselineHandler(integSessionData,integrationName,null);
		
		//util.startTransaction(context);
		
/*		BusinessObject baselineObj		= handler.createBaseLine(context, baselineName, baselineDesc,isOverWrite);

		if(parentObjectId != null)
		{
			BusinessObject object		= new BusinessObject(parentObjectId);
			BusinessObject minorObj		= util.getActiveMinor(context,object);
			StringBuffer topNodeTNR 	= new StringBuffer();
			minorObj.open(context);
			
			topNodeTNR.append(minorObj.getTypeName());
			topNodeTNR.append("|");
			topNodeTNR.append(minorObj.getName());
			topNodeTNR.append("|");
			topNodeTNR.append(minorObj.getRevision());
			baselineObj.setAttributeValue(context,rootNodeDetailAttName,topNodeTNR.toString());
			minorObj.close(context);
		}

		BusinessObjectList businessObjectList = new BusinessObjectList();
				
		Enumeration objectDetailsTokens = MCADUtil.getTokensFromString(objectIds,"|");
		while(objectDetailsTokens.hasMoreElements())
		{
			BusinessObject obj = new BusinessObject((String)objectDetailsTokens.nextElement());
					
			if(util.isObjectRenamed(context, obj))
			{
				obj.open(context);	
				Hashtable messageDetails = new Hashtable(4);
				messageDetails.put("TYPE", obj.getTypeName());
				messageDetails.put("NAME", obj.getName());
				messageDetails.put("REVISION", obj.getRevision());
				obj.close(context);
				MCADServerException.createException(integSessionData.getStringResource("mcadIntegration.Server.Message.BaselineNotAllowedForRenamedObjectSaveFirst", messageDetails), null);				     			
			}
			BusinessObject minorObj = util.getActiveMinor(context,obj);			
			businessObjectList.addElement(minorObj);
		}
		
		boolean result = util.connectObjectAtGivenEnd(context,businessObjectList,baselineObj,baselineRelName,"to",new Hashtable());*/

		String sParentPhyId= null;
		try
		{
			BusinessObject obj = new BusinessObject(parentObjectId);

			if(obj.exists(context))
			{				
				String busid = obj.getObjectId(context);
				StringList selectables = new StringList();
				selectables.add(DomainObject.SELECT_ID);
				selectables.add("physicalid");
				DomainObject doObj = DomainObject.newInstance(context,busid);
				Map objInfo = doObj.getInfo(context, selectables);			
				sParentPhyId = (String) objInfo.get("physicalid");
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			sParentPhyId = null;
		}

if(sParentPhyId!=null)
{

JSONObject operation1 = new JSONObject();
operation1.put("busid",sParentPhyId);//TODO QFP name as an option
operation1.put("Description",baselineDesc);
operation1.put("Title",baselineName);
operation1.put("Name",baselineName);
operation1.put("View",baselineView);
operation1.put("isOverwrite",sIsOverwriteVal);
operation1.put("fromDECWeb","true");//This will skip the CAD Type validation in Snapshot API


JSONObject result = new ENODECSnapshotImpl().create(context, operation1);//TODO handles only As-Built view



	String sResult = (String)result.get("status");
	if(sResult.equalsIgnoreCase("SUCCESS"))
	{
		//no message to be displayed...simply reload
	} else {
String sMessage = (String)result.get("message");
%>
	<script>
		parent.stopProgressClock();
		//XSSOK
		alert("<%=sMessage%>");
		parent.window.close();
	</script>
<%

	}


} else {
//TODO 
}
		//util.commitTransaction(context);
%>
	<script>
		parent.stopProgressClock();
		parent.window.close();
	</script>
<%
	}
	catch(Exception e)
	{
		String exceptionMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.BaselineCreationFailed") + ": " + e.getMessage();
		try 
		{
			if(context.isTransactionActive())
				context.abort();
		} 
		catch (Exception me) 
		{
		}
%>
	<script>
		parent.stopProgressClock();
		//XSSOK
		alert("<%=exceptionMessage%>");
		parent.window.close();
	</script>
<%
	}
%>


