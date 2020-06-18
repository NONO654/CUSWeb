<%--
$Id: AddMaterialsToBlendingTable.jsp
--%>

<html>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%

String errorMessage = "";
try 
{
	String[] selectedIds = emxGetParameterValues(request, "emxTableRowId");
    String strBTObjectId = emxGetParameter(request,"objectId");
	if(selectedIds!=null&&selectedIds.length>0)
    {
		MapList mlUserData = new MapList();
		for(int i=0; i<selectedIds.length; i++)
		{
			String tmpStr = selectedIds[i];
			
			String delims = "[|]+";
			String[] Nametokens = tmpStr.split(delims);
			if( Nametokens.length > 0 )
			{
				String plugObjId = Nametokens[1];
				
				HashMap userData = new HashMap();
				userData.put("selectObjId",plugObjId);
				mlUserData.add(userData);
			}
		}
       
		HashMap hmArgs = new HashMap();
		hmArgs.put( "userSelectedObjects", mlUserData );
		hmArgs.put( "blendedTableObjId", strBTObjectId );
		String[] args = JPO.packArgs( hmArgs );
	
		ContextUtil.startTransaction(context, true);
		JPO.invoke( context, "emxBTMaterialsSelected", null, "createRelationsShips", args, String.class );
		ContextUtil.commitTransaction(context);
	
   }
} catch (Exception ex) {
errorMessage = ex.toString().trim();
}
%>


<script language="javascript">

if ("<%=errorMessage%>".length >0 && parent.window.opener!=null) {
	parent.window.alert("<%=errorMessage%>");
	//parent.window.opener.window.alert("<%=errorMessage%>");
}
	/*if (!parent.window.opener.top.refreshTablePage) {

		parent.window.opener.top.location = parent.window.opener.top.location;
	} else {

		parent.window.opener.top.refreshTablePage();
	}*/
	if (!top.opener.refreshTablePage)
		top.opener.location = top.opener.location;
	else
		top.opener.refreshTablePage();
    top.close();
</script>


</html>
