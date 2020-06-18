<%--  IEFAttributeChooserHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	
	String selectattribute	= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.SelectAttribute");
	String name			    = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Name");
	String basic		    = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Basic");
	String attribute	    = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Attribute");
	String filter		    = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.Filter");
%>

<html>
<head>
        <!--XSSOK-->
	<title><%=selectattribute%></title>
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>

<body>
	<form name="attributeSearchOptions">
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td><img src="images/utilSpace.gif" width="1" height="1"></td>
        </tr>
        <tr>
            <td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td>
        </tr>
        </table>
        <table border="0" width="100%" cellpadding="0">
        <tr>
            <!--XSSOK-->
            <td class="pageHeader"><%=attribute%></td>
        </tr>
        </table>
        <table border="0" cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td>
        </tr>
        </table>
        <table border="0" cellspacing="0" cellpadding="0" width="100%">
        <tr>&nbsp;</tr>
		<tr>
                        <!--XSSOK-->
			<td align="left"><input type="checkbox" name="chkbxBasic" value="checked" checked onClick="javascript:if(this.value == 'unchecked'){this.value='checked';}else{this.value='unchecked';}">&nbsp;<%=basic%>
			<!--XSSOK-->
			<td align="left"><input type="checkbox" name="chkbxAttribute" value="unchecked" onClick="javascript:if(this.value == 'unchecked'){this.value='checked';}else{this.value='unchecked';}">&nbsp;<%=attribute%>
			
		</tr>
		<tr><td style="height: 4px;"></td><tr>
		<tr>
                        <!--XSSOK-->
			<td colspan="4" align="left"><%=name%> &nbsp;<input size="40" type="text" name="txtFilter" value="*"/></td>
                        <!--XSSOK-->
			<td align="right">&nbsp;<input type="button" style="width: 50;" value="<%=filter%>" alt="<%=filter%>" onClick="javascript:parent.searchForAttributes(txtFilter, chkbxBasic, chkbxAttribute)">
        </tr>
    </table>
	</form>
</body>
</html>
