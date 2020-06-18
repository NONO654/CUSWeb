<%--
  MasterFeaturePostProcess.jsp
  
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
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
    
  try {
	  String parentOID = emxGetParameter(request, "parentOID");
	  DomainObject parentObj = new DomainObject(parentOID);
	  String frameName = "";
	  
      String strParentType = parentObj.getType(context);
      
	  if(mxType.isOfParentType(context,strParentType, ConfigurationConstants.TYPE_PRODUCT_VARIANT)){
		  frameName = "FTRProductVariantResourceRulesCommand";
	  }
	  else{
		  frameName = "FTRResourceRulesCommand";
	  }
	  
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

