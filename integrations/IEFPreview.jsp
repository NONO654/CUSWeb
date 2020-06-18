<%--  IEFPreview.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file="MCADTopInclude.inc" %>

<%    
	//hardcoding to be removed
	String integrationName = "SolidWorks";

	MCADIntegrationSessionData oMCADData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	
	Context context						= oMCADData.getClonedContext(session);
	MCADMxUtil _util					= new MCADMxUtil(context, oMCADData.getLogger(), oMCADData.getResourceBundle(),oMCADData.getGlobalCache());
	
	MCADServerGeneralUtil _generalUtil	= new MCADServerGeneralUtil(context, oMCADData, integrationName);	

	String busId = emxGetParameter(request, "busId");

	String sCadTypeAttrName  = _util.getActualNameForAEFData(context,"attribute_CADType");
	BusinessObject busObject = new BusinessObject(busId);
	busObject.open(context);	

	String cadType			= _util.getAttributeForBO(context, busId, sCadTypeAttrName);
	Vector vDepDocDetails   = _generalUtil.getPreviewObjectInfo(context, busObject, cadType);

	busObject.close(context);

	String sPreviewObjId = "";
	String previewFormatName ="";
	String previewFileName ="";	
	
	if(vDepDocDetails != null && vDepDocDetails.size() >= 3)
	{
		sPreviewObjId = (String) vDepDocDetails.elementAt(0);		
		previewFormatName = (String) vDepDocDetails.elementAt(1);		
		previewFileName = (String) vDepDocDetails.elementAt(2);
		
	}	

	String previewservletPath = "/servlet/MCADBrowserServlet?BusObjectId=" + sPreviewObjId + "&FormatName=" + previewFormatName + "&FileName=" + previewFileName + "&Command=GetPreviewFile";

	
	
%>

<!--XSSOK-->
<jsp:forward page="<%=previewservletPath%>" />
