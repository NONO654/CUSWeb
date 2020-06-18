<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.DomainObject"%>
<%@ page import="com.dassault_systemes.knowledge_expert.iplmassessmentmodel.ProfileConstants.Type"%>

<%
    String objectId = emxGetParameter(request, "profileId");
	if(null == objectId)
		objectId = emxGetParameter(request, "objectId");
	String type = DomainObject.newInstance(context, objectId).getInfo(context, DomainObject.SELECT_TYPE);
	boolean readOnly = !type.equals(Type.PLMProfile.getType());
%>

<html>
<head>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
function getParameter(paramName) {
	var searchString = window.location.search.substring(1);
	if(searchString.indexOf(paramName) !== -1){
		var index = searchString.indexOf(paramName)+paramName.length+1;
		var url = searchString.substring(index, searchString.length);
		url = url.replace("&", "?");
	}
	url = decodeURIComponent(url);
	<% if(readOnly) {%>
	url = url.replace("&selection=multiple", "");
	url = url.replace("emxTableEdit.jsp", "emxTable.jsp");
	<%}%>
	return url;
}
function profileAction() {
	var url = getParameter("profileAction");
	var contentFrame = getTopWindow().findFrame(getTopWindow(), "detailsDisplay"); 
	if(contentFrame) {
		contentFrame.document.location.href = url;
	}
}
profileAction();
</script>
</head>
<body>
</body>
</html>
