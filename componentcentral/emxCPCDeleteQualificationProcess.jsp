<%--  emxCPCDeleteQualificationProcess.jsp
(c) Dassault Systemes, 1993-2016.  All rights reserved.
--%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxCPCInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@ page import="com.matrixone.apps.domain.util.MqlUtil"%>

<%
try
{
	String objectId = emxGetParameter(request,"objectId");
	DebugUtil.debug("emxCPCDeleteQualificationProcess::objectId"+objectId);
	if (UIUtil.isNotNullAndNotEmpty(objectId))
	{
		DomainObject.deleteObjects(context, new String[]{objectId});
	}

%>

<%
}catch(Exception err){
//  -- Need to catch exception though there is no functionality issue and also to close popup window
//	err.printStackTrace();
//	ContextUtil.abortTransaction(context);
//	throw new FrameworkException(err.getMessage());
}
%>

<script language="JavaScript">
//  Include following statements to address IR-058591V6R2012 and earlier statements retained for reference

	// Included as part of fix for IR-100170V6R2012 (but need to find code only to refresh one tab)
	getTopWindow().getWindowOpener().location.href=getTopWindow().getWindowOpener().location.href;
	getTopWindow().close();

</script>
