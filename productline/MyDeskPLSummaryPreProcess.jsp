<%--
  MyDeskPLSummaryPreProcess.jsp
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
  String editMode="edit";
  if(isMobileMode){
	  editMode="view";
  }
  String freezePane="Marketing Name,DerivationCue,LatestCue";
	%>
	   <script language="javascript" type="text/javaScript"> 
	   
	   var href = "../common/emxIndentedTable.jsp?program=emxProductLine:getAllTopLevelOwnedProductLines,emxProductLine:getAllTopLevelProductLines&freezePane=<%=XSSUtil.encodeForURL(context,freezePane)%>&expandProgram=emxProductLine:getProductLineHierarchy&programLabel=emxProduct.Filter.Owned,emxProduct.Filter.All&table=PLCMyDeskProductLineList&header=emxProduct.Menu.ProductLines&selection=multiple&toolbar=PLCProductLineHierarchyMenu&sortColumnName=Name&HelpMarker=emxhelpviewingproductlinehierarchy&editRootNode=true&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&suiteKey=ProductLine";
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

