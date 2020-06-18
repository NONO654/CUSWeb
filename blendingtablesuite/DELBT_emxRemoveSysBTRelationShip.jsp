<%--
$Id: RemoveSystemsToBlendingTable.jsp
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
	String strIsSupplier = emxGetParameter(request,"IsSupplier");
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
				userData.put("selectPlugObjId",plugObjId);
				mlUserData.add(userData);
			}
		}
       
		HashMap hmArgs = new HashMap();
		hmArgs.put( "userSelectedObjects", mlUserData );
		hmArgs.put( "blendedTableObjId", strBTObjectId );
		hmArgs.put( "IsSupplier", strIsSupplier );
	
		String[] args = JPO.packArgs( hmArgs );
		ContextUtil.startTransaction(context, true);
		JPO.invoke( context, "emxBTSystemsSelected", null, "removeRelationsShips", args, String.class );
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
window.parent.location.href = window.parent.location.href;
</script>
</html>
