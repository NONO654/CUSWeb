<%--  emxCPCReClassify.jsp  -  This page is frameset page which has create line item dialog in the conent frame.

 (c) Dassault Systemes, 1993-2016.  All rights reserved.
--%>

<%@ include file="../emxUIFramesetUtil.inc"%>
<%@include file  ="emxCPCInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
try{
	String parentOID=(String)emxGetParameter(request,"parentOID");
	String selectedemxIds[]=emxGetParameterValues(request,"emxTableRowId");
	String selectedIds="";
	//Adding all the selected ObjectIds of the Parts selected to a comma seperated list,
	//to reuse the existing code in emxCPCMultipleClassificationReclassifyProcess.jsp
	for(int j=0;j<selectedemxIds.length;j++){
		selectedIds+=selectedemxIds[j]+",";
	}
	String strForwardPageUrl="../common/emxFullSearch.jsp?field=TYPES=type_Libraries&showInitialResults=false&table=CPCSEPPartsGlobalSearchResults&selection=single&HelpMarker=emxhelpfullsearch&submitLabel=Next&submitAction=refreshCaller&viewFormBased=true&cancelLabel=Cancel&submitURL=../componentcentral/emxCPCReClassifyPartTest.jsp?selectedPartIds="+selectedIds+"&parentOID="+parentOID;
%>
<script language="javascript">
	window.open('<xss:encodeForJavaScript><%=strForwardPageUrl%></xss:encodeForJavaScript>','myWindow','width=700,height=600', true);
</script>
<%
}catch(Exception err){
err.printStackTrace();
}
%>
