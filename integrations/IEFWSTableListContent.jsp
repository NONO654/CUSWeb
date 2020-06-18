<%--  IEFWSTableListContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<html>
<head>

<%
MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
Context context                             = integSessionData.getClonedContext(session);
MCADMxUtil util                             = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());


String resultOfPrevOperation =Request.getParameter(request,"result");
String firstIntegName        =Request.getParameter(request,"firstIntegName");
IEFConfigUIUtil configUIUtil                = new IEFConfigUIUtil(context, integSessionData, firstIntegName);
String workspacePrefix    = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.WorkspaceTablePrefix");
String name               = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Name");
String heading            = "mcadIntegration.Server.Heading.WorkSpaceTables";
String listPageUrl        = "IEFConfigUIDialogFS.jsp?pageHeading=" + heading + "&contentPage=IEFWSTableListContent.jsp&firstIntegName="+firstIntegName+"&onBeforeUnload=window.frames['contentFrame'].refreshPreferencePage()&createIcon=buttonCreateTable.gif&modifyIcon=buttonModifyTable.gif&deleteIcon=buttonDeleteTable.gif&onBeforeUnload=window.frames['contentFrame'].refreshPreferencePage()";
String encodedListPageUrl = MCADUrlUtil.hexEncode(listPageUrl);

String error = "";
if(resultOfPrevOperation != null && resultOfPrevOperation.startsWith("false"))
{
	error = resultOfPrevOperation.substring(6);
}
%>

<script language="JavaScript" src="./scripts/IEFUIModal.js" type="text/javascript"></script>
<script>
<%@include file = "IEFTreeTableInclude.inc"%>
     //XSSOK
	if("" != "<%=error%>")
	{
		alert("<%=XSSUtil.encodeForJavaScript(context,error)%>");		
	}	

	function createMethod()
	{	
		var heading		   = "mcadIntegration.Server.Heading.CreateWorkSpaceTable";
		var helpMarker     = "emxhelpdsccreatewksptable";
		var configUIDialog = "IEFConfigUIDialogFS.jsp?pageHeading=" + heading +"&contentPage=IEFCreateWSTableContent.jsp&mode=add&firstIntegName=<%=XSSUtil.encodeForJavaScript(context,firstIntegName)  %>&helpMarker=" + helpMarker;
		showIEFModalDialog(configUIDialog, 465, 500, "")
	}

	function modifyMethod()
	{			
		if(document.forms['selecttable'].tableRowId != null) 
		{
			var strFeatures   = "width=430,height=480,resizable=yes";
			var selectedtable = getSelectedRadioValue(document.forms['selecttable'].tableRowId);
			
			if(selectedtable=="")
			{
                                //XSSOK
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SelectToModify")%>");
				return;
			}

			if(selectedtable!="")
			{		
				var heading		   = "mcadIntegration.Server.Heading.ModifyWorkSpaceTable";
				var helpMarker     = "emxhelpdsccreatewksptable";
				var configUIDialog = "IEFConfigUIDialogFS.jsp?pageHeading="+ heading + "&contentPage=IEFCreateWSTableContent.jsp&mode=modify&firstIntegName=<%= XSSUtil.encodeForJavaScript(context,firstIntegName)  %>&helpMarker=" + helpMarker+ "&selectedItemName=" + hexEncode('<%= XSSUtil.encodeForJavaScript(context,firstIntegName)  %>', selectedtable) ;
				
				showIEFModalDialog(configUIDialog, 465, 500, "")
			}
		}
		else
		{
                        //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.NoTablesFoundToModify")%>");
		}
	}
	
	function deleteMethod()
	{		
		if(document.forms['selecttable'].tableRowId != null) 
		{
			var tableName = getSelectedRadioValue(document.forms['selecttable'].tableRowId);
			if(tableName=="")
			{
                                //XSSOK
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SelectToDelete")%>");
				return;
			}
                        //XSSOK
			var workspaceTableUpdate  = "IEFWorkspaceTableUpdate.jsp?tableName=" + hexEncode("<%= firstIntegName %>", tableName) +"&mode=delete&encodedListPageUrl=<%=encodedListPageUrl%>";

			  	if(emxUIConstants.isCSRFEnabled){
					var csrfKey = emxUIConstants.CSRF_TOKEN_KEY;
					var csrfName = emxUIConstants.CSRF_TOKEN_NAME;

					var tokenName = document.forms['selecttable'].elements[csrfKey].value;
					var tokenValue = document.forms['selecttable'].elements[csrfName].value;
					workspaceTableUpdate= workspaceTableUpdate+"&"+csrfKey+"="+tokenName+"&"+csrfName+"="+tokenValue;
				  }
			window.parent.location.replace(workspaceTableUpdate);		
		}
        else
		{
                        //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.NoTablesFoundToDelete")%>");
		}
	}

	function refreshPreferencePage()
	{
		window.parent.opener.updatePreferenceTables();
	}

	function closeWindow()
	{		
		window.parent.close();		
	}

	function getSelectedRadio(buttonGroup)
	{
		if(buttonGroup != null)
		{
			if (buttonGroup[0])
			{ 
				for (var i=0; i<buttonGroup.length; i++) 
				{
					if (buttonGroup[i].checked) 
					{
						return i
					}
				}
			}
			else 
			{
				if (buttonGroup.checked) 
				{ 
					return 0;
				}
			}
		}
		
	   return -1;
	}
	
	function getSelectedRadioValue(buttonGroup)
	{ 
		var i = getSelectedRadio(buttonGroup);

		if (i == -1) 
		{
			return "";
		} 
		else 
		{
			if (buttonGroup[i])
			{ 
				return buttonGroup[i].value;
			} 
			else
			{ 
				return buttonGroup.value;
			}
	   }
	} 	

</script>

</head>
<body>
<form name="selecttable"method = post>

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

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
    Vector allWSTables   = configUIUtil.getWorkspaceTableNames(context);
	StringList allTables = new  StringList();

	for(int a = 0; a < allWSTables.size(); a++)
	{
		allTables.addElement((String)allWSTables.elementAt(a));
	}

	allTables.sort();	

	for(int i =0; i< allTables.size(); i++)
	{
		String tableNameElement       = (String)allTables.elementAt(i);	
		String tableNameWithPrefix    = workspacePrefix + tableNameElement;
		String evenOrOdd	          = (i%2 == 0 ? "even" : "odd");
%>
<!--XSSOK-->
<tr class="<%=evenOrOdd%>">
        <!--XSSOK-->
	<td class=node style="text-align: left">&nbsp;<input type="radio" name="tableRowId" value="<%=tableNameElement%>"> </td>
	<!--XSSOK-->
	<td class="listCell" valign="top">&nbsp;<%=tableNameWithPrefix%></td>
</tr>
<%
	}
	if(allTables.size() == 0)
	{		
		String message = integSessionData.getStringResource("mcadIntegration.Server.FieldName.NoItemsFound");
%>
                <!--XSSOK-->
		<tr><td colspan="2" style="text-align: center"><%=message%></td></tr> 
<%
	}
%>	

</table>
</form>
</body>
</html>
