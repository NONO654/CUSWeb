
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ include file ="../emxI18NMethods.inc" %>
<%@ include file = "../components/emxSearchInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%!
	private String getI18NString(MCADIntegrationSessionData integSessionData, String type, String key) throws Exception
	{
		key	= removeSpacesInKey(key);
		//special case: If CAD object attributes(key) contains "-" in their name.
		if(key.contains("-"))
		{
			key = key.replace("-", "");
		}
		
		String i18nKey		= "mcadIntegration.Server." + type + "." + key;
		String i18nString	= integSessionData.getStringResource(i18nKey);

		if(i18nString == null || "null".equals(i18nString) || "".equals(i18nString) || i18nString.equals(i18nKey))
		{
			i18nString = key;
		}
		
		return i18nString;
	}

	private String getAttributeValue(AttributeList attributeList, String attributeName) throws Exception
	{
		String attributeValue = "";

		AttributeItr attributeItr = new AttributeItr(attributeList);
		while(attributeItr.next())
		{
			Attribute attribute = attributeItr.obj();
			if(attribute.getName().equals(attributeName))
			{
				attributeValue = attribute.getValue();
				break;
			}
		}

		return attributeValue;
	}

    private boolean attributeHasChoicesOnly(Context context, MCADMxUtil util, String attrName)throws Exception
    {
        boolean hasChoices	= false;
		String Args[] = new String[3];
		Args[0] = attrName;
		Args[1] = "range";
		Args[2] = "~";
		String result = util.executeMQL(context, "print attribute $1 select $2 dump $3", Args);

		if(result.startsWith("true|"))
		{
			result = result.substring(5);
		}
		else
		{
			throw new Exception(result.substring(6));
		}

        StringList stringlist = new StringList();
        StringTokenizer rangeValues = new StringTokenizer(result, "~");
        if(rangeValues.hasMoreTokens())
        {
			hasChoices = true;
		}

        while(rangeValues.hasMoreTokens() && hasChoices) 
        {
            StringTokenizer tokens = new StringTokenizer(rangeValues.nextToken(), " ");
            if(tokens.hasMoreTokens())
            {
                String str = tokens.nextToken();
                if(str != null && !str.equals("=") && !str.equals("uses"))
				{
                    hasChoices = false;
				}
            }
        }

        return hasChoices;
    }

	/*
    Display the field
	*/
	private String displayField(Context context,
									MCADMxUtil util,
									Map mapValue,
									String access,
									HttpSession session,
									String sAttribParamName,
									String sFormName, String language) throws Exception 
	{
		//ATTRIBUTE_DETAILS_TYPE
		String strAttrType = (String)mapValue.get("type");
		//ATTRIBUTE_DETAILS_MULTILINE
		String strAttrMultiLine = (String)mapValue.get("multiline");
		//ATTRIBUTE_DETAILS_NAME
		String strAttrName    = (String)mapValue.get("name");
		
		if("".equals(sAttribParamName) || null == sAttribParamName || "null".equals(sAttribParamName) ) {
			sAttribParamName = strAttrName;
		}
		
		//SEL_ATTRIBUTE_VALUE
		String strAttrValue = (String)mapValue.get("value");
		//ATTRIBUTE_DETAILS_CHOICES
		StringList strListChoices = (StringList)mapValue.get("choices");

		if ("edit".equalsIgnoreCase(access)) 
		{
			StringBuffer strDisplayField;
			boolean hasChoices = attributeHasChoicesOnly(context, util, strAttrName);
			if ( hasChoices && strListChoices != null && strListChoices.size() > 0 )
			{   
				strDisplayField = new StringBuffer(350);
				strDisplayField.append(" <select name=\"").append(sAttribParamName).append("\">");
				StringItr strItr = new StringItr(strListChoices);
				while ( strItr.next() )
				{
					if ( strItr.obj().equals(strAttrValue) ) 
					{
						strDisplayField.append("<option selected value=\"").append(strItr.obj()).append("\">").append(i18nNow.getMXI18NString(strItr.obj(),strAttrName, language ,"Range")).append("</option>");						
					}
					else 
					{
						strDisplayField.append("<option value=\"").append(strItr.obj()).append("\">").append(i18nNow.getMXI18NString(strItr.obj(),strAttrName, language ,"Range")).append("</option>");
					}
				}
				strDisplayField.append("</select>");
				
				return strDisplayField.toString();
			}
			else if (strAttrType.equals("real") || strAttrType.equals("integer"))
			{
				strDisplayField = new StringBuffer(60);
				strDisplayField.append("<input type=\"text\" name=\"").append(sAttribParamName).append("\" value=\"").append(strAttrValue).append("\">");			

				return strDisplayField.toString();
			}
			 
			else if (strAttrType.equals("timestamp"))
			{
				double iClientTimeOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
				Hashtable hashDateTime = new Hashtable();
				String strDate = "";
				if (strAttrValue != null && !"".equals(strAttrValue) )
				{
					hashDateTime = eMatrixDateFormat.getFormattedDisplayInputDateTime(strAttrValue,iClientTimeOffset);
					strDate = (String)hashDateTime.get("date");
				}
				
				strDisplayField = new StringBuffer(250);
				strDisplayField.append("<input type=\"text\" name=\"").append(sAttribParamName).append("\" value=\"").append(strDate).append("\" onFocus=blur();>&nbsp;&nbsp;");

				if(sFormName!= null && !"".equals(sFormName) && !"null".equals(sFormName))
				{
					strDisplayField.append("<a href=\"javascript:showCalendar('"+sFormName +"','").append(java.net.URLEncoder.encode(sAttribParamName)).append("','')\"><img src=\"../common/images/iconSmallCalendar.gif\" border=0></img></a> &nbsp;");

					strDisplayField.append("<a name=\"ancClear\" href=\"#ancClear\" class=\"dialogClear\" onclick=\"document.");
					strDisplayField.append(sFormName);
					strDisplayField.append(".");
					strDisplayField.append(java.net.URLEncoder.encode(sAttribParamName));
					strDisplayField.append(".value='';\">");
					strDisplayField.append(i18nNow.getI18nString("emxComponents.Common.Clear", "emxComponentsStringResource", language));
					strDisplayField.append("</a>");

				}
				else
				{
					strDisplayField.append("<a href=\"javascript:showCalendar(\'editForm',\'").append(java.net.URLEncoder.encode(sAttribParamName)).append("','')\"><img src=\"../common/images/iconSmallCalendar.gif\" border=0></img></a> &nbsp;");

					strDisplayField.append("<a name=\"ancClear\" href=\"#ancClear\" class=\"dialogClear\" onclick=\"document.");
					strDisplayField.append("editForm");
					strDisplayField.append(".");
					strDisplayField.append(java.net.URLEncoder.encode(sAttribParamName));
					strDisplayField.append(".value='';\">");
					strDisplayField.append(i18nNow.getI18nString("emxComponents.Common.Clear", "emxComponentsStringResource", language));
					strDisplayField.append("</a>");

				}
				
				return strDisplayField.toString();
			}

			if ((strAttrMultiLine == null) || ("null".equalsIgnoreCase(strAttrMultiLine)) || ("".equals(strAttrMultiLine))) 
			{
				String Args1[] = new String[3];
				Args1[0] = strAttrName;
				Args1[1] = "multiline";
				Args1[2] = "|";
				String sResult = util.executeMQL(context,  "print attribute $1 select $2 dump $3", Args1);
				if(sResult.startsWith("true|"))
				{
					sResult = sResult.substring(5);
				}
				else
				{
					throw new Exception(sResult.substring(6));
				}

				if(sResult.trim().equalsIgnoreCase("TRUE")) 
				{ 
					strAttrMultiLine = "true";
				} 
				else 
				{ 
					strAttrMultiLine = "false";
				}
			}
			if ("true".equals(strAttrMultiLine) )
			{
				strDisplayField = new StringBuffer(150);
				strDisplayField.append("<textarea name=\"").append(sAttribParamName).append("\" rows=\"5\" cols=\"40\" wrap>").append(strAttrValue).append("</textarea>");
				
				return strDisplayField.toString();
			}
			else
			{
				strDisplayField = new StringBuffer(100);
				String attModelType         = MCADMxUtil.getActualNameForAEFData(context, "attribute_ModelType");
                String attDesignatedUser    = MCADMxUtil.getActualNameForAEFData(context, "attribute_DesignatedUser");
				if((sAttribParamName.equals(attModelType) || sAttribParamName.equals(attDesignatedUser)))
                {
					strDisplayField.append("<input type=\"text\" name=\"").append(sAttribParamName + "_dummy").append("\" value=\"").append(i18nNow.getI18nString("emxIEFDesignCenter.Common.Unassigned", "emxIEFDesignCenterStringResource", language)).append("\">");
					strDisplayField.append("<input type=\"hidden\" name=\"").append(sAttribParamName).append("\" value=\"").append(i18nNow.getI18nString("emxIEFDesignCenter.Common.Unassigned", "emxIEFDesignCenterStringResource", language)).append("\">");					
                }
				else
				{
				    strDisplayField.append("<input type=\"text\" name=\"").append(sAttribParamName).append("\" value=\"").append(i18nNow.getMXI18NString(strAttrValue, strAttrName, language ,"Range")).append("\">");
				}
				
				return strDisplayField.toString();
			}
		}
		return "";
	}
	
	private String	removeSpacesInKey(String key)throws Exception
	{
		StringTokenizer tokenizer	= new StringTokenizer(key," ");
		StringBuffer tempStringBuff	= new StringBuffer();
		while (tokenizer.hasMoreElements())
		{
			tempStringBuff.append(tokenizer.nextElement());
		}
		return tempStringBuff.toString();
	}

%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	MCADMxUtil util = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	String integrationName					  =Request.getParameter(request,"integrationName");
	MCADGlobalConfigObject globalConfigObject = integSessionData.getGlobalConfigObject(integrationName,context);
	MCADLocalConfigObject localConfigObject	  = integSessionData.getLocalConfigObject();
		
	MCADFolderUtil folderUtil 					= new MCADFolderUtil(context, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	String defaultFolderAttrName				= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-Pref-IEF-DefaultFolder");

	String isdefaultFolderDisabled				= "";	
	String defaultFolderHiddenHTMLContent				= "";	
	String folderTNR							= "";
	String folderPath							= "" ;
	String applyToChild							= "false";
	String folderId								=Request.getParameter(request,"workspaceFolderId");
	//If isFolderDisabled flag is true Start Design operation is initiated from Workspace Folder
	String isFolderDisabled						=Request.getParameter(request,"isFolderDisabled");
	if(folderId != null && !"".equals(folderId) && !"null".equals(folderId) && "TRUE".equalsIgnoreCase(isFolderDisabled))
	{
		isdefaultFolderDisabled = "disabled";		
		folderPath = folderUtil.getWorkspaceFolderPath(context, folderId);
	}
	else
	{
		
		String defaultFolderPrefType	= globalConfigObject.getPreferenceType(defaultFolderAttrName);
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
	}
			
	String selectedTemplateObjID	=Request.getParameter(request,"selectedTemplateObjID");
	String cadType					=Request.getParameter(request,"selectedCADType");
	String source					=Request.getParameter(request,"source");
	String isCheckoutRequired		=Request.getParameter(request,"isCheckoutRequired");
	String parentObjectId			=Request.getParameter(request,"parentObjectId");

   String sCreateNew				= integSessionData.getStringResource("mcadIntegration.Server.ButtonName.CreateNew");

	String selectedMxType			=Request.getParameter(request,"selectedType");
	if(selectedMxType == null || selectedMxType.equals("null"))
	{
		selectedMxType = "";
	}

	String selectedPolicy			=Request.getParameter(request,"selectedPolicy");
	if(selectedPolicy == null || selectedPolicy.equals("null"))
	{
		selectedPolicy = "";
	}

	BusinessObject templateObject = new BusinessObject(selectedTemplateObjID);

	templateObject.open(context);
	
	String templateType = templateObject.getTypeName();
	AttributeList attributeList = templateObject.getAttributeValues(context);
	
	String drawingNum   = Request.getParameter(request,"drawingNum");
	if(drawingNum == null || "null".equals(drawingNum))
	{
		drawingNum="";
	}

	String autoName =Request.getParameter(request,"autoName") ;
	if((autoName == null) || (autoName.equals("")) || (autoName.equals("null"))) 
	{
		autoName = "";
	}
	else if(autoName.equalsIgnoreCase("true")) 
	{
		autoName = "checked";
	}

	String sDescription =Request.getParameter(request,"Description") ;
	if((sDescription == null) || (sDescription.equals("")) || (sDescription.equals("null"))) 
	{
		sDescription = templateObject.getDescription(context);
	}
	
	templateObject.close(context);

	//get the list of unsupported characters
	String unsupportedChars = globalConfigObject.getNonSupportedCharacters();
        if(unsupportedChars == null || unsupportedChars.equals(""))
	   unsupportedChars = MCADNameValidationUtil.getInvalidCharactersForCADType(cadType, globalConfigObject);

	String sKeyPress = " onkeypress=\"javascript:if((event.keyCode == 13) || (event.keyCode == 10) || (event.which == 13) || (event.which == 10)) parent.submit()\"";
%>

<html>
<head>

<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIForm.css" type="text/css">

<script language="JavaScript" src="scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>

<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="javascript">
//get date to start with

function showFolderChooser()
{
	var url = "MCADFolderSearchDialogFS.jsp?integrationName=<%=XSSUtil.encodeForJavaScript(context,integrationName)%>";
	showIEFModalDialog(url, 430,400, true);
}

function doGlobalSelect(objectId, objectName, applyToChild)
{
        objectName = hexDecode("<%=XSSUtil.encodeForJavaScript(context,integrationName)%>", objectName);
        document.createForm.folder.value = objectName;
	document.createForm.folderId.value = objectId;
	document.createForm.applyToChild.value = applyToChild;
}

function clearSelectedFolder()
{
document.createForm.folder.value="";
	document.createForm.folderId.value = "";
	document.createForm.applyToChild.value = "";
}

function selectPolicy()
{
	reload(true);
}

function selectType()
{
	reload(false);
}

//Function to reload the page
function reload(isPolicyChanged) 
{
	
	document.createForm.drawingNum.value = document.createForm.SpecDrawingNum.value;
    document.createForm.autoName.value = document.createForm.checkAutoName.checked;
    document.createForm.selectedSeries.value = document.createForm.AutoNameList.selectedIndex;
	document.createForm.selectedType.value = document.createForm.TypeList.options[document.createForm.TypeList.selectedIndex].value;
	
	if(isPolicyChanged)
	{
		document.createForm.selectedPolicy.value = document.createForm.PolicyList.options[document.createForm.PolicyList.selectedIndex].value;
	}

	var url = "IEFStartDesignCreateObjectContent.jsp?integrationName=<%= XSSUtil.encodeForJavaScript(context,integrationName) %>&selectedTemplateObjID=<%= XSSUtil.encodeForURL(context ,selectedTemplateObjID) %>&selectedCADType=<%= XSSUtil.encodeForURL(context , cadType) %>&workspaceFolderId=<%=XSSUtil.encodeForURL(context , folderId)%>&isFolderDisabled=<%=XSSUtil.encodeForURL(context , isFolderDisabled)%>";

	document.createForm.action = url;
    document.createForm.target="";
    document.createForm.method="post";
    document.createForm.submit();

}

function checkInput()
{
        //XSSOK
	var badChars = "<%= unsupportedChars %>";

	var isNameWithBadChars = validateForBadChars(badChars, document.createForm.SpecDrawingNum.value);
    if (!isNameWithBadChars)
	{
      //XSSOK
      alert("<%= getI18NString(integSessionData, "Message", "AlertInValidChars") %>" + badChars + "<%= getI18NString(integSessionData, "Message", "AlertRemoveInValidChars")%>");

      document.createForm.SpecDrawingNum.focus();
      return false;
    }

<% if(globalConfigObject.isAssignCADModelNameFromPart())
	{ 
%>
	document.createForm.partName.value = parent.jsTrim(document.createForm.partName.value);
    if (document.createForm.partName.value == "") 
	{
      //XSSOK
      alert("<%= getI18NString(integSessionData, "Message" ,"partnameNotSet") %>");
      document.createForm.partName.focus();
      return false;
    }
<%
	}
	else
	{
%>
    if (!document.createForm.checkAutoName.checked)
	{
      if (document.createForm.SpecDrawingNum.value == "") 
	  {
        //XSSOK
        alert("<%= getI18NString(integSessionData, "Message", "EnterObjectName") %>");
        return false;
      }
    }
	
<%
	}
%>

    document.createForm.CustomRevLevel.value = parent.jsTrim(document.createForm.CustomRevLevel.value);
    if (document.createForm.CustomRevLevel.value == "") 
	{
      //XSSOK
      alert("<%= getI18NString(integSessionData, "Message" ,"RevisionNotSet") %>");
      document.createForm.CustomRevLevel.focus();
      return false;
    }

    if (document.createForm.checkAutoName.checked) 
	{
      if (document.createForm.SpecDrawingNum.value != "") 
	  {
        //XSSOK
        alert("<%= getI18NString(integSessionData, "Message", "PickOnlyOne") %>");
        return false;
      }
    }
	
    if (document.createForm.checkAutoName.checked) 
	{
      var AutoNameListValue = document.createForm.AutoNameList[document.createForm.AutoNameList.selectedIndex].value;
      if ((AutoNameListValue == "None")||
          (AutoNameListValue == "Not Selected")) 
	  {
        //XSSOK
        alert("<%= getI18NString(integSessionData, "Message", "PickAutoNameSeries") %>");
        return false;
      }
    }

   
   var mandatoryAttributes = document.createForm.mandatoryAttributes.value;
   if(parent.trimWhitespace(mandatoryAttributes) != '|')
   {
	   for (var i=0; i < document.createForm.elements.length; i++)
	   {
			var formFieldName = document.createForm.elements[i].name;
			var newFormFieldName = "|" + formFieldName + "|";
			var fieldIndex = mandatoryAttributes.indexOf(newFormFieldName,0);
			if(fieldIndex > -1)
		   {
				var formFieldValue = document.createForm.elements[i].value;
				formFieldValue = parent.trimWhitespace(formFieldValue);
				if (formFieldValue == '')
				{
                                        //XSSOK
					alert('' + formFieldName + " - <%= getI18NString(integSessionData, "Message", "ValueNotSet") %>");
					document.createForm.elements[i].focus();
					return false;
				}
		   }
	   }
   }
   
   return true;
}//end of function checkInput()

function checkForUpperCase()
{
	var integrationName = "<%=XSSUtil.encodeForJavaScript(context,integrationName) %>";

	//If the object is of ProE type, convert string to upper case
	if(integrationName == "MxPRO" || integrationName == "MxCATIAV4")
	{
		var inputString = document.createForm.SpecDrawingNum.value;
		document.createForm.SpecDrawingNum.value = inputString.toUpperCase();
	}
}

</script>
</head>
<body>

	<table border="0" cellpadding="0" cellspacing="0"  width="1%" align="center">
	        <!--XSSOK-->
		<tr><td class="requiredNotice" align="center" nowrap ><%= getI18NString(integSessionData, "Message", "FieldsInRedItalicsRequired") %></td></tr>
	</table>

	<form name="createForm"  action="javascript:parent.submit()" target="hiddenFrame">

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

	<input type="hidden" name="integrationName" value="<%= XSSUtil.encodeForJavaScript(context,integrationName) %>" />
	<table width="100%" border="0" cellspacing="2" cellpadding="5">
	  <tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "Type") %></td>
		<td class="inputField">
		  <select name="TypeList" onChange="javaScript:selectType()">
<%
	Vector mappedMxTypes = globalConfigObject.getMappedBusTypes(cadType);
	if(mappedMxTypes != null && mappedMxTypes.size() > 0 )
	{	
		if(selectedMxType.equals(""))
		{
			selectedMxType = (String)mappedMxTypes.elementAt(0);
		}

		for(int i=0; i<mappedMxTypes.size(); i++)
		{
			String mappedMxType = (String)mappedMxTypes.elementAt(i);
			if(mappedMxType.equals(selectedMxType))
			{
%>
                <!--XSSOK-->
				<option value="<%=XSSUtil.encodeForHTML(context, mappedMxType) %>" selected><%= MCADMxUtil.getNLSName(context, "Type",mappedMxType, "", "", acceptLanguage) %></option>
<%
			}
			else
			{
%>
                <!--XSSOK-->
				<option value="<%=XSSUtil.encodeForHTML(context, mappedMxType) %>"><%= MCADMxUtil.getNLSName(context, "Type",mappedMxType, "", "", acceptLanguage) %></option>
<%
			}
		}
	}
%>
		  </select>
		</td>
	  </tr>
<% if(globalConfigObject.isAssignCADModelNameFromPart())
	{ 
%>
	 
	  <tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "Name") %></td>
		<td class="inputField">
		<!--XSSOK-->
		<input type="text" size="20" name="SpecDrawingNum" readonly value="<%= XSSUtil.encodeForHTMLAttribute(context , drawingNum) %>" <%=sKeyPress%> onmouseout="javascript:checkForUpperCase()" onchange="javascript:checkForUpperCase()" onkeyup="javascript:checkForUpperCase()"/>
		<!--XSSOK-->
		<input type="checkbox"  name="checkAutoName"  DISABLED <%=XSSUtil.encodeForHTMLAttribute(context , autoName)%>/>
		<!--XSSOK-->
		<%= getI18NString(integSessionData, "FieldName", "AutoName") %>
		</td>
	  </tr>

<% 
	} else {
%>

	  <tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "Name") %></td>
		<td class="inputField">
		<!--XSSOK-->
		<input type="text" size="20" name="SpecDrawingNum" value="<%= XSSUtil.encodeForHTMLAttribute(context , drawingNum) %>" <%=sKeyPress%> onmouseout="javascript:checkForUpperCase()" onchange="javascript:checkForUpperCase()" onkeyup="javascript:checkForUpperCase()"/>
		<!--XSSOK-->
		<input type="checkbox"  name="checkAutoName" <%=XSSUtil.encodeForHTMLAttribute(context , autoName)%>/>
		<!--XSSOK-->
		<%= getI18NString(integSessionData, "FieldName", "AutoName") %>
		</td>
	  </tr>

<% 
	} 
%>
	  <tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "Policy") %></td>
		<td class="inputField">
		  <select name="PolicyList" onChange="javaScript:selectPolicy()">
<%
	Vector defaultPolicies = util.getDefaultPoliciesForType(selectedMxType, globalConfigObject, localConfigObject, integrationName);
	String designPolicy    = (String)defaultPolicies.firstElement();
	String language = integSessionData.getResourceBundle().getLanguageName();
	MCADMxUtil _util                            = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	Vector policies = globalConfigObject.getPolicyListForType(selectedMxType);	
	if(policies!=null && policies.size()>0)
	{
	    if(selectedPolicy.equals(""))
	    {
			if(designPolicy!=null && !designPolicy.equals("") && !designPolicy.equals("null"))
				selectedPolicy = designPolicy;
			else
				selectedPolicy = (String)policies.elementAt(0);
	    }

	    for(int i=0; i<policies.size(); i++)
	    {
			String policy = (String)policies.elementAt(i);
			
			if(policy.equals(selectedPolicy))
			{
%>
                                <!--XSSOK-->
				<option value="<%= policy %>" selected><%= MCADMxUtil.getNLSName(context, "Policy",policy, "", "", acceptLanguage) %>
<%
			}
			else
			{
%>
                                <!--XSSOK-->
				<option value="<%= policy %>"><%= MCADMxUtil.getNLSName(context, "Policy",policy, "", "", acceptLanguage) %>
<%
			}
		}
	}
%>
		  </select>
		</td>
	  </tr>

<%
	String selected = "";
	String sSeries  =  emxGetParameter(request, "selectedSeries") ;
	if((sSeries==null) || (sSeries.equals("")) || (sSeries.equals("null"))) 
	{
		sSeries = "0";
	}

%>		
	  <tr>
	        <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "AutonameSeries") %></td>
		<td class="inputField">
<% 
	if(globalConfigObject.isAssignCADModelNameFromPart())
	{ 
%>
		<select name="AutoNameList" disabled onChange="">
<%
	}
	else
	{
%>
		  <select name="AutoNameList" onChange="">
<%
	}

	if (Integer.parseInt(sSeries) == 0) 
	{
		selected = "selected";
	}
%>
                  <!--XSSOK-->
		  <option value="None" <%= selected %>><%= getI18NString(integSessionData, "FieldName", "NotSelected") %></option>
<%		
	selected="";
	//Get all the objects of type eService Object Generator for base type of the selected matrix type
	//and get their revisions
	
	String baseType     = util.getBaseType(context, selectedMxType);
	String sNamePattern = util.getSymbolicName(context, "type", baseType);
	
	//Object Generator Type
	String sObjGeneratorType = util.getActualNameForAEFData(context,"type_eServiceObjectGenerator");

	String sRevisionPattern ="*";
	String sVaultPattern ="*";
	String sOwnerPattern ="*";
	String sWhereExp = "";

	matrix.db.Query queryObj = new matrix.db.Query("");

	queryObj.open(context);
	queryObj.setBusinessObjectType(sObjGeneratorType);
	queryObj.setBusinessObjectName(sNamePattern);
	queryObj.setBusinessObjectRevision(sRevisionPattern);
	queryObj.setVaultPattern(sVaultPattern);
	queryObj.setOwnerPattern(sOwnerPattern);
	queryObj.setWhereExpression(sWhereExp);
	queryObj.setExpandType(false);

	BusinessObjectList busObjList = queryObj.evaluate(context);

	BusinessObjectItr autoNamerItr = new BusinessObjectItr(busObjList);
	BusinessObject objGenObj = null;
		
	Vector sortedRevList = new Vector(4);
	while(autoNamerItr.next())
	{
		objGenObj = autoNamerItr.obj();
		String rev = objGenObj.getRevision();
		sortedRevList.addElement(rev);
	}

	Collections.sort(sortedRevList);

	for(int i=0; i<sortedRevList.size(); i++)
	{
		String revision = (String)sortedRevList.elementAt(i);
		
		if (Integer.parseInt(sSeries) == i + 1) 
		{
			selected = "selected";
		}
	  String strTranslatedRev = _util.localizeAutoNameSeries(context,revision,baseType,language);
%>
                        <!--XSSOK-->
			<option value="<%=revision%>" <%= selected %>><%=strTranslatedRev%></option>
<%			
		selected = "";
	}
%>
		  </select>
		</td>
	  </tr>

	  <tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "CustomRevisionLevel") %></td>

<%
	String revision = "";
	Policy policy = new Policy(selectedPolicy);

	policy.open(context);
	revision = policy.getFirstInSequence();

	policy.close(context);
%>
		<td class="inputField"><input type="text" size="20" name="CustomRevLevel" value="<%= XSSUtil.encodeForHTMLAttribute(context , revision) %>" onFocus="" /></td>
	  </tr>

<% if(globalConfigObject.isAssignCADModelNameFromPart())
	{ 
%>

 <tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "PartName") %></td>
		<td class="inputField"><input type="text" readonly name="partName" size="20" />
		<input type="hidden" name="partId" value="" />
		<input type="button"  name="btn" value="..."  onClick="javascript:parent.showPartSearchDialog()"/>
		<!--XSSOK-->
		<input type="button"  name="btn" value="<%=sCreateNew%>" onClick="javascript:parent.showCreatePartDialog()" />
    	</td>
</tr>

<%
	} 
%>
	  <tr>
                <!--XSSOK-->
		<td class="label"><%= getI18NString(integSessionData, "FieldName", "Description") %></td>
		<td class="inputField"><textarea wrap="soft"  name="Description" rows="5" cols="40" ><%= XSSUtil.encodeForHTML(context , sDescription) %></textarea></td>
	  </tr>

<% if(globalConfigObject.isAssignCADModelNameFromPart())
	{ 
%>
	  <tr>
                <!--XSSOK-->
		<td class="label"><%= getI18NString(integSessionData, "FieldName", "Specification") %></td>
		<td class="inputField"><input type="text"  name="specification" size="20" readonly="readonly"></td>
	  </tr>
<%
	} 

	String vaultname = "eService Sample";

	String Args2[] = new String[2];
				Args2[0] = context.getUser();
				Args2[1] = "vault";
	String result = util.executeMQL(context, "print person $1 select $2", Args2);
	if(result.startsWith("true|"))
	{
		result	  = result.substring(result.indexOf("=")+1);
		vaultname = result.trim();
	}

	Vault vault = new Vault(vaultname);
	BusinessType busType = new BusinessType(templateType, vault);

	//Get the Attribute Type list
	AttributeTypeList attrTypeList = busType.getAttributeTypes(context);

	//get attribute info
	Map attrMap = FrameworkUtil.toMap(context, attrTypeList);
	//remove following attributes from the attrMap.
	attrMap.remove("IEF-StartDesignForm");
	attrMap.remove("IEFStartDesignJPO");
	attrMap.remove("IEF-StartDesignTemplateSites");
	attrMap.remove("Source");

	//add the map to session
	session.setAttribute("startDesignAttributeMap",attrMap);

	//retrieve and display all custom attributes
	java.util.Set keys = attrMap.keySet();
	Iterator itr = keys.iterator();
	StringBuffer sMandatoryAttributes = new StringBuffer("|");
	while (itr.hasNext())
	{
		Map valueMap    = (Map)attrMap.get((String)itr.next());
		String attrName = (String)valueMap.get("name");
		String labelClass = "label";

		// Check for admin property
		boolean isPropertyExists = util.isPropertyExistsOnAttribute(context, attrName, "mandatory", templateType);

		if(isPropertyExists == true)
		{
			labelClass = "labelRequired";
			sMandatoryAttributes.append(attrName).append("|");
		} 

		String strHtml = displayField(context, util, valueMap,"edit", session, "", "createForm", acceptLanguage);
		
		if(strHtml != null && !strHtml.equals(""))
		{
%>
	  <tr>
                <!--XSSOK-->
		<td class="<%= labelClass %>" width="40%"><%=getI18NString(integSessionData, "FieldName", attrName)%></td>
		<td class="inputField"><!--XSSOK-->
			<%= strHtml %>
		</td>
	  </tr>
<%
		}
	}
%>
         <!--XSSOK-->
	 <tr <%= defaultFolderHiddenHTMLContent %>>
	        <!--XSSOK-->
		<td class="label"><%= getI18NString(integSessionData, "FieldName", "Folder") %></td>
		<!--XSSOK-->
		<td class="inputField"><input type="text" readonly size="20" name="folder" value="<%=folderPath%>" />
		<!--XSSOK-->
		<input type="button"  name="btn" value="..." onClick="javascript:showFolderChooser()" <%=isdefaultFolderDisabled%> />&nbsp;
<%
	if(isdefaultFolderDisabled.equals("disabled") || !"".equals(defaultFolderHiddenHTMLContent))
	{
%>
                <!--XSSOK-->
		<%=getI18NString(integSessionData, "FieldName", "Clear")%>
<%
	}
	else
	{
%>
                <!--XSSOK-->
		<a href="#" onclick="javascript:clearSelectedFolder()"><%=getI18NString(integSessionData, "FieldName", "Clear")%></a>
<%
	}
%>
		</td>
	  </tr>
	  <tr>

	  <tr>
		<input type="hidden" name="mandatoryAttributes" value="<%=XSSUtil.encodeForHTMLAttribute(context ,sMandatoryAttributes.toString())%>">
		<input type="hidden" name="templateObjID" value="<%=XSSUtil.encodeForHTMLAttribute(context ,selectedTemplateObjID)%>">
		<input type="hidden" name="cadType" value="<%= XSSUtil.encodeForHTMLAttribute(context ,cadType) %>">
		<input type="hidden" name="source" value="<%= XSSUtil.encodeForHTMLAttribute(context ,source) %>">
		<input type="hidden" name="drawingNum" value="">
		<input type="hidden" name="autoName" value="">
		<input type="hidden" name="selectedSeries" value="">
		<input type="hidden" name="selectedType" value="">
		<input type="hidden" name="selectedPolicy" value="">
		<input type="hidden" name="folderId" value="<%=XSSUtil.encodeForHTMLAttribute(context ,folderId)%>">
		<!--XSSOK-->
		<input type="hidden" name="applyToChild" value="<%=applyToChild%>">
		<input type="hidden" name="isCheckoutRequired" value="<%=XSSUtil.encodeForHTMLAttribute(context ,isCheckoutRequired)%>">
		<input type="hidden" name="parentObjectId" value="<%=XSSUtil.encodeForHTMLAttribute(context ,parentObjectId)%>">
	 </tr>
	</table>
	</form>
</body>
</html>
