<%-- 
 ** history:
 *  @fullreview  fl3 gh4 2016/09/19: Creation (3DEXP R2017x)
 *  @quickreview gh4 qwm 2017/03/13: IR-508481: Fixed issue of displaying unwanted warning message "Object Find Limit (1) reached"
 *  @quickreview spl7 gh4 2017/07/26: IR-533599 : Fixed issue of XSS encoding feature
--%>

<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import = "com.dassault_systemes.vplm.DELJTypeNAttServices"%>

<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource"
	locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />

<% 
	String errorMessage = "";
	
	String objectId = (String)emxGetParameter(request, "objectId");
	String relId 	= (String)emxGetParameter(request, "relId");
	String sProg 	= (String)emxGetParameter(request, "program");
	String sMethod  = (String)emxGetParameter(request, "method");
	
	String sPID  = DELJTypeNAttServices.getPhysicalId(context, objectId);
	HashMap args = new HashMap();
	args.put("objectId", sPID);
	if (null != relId)
		args.put("relId",relId);
	
	context.start(false);
	String sAttrList = (String)JPO.invoke(context, sProg, null, sMethod, JPO.packArgs(args), String.class);	
	sAttrList = sAttrList.replaceAll("\n", "//n");
	context.abort();
	
	// IR-508481: Clear client tasks so that cached warning messages are removed off! The msg is seen
	// due to DELJNavigationServices.getPIDOfProductScopedWithManItem function call
	context.clearClientTasks();
%>

<html>

<head>
	<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
</head>

<body>
	
	<%
	if ("".equals(errorMessage.trim()))
	{
	%>
		<script language="javascript">
			var url = window.location.href;
			
			url = url.replace("planningreview/CPVForm.jsp", "common/emxForm.jsp");
			url += "<%=XSSUtil.encodeURLForServer(context,sAttrList)%>";
	        
			window.location.href = url;
			
		</script>
	<%
	} else {
	%>
		<link rel="stylesheet" href="../emxUITemp.css" type="text/css">
		&nbsp;
	    <table width="90%" border=0  cellspacing=0 cellpadding=3  class="formBG" align="center" >
	        <tr align="center">
	          <td class="errorMessage" align="center"><xss:encodeForHTML><%=errorMessage%></xss:encodeForHTML></td>
	        </tr>
		</table>
	<%
	}
	%>
</body>
</html>
