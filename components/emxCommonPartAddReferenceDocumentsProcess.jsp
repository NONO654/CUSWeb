<%--
   emxCommonPartAddReferenceDocumentsProcess.jsp   - The Processing page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxCommonPartAddReferenceDocumentsProcess.jsp.rca 1.1.7.5 Wed Oct 22 16:18:41 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUITableUtil.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUIActionbar.js"></script>

<script language="javascript">
<%
    ContextUtil.startTransaction(context,true);
    try
    {
		  Part part = (Part)DomainObject.newInstance(context,DomainConstants.TYPE_PART,"Common");
		  String objectId = emxGetParameter(request, "objectId");
		  String[] refDocObjIds = emxGetParameterValues(request, "emxTableRowId");
		  part.setId(objectId);
		  part.addReferenceDocuments(context, refDocObjIds);
    }
    catch(Exception ex)
    {
		ContextUtil.abortTransaction(context);
		throw ex;
    }
		ContextUtil.commitTransaction(context);
%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>

	var parentDetailsFrame = findFrame(getTopWindow().getWindowOpener(), "listDisplay");
	parentDetailsFrame.parent.document.location.href=parentDetailsFrame.parent.document.location.href;
	getTopWindow().closeWindow();
</script>
