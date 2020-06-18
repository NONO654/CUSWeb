
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<%
	//array to contains all accesses' names <TODO - confirm if we can retrieve the list with M1 API>
	String[] accessList = {"Read", "Modify", "Delete", "CheckOut", "CheckIn", "Schedule", "Lock", "Execute", "UnLock", "Freeze", "Thaw", "Create", "Revise", "Promote", "Demote", "Grant", "Enable", "Disable", "Override", "ChangeName", "ChangeType", "ChangeOwner", "ChangePolicy", "Revoke", "ChangeVault", "FromConnect", "ToConnect", "FromDisconnect", "ToDisconnect", "ViewForm", "ModifyForm", "Show"};
%>

<script language="javascript">
	
	//select all checkboxes
	function selectAll(currentChkBox){
		if(currentChkBox.checked == true)
		{
			document.accessForm.None.checked = false;
			<%
			for(int i = 0; i < accessList.length; i++)
			{
			%>
				document.accessForm.<%=accessList[i]%>.checked = true;
				document.accessForm.<%=accessList[i]%>.disabled = true;
			<%
			}
			%>
		}
		else
		{
			<%
			for(int i = 0; i < accessList.length; i++)
			{
			%>
				document.accessForm.<%=accessList[i]%>.disabled = false;
			<%
			}
			%>
		}

	}
	//select no checkbox
	function selectNone(currentChkBox){
		if(currentChkBox.checked == true)
		{
			document.accessForm.All.checked = false;
			<%
			for(int i = 0; i < accessList.length; i++)
			{
			%>
				document.accessForm.<%=accessList[i]%>.checked = false;
				document.accessForm.<%=accessList[i]%>.disabled = true;
			<%
			}
			%>
		}
		else
		{
			<%
			for(int i = 0; i < accessList.length; i++)
			{
			%>
				document.accessForm.<%=accessList[i]%>.disabled = false;
			<%
			}
			%>
		}

	}
	//submit selected acceses
	function submitAccesses(){
		//alert(parent.window.opener.document.body.innerHTML);
		var selectedValues = "";
		var formToBeFilled = parent.window.opener.document.filterIncludeForm;
		var textFieldToBeFilled = formToBeFilled.accessPattern;

		if(document.accessForm.All.checked == true)
		{
			selectedValues = "All";
		}
		else if(document.accessForm.None.checked == true)
		{
			selectedValues = "None";
		}
		else
		{
			<%
			//get all selected values
			for(int i = 0; i < accessList.length; i++)
			{
			%>
				if(document.accessForm.<%=accessList[i]%>.checked == true)
				{
					selectedValues += document.accessForm.<%=accessList[i]%>.name + ",";
				}
			<%
			}
			%>

			selectedValues = selectedValues.substring(0, selectedValues.length - 1);
		}
	    //alert(selectedValues);
		textFieldToBeFilled.value = selectedValues;
		//close window
		parent.close();
	}
				
</script>
<body>
<form name="accessForm" >
<table width="100%">
	<tr>
		<td>
		<input type='checkbox' name='All' onclick="selectAll(this)">All &nbsp;&nbsp;&nbsp;
		<input type='checkbox' name='None'  onclick="selectNone(this)">None
		<td>
	</tr>
<%
	//build table cells with acceses
	for(int i=0;i<accessList.length; i = i + 4)
	{
		%>
		<tr>
		<%
		for(int j=0;j < 4; j++)
		{
		%>
			<td class="label"><input type='checkbox' name='<%=accessList[i+j]%>' ><%=accessList[i+j]%><td>
		<%
		}
		%>
		<tr>
		<%
	}
%>
</table>

</form>
</body>
