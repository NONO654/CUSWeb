
<%--GBOMViewDuplicatePartsPostProcess.jsp-- 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>

<html>
<head>
  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
</head>
<%
     try{
    	   String strObjectId = emxGetParameter(request, "objectId");
           DomainObject domObj = new DomainObject(strObjectId);
           boolean isPendingJobConnected = domObj.hasRelatedObjects(context, "Pending Job", true);
           String strErrorMessage = i18nNow.getI18nString("emxProduct.Error.Alert.BackgroundJob.Reserved",bundle,acceptLanguage);
           
           if(isPendingJobConnected){
           %>
		      <script language="javascript" type="text/javascript">
		      alert("<%=XSSUtil.encodeForJavaScript(context,strErrorMessage)%>");
		      window.closeWindow();
		       </script>
           <%
           }
           else{
	        %>
	        <script language="javascript" type="text/javascript">
	         document.location.href ='../common/emxIndentedTable.jsp?table=FTRGBOMViewDuplicatePartsTable&suiteKey=Configuration&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&selection=multiple&toolbar=FTRDuplicatePartsToolbar&program=LogicalFeature:getAllDuplicatePartsForSelectedFearture&sortColumnName=GroupNumber&freezePane=PartNumber&header=emxProduct.Heading.DisplayDuplicates&SuiteDirectory=Configuration&parentOID=<%=XSSUtil.encodeForURL(context,strObjectId)%>&HelpMarker=emxhelpduplicatepartview';       
	        </script>
	        <%
           }
       }catch(Exception e){
    	   session.putValue("error.message", e.getMessage());
       }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
