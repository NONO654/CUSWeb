<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "$Id: emxImageManagerUpload.jsp.rca 1.2.2.6 Wed Oct 22 16:18:36 2008 przemek Experimental przemek $"
   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.net.InetAddress"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript">
</script>
<script language="javascript" src="../common/scripts/emxUICore.js" type="text/javascript">
</script>
<script language="javascript" src="../common/scripts/emxUIModal.js" type="text/javascript">
</script>
<%


//Commented and Added for IR-075292V6R2012 -Start

//InetAddress addr = InetAddress.getLocalHost();
//String hostname = addr.getHostName();
//StringBuffer sbMcsURL = new StringBuffer(100);
//sbMcsURL.append(request.getScheme());
//sbMcsURL.append("://");
//sbMcsURL.append(hostname);
//sbMcsURL.append(":");
//sbMcsURL.append(request.getServerPort());
//sbMcsURL.append(request.getContextPath());
//String mcsURL = sbMcsURL.toString();
String mcsURL = com.matrixone.apps.common.CommonDocument.getMCSURL(context, request);

//Commented and Added for IR-075292V6R2012 -End

  String objectId = emxGetParameter(request, "objectId");
  // Added by Infosys for Bug#318079 on Apr 07,2006
  String strType =  DomainObject.TYPE_IMAGE_HOLDER;
  String strPolicy = DomainObject.POLICY_IMAGE_HOLDER;

  String url = "../components/emxCommonDocumentPreCheckin.jsp?objectId=" + XSSUtil.encodeForURL(context, objectId) + "&JPOName=emxImageManager&methodName=associateImage&objectAction=image&override=false&showFormat=false&realType="+XSSUtil.encodeForURL(context, strType)+"&documentType="+XSSUtil.encodeForURL(context, strType)+"&policy="+XSSUtil.encodeForURL(context, strPolicy)+"&showComments=false&HelpMarker=emxhelpimagesupload&appDir=components&appProcessPage=emxImageManagerUploadProcess.jsp"+"&mcsUrl="+XSSUtil.encodeForURL(context, mcsURL);

    
%>
<script language="javascript">
	//XSSOK
		showModalDialog("<%=url%>", 780, 570, true);
</script>

