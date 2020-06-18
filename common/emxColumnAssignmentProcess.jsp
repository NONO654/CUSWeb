<%@ include file="../emxUICommonAppInclude.inc"%> 
<%@page import="com.matrixone.apps.domain.*"%>

<%	//System.out.println("emxColumnAssignmentProcess.jsp: ---------- START ----------");

	String sRelationship	= request.getParameter("relationship");	
	String sOID 			= request.getParameter("objectId");	
	String sRID 			= request.getParameter("relId");	
	String sRowID 			= request.getParameter("rowId");	
	String sPersonOID 		= request.getParameter("personId");
	String sMode 			= request.getParameter("mode");
	String sFrom			= request.getParameter("from");
	DomainObject doTask 	= new DomainObject(sOID);
	
	if(null == sFrom) { sFrom = "TRUE"; }	
	
	if(sMode.equalsIgnoreCase("add")) {
		try {
			if(sFrom.equalsIgnoreCase("TRUE")) {
				doTask.addToObject(context, new RelationshipType(sRelationship), sPersonOID);
			} else {
				doTask.addFromObject(context, new RelationshipType(sRelationship), sPersonOID);
			}
		} catch (Exception e) {
		}
	} else if (sMode.equalsIgnoreCase("remove"))  {
		try {
			DomainRelationship dRel = new DomainRelationship(sRID);
			dRel.remove(context);
		} catch (Exception e) {
		}
	}
%>
<html>
	<script language="javascript" type="text/javaScript">	
		//XSSOK
		parent.emxEditableTable.refreshRowByRowId("<%=sRowID%>");
	</script>	
</html>
