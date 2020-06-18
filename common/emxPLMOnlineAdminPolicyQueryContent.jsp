

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
				setComboboxPosition("policyComboBox", "policyTextboxId");
			}

			//submit query
			function submitQuery(){

				//get all values in textbox if "All" is checked
				var policyPattern = getAllCheckboxValues("policyQueryForm", "policyCheckbox", "policyTextboxId");

				//remove extra commas if necessary
				if(policyPattern != "")
				{
					policyPattern = removeExtraCommas(policyPattern);
				}
				//update textbox value
				document.policyQueryForm.policyPattern.value = policyPattern;

				//alert(policyPattern);
				//submit form
				document.policyQueryForm.action = "emxPLMOnlineAdminPolicyQueryResult.jsp";
				document.policyQueryForm.submit();
				//startProgressBar();
			}
			
	</script>

</head>
<body onload="init();">

	<%
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_byGovernedTypes = getNLS("Access.Policy.Query.byGovernedTypes");
        String i18_GovernedType    = getNLS("Access.Policy.Query.GovernedType");
        String i18_byPolicyName    = getNLS("Access.Policy.Query.byPolicyName");
        String i18_PolicyName      = getNLS("Access.Policy.Query.PolicyName");

		//Load all Policies 
		ArrayList policyList = new ArrayList(); 
		
		try{
			policyList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getPolicyNames", null, ArrayList.class);

		}
		catch(Exception e)
		{
			out.print("Exception has come: "+ e);
		}
			
	%>

<form name="policyQueryForm" target="_parent">
	<table border="1" cellspacing="0" cellpadding="0" width="100%">
		<tr>
			<td width="5%" class="barTDInQuery" align="center"><img src="../common/images/iconSmallType.gif" /></td>
			<td width="85%" class="barTDInQuery"><b><%=i18_byGovernedTypes%></b></td>
			<td width="7%" class="barTDInQuery" ><img src="../common/images/buttonChannelCollapse.gif" id="typesImgId" onclick="switchMenu('divByType', this, 'expandCollapse');"/></td>
	   </tr>
	</table>
	<div id="divByType">
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<tr>
				<td width="40%" class="label"><%=i18_GovernedType%></td>
				<td class="inputField" > <input type="text" name="typePattern" size="10" id="typeNames" value="All" readonly> &nbsp; &nbsp;<input type="button"  class="buttonInQuery"  value="..." onclick="showModalDialog('../common/emxTable.jsp?table=emxPLMOnlineAdminModelViewReferenceTable&selection=multiple&program=emxPLMOnlineAdminModelViewProgram:getReferenceNames&objectBased=false&Style=Dialog&FilterFramePage=emxPLMOnlineAdminCustomFilter.jsp&mode=open&CancelButton=true&CancelLabel=Cancel&SubmitLabel=Done&SubmitURL=emxPLMOnlineAdminPoliciesSelectTypesProcess.jsp?formName=policyQueryForm')"></td>
			</tr>
			
		</table>
	</div>
	<table border="1" cellspacing="0" cellpadding="0" width="100%" >
		<tr>
			<td width="5%" class="barTDInQuery" align="center"><img src="../common/images/iconSmallRule.gif" /></td>
			<td width="85%" class="barTDInQuery"><b><%=i18_byPolicyName%></b></td>
			<td width="7%" class="barTDInQuery" ><img src="../common/images/buttonChannelCollapse.gif" id="policyImgId" onclick="switchMenu('divByPolicy', this, 'expandCollapse');"/></td>
		</tr>
	
	</table>
	<div id="divByPolicy">
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<tr>
				<td width="40%" class="label"><%=i18_PolicyName%></td>
				<td class="inputField"> <input type="text" name="policyPattern" id="policyTextboxId" readonly class="textboxForCombo" style="width:250px;padding-left : 20px" onclick="showHideList(this, 'policyComboBox')"  id="policyNames" value="All">
					<div id="policyComboBox" class="comboboxInFilter" style="display:none">
						<table bgcolor="white" width="100%" id="policyTableId">
							<tr><td><input type='checkbox' name='policyAll' value='All' checked onclick='updateTextBox(this, "policyTextboxId")' >All</td></tr>
							<%
							for(int i=0;i<policyList.size();i++)
							{
								out.println("<tr><td><input type='checkbox' name='policyCheckbox'  value='"+policyList.get(i)+"' onclick='updateTextBox(this, \"policyTextboxId\")' >"+policyList.get(i)+"</td></tr>");
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
