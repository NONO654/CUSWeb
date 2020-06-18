<%@include file = "../common/emxNavigatorInclude.inc"%>
<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>				  

<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%		
	String tableID		= emxGetParameter(request, "tableID");
	
	// Get object & relationship ids
	
	HashMap tableData		= tableBean.getTableData(tableID);
	MapList relBusObjList	= tableBean.getObjectList(tableData);
	
	String toChecked		= emxGetParameter(request, "toDirection");
	String fromChecked		= emxGetParameter(request, "fromDirection");
	String selectedRelation = emxGetParameter(request, "relationshipName");

	String selectedToFrom="*";

	if(fromChecked == null)
		fromChecked = "off";

	if(toChecked == null)
		toChecked = "off";

	String selectedDirection = "both";

	if(toChecked.equalsIgnoreCase("on"))
	{
		selectedToFrom	  ="to";
		selectedDirection = "to";
	}
	
	if(fromChecked.equalsIgnoreCase("on"))
	{

		if(!selectedDirection.equals("to"))
		{
			selectedToFrom="from";
			selectedDirection = "from";
		}
		else
		{
			selectedToFrom="*";
			selectedDirection = "both";
		}
	}
	
	// Get business object list from session level Table bean
	tableData = tableBean.getTableData(tableID);
	
	MapList filteredObjPageList = new MapList();
	StringList busSelects = new StringList();
	BusinessObjectWithSelectList busObjwsl = null;
		
	if ( relBusObjList != null)
	{
		
		for (int i = 0; i < relBusObjList.size(); i++)
		{
			String currentRelation	= (String)((HashMap)relBusObjList.get(i)).get("rel_type");
			String currentDirection = (String)((HashMap)relBusObjList.get(i)).get("rel_end");
			if (currentRelation != null && currentDirection != null )
			{
				if((selectedRelation.equalsIgnoreCase("all") || currentRelation.equals(selectedRelation)) && (selectedDirection.equals("both") || 	currentDirection.equalsIgnoreCase(selectedDirection)))
					{
							filteredObjPageList.add(relBusObjList.get(i));
					}
			}
		}
	}
	tableBean.setFilteredObjectList(tableData, filteredObjPageList);
%>
<script language="JavaScript">
	parent.refreshTableBody();
</script>
