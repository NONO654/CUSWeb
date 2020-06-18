<%--  IEFAttributeChooserContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file="MCADTopInclude.inc" %>

<%!
	private Vector filterList( StringList currentList ,Vector basics, String filter)
	{
		Pattern patternGeneric = null;
		Vector retVector = new Vector();
		
		//Iterate through given list 
		if(currentList != null && currentList.size() > 0 )
		{        
			currentList.sort();

			for( int i = 0 ; i < currentList.size(); i++ )
			{
				String value    = "";
				String reassign = (String) currentList.elementAt( i );
				
				if( (filter == null ) && ( filter.equals("")) ) 
				{
					value = reassign;
				}
				else 
				{
					patternGeneric = new Pattern(filter);

					if(patternGeneric.match(reassign)) 
					{
						value = reassign;
					}
				}

				if(!value.equals(""))
				{
					for(int j=0; j< basics.size(); j++)
					{
						Vector item  = (Vector)basics.elementAt(j);
						String label = (String)item.elementAt(0);
						if(label.equals(value))
						{
							retVector.addElement(item);
						}
					}
				}
			}
		}

		return retVector;
	}
%>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");	
	Context context                             = integSessionData.getClonedContext(session);
	MCADMxUtil util = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	
	String name                                 = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Name");
	
	HashMap paramMap                            = new HashMap(5);
	String chkbxBasic                           = emxGetParameter(request, "chkbxBasic");

	paramMap.put("chkbxBasic",chkbxBasic);
	paramMap.put("chkbxAttribute", emxGetParameter(request, "chkbxAttribute"));
	paramMap.put("txtFilter", emxGetParameter(request, "txtFilter"));

	String filter                               = emxGetParameter(request, "txtFilter");
	
	String[] intArgs                            = new String[]{};
	CustomMapList tableData                     = (CustomMapList)JPO.invoke(context, "IEFSearchAttributes", intArgs, "getTableData", JPO.packArgs(paramMap), CustomMapList.class);

%>

<html>
<head>
</head>
<body>

<form name="attributeListForm" method="post">

<table border="0" cellpadding="3" cellspacing="2" width="100%">
	<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
	<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
	<link rel="stylesheet" href="styles/emxIEFCommonUI.css" type="text/css">

	<tr>
		<th class=sorted width="5%">&nbsp;</th>
		<th class=sorted>
		
			<table border="0" cellspacing="0" cellpadding="0">
			        <!--XSSOK-->
				<tr><th><%=name%></th></tr>
			</table>

		</th>
	</tr>

<%
	Vector basics         = new Vector();
	StringList basicsList = new StringList();

	String Current =integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Current");
	Vector current = new Vector();
	
	current.addElement(Current);
	current.addElement("current");
	basicsList.addElement(Current);

	String Description =integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Description");
	Vector description = new Vector();
	
	description.addElement(Description);
	description.addElement("description");
	basicsList.addElement(Description);

	String Grantee = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Grantee");
	Vector grantee = new Vector();
	
	grantee.addElement(Grantee);
	grantee.addElement("grantee");
	basicsList.addElement(Grantee);

	String Grantor = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Grantor");
	Vector grantor = new Vector();
	
	grantor.addElement(Grantor);
	grantor.addElement("grantor");
	basicsList.addElement(Grantor);

	String Modified = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Modified");
	Vector modified = new Vector();
	
	modified.addElement(Modified);
	modified.addElement("modified");
	basicsList.addElement(Modified);

	String NameOf = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Name");
	Vector nameof = new Vector();
	
	nameof.addElement(NameOf);
	nameof.addElement("name");
	basicsList.addElement(NameOf);

	String Originated = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Originated");
	Vector originated = new Vector();
	
	originated.addElement(Originated);
	originated.addElement("originated");
	basicsList.addElement(Originated);

	String Owner = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Owner");
	Vector owner = new Vector();
	
	owner.addElement(Owner);
	owner.addElement("owner");
	basicsList.addElement(Owner);

	String Policy = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Policy");
	Vector policy = new Vector();
	
	policy.addElement(Policy);
	policy.addElement("policy");
	basicsList.addElement(Policy);

	String Revision = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Revision");
	Vector revision = new Vector();
	
	revision.addElement(Revision);
	revision.addElement("revision");
	basicsList.addElement(Revision);

	String Type = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Type");
	Vector type = new Vector();
	
	type.addElement(Type);
	type.addElement("type");
	basicsList.addElement(Type);
	
	basics.addElement(current);
	basics.addElement(description);
	basics.addElement(grantee);
	basics.addElement(grantor);
	basics.addElement(modified);
	basics.addElement(nameof);
	basics.addElement(originated);
	basics.addElement(owner);
	basics.addElement(policy);
	basics.addElement(revision);
	basics.addElement(type);

	Vector filteredBasics = filterList( basicsList , basics, filter);
	

	if("checked".equals(chkbxBasic))
	{
		for(int a=0; a < filteredBasics.size(); a++)
		{
			Vector basicItem      = (Vector)filteredBasics.elementAt(a);

			String evenOrOd	      = (a%2 == 0 ? "even" : "odd");			
			String basicItemLabel = (String)basicItem.elementAt(0);
			String basicItemValue = (String)basicItem.elementAt(1);
%>
                <!--XSSOK-->
		<tr class="<%=evenOrOd%>">				

				<!--XSSOK-->
				<td class=node style="text-align: center"><input type="radio" name="tableRowId" value='<%=basicItemValue%>'></td>
				<!--XSSOK-->
				<td class="listCell" valign="top"><img border="0" src="images/iconSmallAttributeGroup.gif"><%=basicItemLabel%></td>
					
		</tr>
<%
		}
	}

	if(tableData != null && tableData.size() > 0)
	{
		for(int i=0; i<tableData.size(); i++)
		{
			Hashtable map		  = (Hashtable)tableData.get(i);
			
			CellData cellData	  = (CellData)map.get("Name");

			String userName		  = cellData.getCellText();
			String userNameValue  = "attribute[" + userName + "]";			
			
			String sUserNameFromResource=  util.getStringResourceFromFrameworkBundle(userName,"Attribute", context);
			if(sUserNameFromResource.equals(""))
				sUserNameFromResource = userName;
				
			String iconUrl		  = cellData.getIconUrl();			
			String expressionType = (String)map.get("ExpressionType");
			String evenOrOdd	  = (i%2 == 0 ? "even" : "odd");
%>		
			<!--XSSOK-->
			<tr class="<%=evenOrOdd%>">

				<script language="javascript">
                                //XSSOK
				parent.userNameTypeMap['<%=userName%>'] = '<%=expressionType%>';

				</script>
                                <!--XSSOK-->
				<td class=node style="text-align: center"><input type="radio" name="tableRowId" value='<%=userNameValue%>'></td>
                                <!--XSSOK-->
				<td class="listCell" valign="top"><img border="0" src="<%=iconUrl%>"><%=sUserNameFromResource%></td>

			</tr>
<%
		}
	}
	else if(filteredBasics.size() == 0)
	{		
		String message = integSessionData.getStringResource("mcadIntegration.Server.Message.NoMatchFound");
%>
                <!--XSSOK-->
		<tr><td colspan="2" style="text-align: center"><%=message%></td></tr> 
<%
	}
%>

</table>
</form>
</body>
</html>
