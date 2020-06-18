<%--  emxEngrCreateApplicationPartHiddenDialog.jsp   -   FS page for Create Part dialog
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>

<html>
<head>

<%
  String initSource = emxGetParameter(request,"initSource");

  if (initSource == null){
           initSource = "";
     }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");


  // ----------------- Do Not Edit Above ------------------------------

  String emxTableRowId = emxGetParameter(request,"emxTableRowId");
  String parentOID = emxGetParameter(request,"parentOID");
  String SuiteDirectory = emxGetParameter(request,"SuiteDirectory");


  String selectedEPId = null;

  if(emxTableRowId != null && emxTableRowId.indexOf("|") != -1) {
     selectedEPId = emxTableRowId.substring(emxTableRowId.indexOf("|")+1);
  }
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<%
   if(parentOID != null && selectedEPId != null) {
      String url = "./emxEngrCreateApplicationPartDialogFS.jsp?objectId="+selectedEPId+"&assemblyPartId="+parentOID+"&suiteKey="+suiteKey+"&jsTreeID="+jsTreeID+"&SuiteDirectory="+SuiteDirectory;
%>
<script language="javascript">
//XSSOK
      showModalDialog('<%=XSSUtil.encodeForJavaScript(context,url)%>',600,700);
</script>
<%
   }else {
%>
<script language="javascript">
      alert("Invalid data");
</script>
<%
   }
%>

</head>
</html>


