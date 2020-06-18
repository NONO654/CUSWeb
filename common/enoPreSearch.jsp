<%--  emxRouteFindContentTypes.jsp - The processing page for  main search Type Chooser

      Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne, Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended
      publication of such program

	  static const char RCSID[] = $Id: emxRouteFindContentTypes.jsp.rca 1.7 Wed Oct 22 16:18:26 2008 przemek Experimental przemek $

--%>
<%@ page import = "com.matrixone.apps.domain.*, com.matrixone.apps.domain.util.*, java.util.*, com.matrixone.apps.framework.ui.*"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxJSValidation.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%
	String searchTypes = "";
	String relType = "";
	String fromPage = "";
	String otherParams = "";
	Map paramMap = new HashMap();
    Enumeration eNumParameters = emxGetParameterNames(request);
    while( eNumParameters.hasMoreElements() ) {
    	String key = XSSUtil.encodeForURL(context, (String)eNumParameters.nextElement());
		String val = XSSUtil.encodeForURL(context, (String) emxGetParameter(request, key));
		if ("relType".equals(key)) {
			relType = val;
		} else if ("commandName".equals(key)) {
			fromPage = val;
		} else {
			if("fieldNameActual".equals(key) || "fieldNameOID".equals(key) || "fieldNameDisplay".equals(key)){
				otherParams += "&" + key + "=" +  XSSUtil.encodeForURL(context,(String) emxGetParameter(request, key));
			}else{
				otherParams += "&" + key + "=" + val;
			}
		}
    }
    relType = PropertyUtil.getSchemaProperty(relType);
	String mqlCmd = "print relationship $1 select totype dump";

	// Use the list returned from mql to populate
	// the type chooser
	//
	try {
		searchTypes = MqlUtil.mqlCommand(context, mqlCmd, relType);
	} catch (FrameworkException fe) {
		searchTypes = " ";
	}
%>
<!DOCTYPE html>
<body>
	<%
		if ("TMCGeneralSearch".equals(fromPage)) {
	%>
	
	<script language="javascript">
		var strURL = "emxFullSearch.jsp?table=AppFolderContentSearchResult&showInitialResults=true&default=TYPE=type_Document&field=TYPES=<%=searchTypes%>:IS_VERSION_OBJECT!=True&HelpMarker=emxhelpsearch&SubmitLabel=emxTeamCentral.Common.Done&header=emxTeamCentral.Common.SelectContent&form=TMCAddWorkspaceContentForm&selection=multiple&targetLocation=popup&SelectAbstractTypes=true<%=otherParams%>&submitURL=../teamcentral/emxTeamFolderAttachDocuments.jsp";
		showModalDialog(strURL, 450, 350);
	</script>

	<%
		}else if("IssueReportedAgainstSearch".equals(fromPage)) {
			%>
			
			<script language="javascript">

				var strURL = "emxFullSearch.jsp?table=IssueAddExistingSearchGenericTable&selection=single&showInitialResults=true&field=TYPES=<%=searchTypes%>:IS_VERSION_OBJECT!=True&HelpMarker=emxhelpsearch&submitURL=AEFSearchUtil.jsp&mode=Chooser&chooserType=TypeChooser&frameNameForField=slideInFrame<%=otherParams%>";
				showModalDialog(strURL, 450, 350);
			</script>
			<%
		}else if("IssueReportedAgainstSearchToolbar".equals(fromPage)) {
			%>
			
			<script language="javascript">

				var strURL = "emxFullSearch.jsp?table=AEFGeneralSearchResults&selection=multiple&showInitialResults=true&field=TYPES=<%=searchTypes%>:IS_VERSION_OBJECT!=True&HelpMarker=emxhelpsearch&submitLabel=emxFramework.GlobalSearch.Done&submitURL=../components/emxCommonConnectObjects.jsp&srcDestRelName=relationship_Issue&targetLocation=popup&excludeOIDprogram=emxCommonIssue:excludeIssueRelatedObjects&mode=reportedAgainst&isTo=true<%=otherParams%>";
				showModalDialog(strURL, 450, 350);
			</script>
			<%
		}else if("AddExistingIssueResolvedToLink".equals(fromPage)) {
			%>
			
			<script language="javascript">

				var strURL = "emxFullSearch.jsp?table=AEFGeneralSearchResults&selection=multiple&showInitialResults=true&field=TYPES=<%=searchTypes%>:IS_VERSION_OBJECT!=True&HelpMarker=emxhelpsearch&submitLabel=emxFramework.GlobalSearch.Done&submitURL=../components/emxCommonConnectObjects.jsp&srcDestRelName=relationship_ResolvedTo&targetLocation=popup&excludeOIDprogram=emxCommonIssue:excludeIssueRelatedObjects&mode=resolvedby&isTo=true<%=otherParams%>";
				showModalDialog(strURL, 450, 350);
			</script>
			<%
		}
	%>
	
</body>
</html>
