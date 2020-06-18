<%-- emxAddChecksToProfile.jsp --%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@ page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
	System.out.println("START emxAddChecksToProfile.jsp");
	
	String mode = emxGetParameter(request,"plmcheck");
	String emxTableRowId[] = emxGetParameterValues(request,"emxTableRowId");
	int size = 0;
	if(emxTableRowId != null) {
		size = emxTableRowId.length;
	}
	System.out.println("SELECTED :: " + size + ", mode: "+mode);
	if(mode != null && mode.equals("true")) {
		HashMap requestMap 		= UINavigatorUtil.getRequestParameterMap(request);
		String objectId = emxGetParameter(request,"objectId");
		requestMap.put("objectId",objectId);
		JPO.invoke(context, "emxProfileCheck", null, "addCheck", JPO.packArgs(requestMap));
		String profileId = emxGetParameter(request,"profileId");%>
		<script language="javascript" src="../common/scripts/emxUICore.js"></script>
		<script language="javascript">
		var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
		if(contentFrame) {
			contentFrame.document.location.href = "../common/emxTree.jsp?objectId=<%=profileId%>";
		}
		</script><%
	} else if(size > 0) {
		for(String id: emxTableRowId) {
			System.out.println("emxTableRowId:: "+id);
		}
		HashMap requestMap 		= UINavigatorUtil.getRequestParameterMap(request);
		requestMap.put("emxTableRowId",emxTableRowId);
		JPO.invoke(context, "emxProfileCheck", null, "addCheck", JPO.packArgs(requestMap));
		String profileId = emxGetParameter(request,"profileId");%>
		<script language="javascript" src="../common/scripts/emxUICore.js"></script>
		<script language="javascript">
		getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
		getTopWindow().close();
		</script>
	<%} else {
		String languageStr      = request.getHeader("Accept-Language");
		String required = EnoviaResourceBundle.getProperty(context, "emxProfile.AddCheck.NoneSelected", "emxProfileStringResource", languageStr);%>
		<script language="javascript">
		alert("<%=required%>");
		</script>
	<%}
	
	System.out.println("END emxAddChecksToProfile.jsp");
%>
	

