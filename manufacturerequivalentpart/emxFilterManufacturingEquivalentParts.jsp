<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%

String MEPName        = emxGetParameter(request, "MEPName");
String MEPType        = emxGetParameter(request, "MEPType");
String MEPDescription        = emxGetParameter(request, "MEPDescription");
String MEPStatus        = emxGetParameter(request, "MEPStatus");
String MEPState        = emxGetParameter(request, "MEPState");
String MEPManufacturer        = emxGetParameter(request, "MEPManufacturer");
String MEPPreference        = emxGetParameter(request, "MEPPreference");
String QueryLimit        = emxGetParameter(request, "QueryLimit");
%>

<script language="javascript" type="text/javaScript">
	var MEPName = "<xss:encodeForJavaScript><%=MEPName%></xss:encodeForJavaScript>";
	var MEPState = "<xss:encodeForJavaScript><%=MEPState%></xss:encodeForJavaScript>";
	var MEPType = "<xss:encodeForJavaScript><%=MEPType%></xss:encodeForJavaScript>";
	var QueryLimit =  "<xss:encodeForJavaScript><%=QueryLimit%></xss:encodeForJavaScript>";
	var MEPDescription        = "<xss:encodeForJavaScript><%=MEPDescription%></xss:encodeForJavaScript>";
	var MEPStatus        = "<xss:encodeForJavaScript><%=MEPStatus%></xss:encodeForJavaScript>";
	var MEPManufacturer        = "<xss:encodeForJavaScript><%=MEPManufacturer%></xss:encodeForJavaScript>";
	var MEPPreference        = "<xss:encodeForJavaScript><%=MEPPreference%></xss:encodeForJavaScript>";
	
	  var sURL = "../common/emxIndentedTable.jsp?program=jpo.manufacturerequivalentpart.Part:getFilteredMEP&table=MEPManufacturerEquivalentsPartSB&toolbar=MEPManufacturerEquivalentPartsToolbar&suiteKey=ManufacturerEquivalentPart&header=emxManufacturerEquivalentPart.label.ManufacturerEquivalentParts&selection=multiple&HelpMarker=emxhelpmepsummary&sortColumnName=Name&sortDirection=ascending&PrinterFriendly=true&MEPName="+MEPName+"&MEPState="+MEPState+"&MEPType="+MEPType+"&QueryLimit="+QueryLimit+"&MEPDescription="+MEPDescription+"&MEPStatus="+MEPStatus+"&MEPManufacturer_actualValue="+MEPManufacturer+"&MEPPreference="+MEPPreference;
	  top.findFrame(top, "content").location.href = sURL;
  </script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>



