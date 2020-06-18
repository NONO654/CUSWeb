<%-- emxProfileDeleteCheck.jsp --%>

<%@ include file = "../emxUICommonAppInclude.inc"%>

<%
	String parentOID = emxGetParameter(request,"parentOID");
	String PGId = emxGetParameter(request,"PGId");
	
	HashMap mapArgs = new HashMap();
	mapArgs.put("parentOID", parentOID);
	mapArgs.put("PGId", PGId);
	
	String args[] = JPO.packArgs(mapArgs);
	String retour = (String)JPO.invoke(context, "emxProfileBase", null, "deletePG", args, String.class);
	System.out.println("retour: "+retour);
	if(retour == null) {
%>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript">
		getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
		getTopWindow().close();
	</script>
<%
	} else {
%>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript">
		var reponse = confirm(retour);
		if(reponse == true)
		{
			var url = "../PLMProfile/emxProfileDeletePGForce.jsp?"+decodeURIComponent(window.location.search.substring(1));
			if(parentOID != null) {
				url += "&parentOID="+parentOID;
			}
			if(PGId != null) {
				url += "&PGId="+PGId;
			}
			var contentFrame = getTopWindow().findFrame(getTopWindow(), "content"); 
			if(contentFrame) {
				contentFrame.document.location.href = url;
			}
		}
	</script>
<%
	}
%>
	
