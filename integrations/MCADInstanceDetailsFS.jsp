<%--  MCADInstanceDetailsFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<html>
<head>
<%@ include file ="MCADTopInclude.inc"%>

<%
 
 MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
Context context = integSessionData.getClonedContext(session);
  String appendParams = emxGetEncodedQueryString(integSessionData.getClonedContext(session),request);

  String objectId		= request.getParameter("busId");
  appendParams	= appendParams + "&objectId=" + objectId;

  String instanceDetailsHeaderURL	= "../iefdesigncenter/emxInfoObjectInstanceHeader.jsp?" + appendParams;
  String instanceDetailsBodyURL		= "MCADInstanceDetails.jsp?" + appendParams;
  String instanceDetailsFooterURL	= "MCADInstanceDetailsFooter.jsp?" + appendParams;  

%>  
</head>
  <frameset rows="75,*,50" framespacing="0" frameborder="no" border="0">
       <frame name="pageheader" src="<%=XSSUtil.encodeForHTML(context,instanceDetailsHeaderURL)%>" noresize="noresize" marginheight="0" marginwidth="0" border="0" scrolling="no"/>
       <frame name="pagecontent" src="<%=XSSUtil.encodeForHTML(context,instanceDetailsBodyURL)%>" noresize="noresize" marginheight="0" marginwidth="10" />
	   <frame name="pagefooter" src="<%=XSSUtil.encodeForHTML(context,instanceDetailsFooterURL)%>" noresize="noresize" marginheight="0" marginwidth="10"/>
  </frameset>
</html>
