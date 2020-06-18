

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<%
	System.out.println("in emxComponentsPersonViewAccessRulesSelectRelations.jsp ");
	//get table row Ids
	String[] strTableRowIds = request.getParameterValues("emxTableRowId");
	//list to contain policy names
	ArrayList relationList = new ArrayList(); 
	//step through each Id
	for(int i=0;i<strTableRowIds.length;i++)
	{
		//get relationship name
		String relation = FrameworkUtil.decodeURL(strTableRowIds[i], "UTF-8");
		
		//add relationship name to list
		relationList.add(relation);
	}

	//Load all rules 
	//list to contain rule names
	ArrayList ruleList = new ArrayList(); 

	//pack relationship list in JPO args
	HashMap ruleMap = new HashMap();
	ruleMap.put("relationList",relationList);
	String []args = JPO.packArgs(ruleMap);
	//call JPO method to get rule list
	try{
		//System.out.println("getting invoke ::"+JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getRelationNames",null, ArrayList.class));
		ruleList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getRulesFromRelations", args, ArrayList.class);
	}
	catch(Exception e)
	{
		out.print("Exception has come: "+ e);
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
	var textFieldToBeFilled = formToBeFilled.relationPattern;

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
		selectedValues = selectedValues.substring(0, selectedValues.length - 1);
	}
	//if there is only one checkbox
	else
	{
		selectedValues = tableFrame.document.emxTableForm.emxTableRowId.value;
	}
   selectedValues = unescape(selectedValues);
   //alert(selectedValues);
   //unscape characters
   textFieldToBeFilled.value = selectedValues;

	//array to contain rule names
	var ruleArray = new Array();
<%
	//update array with policy names
	for(int i=0;i<ruleList.size();i++)
		{
			String ruleName = (String)ruleList.get(i);
			
			%>
			ruleArray[<%=i%>] = <%="'"+ruleName+"'"%>;
			//alert(<%="'"+ruleName+"'"%>);
			<%
		}
%>

		
	//alert(ruleArray);
	//update rule combobox in main page
	top.opener.fillCombobox(ruleArray, "rule");

	//close window
	top.close();


</script>
