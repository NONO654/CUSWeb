<%@ include file="../emxUICommonAppInclude.inc"%> 
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainRelationship"%>

<%	
	
	String sAction	= request.getParameter("action");
	String sOID 	= request.getParameter("objectId");
	String sRID 	= request.getParameter("relId");
	String sRowID	= request.getParameter("rowId");	
	
	if(sAction.equals("remove")) {
		DomainRelationship.disconnect(context, sRID);
	} else if (sAction.equals("delete")) {
		DomainObject dObject = new DomainObject(sOID);
		dObject.deleteObject(context);
	} else if (sAction.equals("promote")) {
		BusinessObject bObject = new BusinessObject(sOID);
		bObject.promote(context);  
	} else if (sAction.equals("demote")) {
		BusinessObject bObject = new BusinessObject(sOID);
		bObject.demote(context);  	
	}
	
%>
<html>
	<script language="javascript" type="text/javaScript">	
		var url = parent.document.location.href;
		
		if(url.indexOf("emxIndentedTable.jsp") == -1) {

			parent.document.location.href = url;
		} else {
			//XSSOK
			parent.emxEditableTable.refreshRowByRowId("<%=XSSUtil.encodeForJavaScript(context,sRowID)%>");
		}
	</script>	
</html>
