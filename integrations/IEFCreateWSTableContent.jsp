<%--  IEFCreateWSTableContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<script language="JavaScript" src="./scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="./scripts/IEFUIModal.js" type="text/javascript"></script>

<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIForm.css" type="text/css">
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");	
	Context context                             = integSessionData.getClonedContext(session);
	
	String table           = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.TableName");
	String columnLabel     = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.ColumnName");
	String expressionlabel = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Expression");
	String addColumn       = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.AddColumn");
	String deleteColumn    = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.DeleteColumn");
	String modifyColumn    = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.ModifyColumn");
	String moveUp          = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.MoveUp");
	String moveDown        = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.MoveDown");
	String search          = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.Search");		
	String tableNameOrig   = "";

	String mode            =Request.getParameter(request,"mode");	
	String firstIntegName  =Request.getParameter(request,"firstIntegName");

	Hashtable mandatoryColumnsTable		= new Hashtable();
	String mandatoryColumnsListString	= integSessionData.getPropertyValue("mcadIntegration.MandatoryColumnsList");
	if(mandatoryColumnsListString!=null && !mandatoryColumnsListString.trim().equals(""))
	{
		Enumeration mandatoryColumnsListElements = MCADUtil.getTokensFromString(mandatoryColumnsListString.trim(), ",");
		while (mandatoryColumnsListElements.hasMoreElements())
		{
			String mandatoryColumnElement = (String)mandatoryColumnsListElements.nextElement();

			Enumeration mandatoryColumnDataElements = MCADUtil.getTokensFromString(mandatoryColumnElement, "|");
			if(mandatoryColumnDataElements.hasMoreElements())
			{
				String columnName		= (String)mandatoryColumnDataElements.nextElement();
				String columnExpression = (String)mandatoryColumnDataElements.nextElement();

				mandatoryColumnsTable.put(columnName, columnExpression);
			}
		}
	}
    
	if(mode.equals("modify"))		
		tableNameOrig     =  MCADUrlUtil.hexDecode(Request.getParameter(request,"selectedItemName"));

	
	
	String heading            = "mcadIntegration.Server.Heading.WorkSpaceTables";
	String listPageUrl        = "IEFConfigUIDialogFS.jsp?pageHeading=" + heading + "&contentPage=IEFWSTableListContent.jsp&firstIntegName="+firstIntegName+"&onBeforeUnload=window.frames['contentFrame'].refreshPreferencePage()&createIcon=buttonCreateTable.gif&modifyIcon=buttonModifyTable.gif&deleteIcon=buttonDeleteTable.gif";
	String encodedListPageUrl = MCADUrlUtil.hexEncode(listPageUrl);

	String noSupportedChars		= "";
	if(firstIntegName!=null && !firstIntegName.equals(""))
	{   
		
		MCADGlobalConfigObject gco  = integSessionData.getGlobalConfigObject(firstIntegName,context);
		if(gco != null)
			noSupportedChars		= gco.getNonSupportedCharacters();
	}
	
        if(noSupportedChars == null || noSupportedChars.equals(""))
        {
             noSupportedChars		= "/\\\\|<>*$?;:@,[]{}%'#\\\"&";
        } 

	noSupportedChars = noSupportedChars.replace('+', ' ');
	noSupportedChars = noSupportedChars.replace('-', ' ');
	noSupportedChars = noSupportedChars.replace('*', ' ');
	noSupportedChars = noSupportedChars.replace('/', ' ');
	noSupportedChars = noSupportedChars.replace('=', ' ');
	noSupportedChars = noSupportedChars.replace('[', ' ');
	noSupportedChars = noSupportedChars.replace(']', ' ');	

%>

<html>
<head>

<style type="text/css">

        body { background-color: #FFFFFF; } body, th, td, p { font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt; }a { color: #003366; } a:hover { } a.object { font-weight: bold; } a.object:hover { } span.object {  font-weight: bold; } a.button { } a.button:hover { } td.pageHeader {  font-family: Arial, Helvetica, Sans-Serif; font-size: 13pt; font-weight: bold; color: #990000; } td.pageBorder {  background-color: #003366; } th { text-align: left; color: white; background-color: #336699; } th.sub { text-align: left; color: white; background-color: #999999; } tr.odd { background-color: #ffffff; } tr.even { background-color: #eeeeee; } 

</style>

<script>

<%@include file = "IEFTreeTableInclude.inc"%>	
	
	function showAttributeSelector(formName, fieldName)
	{	
		var url = "IEFAttributeChooserFS.jsp?formName="+formName+"&fieldName="+fieldName;
		
		showIEFModalDialog(url,400,450, "")
	}

	function jsValidate(formName, fieldName, integrationName) 
	{
		var textToValidate   = eval("document." + formName + "." + fieldName + ".value");	
		var integrationFrame = getIntegrationFrame(this);
                //XSSOK
		var unsupportedChars = "<%=noSupportedChars%>";
	
		var isTextWithBadChars = validateForBadChars(unsupportedChars, textToValidate);

		if (!isTextWithBadChars)
		{
		   var msg = integrationFrame.getAppletObject().getStringResource("mcadIntegration.Server.Message.InputValueContainsInvalidChars");
		  alert(msg + unsupportedChars);

		  eval("document." + formName + "." + fieldName + ".focus()");

		  return false;
		}

		return true;
	}

	function doneMethod()
	{
		if (!(jsValidate('wkstableform', 'TableName', '<%= XSSUtil.encodeForJavaScript(context,firstIntegName) %>'))) 
			return;

		var dircForm = document.forms['wkstableform'];
		var mode     = dircForm.mode.value;

		if(mode == "add")
			createTable();
		else if(mode == "modify")
			modifyTable();
		if(mode == "delete")
			deleteTable();
	}

	function createTable()
	{		
		var dircForm    = document.forms['wkstableform'];
		var columnCount = dircForm.columnlist.length;		
		var tableData   = "";
		var tableName   = dircForm.TableName.value;
		
		if(tableName == "")
		{
                        //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.EnterTableName")%>");

			return;
		}
		if(columnCount=="0")
		{
                        //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.EnterColumnName")%>");

			return;
		}			
		for(i = 0; i < columnCount; i++) 
		{ 
			var temp       = dircForm.columnlist.options[i].value;
			var expression = dircForm.columnlist.options[i].value;
			var label      = dircForm.columnlist.options[i].text;

			tableData += label + "|" + expression + "@";	
		}
        //XSSOK
        var chooserURL  = "IEFWorkspaceTableUpdate.jsp?tableData=" + hexEncode('<%= firstIntegName %>', tableData) + "&tableName=" + hexEncode('<%= firstIntegName %>', tableName) + "&mode=add" + "&encodedListPageUrl=<%=encodedListPageUrl%>" ;
        
        if(emxUIConstants.isCSRFEnabled){
    		var csrfKey = emxUIConstants.CSRF_TOKEN_KEY;
    		var csrfName = emxUIConstants.CSRF_TOKEN_NAME;

    		var tokenName = document.forms['wkstableform'].elements[csrfKey].value;
    		var tokenValue = document.forms['wkstableform'].elements[csrfName].value;
    		chooserURL= chooserURL+"&"+csrfKey+"="+tokenName+"&"+csrfName+"="+tokenValue;

            }
        
		var strFeatures = "width=400,height=450,resizable=yes";
				
		window.parent.opener.parent.location.replace(chooserURL);
		window.parent.close();		
	}

	function getSelectedRadio(buttonGroup) 
	 {
	   if(buttonGroup[0]) 
		{ 
		  for(var i=0; i<buttonGroup.length; i++) 
			{
				if(buttonGroup[i].checked)
					return i
			}
		}
		else 
		{
			if(buttonGroup.checked)
				return 0;          
		}  
	   return -1;         
	}
	
	function getSelectedRadioValue(buttonGroup)  
	{
	   var i = getSelectedRadio(buttonGroup);

	   if(i == -1) 
		{
		  return "";
		} 
		else 
		{
		  if(buttonGroup[i]) 
			{ 
			 return buttonGroup[i].value;
			} 
			else 
			{
			return buttonGroup.value;
			}
	   }
	} 

	function modifyTable()
	{	
		var dircForm    = document.forms['wkstableform'];
		var columnCount = dircForm.columnlist.length;
		var tableData   = "";
		var tableName   = dircForm.TableName.value;

		if(columnCount=="0")
		{		
                 	//XSSOK		
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.EnterColumnName")%>");
			
		    return;
		}
		for(i = 0; i < columnCount; i++) 
		{ 
			var expression = dircForm.columnlist.options[i].value;		
			var label      = dircForm.columnlist.options[i].text;

			tableData += label + "|" + expression + "@";
		}
		//XSSOK
		var chooserURL  = "IEFWorkspaceTableUpdate.jsp?tableData=" + hexEncode('<%= firstIntegName %>', tableData )+ "&tableName=" + hexEncode('<%= firstIntegName %>', tableName )+"&tableNameOrig=" + hexEncode('<%= firstIntegName %>', "<%=XSSUtil.encodeForJavaScript(context,tableNameOrig)%>") +"&mode=modify"+ "&encodedListPageUrl=<%=encodedListPageUrl%>";
		var strFeatures = "width=400,height=450,resizable=yes";
		
		if(emxUIConstants.isCSRFEnabled){
    		var csrfKey = emxUIConstants.CSRF_TOKEN_KEY;
    		var csrfName = emxUIConstants.CSRF_TOKEN_NAME;

    		var tokenName = document.forms['wkstableform'].elements[csrfKey].value;
    		var tokenValue = document.forms['wkstableform'].elements[csrfName].value;
    		chooserURL= chooserURL+"&"+csrfKey+"="+tokenName+"&"+csrfName+"="+tokenValue;

            }
		
		window.parent.opener.parent.location.replace(chooserURL);
		window.parent.close();		
	}
	

	function closeWindow()
	{
		window.close();
	}

	function setColumnNameField(listbox)
	{		
		document.forms['wkstableform'].ColumnName.value       = listbox.options[listbox.selectedIndex].text;
		document.forms['wkstableform'].Attribute.value        = listbox.options[listbox.selectedIndex].value;
		document.forms['wkstableform'].ColumnNameUnique.value = listbox.options[listbox.selectedIndex].text;		
	} 
  
	function moveup(listField)
	{		
		if( listField.length == -1) 
		{  
                        //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.NoValues")%>");
		} 
		else 
		{
			var selected = listField.selectedIndex;
			if(selected == -1) 
			{				 				
                                //XSSOK		 				
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SelectMove")%>");
			} 
			else  
			{ 
				if( listField.length == 0 )
				{ 
                                        //XSSOK
					alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.OneEntry")%>");
				} 
				else  
				{ 
					if( selected == 0 )
					{
                                                //XSSOK
						alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.FirstEntryMoveup")%>");
					}				 
					else 					
					{						
						var moveText1  = listField[selected-1].text;
						var moveText2  = listField[selected].text;
						var moveName1  = listField[selected-1].name;
						var moveName2  = listField[selected].name;
						var moveValue1 = listField[selected-1].value;
						var moveValue2 = listField[selected].value;

						listField[selected].text    = moveText1;
						listField[selected].value   = moveValue1;
						listField[selected].name    = moveName1;
						listField[selected-1].text  = moveText2;
						listField[selected-1].value = moveValue2;
						listField[selected-1].name  = moveName2;
						listField.selectedIndex     = selected-1;
					}  
				} 
			}  
		}  
	}

	function movedown(listField) 
	{
		if( listField.length == -1) 
		{  
                        //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.NoValues")%>");
	    } 
		else 
		{
		  var selected = listField.selectedIndex;
		  if(selected == -1) 
			{
                                //XSSOK
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SelectMove")%>");
		    } 
			else  
			{ 
				if( listField.length == 0 ) 
				{  
                                        //XSSOK
					alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.OneEntry")%>");
				} 
				else 
				{  
					if( selected == listField.length-1 ) 
					{
                                           //XSSOK
					   alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.LastEntryMoveDown")%>");
					} 
					else 
					{					   
					   var moveText1  = listField[selected+1].text;
					   var moveText2  = listField[selected].text;
					   var moveValue1 = listField[selected+1].value;
					   var moveValue2 = listField[selected].value;
					   var moveName1  = listField[selected+1].name;
					   var moveName2  = listField[selected].name;

					   listField[selected].text    = moveText1;
					   listField[selected].value   = moveValue1;
					   listField[selected].name    = moveName1;
					   listField[selected+1].text  = moveText2;
					   listField[selected+1].value = moveValue2;
					   listField[selected+1].name  = moveName2;
					   listField.selectedIndex     = selected+1; 
					}  
				}  
			}  
	   }  
	}

	function addtolistbox(listField, newText, newValue)
	{	   
	    if( ( newValue == "" ) || ( newText == "" ) ) 
		{
                  //XSSOK
		  alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.BlankValue")%>");		  
		} 	
		else
		{			
			for ( var i = 0; i<listField.length; i++)
			{
				if (newText == listField[i].text)
				{
                                        //XSSOK
					alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.ColumnNameNotUnique")%>: " + document.forms['wkstableform'].ColumnName.value);		  
					return;
				}
			}
			
			if(!(jsValidate('wkstableform', 'ColumnName', '<%= XSSUtil.encodeForJavaScript(context,firstIntegName) %>'))) 		
			{
				return;
			}

			var expressionValue    = document.forms['wkstableform'].Attribute.value;		
                        //XSSOK			
			var charsNotSupported  = "<%=noSupportedChars%>";
			var isValidChars       = validateForBadChars(charsNotSupported, expressionValue);

			if(!isValidChars)
			{
				var msg = integrationFrame.getStringResource("Server", "Message", "InputValueContainsInvalidChars");
				alert(msg + charsNotSupported);
				document.forms['wkstableform'].Attribute.focus();

				return;
			}
			
			var columnName = document.forms['wkstableform'].ColumnName.value;
<%
				Enumeration tableKeys = mandatoryColumnsTable.keys();
				while(tableKeys.hasMoreElements())					
			    {
					String mandatoryColumnName= (String)tableKeys.nextElement();
%>
                    //XSSOK
					if(columnName == "<%=mandatoryColumnName%>")
					{
                                        	//XSSOK						
						alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SameNameMandatory")%>");
						return;					
					}	
<%
			    }
%>
				document.forms['wkstableform'].ColumnNameUnique.value = document.forms['wkstableform'].ColumnName.value;

				var len  = listField.length++; 

				listField.options[len].value =  newValue;
				listField.options[len].text  = newText;
				listField.options[len].name  = newText;
				listField.selectedIndex      = len; 
					
		 }
	}

	function removeFromListbox(listField) 
	{
	   if( listField.length == 0) 
		{     
                        //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.NothingToRemove")%>");
		} 
		else 
		{
		  var selected = listField.selectedIndex;
		  if(selected == -1) 
		  {				 
                                //XSSOK	 
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SelectRemove")%>");
		  } 
		  else 
		  {  
				
		  var columnName = document.forms['wkstableform'].ColumnNameUnique.value;
<%
				Enumeration enumd = mandatoryColumnsTable.keys();
				while(enumd.hasMoreElements())					
			    {
					String dColumnName= (String)enumd.nextElement();
%>
                                        <!--XSSOK-->
					if(columnName == "<%=dColumnName%>")
					{					
                                                	//XSSOK		
							alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CannotDeleteMandatory")%>");
							return;					
					}	
<%
			    }
%>				
	            if(selected != (listField.length -1))
				{
					document.forms['wkstableform'].ColumnNameUnique.value= listField.options[selected + 1].text;
				}
				 var replaceTextArray  = new Array(listField.length-1);
				 var replaceValueArray = new Array(listField.length-1);
				 var replaceNameArray  = new Array(listField.length-1);
				 for(var i = 0; i < listField.length; i++) 
				 { 
					 if( i < selected) 
						 replaceTextArray[i] = listField.options[i].text; 
					 if( i > selected ) 
						 replaceTextArray[i-1] = listField.options[i].text; 
					 if( i < selected) 
						 replaceValueArray[i] = listField.options[i].value; 
					 if( i > selected ) 
						 replaceValueArray[i-1] = listField.options[i].value; 
					 if( i < selected) 
						 replaceNameArray[i] = listField.options[i].name; 
					 if( i > selected ) 
						 replaceNameArray[i-1] = listField.options[i].name; 				 
			     }

			 listField.length = replaceTextArray.length;  

			 for(i = 0; i < replaceTextArray.length; i++) 
			 { 
				listField.options[i].value = replaceValueArray[i];
				listField.options[i].text  = replaceTextArray[i];
				listField.options[i].name  = replaceNameArray[i];
			 }
		  } 
	   } 
	}

	function modify(listbox, newText, newValue)
	{		
		var selected = listbox.selectedIndex;

		if(selected == -1) 
		{  
                        //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SelectModify")%>");
	    } 
		else
		{			
			 if( ( newValue == "" ) || ( newText == "" ) ) 
			{
                                //XSSOK
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.BlankValue")%>");

				return;
			} 	
			
			for ( var i = 0; i<listbox.length; i++)
			{
				if (newText == listbox[i].text && newValue == listbox[i].value)
				{
                                        //XSSOK
					alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.ColumnNameNotUnique")%>: " + document.forms['wkstableform'].ColumnName.value + " with expression " + document.forms['wkstableform'].Attribute.value);		  
					return;
				}
			}
			
			var columnNameOrig = document.forms['wkstableform'].ColumnNameUnique.value;
			var columnNameNew  = document.forms['wkstableform'].ColumnName.value;
<%
				Enumeration mandatoryColumnKeys = mandatoryColumnsTable.keys();
				while(mandatoryColumnKeys.hasMoreElements())					
			    {
					String uColumnName= (String)mandatoryColumnKeys.nextElement();
%>
                                        //XSSOK
					if(columnNameOrig == "<%=uColumnName%>")
					{
                                                //XSSOK			
						alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CannotModifyMandatory")%>");

						return;					
					}
					//XSSOK
					else if(columnNameNew == "<%=uColumnName%>")
					{					
                                                //XSSOK			
						alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CannotRenameMandatory")%>");

						return;
					}
<%
				}
%>
			if(!(jsValidate('wkstableform', 'ColumnName', '<%= XSSUtil.encodeForJavaScript(context,firstIntegName) %>'))) 		
			{
				return;
			}

			var expressionValue     = document.forms['wkstableform'].Attribute.value;		
                        //XSSOK			
			var charsNotSupported   = "<%=noSupportedChars%>";
			var isValidChars        = validateForBadChars(charsNotSupported, expressionValue);

			if(!isValidChars)
			{
				var msg = integrationFrame.getStringResource("Server", "Message", "InputValueContainsInvalidChars");
				alert(msg + charsNotSupported);
				document.forms['wkstableform'].Attribute.focus();

				return;
			}
			
			listbox.options[listbox.selectedIndex].value = document.forms['wkstableform'].Attribute.value;
			listbox.options[listbox.selectedIndex].text  = document.forms['wkstableform'].ColumnName.value;			
		}
	}

</script>
</head>
<body>
<form name='wkstableform' method="post">

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


<input type="hidden" name="mode" value="<xss:encodeForHTMLAttribute><%=mode%></xss:encodeForHTMLAttribute>">
<table border="0" >   
   <tr>
                <!--XSSOK-->
		<td  class="labelRequired"  align="left"><b><%=table%></b></td>
                <!--XSSOK-->
		<td  class="inputField" align="left"><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.WorkspaceTablePrefix")%><input type =text  name=TableName size=27 value ="<xss:encodeForHTMLAttribute><%=tableNameOrig%></xss:encodeForHTMLAttribute>"></td>	
		<td  class="inputField" align="left" colspan="2"></td>
   </tr>
   <tr>
                <!--XSSOK-->
  		<td  class="labelRequired" align="left" ><b><%=columnLabel%></b>
		<input type =hidden name=ColumnNameUnique ></td>
		<td   class="inputField" align="left" ><input type =text  name=ColumnName size=35></td>
   		<td   class="inputField" align="left" colspan="2"></td>
   </tr>
   <tr>   
                <!--XSSOK-->
		<td  class="labelRequired" align="left" ><b><%=expressionlabel%></b></td>
		<td   class="inputField"align="left" ><input type =text  name=Attribute size=35></td>
		<!--XSSOK-->
		<td ><input type="button" align="center" value="<%=search%>" name="B3" onClick="javascript:showAttributeSelector('wkstableform','Attribute')" style="width:80">&nbsp;&nbsp;&nbsp;
		</td>
		<td  align="left" colspan="1"></td>
  </tr>
</table>

<tr>&nbsp;</tr>
<tr>&nbsp;</tr>
<tr>&nbsp;</tr>

<table>
<tr>
		<td align="right">
	<table>
	<tr>
                <!--XSSOK-->
		<td><input type=button value="<%=addColumn%>" name=button1 style="width:130" onclick="javascript:addtolistbox(document.forms['wkstableform'].columnlist,document.forms['wkstableform'].ColumnName.value,document.forms['wkstableform'].Attribute.value);"></td>&nbsp;&nbsp;&nbsp;&nbsp;
	</tr>
	<tr>&nbsp;&nbsp;&nbsp;</tr>
	<tr>
                <!--XSSOK-->
		<td><input  type=button value="<%=deleteColumn%>" name=button2 style="width:130" onclick="javascript:removeFromListbox(document.forms['wkstableform'].columnlist);" ></td>&nbsp;&nbsp;&nbsp;
	</tr>
	<tr>&nbsp;&nbsp;&nbsp;</tr>
	<tr>
                <!--XSSOK-->
		<td><input id=button3 type=button value="<%=modifyColumn%>" name=button3 style="width:130" onclick="javascript:modify(document.forms['wkstableform'].columnlist,document.forms['wkstableform'].ColumnName.value,document.forms['wkstableform'].Attribute.value);"></td>&nbsp;&nbsp;&nbsp;
	</tr>
	</table>
	</td>
	<td align="center" width="50%">
	<table>	
		<select readonly style="width:150px;overflow-x:auto;" size="11" width = "130" name="columnlist" onChange="setColumnNameField(this)">

<%

	try
	{		
		if(mode.equals("add")) 
		{
			Enumeration e = mandatoryColumnsTable.keys();
			while(e.hasMoreElements())
			{
				String columnName = (String)e.nextElement();				
				String expressionm = (String)mandatoryColumnsTable.get(columnName);				
		
%>
<!--XSSOK-->
	<option name="<%=columnName%>" VALUE="<%=expressionm%>"><%=columnName%></option>
<%
			}    
		}
			 
	}
	catch(Exception exception)
	{
		  System.out.println(exception.toString());
	}

	IEFConfigUIUtil iefConfigUIUtil = null;
	
	try
	{
		iefConfigUIUtil = new IEFConfigUIUtil(context, integSessionData, "");

		if(mode.equals("modify")) 
		{
				Vector columns = iefConfigUIUtil.getTableValues(context, tableNameOrig);				
				for(int i=0; i<columns.size(); i++)
				{
					Hashtable column = (Hashtable)columns.elementAt(i);

					String columnName     = (String)column.get(IEFConfigUIUtil.COLUMN_NAME);
					String label          = (String)column.get(IEFConfigUIUtil.LABEL);
					String expression     = (String)column.get(IEFConfigUIUtil.EXPRESSION);
					String expressionType = (String)column.get(IEFConfigUIUtil.EXPRESSION_TYPE);		
					
%>
        <!--XSSOK-->
	<option name="<%=label%>" VALUE="<%=expression%>"><%=label%></option>
<%
				}    
		 }
			 
	}
	catch(Exception exception)
	{
		  System.out.println(exception.toString());
	}
%>
		</select>
	</table>
	</td>
	<td align="left">
	<table>
	<tr>
                <!--XSSOK-->
		<input type="button" value="<%=moveUp%>  " name="B3" style="width:80" onClick="javascript:moveup(document.forms['wkstableform'].columnlist);">
	</tr>
	<tr>&nbsp;</tr>
	<tr>
                <!--XSSOK-->
		<input type="button" value="<%=moveDown%>" name="B3" style="width:80" onClick="javascript:movedown(document.forms['wkstableform'].columnlist);">
	</tr>
	</table>
	</td>

</tr>
</table>
<tr>&nbsp;</tr>
</form> 
</body>
</html>
