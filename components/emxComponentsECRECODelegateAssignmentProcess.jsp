<%--  emxECRECODelegateAssignmentProcess.jsp  -

   Performs the action of connecting the objects by the given relationship

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsECRECODelegateAssignmentProcess.jsp.rca 1.3.3.2 Wed Oct 22 16:18:38 2008 przemek Experimental przemek $";
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="matrix.db.JPO"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.common.Change"%>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<%
  String objectId = request.getParameter("objectId");
  String[] strChangeObjID = new String[1];
  strChangeObjID[0] = objectId;
  String strNewAssigneeRowID = request.getParameter("emxTableRowId");
  String[] strNewAssigneeID = new String[1];
  String[] strNewAssigneeRowData = strNewAssigneeRowID.split("\\|"); 
  strNewAssigneeID[0] = strNewAssigneeRowData[1];
  String[] strOldAssigneeObjID = (String[])request.getParameterValues("arrObjIds1");
  String[] arrRelIds1 = (String[])request.getParameterValues("arrRelIds1");
  String assgn = (String)request.getParameter("ECAssign");
  Map reqMap1 = new HashMap();
  reqMap1.put("strChangeObjID",strChangeObjID);
  reqMap1.put("strNewAssigneeID",strNewAssigneeID);
  reqMap1.put("strOldAssigneeObjID",strOldAssigneeObjID);
  reqMap1.put("arrRelIds1",arrRelIds1);
  Change changeObject = new Change();
  changeObject.delegateAssignees(context, reqMap1);
%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>

<script language="javascript" type="text/javaScript">//<![CDATA[
    //getTopWindow().parent.getWindowOpener().parent.location.href = getTopWindow().parent.getWindowOpener().parent.location.href;
    getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
    getTopWindow().closeWindow();
</script>
