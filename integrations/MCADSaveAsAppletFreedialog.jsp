<%--  MCADSaveAsAppletFreedialog.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>

<%@page import = "com.matrixone.apps.domain.util.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Set" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context								= integSessionData.getClonedContext(session);
	String integrationName				= Request.getParameter(request,"integrationName");
	String objectId						= Request.getParameter(request,"objectId");
	String objectIds					= Request.getParameter(request,"objectIds");
	String refresh						= Request.getParameter(request,"refresh");
	String multiSelectdisabled			= "";
 String sRefreshFrame		=Request.getParameter(request,"refreshFrame");

	if(objectIds != null) 
	{
		if(objectIds.contains(";"))
		{
				multiSelectdisabled = "unchecked disabled";
		}
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

	String isdefaultFolderDisabled			= "";
	String defaultFolderHiddenHTMLContent	= "";
	String folderTNR							= "";
	String folderPath							= "";
	String defaultFolderAttrName			= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-Pref-IEF-DefaultFolder");
	String defaultFolderPrefType			= globalConfigObject.getPreferenceType(defaultFolderAttrName);
	MCADFolderUtil folderUtil				  = new MCADFolderUtil(context, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		String folderId								=Request.getParameter(request,"workspaceFolderId");    
	if(defaultFolderPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE))
	{
		isdefaultFolderDisabled = "disabled";
		folderTNR = globalConfigObject.getPreferenceValue(defaultFolderAttrName);
	}
	else if(defaultFolderPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		defaultFolderHiddenHTMLContent = "style=\"visibility: hidden\"";
		folderTNR = globalConfigObject.getPreferenceValue(defaultFolderAttrName);
	}
	else
	{                
		folderTNR = localConfigObject.getDefaultFolderValue(integrationName);
	}
	if(folderTNR != null && !"".equals(folderTNR))
	{
		Enumeration tnr = MCADUtil.getTokensFromString(folderTNR, ",");

		String type  = (String)tnr.nextElement();
		String name  = (String)tnr.nextElement();
		String rev    = (String)tnr.nextElement();				

		BusinessObject busObj	= new BusinessObject(type,name,rev,"");
		busObj.open(context);
		folderId      			= busObj.getObjectId();
		busObj.close(context);
		folderPath = folderUtil.getWorkspaceFolderPath(context, folderId);
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
<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
<html>

<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">

<head>

<script language="JavaScript">

function silentSaveAs()
{
	var regularExpr = document.forms['PatternMatching'].RegularExpression.value;	
	var stdPart = "";//document.forms['PatternMatching'].StandardPart.value;	
	var replaceString = document.forms['PatternMatching'].ReplaceString.value;
	var folderId = document.forms['PatternMatching'].folderId.value;
	var cadDrawSeries = document.forms['PatternMatching'].AutoSeriesCADDrawing.value;
	var cadModelSeries = document.forms['PatternMatching'].AutoSeriesCADModel.value;

	if(document.forms['PatternMatching'].autoName.checked)
	{
		if((document.forms['PatternMatching'].AutoSeriesCADModel.selectedIndex  == "0") || (document.forms['PatternMatching'].AutoSeriesCADDrawing.selectedIndex  == "0")) {
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.PickAutoNameSeries")%>");
			return;
		}
	}
	else
	{
		if(regularExpr == null || regularExpr.trim().length === 0) {
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Select") + " " + integSessionData.getStringResource("mcadIntegration.Server.FieldName.RegularExpression")%>");
			return;
		}

		if(replaceString == null || replaceString.trim().length === 0) {
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Select") +" " + integSessionData.getStringResource("mcadIntegration.Server.FieldName.ReplaceString")%>");
			return;
	    }
	}

	var saveAsDetails = "integrationName="+'<%=integrationName%>' + "&objectId=" + '<%=objectId%>' + "&regEx="+ regularExpr+"&replaceStr="+ encodeURIComponent(replaceString)+"&stdPart="+stdPart+"&folderId="+folderId+"&caddrawseries="+cadDrawSeries+"&cadmodelseries="+cadModelSeries+ "&objectIds=" + '<%=objectIds%>'+"&refreshFrame="+'<%=sRefreshFrame%>';
	
		var url = "../integrations/MCADSaveAsAppletFreePost.jsp";
		url += "?" + saveAsDetails;
		var http = emxUICore.createHttpRequest();
		url = encodeURI(url);
		http.onreadystatechange=function()
		 {
			if (http.readyState < 4)
			 {
				document.forms['PatternMatching'].progress.src = "../common/images/utilProgressGraySmall.gif";
			}
			if (http.readyState == 4) 
			{   
				var response = http.responseText;
				var res=JSON.parse(response);
				alert(res.message);
				document.forms['PatternMatching'].progress.src = "./images/utilSpace.gif";
				if(res.result =="SUCCESS")
				{
				refreshParentFrame(res.busId,res.result);
				}
				else
				{
				refreshParentFrame("",res.result);
				}
				parent.window.close();
			}
		}
		http.open("GET", url, true);
		http.send();
		
}
function doGlobalSelect(objectId, objectName, applyToChild)
{
	var s = '';
    for (var i = 0; i < objectName.length; i+=2) {
        s += String.fromCharCode(parseInt(objectName.substr(i, 2), 16));
    }
    
    document.PatternMatching.WorkspaceFolder.value =  decodeURIComponent(escape(s));
    document.PatternMatching.folderId.value = objectId;
}

function saveAsPageAutoName(iefIntegrationName, saveAsDetails)
{
	var integrationFrame = getIntegrationFrame(this);
	integrationFrame.setBrowserCommandOpener(this);
	integrationFrame.getAppletObject().callCommandHandler(iefIntegrationName, "createSaveAsPageAfterAutoName", saveAsDetails);
}

function autoNameSelected(isConfirmed)
{
	var regularExpr = document.forms['PatternMatching'].RegularExpression.value;
	var stdPart = "";//document.forms['PatternMatching'].StandardPart.value;
	var replaceString = document.forms['PatternMatching'].ReplaceString.value;

	var folderId = document.forms['PatternMatching'].folderId.value;
	var saveAsDetails = '<%=integrationName%>' + "|" + '<%=objectId%>' + "|" + '<%=refresh%>'+"|"+ regularExpr+"|"+ replaceString+"|"+stdPart+"|"+folderId;
	//var saveAsDetails = '<%=integrationName%>' + "|" + '<%=objectId%>' + "|" + '<%=refresh%>';
	saveAsPageAutoName('<%=integrationName%>', saveAsDetails);
	//showSaveAsPage('<%=integrationName%>', saveAsDetails);
}

function saveAsNamingHelp()
{
    var saveAsHelp = "<HTML><head><title>SaveAs Naming</title></head><body><h3>Regular Expressions: <font color=\"#0000FF\"> How to use?</font></h3><p>For user convenience some use cases have been discussed to show how to use regular expressions for<i> SaveAs Naming</i>.In order to give new names to assembly and components of assembly using regular expressions, user needs to select rows to which this should be applied before hand.<h4>Use case1: Replacing existing name or part of the existing name with some string</h4><i>Original Name:</i> BottomPlate<br><br><font color=\"#0000FF\">Regular Expression:</font> Bottom<br><font color=\"#0000FF\">Replace String:</font> Top<br><br><i>SaveAs Naming result:</i> TopPlate<h4>Use case2: Suffix existing name with some string</h4><i>Original Name:</i> BottomPlate<br><br><font color=\"#0000FF\">Regular Expression:</font>($)<br><font color=\"#0000FF\">Replace String:</font> New<br><br><i>SaveAs Naming result:</i> BottomPlateNew<h4>User case3: Prefix existing name with some string</h4><i>Original Name:</i> BottomPlate<br><br><font color=\"#0000FF\">Regular Expression: </font>(^)<br><font color=\"#0000FF\">Replace String:</font> New<br><br><i>SaveAs Naming result:</i> NewBottomPlate<br><br>For further details <a href=\"http://docs.oracle.com/javase/tutorial/essential/regex/\" target=\"_new\">detailed help</a></body></HTML>";
    var helpWindow = window.open("", "SaveAsNaming", "height=300,width=400,left=0,top=0,toolbar=0,status=0,menubar=0,scrollbars=1,resizable=1");
    
    helpWindow.document.open("text/html");
    helpWindow.document.write(saveAsHelp);
    helpWindow.document.close();
}


function showFolderChooser()
{
	var url = "MCADFolderSearchDialogFS.jsp" + "?integrationName=<%=XSSUtil.encodeForJavaScript(context,integrationName)%>";	
	showIEFModalDialog(url, 430, 400, true);
}

function onSelectAutoRename(checked)
{
   if(checked != null && checked != 'undefined' && checked)
	{
		 document.forms['PatternMatching'].RegularExpression.value = "";
		 document.forms['PatternMatching'].ReplaceString.value = "";

		 document.forms['PatternMatching'].AutoSeriesCADModel.disabled = false;
		document.forms['PatternMatching'].AutoSeriesCADDrawing.disabled = false;

		 document.forms['PatternMatching'].RegularExpression.disabled = true;
		 document.forms['PatternMatching'].ReplaceString.disabled = true;

	}else
	{
		document.forms['PatternMatching'].AutoSeriesCADModel.selectedIndex  = "0";
		document.forms['PatternMatching'].AutoSeriesCADDrawing.selectedIndex  = "0";

	    document.forms['PatternMatching'].AutoSeriesCADModel.disabled = true;
	    document.forms['PatternMatching'].AutoSeriesCADDrawing.disabled = true;

		document.forms['PatternMatching'].RegularExpression.disabled = false;
		document.forms['PatternMatching'].ReplaceString.disabled = false;

		document.forms['PatternMatching'].RegularExpression.focus();
	}

}
function refreshParentFrame(response,result)
{
	var refreshFrame		= getFrameObject(parent.top.opener.top, '<%=sRefreshFrame%>');
	var integrationFrame	= getIntegrationFrame(this);
	if(integrationFrame != null)
	{
		if(refreshFrame == null)
		{
			//Set the refresh for Full Search
			refreshFrame = getFrameObject(top, "structure_browser");
		}
		
		var refreshFrameURL	= refreshFrame.location.href;
		if(result =="SUCCESS")
		{
			var objectId_New = getQueryString('objectId');
			refreshFrameURL = refreshFrameURL.replace(objectId_New , response.trim() );
		}
		
		if(refreshFrame.name == "content")
		{
			refreshFrame.location.href = refreshFrameURL;							
		}
	}	
}

function getQueryString() {
          var key = false, result = {}, item = null;
          var queryString = location.search.substring(1);
		 
          if (arguments.length > 0 && arguments[0].length > 1)
            key = arguments[0];
		
          var pattern = /([^&=]+)=([^&]*)/g;
		  
          while (item = pattern.exec(queryString)) {
            if (key !== false && decodeURIComponent(item[1]) === key)
              return decodeURIComponent(item[2]);
            else if (key === false)
              result[decodeURIComponent(item[1])] = decodeURIComponent(item[2]);
          }

          return key === false ? result : null;
}
</script>
</head>
<body>
<form name="PatternMatching" method="post">
<table border="0" align="left" width="20%" cellspacing="4" cellpadding="4" >
 <tr>
		    <!--XSSOK-->
            <td nowrap></td>
            <td nowrap></td>
			<td><td nowrap align="right"><img src="./images/utilSpace.gif" name="progress"></p></td></td>
   </tr>

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

		<tr><td>&nbsp;</td></tr>
        <tr>
		    <!--XSSOK-->
            <td nowrap><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.RegularExpression")%></td>
            <td class="inputField" nowrap align="right"><input type="text" name="RegularExpression"></td>
			<td><td nowrap>&nbsp;&nbsp;&nbsp;<a href="javascript:saveAsNamingHelp()">
		<%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.Help")%></a></td></td>
        </tr>

		<tr>
		<td>&nbsp;</td>
		</tr>
        <tr>
		    <!--XSSOK-->
            <td nowrap><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.ReplaceString")%> </td><td nowrap align="right"><input class="inputField" type="text" name="ReplaceString"></td>
        </tr>
		<tr>
		<td>&nbsp;</td>
		</tr>
		<tr><td colspan ="7" style="border-bottom: 1px solid #000;"> </td></tr>
		<tr><td>&nbsp;</td></tr>
  <tr>
			<td><input type="checkbox" name="autoName" id="autoName" onClick="onSelectAutoRename(document.forms['PatternMatching'].autoName.checked)"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.AutoName")%></td>
			<!--XSSOK-->
			</br>
            <td nowrap><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.CADModelAutonameSeries")%></td>
            <td nowrap align="center">
				
			</td>			
			<!--XSSOK-->
            <td nowrap><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.CADDrawingAutonameSeries")%></td>
            <td nowrap align="center">
				
			</td>
        </tr>	

		<tr>
		<td></td>
		<td><select disabled name="AutoSeriesCADModel">
				<option value="None" selected><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.NotSelected")%></option>
<%
	Set actualValuesForCADModel = autoSeriesListForCADModel.keySet();
	ArrayList actualValuesForCADModelList = new ArrayList(actualValuesForCADModel);
	Collections.sort(actualValuesForCADModelList);
	for(int i=0;i<actualValuesForCADModelList.size();i++)
	{
		String autoSeriesNameActualVal = (String)actualValuesForCADModelList.get(i);
		String autoSeriesNameToDisplay = (String)autoSeriesListForCADModel.get(autoSeriesNameActualVal); 
	
%>
                    <!--XSSOK-->
					<option value="<%= autoSeriesNameActualVal %>"><%= autoSeriesNameToDisplay %></option>
<%
	}
%>
				</select></td>
		<td></td>
		<td><select disabled name="AutoSeriesCADDrawing">
				<option value="None" selected><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.NotSelected")%></option>
<%
	Set actualValuesForCADDrw = autoSeriesListForCADDrawing.keySet();
	ArrayList actualValuesForCADDrwList = new ArrayList(actualValuesForCADDrw);
	Collections.sort(actualValuesForCADDrwList);
	for(int i=0;i<actualValuesForCADDrwList.size();i++)
	{
		String autoSeriesNameActualVal = (String)actualValuesForCADDrwList.get(i);
		String autoSeriesNameToDisplay = (String) autoSeriesListForCADDrawing.get(autoSeriesNameActualVal);
		
%>
                    <!--XSSOK-->

					<option value="<%= autoSeriesNameActualVal %>"><%= autoSeriesNameToDisplay %></option>
<%
	}
%>
				</select></td>
		</tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td colspan ="7" style="border-bottom: 1px solid #000;"> </td></tr>
	<tr><td>&nbsp;</td></tr>
		 <tr>
		    <!--XSSOK-->
			  <td><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.AssignFolder")%></td> 
		    <td nowrap><input type="text" name="WorkspaceFolder"  size = "25" readonly="readonly" id="WorkspaceFolder" value="<%=folderPath%>" ><td>
		    <td nowrap><input type="button" name="butClear" id="" value="..." onclick="javascript:showFolderChooser()">&nbsp;</td>
			<input type="hidden" name="folderId" value="<%=(folderId == null) ? "" : folderId%>">
        </tr>
		<tr><td>&nbsp;</td></tr>
       
    </form>
</table>

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

