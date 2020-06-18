<% response.setContentType("text/xml");
   response.setContentType("charset=UTF-8");
   response.setHeader("Content-Type", "text/xml");
   response.setHeader("Cache-Control", "no-cache");
   response.getWriter().write("<?xml version='1.0' encoding='iso-8859-1'?>");
%>
<%--
//@fullReview  ZUR 12/04/30 : Creation, Split from emxPLMOnlineAdminXPExchangeParamsAjax - IR-164539V6R2013x 
--%>
<%@ page import="com.dassault_systemes.vplmposadminservices.HtmlCatalogHandler" %>
<%@ page import ="com.matrixone.vplm.ParameterizationImportExport.ParameterizationImportExport"%>

<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
		
<%
String finalNameString="<root>";

ParameterizationImportExport PIE = 	new ParameterizationImportExport(context);	

int retDeploy = PIE.deploy();
		
String StrRetDeploy="S_OK";
		
if (retDeploy != PIE.S_OK)
	StrRetDeploy="S_ERROR";		
		
finalNameString=finalNameString+"<DeployResult>"+StrRetDeploy+"</DeployResult>";
	
finalNameString = finalNameString+"</root>";

response.getWriter().write(finalNameString);

%>
