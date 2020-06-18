<%--
  ConfigurationRuleCreateEditPostProcess.jsp
  
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of 
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%
  try {
		  String frameName = "FTRMatrixRulesCommand";
		  %>
			  <script language="javascript" type="text/javaScript">
			  var listFrame = findFrame(getTopWindow(),'<%=XSSUtil.encodeForJavaScript(context,frameName)%>');
			  listFrame.editableTable.loadData();
			  listFrame.rebuildView();
			  </script>
	      <% 
	   }
     catch(Exception e)
     {
         throw new FrameworkException(e.getMessage());
     }

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

