<%--
    Copyright (c) 1993-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of
    Dassault Systemes.
    Copyright notice is precautionary only and does not evidence any actual
    or intended publication of such program
    ProductVariantCreatePreProcess.jsp
--%>



<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@page import="com.matrixone.apps.productline.ProductLineCommon" %>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
 
<%
String objectId = emxGetParameter(request, "objectId");
String jsTreeID = emxGetParameter(request, "jsTreeID");
String strRelId = emxGetParameter(request, "relId");
String strTimeStamp = emxGetParameter(request, "timeStamp");
String strHasTechnical = ""; 

try
{
    //* To check if the product has the Logical Structure
        String[] argsTemp = new String[3];
        argsTemp[0] = objectId;
        argsTemp[1] = "from";
        argsTemp[2] = ConfigurationConstants.RELATIONSHIP_LOGICAL_FEATURES;
        
        strHasTechnical = ProductLineCommon.hasRelationship(context,argsTemp);    
        session.removeAttribute("productVariant");
        
	  %>
	  <script language="javascript" type="text/javaScript">
	  var formName = document.getElementById("ProductVariantUtil");
	  var strTreeId = '<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>';
	  var strRelId = '<%=XSSUtil.encodeForJavaScript(context,strRelId)%>';
	  var strObjectId = '<%=XSSUtil.encodeForJavaScript(context,objectId)%>';
	  var timeStamp = '<%=XSSUtil.encodeForJavaScript(context,strTimeStamp)%>';
	  var hasTechnical ='<%=XSSUtil.encodeForJavaScript(context,strHasTechnical)%>';
	  
	  if(hasTechnical=="false")
	  {
		  alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.NoTechnicalFeatures</emxUtil:i18n>");
	  } 
	  else {
	       var submitURL = "../components/emxCommonFS.jsp?mode=create&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&functionality=ProductVariantCreateFSInstance&PRCFSParam1=ProductVariant&jsTreeID="+strTreeId+"&relId="+strRelId+"&objectId="+strObjectId+"&FTRParam=getFromSession&timeStamp="+timeStamp;
	       showModalDialog(submitURL,575,575,"true","Large");
	  }
	  
	  </script>  
  
  <%
        
       
}
catch(Exception e)
{
	session.putValue("error.message", e.getMessage());
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
