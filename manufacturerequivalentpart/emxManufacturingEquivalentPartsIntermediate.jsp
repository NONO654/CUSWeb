<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>


<%
	String sTotalMEPCount = MqlUtil.mqlCommand(context,"eval expr 'count true' on temp que bus Part * * where 'policy == \"Manufacturer Equivalent\"'");
	String sInitialQueryLimit = FrameworkProperties.getProperty(context,"emxManufacturerEquivalentPart.MEPInitialLoad.QueryLimit");
	int initialLimit = Integer.parseInt(sInitialQueryLimit);
	int maxQeryLimit = 32000;
	if(initialLimit > maxQeryLimit)
		sInitialQueryLimit = Integer.toString(maxQeryLimit);
	
	String sOpenMode = emxGetParameter(request,"openMode");
	String sJOBId = emxGetParameter(request,"jobid");
%>


<script language="Javascript">

//XSSOK
var totalMEPCount = <%=sTotalMEPCount%>;
var initialQueryLimit = <%=sInitialQueryLimit%>;
var openMode = "<xss:encodeForJavaScript><%=sOpenMode%></xss:encodeForJavaScript>";
var jobId = "<xss:encodeForJavaScript><%=sJOBId%></xss:encodeForJavaScript>";

if(totalMEPCount >initialQueryLimit)
	top.showSlideInDialog("../common/emxForm.jsp?form=FilterMEP&submitAction=doNothing&formHeader=emxManufacturerEquivalentPart.MEPCriteriaForm.Header&mode=edit&HelpMarker=emxhelppartbomadd&suiteKey=ManufacturerEquivalentPart&initialLoad=true&postProcessURL=../manufacturerequivalentpart/emxFilterManufacturingEquivalentParts.jsp", true);


if(openMode == "Link")
	top.showModalDialog("../manufacturerequivalentpart/emxMEPExcelExport.jsp?jobid="+jobId, 100, 100, true);
var contentFrame = top.findFrame(top, "content");

contentFrame.location.href = "../common/emxIndentedTable.jsp?program=jpo.manufacturerequivalentpart.Part:getInProcessMEPs&table=MEPManufacturerEquivalentsPartSB&toolbar=MEPManufacturerEquivalentPartsToolbar&header=emxManufacturerEquivalentPart.label.ManufacturerEquivalentParts&selection=multiple&HelpMarker=emxhelpmepsummary&sortColumnName=Name&sortDirection=ascending&PrinterFriendly=true&customSearchCriteria=true&suiteKey=ManufacturerEquivalentPart";

</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>



