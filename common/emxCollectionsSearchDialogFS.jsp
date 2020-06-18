 <%--  emxCollectionsSearchDialogFS.jsp  -  Search dialog frameset

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program

  static const char RCSID[] = $Id: emxCollectionsSearchDialogFS.jsp.rca 1.10 Wed Oct 22 15:48:31 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>



<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />


<%
  // ----------------- Do Not Edit Above ------------------------------

  //String objectId = emxGetParameter(request,"objectId");
  //String jsTreeID = emxGetParameter(request,"jsTreeID");
  String collection = emxGetParameter(request,"collection");
  String sCharSet   = Framework.getCharacterEncoding(request);
  String sCollectionId = "";
  if (collection != null && 
      !"null".equalsIgnoreCase(collection) &&
      !"".equalsIgnoreCase(collection) &&
      "true".equalsIgnoreCase(collection)) {
    String timeStamp = emxGetParameter(request,"timeStamp");
    HashMap tableData = indentedTableBean.getTableData(timeStamp);
    HashMap requestMap = indentedTableBean.getRequestMap(tableData);
    sCollectionId = emxGetParameter(request,"relId");
  } 
  sCollectionId = XSSUtil.encodeForURL(context, sCollectionId);
  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(100);
  contentURL.append("emxFullSearch.jsp?table=AEFGeneralSearchResults&selection=multiple&hideHeader=true&showClipboard=false&showInitialResults=false&addPreCondParam=false");
 
  // add these parameters to each content URL, and any others the App needs
  contentURL.append("&submitURL=");
  contentURL.append("../common/emxCollectionsAddToProcess.jsp?CollectionId="+sCollectionId);
  
  StringBuffer urlStr = new StringBuffer(100);
  urlStr.append("../common/emxCollectionsAddToProcess.jsp?CollectionId="+sCollectionId);
  
%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"  type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language = "javascript">

function doSubmit()
{
	showModalDialog('<%=contentURL.toString()%>');
}

</script>
<body onload="doSubmit()">
<form name="CollectionSearch" action="<%=XSSUtil.encodeForHTMLAttribute(context,contentURL.toString())%>">
<input type=hidden name="table" value="AEFGeneralSearchResults">
<input type=hidden name="selection" value="multiple">
<input type=hidden name="hideHeader" value="true">
<input type=hidden name="showClipboard" value="false">
<input type=hidden name="showInitialResults" value="false">
<input type=hidden name="&submitURL" value="<%=urlStr.toString()%>">



</form>

