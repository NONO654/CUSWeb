<%--  MCADFinalizationFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

    String integrationName				= Request.getParameter(request,"integrationName");
    String showMessageOnFooter			        = Request.getParameter(request,"showMessageOnFooter"); 
	MCADLocalConfigObject localConfig	= integSessionData.getLocalConfigObject();
	boolean selectAllChildren			= localConfig.isSelectAllChildrenFlagOn(integrationName);
%>

<html>
<head>
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>
<body>

<table width="100%" border="0" cellspacing="3" cellpadding="3">
 
    <form name='configOptions'>
		<td nowrap align='left'>
		<!--XSSOK-->
            <input type='checkBox' name='selectAllChildren' <%= selectAllChildren?"checked":"" %> ><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Finalization.SelectAllChildren")%>
        </td>
	</form>
	
	<td nowrap align="left">
		<div id="msgOnFooter" style="visibility: hidden">
		<p align=left>
				<img src="../integrations/images/iconStatusAlert.gif" border="0" />
				<!--XSSOK-->
				<font size="3" color="red"><b><%=integSessionData.getStringResource("mcadIntegration.Server.Message.AtLeastOneDrawingOutOfSync")%></b></font>
		</p>
		</div>
	</td>
	<td nowrap align="right">
		<table border="0">
			<td nowrap>
			        <!--XSSOK-->
				<a href="javascript:parent.finalizationSelected()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Submit")%>">
				</a>&nbsp;
			</td>
			<td nowrap>
			        <!--XSSOK-->
				<a href="javascript:parent.finalizationSelected()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Submit")%>
				</a>
			</td>
			<td nowrap>&nbsp;</td>
			<td nowrap>
		         	<!--XSSOK-->
				<a href="javascript:parent.finalizationCancelled()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>">
				</a>&nbsp;
			</td>
			<td nowrap>
		          	<!--XSSOK-->
				<a href="javascript:parent.finalizationCancelled()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Close")%>
				</a>
			</td>
		</table>
	</td>
  
</table>
<script language="JavaScript">
		var optionArr = new Array();
		var integrationFrame	= getIntegrationFrame(this);
		optionArr = integrationFrame.getFooterOptions();
		if (optionArr != null && optionArr != "")
		{
			if(optionArr[0] == "true")
			{		
				document.forms["configOptions"].selectAllChildren.checked = true;
			}else
			{
				document.forms["configOptions"].selectAllChildren.checked = false;
			}
		}	

		setShowMessageOnFooter("<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),showMessageOnFooter)%>");
				
	function setShowMessageOnFooter(showMsgOnFooter)
	{
		if(showMsgOnFooter == "true")
		{
			document.getElementById("msgOnFooter").style.visibility = "visible";
		}
		else
		{
			document.getElementById("msgOnFooter").style.visibility = "hidden";
		}
	}
	</script>
	
	<script language="JavaScript">
		var option  = new Array();
		option[0]=document.forms["configOptions"].selectAllChildren.checked;
		var integrationFrame	= getIntegrationFrame(this);
		integrationFrame.setFooterOptions(option);

	</script>
</body>
</html>
