
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@ page import = "com.matrixone.vplmintegrationitf.util.*" %>

<%
	String LinPubType = emxGetParameter(request, "chkLinPubType");
	if(LinPubType != null) 
	{
		PropertyUtil.setAdminProperty(context, "Person", context.getUser(), VPLMIntegrationConstants.PREFERENCE_VPLMINTEG_LINPUBLICATION , "true");
	}
	else
	{
		PropertyUtil.setAdminProperty(context, "Person", context.getUser(), VPLMIntegrationConstants.PREFERENCE_VPLMINTEG_LINPUBLICATION , "false");
	}
%>


<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
