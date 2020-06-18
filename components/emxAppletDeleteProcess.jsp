<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "emxComponentsAppletInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<%
Map requestMap = (Map) session.getAttribute("emxCommonDocumentCheckinData");
String filePath = (String)requestMap.get("updates");
HashMap props = new HashMap();
props.put("debug", "true");
props.put("filePath", filePath);

addApplet(request, response, out, context, "com.matrixone.fcs.applet.DocumentDeleteApplet", 1, 1, props);
%>


