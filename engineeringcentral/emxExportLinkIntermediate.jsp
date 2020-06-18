<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>


<%
	String sOpenMode = emxGetParameter(request,"openMode");
	String sJOBId = emxGetParameter(request,"jobid");
%>


<script language="Javascript">
var openMode = "<xss:encodeForJavaScript><%=sOpenMode%></xss:encodeForJavaScript>";
var jobId = "<xss:encodeForJavaScript><%=sJOBId%></xss:encodeForJavaScript>";
getTopWindow().showModalDialog("../engineeringcentral/emxExportAllObjectToExcel.jsp?jobid="+jobId, 100, 100, true);
var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");

//contentFrame.location.href = "../common/emxIndentedTable.jsp?program=jpo.manufacturerequivalentpart.Part:getInProcessMEPs&table=MEPManufacturerEquivalentsPartSB&toolbar=MEPManufacturerEquivalentPartsToolbar&header=emxManufacturerEquivalentPart.label.ManufacturerEquivalentParts&selection=multiple&HelpMarker=emxhelpmepsummary&sortColumnName=Name&sortDirection=ascending&PrinterFriendly=true&suiteKey=ManufacturerEquivalentPart&autoFilter=false";

</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>



