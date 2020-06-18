<%--
  ConfigSBApplyProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.jdom.*"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

  <jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<html>
<body>

<%
	try {
		
		Document tableDoc = (Document) request.getAttribute("XMLDoc");
		Map requestMap = (Map) request.getAttribute("requestMap");
		String logicalFeatureID = "";
        
		if (requestMap != null) {
			logicalFeatureID = (String) requestMap.get("objectId");
		}

		if (tableDoc != null) {
			Element rootElement = tableDoc.getRootElement();
			
			MapList changeMapList = indentedTableBean.getChangedRowsMapFromElement(context, rootElement);
			
			LogicalFeature lfBean = new LogicalFeature(logicalFeatureID);
			lfBean.updateEffectivityExpressionValues(context, changeMapList);
		}
	} 
	catch (Exception e) {
		session.putValue("error.message", e.getMessage());
	}
%>
</body>
</html>
