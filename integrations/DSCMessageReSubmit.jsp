<%--  DSCMessageReSubmit.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.batchprocessor.*,com.matrixone.MCADIntegration.utils.*" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ page import="matrix.db.*" %>
<%@ page import="com.matrixone.MCADIntegration.utils.MCADXMLUtils"%>
<%@ page import="com.matrixone.MCADIntegration.utils.xml.IEFXmlNode"%>
<%
	String objectID								  =Request.getParameter(request,"objectId");

	MCADIntegrationSessionData integSessionData	  = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	
	String acceptLanguage						  = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

	Context context								  = integSessionData.getClonedContext(session);
	MCADMxUtil util								  = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	String successMessage						  = serverResourceBundle.getString("mcadIntegration.Server.Message.MessageResubmitted");
	String errorMessage							  = "";
	String mqlUnSignCommand[]= new String[3];
	mqlUnSignCommand[0]= objectID;
	mqlUnSignCommand[1] = "signature";
	mqlUnSignCommand[2] = "all";
	String mqlSignReSubmitCommand[] = new String[5]; 
	mqlSignReSubmitCommand[0] = objectID;
	mqlSignReSubmitCommand[1]= "signature";
	mqlSignReSubmitCommand[2] = "ReSubmit";
	mqlSignReSubmitCommand[3] = "comment";
	mqlSignReSubmitCommand[4] = "";
	String sResult = util.executeMQL(context,"unsign bus $1 $2 $3",mqlUnSignCommand);
	        
	if(sResult.startsWith("true|"))
		sResult      = util.executeMQL(context,"approve bus $1 $2 $3 $4 $5",mqlSignReSubmitCommand);
	
	if(sResult.startsWith("true|"))
	{
		DSCMessage message						 = new DSCMessage(context, objectID);
		message.open(context);

		message.promote(context);
		DSCQueue queue	 = message.getRelatedQueue(context);
		AttributeList attributeList = new AttributeList();
		String  dscErrorMessageName				= DSCBackgroundProcessorUtil.getActualNameForAEFData(context, "attribute_ErrorMessage");
		String  abortedMessageName					= DSCBackgroundProcessorUtil.getActualNameForAEFData(context, "attribute_AbortRequested");
		attributeList.addElement(new Attribute(new AttributeType(dscErrorMessageName), ""));
		attributeList.addElement(new Attribute(new AttributeType(abortedMessageName), "No"));			
		message.setAttributes(context, attributeList);		
		message.setCompletionStatus(context, "None");

		//L86 : START
		String messageBody 	= message.getBody(context);
		IEFXmlNode messageBodyPacket 	= MCADXMLUtils.parse(messageBody, "UTF8");
		String ignoreLock = null;
		
		if(messageBodyPacket.getChildByName("ignoreLock") != null)
		{
	      ignoreLock = messageBodyPacket.getChildByName("ignoreLock").getFirstChild().getContent();
		if(ignoreLock !=null && ignoreLock.length() > 0 && ignoreLock.equalsIgnoreCase("false"))
		{
		String activeMessageRelName           = DSCBackgroundProcessorUtil.getActualNameForAEFData(context, "relationship_ActiveMessage");
		String failedMessageRelName           = DSCBackgroundProcessorUtil.getActualNameForAEFData(context, "relationship_FailedMessage");

                BusinessObject busObject = null;
		RelationshipList	relList = util.getFromRelationship(context, message, (short)0, false);

    	if (relList != null)
    	{
    		RelationshipItr relItr = new RelationshipItr(relList);
    		while (relItr.next())
    		{
    			Relationship returnRel = relItr.obj();
    			returnRel.open(context);
    			if(returnRel.getTypeName().equals("failedMessageRelName"));
    			{
    				busObject =  returnRel.getTo();
    			}
    		}
    	}


		DSCBackgroundProcessorUtil.disconnectBusObjects(context, message.getObjectId(context), busObject.getObjectId(context), failedMessageRelName, true);						
		DSCBackgroundProcessorUtil.connectBusObjects(context, message.getObjectId(context), busObject.getObjectId(context), activeMessageRelName, true, null);
		}
		}
	
		queue.open(context);
		queue.addPendingMessage(context,message);
		queue.close(context);

		message.close(context);
	}
	else
	{
		errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.FailedToSignForResubmit")+ sResult.substring(sResult.indexOf("|")+1, sResult.length()) ;
		MCADServerException.createException(errorMessage, null);
	}
%>

<html>
<head>
<script language="javascript">

function refresh()
{
  //XSSOK
  alert("<%= successMessage %>");
  window.opener.location.reload();
}

</script>
</head>
<%@include file = "MCADBottomErrorInclude.inc"%>
<body onLoad="refresh()">

</body>
</html>

