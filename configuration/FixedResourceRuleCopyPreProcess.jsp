<%--
  FixedResourceRuleCopyPreProcess.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/BooleanCompatibilityUtil.jsp 1.19.2.2.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="java.util.StringTokenizer"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
 
<%
try
 {
	String strMode = emxGetParameter(request,"mode");
	if(!"create".equalsIgnoreCase(strMode))
	{  
	  String contextOID = (String)emxGetParameter(request, "objectId");
	  String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	  String arrObjectIds[] = null;
	  arrObjectIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("ObjId");
	  StringTokenizer st = new StringTokenizer(arrObjectIds[0],"|");
	  String strObject = st.nextToken();
 %>
  <script language="javascript" type="text/javaScript">
   var url="../common/emxCreate.jsp?type=type_FixedResource&vaultChooser=true&form=FTRFixedResourceCopyForm&nameField=both&header=emxProduct.Heading.FixedResourceCreateNew&relationship=relationship_ResourceLimit&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&postProcessJPO=emxRule:updateMandatoryAttr&objectId=<%=XSSUtil.encodeForURL(context,contextOID)%>&parentOID=<%=XSSUtil.encodeForURL(context,contextOID)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,strObject)%>&autoNameChecked=true&postProcessURL=../configuration/FixedResourceRuleCopyPreProcess.jsp";
   /* changes for IR IR-369131-3DEXPERIENCER2016x - added autoNameChecked parameter */
   //getTopWindow().location.href = url;
   showModalDialog(url, 780, 500,true, 'Large');
  </script>
  <% 
  }
  else
  {
  %>
     <script language="javascript" type="text/javaScript">
     var listFrame=window.parent.getTopWindow().getWindowOpener().getTopWindow().getWindowOpener();
 	 listFrame.editableTable.loadData();
     listFrame.rebuildView();
     parent.window.closeWindow();
     getTopWindow().getWindowOpener().closeWindow();
     </script>
  <%
  }
  %>
 <%}
 catch (Exception e)
 {
 }
%>

