<%--   
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.  
--%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import = "com.matrixone.apps.domain.util.*" %> 
<%@ page import = "com.matrixone.apps.domain.*" %> 
<%@ page import = "com.matrixone.apps.common.Task" %> 
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil" %> 
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"  type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<html>
<body>
<%
if (emxGetParameter(request, "mode").equals("IssuechangeOwner"))
{
	String[] selectedIssueRowIDs = emxGetParameterValues(request, "emxTableRowId");
	String sIssueManagerRole = PropertyUtil.getSchemaProperty(context, "role_IssueManager");
	String sVPLMCreator = PropertyUtil.getSchemaProperty(context,"role_VPLMCreator");
	
	StringBuffer issueIDs= new StringBuffer();
	for (String selectedIssue : selectedIssueRowIDs) {
		issueIDs.append(selectedIssue);
		issueIDs.append("!!");
	}
	String strURL="../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE="+sIssueManagerRole+","+sVPLMCreator+"&mode=IssuechangeOwner&submitLabel=emxFramework.GlobalSearch.Done&table=AEFPersonChooserDetails&form=BPSUserSearchForm&selection=single&submitURL=../components/emxCommonFullSearchProcess.jsp&showInitialResults=true&IssueID="+XSSUtil.encodeForURL(context,issueIDs.toString());
			
%>
	</body>
	</html>
	<script language="javascript" type="text/javaScript">
	//XSSOK
		showModalDialog('<%=strURL%>');
	</script>
<%
}

%>
