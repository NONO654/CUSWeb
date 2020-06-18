
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminIncludeNLS.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<html>
<!-- This file is to generate the commands Access hosting page-->
<head>

	<title></title>
	
	<link href="../common/styles/emxUIDefault.css" rel="stylesheet" type="text/css" />

	<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
	<link href="styles/emxPLMOnlineAdminStyle.css" rel="stylesheet" type="text/css" />

	<script language="javascript">
			
			//var to contain previous statePattern input for Report
			var prevCommandPattern = "NoPrevious";
			//get tree object
			var objDetailsTree = top.objDetailsTree;
			//get tree's root name
			var treeRoot = objDetailsTree.getCurrentRoot().getName();

			//initialization on page loading
			function init()
			{
				//set cobobox position
				setComboboxPosition("commandComboBox", "commandTextboxId");
				//refresh report
				refreshReport();
			}

			//refresh report
			function refreshReport(){

				//get all values in textbox if "All" is checked
				var commandPattern = getAllCheckboxValues("filterIncludeForm", "commandCheckbox", "commandTextboxId");

				//remove extra commas if necessary
				if(commandPattern != "")
				{
					commandPattern = removeExtraCommas(commandPattern);
				}

				//refresh report with new values
				//added temporarily to work in MySpace
				if(treeRoot != "<%=context.getUser()%>")
					treeRoot = "<%=context.getUser()%>";
				//end
				if(prevCommandPattern != commandPattern)
					document.getElementById("contentFrame").src = "emxPLMOnlineAdminCommandsContent.jsp?treeRoot="+treeRoot+"&commandPattern="+commandPattern;
				prevCommandPattern = commandPattern;
			}

	</script>

</head>
	<body  onload="init()">
	<%
        initTrace("AdminCommandReportUI");
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_command = getNLS("Filter.Command");
        String i18_report  = getSafeNLS("Filter.Report");
        try {
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
	  <form name="filterIncludeForm">
          <table border="0" cellspacing="2" cellpadding="0" width="100%">
             <tr>
                 <td>
                    <table border="0" cellspacing="0" cellpadding="0" width="100%">
                       <tr>
                          <td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1" alt=""></td>
                       </tr>
                     </table>
                        </td></tr>
                     </table>
                     <table >
                        <tr>
                          <td class="labelInFilter"><label><%=i18_command%></label></td>
						  <td> <input type="text" name="commandPattern" id="commandTextboxId" readonly class="textboxForCombo" style="width:220px;" onclick="showHideList(this, 'commandComboBox');" value="All">
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
						<td width="50"> &nbsp; </td>
						<td width="150"><input type="button" class="buttonInFilter" name="btnFilter" value="<%=i18_report%>" onclick="refreshReport()"></td>
					</tr>
				</table>
			</form>
	
		<iframe name="contentFrame" id="contentFrame" frameborder="0" class="iframe" src="" width="100%" height="540"/>
	<%
    }
    catch (Exception ex) {
        ex.printStackTrace();
    }
	%>
	
	</body>

</html>
