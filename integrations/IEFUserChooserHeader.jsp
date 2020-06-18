<%--  IEFUserChooserHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String language								= request.getHeader("Accept-Language");

	//Labels
	String selectUser			= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.SelectUser");
	String name					= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Name");
	String topLevel				= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.TopLevel");
	String person				= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Person");
	String role					= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Role");
	String filter				= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.Filter");
	String helpMarker			= "emxhelpdscassignint2";
	String strHelp				= UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.Help", "emxFrameworkStringResource", language);

	String filterInput			= null;
	String chkbxTopLevel		= null;
	String chkbxPerson			= null;
	String chkbxRole			= null;
	String fromSelectGCOPage	= emxGetParameter(request, "fromSelectGCOPage");

	if((fromSelectGCOPage != null && !"".equals(fromSelectGCOPage)) && "true".equals(fromSelectGCOPage))
	{
		filterInput		= (String)session.getAttribute("txtFilter");
		chkbxTopLevel	= (String)session.getAttribute("chkbxTopLevel");
		chkbxPerson		= (String)session.getAttribute("chkbxPerson");
		chkbxRole		= (String)session.getAttribute("chkbxRole");
		//filterInput,chkbxTopLevel,chkbxPerson,chkbxRole these values no need to remove here.These are required in
		//IEFUserChooserContent.jsp. There we are removing after using these values.
	}
%>

<html>
<head>
        <!--XSSOK-->
	<title><%=selectUser%></title>
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>

<body>
<script language="javascript" src="./scripts/IEFHelpInclude.js">
</script>
	<form name="peopleSearchOptions">
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
            <td class="pageHeader"><%=selectUser%></td>
	    <!--XSSOK-->
            <td align="right" ><a href='javascript:openIEFHelp("<%=helpMarker%>")'><img src="images/buttonContextHelp.gif" width="16" height="16" border="0" title="<%=strHelp%>"></a></td>
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
			<td align="left"><input type="checkbox" name="chkbxTopLevel" value="checked" checked onClick="javascript:if(this.value == 'unchecked'){this.value='checked';}else{this.value='unchecked';}">&nbsp;<%=topLevel%>
			<!--XSSOK-->
			<td align="left"><input type="checkbox" name="chkbxPerson" value="unchecked" onClick="javascript:if(this.value == 'unchecked'){this.value='checked';}else{this.value='unchecked';}"><img border="0" src="images/iconPerson.gif">&nbsp;<%=person%>
			<!--XSSOK-->
			<td align="left"><input type="checkbox" name="chkbxRole" value="unchecked" onClick="javascript:if(this.value == 'unchecked'){this.value='checked';}else{this.value='unchecked';}"><img border="0" src="images/iconRole.gif">&nbsp;<%=role%>
		</tr>
		<tr><td style="height: 4px;"></td><tr>
		<tr>
		<% //Fix for IR-380792-3DEXPERIENCER2015x Starts %>
	           	<!--XSSOK-->
			<td colspan="4" align="left"><%=name%> &nbsp;<input size="20" type="text" name="txtFilter" value="*"/></td>
			<!--XSSOK-->
			<td align="left">&nbsp;<input type="button" style="width: 50;" value="<%=filter%>" title="<%=filter%>" onClick="javascript:parent.searchForUsers(txtFilter, chkbxTopLevel, chkbxPerson, chkbxRole)">
		<% //Fix for IR-380792-3DEXPERIENCER2015x Ends %>
        </tr>
    </table>
	</form>

	<script language="javascript">

<%
	if((fromSelectGCOPage != null && !"".equals(fromSelectGCOPage)) && "true".equals(fromSelectGCOPage))
	{
%>
		document.forms['peopleSearchOptions'].chkbxTopLevel.checked	= <xss:encodeForHTMLAttribute><%="checked".equals(chkbxTopLevel)%></xss:encodeForHTMLAttribute>;
		document.forms['peopleSearchOptions'].chkbxPerson.checked	= <xss:encodeForHTMLAttribute><%="checked".equals(chkbxPerson)%></xss:encodeForHTMLAttribute>;
		document.forms['peopleSearchOptions'].chkbxRole.checked		= <xss:encodeForHTMLAttribute><%="checked".equals(chkbxRole)%></xss:encodeForHTMLAttribute>;

		document.forms['peopleSearchOptions'].chkbxTopLevel.value	= '<xss:encodeForHTMLAttribute><%=chkbxTopLevel%></xss:encodeForHTMLAttribute>';
		document.forms['peopleSearchOptions'].chkbxPerson.value		= '<xss:encodeForHTMLAttribute><%=chkbxPerson%></xss:encodeForHTMLAttribute>';
		document.forms['peopleSearchOptions'].chkbxRole.value		= '<xss:encodeForHTMLAttribute><%=chkbxRole%></xss:encodeForHTMLAttribute>';
		document.forms['peopleSearchOptions'].txtFilter.value		= '<xss:encodeForHTMLAttribute><%=filterInput%></xss:encodeForHTMLAttribute>';
<%
	}
%>
	</script>
</body>
</html>
