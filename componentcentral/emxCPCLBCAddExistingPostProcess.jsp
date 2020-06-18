<%--  emxCPCLBCAddExistingPostProcess.jsp  -  This page is frameset page which has create line item dialog in the conent frame.

 (c) Dassault Systemes, 1993-2016.  All rights reserved.
--%>

<%@ include file="../emxUIFramesetUtil.inc"%>
<%@include file  ="emxCPCInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
try{
	String classId[]=emxGetParameterValues(request,"objectId");
	String PartIds[]=emxGetParameterValues(request,"emxTableRowId");
	session.setAttribute("CPCLBCAddExistingIds",PartIds);
	//This session object is removed, since we are using the same jsp for classify,reclassify, add existing from LBC
	session.removeAttribute("ReclassifyFromId");
	session.removeAttribute("ReclassifyToId");
	session.removeAttribute("strNewParentObjectId");
	session.removeAttribute("childIds");
	session.removeAttribute("stroldParentObjectId");

%>
<script language="Javascript">
		var objId='<%=classId[0]%>';
		getTopWindow().parent.location.href = "../componentcentral/emxCPCShowAttributeFS.jsp?CPCLBCClassId="+objId;
</script>
<%
}catch(Exception err){
err.printStackTrace();
}

%>







