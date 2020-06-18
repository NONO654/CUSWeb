<%-- (c) Dassault Systemes, 2010 --%>
<%--
  Station Access Delete processing
--%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@page import="java.util.HashMap"%>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.db.Context"%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

<html>
<body style="height:100%;width:100%;">
<%
	PropertyUtil.setGlobalRPEValue(context, DomainAccess.RPE_MEMBER_ADDED_REMOVED, "true");    
	String objectId = emxGetParameter(request, "objectId");
	String access = emxGetParameter(request, "access");
	String jpoName = emxGetParameter(request,"jpoName");
	String methodName = emxGetParameter(request,"methodName");
	String[] ids = emxGetParameterValues(request, "emxTableRowId");
	if(UIUtil.isNullOrEmpty(jpoName) && UIUtil.isNullOrEmpty(methodName)){
		jpoName = "emxDomainAccess";
		methodName = "deleteAccess";
	}
	Map paramMapForJPO = new HashMap();		
	paramMapForJPO.put("busObjId", objectId);			
	paramMapForJPO.put("emxTableRowIds" ,ids);		
	String[] args = JPO.packArgs(paramMapForJPO);
	JPO.invoke(context, jpoName, null, methodName, args);
%>		
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<script>
	getTopWindow().refreshTablePage();
</script>
</body>
</html>
