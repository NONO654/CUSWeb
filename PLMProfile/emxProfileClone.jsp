<%-- emxProfileClone.jsp --%>

<%@include file="../common/emxNavigatorInclude.inc"%>

<%
	System.out.println("Begin cloneProfile.jsp");
	HashMap requestMap 		= UINavigatorUtil.getRequestParameterMap(request);
	HashMap reqValuesMap    = UINavigatorUtil.getRequestParameterValuesMap(request);
	requestMap.put("RequestValuesMap", reqValuesMap); 
	String retour = (String)JPO.invoke(context, "emxImportCloneProfile", null, "cloneProfile", JPO.packArgs(requestMap), String.class);
	System.out.println(":: "+retour);
	if(retour == null) {
%>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript">
		getTopWindow().refreshTablePage();
		getTopWindow().closeSlideInDialog();
	</script>
<%
	} else {
%>
	<script language="javascript">
		alert("<%=retour%>");
	</script>
<%
	}
	System.out.println("End cloneProfile.jsp");
%>
