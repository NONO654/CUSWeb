<%-- emxEngineeringAffectedItemsFilterProcess.jsp --
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>

<%
String objectid = emxGetParameter(request, "objectId");
String table = request.getParameter("table");
String categoryTreeName = emxGetParameter(request, "categoryTreeName");
boolean isMBOMInstalled = EngineeringUtil.isMBOMInstalled(context);

DomainObject doChange = new DomainObject(objectid);
String changeType = doChange.getInfo(context,"type");

table = (isMBOMInstalled && changeType.equalsIgnoreCase(PropertyUtil.getSchemaProperty(context,"type_MECO")) && 
		"MBOMMECOAffectedItemsIndentedSummary".equalsIgnoreCase(table)) ? "MBOMMECOAffectedItemsIndentedSummary" : "ENCECOAffectedItemsIndentedSummary";

 String strPolicy = doChange.getInfo(context, DomainConstants.SELECT_POLICY);

String strTypePartMarkup= PropertyUtil.getSchemaProperty(context,"type_PARTMARKUP");

%>
<script language="Javascript">

	var sURL = "";
	var objectID = window.parent.document.getElementById('objectId').value;
	var suiteKey = window.parent.document.getElementById('suiteKey').value;

	
	var ENCAffectedItemsTypeFilterValue= window.getTopWindow().document.getElementById('ENCAffectedItemsTypeFilter').value;
		
	var ENCAffectedItemsAssigneeFilterValue= window.getTopWindow().document.getElementById('ENCAffectedItemsAssigneeFilter');
	 	if(ENCAffectedItemsAssigneeFilterValue!= null){
			 ENCAffectedItemsAssigneeFilterValue = ENCAffectedItemsAssigneeFilterValue.value;
	 	}
	
	var ENCAffectedItemsRequestedChangeFilterValue= window.getTopWindow().document.getElementById('ENCAffectedItemsRequestedChangeFilter');
		if(ENCAffectedItemsRequestedChangeFilterValue!= null){
			ENCAffectedItemsRequestedChangeFilterValue = ENCAffectedItemsRequestedChangeFilterValue.value;
		}
	//Modified for IR-130572V6R2013 start
	//var emxExpandFilter = window.parent.document.getElementById('emxExpandFilter').value;
	var emxExpandFilter = window.parent.document.getElementById('emxExpandFilter');
	if(emxExpandFilter != null) {
		emxExpandFilter = emxExpandFilter.value;
	} else {
		emxExpandFilter = 1;
	}
	//Modified for IR-130572V6R2013 end
		//XSSOK
		sURL = "../common/emxIndentedTable.jsp?selectHandler=highlight3DAffectedItem&categoryTreeName=<%=XSSUtil.encodeForJavaScript(context,categoryTreeName)%>&program=emxECO:getAffectedItems&expandProgram=emxECO:getAffectedItems&table=<%=table%>&relationship=relationship_AffectedItem&header=emxEngineeringCentral.Change.AffectedItemsSummaryPageHeading&selection=multiple&toolbar=ENCAffectedItemsListToolBar,ENCAffectedItemsFilterToolBar&sortColumnName=Name&HelpMarker=emxhelpaffecteditemslist&objectId="+objectID+"&suiteKey="+suiteKey+"&ENCAffectedItemsTypeFilter="+ENCAffectedItemsTypeFilterValue+"&ENCAffectedItemsAssigneeFilter="+ENCAffectedItemsAssigneeFilterValue+"&ENCAffectedItemsRequestedChangeFilter="+ENCAffectedItemsRequestedChangeFilterValue+"&emxExpandFilter="+emxExpandFilter;
		

	var sURL1 ="";
	//XSSOK
	if(ENCAffectedItemsTypeFilterValue== "<%=strTypePartMarkup%>"){
		//XSSOK
		sURL1 = sURL = "../common/emxIndentedTable.jsp?selectHandler=highlight3DAffectedItem&categoryTreeName=<%=XSSUtil.encodeForJavaScript(context,categoryTreeName)%>&program=emxECO:getAffectedItems&table=ENCAffectedItemsIndentedSummary&header=emxEngineeringCentral.Change.AffectedItemsSummaryPageHeading&selection=multiple&toolbar=ENCAffectedItemsListToolBar,ENCAffectedItemsFilterToolBar&sortColumnName=Name&HelpMarker=emxhelpaffecteditemslist&objectId="+objectID+"&suiteKey="+suiteKey+"&ENCAffectedItemsTypeFilter="+ENCAffectedItemsTypeFilterValue+"&ENCAffectedItemsAssigneeFilter="+ENCAffectedItemsAssigneeFilterValue+"&ENCAffectedItemsRequestedChangeFilter="+ENCAffectedItemsRequestedChangeFilterValue+"&emxExpandFilter="+emxExpandFilter+"&expandLevelFilter=false";
		
		window.parent.frames.location.href	= sURL1;
	}
	else{
		if (emxExpandFilter !=1)
		sURL+="&expandByDefault=true";
		window.parent.frames.location.href	= sURL;
	}
	
</script>
