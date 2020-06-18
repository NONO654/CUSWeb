<%--  DELBT_emxCloneIntermediate.jsp
   Copyright (c) 1992-2012 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<%
String strAction="";
String objectId = emxGetParameter(request, "objectId");
String typeStr = emxGetParameter(request,"type");
strAction =emxGetParameter(request,"action");
String parentOID = emxGetParameter(request, "parentOID");
String copyObjectId = emxGetParameter(request, "objectId");
String pfId = null;
String pfAutoNameGenerator = "FALSE";
%>

<script language="Javascript">
var sURL = "../common/emxCreate.jsp?submitAction=treeContent&nameField=both&header=CloneBlendingTable&form=DELBT_Clone&suiteKey=blendingtablesuite&copyObjectId=<%=objectId%>&parentOID=<%=parentOID%>&targetLocation=popup&type=type_DEL_BlendingTable&preProcessJavaScript=preProcessInCreatePartClone&TypeActual=DEL_BlendingTable&createJPO=emxBlendingTable:checkLicenseAndCloneObject&submitAction=treeContent";
window.location.href = sURL;
</script>

