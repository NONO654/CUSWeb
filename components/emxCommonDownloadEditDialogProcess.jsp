<%-- emxCommonDownloadEditDialogProcess.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDownloadEditDialogProcess.jsp.rca 1.1.7.5 Wed Oct 22 16:17:49 2008 przemek Experimental przemek $ 
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%
	String strRelId = emxGetParameter(request, "relId");
	DomainRelationship.setAttributeValue(context, strRelId, "Download Status", emxGetParameter(request, "status"));
%>
<script>
    //getTopWindow().getWindowOpener().parent.refreshTableContent();

	  //parent.listDisplay.location.reload();

	//getTopWindow().getWindowOpener().refreshTableBody();
	//getTopWindow().close();
    getTopWindow().getWindowOpener().parent.location.reload();
    window.closeWindow();
</script>
