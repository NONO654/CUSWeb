<%--
  BCRCopyPreProcess.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/BooleanCompatibilityUtil.jsp 1.19.2.2.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.configuration.RuleProcess"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
 
<%
try
 {
	String contextOID = (String)emxGetParameter(request, "objectId");
	  String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	  String arrObjectIds[] = null;
	  arrObjectIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("ObjId");
	  StringTokenizer st = new StringTokenizer(arrObjectIds[0],"|");
	  String strObject = st.nextToken();
	  
	  DomainObject objMV = new DomainObject(contextOID);
	  if(objMV.isKindOf(context, ConfigurationConstants.TYPE_PRODUCTS))
	  {
		  RuleProcess ruleProcess = new RuleProcess();
		  String strWarningMessage = ruleProcess.checkOptionsUsedInBCRMPRAreAllocatedToMV(context,contextOID, strObject);
		  if(ProductLineCommon.isNotNull(strWarningMessage))
		  {
			  %>
			  <script type="text/javascript">
	          alert("<%=strWarningMessage%>");
	          </script>
			  <%
		  }
	  }
 %>
   <script language="javascript" type="text/javaScript">
   var contextOID = '<%=XSSUtil.encodeForJavaScript(context,contextOID)%>';
   var ruleID = '<%=XSSUtil.encodeForJavaScript(context,strObject)%>';          
   var url= "../configuration/CreateRuleDialog.jsp?modetype=copy&commandName=FTRBooleanCompatibilityRuleSettings&ruleType=BooleanCompatibilityRule&SuiteDirectory=configuration&suiteKey=configuration&productID=<%=XSSUtil.encodeForURL(context,contextOID)%>&relId=null&suiteKey=configuration&objectId=<%=XSSUtil.encodeForURL(context,strObject)%>&submitURL=../configuration/BCRCopyPostProcess.jsp?mode=copy|objectId=<%=XSSUtil.encodeForURL(context,strObject)%>";
   /* getTopWindow().location.href = url; */

   showModalDialog(url,575,575,"true","Large");   
   //getTopWindow().close();
  </script>
 <%}
 catch (Exception e)
 {
 }
%>

