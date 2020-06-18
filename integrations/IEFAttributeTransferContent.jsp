<%--  IEFAttributeTransferContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>


<script language="JavaScript" src="./scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="./scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>

<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIForm.css" type="text/css">

<%
	String textValue			= "";
	int colCount				= 0;
	String integrationName		= emxGetParameter(request,"integrationName");
	String prefAttrInfo			= emxGetParameter(request,"prefAttrInfo");
	String mandAttrInfo			= emxGetParameter(request,"mandAttrInfo");
	String submitUrl			= emxGetParameter(request,"submitUrl");
	String toTypeVal			= emxGetParameter(request,"toType");
	String fromTypeVal			= emxGetParameter(request,"fromType");
	String filterInfo			= emxGetParameter(request,"filterProgram");
	String isBusMapping			= emxGetParameter(request,"isBusMapping");
	String validationJSP		= emxGetParameter(request,"validationURL");
	
	String mandAttrName			  = "";
	String prefAttrName			  = "";
	String prefConfigID			  = "";
	String mandConfigID			  = "";
	String filterProg			  = "";
	String filterMethod			  = "";
	
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");	
	Context context                             = integSessionData.getClonedContext(session);
	
	String fromType				= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.FromType");
	String fromAttr				= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.FromAttr");
	String toType				= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.ToType");
	String toAttr				= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.ToAttr");
	String addColumn			= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.AddColumn");
	String deleteColumn			= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.DeleteColumn");
	String modifyColumn			= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.ModifyColumn");
	String search				= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.Search");
	String heading				= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.AttributeTransfer");
	
	String tableNameOrig		= "";

	Hashtable mandatoryAttributeMapping		= new Hashtable();
	StringTokenizer token1			= new StringTokenizer(prefAttrInfo, ":");
	if(token1.countTokens() >= 2)
	{
		prefConfigID	= (String)token1.nextElement();
		prefAttrName	= (String)token1.nextElement();	
	}
	
	StringTokenizer token2			= new StringTokenizer(mandAttrInfo, ":");
	if(token2.countTokens() >= 2)
	{
		mandConfigID	= (String)token2.nextElement();
		mandAttrName	= (String)token2.nextElement();
	}
	
	if(filterInfo != null && !filterInfo.equals(""))
	{
		StringTokenizer filterTokens = new StringTokenizer(filterInfo, ":");
		if(filterTokens.countTokens() >= 2)
		{
			filterProg	 = (String)filterTokens.nextElement();
			filterMethod = (String)filterTokens.nextElement();	
		}
	}
	
	BusinessObject mandBusObj		= new BusinessObject(mandConfigID);
	Attribute mandatoryAttributeMappingValue	= mandBusObj.getAttributeValues(context, mandAttrName);
	String mandatoryAttributeMappingString		= mandatoryAttributeMappingValue.getValue();
	
	if(mandatoryAttributeMappingString!=null && !mandatoryAttributeMappingString.trim().equals(""))
	{
		Vector mandatoryAttributeMappingList = MCADUtil.getVectorFromString(mandatoryAttributeMappingString.trim(), "\n");
						
		if(filterProg != null && !filterProg.equals(""))
		{
			Hashtable argsTable = new Hashtable();
			argsTable.put("GCO", integSessionData.getGlobalConfigObject(integrationName,context));
			argsTable.put("Mapping", mandatoryAttributeMappingList);

			String [] args = JPO.packArgs(argsTable);
		
			Hashtable jpoReturnTable = (Hashtable)JPO.invoke(context, filterProg, args, filterMethod, args, Hashtable.class);
			mandatoryAttributeMapping.putAll(jpoReturnTable);
		}
		else
		{
			Enumeration mandatoryAttributeMappingElements = mandatoryAttributeMappingList.elements();

		while (mandatoryAttributeMappingElements.hasMoreElements())
		{
				String mandatoryColumnElement = (String)mandatoryAttributeMappingElements.nextElement();
			
				mandatoryAttributeMapping.put(mandatoryColumnElement, mandatoryColumnElement);
		}
	}
	}

	String prefColElement	= "";
	
	Hashtable preferenceAttributeMapping = new Hashtable();

	BusinessObject localBusObj		= new BusinessObject(prefConfigID);
	Attribute prefAttrMappingValue	= localBusObj.getAttributeValues(context, prefAttrName);
	String prefAttrMappingString	= prefAttrMappingValue.getValue();
	if(prefAttrMappingString!=null && !prefAttrMappingString.trim().equals(""))
	{
		StringTokenizer prefAttrMappingToken		= new StringTokenizer(prefAttrMappingString, "\n");
		while(prefAttrMappingToken.hasMoreElements())
		{
			prefColElement		= (String)prefAttrMappingToken.nextElement();
			int firstIndex		= prefColElement.indexOf("|");
			String integName	=	prefColElement.substring(0,firstIndex);

			if (integName.equals(integrationName))
			{
				String prefValue =  prefColElement.substring(firstIndex+1,prefColElement.length());
				
				if(prefValue == null || prefValue.trim().equals(""))
					continue;

				Vector prefList  = new Vector();

				if(prefValue.indexOf("@") >= 0)
				{
					prefList = MCADUtil.getVectorFromString(prefValue.trim(), "@");
				}
				else 
					prefList.addElement(prefValue);

				if(filterProg != null && !filterProg.equals(""))
				{
					Hashtable argsTable = new Hashtable();
					argsTable.put("GCO", integSessionData.getGlobalConfigObject(integrationName,context));
					argsTable.put("Mapping", prefList);
					String [] args = JPO.packArgs(argsTable);
					
					Hashtable jpoReturnTable   = (Hashtable)JPO.invoke(context, filterProg, args, filterMethod, args, Hashtable.class);
					preferenceAttributeMapping.putAll(jpoReturnTable);
				}
				else
				{
					Enumeration prefEnum = prefList.elements();

					while(prefEnum.hasMoreElements())
					{
						String prefIntegValue	= (String) prefEnum.nextElement();
						preferenceAttributeMapping.put(prefIntegValue, prefIntegValue);
					}
				}
			}
		}
	}
  
%>

<html>
<head>

<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">

<script>

<%@include file = "IEFTreeTableInclude.inc"%>	
	

	function showTypeChooser(formName, fieldValue, fieldName)
	{

	  		
	  var url= "../common/emxTypeChooser.jsp?frameName=contentFrame&formName="+formName+"&SelectType=single&SelectAbstractTypes=true&InclusionList=" +fieldValue+ "&ObserveHidden=true&ShowIcons=true&fieldNameActual="+fieldName+"&fieldNameDisplay=Searchl&ReloadOpener=true";

	  showIEFModalDialog(url,420,470, ""); 
	  
	}

	function doneMethod()
	{
		var dircForm = document.forms['attrTransferForm'];
		var colCount	 = dircForm.colCount.value;
		
		var listField=document.forms['attrTransferForm'].columnlist;
		var textData ="";
		var tempData = "";
		for(var i = colCount; i<listField.length; i++)
		{
			tempData = listField.options[i].text + "@";
			textData = textData + tempData;
		}
		document.forms['submitForm'].tableData.value = textData;
        document.forms['submitForm'].submit();  
		window.parent.close();
	}
	
	function closeWindow()
	{
		window.close();
	}

	function setColumnNameField(listbox)
	{		
		var textValue = listbox.options[listbox.selectedIndex].text.split("|");
		var text1 = textValue[0];
		var text2 = textValue[1];
		var text3 = textValue[2];
		var text4 = textValue[3];

		document.forms['attrTransferForm'].fromType.value		= text1;
		document.forms['attrTransferForm'].fromAttr.value		= text2;
		document.forms['attrTransferForm'].toType.value			= text3;
		document.forms['attrTransferForm'].toAttr.value			= text4;
		
		document.forms['attrTransferForm'].ColumnNameUnique.value     = listbox.options[listbox.selectedIndex].value;
	} 
	
	function addToListBox(listField, fromType, fromAttr, toType, toAttr)
	{
		var validationURL = "<%=XSSUtil.encodeForJavaScript(context, validationJSP)%>";

	    if( ( fromType == "" ) || ( fromAttr == "" )|| ( toType == "" )||(toAttr =="") ) 
		{
                  //XSSOK
		  alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.BlankValue")%>");		  
		} 	
		else
		{			
			var message = "";
			
			if(validationURL != null && validationURL != "")
			{
				var queryString = "isBusMapping=" + "<%=XSSUtil.encodeForJavaScript(context, isBusMapping)%>" + "&integrationName=" + "<%=XSSUtil.encodeForJavaScript(context, integrationName)%>" + "&fromType=" + fromType + "&fromAttribute=" + fromAttr + "&toType=" + toType + "&toAttribute=" + toAttr;

				message = emxUICore.getDataPost(validationURL, queryString);
			}
			
			if(message.substring(0,4) == "true")
			{
			var fromType = document.forms['attrTransferForm'].fromType.value;
			var fromAttr  = document.forms['attrTransferForm'].fromAttr.value;
			var toType		   = document.forms['attrTransferForm'].toType.value;	
			var toAttr		   = document.forms['attrTransferForm'].toAttr.value;		
			
			var columnNameOrig = fromType+ "|" +fromAttr+ "|" +toType+ "|" +toAttr;
			
			for ( var i = 0; i<listField.length; i++)
			{
				if (columnNameOrig == listField[i].text)
				{
                                        //XSSOK
					alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.ColumnNameNotUnique")%>: " + document.forms['attrTransferForm'].fromType.value);		  
					return;
				}
			}
	
			var toType    = document.forms['attrTransferForm'].toType.value;
			var toAttr    = document.forms['attrTransferForm'].toAttr.value;
			
			var colCount	= document.forms['attrTransferForm'].colCount.value;			
			var tempText	= fromType;
			var tempValue	= toType;
			 
			tempText		= tempText + "|" + fromAttr;
			tempvalue		= tempValue + "|" + toAttr;
			tempText        = tempText + "|" + tempvalue;
			
			for(var i=0; i<colCount; i++ )
			{
				var textVal = listField.options[i].text.split("|");
				var text1 = textVal[0];
				var text2 = textVal[1];
				if (text2 == tempvalue)
				{
                                        //XSSOK
					alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SameValue")%>");
					return;
				}
			}
			
			var fromType = document.forms['attrTransferForm'].fromType.value;
<%
				Enumeration tableKeys = mandatoryAttributeMapping.keys();
				while(tableKeys.hasMoreElements())					
			    {
					String mandatoryColumnName= (String)tableKeys.nextElement();
%>
                                        //XSSOK
					if(tempText == "<%=mandatoryColumnName%>")
					{							
                                         	//XSSOK					
						alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SameNameMandatory")%>");
						return;					
					}	
<%
			    }
%>
				document.forms['attrTransferForm'].fromType.value = document.forms['attrTransferForm'].fromType.value;

				
				var len  = listField.length++; 

				listField.options[len].value = tempValue;
				listField.options[len].text  = tempText;
				listField.options[len].name  = fromType;
				listField.selectedIndex      = len; 
					
		 }
			 else
			 {
				alert(message.substring(6));
			 }
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
				
			var columnNameOrig = document.forms['attrTransferForm'].fromType.value;
			var columnNameNew  = document.forms['attrTransferForm'].fromAttr.value;
			var toType		   = document.forms['attrTransferForm'].toType.value;	
			var toAttr		   = document.forms['attrTransferForm'].toAttr.value;		
			
			columnNameOrig = columnNameOrig+ "|" +columnNameNew+ "|" +toType+ "|" +toAttr;
			
<%
				Enumeration enumd = mandatoryAttributeMapping.keys();
				while(enumd.hasMoreElements())					
			    {
					String dColumnName= (String)enumd.nextElement();
%>
                                        //XSSOK
					if(columnNameOrig == "<%=dColumnName%>")
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
					document.forms['attrTransferForm'].ColumnNameUnique.value= listField.options[selected + 1].text;
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
			 document.forms['attrTransferForm'].fromType.value = "";
			 document.forms['attrTransferForm'].fromAttr.value = "";
			 document.forms['attrTransferForm'].toType.value = "";	
			 document.forms['attrTransferForm'].toAttr.value = "";
		  } 
	   } 
	}

	function modify(listbox, fromType, fromAttr, toType, toAttr)
	{
		var validationURL = "<%=XSSUtil.encodeForJavaScript(context, validationJSP)%>";
		
		var selected = listbox.selectedIndex;
		var colCount	 = document.forms['attrTransferForm'].colCount.value; 
		
		if(selected == -1) 
		{  
                        //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SelectModify")%>");
	    } 
		else
		{			
			 if( ( fromType == "" ) || ( fromAttr == "" ) || ( toType == "" ) || ( toAttr == "" ) ) 
			{
                                //XSSOK
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.BlankValue")%>");

				return;
			} 	
			
			var message = "";
			
			if(validationURL != null && validationURL != "")
			{
				var queryString = "isBusMapping=" + "<%=XSSUtil.encodeForJavaScript(context, isBusMapping)%>" + "&integrationName=" + "<%=XSSUtil.encodeForJavaScript(context, integrationName)%>" + "&fromType=" + fromType + "&fromAttribute=" + fromAttr + "&toType=" + toType + "&toAttribute=" + toAttr;

				message = emxUICore.getDataPost(validationURL, queryString);
			}
			
			if(message.substring(0,4) == "true")
			{
			var columnNameOrig = document.forms['attrTransferForm'].fromType.value;
			var columnNameNew  = document.forms['attrTransferForm'].fromAttr.value;
			var toType		   = document.forms['attrTransferForm'].toType.value;	
			var toAttr		   = document.forms['attrTransferForm'].toAttr.value;		
			
			columnNameOrig = columnNameOrig+ "|" +columnNameNew+ "|" +toType+ "|" +toAttr;
			
			for ( var i = 0; i<listbox.length; i++)
			{
				var columnNameUni = listbox.options[i].value;
				if (columnNameOrig == columnNameUni )
				{
                                        //XSSOK
					alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.ColumnNameNotUnique")%>" + columnNameOrig);		  
					return;
				}
			}
			
			var columnNameOrig = document.forms['attrTransferForm'].ColumnNameUnique.value;
				
			if(selected+1 <= colCount)
			{					
                                //XSSOK		
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CannotModifyMandatory")%>");

				return;					
			}

			var toAttr    = document.forms['attrTransferForm'].toAttr.value;

			var tempText	= fromType;
			var tempValue	= toType;
			
			//concanating Value For the Modify button
			tempText		= tempText + "|" + fromAttr;
			tempvalue		= tempValue + "|" + toAttr;
			tempText        = tempText + "|" + tempvalue;
			
			listbox.options[listbox.selectedIndex].value = document.forms['attrTransferForm'].toType.value;
			listbox.options[listbox.selectedIndex].text  = tempText;			
		}
			else if(message.substring(0,5) == "false")
			{
				alert(message.substring(6));
			}
			else
			{
				alert(message);
			}
		}
	}

</script>
</head>
<body>
<form name='attrTransferForm' method="post">

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
//System.out.println("CSRFINJECTION::form::attrTransferForm");
%>

<input type="hidden" name="prefAttrName" value="<xss:encodeForHTMLAttribute><%=prefAttrName%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=prefConfigID%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="integrationName" value="<xss:encodeForHTMLAttribute><%=integrationName%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="toTypeVal" value="<xss:encodeForHTMLAttribute><%=toTypeVal%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="fromTypeVal" value="<xss:encodeForHTMLAttribute><%=fromTypeVal%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="submitUrl" value="<xss:encodeForHTMLAttribute><%=submitUrl%></xss:encodeForHTMLAttribute>">
<table border="0" >   
   <tr>
                <!--XSSOK-->
		<td  class="labelRequired"  align="left"><b><%=fromType%></b></td>
		<input type =hidden name=ColumnName></td>
		<td  class="inputField" align="left"> <input type =text  name=fromType size=35></td>	
		<%
		if(fromTypeVal != null)
		{
%>		
                <!--XSSOK-->
		<td ><input type=hidden name="Search2"><input type="button" align="center" value=<%=search%> name="B4" onClick="javascript:showTypeChooser('attrTransferForm',document.forms['attrTransferForm'].fromTypeVal.value,'fromType')" style="width:80">&nbsp;&nbsp;&nbsp;
		</td>
<%
		}
%>
		
   </tr>
   <tr>
  		<td  class="labelRequired" align="left" ><b><%=fromAttr%></b>
		<input type =hidden name=ColumnNameUnique ></td>
		<td   class="inputField" align="left" ><input type =text  name=fromAttr size=35></td>
   		
   </tr>
   <tr>   
		<td  class="labelRequired" align="left" ><b><%=toType%></b></td>
		<td   class="inputField"align="left" ><input type =text  name=toType size=35></td>
<%
		if(toTypeVal != null)
		{
%>		
         	<!--XSSOK-->
		<td ><input type=hidden name="Searchl"><input type="button" align="center" value=<%=search%> name="B3" onClick="javascript:showTypeChooser('attrTransferForm',document.forms['attrTransferForm'].toTypeVal.value, 'toType')" style="width:80">&nbsp;&nbsp;&nbsp;
		</td>
<%
		}
%>
		<td  align="left" colspan="1"></td>
  </tr>
   <tr>   
		<td  class="labelRequired" align="left" ><b><%=toAttr%></b></td>
		<td   class="inputField" align="left" ><input type=text  name=toAttr size=35></td>
		<td>&nbsp;&nbsp;&nbsp;
		</td>
		
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
		<td><input type=button  value="<%=addColumn%>" name=button1 style="width:130" onclick="javascript:addToListBox(document.forms['attrTransferForm'].columnlist,document.forms['attrTransferForm'].fromType.value,document.forms['attrTransferForm'].fromAttr.value,document.forms['attrTransferForm'].toType.value,document.forms['attrTransferForm'].toAttr.value);"></td>&nbsp;&nbsp;&nbsp;&nbsp;
	</tr>
	<tr>&nbsp;&nbsp;&nbsp;</tr>
	<tr>
	        <!--XSSOK-->
		<td><input  type=button value="<%=deleteColumn%>" name=button2 style="width:130" onclick="javascript:removeFromListbox(document.forms['attrTransferForm'].columnlist);" ></td>&nbsp;&nbsp;&nbsp;
	</tr>
	<tr>&nbsp;&nbsp;&nbsp;</tr>
	<tr>
	        <!--XSSOK-->
		<td><input id=button3 type=button value="<%=modifyColumn%>" name=button3 style="width:130" onclick="javascript:modify(document.forms['attrTransferForm'].columnlist,document.forms['attrTransferForm'].fromType.value,document.forms['attrTransferForm'].fromAttr.value,document.forms['attrTransferForm'].toType.value, document.forms['attrTransferForm'].toAttr.value);"></td>&nbsp;&nbsp;&nbsp;
	</tr>
	<tr>&nbsp;&nbsp;&nbsp;</tr>
	</table>
	</td>
	<td align="center" width="50%">
		<table>	
		<select readonly style="width:250px;overflow-x:auto;" size="11" width = "130" name="columnlist" onChange="setColumnNameField(this)">
<%

	try
	{		
			
			Enumeration mandAttrOptions = mandatoryAttributeMapping.keys();
			while(mandAttrOptions.hasMoreElements())
			{
				String columnName = (String)mandAttrOptions.nextElement();				
				String expressionm = (String)mandatoryAttributeMapping.get(columnName);
				if(expressionm != null && !"".equalsIgnoreCase(expressionm))
				{
		
%>
        <!--XSSOK-->
	<option name="<%=columnName%>" VALUE="<%=expressionm%>"><%=columnName%></option>
<%
				colCount++;
				}
			}    
 
			Enumeration prefAttrOptions = preferenceAttributeMapping.keys();
			while(prefAttrOptions.hasMoreElements())
			{
				String prefcolumnName = (String)prefAttrOptions.nextElement();				
				String prefexpressionm = (String)preferenceAttributeMapping.get(prefcolumnName);
				if(prefexpressionm != null && !"".equalsIgnoreCase(prefexpressionm))
				{
		
%>
        <!--XSSOK-->
	<option name="<%=prefcolumnName%>" VALUE="<%=prefexpressionm%>"><%=prefcolumnName%></option>
	
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
	<input type="hidden" name="colCount" value="<%=colCount%>">
		</table>
	</td>
	

</tr>
</table>
<tr>&nbsp;</tr>
</form>
<form name='submitForm' method ='post' action='<xss:encodeForHTML><%=submitUrl%></xss:encodeForHTML>' >

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

<input type="hidden" name="prefAttrName" value="<xss:encodeForHTMLAttribute><%=prefAttrName%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=prefConfigID%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="integrationName" value="<xss:encodeForHTMLAttribute><%=integrationName%></xss:encodeForHTMLAttribute>"">
<input type="hidden" name="tableData" value="">
</body>
</html>
