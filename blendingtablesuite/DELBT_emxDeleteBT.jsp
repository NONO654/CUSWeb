<%--
$Id: DeleteBlendingTable.jsp
--%>

<html>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%

String errorMessage = "";
try 
{
	/*String strParentOID= emxGetParameter(request, "parentOID");
	//System.out.println("parentOID : " + strParentOID);  
	
	HashMap hmArgs = new HashMap();
	hmArgs.put( "blendedTableObjId", strParentOID );
	String[] args = JPO.packArgs( hmArgs );
	ContextUtil.startTransaction(context, true);*/
	
	
	
	String[] selectedIds = emxGetParameterValues(request, "emxTableRowId");
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
				String BTObjId = Nametokens[1];
				HashMap userData = new HashMap();
				userData.put("selectedBTObjId",BTObjId);
				mlUserData.add(userData);
			}
		}
    
       
		HashMap hmArgs = new HashMap();
		hmArgs.put( "userSelectedObjects", mlUserData );
	
		String[] args = JPO.packArgs( hmArgs );
		ContextUtil.startTransaction(context, true);
		
		JPO.invoke( context, "emxBlendingTable", null, "DeleteBlendingTable", args, String.class );
		ContextUtil.commitTransaction(context);
    }
	
} catch (Exception ex) {
//System.out.println("EXECPTION IN JSPPPPPP");
errorMessage = ex.toString().trim();
}
%>


<script language="javascript">

if ("<%=errorMessage%>".length >0 && parent.window.opener!=null) {
	parent.window.alert("<%=errorMessage%>");
}

	//top.parent.location.href = top.parent.location.href;
	top.parent.location.href ="../common/emxFullSearch.jsp?field=TYPES=DEL_BlendingTable:POLICY=DELBT_DefaultPolicy&showInitialResults=true&table=AEFGeneralSearchResults&selection=multiple&freezePane=Name&HelpMarker=emxhelpfullsearch&toolbar=DELBT_SearchToolbar";

</script>

</html>
