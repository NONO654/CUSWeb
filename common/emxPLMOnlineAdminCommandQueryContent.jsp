

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminIncludeNLS.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<!--include required for showModalDialog() function-->
<script type="text/javascript" language="javascript" src="../common/scripts/emxUIModal.js"></script>

<html>

<head>

	<title></title>
	
	<link href="../common/styles/emxUIDefault.css" rel="stylesheet" type="text/css" />

	<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
	<link href="styles/emxPLMOnlineAdminStyle.css" rel="stylesheet" type="text/css" />

	<script language="javascript">
			
			//initialization on page loading
			function init()
			{
				//set coboboxes' positions
				setComboboxPosition("commandComboBox", "commandTextboxId");
			}

			//submit query
			function submitQuery(){

				//get all values in textbox if "All" is checked
				var commandPattern = getAllCheckboxValues("commandQueryForm", "commandCheckbox", "commandTextboxId");

				//remove extra commas if necessary
				if(commandPattern != "")
				{
					commandPattern = removeExtraCommas(commandPattern);
				}
				//update textbox value
				document.commandQueryForm.commandPattern.value = commandPattern;

				//alert(commandPattern);
				//submit form
				document.commandQueryForm.action = "emxPLMOnlineAdminCommandQueryResult.jsp";
				document.commandQueryForm.submit();
				//startProgressBar();
			}
			
	</script>

</head>
<body onload="init();">

	<%
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_byName    = getNLS("Access.Command.Query.byName");
        String i18_Name      = getNLS("Access.Command.Query.Name");

		//Load all Commands 
		ArrayList commandList = new ArrayList(); 
		
		try{
			commandList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getCommandNames", null, ArrayList.class);

		}
		catch(Exception e)
		{
			out.print("Exception has come: "+ e);
		}
	%>

<form name="commandQueryForm" target="_parent">
	
	<table border="1" cellspacing="0" cellpadding="0" width="100%" >
		<tr>
			<td width="5%" class="barTDInQuery" align="center"><img src="../common/images/iconSmallRule.gif" /></td>
			<td width="85%" class="barTDInQuery"><b><%=i18_byName%></b></td>
			<td width="7%" class="barTDInQuery" ><img src="../common/images/buttonChannelCollapse.gif" id="commandImgId" onclick="switchMenu('divByPolicy', this, 'expandCollapse');"/></td>
		</tr>
	
	</table>
	<div id="divByPolicy">
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<tr>
				<td width="40%" class="label"><%=i18_Name%></td>
				<td class="inputField"> <input type="text" name="commandPattern" id="commandTextboxId" readonly class="textboxForCombo" style="width:250px;padding-left:20px" onclick="showHideList(this, 'commandComboBox')"  id="commandNames" value="All">
					<div id="commandComboBox" class="comboboxInFilter" style="display:none">
						<table bgcolor="white" width="100%" id="commandTableId">
							<tr><td><input type='checkbox' name='commandAll' value='All' checked onclick='updateTextBox(this, "commandTextboxId")' >All</td></tr>
							<%
							for(int i=0;i<commandList.size();i++)
							{
								out.println("<tr><td><input type='checkbox' name='commandCheckbox'  value='"+commandList.get(i)+"' onclick='updateTextBox(this, \"commandTextboxId\")' >"+commandList.get(i)+"</td></tr>");
							}					
							%>
						</table>
					</div>
				</td>
			</tr>
			
		</table>
	</div>
	
</form>
                                    
</body>
</html>
