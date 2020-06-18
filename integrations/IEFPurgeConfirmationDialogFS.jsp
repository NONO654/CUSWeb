<%--  IEFPurgeConfirmationDialogFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ include file ="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<html>
<%
    Context context= Framework.getMainContext(session);
	String isContentHtml = (String)Request.getParameter(request,"isContentHtml");
%>

<frameset rows="85,*,75" frameborder="no">
	<frame name="headerFrame"  src="MCADGenericHeaderPage.jsp" scrolling=no>
	<frame name="contentFrame" src="MCADMessageContent.jsp?isContentHtml=<%=XSSUtil.encodeForHTML(context, isContentHtml)%>">
	<frame name="bottomFrame"  src="MCADGenericFooterPage.jsp" scrolling=no >
</frameset>

<%@include file = "MCADBottomErrorInclude.inc"%>

</html>
