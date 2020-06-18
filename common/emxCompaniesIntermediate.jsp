
<%-- emxCompaniesIntermediate.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCompaniesIntermediate.jsp.rca 1.5.3.2 Wed Oct 22 15:48:25 2018 przemek Experimental przemek $

--%>
               
<%@include file = "emxNavigatorInclude.inc"%>  
<%@page import  = "com.matrixone.apps.domain.util.*"%>

<html>
	<head>
		<link rel="stylesheet" type="text/css" href="styles/emxUIDefault.css" />	
	</head>
	<body>
		<%
			String loggedInRole = PersonUtil.getActiveSecurityContext(context);
			String roleVPLMAdmin = PropertyUtil.getSchemaProperty(context,"role_VPLMAdmin"); 
			String accessUsers = "role_OrganizationManager,role_VPLMProjectAdministrator";
			if(!FrameworkUtil.isOnPremise(context) && loggedInRole.startsWith(roleVPLMAdmin+".") && loggedInRole.endsWith(".Default")){
		%>
				<jsp:include page="emxIndentedTable.jsp" >
					<jsp:param name="table" value="APPCompaniesSummary"/>
					<jsp:param name="toolbar" value="APPCompanySummaryToolBar"/>
					<jsp:param name="program" value="emxCompany:getAllActiveCompanies"/>
					<jsp:param name="header" value="emxComponents.CompanySummary.Heading"/>
					<jsp:param name="HelpMarker" value="emxhelpcompanylist"/>
					<jsp:param name="selection" value="multiple"/>
					<jsp:param name="PrinterFriendly" value="true"/>
					<jsp:param name="sortColumnName" value="Name"/>
					<jsp:param name="sortDirection" value="ascending"/>
					<jsp:param name="customize" value="false"/>
					<jsp:param name="showRMB" value="false"/>
				</jsp:include>
		<%
			}else if(FrameworkUtil.isOnPremise(context) && (PersonUtil.hasAnyAssignment(context, accessUsers) || (loggedInRole.startsWith(roleVPLMAdmin+".") && loggedInRole.endsWith(".Default")))){
		%>
				<jsp:include page="emxIndentedTable.jsp">
					<jsp:param name="table" value="APPCompaniesSummary"/>
					<jsp:param name="toolbar" value="APPCompanySummaryToolBar"/>
					<jsp:param name="program" value="emxCompany:getAllActiveCompanies,emxCompany:getMyCompany,emxCompany:getActiveMyCompanyAndSubsidiaries,emxCompany:getHostCompanySuppliers,emxCompany:getHostCompanyCustomers"/>
					<jsp:param name="programLabel" value="emxComponents.Filter.AllCompanies,emxComponents.Filter.MyCompany,emxComponents.Filter.MyCompanySubsidiaries,emxComponents.Filter.Suppliers,emxComponents.Filter.Customers"/>
					<jsp:param name="header" value="emxComponents.CompanySummary.Heading"/>
					<jsp:param name="HelpMarker" value="emxhelpcompanylist"/>
					<jsp:param name="selection" value="multiple"/>
					<jsp:param name="PrinterFriendly" value="true"/>
					<jsp:param name="sortColumnName" value="Name"/>
					<jsp:param name="sortDirection" value="ascending"/>
				</jsp:include>
		<%
			}else{
		%>
		<div class="pageHead" id="pageHeadDiv">
			<table id="contentHeader">
				<tbody>
					<tr>
						<td class="page-title">
							<h2>
								<%=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CompanySummary.Heading")%>
							</h2>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<div class="message-pane">
			<p class="message-pane-title">
				<%=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Company.Access.Alert")%>
			</p>
		</div>
		<%
			}
		%>
	</body>
</html>

