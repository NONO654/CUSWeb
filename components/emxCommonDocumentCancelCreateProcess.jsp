<%--   emxCommonDocumentCancelCreateProcess.jsp -- This is the process page which edits the Route Template Object.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program  

  static const char RCSID[] = $Id: emxCommonDocumentCancelCreateProcess.jsp.rca 1.6 Wed Oct 22 16:17:46 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>


<jsp:useBean id="documentFormBean" scope="session"
                                   class="com.matrixone.apps.common.util.FormBean" />

<%  
  String formKeyValue = documentFormBean.getFormKey();
  documentFormBean.removeFormInstance(session,request);

  if(formKeyValue != null)
  {
    session.removeAttribute(formKeyValue);
  }
%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript">
  getTopWindow().closeWindow();
</script>


