
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminIncludeNLS.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<html>

<head>

	<title></title>
	
	<link href="../common/styles/emxUIDefault.css" rel="stylesheet" type="text/css" />

	<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
	<link href="styles/emxPLMOnlineAdminStyle.css" rel="stylesheet" type="text/css" />

	<script language="javascript">

			//var to contain previous maskPattern input for Report
			var prevMaskPattern = "NoPrevious";
			//get tree object
			var objDetailsTree = top.objDetailsTree;
			//get tree's root name
			var treeRoot = objDetailsTree.getCurrentRoot().getName();

			
			//initialization on page loading
			function init()
			{
				//set cobobox position
				setComboboxPosition("maskComboBox", "maskTextboxId");
				//refresh report
				refreshReport();
			}

			//refresh report
			function refreshReport(){

				//get all values in textbox if "All" is checked
				var maskPattern = getAllCheckboxValues("filterIncludeForm", "maskCheckbox", "maskTextboxId");

				//remove extra commas if necessary
				if(maskPattern != "")
				{
					maskPattern = removeExtraCommas(maskPattern);
				}

				//refresh report with new values
				//added temporarily to work in MySpace
				if(treeRoot != "<%=context.getUser()%>")
					treeRoot = "<%=context.getUser()%>";
				//end
				//update Report only if inputs are different
				if(prevMaskPattern != maskPattern)
					document.getElementById("contentFrame").src = "emxPLMOnlineAdminMasksContent.jsp?treeRoot="+treeRoot+"&maskPattern="+maskPattern;
				//update previous maskPattern
				prevMaskPattern = maskPattern;
			}
	</script>

</head>
	<body  onload="init()">
	<%
    initTrace("AdminMaskReportUI");
    initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
			
        String i18_mask    = getNLS("Filter.Mask");
        String i18_report  = getSafeNLS("Filter.Report");
        try {
		//Load all Masks 
		ArrayList maskList = new ArrayList(); 
		
		try{
			maskList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getMaskNames", null, ArrayList.class);

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
                          <td class="labelInFilter"><label><%=i18_mask%></label></td>
						  <td> <input type="text" name="maskPattern" readonly class="textboxForCombo" style="width:220px" onclick="showHideList(this, 'maskComboBox');"  id="maskTextboxId" value="All">
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
