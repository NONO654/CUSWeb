<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%-- Wrapper JSP to invoke SubmitJPO with selected rows. --%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.classification.ClassificationAttributesCreationUtil"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script src="../plugins/libs/jquery/2.0.0/jquery.min.js"></script>

<%
	HashMap paramMap = new HashMap();
	String alertMessage = null;

    String timeZone =(String)session.getAttribute("timeZone");
	Enumeration paramNames = emxGetParameterNames(request);
	while (paramNames.hasMoreElements()) {
		String paramName = (String) paramNames.nextElement();
		String paramValue = emxGetParameter(request, paramName);
		paramMap.put(paramName, paramValue);
	}
	paramMap.put("timeZone", timeZone);
	paramMap.put("localeObject", request.getLocale());

	try {
		alertMessage = ClassificationAttributesCreationUtil.createClassificationAttribute(context, paramMap);
	} catch (FrameworkException ex) {
		alertMessage = ex.getMessage();
	} catch(Exception ex2){
		alertMessage = ex2.getMessage();
		ex2.printStackTrace();
	}
	if (alertMessage != null && !"".equals(alertMessage)) {
%>		<script language="Javascript">
			alert("<xss:encodeForJavaScript><%=alertMessage%></xss:encodeForJavaScript>");
		</script>
<%	}else{
%>		<script>
			getTopWindow().refreshTablePage();
		</script>
<%	}
%>
