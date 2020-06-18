<%--  IEFBaselinePreProcessing.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>

<%@ page import="java.util.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*,matrix.db.*, com.matrixone.MCADIntegration.utils.*"  %>
<%@ page import="matrix.db.*"  %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	String parentObjectId   =Request.getParameter(request,"parentObjectId");
	String objectIds		=Request.getParameter(request,"objectIdList");
	String baselineName		=Request.getParameter(request,"baselineName");
	String baselineDesc		=Request.getParameter(request,"baselineDesc");
	String baselineView		=Request.getParameter(request,"baselineView");
	String integrationName	=Request.getParameter(request,"integrationName");
	String selectedProgram	=Request.getParameter(request,"selectedProgram");	
	
	boolean  isOverWrite		=Request.getParameter(request,"isOverWrite") == null ? false:true;
	boolean isNameAlreadyExist  =  false;

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

    Context context				= integSessionData.getContext();
	ENOCsrfGuard.validateRequest(context, session, request, response);
    MCADServerLogger logger		= integSessionData.getLogger();
    MCADMxUtil util				= new MCADMxUtil(context, logger, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());	
	
	Hashtable values			=  new  Hashtable(1);
	values.put("NAME",baselineName);
	String errorMessage			=  integSessionData.getStringResource("mcadIntegration.Server.FieldName.BaselineNameAlreadyExist",values);
	String baselineTypeName 	= util.getActualNameForAEFData(context,"type_DECBaseline");

	if(integrationName==null)
	{		
		integrationName = util.getIntegrationName(context, parentObjectId);
		request.setAttribute("integrationName",integrationName);
	}	

	if(!isOverWrite)
		isNameAlreadyExist  =util.doesBusinessObjectExist(context,baselineTypeName,baselineName,"-");

	StringBuffer urlBuffer = new StringBuffer();
	urlBuffer.append("./IEFBaselineProcessing.jsp?objectIdList="+objectIds);
	urlBuffer.append("&objectId=");
	urlBuffer.append(parentObjectId);
	urlBuffer.append("&baselineName=");
	urlBuffer.append(baselineName);
	urlBuffer.append("&baselineDesc=");
	urlBuffer.append(baselineDesc);
	urlBuffer.append("&baselineView=");
	urlBuffer.append(baselineView);
	urlBuffer.append("&selectedProgram=");
	urlBuffer.append(selectedProgram);
	urlBuffer.append("&errorMessage=");
	urlBuffer.append(errorMessage);
	urlBuffer.append("&isOverWrite=");
	urlBuffer.append(isOverWrite);

	String forwardPage = urlBuffer.toString();
	
	if(isNameAlreadyExist)
	{		
		//If Name already exists then stop progress clock and go to 1st page.
%>
	<script> 
		var isOverwrite = confirm('<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>');
		if(!isOverwrite)
			{
				parent.stopProgressClock();
				parent.window.location.href = "./IEFBaselineFS.jsp?objectIdList=<%=XSSUtil.encodeForURL(context,objectIds)%>&objectId=<%=XSSUtil.encodeForURL(context,parentObjectId)%>&baselineName=<%=XSSUtil.encodeForURL(context,baselineName)%>&baselineDesc=<%=XSSUtil.encodeForURL(context,baselineDesc)%>&selectedProgram=<%=XSSUtil.encodeForURL(context,selectedProgram)%>";
			}
			else
			{
				
				window.location.href = "./IEFBaselineProcessing.jsp?objectIdList=<%=XSSUtil.encodeForURL(context,objectIds)%>&objectId=<%=XSSUtil.encodeForURL(context,parentObjectId)%>&baselineName=<%=XSSUtil.encodeForURL(context,baselineName)%>&baselineDesc=<%=XSSUtil.encodeForURL(context,baselineDesc)%>&selectedProgram=<%=XSSUtil.encodeForURL(context,selectedProgram)%>&isOverWrite=true";

				top.opener.location.reload();

			}
	</script>
<%
	}
	else
	{
	%>
	    <!--XSSOK CAUSED REG-->
		<jsp:forward page="<%=forwardPage%>" />
	<%
	}
	%>


