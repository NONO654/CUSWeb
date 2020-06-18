

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
				setComboboxPosition("ruleComboBox", "ruleTextboxId");
			}

			//submit query
			function submitQuery(){

				//get all values in textbox if "All" is checked
				var rulePattern = getAllCheckboxValues("ruleQueryForm", "ruleCheckbox", "ruleTextboxId");

				//remove extra commas if necessary
				if(rulePattern != "")
				{
					rulePattern = removeExtraCommas(rulePattern);
				}
				//update textbox value
				document.ruleQueryForm.rulePattern.value = rulePattern;

				//alert(rulePattern);
				//submit form
				document.ruleQueryForm.action = "emxPLMOnlineAdminRuleQueryResult.jsp";
				document.ruleQueryForm.submit();
				//startProgressBar();
			}
			
	</script>

</head>
<body onload="init();">

	<%
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_byGovernedTypes = getNLS("Access.Rule.Query.byGovernedRels");
        String i18_GovernedType    = getNLS("Access.Rule.Query.GovernedRel");
        String i18_byRuleName      = getNLS("Access.Rule.Query.byRuleName");
        String i18_RuleName        = getNLS("Access.Rule.Query.RuleName");

		//Load all Relations
		ArrayList relationList = new ArrayList(); 
		
		try{
			relationList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getInstanceNames", null, ArrayList.class);

		}
		catch(Exception e)
		{
			out.print("Exception has come: "+ e);
		}
		
		//Load all rules from relations
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

<form name="ruleQueryForm" target="_parent">
	<table border="1" cellspacing="0" cellpadding="0" width="100%">
		<tr>
			<td width="5%" class="barTDInQuery" align="center"><img src="../common/images/iconSmallType.gif" /></td>
			<td width="85%" class="barTDInQuery"><b><%=i18_byGovernedTypes%></b></td>
			<td width="7%" class="barTDInQuery" ><img src="../common/images/buttonChannelCollapse.gif" id="relationshipImgId" onclick="switchMenu('divByRelation', this, 'expandCollapse');"/></td>
	   </tr>
	</table>
	<div id="divByRelation">
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<tr>
				<td width="40%" class="label"><%=i18_GovernedType%></td>
				<td class="inputField" > <input type="text" name="relationPattern" size="10" id="relationshipNames" value="All" readonly> &nbsp; &nbsp;<input type="button"  class="buttonInQuery"  value="..." onclick="showModalDialog('../common/emxTable.jsp?table=emxPLMOnlineAdminModelViewReferenceTable&selection=multiple&program=emxPLMOnlineAdminModelViewProgram:getInstanceNames&objectBased=false&Style=Dialog&FilterFramePage=emxPLMOnlineAdminCustomFilter.jsp&mode=open&CancelButton=true&CancelLabel=Cancel&SubmitLabel=Done&SubmitURL=emxPLMOnlineAdminRulesSelectRelationsProcess.jsp?formName=ruleQueryForm')"></td>
			</tr>
			
		</table>
	</div>
	<table border="1" cellspacing="0" cellpadding="0" width="100%" >
		<tr>
			<td width="5%" class="barTDInQuery" align="center"><img src="../common/images/iconSmallRule.gif" /></td>
			<td width="85%" class="barTDInQuery"><b><%=i18_byRuleName%></b></td>
			<td width="7%" class="barTDInQuery" ><img src="../common/images/buttonChannelCollapse.gif" id="ruleImgId" onclick="switchMenu('divByRule', this, 'expandCollapse');"/></td>
		</tr>
	</table>
	<div id="divByRule">
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<tr>
				<td width="40%" class="label"><%=i18_RuleName%></td>
				<td class="inputField"> <input type="text" name="rulePattern" id="ruleTextboxId" readonly class="textboxForCombo" style="width:250px; padding-left:20px" onclick="showHideList(this, 'ruleComboBox')"  id="ruleNames" value="All">
					<div id="ruleComboBox" class="comboboxInFilter" style="display:none">
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
			</tr>
			
		</table>
	</div>
	
</form>
                                    
</body>
</html>
