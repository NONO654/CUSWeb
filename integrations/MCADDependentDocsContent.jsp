<%--  MCADDependentDocsContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@page import = "matrix.db.*, matrix.util.*, com.matrixone.MCADIntegration.utils.*, com.matrixone.MCADIntegration.server.beans.*" %>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%!

	private boolean isFormFieldHidden(MCADGlobalConfigObject globalConfigObject, String attrName)
	{
		String attrEnforcedValues 	= globalConfigObject.getPreferenceValue(attrName);
		boolean isHidden  		= false;
	
		if("none".equalsIgnoreCase(attrEnforcedValues) || "".equals(attrEnforcedValues))
		{
			isHidden = true;
		}
		return isHidden;
	}


%>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String integrationName						= Request.getParameter(request,"integrationName");
	MCADLocalConfigObject localConfig			= integSessionData.getLocalConfigObject();
	MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName, integSessionData.getClonedContext(session));
	Context context								= integSessionData.getClonedContext(session);

	MCADMxUtil mxUtil							= new MCADMxUtil(context, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	String backgroundAttrName 					= mxUtil.getActualNameForAEFData(context, "attribute_IEF-Pref-IEF-SelectedBackgroundDerivedOutputs");
	String manualAttrName 					= mxUtil.getActualNameForAEFData(context, "attribute_IEF-Pref-IEF-SelectedManualDerivedOutputs");
	String autoAttrName 					= mxUtil.getActualNameForAEFData(context, "attribute_IEF-Pref-MCADInteg-SelectedDerivedOutputs");
   
	
	String backprefType 							= globalConfigObject.getPreferenceType(backgroundAttrName);
	String manualprefType 							= globalConfigObject.getPreferenceType(manualAttrName);
	String autoprefType 							= globalConfigObject.getPreferenceType(autoAttrName);
	
	String attrEnforcedValues 					= globalConfigObject.getPreferenceValue(backgroundAttrName);

	Vector enforcedValuesList					= MCADUtil.getVectorFromString(attrEnforcedValues, ",");
	boolean enforceBackgroundAsDisabled			= false;

	String enforceBackgroundAsHidden			= "";
	String enforceAutoAsHidden					= "";
	String enforceManualAsHidden				= "";


	Hashtable derivedOutputParameterObjTypeMap	= globalConfigObject.getDerivedOutputParameterObjectTypeMap();
	String showDerivedOutput					= "hidden";

	if(derivedOutputParameterObjTypeMap != null && derivedOutputParameterObjTypeMap.size() > 0)
	{
		showDerivedOutput = "visible";
	}

    if(backprefType.equalsIgnoreCase(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE) && enforcedValuesList.contains("none"))
    {
		enforceBackgroundAsDisabled = true;
    }

    if(backprefType.equalsIgnoreCase(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
    {
    	if(isFormFieldHidden(globalConfigObject, backgroundAttrName))
    		enforceBackgroundAsHidden = " style=\"visibility: hidden\" ";
    }
    
    if(autoprefType.equalsIgnoreCase(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
    {
    	if(isFormFieldHidden(globalConfigObject, autoAttrName))
    		enforceAutoAsHidden = " style=\"visibility: hidden\" ";
    }
    
    if(manualprefType.equalsIgnoreCase(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
    {
    	if(isFormFieldHidden(globalConfigObject, manualAttrName))
    		enforceManualAsHidden = " style=\"visibility: hidden\" ";
    }

	String nodeID	= Request.getParameter(request,"nodeid");
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFMiscUI.css" type="text/css">
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript">

	function formSubmit()
	{
	    //XSSOK
		var nodeID		= '<%=nodeID%>';
		var fieldsArray = document.forms['dependentDocsForm'].elements;
		for(var i=0; i < fieldsArray.length; i=i+4)
		{
			var defParamObj				= "noObject";
			var dependentDocCadType		= fieldsArray[i].name;
			var selectedGenerationType	= "noSelection";

			for(var j=i; j < i+3; j++)
			{
				var field				   = fieldsArray[j];
				var tmpdependentDocCadType = field.name;

				var isSelected			   = field.checked;

				if(isSelected)
				{
					if(tmpdependentDocCadType.indexOf('manualSelect') > -1)
					{
						selectedGenerationType = "manualSelection";
					}
					else if(tmpdependentDocCadType.indexOf('backgroundSelect') > -1)
					{
						selectedGenerationType = "backgroundSelection";
					}
					else
					{
						selectedGenerationType = "automaticSelection";
					}
				}
			}

			var fieldDefParamObj = fieldsArray[j];
			if(fieldDefParamObj.type == "select-one")
			{

				if(fieldDefParamObj.selectedIndex > -1)
				{
					defParamObj = fieldDefParamObj.options[fieldDefParamObj.selectedIndex].value;
				}
			}

			var response = changeNodeDependentDocSelection(nodeID, dependentDocCadType, selectedGenerationType, defParamObj);

			if(response != "true"  && response != "false"  && response != "")
				break;
		}


		top.close();
     }

	function changeNodeDependentDocSelection(nodeID, dependentDocCadType, selectedGenerationType, paramObj)
	{
		var framefooterFrame = findFrame(parent,"footerFrame");
		var selectChildNodes	= framefooterFrame.document.forms["dependentDocOptions"].applyToChildrenOnCheckin.checked;

		var selectionDetails = nodeID + "|" + dependentDocCadType + "|" + selectedGenerationType + "|" + paramObj + "|" + selectChildNodes;


<%
		if(nodeID != null && !"".equals(nodeID) && !"null".equalsIgnoreCase(nodeID))
		{
%>
			return parent.opener.parent.changeNodeDependentDocSelection(selectionDetails);
<%
		}
		else
		{
%>
			return top.opener.changeNodeDependentDocSelection(selectionDetails);
<%
		}
%>
	}

	function derivedOutputCheckAll()
	{
		var objForm				= document.dependentDocsForm;
		var objHeaderForm		= document.dependentDocsHeaderForm;
		var headerSelect		= objHeaderForm.headerSelect;
		var manualSelectAll		= objHeaderForm.manualSelectAll;
		var backgroundSelectAll	= objHeaderForm.backgroundSelectAll;

		for (var i=0; i < objForm.elements.length; i++)
		{
			if ((objForm.elements[i].name.indexOf('manualSelect') == -1) && (objForm.elements[i].name.indexOf('backgroundSelect') == -1) && (!objForm.elements[i].disabled))
			{
				objForm.elements[i].checked = headerSelect.checked;
			}
		}

		if(headerSelect.checked == true)
		{
			manualSelectAll.checked		= false;
			backgroundSelectAll.checked = false;
			backgroundCheckAll();
			manualCheckAll();
		}

    }

	function manualCheckAll()
	{
		var objForm				= document.dependentDocsForm;
		var objHeaderForm		= document.dependentDocsHeaderForm;
		var headerSelect		= objHeaderForm.headerSelect;
		var manualSelectAll		= objHeaderForm.manualSelectAll;
		var backgroundSelectAll	= objHeaderForm.backgroundSelectAll;

		for (var i=0; i < objForm.elements.length; i++)
		{
			if ((objForm.elements[i].name.indexOf('manualSelect') > -1) && (objForm.elements[i].name.indexOf('backgroundSelect') == -1) &&
			(!objForm.elements[i].disabled))
			{
				objForm.elements[i].checked = manualSelectAll.checked;
			}
		}

		if(manualSelectAll.checked == true)
		{
			headerSelect.checked = false;
			backgroundSelectAll.checked = false;
			backgroundCheckAll();
			derivedOutputCheckAll();
		}

	}

	function backgroundCheckAll()
	{

		var objForm				= document.dependentDocsForm;
		var objHeaderForm		= document.dependentDocsHeaderForm;
		var headerSelect		= objHeaderForm.headerSelect;
		var manualSelectAll		= objHeaderForm.manualSelectAll;
		var backgroundSelectAll	= objHeaderForm.backgroundSelectAll;

		for (var i=0; i < objForm.elements.length; i++)
		{
			if ((objForm.elements[i].name.indexOf('backgroundSelect') > -1) && (objForm.elements[i].name.indexOf('manualSelect') == -1) && (!objForm.elements[i].disabled))
			{
				objForm.elements[i].checked = backgroundSelectAll.checked;
			}
		}

		if(backgroundSelectAll.checked == true)
		{
			headerSelect.checked = false;
			manualSelectAll.checked = false;
			manualCheckAll();
			derivedOutputCheckAll();
		}

	}


	function checkSelection(object)
	{
		var objForm					= document.dependentDocsForm;
		isChecked					= object.checked;
		var isEverythingSelected	= true;
		if(isChecked)
		{

			var fieldsArray = objForm.elements;
			for(var i=0; i < fieldsArray.length; i++)
			{
				var field		= fieldsArray[i];



				if ((field.name == object.name))
				{

					if(objForm.elements[i+1].checked)
					{

						objForm.elements[i+1].checked = false;
					checkManualSelection(objForm.elements[i+1]);
					}
					if(objForm.elements[i+2].checked)
					{

						objForm.elements[i+2].checked = false;
					    checkBackgroundSelection(objForm.elements[i+2]);
					}
				}

				if (field.name.indexOf('manualSelect') == -1 && field.name.indexOf('backgroundSelect') == -1 && field.type != "select-one")
				{

					if(!field.checked)
					{
						isEverythingSelected = false;
					}
				}
			}

			if(isEverythingSelected)
			{

				var headerField		= document.forms['dependentDocsHeaderForm'].elements[0];
				headerField.checked	= true;
			}
		}
		else
		{
			var headerField		= document.forms['dependentDocsHeaderForm'].elements[0];
			headerField.checked	= false;
		}
	}

	function checkManualSelection(object)
	{

		var isEverythingSelected = true;

		if(object.checked)
		{
			var objForm = document.dependentDocsForm;
			for (var i=0; i < objForm.elements.length; i++)
			{
				var field		= objForm.elements[i];
				if ((field.name == object.name))
				{
					if(objForm.elements[i-1].checked)
					{
						objForm.elements[i-1].checked = false;
						checkSelection(objForm.elements[i-1]);
					}
					if(objForm.elements[i+1].checked)
					{
						objForm.elements[i+1].checked = false;
						checkBackgroundSelection(objForm.elements[i+1]);
					}

				}

				if (field.name.indexOf('manualSelect') > -1 && field.name.indexOf('backgroundSelect') == -1)
				{
					if(!field.checked)
					{
						isEverythingSelected = false;
					}
				}
			}

			if(isEverythingSelected)
			{
				var headerField		= document.forms['dependentDocsHeaderForm'].elements[1];
				headerField.checked	= true;
			}
		}
		else
		{
			var headerField		= document.forms['dependentDocsHeaderForm'].elements[1];
			headerField.checked	= false;
		}
	}

	function checkBackgroundSelection(object)
	{

		var isEverythingSelected = true;
		//XSSOK
		if('<%=enforceBackgroundAsDisabled%>' == 'true')
		{
			document.dependentDocsHeaderForm.elements[2].disabled = true;
		}

		if(object.checked)
		{
			var objForm = document.dependentDocsForm;

			for (var i=0; i < objForm.elements.length; i++)
			{
				var field		= objForm.elements[i];
				if ((field.name == object.name))
				{
					if(objForm.elements[i-2].checked)
					{
						objForm.elements[i-2].checked = false;
						checkSelection(objForm.elements[i-2]);
					}

					if(objForm.elements[i-1].checked)
					{
						objForm.elements[i-1].checked = false;
						checkManualSelection(objForm.elements[i-1]);
					}
				}

				if (field.name.indexOf('backgroundSelect') > -1 && field.name.indexOf('manualSelect') == -1)
				{
					if(!field.checked)
					{
						isEverythingSelected = false;
					}
				}
			}

			if(isEverythingSelected)
			{
				var headerField		= document.forms['dependentDocsHeaderForm'].elements[2];
				headerField.checked	= true;
			}
		}
		else
		{
			var headerField		= document.forms['dependentDocsHeaderForm'].elements[2];
			headerField.checked	= false;
		}
	}
	function doClose()
	{
		top.handledependentDocSelection();
	}

</script>
</head>
<body onunload="doClose()">
	<center>
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<form name="dependentDocsHeaderForm">
				<tr>
					<th width="23%"><%= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.DependentDocuments")%></th>
					<th width="20%" <%= enforceAutoAsHidden %>><input type="checkbox" id="auto" name="headerSelect" onClick="javascript:derivedOutputCheckAll()"><%= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.AutoDerivedOutput")%></th>
					<th width="16%" <%= enforceManualAsHidden %>><input type="checkbox" name="manualSelectAll" onClick="javascript:manualCheckAll()"><%= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.ManualDerivedOutput")%></th>
					<th width="22%" <%= enforceBackgroundAsHidden %>><input type="checkbox" name="backgroundSelectAll" onClick="javascript:backgroundCheckAll()" ><%= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.BackgroundDerivedOutput")%></th>
					<th width="29%" style="visibility:<%=showDerivedOutput%>;"><%= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.ParameterObject")%></th>
				</tr>
			</form>
			<form name="dependentDocsForm" method="post" target="_top" action="javascript:formSubmit()">
				<script language="JavaScript">
<%
					if(nodeID != null && !"".equals(nodeID) && !"null".equalsIgnoreCase(nodeID))
					{
%>
                                                //XSSOK
						document.write(parent.opener.parent.getDependentDocsContent("<%=nodeID%>"));
<%
					}
					else
					{
%>
						document.write(top.opener.getDependentDocsContent());
<%
					}

%>

					checkSelection(document.forms['dependentDocsForm'].elements[0]);
					checkManualSelection(document.forms['dependentDocsForm'].elements[1]);
					checkBackgroundSelection(document.forms['dependentDocsForm'].elements[2]);

				</script>
			</form>
		</table>
	</center>
</body>

</html>

