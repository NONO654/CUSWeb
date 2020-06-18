<%--
  DependencyReportPreProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>

<html>
<head>

  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
</head>

<body>
<%
  try{
     ProductLineUtil utilBean = new ProductLineUtil();
     //Getting the table row ids of the selected objects from the request
     String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
     //Getting the object ids from the table row ids
     String arrObjectIds[] = null;
     arrObjectIds = utilBean.getObjectIds(arrTableRowIds);
%>
    <script language="javascript" type="text/javaScript">
    var url="../common/emxTable.jsp?table=FTRProductDependencyList&program=LogicalFeature:getDependencyReport&header=emxProduct.Heading.DependencyReport&mode=ListPage&HelpMarker=emxhelpproductdependencyreport&emxTableRowId=<%=XSSUtil.encodeForURL(context,arrObjectIds[0])%>&objectId=<%=XSSUtil.encodeForURL(context,arrObjectIds[0])%>&suiteKey=Configuration";
    showNonModalDialog(url,860,600,true, '', 'Medium');
    </script>
<%
  }catch(Exception e){
     session.putValue("error.message", e.getMessage());
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
