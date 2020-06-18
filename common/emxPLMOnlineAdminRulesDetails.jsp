

<%@include file = "../common/emxNavigatorInclude.inc"%>
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

			//var to contain previous rulePattern input for Report
			var prevRulePattern = "NoPrevious";
			//var to contain previous accessPattern input for Report
			var prevAccessPattern = "NoPrevious";

			//get tree object
			var objDetailsTree = top.objDetailsTree;
			//get tree's root name
			var treeRoot = objDetailsTree.getCurrentRoot().getName();
			
			//initialization on page loading
			function init()
			{
				//set cobobox position
				setComboboxPosition("ruleComboBox", "ruleTextboxId");
				//refresh report
				refreshReport();
			}

			//refresh report
			function refreshReport(){

				var accessPattern = document.filterIncludeForm.accessPattern.value;
				//get all values in textbox if "All" is checked
				var rulePattern = getAllCheckboxValues("filterIncludeForm", "ruleCheckbox", "ruleTextboxId");

				//remove extra commas if necessary
				if(rulePattern != "")
				{
					rulePattern = removeExtraCommas(rulePattern);
				}

				//refresh report with new values
				//added temporarily to work in MySpace
				if(treeRoot != "<%=context.getUser()%>")
					treeRoot = "<%=context.getUser()%>";
				//end
				//update Report only if inputs are different
				if(prevRulePattern != rulePattern || prevAccessPattern != accessPattern)
					document.getElementById("contentFrame").src = "emxPLMOnlineAdminRulesContent.jsp?treeRoot="+treeRoot+"&rulePattern="+rulePattern+"&accessPattern="+accessPattern;
				
				//update previous rulePattern
				prevRulePattern = rulePattern;
				//update previous accessPattern
				prevAccessPattern = accessPattern;
			}
	</script>

</head>
	<body  onload="init()">
	<%
        initTrace("AdminRuleReportUI");
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_relation= getNLS("Filter.Relation");
        String i18_rule    = getNLS("Filter.Rule");
        String i18_access  = getNLS("Filter.Access");
        String i18_report  = getSafeNLS("Filter.Report");
		try {
		//Load all Relation 
		ArrayList relationList = new ArrayList(); 
		
		try{
			relationList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getInstanceNames", null, ArrayList.class);
		}
		catch(Exception e)
		{
			out.print("Exception has come: "+ e);
		}
		for(int i=0;i<relationList.size();i++)
		{
			String relationName = (String)relationList.get(i);
		}

		//Load all rules 
		ArrayList ruleList = new ArrayList(); 
		HashMap polMap = new HashMap();
		polMap.put("relationList",relationList);
		String []args = JPO.packArgs(polMap);
		
		try{
			ruleList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getRulesFromRelations", args, ArrayList.class);
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
                          <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt=""></td>
                       </tr>
                     </table>
                        </td></tr>
                     </table>
                     <table >
                        <tr>
                          <td class="labelInFilter"><label><%=i18_relation%></label></td>
                          <td class="inputField" > <input type="text" name="relationPattern" size="10" id="relationNames" value="All" readonly></td>
						  <td> <input type="button" class="buttonInFilter" value="..." onclick="showModalDialog('../common/emxTable.jsp?table=emxPLMOnlineAdminModelViewInstanceTable&selection=multiple&program=emxPLMOnlineAdminModelViewProgram:getInstanceNames&objectBased=false&Style=Dialog&FilterFramePage=emxPLMOnlineAdminCustomFilter.jsp&mode=open&CancelButton=true&CancelLabel=Cancel&SubmitLabel=Done&SubmitURL=emxPLMOnlineAdminRulesSelectRelationsProcess.jsp')"></td>
                          <td > &nbsp; </td>
                          <td class="labelInFilter"><label><%=i18_rule%></label></td>
						  <td> <input type="text" name="rulePattern" id="ruleTextboxId" readonly class="textboxForCombo" style="width:220px" onclick="showHideList(this, 'ruleComboBox');" id="ruleNames" value="All">
							<div id="ruleComboBox" class="comboboxInFilter" style="display:none;">
								<table bgcolor="white" width="100%" id="ruleTableId">
									<tr><td><input type='checkbox' name='ruleAll' value='All' checked onclick='updateTextBox(this, "ruleTextboxId")' >All</td></tr>
									<%
									for(int i=0;i<ruleList.size();i++)
									{
										out.println("<tr><td><input type='checkbox' name='ruleCheckbox'  value='"+ruleList.get(i)+"' onclick='updateTextBox(this, \"ruleTextboxId\")' >"+ruleList.get(i)+"</td></tr>");
									}					
									%>
								</table>
							</div>
						</td>

						<td > &nbsp; </td>
						<td class="labelInFilter"><label><%=i18_access%></label></td>
						<td class="inputField" >
							<input type="text" name="accessPattern" size="10" value="All" readonly>
						</td>
						<td> <input type="button"  class="buttonInFilter" value="..." onclick="showModalDialog('emxPLMOnlineAdminAccessDisplayFS.jsp')"></td>
						<td width="50"> &nbsp; </td>
						<td width="150"><input type="button"  class="buttonInFilter" name="btnFilter" value="<%=i18_report%>" onclick="refreshReport()"></td>
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
