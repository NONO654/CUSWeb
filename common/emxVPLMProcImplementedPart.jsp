<%@ page import = "java.util.HashMap" %>
<%@ page import = "matrix.db.*" %>
<%@ page import = "com.dassault_systemes.VPLMJProcessNavUI.VPLMJProcessAdapterUIModel" %>
<%@ page import = "com.matrixone.apps.domain.util.XSSUtil"%>


<%@include file="../emxUIFramesetUtil.inc"%>

<HEAD>
<%@include  file="../emxUICommonHeaderBeginInclude.inc"%>
</HEAD>
<BODY>
	<%
	//framesetObject fs = new framesetObject();


	

	
	
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	String relId = (String) requestMap.get("relId");

	String[] implementedProductID = null;
	if (!relId.equals(""))
	{
		VPLMJProcessAdapterUIModel adapterUIModel = VPLMJProcessAdapterUIModel.getInstance();
		implementedProductID = adapterUIModel.getImplementedPart(context, relId);
	}
	if (implementedProductID == null)
	{
		//String strAlertMessage = i18nNow.getI18nString("emxVPLMProcessEditor.Message.NoImplementedPart", "VPLMProcessEditor", context.getSession().getLanguage());
		String strAlertMessage = MessageUtil.getMessage(context, null, "emxVPLMProcessEditor.Message.NoImplementedPart", null, null, context.getLocale(), "emxVPLMProcessEditorStringResource");
		%>
		<script  language="javascript"  type="text/javaScript">
		window.alert("<%=XSSUtil.encodeForJavaScript(context,strAlertMessage)%>");  
		top.location.href = "../common/emxCloseWindow.jsp";
		</script>
		<%    
	}
	else
	{
		StringBuffer actionURL = new StringBuffer();;
		actionURL.append("emxForm.jsp?form=type_VPMInstance&relId=");
		actionURL.append(implementedProductID[0]);
		actionURL.append("&objectId=");
		actionURL.append(implementedProductID[1]);
		
		RequestDispatcher rd = request.getRequestDispatcher(actionURL.toString());
		rd.forward(request, response);
	}

	
	//if (isStartedByMe) context.abort();
	%>

</BODY>
