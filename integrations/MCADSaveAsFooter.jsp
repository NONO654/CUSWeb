<%--  MCADSaveAsFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@page import = "com.matrixone.apps.domain.util.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Set" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context								= integSessionData.getClonedContext(session);
%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%

	String integrationName						= Request.getParameter(request,"integrationName");
	String cadModelSeries						= Request.getParameter(request,"cadmodel");
	String cadDrawSeries						= Request.getParameter(request,"caddraw");

	if(cadModelSeries != null && cadDrawSeries != null)
	{
		cadModelSeries	= MCADUrlUtil.hexDecode(cadModelSeries);
		cadDrawSeries	= MCADUrlUtil.hexDecode(cadDrawSeries);
	}

	MCADLocalConfigObject localConfigObject		= integSessionData.getLocalConfigObject();

	MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);

	String selectAllChildrenAttrName		= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-SelectChildItems");

	boolean selectAllChildren			= false;

	String isSelectAllChildrenDisabled			= "";
	String selectAllChildrenHiddenContent			= "";

	String selectAllChildrenPrefType	= globalConfigObject.getPreferenceType(selectAllChildrenAttrName);
	if(selectAllChildrenPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isSelectAllChildrenDisabled = "disabled";
		selectAllChildren = globalConfigObject.getPreferenceValue(selectAllChildrenAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else if(selectAllChildrenPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		selectAllChildrenHiddenContent	= "style=\"visibility: hidden;\"" ;
		selectAllChildren = globalConfigObject.getPreferenceValue(selectAllChildrenAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else
	{
		selectAllChildren = localConfigObject.isSelectAllChildrenFlagOn(integrationName);
	}
	
	MCADMxUtil util				= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
        
        String regularExpression                   = "";
	String replaceString                       = "";
	String autoSeriesCADModel		   = "";
	String autoSeriesCADDrawing	           = "";

	String cadModelName			= util.getSymbolicName(context, "type", "CAD Model");
	String cadDrawingName		= util.getSymbolicName(context, "type", "CAD Drawing");
	String objectGeneratorType	= util.getActualNameForAEFData(context,"type_eServiceObjectGenerator");

	Vector typesList = new Vector(5);
	typesList.addElement(cadModelName);
	typesList.addElement(cadDrawingName);

	String[] packedTypesList = JPO.packArgs(typesList);

	String[] args	= new String[4];	
	args[0]			= packedTypesList[0];
	args[1]			= packedTypesList[1];
	args[2]			= objectGeneratorType;

	String language = integSessionData.getResourceBundle().getLanguageName();
	args[3]				= language;

	Hashtable autoNameSeriesTable = (Hashtable)util.executeJPO(context, "IEFGetAutoNameSeries", "getTypeNameAutoNameSeriesTable", args, Hashtable.class);

	Hashtable autoSeriesListForCADModel	= (Hashtable)autoNameSeriesTable.get(cadModelName);
	Hashtable autoSeriesListForCADDrawing	= (Hashtable)autoNameSeriesTable.get(cadDrawingName);
%>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<html>
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
<head>

<script language="JavaScript">
function saveAsNamingHelp()
{
    var saveAsHelp = "<HTML><head><title>SaveAs Naming</title></head><body><h3>Regular Expressions: <font color=\"#0000FF\"> How to use?</font></h3><p>For user convenience some use cases have been discussed to show how to use regular expressions for<i> SaveAs Naming</i>.In order to give new names to assembly and components of assembly using regular expressions, user needs to select rows to which this should be applied before hand.<h4>Use case1: Replacing existing name or part of the existing name with some string</h4><i>Original Name:</i> BottomPlate<br><br><font color=\"#0000FF\">Regular Expression:</font> Bottom<br><font color=\"#0000FF\">Replace String:</font> Top<br><br><i>SaveAs Naming result:</i> TopPlate<h4>Use case2: Suffix existing name with some string</h4><i>Original Name:</i> BottomPlate<br><br><font color=\"#0000FF\">Regular Expression:</font>($)<br><font color=\"#0000FF\">Replace String:</font> New<br><br><i>SaveAs Naming result:</i> BottomPlateNew<h4>User case3: Prefix existing name with some string</h4><i>Original Name:</i> BottomPlate<br><br><font color=\"#0000FF\">Regular Expression: </font>(^)<br><font color=\"#0000FF\">Replace String:</font> New<br><br><i>SaveAs Naming result:</i> NewBottomPlate<br><br>For further details <a href=\"http://docs.oracle.com/javase/tutorial/essential/regex/\" target=\"_new\">detailed help</a></body></HTML>";
    var helpWindow = window.open("", "SaveAsNaming", "height=300,width=400,left=0,top=0,toolbar=0,status=0,menubar=0,scrollbars=1,resizable=1");
    
    helpWindow.document.open("text/html");
    helpWindow.document.write(saveAsHelp);
    helpWindow.document.close();
}

</script>
</head>
<body>
<!--  //L86-->
<% if(integrationName  != null && integrationName.equalsIgnoreCase("solidworks"))     
{ %>
<table width="100%" cellspacing="7" cellpadding="7" align="center">
<tr>
<td align="Center" style="color:red">
<%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.EnterFileNamewithoutextensionorInstanceName")%>
</td>
</tr>
</table>
<% } %>
<table align="left" width="20%" cellspacing="3" cellpadding="3">
    <tr>
        <td nowrap class="heading"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.SaveAsNamingByRegExpression")%></b>&nbsp;&nbsp;&nbsp;<a href="javascript:saveAsNamingHelp()"><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.Help")%></a></td>
    </tr>
    <form name="PatternMatching" method="post">

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


        <tr>
		    <!--XSSOK-->
            <td nowrap><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.RegularExpression")%></td>
            <td nowrap align="right"><input type="text" name="RegularExpression"></td>
        </tr>
        <tr>
		    <!--XSSOK-->
            <td nowrap><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.ReplaceString")%> </td><td nowrap align="right"><input type="text" name="ReplaceString"></td>
        </tr>
        <tr>
			<td nowrap colspan="2" align="right">
				<table>
					<tr>
						<td nowrap align="right"><img src=images/utilSpace.gif width=24 height=16 >&nbsp;</td>
						<!--XSSOK-->
						<td nowrap align="right"><input type="button" name="Apply" value="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Apply")%> " onClick="javascript:parent.processNames()"></td>
					</tr>
				</table>
			</td>
        </tr>
    </form>
</table>


<% 
if(integrationName  != null && !integrationName.equalsIgnoreCase("solidworks"))     
{ %>
<table align="left" width="20%" cellspacing="3" cellpadding="3">
    <tr>
		<td>&nbsp;&nbsp;</td>
		<!--XSSOK-->
        <td nowrap class="heading"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.AutoNaming")%></b></td>
    </tr>
    <form name="AutoNaming" method="post">

<%
boolean csrfEnabled1 = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled1)
{
  Map csrfTokenMap1 = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName1 = (String)csrfTokenMap1 .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue1 = (String)csrfTokenMap1.get(csrfTokenName1);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName1%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName1%>" value="<%=csrfTokenValue1%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>


        <tr>
			<td>&nbsp;&nbsp;</td>
			<!--XSSOK-->
            <td nowrap><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.CADModelAutonameSeries")%></td>
            <td nowrap align="right">
				<select name="AutoSeriesCADModel">
<%
	Set actualValuesForCADModel = autoSeriesListForCADModel.keySet();
	ArrayList actualValuesForCADModelList = new ArrayList(actualValuesForCADModel);
	Collections.sort(actualValuesForCADModelList);
	String isSelectedCADModel = "";
	for(int i=0;i<actualValuesForCADModelList.size();i++)
	{
		isSelectedCADModel = "";
		String autoSeriesNameActualVal = (String)actualValuesForCADModelList.get(i);
		String autoSeriesNameToDisplay = (String)autoSeriesListForCADModel.get(autoSeriesNameActualVal); 
		if(autoSeriesNameActualVal.equalsIgnoreCase(cadModelSeries))
		{
				isSelectedCADModel = "selected";
		}
%>
                    <!--XSSOK-->
			<option value="<%=autoSeriesNameActualVal%>"  <%=isSelectedCADModel%> ><%=autoSeriesNameToDisplay%></option>

<%
	}
%>
				</select>
			</td>
        </tr>
		<tr>
			<td>&nbsp;&nbsp;</td>
			<!--XSSOK-->
            <td nowrap><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.CADDrawingAutonameSeries")%></td>
            <td nowrap align="right">
				<select name="AutoSeriesCADDrawing">
<%
	Set actualValuesForCADDrw = autoSeriesListForCADDrawing.keySet();
	ArrayList actualValuesForCADDrwList = new ArrayList(actualValuesForCADDrw);
	Collections.sort(actualValuesForCADDrwList);
	String isSelectedCADDrw = "";
	for(int i=0;i<actualValuesForCADDrwList.size();i++)
	{
		String autoSeriesNameActualVal = (String)actualValuesForCADDrwList.get(i);
		String autoSeriesNameToDisplay = (String) autoSeriesListForCADDrawing.get(autoSeriesNameActualVal);
		if(autoSeriesNameActualVal.equalsIgnoreCase(cadDrawSeries))
		{
				isSelectedCADDrw = "selected";
		}
		
%>
                    <!--XSSOK-->
					<option value="<%= autoSeriesNameActualVal %>" <%=isSelectedCADDrw%>><%= autoSeriesNameToDisplay %></option>

<%
		isSelectedCADDrw = "";
	}
%>
				</select>
			</td>
        </tr>
        <tr>
			<td>&nbsp;&nbsp;</td>
			<td nowrap colspan="2" align="right">
				<table>
					<tr>
						<td nowrap align="right"><img src=images/utilSpace.gif width=24 height=16 >&nbsp;</td>
						<!--XSSOK-->
						<td nowrap align="right"><input type="button" name="Apply" value="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Apply")%> " onClick="javascript:parent.populateAutoNames()"></td>
					</tr>
				</table>
			</td>
        </tr>
    </form>
</table>
<% 
	}
%>
<table border='0' width='10%' height='35%' align="right" cellspacing="3" cellpadding="3">
    <tr>
		<form name='configOptions' method="post">

<%
boolean csrfEnabled2 = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled2)
{
  Map csrfTokenMap2 = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName2 = (String)csrfTokenMap2 .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue2 = (String)csrfTokenMap2.get(csrfTokenName2);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName2%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName2%>" value="<%=csrfTokenValue2%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

        <!--XSSOK-->
		<td  nowrap align='right' <%= selectAllChildrenHiddenContent %> ><input type='checkBox' name='selectAllChildren' <%= selectAllChildren?"checked":"" %> <%= isSelectAllChildrenDisabled %>  ><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.SelectAllChildren")%></td>
		</form>
	</tr>
</table>
	
<BR><BR><BR><BR>

<table border="0" width="38%" align="right" cellspacing="3" cellpadding="3">
    <tr>
        <td nowrap align="right">
            <table border="0">
                <tr>				
                    <!--XSSOK-->				
					<td><a href="javascript:parent.globalFolderAssign()"><img src="../common/images/iconSmallFolder.png" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.AssignFolder")%>"></a></td> 
					<td nowrap>
					<!--XSSOK-->
					<a href="javascript:parent.globalFolderAssign()"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.AssignFolder")%></a></td>
                    <td nowrap>&nbsp;</td>
					<!--XSSOK-->
					<td nowrap><a href="javascript:parent.saveAsSelected()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.SaveAs")%>"></a>&nbsp;</td>
                    <!--XSSOK-->
                    <td nowrap><a href="javascript:parent.saveAsSelected()"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.SaveAs")%></a></td>
                    <td nowrap>&nbsp;</td>
					<td nowrap>
					<!--XSSOK-->
					<a href="javascript:parent.saveAsCancelled()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a>&nbsp;</td>
                    <!--XSSOK-->
                    <td nowrap><a href="javascript:parent.saveAsCancelled()"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.Cancel")%></a></td>
                </tr>
            </table>
        </td>
    </tr>
</table>

	<form name="UpdatePage" action="MCADUpdateWithMessage.jsp" target="_top" method="post">

<%
boolean csrfEnabled3 = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled3)
{
  Map csrfTokenMap3 = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName3 = (String)csrfTokenMap3 .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue3 = (String)csrfTokenMap3.get(csrfTokenName3);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName3%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName3%>" value="<%=csrfTokenValue3%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>


		<input type="hidden" name="busId" value="">
		<input type="hidden" name="instanceName" value="">
		<input type="hidden" name="refresh" value="true">
		<input type="hidden" name="instanceRefresh" value="true">
		<input type="hidden" name="details" value="">
		<input type="hidden" name="refreshmode" value="replace">
	</form>
<script language="JavaScript">

		var optionArr = new Array();
		var integrationFrame	= getIntegrationFrame(this);
		optionArr = integrationFrame.getFooterOptions();
		if (optionArr != null && optionArr != "")
		{
				if(optionArr[0] != "")
				{
					document.forms["PatternMatching"].RegularExpression.value =  optionArr[0];
				}else 
					document.forms["PatternMatching"].RegularExpression.value = "";

				
				if(optionArr[1] != "")
				{
					document.forms["PatternMatching"].ReplaceString.value =  optionArr[1];
				}else 
					document.forms["PatternMatching"].ReplaceString.value = "";

				
				if(optionArr[2] != "")
				{		
					for (var i=0 ; i<document.forms["AutoNaming"].AutoSeriesCADModel.options.length; i++ ){
						var temp = document.forms["AutoNaming"].AutoSeriesCADModel.options[i].value;
						if(temp == optionArr[2])
						{
							document.forms["AutoNaming"].AutoSeriesCADModel.options[i].selected = true;						
						}
					
					}
				}
				
				if(optionArr[3] != "")
				{		
					for (var i=0 ; i<document.forms["AutoNaming"].AutoSeriesCADDrawing.options.length; i++ ){
						var temp = document.forms["AutoNaming"].AutoSeriesCADDrawing.options[i].value;
						if(temp == optionArr[3])
						{
							document.forms["AutoNaming"].AutoSeriesCADDrawing.options[i].selected = true;						
						}
					
					}

				}

				if(optionArr[4] == "true")
				{		
					document.forms["configOptions"].selectAllChildren.checked = true;

				}else
				{
					document.forms["configOptions"].selectAllChildren.checked = false;
				}
	
		}
	
	</script>
	
	
	<script language="JavaScript">
		var option  = new Array();
		option[0]=document.forms["PatternMatching"].RegularExpression.value;
		option[1]=document.forms["PatternMatching"].ReplaceString.checked;
		option[2]=document.forms["AutoNaming"].AutoSeriesCADModel.value;
		option[3]=document.forms["AutoNaming"].AutoSeriesCADDrawing.value;
		option[4]=document.forms["configOptions"].selectAllChildren.checked;

		var integrationFrame	= getIntegrationFrame(this);
		integrationFrame.setFooterOptions(option);

	</script>
</body>
</html>

