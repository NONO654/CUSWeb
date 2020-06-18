<%--  IEFBaselineContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%

MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
Context context								= integSessionData.getContext();
String errorMessage	 = MCADUrlUtil.hexDecode(Request.getParameter(request,"errorMessage"));
String baselineName	 =Request.getParameter(request,"baselineName") == null ? "": MCADUrlUtil.hexDecode(Request.getParameter(request,"baselineName"));
String baselineDesc	 =Request.getParameter(request,"baselineDesc") ==null ?"": MCADUrlUtil.hexDecode(Request.getParameter(request,"baselineDesc"));

//Below Lateral View Names should always match with corresponding Default View Registry Name in GCO
Locale objLocale = context.getLocale();
LinkedHashMap<String,String> viewMap = new LinkedHashMap(5);
viewMap.put("As-Built", "emxIEFDesignCenter.Common.AsStored");
viewMap.put("LatestRELEASEDRevision", "emxIEFDesignCenter.Common.LatestReleasedRevision");
viewMap.put("LatestRevision", "emxIEFDesignCenter.Common.LatestRevision");
viewMap.put("LatestIN_WORKRevision", "emxIEFDesignCenter.Common.LatestIn_WorkRevision");
viewMap.put("LatestFROZENRevision", "emxIEFDesignCenter.Common.LatestDesignFrozenRevision");

String baselineDefaultView = ResourceBundle.getBundle("emxIEFDesignCenter").getString("emxDesignerCentral.CreateBaseline.DefaultView");
if(!viewMap.containsKey(baselineDefaultView)){
	Hashtable values			=  new  Hashtable(1);
	values.put("NAME",baselineDefaultView);
	String errorMsg = integSessionData.getStringResource("mcadIntegration.Server.Message.InvalidBaselineViewSet",values);
	emxNavErrorObject.addMessage(errorMsg);
}

if ((emxNavErrorObject.toString()).trim().length() == 0)
{
%>
<html>
<head>
<style type="text/css"> 
body { background-color: white; }
body, th, td, p, select, option { font-family: Verdana, Arial, Helvetica, Sans-Serif; font-size: 8pt; }
a { color: #003366; }
a:hover { }
td.pageHeader {  font-family: Arial, Helvetica, Sans-Serif; font-size: 13pt; font-weight: bold; color: #990000; } 
td.pageBorder {  background-color: #003366; } 
th { text-align: left; color: white; background-color: #336699; font-size: 10pt;}
</style>
</head>
<body>
	<form name="baseline" action="" method="post" >

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
//System.out.println("CSRFINJECTION::DSCDerivedOutput.jsp");

%>	
		<input type="hidden" name="objectIdList" value="">
		<input type="hidden" name="parentObjectId" value="">
		<input type="hidden" name="selectedProgram" value="">
		
		<table border="0" width="100%">
		        <!--XSSOK-->
				<tr><th width="100%"><%=integSessionData.getStringResource("mcadIntegration.Server.Feature.BaselineDetails")%></th></tr>
				<tr><td>&nbsp;</td></tr>					
				<tr>
						<td>
								<table border="0" width="100%">
										<tr>
										        <!--XSSOK-->
												<td align="left"><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.BaselineName")%></td>
												<!--XSSOK-->
												<td ><input type="text"  name="baselineName"  value="<%=baselineName%>" /></td>
										</tr>
										<tr><td><br/></td></tr>
										<tr>
										        <!--XSSOK-->
												<td  align="left"><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.BaselineDesc")%></td>
												<!--XSSOK-->
												<td ><input type="text"  name="baselineDesc"  value="<%=baselineDesc%>" /></td>
										</tr>
										<tr><td><br/></td></tr>
										<tr>
										        <!--XSSOK-->
												<td  align="left"><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.BaselineView")%></td>
												<!--XSSOK-->
												<td >
													<select name=baselineView>
													<option value="<%=baselineDefaultView%>"><%=EnoviaResourceBundle.getProperty(context,"emxIEFDesignCenterStringResource",objLocale,viewMap.get(baselineDefaultView))%></option>
														<%
															for(String key : viewMap.keySet()) { 
																if(key.equals(baselineDefaultView))
																	continue;
																%>
																<option value="<%=key%>"><%=EnoviaResourceBundle.getProperty(context,"emxIEFDesignCenterStringResource",objLocale,viewMap.get(key))%></option>
															<% }
														%>
												</td>
										</tr>
								</table>								
						</td>
				</tr>
		</table>
	</form>
</body>
</html>
<%
	}
	else
	{
%>
	<html>
	<body>
	<link rel="stylesheet" href="../emxUITemp.css" type="text/css">
	&nbsp;
      <table width="90%" border=0  cellspacing=0 cellpadding=3  class="formBG" align="center" >
        <tr >
		  <!--XSSOK-->
          <td class="errorHeader"><%=integSessionData.getStringResource("mcadIntegration.Server.Heading.Error")%></td>
        </tr>
        <tr>
        <td>&nbsp;</td>
        </tr>
        <tr align="center">
          <td class="errorMessage" align="center"><%=emxNavErrorObject%></td>
        </tr>
      </table>
		  </body>
		  </html>
<%
	}
	  %>

