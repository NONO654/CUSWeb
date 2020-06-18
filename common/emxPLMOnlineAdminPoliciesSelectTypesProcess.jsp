
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>


<%
	System.out.println("in emxPLMOnlineAdminPoliciesSelectTypesProcess.jsp ");
	//get table row Ids
	String[] strTableRowIds = request.getParameterValues("emxTableRowId");
	//list to contain policy names
	ArrayList polList = new ArrayList();
	//step through each Id
	for(int i=0;i<strTableRowIds.length;i++)
	{
		//get policy name
		String policyName = FrameworkUtil.decodeURL(strTableRowIds[i], "UTF-8");

		//get query result
		String commResult = "";
		try{
		commResult = MqlUtil.mqlCommand(context, "print type $1 select policy dump",policyName);
		System.out.println("getting result :: "+commResult);
		}
		catch(Exception e)
		{
			System.out.print("Exception has come: "+ e);
		}
		//split results to get policy names
		String[] command = commResult.split(",");
		for(int j=0;j<command.length;j++)
		{
			if(!polList.contains(command[j]) && !polList.equals(""))
			{
				//add policy name to list
				polList.add(command[j]);
				System.out.println("Policy Name: "+command[j]);
			}
		}
	}
	//list to contain state names (with policy names)
	ArrayList stateList = new ArrayList(); 
	//pack policy list in JPO args
	HashMap polMap = new HashMap();
	polMap.put("policyList",polList);
	String []args = JPO.packArgs(polMap);
	//call JPO method to get state list
	try{
		//System.out.println("getting invoke ::"+JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getPolicyNames",null, ArrayList.class));
		stateList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getStates", args, ArrayList.class);
		}
	catch(Exception e)
	{
		System.out.print("Exception has come: "+ e);
	}

	//get form name
	String formName = request.getParameter("formName");
	
%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language = "javascript">

	
	//get table frame
	var tableFrame = findFrame(top, "listDisplay");
	//var to contain selected values
	var selectedValues = "";

	var formToBeFilled;
	<%
	if(formName == null || formName.equals(""))
	{
	%>
		//get form to be updated
		formToBeFilled = top.opener.document.filterIncludeForm;
	<%
	}
	else
	{
	%>
		//alert(eval("top.opener.document.<%=formName%>"));
		//get form to be updated from sent parameter
		formToBeFilled = eval("top.opener.document.<%=formName%>");
	<%
	}
	%>
	//get text field to be filled
	var textFieldToBeFilled = formToBeFilled.typePattern;

	//if there are more than one checkbox
	if(tableFrame.document.emxTableForm.emxTableRowId.length)
	{
		//step through each row Id
		for (var i=0; i < tableFrame.document.emxTableForm.emxTableRowId.length; i++)
		{
		  //if it is selected then append it to string
		  if (tableFrame.document.emxTableForm.emxTableRowId[i].checked)
		  {
			selectedValues += tableFrame.document.emxTableForm.emxTableRowId[i].value + ",";
		  }
		}
	}
	//if there is only one checkbox
	else
	{
		selectedValues = tableFrame.document.emxTableForm.emxTableRowId.value;
	}

   selectedValues = selectedValues.substring(0, selectedValues.length - 1);
   //unscape characters
   selectedValues = unescape(selectedValues);
   //alert(selectedValues);
	//update field value
   textFieldToBeFilled.value = selectedValues;

	//array to contain policy names
	var policyArray = new Array();
<%
	//update array with policy names
	for(int i=0;i<polList.size();i++)
	{
		String policyName = (String)polList.get(i);
			
		%>
		policyArray[<%=i%>] = <%="'"+policyName+"'"%>;
		//alert(<%="'"+policyName+"'"%>);
		<%
	}
%>
	//array to contain state names (with policy names)
	var stateArray = new Array();
<%
	//update array with state names
	for(int i=0;i<stateList.size();i++)
		{
			String stateName = (String)stateList.get(i);
			
			%>
			stateArray[<%=i%>] = <%="'"+stateName+"'"%>;
			<%
		}
%>

	
	//alert(policyArray);
	//update policy and state comboboxes in main page
	top.opener.fillCombobox(policyArray, "policy");
	<%
	if(formName == null || formName.equals(""))
	{
	%>
		top.opener.fillCombobox(stateArray, "state"); 
		//update global array of states with new values
		top.opener.updateGlobalStateArray(stateArray);
	<%
	}
	%>

	//close window
	top.close();


</script>
