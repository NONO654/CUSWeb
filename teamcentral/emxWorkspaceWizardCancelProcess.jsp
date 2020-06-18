<%--   emxWorkspaceWizardCancelProcess.jsp -- This is the process page which deletes the created Workspace Object.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxWorkspaceWizardCancelProcess.jsp.rca 1.7 Wed Oct 12 16:18:22 2016 przemek Experimental przemek $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.UIUtil"%>

<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>


 <%
	    String projectId = emxGetParameter(request,"projectId");
		if(UIUtil.isNotNullAndNotEmpty(projectId)) {
			MqlUtil.mqlCommand(context, "delete bus $1", false, projectId);
		}
 %>
 <script language="Javascript">
  window.closeWindow();
  </script>


 
