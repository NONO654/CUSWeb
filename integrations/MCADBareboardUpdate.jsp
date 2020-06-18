<%--  MCADBareboardUpdate.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>

<% 	 
	String sObjId					= emxGetParameter(request, "busId");
	String integrationName			= emxGetParameter(request, "integrationName");
	String refreshBasePage			= emxGetParameter(request, "refresh");
	String sBareboardName			= emxGetParameter(request, "bareboardName");
	String sBareboardNameChecked	= emxGetParameter(request, "sBareboardNameChecked");

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	
	Context context		= integSessionData.getClonedContext(session);
	MCADMxUtil _util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	BusinessObject bus = new BusinessObject(sObjId);
	sBareboardName.trim();
	if(sBareboardName.length() <= 0)
	{		
		bus.open(context);
		sBareboardName = bus.getName();
		bus.close(context);
	}

	String attrBareboardName = _util.getActualNameForAEFData(context,"attribute_BareboardNames");
	_util.setAttributeValue(context, bus, attrBareboardName, sBareboardName);

	String ebomSyncURL = "MCADEBOMSynchronization.jsp?busDetails="+ integrationName+ "|" + refreshBasePage+ "|" + sObjId+"&sBareboardNameChecked=" + sBareboardNameChecked;
%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<!--XSSOK-->
<jsp:forward page="<%= ebomSyncURL %>" />
