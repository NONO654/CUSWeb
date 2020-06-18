<%@include file = "../emxUICommonAppInclude.inc"%>

<html>
<head>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
function profileAction() {
	var objectId;
	var objDetailsTree = getTopWindow().objDetailsTree;
	if(objDetailsTree != null) {
		var currentRoot = objDetailsTree.currentRoot;
		if(currentRoot != null) {
			objectId = currentRoot.objectID;
		}
	}
	var url = "../PLMProfile/emxProfileTreeAction.jsp?"+decodeURIComponent(window.location.search.substring(1));
	if(objectId != null) {
		url += "&profileId="+objectId;
	}
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
