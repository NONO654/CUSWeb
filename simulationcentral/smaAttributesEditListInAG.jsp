<%@page import = "java.util.HashMap"%>
<%@page import="matrix.db.Context" %>
<%@page import="com.matrixone.apps.domain.util.CacheUtil"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
  <!-- (Irrelevant source removed.) -->
<%

matrix.db.Context context2 = 
(matrix.db.Context)request.getAttribute("context");
if (context2 != null)
context = context2;

String objectId  = emxGetParameter(request, "objectId");
String parentId  = emxGetParameter(request, "parentOID");

String timestamp = emxGetParameter(request, "timeStamp");
String refreshFrame = emxGetParameter(request, "refreshFrame");
String lang = request.getHeader("Accept-Language");
    
String[] sRowIds = emxGetParameterValues(request, "emxTableRowId");
HashMap hm = new HashMap();
hm.put("PCW-ToBeAddedAttributesInSAG", sRowIds);
CacheUtil.setCacheMap(context, "PCW-ToBeAddedAttributesInSAG", hm);
StringBuffer href = new StringBuffer(256);
href.append("../common/emxTableEdit.jsp")            
    .append("?objectId="+objectId)
    .append("&table=SMASimType_AddAttributesToGroup")
    .append("&header=AttributeGroup.AddAttributes.PageHeading")
    .append("&CancelButton=true")
    .append("&toolbar=SMASimType_SelectAttributesToolbar")
    .append("&selection=multiple")
    .append("&mode=edit")
    .append("&objectBased=false")
    .append("&sortColumnName=Name")
    .append("&HelpMarker=SMASimType_AddAttribute")
    .append("&program=jpo.simulation.AttributeGroup:getAttrsTableToAddInAG")
    .append("&postProcessURL=../simulationcentral/smaSubmitUtil.jsp&SubmitJPO=jpo.simulation.AttributeGroup:addAttributes")
    .append("&refreshAction=parentClose")
    .append("&objectBased=false")
    .append("&suiteKey=SimulationCentral")
    .append("&parentOID=").append(parentId);

%>
<script>
 
var EditTable = findFrame(getTopWindow(),"EditTable");
var url = "<%=href.toString()%>";
getTopWindow().location.href = url;
</script>




