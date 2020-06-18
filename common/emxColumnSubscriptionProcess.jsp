<%--  emxColumnSubscriptionProcess.jsp - to subscribe all events for object from column
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.apps.common.util.*"%>
<%@page import="matrix.util.StringList"%>
<%@page import="matrix.util.Pattern"%>

<%	
	HashMap requestMap 		= UINavigatorUtil.getRequestParameterMap(request);
	String events[]    		= emxGetParameterValues(request, "chkSubscribeEvent");
	String sOID				= emxGetParameter(request, "objectId");
	String sRowID			= emxGetParameter(request, "rowId");
	String sOIDSubscription	= emxGetParameter(request, "subscriptionId");
	
	if((null != sOIDSubscription) && (!"".equals(sOIDSubscription))) {
		
		Pattern pTypes = new Pattern("Person");

		Map mFilter = new HashMap();
		mFilter.put("name", context.getUser());
		
		StringList selBUS = new StringList();
		StringList selREL = new StringList();
		selBUS.add(DomainConstants.SELECT_TYPE);
		selBUS.add(DomainConstants.SELECT_NAME);
		selREL.add(DomainConstants.SELECT_RELATIONSHIP_ID);
		
		DomainObject doSubscription = new DomainObject(sOIDSubscription);
		
		String relPattern = DomainConstants.RELATIONSHIP_PUBLISH+","+ DomainConstants.RELATIONSHIP_SUBSCRIBED_PERSON;
		String typePattern = DomainConstants.TYPE_EVENT+","+ DomainConstants.TYPE_PERSON;
		MapList mlSubscriptions = doSubscription.getRelatedObjects(context, relPattern, typePattern, selBUS, selREL, false, true, (short) 2, "", "", 0, pTypes, null, mFilter);

		for(int i = 0; i < mlSubscriptions.size(); i++) {
			Map mSubscription = (Map)mlSubscriptions.get(i);
			String sRID = (String)mSubscription.get(DomainConstants.SELECT_RELATIONSHIP_ID);
			DomainRelationship.disconnect(context, sRID);
		}
	
	} else {
	
		SubscriptionUtil.createSubscriptions(context, sOID, events, requestMap);
	}
	
%>
<html>
	<script language="javascript" type="text/javaScript">	
		parent.emxEditableTable.refreshRowByRowId("<%=XSSUtil.encodeForJavaScript(context, sRowID)%>");
	</script>	
</html>
