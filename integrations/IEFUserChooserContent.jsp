<%--  IEFUserChooserContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.MCADIntegration.utils.customTable.*" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);

	//Labels
	String name = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Name");

	String filterInput		= emxGetParameter(request, "txtFilter");
	String chkbxTopLevel	= emxGetParameter(request, "chkbxTopLevel");
	String chkbxPerson		= emxGetParameter(request, "chkbxPerson");
	String chkbxRole		= emxGetParameter(request, "chkbxRole");

	String fromSelectGCOPage	= emxGetParameter(request, "fromSelectGCOPage");
	String selectedUser			= null;

	if((filterInput != null && !filterInput.equals("")))
		filterInput = MCADUrlUtil.hexDecode(filterInput);

	if((fromSelectGCOPage != null && !"".equals(fromSelectGCOPage)) && "true".equals(fromSelectGCOPage))
	{
		filterInput		= (String)session.getAttribute("txtFilter");
		chkbxTopLevel	= (String)session.getAttribute("chkbxTopLevel");
		chkbxPerson		= (String)session.getAttribute("chkbxPerson");
		chkbxRole		= (String)session.getAttribute("chkbxRole");

		session.removeAttribute("txtFilter");
		session.removeAttribute("chkbxTopLevel");
		session.removeAttribute("chkbxPerson");
		session.removeAttribute("chkbxRole");
	}

	HashMap paramMap = new HashMap(5);
	paramMap.put("chkbxTopLevel",chkbxTopLevel);
	paramMap.put("chkbxPerson", chkbxPerson);
	paramMap.put("chkbxRole", chkbxRole);
	paramMap.put("txtFilter", filterInput);

	String[] intArgs = new String[]{};
	CustomMapList tableData = (CustomMapList)JPO.invoke(context, "IEFSearchUsers", intArgs, "getTableData", JPO.packArgs(paramMap), CustomMapList.class);

%>

<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
	<script language="javascript">

<%
	if((fromSelectGCOPage != null && !"".equals(fromSelectGCOPage)) && "true".equals(fromSelectGCOPage))
	 {
%>	var frameheaderDisplay = findFrame(parent,"headerDisplay");
		frameheaderDisplay.document.forms['peopleSearchOptions'].chkbxTopLevel.checked	= <%="checked".equals(chkbxTopLevel)%>;
		frameheaderDisplay.document.forms['peopleSearchOptions'].chkbxPerson.checked	= <%="checked".equals(chkbxPerson)%>;
		frameheaderDisplay.document.forms['peopleSearchOptions'].chkbxRole.checked		= <%="checked".equals(chkbxRole)%>;

		frameheaderDisplay.document.forms['peopleSearchOptions'].chkbxTopLevel.value	= '<xss:encodeForHTMLAttribute><%=chkbxTopLevel%></xss:encodeForHTMLAttribute>';
		frameheaderDisplay.document.forms['peopleSearchOptions'].chkbxPerson.value		= '<xss:encodeForHTMLAttribute><%=chkbxPerson%></xss:encodeForHTMLAttribute>';
		frameheaderDisplay.document.forms['peopleSearchOptions'].chkbxRole.value		= '<xss:encodeForHTMLAttribute><%=chkbxRole%></xss:encodeForHTMLAttribute>';
		frameheaderDisplay.document.forms['peopleSearchOptions'].txtFilter.value		= '<xss:encodeForHTMLAttribute><%=filterInput%></xss:encodeForHTMLAttribute>';

<%
		selectedUser	= (String)session.getAttribute("selectedUser");
		session.removeAttribute("selectedUser");
	}
%>
	</script>



</head>
<body>

<form name="usersListForm" method="post">

	<table border="0" cellpadding="3" cellspacing="2" width="100%">
		<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
		<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
		<link rel="stylesheet" href="styles/emxIEFCommonUI.css" type="text/css">

		<tr>
			<th class=sorted width="5%">&nbsp;</th>
			<th class=sorted>
			<table border="0" cellspacing="0" cellpadding="0">
			        <!--XSSOK-->
				<tr><th><%=name%></th></tr>
			</table>
			</th>
		</tr>
<%
	if(tableData != null && tableData.size() > 0)
	{
		for(int i=0; i<tableData.size(); i++)
		{
			Hashtable map		= (Hashtable)tableData.get(i);

			CellData cellData	= (CellData)map.get("Name");
			String userName		= cellData.getCellText();
			String iconUrl		= cellData.getIconUrl();

			String userType		= (String)map.get("UserType");
			String evenOrOdd	= (i%2 == 0 ? "even" : "odd");
%>
                <!--XSSOK-->
		<tr class="<%=evenOrOdd%>">

			<script language="javascript">
			<!--XSSOK-->
				parent.userNameTypeMap["<%=userName%>"] = "<%=userType%>";
			</script>
                        <!--XSSOK-->
 			<td class=node style="text-align: center"><input type="radio" name="tableRowId" <% if(selectedUser != null && selectedUser.equals(userName)){%> checked <%}%> value="<%=userName%>"></td>

  	        <td class="listCell" valign="top">
			    <!--XSSOK-->
				&nbsp;<img border="0" src="<%=iconUrl%>"><%=userName%>
            </td>

		</tr>

<%
		}
	}
	else
	{
		//No match found
		String message = integSessionData.getStringResource("mcadIntegration.Server.Message.NoMatchFound");
%>
                <!--XSSOK-->
		<tr><td colspan="2" style="text-align: center"><%= message %></td></tr>

<%
	}
%>
	</table>
</form>
</body>
</html>
