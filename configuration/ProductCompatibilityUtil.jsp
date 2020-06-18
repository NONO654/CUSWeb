<%--
  ProductCompatibilityUtil.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>

<%
boolean bFlag=false;
try{
  //get the mode passed
  String strMode = emxGetParameter(request, "mode");
  if(strMode.equals("report")){
     //Instantiating ProductLineUtil.java bean
     ProductLineUtil utilBean = new ProductLineUtil();
     //Getting the table row ids of the selected objects from the request
     String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
     //Getting the object ids from the table row ids
     String arrObjectIds[] = null;

     arrObjectIds = (String[])utilBean.getObjectIdsRelIdsR213(arrTableRowIds).get("ObjId");
     //Calling emxTable.jsp
%>
	<form name="Compatibilityreport"   method="post" >
	  <input type="hidden" name="forNetscape" value ="" />
	</form>
    <script language="javascript" type="text/javaScript">
	showNonModalDialog("../common/emxTable.jsp?table=FTRProductCompatibilityReportList&emxTableRowId=<%=XSSUtil.encodeForURL(context,arrObjectIds[0])%>&objectId=<%=XSSUtil.encodeForURL(context,arrObjectIds[0])%>&suiteKey=Configuration&header=emxProduct.Heading.ProductCompatibilityReport&program=emxBooleanCompatibility:getAllProductCompatibilityRules&mode=ListPage&HelpMarker=emxhelpproductcompatibilityreport",700,500);
    </script>
<%
}
}catch (Exception e){
    bFlag=true;
    session.putValue("error.message", e.getMessage());
}
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%
    if (bFlag)
    {
%>
    <!--Javascript to bring back to the previous page-->
    <script language="javascript" type="text/javaScript">

      //parent.frames[0].document.progress.src = "../common/images/utilSpacer.gif";
      history.back();
    </script>
<%
    }
%>
