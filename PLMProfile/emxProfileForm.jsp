<%--	emxProfileCloneForm.jsp	--%>

<%@ page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List"%>
<%@ page import="java.lang.String" %>
<%@ page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@	include file = "../emxUICommonHeaderBeginInclude.inc" %>
<jsp:useBean id="emxPLMCheck" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
	System.out.println("Begin emxProfileCloneForm.jsp");
	String form = emxGetParameter(request,"form");
	String mode = emxGetParameter(request,"mode");
	if(form != null && mode != null) {
		if(mode.equals("clone")) {
			String sRelId = "";
			String sObjId = "";
			String selectedId[] = emxGetParameterValues(request,"emxTableRowId");
			if(selectedId != null) {
				if(selectedId[0].indexOf("|") != -1) {
					StringTokenizer st = new StringTokenizer(selectedId[0], "|");
					sObjId = st.nextToken();
					sRelId = st.nextToken();
				} else {
					sObjId = selectedId[0];
				}
			}
			String commandStr = EnoviaResourceBundle.getProperty(context, "emxProfile.Common.CloneTitle", "emxProfileStringResource", request.getHeader("Accept-Language"));
			String contentURL = "emxProfileDisplay.jsp?mode=clone"; 
			contentURL += "&objectId="+sObjId;
			contentURL += "&form=" + form;
			framesetObject fs = new framesetObject();
			fs.removeDialogWarning();
			fs.setStringResourceFile("emxProfileStringResource");
			fs.initFrameset(commandStr,"emxhelpfindselect",contentURL,false,true,false,false);
			fs.createFooterLink("emxProfile.Button.Clone","cloneEntity()","role_GlobalUser",false,true,"common/images/buttonDialogDone.gif",0);
			fs.createFooterLink("emxProfile.Button.Cancel","top.closeSlideInDialog()","role_GlobalUser",false,true,"common/images/buttonDialogCancel.gif",5);
			System.out.println("contentUrl "+contentURL);
			fs.writePage(out);
		}
		if(mode.equals("create")) {
			String commandStr = EnoviaResourceBundle.getProperty(context, "emxProfile.Common.CreateProfile", "emxProfileStringResource", request.getHeader("Accept-Language"));
			String contentURL = "emxProfileDisplay.jsp?mode=create"; 
			contentURL += "&form=" + form;
			framesetObject fs = new framesetObject();
			fs.removeDialogWarning();
			fs.setStringResourceFile("emxProfileStringResource");
			fs.initFrameset(commandStr,"emxhelpfindselect",contentURL,false,true,false,false);
			fs.createFooterLink("emxProfile.Button.Create","createEntity()","role_GlobalUser",false,true,"common/images/buttonDialogDone.gif",0);
			fs.createFooterLink("emxProfile.Button.Cancel","top.closeSlideInDialog()","role_GlobalUser",false,true,"common/images/buttonDialogCancel.gif",5);
			System.out.println("contentUrl "+contentURL);
			fs.writePage(out);
		}
	}
	System.out.println("End emxProfileCloneForm.jsp");
%>
