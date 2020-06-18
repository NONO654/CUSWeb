<%--  
	RichEditPrefProcess.jsp
	Copyright (c) 1992-2018 Dassault Systemes.
--%>
<%@page import="com.dassault_systemes.enovia.webapps.richeditor.util.RichEditUtil"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
    String richeditor = (String)emxGetParameter(request,"richeditor");

    // if change has been submitted then process the change
    if (richeditor != null) {
        try {
        	RichEditUtil.setPreferredEditor(context, richeditor);
        	
        	if(!UINavigatorUtil.isCloud(context) && "Word".equalsIgnoreCase(richeditor)) {
        		String warning = MessageUtil.getMessage(context, null, "emxProductLine.RichTextEditor.Alert.MSFDeploy", 
            			new String[]{"ENOVIACollaborationforMicrosoftClient"}, null, context.getLocale(), "emxProductLineStringResource");
%>
				<script type="text/javascript">
					alert("<%=warning%>");
				</script>
<%
        	}
        } catch (Exception ex) {
            if(ex.toString()!=null && (ex.toString().trim()).length()>0) {
                emxNavErrorObject.addMessage(ex.getMessage());
            }
        }
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

