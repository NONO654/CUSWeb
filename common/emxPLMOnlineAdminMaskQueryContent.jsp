

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
				setComboboxPosition("maskComboBox", "maskTextboxId");
			}

			//submit query
			function submitQuery(){

				//get all values in textbox if "All" is checked
				var maskPattern = getAllCheckboxValues("maskQueryForm", "maskCheckbox", "maskTextboxId");

				//remove extra commas if necessary
				if(maskPattern != "")
				{
					maskPattern = removeExtraCommas(maskPattern);
				}
				//update textbox value
				document.maskQueryForm.maskPattern.value = maskPattern;

				//alert(maskPattern);
				//submit form
				document.maskQueryForm.action = "emxPLMOnlineAdminMaskQueryResult.jsp";
				document.maskQueryForm.submit();
				//startProgressBar();
			}
			
	</script>

</head>
<body onload="init();">

	<%
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_byName    = getNLS("Access.Mask.Query.byName");
        String i18_Name      = getNLS("Access.Mask.Query.Name");

		//Load all Commands 
		ArrayList maskList = new ArrayList(); 
		
		try{
			maskList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getMaskNames", null, ArrayList.class);

		}
		catch(Exception e)
		{
			out.print("Exception has come: "+ e);
		}
	%>

<form name="maskQueryForm" target="_parent">
	
	<table border="1" cellspacing="0" cellpadding="0" width="100%" >
		<tr>
			<td width="5%" class="barTDInQuery" align="center"><img src="../common/images/iconSmallRule.gif" /></td>
			<td width="85%" class="barTDInQuery"><b><%=i18_byName%></b></td>
			<td width="7%" class="barTDInQuery" ><img src="../common/images/buttonChannelCollapse.gif" id="maskImgId" onclick="switchMenu('divByPolicy', this, 'expandCollapse');"/></td>
		</tr>
	
	</table>
	<div id="divByPolicy">
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<tr>
				<td width="40%" class="label"><%=i18_Name%></td>
				<td class="inputField"> <input type="text" name="maskPattern" id="maskTextboxId" readonly class="textboxForCombo" style="width:250px; padding-left:20px" onclick="showHideList(this, 'maskComboBox')"  id="maskNames" value="All">
					<div id="maskComboBox" class="comboboxInFilter" style="display:none">
						<table bgcolor="white" width="100%" id="maskTableId">
							<tr><td><input type='checkbox' name='maskAll' value='All' checked onclick='updateTextBox(this, "maskTextboxId")' >All</td></tr>
							<%
							for(int i=0;i<maskList.size();i++)
							{
								out.println("<tr><td><input type='checkbox' name='maskCheckbox'  value='"+maskList.get(i)+"' onclick='updateTextBox(this, \"maskTextboxId\")' >"+maskList.get(i)+"</td></tr>");
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
