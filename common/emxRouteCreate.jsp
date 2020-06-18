<%@ include file="../emxUICommonAppInclude.inc"%> 
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<%	
	Calendar cNow = Calendar.getInstance();
	cNow.add(java.util.GregorianCalendar.DAY_OF_YEAR,-1);

	String sLang 				= request.getHeader("Accept-Language");
	String sLabelHeader			= i18nNow.getI18nString("emxComponents.Common.CreateSimpleRoute", 				"emxComponentsStringResource", sLang);
	String sLabelAssignees		= i18nNow.getI18nString("emxComponents.Command.AssigneeList", 					"emxComponentsStringResource", sLang);	
	String sLabelSelectPerson	= i18nNow.getI18nString("emxComponents.Common.SelectPerson", 					"emxComponentsStringResource", sLang);	
	String sLabelMemberList		= i18nNow.getI18nString("emxFramework.Type.Member_List", 						"emxFrameworkStringResource" , sLang);	
	String sLabelPeople			= i18nNow.getI18nString("emxFramework.Command.People", 							"emxComponentsStringResource", sLang);	
	String sLabelTitle			= i18nNow.getI18nString("emxComponents.AssignTasksDialog.TaskName", 			"emxComponentsStringResource", sLang);	
	String sLabelInstructions	= i18nNow.getI18nString("emxComponents.AssignTasksDialog.Instructions", 		"emxComponentsStringResource", sLang);	
	String sLabelDueDate		= i18nNow.getI18nString("emxComponents.TaskDetails.DueDate", 					"emxComponentsStringResource", sLang);	
	String sLabelRequired		= i18nNow.getI18nString("emxComponents.ActionRequiredDialog.ActionRequired",	"emxComponentsStringResource", sLang);	
	String sLabelAction			= i18nNow.getI18nString("emxFramework.History.ActionType", 						"emxFrameworkStringResource",  sLang);
	String sLabelContents		= i18nNow.getI18nString("emxFramework.Command.Content", 						"emxComponentsStringResource", sLang);
	String sLabelDone			= i18nNow.getI18nString("emxCommonButton.Done", 								"emxComponentsStringResource", sLang);
	String sLabelStart			= i18nNow.getI18nString("emxComponents.Button.StartRoute", 						"emxComponentsStringResource", sLang);
	String sLabelCancel			= i18nNow.getI18nString("emxCommonButton.Cancel", 								"emxComponentsStringResource", sLang);
	String sLabelReset			= i18nNow.getI18nString("emxFramework.FullSearch.button.Reset", 				"emxFrameworkStringResource",  sLang);
	String sValueAll			= i18nNow.getI18nString("emxComponents.ActionRequiredDialog.All", 				"emxComponentsStringResource", sLang);
	String sValueAny			= i18nNow.getI18nString("emxComponents.ActionRequiredDialog.Any", 				"emxComponentsStringResource", sLang);
	String sHeaderType			= i18nNow.getI18nString("emxFramework.Basic.Type", 								"emxFrameworkStringResource" , sLang);
	String sHeaderName			= i18nNow.getI18nString("emxFramework.Basic.Name", 								"emxFrameworkStringResource" , sLang);
	String sHeaderStatus		= i18nNow.getI18nString("emxFramework.Basic.Current", 							"emxFrameworkStringResource" , sLang);
	String sHeaderDescription	= i18nNow.getI18nString("emxFramework.Basic.Description", 						"emxFrameworkStringResource" , sLang);
	String sHeaderBlock			= i18nNow.getI18nString("emxComponents.Common.StateBlock", 						"emxComponentsStringResource", sLang);
	String sLabelComment		= i18nNow.getI18nString("emxFramework.Range.Route_Action.Comment", 				"emxFrameworkStringResource" , sLang);
	String sLabelApprove		= i18nNow.getI18nString("emxFramework.Range.Route_Action.Approve", 				"emxFrameworkStringResource" , sLang);
	String sLabelNotifyOnly		= i18nNow.getI18nString("emxFramework.Range.Route_Action.Notify_Only", 			"emxFrameworkStringResource" , sLang);	
	
	String sErrorDate			= "Date is required and must not be earlier than today's date.";
	
	String attrFirstName = DomainConstants.ATTRIBUTE_FIRST_NAME;
	String attrLastName = DomainConstants.ATTRIBUTE_LAST_NAME;
	StringList slPerson = new StringList();	
	slPerson.add(DomainConstants.SELECT_ID);
	slPerson.add(DomainConstants.SELECT_NAME);
	slPerson.add("attribute["+ attrFirstName +"]");
	slPerson.add("attribute["+ attrLastName +"]");	
	
	String typeMemberList = PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_type_MemberList);
	MapList mlUsers 			= DomainObject.findObjects(context, DomainConstants.TYPE_PERSON, "eService Production", "current == 'Active'", slPerson);	
	MapList mlMemberLists		= DomainObject.findObjects(context, typeMemberList, "eService Production", "(current == 'Active') && (owner =='" + context.getUser() + "')", slPerson);	
	StringBuilder sbUsers 		= new StringBuilder();
	StringBuilder sbUsersList	= new StringBuilder();
	
	mlUsers.sort("attribute["+ attrFirstName +"]", "ascending", "String");
	mlUsers.sort("attribute["+ attrLastName +"]", "ascending", "String");
	mlMemberLists.sort("name", "ascending", "String");
	
	sbUsersList.append("<optgroup label='").append(sLabelPeople).append("'>");
		
	for (int i = 0; i < mlUsers.size(); i++) {
		Map mUser 			  = (Map)mlUsers.get(i);
		String sUserOID 	  = (String)mUser.get(DomainConstants.SELECT_ID);
		String sUserName 	  = (String)mUser.get(DomainConstants.SELECT_NAME);
		String sUserLastName  = (String)mUser.get("attribute["+ attrLastName +"]");
		String sUserFirstName = (String)mUser.get("attribute["+ attrFirstName +"]");
		sUserLastName 		  = sUserLastName.toUpperCase();
		sbUsers.append("'").append(sUserLastName).append(" ").append(sUserFirstName).append(" (").append(sUserName).append(")',");
		sbUsersList.append("<option value='").append(sUserOID).append("'>");
		sbUsersList.append(sUserLastName).append(" ").append(sUserFirstName).append(" (").append(sUserName).append(")");
		sbUsersList.append("</option>");
	}
	if(sbUsers.length() > 0) {
		sbUsers.setLength(sbUsers.length() - 1);
		//sbUsersList.setLength(sbUsersList.length() - 1);
	}	
	
	sbUsersList.append("</optgroup>");
	sbUsersList.append("<optgroup label='").append(sLabelMemberList).append("'>");
	
	for (int i = 0; i < mlMemberLists.size(); i++) {
		Map mMemberList		= (Map)mlMemberLists.get(i);
		String sListOID		= (String)mMemberList.get(DomainConstants.SELECT_ID);
		String sListName	= (String)mMemberList.get(DomainConstants.SELECT_NAME);
		sbUsersList.append("<option value='").append(sListOID).append("'>");
		sbUsersList.append(sListName);
		sbUsersList.append("</option>");
	}	
	
	sbUsersList.append("</optgroup>");
		
	StringBuilder sbContents = new StringBuilder();	
	StringBuilder sbRowIds = new StringBuilder();	
	String[] emxTableRowId = emxGetParameterValues(request, "emxTableRowId");	
	if(null == emxTableRowId) {	emxTableRowId = new String[]{"|" + request.getParameter("objectId") + "|"}; }
	
	StringList slBusSelects = new StringList();
	slBusSelects.add(DomainConstants.SELECT_TYPE);
	slBusSelects.add(DomainConstants.SELECT_NAME);
	slBusSelects.add(DomainConstants.SELECT_CURRENT);
	slBusSelects.add(DomainConstants.SELECT_DESCRIPTION);
	slBusSelects.add(DomainConstants.SELECT_POLICY);
	
	RelationshipType rType 	= new RelationshipType(DomainConstants.RELATIONSHIP_OBJECT_ROUTE);
	BusinessTypeList btList = rType.getFromTypes(context, true);
	StringBuilder sbMessage	= new StringBuilder();
		
	for(int i = 0; i < emxTableRowId.length; i++) {
	
		String sClass = "odd";
		if(i%2 == 0) { sClass = "even"; }
		
		String sRowId 			= emxTableRowId[i];
		String[] aRowId 		= sRowId.split("\\|");	
		DomainObject dObject 	= new DomainObject(aRowId[1]);		
		Map mData 				= dObject.getInfo(context, slBusSelects);		
		String sName 			= (String)mData.get(DomainConstants.SELECT_NAME);	
		String sType 			= (String)mData.get(DomainConstants.SELECT_TYPE);	
		String sTypeLocal   	= i18nNow.getTypeI18NString(sType, sLang);

		BusinessType bType		= btList.find(sType);
		
		if(null == bType) {
			
			sbMessage.append("\\n - ").append(sTypeLocal).append(" ").append(sName);
			
		} else {

		
			String sTypeIcon 		= UINavigatorUtil.getTypeIconProperty(context, sType);		
			String sStatus   		= (String)mData.get(DomainConstants.SELECT_CURRENT);	
			String sPolicy   		= (String)mData.get(DomainConstants.SELECT_POLICY);	
			String sStateLocal 		= i18nNow.getStateI18NString(sPolicy, sStatus, sLang);

			sbRowIds.append(aRowId[1]).append(";");
			
			sbContents.append("<tr class='").append(sClass).append("'>");
			sbContents.append("<td><img src='../common/images/").append(sTypeIcon).append("' /> ").append(sTypeLocal).append("</td>");
			sbContents.append("<td>").append(sName).append("</td>");
			sbContents.append("<td>").append((String)mData.get("description")).append("</td>");
			sbContents.append("<td>").append(sStateLocal).append("</td>");
			sbContents.append("</tr>");	
			
		}		
		
	}
	
		
%>


<html style="background:#FFFFFF;">
	<head>
		<title><%=sLabelHeader%></title>
		<script src="scripts/jquery-1.9.1.js"></script>
		<script src="../plugins/libs/jqueryui/1.10.3/js/jquery-ui.js"></script>
		<script src='../plugins/parsley/js/parsley.js'></script>	
		<script src='../plugins/parsley/js/parsley.extend.js'></script>	
		<script src='../plugins/multipleSelect/js/jquery.multiple.select.js'></script>	
		<link rel="stylesheet" href="../plugins/libs/jqueryui/1.10.3/css/jquery-ui.css" />
		<link rel="stylesheet" href="../plugins/multipleSelect/css/multiple-select.css" />
		<link rel="stylesheet" href="../common/styles/emxUIDefault.css" />
		<link rel="stylesheet" href="../common/styles/emxUIProperties.css" />
		<link rel="stylesheet" href="../common/styles/emxUIForm.css" />
		<link rel="stylesheet" href="../common/styles/emxUIList.css" />
		<link rel="stylesheet" href="../plugins/parsley/css/parsley.css" />
		
		<style rel='stylesheet' type='text/css'>
			div#divPageFoot {
				background : #f1f1f1;
			}
			input, textarea {
				padding: 2px;
			}
			td.field {
				white-space:normal;
			}
			td.heading1{
				background: none repeat scroll 0 0 #FFFFFF;
				border-bottom: 1px solid #BABABA !important;
				color: #333333;
				font-size: 14px;
				font-weight: bold;
				padding: 12px 5px 6px 15px;
				vertical-align: bottom;
			}
		</style>
		
		<script type="text/javascript">
			$(document).ready(function() { 
				$("#duedate").datepicker({
					showWeek		: true, 
					numberOfMonths	: 3, 
					firstDay		: 1
				});
				$("#recipients").multipleSelect({
					filter			: true,
					multiple		: true,
					multipleWidth	: 250,
					selectAll		: false,
					placeholder		: '<%=sLabelSelectPerson%>'
				});				
			});
		</script>
		
		<script>
			function submitData(startRoute) {
				if(startRoute == false || $('#createRoute').parsley( 'validate' )) {
					var objform = document.forms['createRoute'];
					objform.action = "emxRouteCreateProcess.jsp?start=" + startRoute;
					objform.submit();
				} else {								
					if(null == $('#recipients').val()) {
						$('.ms-choice').css("border", "1px solid #CC0000");
						$('.ms-choice').css("background-color", "#FFD7D8");
					} else {
						$('.ms-choice').css("border", "1px solid #AAAAAA");
						$('.ms-choice').css("background-color", "#FFFFFF");
					}				
					alert("The route cannot be started with the data provided.\nPlease update the highlighed entry fields.");				
				}
			}
		</script>
		
	</head>
	<body>
	
<%	if(sbMessage.length() > 0) {%>
		<script type="text/javascript">
			alert("The following items cannot be connected to routes and have been removed from the selection:<%=XSSUtil.encodeForJavaScript(context, sbMessage.toString())%>");
		</script>
<%	} %>	
		
		<div id="pageHeadDiv">
			<table>
				<tbody>
					<tr>
						<td class="page-title">
							<h2><%=sLabelHeader%></h2>
						</td>
						<td class="functions">
					</tr>
				</tbody>
			</table>
		</div>
		
		<div id="editor" class="editor2">
			<form nsubmit="return false;" method="post" name="createRoute" id="createRoute" data-validate="parsley">
				<table>
					<tr>
						<td class="label" width="150"><%=sLabelAssignees%></td>
						<td class="field">
						   <select style="width:600px;" id='recipients' name='recipients' multiple="multiple"  data-required='true' data-error-container='dummy' data-trigger='change'>
								<%=sbUsersList.toString()%>
							</select>     <span id="disableBtn" style="cursor:pointer;color:#207cca;"><%=sLabelReset%></span>
							<script type="text/javascript">
        $("#disableBtn").click(function() {
            $("#recipients").multipleSelect("uncheckAll");
        });
							</script>
						</td>
					</tr>
					<tr>
						<td class="label" width="150"><%=sLabelTitle%></td>
						<td class="inputField"><input style="padding:2px;" id='title' name="title" data-required='true' data-error-container='dummy' data-trigger='change'></input></td>
					</tr>					
					<tr>
						<td class="label" width="150"><%=sLabelDueDate%></td>
						<td class="field"><input style='display:inline-block;float:left;' type='text' id='duedate' name='duedate' onClick='this.select();' value=''  size='10' data-required='true' data-error-container='#dateError' data-trigger='change' data-error-message='<%=sErrorDate%>' data-afterdate='#afterDate-Value'/><span style='line-height:20px;color:#cc0000;vertical-align:middle;display:inline-block;float:left;' id='dateError'></span></td>
					</tr>	
					<tr>
						<td class="label" width="150"><%=sLabelInstructions%></td>
						<td class="inputField"><textarea id='instructions' name="instructions" cols="40" rows="5"></textarea></td>
					</tr>	
					<tr>
						<td class="label" width="150"><%=sLabelRequired%></td>
						<td class="field">
							<select name="required" size="1">
								<option value="All" selected><%=sValueAll%></option>
								<option value="Any" ><%=sValueAny%></option>   
							</select>
						</td>
					</tr>						
					<tr>
						<td class="label" width="150"><%=sLabelAction%></td>
						<td class="field">
							<select name="action" size="1">
								<option value="Approve"><%=sLabelApprove%></option>
								<option value="Comment" selected><%=sLabelComment%></option>
								<option value="Notify Only"><%=sLabelNotifyOnly%></option>     
							</select>
						</td>
					</tr>					
					<tr>
						<td class="heading1" colspan="2"><%=sLabelContents%></td>
					</tr>					
					<tr>
						<td colspan="2">												
							<table id="docList" class="list">
								<tbody>
									<tr>
										<th nowrap=""><%=sHeaderType%></th>
										<th nowrap=""><%=sHeaderName%></th>
										<th nowrap=""><%=sHeaderDescription%></th>
										<th nowrap=""><%=sHeaderStatus%></th>
									</tr>	
									<%=sbContents.toString()%>
								</tbody>
							</table>
						</td>
					</tr>	
				</table>
				<input type="hidden" id="afterDate-Value" value="<%=cNow.get(Calendar.MONTH)+1%>/<%=cNow.get(Calendar.DAY_OF_MONTH)%>/<%=cNow.get(Calendar.YEAR)%>" />				
				<input type="hidden"  name="ids" value="<%= XSSUtil.encodeForHTMLAttribute(context, sbRowIds.toString())%>"/>
			</form>
		</div>
		
		<div class="footer">
			<table><tr>
				<td width="100%"></td>
			</tr></table>
		</div>		
		<div id="divPageFoot">
			<div id="divDialogButtons">
				<table>
					<tbody>
						<tr>
							<td class="functions"></td>
							<td class="buttons">
								<table>
									<tbody>
										<tr>								
											<td><a class="footericon" onclick="submitData(false)"  href="javascript:void(0)"><img border="0" alt="Done" src="../common/images/buttonDialogDone.gif"></a> </td>
											<td><a onclick="submitData(false)"  href="javascript:void(0)"><button class="btn-primary" type="button"><%=sLabelDone%></button></a></td>
											<td><a class="footericon" onclick="submitData(true)"   href="javascript:void(0)"><img border="0" alt="Apply" src="../common/images/buttonDialogApply.gif"></a> </td>
											<td><a onclick="submitData(true)"   href="javascript:void(0)"><button class="btn-default" type="button"><%=sLabelStart%></button></a></td>					
											<td><a class="footericon" onclick="window.closeWindow()" 	href="javascript:void(0)"><img border="0" alt="Cancel" src="../common/images/buttonDialogCancel.gif"></a> </td>
											<td><a onclick="window.closeWindow()" 	href="javascript:void(0)"><button class="btn-default" type="button"><%=sLabelCancel%></button></a></td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
		
	</body>
</html>
