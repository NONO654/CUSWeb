<%--  IEFGCOChooserContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context   context       = integSessionData.getClonedContext(session);
	String selectedIntegrationName	=Request.getParameter(request,"integrationName");
    String fieldId                  =Request.getParameter(request,"fieldId");
	String defaultGCO				=Request.getParameter(request,"gcoDefault");
	String closeWindow				=Request.getParameter(request,"closeWindow");
	
	selectedIntegrationName        =XSSUtil.decodeFromURL(selectedIntegrationName);
	fieldId                        =XSSUtil.decodeFromURL(fieldId);
	defaultGCO                     =XSSUtil.decodeFromURL(defaultGCO);

    //This page gets called form 3 places 
    //Usecase1:Prefernces. Select GCO. Usecase2:Update Assignemnt. Usecase3:Global Prefernces. 
    //1.IEFPreferencesContent.jsp(IEFPreferencesPage.java)&& 2.IEFIntegrationAssignmentSelectGCO.jsp
    //Usecase1 uses fieldId for name of textbox ,while Usecase2 uses selectedIntegrationName
    if(fieldId == null)
    	fieldId = selectedIntegrationName;
    	
	if(closeWindow == null)
	{
		closeWindow = "TRUE";
	}

	String message	= integSessionData.getStringResource("mcadIntegration.Server.Message.PleaseSelectAGCO");
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFMiscUI.css" type="text/css">

<script language="JavaScript">

	function formSubmit()
	{
		var selectedGCO = "";
		
		if(document.forms['gcoListForm'].length > 0)
		{
			var elements = document.forms['gcoListForm'].elements;
			for(var i = 0; i < elements.length; i++)
			{
				var filedElement = elements[i];
				if(filedElement.type == "radio"){
					var isSelected = filedElement.checked;
					if(isSelected == true)
					{
							selectedGCO = filedElement.value;
                        top.opener.setSelectedGCOName("<%= XSSUtil.encodeForJavaScript(context,fieldId) %>", selectedGCO);               
					}
				}
			}
			
			if(selectedGCO == "")
			{
                                //XSSOK
				alert("<%= message %>");
			}
			else
			{	
				var closeWindow = "<%= XSSUtil.encodeForJavaScript(context,closeWindow) %>"; 
				if(closeWindow == "TRUE")
				{
					top.close();
				}
			}
		}
		else
		{
			top.close();
		}
	}
	


</script>
</head>

<body>
	<center>
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<form name="gcoListForm" action="javascript:formSubmit()">
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
//System.out.println("CSRFINJECTION::IEFGCOChooserContent");
%>
			<table align="left">
			<tr><td>&nbsp;</td></tr>
<%
        
        String    gcoRevision   = MCADMxUtil.getConfigObjectRevision(context);
    String  attrIEFSourceDetails    = MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-SourceDetails");
    
    //Usecase3:Global Prefernces
	String queryResult = "";
	MCADMxUtil util		= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	String mqlCmd= new StringBuffer("MCADInteg-GlobalConfig").append("*").append(gcoRevision).append("|").toString();
	String Args[]=new String[4];
	Args[0]="MCADInteg-GlobalConfig";
    Args[1]="*";
	Args[2]=gcoRevision;
	Args[3]="|";
	queryResult = util.executeMQL(context, "temp query bus $1 $2 $3 select name dump $4",Args);
    //Usecase1:Prefernces. Select GCO. Usecase2:Update Assignemnt.
    if(selectedIntegrationName != null && !"".equals(selectedIntegrationName))
	{
		String Args1[]=new String[5];
		Args1[0]="MCADInteg-GlobalConfig";
		Args1[1]="*";
		Args1[2]=gcoRevision;
		Args1[3]="attribute["+attrIEFSourceDetails+"]==\""+selectedIntegrationName+"\"";
		Args1[4]="|";
    
    	queryResult = util.executeMQL(context, "temp query bus $1 $2 $3 where $4 select name dump $5",Args1);
	}

	StringTokenizer gcoQueryElements	= new StringTokenizer(queryResult, "\n");		
	
	if(gcoQueryElements.countTokens() == 1)
	{
		String gcoInfo			= gcoQueryElements.nextToken();
		String gcoName			= gcoInfo.substring(gcoInfo.lastIndexOf("|")+1, gcoInfo.length());
			
%>

				<tr>
					<td>&nbsp;</td>
					<!--XSSOK-->
					<td><input type="radio" name="gcoList" value="<%= gcoName %>" checked></td><td><%= gcoName %></td>
				</tr>

<%
	}
	else if(gcoQueryElements.countTokens() > 1)
	{
		while(gcoQueryElements.hasMoreTokens())
		{
			String gcoInfo			= gcoQueryElements.nextToken();
			String gcoName			= gcoInfo.substring(gcoInfo.lastIndexOf("|")+1, gcoInfo.length());
			String isChecked		= "";
			
			if(gcoName.equals(defaultGCO))
				isChecked = "checked";
%>
				
				<tr>
					<td width="50">&nbsp;</td>
					<td width="50"><input type="radio" name="gcoList" value="<xss:encodeForHTMLAttribute><%= gcoName %></xss:encodeForHTMLAttribute>" <xss:encodeForHTML><%= isChecked %></xss:encodeForHTML>></td>
					<td><xss:encodeForHTMLAttribute><%= gcoName %></xss:encodeForHTMLAttribute></td>
				</tr>
				
<%
		}
	}
%>

			</table>
			</form>
		</table>
	</center>
</body>
</html>

