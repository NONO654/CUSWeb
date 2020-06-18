<%@ include file="../emxUICommonAppInclude.inc"%> 
<%@page import="matrix.db.*"%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.apps.domain.util.*"%>

<%	
	String sOID 			= request.getParameter("objectId");
	String sSortOrder 		= request.getParameter("sortOrder");
	String sStartRoute 		= request.getParameter("startRoute");
	RelationshipType rType 	= new RelationshipType(DomainConstants.RELATIONSHIP_ROUTE_NODE);
	DomainObject doRoute 	= new DomainObject(sOID);
	String sTypeRoute 		= doRoute.getInfo(context, "attribute["+ DomainConstants.ATTRIBUTE_ROUTE_BASE_PURPOSE +"]");	
	
	StringList busSelects = new StringList();
	StringList relSelects = new StringList();
	busSelects.add(DomainConstants.SELECT_ID);
	relSelects.add(DomainConstants.SELECT_RELATIONSHIP_ID);
	
	MapList mlRouteNodes = doRoute.getRelatedObjects(context, DomainConstants.RELATIONSHIP_ROUTE_NODE, DomainConstants.TYPE_PERSON, busSelects, relSelects, false, true, (short)1, "", "", 0);

	for(int i = 0; i < mlRouteNodes.size(); i++) {	
		Map mRouteNode 			= (Map)mlRouteNodes.get(i);
		String sRID 			= (String)mRouteNode.get(DomainConstants.SELECT_RELATIONSHIP_ID);
		DomainRelationship dRel = new DomainRelationship(sRID);		
		dRel.remove(context);		
	}
	
	if(!"".equals(sSortOrder)) {
	
		String[] aSortOrder = sSortOrder.split(",");
			
		for (int i = 0; i < aSortOrder.length; i++) {
		
			String sID 				= aSortOrder[i];
			String sUser 			= request.getParameter("user"  + sID);
			String sTitle 			= request.getParameter("title" + sID);
			String sType 			= request.getParameter("type"  + sID);
			String sDate 			= request.getParameter("date"  + sID);
			String sInstructions 	= request.getParameter("inst"  + sID);
			String sSequence 		= request.getParameter("seq"   + sID);
			String sRule 			= request.getParameter("rule"  + sID);
			
			if(null == sTitle) { sTitle = ""; }
			if(null == sDate) { sDate = ""; } else if (!sDate.equals("")) {sDate = sDate + " 5:00:00 PM"; }
			if(null == sInstructions) { sInstructions = ""; }
		
			sUser 				= sUser.substring(sUser.indexOf("(") + 1);
			sUser 				= sUser.substring(0, sUser.length() - 1);
			String sOIDPerson	= PersonUtil.getPersonObjectID(context, sUser);			
			
			DomainRelationship dRel = doRoute.addToObject(context, rType, sOIDPerson);
			
			dRel.setAttributeValue(context, DomainConstants.ATTRIBUTE_TITLE, sTitle);
			dRel.setAttributeValue(context, DomainConstants.ATTRIBUTE_SCHEDULED_COMPLETION_DATE, sDate);
			dRel.setAttributeValue(context, DomainConstants.ATTRIBUTE_ROUTE_INSTRUCTIONS, sInstructions);
			dRel.setAttributeValue(context, DomainConstants.ATTRIBUTE_ROUTE_SEQUENCE, sSequence);
			dRel.setAttributeValue(context, DomainConstants.ATTRIBUTE_SEQUENCE_ORDER, String.valueOf(i));
			dRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_attribute_ParallelNodeProcessionRule), sRule);
			
			if(null == sType || sType.equals("null")) {
				if(sTypeRoute.equals("Approval")) 	{ sType = "Approve"; }
				else if(sTypeRoute.equals("Review")){ sType = "Comment"; }
				else 							  	{ sType = ""; }
			}
			
			dRel.setAttributeValue(context, "Route Action", sType);
		}

	}
%>

<html>
	<head>	
	<script src="scripts/emxUICore.js" type="text/javascript"></script>
		<script> 
<%	if(sStartRoute.equalsIgnoreCase("TRUE")) { %>
			getTopWindow().getWindowOpener().frames[0].document.location.href = "../components/emxRouteStartPreProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context, sOID)%>";			
<%	} else { %>
		getTopWindow().getWindowOpener().document.location.href = getTopWindow().getWindowOpener().document.location.href;		
<% } %>
			window.closeWindow();			
		</script>		
	</head>
	<body>
		Saving ...
	</body>
</html>
