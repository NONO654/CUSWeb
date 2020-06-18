<%--	emxPLMRuleEditorEditForm.jsp	-	Search summary frameset
--%>

<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List"%>
<%@ page import="java.lang.String" %>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@	include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%
	System.out.println("Begin emxPLMRuleEditorEditForm.jsp");
	String form = emxGetParameter(request,"form");
	System.out.println("form "+form);
	String objectId = emxGetParameter(request,"objectId");
	String ArgumentListLabel = emxGetParameter(request,"ArgumentListLabel");
	String BodyLabel = emxGetParameter(request,"BodyLabel");
	System.out.println("objectId "+objectId);
	HashMap programMap = new HashMap();
	HashMap paramMap = new HashMap();
	programMap.put("paramMap", paramMap);
	paramMap.put("objectId",objectId);
	StringList retour = (StringList)JPO.invoke(context, "emxPLMRuleEditor", null, "isKindOf", JPO.packArgs(programMap), StringList.class);
	String typeEdit = (String)retour.firstElement();
	String typeModel = (String)retour.lastElement();
	Locale loc = context.getLocale();
	String commandStr = /*UINavigatorUtil.getI18nString("emxComponents.Common.Edit", "emxComponentsStringResource", request.getHeader("Accept-Language"))*/EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", loc, "emxComponents.Common.Edit")+" "+(typeEdit.equals("PLMBusinessRule")?EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", loc, "emxFramework.Type." + typeEdit):typeEdit)+".";
	String contentURL = "emxPLMRuleEditorDisplay.jsp?"; 
	contentURL += "typeModel=" + typeModel;
	contentURL += "&objectId=" + objectId;
	if(ArgumentListLabel.startsWith("emx")&&typeEdit.equals("PLMBusinessRule"))
		ArgumentListLabel = EnoviaResourceBundle.getProperty(context, "emxDataSpecializationStringResource", loc, ArgumentListLabel);
	if(BodyLabel.startsWith("emx")&&typeEdit.equals("PLMBusinessRule"))
		BodyLabel = EnoviaResourceBundle.getProperty(context, "emxDataSpecializationStringResource", loc, BodyLabel);
	contentURL += "&ArgumentListLabel=" + ArgumentListLabel;
	contentURL += "&BodyLabel=" + BodyLabel;
	contentURL += "&typeEdit="+typeEdit;
	String strReadOnly = emxGetParameter(request,"readonly");
	boolean readOnly = false;
	if(strReadOnly != null)
		if(strReadOnly.equals("true"))
			readOnly = true;
	contentURL += "&readonly="+readOnly;
	if( form == null ) {
		contentURL += "&form=PLMRuleEditorWebForm";
	}
	else{
		contentURL += "&form=" + form;
	}
	framesetObject fs = new framesetObject();
	fs.removeDialogWarning();
	fs.setStringResourceFile("emxComponentsStringResource");
	fs.initFrameset(commandStr,"emxhelpfindselect",contentURL,false,true,false,false);
	if(!readOnly) {
		fs.createFooterLink("emxComponents.Button.Approve","check(false, 0)","role_GlobalUser",false,true,"common/images/buttonDialogApply.gif",1);
		fs.createFooterLink("emxComponents.Button.Modify","check(true, 1)","role_GlobalUser",false,true,"common/images/buttonDialogDone.gif",0);
	}
	fs.createFooterLink("emxComponents.Common.Cancel","top.close()","role_GlobalUser",false,true,"common/images/buttonDialogCancel.gif",5);
	System.out.println("contentUrl "+contentURL);
	fs.writePage(out);
	System.out.println("End emxPLMRuleEditorEditForm.jsp");
%>
