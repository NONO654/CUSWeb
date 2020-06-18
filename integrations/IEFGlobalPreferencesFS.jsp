<%--  IEFGlobalPreferencesFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context				= integSessionData.getClonedContext(session);

	String gcoName = emxGetParameter(request, "gcoName");
	String integrationName = emxGetParameter(request, "integrationName");

   	String errMsgLabel				= integSessionData.getStringResource("mcadIntegration.Applet.Message.FailedToUpdateGlobalPreferences");
	String defaultConfigTableLabel	= integSessionData.getStringResource("mcadIntegration.Server.FieldName.DefaultTableName");
	String operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title.GlobalPreferences");
%>

<html>
<head>
<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="./scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">
<%@include file = "IEFTreeTableInclude.inc"%>

var attributeNames			= new Array();
var matrixTypes				= new Array();
var pageKeys				= new Array();
var webformKeys				= new Array();
var hiddenDefaultTypesValues		= new Array();
var hiddenDefaultTypes		= new Array();
var hiddenDefaultConfigValues		= new Array();
var hiddenDefaultConfigTypes		= new Array();
var hiddenDefaultWebFormValues		= new Array();
var hiddenDefaultWebFormTypes		= new Array();
//XSSOK
var defaultConfigTableName  = "<%= defaultConfigTableLabel %>";
var searchBoxName = "";
var hiddenSearchBoxName = "";

var frametableDisplay = null;
function init()
{
	frametableDisplay = findFrame(this,"tableDisplay");
}
function closeWindow()
{
	window.close();
    return;
}

function  showDialogAttrMapping(chooser)
{
	var  url  =  "IEFAttribMappingFS.jsp?gcoName=<%=XSSUtil.encodeForURL(context,gcoName)%>&MappingType=" + chooser + "&firstTime=true";
	showIEFModalDialog(url,  700,  400,  true);
} 
//Event Handlers Start
function showDependentDocs(fieldName, integrationName)
{
	var derivedOutputPage = "MCADDependentDocsFS.jsp?nodeid=" + fieldName + "&integrationName=" + integrationName;

	showIEFModalDialog(derivedOutputPage, 300, 350);
}

//Event Handlers End
function getFieldValue(formField)
{
	var fieldValue = "";

    if(formField.type == "checkbox" || formField.type == "radio")
    {
		fieldValue = formField.checked;
    }
	else if(formField.type == "select-one" || formField.type == "combobox")
    {
		fieldValue = formField.options[formField.selectedIndex].value;
    }
	else if(formField.type == "text" || formField.type == "editbox" || formField.type == "hidden")
	{
		fieldValue = formField.value;
	}

	return fieldValue;
}

function contains(a, obj)
{
    for(var i = 0; i < a.length; i++) 
    {
	  if(a[i] === obj)
	  {
	    return true;
	  }
    }

    return false;
}
		

function submit()
{
	var attrNameValList = "";
	var formObject = frametableDisplay.document.forms['formGlobalPreferences'];
	for(i=0; i<attributeNames.length; i++)
	{
		var attributeName = attributeNames[i];
        if(attributeName == "IEF-Pref-MCADInteg-DefaultTypePolicySettings")
		{
			attrNameValList += attributeName + "|";

			for(count=0; count<matrixTypes.length; count++)
			{
				var matrixType			   = matrixTypes[count];
				if(!contains(hiddenDefaultTypes,matrixType))
				{
				var fieldNameForDesPols	   = attributeName + "_DesPol[" + count + "]";
				var fieldForDesPols	       = formObject.elements[fieldNameForDesPols];
				var fieldValForDesPols     = getFieldValue(fieldForDesPols);
//[NDM] : H68
				var fieldNameForAttrType   = attributeName + "_Type[" + count + "]";
				var fieldForAttrType	   = formObject.elements[fieldNameForAttrType];
				var attributeType		   = getFieldValue(fieldForAttrType);

				if(attributeType == "Enforce To")
				{
					attributeType = "ENFORCED";
				}
				else
				{
					attributeType = "DEFAULTVALUE";
				}
//[NDM] : H68
				attrNameValList += "(" + attributeType + ")" + matrixType + "|" + fieldValForDesPols + "\n";
			}
				else
				{
					attrNameValList += hiddenDefaultTypesValues[count];
				}
			}

			attrNameValList += ";";
		}
		else if(attributeName == "IEF-Pref-IEF-DefaultConfigTables")
		{
			attrNameValList  += attributeName + "|";

			for( var x = 0; x < pageKeys.length; x++)
			{
				var pageKey					= pageKeys[x];

				if(!contains(hiddenDefaultConfigTypes,pageKey))
				{
				var fieldNameForTableName	= attributeName + "_tableList["+ x +"]";
				var fieldForTableName		= formObject.elements[fieldNameForTableName];
				var fieldValueForTableName	= getFieldValue(fieldForTableName);
				var fieldNameForAttrType	= attributeName + "_tableListRule[" + x + "]";
				var fieldForAttrType		= formObject.elements[fieldNameForAttrType];
				var attributeType			= getFieldValue(fieldForAttrType);

				if(fieldValueForTableName == defaultConfigTableName)
					fieldValueForTableName = "Default";

				if(attributeType == "Enforce To")
				{
					attributeType = "ENFORCED";
				}
				else
				{
					attributeType = "DEFAULTVALUE";
				}

				attrNameValList += "(" + attributeType + ")" + pageKey + "$" + fieldValueForTableName + "@";
				}
				else
				{
					attrNameValList += hiddenDefaultConfigValues[x];
				}
			}

			if( pageKeys.length > 0)
			{
				attrNameValList = attrNameValList.substring(0,(attrNameValList.length)-1);
			}

			attrNameValList += ";";
		}
		else if(attributeName == "IEF-Pref-IEF-DefaultWebforms")
		{
			attrNameValList  += attributeName + "|";

			for( var x = 0; x < webformKeys.length; x++)
			{
				var webformKey					= webformKeys[x];
				if(!contains(hiddenDefaultWebFormTypes,webformKey))
				{
				var fieldNameForTableName	= attributeName + "_webformList["+ x +"]";
				var fieldForTableName		= formObject.elements[fieldNameForTableName];
				var fieldValueForTableName	= getFieldValue(fieldForTableName);
				var fieldNameForAttrType	= attributeName + "_webformListRule[" + x + "]";
				var fieldForAttrType		= formObject.elements[fieldNameForAttrType];
				var attributeType			= getFieldValue(fieldForAttrType);

				if(attributeType == "Enforce To")
				{
					attributeType = "ENFORCED";
				}
				else
				{
					attributeType = "DEFAULTVALUE";
				}

				attrNameValList += "(" + attributeType + ")" + webformKey + "$" + fieldValueForTableName + "@";
				}
				else
				{
					attrNameValList += hiddenDefaultWebFormValues[x];
				}
			}

			if( pageKeys.length > 0)
			{
				attrNameValList = attrNameValList.substring(0,(attrNameValList.length)-1);
			}

			attrNameValList += ";";
		}
		else
		{
			var field		  = formObject.elements[attributeName];
			var attributeVal  = getFieldValue(field);

			var fieldNameForAttrType	= attributeName + "_Type";
			var fieldForAttrType		= formObject.elements[fieldNameForAttrType];
			var attributeType			= getFieldValue(fieldForAttrType);

			if(attributeType == "Enforce To")
			{
				attributeType = "ENFORCED";
			}
			else
			{
				attributeType = "DEFAULTVALUE";
			}

			attrNameValList += attributeName + "|"  + "(" + attributeType + ")" + attributeVal + ";";
		}
	}
	formObject.elements['attrNameValList'].value = attrNameValList;

	formObject.submit();
}

function done(statusMsg)
{
	if(statusMsg.indexOf("true") > -1)
	{
		window.close();
	}
	else if(statusMsg.indexOf("false") > -1)
	{
                //XSSOK
		alert("<%= errMsgLabel %>" + statusMsg.substring(6));
	}
}

function showDirectoryChooser(fieldName)
{

	var checkoutDirectoryField	= frametableDisplay.document.forms['formGlobalPreferences'].elements[fieldName];
	var integrationFrame = getIntegrationFrame(this);

	//cannot go ahead if unable to locate integration frame.
	if( integrationFrame != null )
	{
		integrationFrame.showDirectoryChooser("", checkoutDirectoryField, "");
	}
}

function showFolderChooser(fieldName, hiddenFieldName)
{
	searchBoxName = frametableDisplay.document.forms['formGlobalPreferences'].elements[fieldName];
	//XSSOK
	var url = "MCADFolderSearchDialogFS.jsp" + "?integrationName=<%=integrationName%>" +"&gcoName=<%=XSSUtil.encodeForURL(context,gcoName)%>";
	hiddenSearchBoxName = frametableDisplay.document.forms['formGlobalPreferences'].elements[hiddenFieldName];	
	showIEFModalDialog(url, 430, 400,true);
}
function doGlobalSelect(objectId, objectName, applyToChild)
{
        //XSSOK
	objectName = hexDecode("<%=integrationName%>", objectName);
	searchBoxName.value = objectName;
	hiddenSearchBoxName.value = objectId;
}
function clearSelectedFolder(fieldName, hiddenFieldName)
{
	frametableDisplay.document.forms['formGlobalPreferences'].elements[fieldName].value="";
	frametableDisplay.document.forms['formGlobalPreferences'].elements[hiddenFieldName].value="";
}
</script>
</head>
<title><xss:encodeForHTML><%=operationTitle%></xss:encodeForHTML></title>
<frameset rows="75,*,80,0" frameborder="no" framespacing="0" onLoad="javascript:init()" onUnload="javascript:closeWindow()">
	<frame name="headerDisplay" src="IEFGlobalPreferencesHeader.jsp" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="no">
	<frame name="tableDisplay"  src="IEFGlobalPreferencesContent.jsp?gcoName=<%= XSSUtil.encodeForURL(context,gcoName)%>" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="bottomDisplay" src="IEFGlobalPreferencesFooter.jsp" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="hiddenFrame" src="IEFGlobalPreferencesHiddenFrame.jsp" noresize="noresize" marginheight="0" marginwidth="0" frameborder="0" scrolling="no" >
</frameset>
</html>
