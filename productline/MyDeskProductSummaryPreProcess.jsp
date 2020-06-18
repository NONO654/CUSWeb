<%--
  MyDeskProductSummaryPreProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>


<%
try
{ 
  boolean isMobileMode = UINavigatorUtil.isMobile(context);
  String editLink="true";
  if(isMobileMode){
	  editLink="false";
  }
  
	%>
	   <script language="javascript" type="text/javaScript">          
	   var href = "../common/emxIndentedTable.jsp?program=emxModel:getAllModels&expandProgram=emxModel:getMyDeskProductHierarchy&table=PLCMyDeskProductList&header=emxProduct.Menu.Products&selection=multiple&freezePane=MarketingName,DerivationCue,LatestCue&toolbar=PLCProductListToolBar&sortColumnName=MarketingName&HelpMarker=emxhelpproductlist&mode=view&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&suiteKey=ProductLine";
	   var contentFrame = findFrame (getTopWindow(), "content");
       contentFrame.location.href = href;
       </script>
	<%
  
}
catch(Exception e){
    session.putValue("error.message", e.getMessage());
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

