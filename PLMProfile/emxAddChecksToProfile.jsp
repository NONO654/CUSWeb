<%-- emxAddChecksToProfile.jsp --%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.PLMProcessingGroup" %>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
	System.out.println("START emxAddChecksToProfile.jsp");

	String objectIds[] = emxGetParameterValues(request,"emxTableRowId");
	
	if(objectIds != null && objectIds.length > 0) {
		String parentOID = emxGetParameter(request,"parentOID");
		String timeStamp   		= emxGetParameter(request,"timeStamp");
		HashMap tableData 	= indentedTableBean.getTableData(timeStamp);
		TreeMap indexedList = (TreeMap)tableData.get("IndexedObjectList");
		PLMProcessingGroup pgInstance = PLMProcessingGroup.getInstance(context, parentOID);
		String profileId = pgInstance.getProfile(context);		
		HashMap requestMap 		= UINavigatorUtil.getRequestParameterMap(request);
		HashMap reqValuesMap    = UINavigatorUtil.getRequestParameterValuesMap(request);
		requestMap.put("RequestValuesMap", reqValuesMap); 
		requestMap.put("SelectedObjectId", objectIds);
		requestMap.put("parentOID", parentOID);
		requestMap.put("IndexedObjectList",indexedList);
		System.out.println("SEND emxAddChecksToProfile.jsp");
		JPO.invoke(context, "emxProfileCheck", null, "addCheck", JPO.packArgs(requestMap));
		%>
		<script language="javascript" src="../common/scripts/emxUICore.js"></script>
		<script language="javascript">
		getTopWindow().closeSlideInDialog();
		getTopWindow().location.href = "../common/emxTree.jsp?objectId=<%=profileId%>";
		</script>
		<%
	} else {
		%>
		<script language="javascript" src="../common/scripts/emxUICore.js"></script>
		<script language="javascript">
		getTopWindow().closeSlideInDialog();
		</script>
		<%
	}

	System.out.println("END emxAddChecksToProfile.jsp");
%>
	

