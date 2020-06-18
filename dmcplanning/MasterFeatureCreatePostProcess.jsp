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
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%
    
  try {
	  %>
	  <script language="javascript" type="text/javaScript">
	  var listFrame = findFrame(getTopWindow(),'CFPModelLogicalFeatureTemplateTreeCategory');
	  listFrame.location.href=listFrame.location.href;
	  </script>
      <% 
	     }
     catch(Exception e)
     {
         throw new FrameworkException(e.getMessage());
     }

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

