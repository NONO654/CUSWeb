<%--
  ConfigurationFeaturePreProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
                 
<%
  try
  {	  
	  String strObjIdContext = "";
	  String strSuiteKey = "";
	  String strDefaultCategory="FTRContextConfigurationFeatures";

	  strObjIdContext = XSSUtil.encodeForURL(context,emxGetParameter(request, "objectId"));
      strSuiteKey = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "suiteKey"));
	  boolean isMobileMode = UINavigatorUtil.isMobile(context);
	  boolean isFTRUser = ConfigurationUtil.isFTRUser(context);
	  boolean isCMMUser = ConfigurationUtil.isCMMUser(context);
	  if(isMobileMode||(!isFTRUser&&!isCMMUser)){
		  strDefaultCategory="FTRContextConfigurationFeaturesMobile";//read only
	  }
	  
	  String  strMode  = emxGetParameter(request, "mode");
      String  strCFId  = emxGetParameter(request, "ConfFeatId");
      if("getSelectionType".equalsIgnoreCase(strMode))
      {
    	  DomainObject domObj = new DomainObject(strCFId);
    	  String strSelectionType = domObj.getInfo(context, "attribute[Configuration Selection Type]");
    	  out.println("SelectionType=");
		  out.println(strSelectionType);
		  out.println(";");
      }
      else
      {
%>
	  <script language="javascript" type="text/javaScript">
         var actionURL = "../common/emxTree.jsp?objectId=<%=strObjIdContext%>&mode=insert&suiteKey=<%=strSuiteKey%>&DefaultCategory=<%=strDefaultCategory%>";
		 showModalDialog(actionURL, "600", "500");
	  </script>
<%
      }
  }
  catch(Exception e){
    	    session.putValue("error.message", e.getMessage());
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
