<%--  IEFCreateDesignTemplateObjectContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*,com.matrixone.apps.common.*" %>
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

	private boolean attributeHasChoicesOnly(Context context, MCADMxUtil util, String attrName) throws Exception
    {
        boolean hasChoices	= false;
		String Args[]=new String[3];
		Args[0]=attrName;
		Args[1]= "range";
		Args[2]="~";
		String result = util.executeMQL(context, "print attribute $1 select $2 dump $3",Args);
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
	private String displayField(Context context, MCADMxUtil util, Map mapValue, String access, HttpSession session,
                                String sAttribParamName, String sFormName, String language) throws Exception 
	{
		//ATTRIBUTE_DETAILS_TYPE
		String strAttrType = (String)mapValue.get("type");
		//ATTRIBUTE_DETAILS_MULTILINE
		String strAttrMultiLine = (String)mapValue.get("multiline");
		//ATTRIBUTE_DETAILS_NAME
		String strAttrName = (String)mapValue.get("name");

		if("".equals(sAttribParamName) || null == sAttribParamName || "null".equals(sAttribParamName))
		{
			sAttribParamName = strAttrName;
		}
		
		//SEL_ATTRIBUTE_VALUE
		String strAttrValue = (String)mapValue.get("value");
		//ATTRIBUTE_DETAILS_CHOICES
		StringList strListChoices = (StringList)mapValue.get("choices");

		if("edit".equalsIgnoreCase(access)) 
		{
			StringBuffer strDisplayField;
			boolean hasChoices = attributeHasChoicesOnly(context, util, strAttrName);
			if(hasChoices && strListChoices != null && strListChoices.size() > 0 )
			{   
				strDisplayField = new StringBuffer(350);
				strDisplayField.append(" <select name=\"").append(sAttribParamName).append("\">");

				StringItr strItr = new StringItr(strListChoices);
				while(strItr.next())
				{
					if(strItr.obj().equals(strAttrValue)) 
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
			else if(strAttrType.equals("real") || strAttrType.equals("integer"))
			{
				strDisplayField = new StringBuffer(60);
				strDisplayField.append("<input type=\"text\" name=\"").append(sAttribParamName).append("\" value=\"").append(strAttrValue).append("\">");			

				return strDisplayField.toString();
			}
			else if(strAttrType.equals("timestamp"))
			{
				double iClientTimeOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
				Hashtable hashDateTime = new Hashtable();
				String strDate = "";
				if(strAttrValue != null && !"".equals(strAttrValue))
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
					strDisplayField.append(sFormName);
					strDisplayField.append(".");
					strDisplayField.append(java.net.URLEncoder.encode(sAttribParamName));
					strDisplayField.append(".value='';\">");
					strDisplayField.append(i18nNow.getI18nString("emxComponents.Common.Clear", "emxComponentsStringResource", language));
					strDisplayField.append("</a>");

				}
				
				return strDisplayField.toString();
			}
			if((strAttrMultiLine == null) || ("null".equalsIgnoreCase(strAttrMultiLine)) || ("".equals(strAttrMultiLine))) 
			{
				String Args[]=new String[2];
				Args[0]=strAttrName;
				Args[1]="|";
				String sResult = util.executeMQL(context, "print attribute $1 select multiline dump $2",Args);
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
			if("true".equals(strAttrMultiLine))
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
                if((sAttribParamName.equals(attModelType) || sAttribParamName.equals(attDesignatedUser))&& strAttrValue != null && strAttrValue.equals("Unassigned"))
                {
                    strDisplayField.append("<input type=\"text\" name=\"").append(sAttribParamName + "_dummy").append("\" value=\"").append(i18nNow.getI18nString("emxIEFDesignCenter.Common.Unassigned", "emxIEFDesignCenterStringResource", language)).append("\">");
                    strDisplayField.append("<input type=\"hidden\" name=\"").append(sAttribParamName).append("\" value=\"").append(i18nNow.getI18nString("emxIEFDesignCenter.Common.Unassigned", "emxIEFDesignCenterStringResource", language)).append("\">");
                }
                else
                {
				strDisplayField.append("<input type=\"text\" name=\"").append(sAttribParamName).append("\" value=\"").append(strAttrValue).append("\">");
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

	//TEAM solution specific 
	boolean isSolutionBased	        = MCADMxUtil.isSolutionBasedEnvironment(context);
			

	String cadType		   =Request.getParameter(request,"cadType");
	String integrationName =Request.getParameter(request,"integrationName");
			
	MCADLocalConfigObject localConfigObject	  = integSessionData.getLocalConfigObject();
	MCADGlobalConfigObject globalConfigObject = integSessionData.getGlobalConfigObject(integrationName,context);
        String unsupportedChars					  = globalConfigObject.getNonSupportedCharacters();
        String fileNameBadChars                   = "";
        String validateForFileName      = "false";
         if(unsupportedChars == null || unsupportedChars.equals(""))
         {
            validateForFileName    = "true";
			//Add regex to handle single and double quote
            unsupportedChars	   = MCADNameValidationUtil.getInvalidCharactersForCADType(cadType, globalConfigObject);
			unsupportedChars = unsupportedChars.replaceAll("'", "\\\\'");
			unsupportedChars = unsupportedChars.replaceAll("\"", "\\\\\"");
			
            fileNameBadChars       = MCADNameValidationUtil.getInvalidCharactersForEntityType(MCADAppletServletProtocol.ENTITY_FILE_NAME, globalConfigObject);
			fileNameBadChars = fileNameBadChars.replaceAll("'", "\\\\'");
			fileNameBadChars = fileNameBadChars.replaceAll("\"", "\\\\\"");
				
         }	

	
	MCADFolderUtil folderUtil				  = new MCADFolderUtil(context, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	String defaultFolderAttrName				= MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-Pref-IEF-DefaultFolder");
        String startDesignTemplateSiteAttrName      = MCADMxUtil.getActualNameForAEFData(context,"attribute_IEF-StartDesignTemplateSites");

	String isdefaultFolderDisabled				= "";
	String defaultFolderHiddenHTMLContent				= "";
	String folderTNR							= "";
	String folderPath							= "";
	String applyToChild							= "false";
	String folderId								=Request.getParameter(request,"workspaceFolderId");    
	if(folderId != null && !"".equals(folderId) && !"null".equals(folderId))
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

	String selectedTemplateType =Request.getParameter(request,"selectedTemplateType");
	if(selectedTemplateType == null || selectedTemplateType.equals("null") || selectedTemplateType.equals(""))
	{
		selectedTemplateType = "";
	}
	String selectedPolicy =Request.getParameter(request,"selectedPolicy");
	if(selectedPolicy == null || selectedPolicy.equals("null") || selectedPolicy.equals(""))
	{
		selectedPolicy = "";
	}
	String selectedVault =Request.getParameter(request,"selectedVault");
	if(selectedVault == null || selectedVault.equals("null") || selectedVault.equals(""))
	{
		selectedVault = "";
	}
	String name	=Request.getParameter(request,"name");
	if(name == null || name.equals("null") || name.equals(""))
	{
		name = "";
	}
	String autoName	=Request.getParameter(request,"autoName");
	if(autoName == null || autoName.equals("null") || autoName.equals(""))
	{
		autoName = "";
	}
	else if(autoName.equalsIgnoreCase("true")) 
	{
		autoName = "checked";
	}

	String template	=Request.getParameter(request,"TemplateFile");
	
	if(template == null || template.equals("null") || template.equals(""))
	{
		template = "";
	}

	String Args1[]=new String[1];
	Args1[0]="Site";
    String allSites = util.executeMQL(context, "List $1", Args1);
		
	if(allSites.startsWith("true|"))
	{
		allSites = allSites.substring(5);
	}

%>

<html>
<head>

<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIForm.css" type="text/css">
<script language="JavaScript" src="scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>



<script language="javascript">

function showFolderChooser()
{
	var url = "MCADFolderSearchDialogFS.jsp" + "?integrationName=<%=XSSUtil.encodeForJavaScript(context,integrationName)%>";
	showIEFModalDialog(url, 430, 400, true);
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

function selectVault()
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
	document.createForm.name.value = document.createForm.Name.value;
	document.createForm.autoName.value = document.createForm.AutoName.checked;
    document.createForm.autoNameList.value = document.createForm.AutoNameList.selectedIndex;
   	document.createForm.selectedTemplateType.value = document.createForm.TypeList.options[document.createForm.TypeList.selectedIndex].value;
	//XSSOK
	if(<%=isSolutionBased%>)
		document.createForm.selectedVault.value = document.createForm.VaultList.value;
	else
	document.createForm.selectedVault.value = document.createForm.VaultList.options[document.createForm.VaultList.selectedIndex].value;
	
	if(isPolicyChanged)
	{
		document.createForm.selectedPolicy.value = document.createForm.PolicyList.options[document.createForm.PolicyList.selectedIndex].value;
	}

        var url = "IEFCreateDesignTemplateObjectContent.jsp?integrationName=<%=XSSUtil.encodeForJavaScript(context,integrationName)%>&cadType=<%= XSSUtil.encodeForURL(context , cadType)%>";

	document.createForm.action = url;
    document.createForm.target = "";
    document.createForm.method = "post";
    document.createForm.submit();
}

function checkInput()
{
        //XSSOK
	var badChars = "<%=unsupportedChars%>";

	var isNameValid = validateForBadChars(badChars, document.createForm.Name.value);
    if(!isNameValid)
	{
                //XSSOK
		alert("<%= getI18NString(integSessionData, "Message", "AlertInValidChars") %>" + badChars + "<%= getI18NString(integSessionData, "Message", "AlertRemoveInValidChars")%>");

		document.createForm.Name.focus();
		return false;
    }
	if(document.createForm.AutoName.checked) 
	{
		if(document.createForm.Name.value != "") 
		{
                        //XSSOK
			alert("<%= getI18NString(integSessionData, "Message", "PickOnlyOne") %>");
			return false;
		}
    
		var AutoNameListValue = document.createForm.AutoNameList[document.createForm.AutoNameList.selectedIndex].value;
		if((AutoNameListValue == "None") || (AutoNameListValue == "Not Selected")) 
		{
                        //XSSOK
			alert("<%= getI18NString(integSessionData, "Message", "PickAutoNameSeries") %>");
			return false;
		}
    }
	else
	{
		if(document.createForm.Name.value == "") 
		{
                        //XSSOK
			alert("<%= getI18NString(integSessionData, "Message", "EnterObjectName") %>");

			document.createForm.Name.focus();
			return false;
		}
    }

	if(typeof document.createForm.InstanceAutoName != 'undefined')
	{
		if(document.createForm.InstanceName.value == "") 
		{
                        //XSSOK
			alert("<%= getI18NString(integSessionData, "Message", "EnterInstanceName") %>");

			document.createForm.InstanceName.focus();
			return false;
		}
		if(document.createForm.InstanceAutoName.checked)
		{
			var AutoNameListValue = document.createForm.AutoNameList[document.createForm.AutoNameList.selectedIndex].value;
			if((AutoNameListValue == "None") || (AutoNameListValue == "Not Selected")) 
			{
                                //XSSOK
				alert("<%= getI18NString(integSessionData, "Message", "PickAutoNameSeries") %>");
				return false;
			}
		}
	}

    
    document.createForm.Revision.value = parent.jsTrim(document.createForm.Revision.value);
    if(document.createForm.Revision.value == "") 
	{
        //XSSOK
        alert("<%= getI18NString(integSessionData, "Message" ,"RevisionNotSet") %>");

        document.createForm.Revision.focus();
        return false;
    }

	var templateValue = document.createForm.TemplateFile.value;
	if(templateValue == "") 
	{
       //XSSOK
       alert("<%= getI18NString(integSessionData, "Message" ,"TemplateFileNotSet") %>");
	   document.createForm.TemplateFile.focus();
       return false;
    }
	else
	{
              //XSSOK
              var doFileNameValidation = "<%=validateForFileName%>";
	      //XSSOK
              var  fileNameBadChars    = "<%=fileNameBadChars%>";
              if(doFileNameValidation == "true")
              {
                   //XSSOK
                   var arguments        = "<%=MCADAppletServletProtocol.ENTITY_FILE_NAME%>".concat("|").concat(templateValue);
		           var intFrame = getIntegrationFrame(this);

		           var integrationName = "<%=XSSUtil.encodeForJavaScript(context,integrationName)%>";
		           var isFileNameValid = intFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, "isValidNameForEntity", arguments);
		           if(isFileNameValid != "true")
		           {
                                        //XSSOK
					alert("<%= getI18NString(integSessionData, "Message", "AlertInValidCharsInFileName") %>" + fileNameBadChars );
					document.createForm.TemplateFile.focus();
					return false;
				   }
              }            

              document.createForm.templateFileWithPath.value = templateValue;
	}

	var mandatoryAttributes = document.createForm.mandatoryAttributes.value;
	
    if(parent.trimWhitespace(mandatoryAttributes) != '|')
    {
		for(var i=0; i < document.createForm.elements.length; i++)
		{
			var formFieldName = document.createForm.elements[i].name;
			var newFormFieldName = "|" + formFieldName + "|";

			var fieldIndex = mandatoryAttributes.indexOf(newFormFieldName, 0);
			if(fieldIndex > -1)
			{
				var formFieldValue = document.createForm.elements[i].value;
				formFieldValue = parent.trimWhitespace(formFieldValue);
				if(formFieldValue == '')
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
}

function autoNameChanged(isChecked)
{
	if(isChecked)
	{		
		document.createForm.InstanceNameForDesign.value = '';
	}
	else
	{
		document.createForm.InstanceNameForDesign.value=document.createForm.InstanceName.value;
	}
}

function copyAutoName()
{
	if(!document.createForm.InstanceAutoName.checked)
	{
		document.createForm.InstanceNameForDesign.value = document.createForm.InstanceName.value;	
	}
}

</script>
</head>
<body>

	<table border="0" cellpadding="0" cellspacing="0"  width="1%" align="center">
	        <!--XSSOK-->
		<tr><td class="requiredNotice" align="center" nowrap ><%= getI18NString(integSessionData, "Message", "FieldsInRedItalicsRequired") %></td></tr>
	</table>

	<form name="createForm" method="post" action="IEFCreateDesignTemplateObject.jsp" target="hiddenFrame">

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


	<input type="hidden" name="integrationName" value="<xss:encodeForHTMLAttribute><%=integrationName%></xss:encodeForHTMLAttribute>" />
	<table width="100%" border="0" cellspacing="2" cellpadding="5">
	  <tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "Type") %></td>
		<td class="inputField">
		  <select name="TypeList" onChange="javaScript:selectType()">
<%
	Vector mappedTemplateTypes = globalConfigObject.getTemplateTypesForCADType(cadType);
	String language = integSessionData.getResourceBundle().getLanguageName();

	MCADMxUtil _util                            = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	if(mappedTemplateTypes != null && mappedTemplateTypes.size() > 0 )
	{	
		if(selectedTemplateType.equals(""))
		{
			selectedTemplateType = (String)mappedTemplateTypes.elementAt(0);
		}

		for(int i=0; i<mappedTemplateTypes.size(); i++)
		{
			String mappedTemplateType = (String)mappedTemplateTypes.elementAt(i);
			if(mappedTemplateType.equals(selectedTemplateType))
			{
%>
                <!--XSSOK-->
				<option value="<%= XSSUtil.encodeForHTML(context,mappedTemplateType) %>" selected><%= MCADMxUtil.getNLSName(context, "Type",mappedTemplateType, "", "", acceptLanguage) %></option>
<%
			}
			else
			{
%>
                <!--XSSOK-->
				<option value="<%= XSSUtil.encodeForHTML(context,mappedTemplateType) %>"><%= MCADMxUtil.getNLSName(context, "Type",mappedTemplateType, "", "", acceptLanguage) %></option>
<%
			}
		}
	}
%>
		  </select>
		</td>
	  </tr>

<tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "Name") %></td>
		<td class="inputField">
		<input type="text" size="20" name="Name" value="<%= XSSUtil.encodeForHTMLAttribute(context , name) %>" />
		<!--XSSOK-->
		<input type="checkbox" name="AutoName" <%= XSSUtil.encodeForHTMLAttribute(context , autoName) %> /><%= getI18NString(integSessionData, "FieldName", "AutoName") %>
		</td>
	  </tr>
	  <%
	  
	  boolean isFamilyLike = globalConfigObject.isTypeOfClass(cadType,MCADAppletServletProtocol.TYPE_FAMILY_LIKE);	  
	  String isUniqueInstanceName = "";
	  String isAutoNameSelected	  = "";
	  if(isFamilyLike)
	  {
		  if(globalConfigObject.isObjectAndFileNameDifferent())
		  {
			 isUniqueInstanceName = "checked onclick=\"return false\" onkeydown=\"return false\"";	
			 isAutoNameSelected ="disabled";
		  }
		  if(!globalConfigObject.isObjectAndFileNameDifferent() && !globalConfigObject.isUniqueInstanceNameInDBOn())
		  {
				isUniqueInstanceName = "checked onclick=\"return false\" onkeydown=\"return false\"";	
				 isAutoNameSelected ="disabled";
		  }	 
	  %>
	  	<tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "InstanceNameinTemplate") %></td>
		<td class="inputField">
		<input type="text" size="20" name="InstanceName" onmouseout="javascript:copyAutoName()" onchange="javascript:checkForUpperCase()" onkeyup="javascript:copyAutoName()" value="<%= name %>" />		
		</td>
	  </tr>
	<tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "InstanceName") %></td>
		<td class="inputField">
		<!--XSSOK-->
		<input type="text" <%=isAutoNameSelected%> size="20" name="InstanceNameForDesign" disabled value="<%= name %>" />
		<!--XSSOK-->
		<input type="checkbox" <%=isUniqueInstanceName%> onClick="javascript:autoNameChanged(this.checked)" name="InstanceAutoName" <%=XSSUtil.encodeForHTMLAttribute(context , autoName) %> /><%= getI18NString(integSessionData, "FieldName", "AutoName") %>
		</td>
	  </tr>

<%
	}
	String selected = "";
	String autoNameList =Request.getParameter(request,"autoNameList") ;
	if(autoNameList == null || autoNameList.equals("null") || autoNameList.equals("")) 
	{
		autoNameList = "0";
	}
%>		
	  <tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "AutonameSeries") %></td>
		<td class="inputField">
		  <select name="AutoNameList" onChange="">
<%
	if(Integer.parseInt(autoNameList) == 0) 
	{
		selected = "selected";
	}
%>
                        <!--XSSOK-->
			<option value="None" <%= selected %>><%= getI18NString(integSessionData, "FieldName", "NotSelected") %></option>
<%		
	selected = "";
	//Get all the objects of type eService Object Generator for base type of the selected template type and get their revisions
	
	String baseType		= util.getBaseType(context, selectedTemplateType);
	String sNamePattern = util.getSymbolicName(context, "type", baseType);

	String sObjGeneratorType = util.getActualNameForAEFData(context,"type_eServiceObjectGenerator");
	

	String sRevisionPattern = "*";
	String sVaultPattern    = "*";
	String sOwnerPattern    = "*";
	String sWhereExp        = "";

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

	BusinessObjectItr autoNameItr = new BusinessObjectItr(busObjList);
	BusinessObject objGenObj      = null;
		
	Vector sortedRevList = new Vector(4);
	while(autoNameItr.next())
	{
		objGenObj  = autoNameItr.obj();

		String rev = objGenObj.getRevision();
		sortedRevList.addElement(rev);
	}	

	Collections.sort(sortedRevList);
	String [] arrRev = null;
	String revString = "";
	String translatedRev = "";

	for(int i=0; i<sortedRevList.size(); i++)
	{
		String rev = (String)sortedRevList.elementAt(i);
		String strTranslated = _util.localizeAutoNameSeries(context,rev,baseType,language);

		if(Integer.parseInt(autoNameList) == i + 1) 
		{
			selected = "selected";
		}
%>
                        <!--XSSOK-->
			<option value="<%= rev %>" <%= selected %>><%= strTranslated %></option>
<%			
		selected = "";
	}
%>
		  </select>
		</td>
	  </tr>

	  <tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "Policy") %></td>
		<td class="inputField">
		  <select name="PolicyList" onChange="javaScript:selectPolicy()">
<%
	String selectedMxType	= null;
	Vector defaultPolicies  = null;
	Vector mappedMxTypes	= globalConfigObject.getMappedBusTypes(cadType);

if(mappedTemplateTypes != null && mappedTemplateTypes.size() > 0 )
{
	selectedMxType = (String)mappedTemplateTypes.elementAt(0);
	defaultPolicies = globalConfigObject.getPolicyListForType(selectedMxType);
}
if(defaultPolicies == null)
{
	if(mappedMxTypes!=null && mappedMxTypes.size()>0 )
		selectedMxType = (String)mappedMxTypes.elementAt(0);
	defaultPolicies = globalConfigObject.getPolicyListForType(selectedMxType);
}
		
	String designPolicy    = (String)defaultPolicies.firstElement();

	String vaultname = "eService Sample";
	String Args[] = new String[1];
	Args[0] = context.getUser();
	String result = util.executeMQL(context, "print person $1 select vault",Args);
	if(result.startsWith("true|"))
	{
		result	  = result.substring(result.indexOf("=")+1);
		vaultname = result.trim();
	}			
	Vault vault	  = new Vault(vaultname);
	
	BusinessType busType  = new BusinessType(selectedTemplateType, vault);
	busType.open(context);

	if(selectedPolicy==null || selectedPolicy.equals(""))
	{
			selectedPolicy = designPolicy;
	}
	for(int i=0; i<defaultPolicies.size(); i++)
	  {
		String policy = (String)defaultPolicies.elementAt(i);
		if(policy.equals(selectedPolicy))
		  {
%>
                        <!--XSSOK-->
			<option value="<%=policy %>" selected><%=MCADMxUtil.getNLSName(context, "Policy",policy, "", "", acceptLanguage) %>
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
%>
		  </select>
		</td>
	  </tr>

	  <tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "Vault") %></td>
		<td class="inputField">
			<%
				if(isSolutionBased)
				{
			%>
                                        <!--XSSOK-->
					<input type="text" size="20" name="VaultList" value="<%= vaultname %>"  readonly />
					  
				<%
				}
				else
					{

				%>
		  <select name="VaultList" onChange="javaScript:selectVault()">
<%
						String personCompanyId = PersonUtil.getUserCompanyId(context);
						String allVaults = new Company(personCompanyId).getAllVaults(context);
						StringList vaultList = FrameworkUtil.split(allVaults,",");

						Iterator itr1 = vaultList.iterator();
						
						if(itr1.hasNext())
						{
							if(selectedVault.equals(""))
							{
								selectedVault = vaultname;
							}
	
							while(itr1.hasNext())
        						{
								String vlt = (String)itr1.next();
			
								if(vlt.equals(selectedVault))
								{
					%>
									<option value="<xss:encodeForHTMLAttribute><%= vlt %></xss:encodeForHTMLAttribute>" selected><xss:encodeForHTML><%= vlt %></xss:encodeForHTML>
					<%
								}
								else
								{
					%>
									<option value="<xss:encodeForHTMLAttribute><%= vlt %></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%= vlt %></xss:encodeForHTML>
					<%
								}
							}
						}
					%>
				 </select>
					
				<%
					}
				%>
			</td>
		 </tr>

		<tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "Revision") %></td>
		<%
			Policy policy = new Policy(selectedPolicy);

			policy.open(context);
			String revision = policy.getFirstInSequence();
			policy.close(context);
		%>
		<td class="inputField"><input type="text" size="20" name="Revision" value="<%= revision %>" onFocus="" /></td>
	  </tr>

<tr>
                <!--XSSOK-->
		<td class="labelRequired"><%= getI18NString(integSessionData, "FieldName", "TemplateFile") %></td>
		<td class="inputField">
		<!--XSSOK-->
		<input type="file" name="TemplateFile"  value="<%= XSSUtil.encodeForHTMLAttribute(context , template) %>" /></td>
	  </tr>
	  <tr>
                <!--XSSOK-->
		<td class="label"><%= getI18NString(integSessionData, "FieldName", "Description") %></td>
		<td class="inputField"><textarea wrap="soft"  name="Description" rows="5" cols="40" ></textarea></td>
	  </tr>
	   <tr>
                <!--XSSOK-->
		<td class="label"><%= getI18NString(integSessionData, "FieldName", "Site") %></td>
		<td class="inputField"><SELECT  size="6" multiple name="Sites" >
		<% 
		StringTokenizer rangeValuesSt = new StringTokenizer(allSites, "\n");
		
        while(rangeValuesSt.hasMoreTokens()){
        String rangeValueToken = rangeValuesSt.nextToken();
		
		%>
		<OPTION ><%=rangeValueToken%></OPTION>

		<%
		}

		%>

</SELECT></td>
	  </tr>
<%
	//Get the Attribute Type list
	AttributeTypeList attrTypeList = busType.getAttributeTypes(context);

	busType.close(context);

	//get attribute info
	Map attrMap = FrameworkUtil.toMap(context, attrTypeList);
	attrMap.remove("Source");
	attrMap.remove(startDesignTemplateSiteAttrName);
	
	//add the map to session
	session.setAttribute("attributeMap", attrMap);

	StringBuffer sMandatoryAttributes = new StringBuffer("|");

	//retrieve and display all custom attributes
	java.util.Set keys = attrMap.keySet();
	
	Iterator itr = keys.iterator();
	while(itr.hasNext())
	{
		Map valueMap    = (Map)attrMap.get((String)itr.next());
		String attrName = (String)valueMap.get("name");

		String labelClass = "label";

		// Check for admin property
		boolean isPropertyExists = util.isPropertyExistsOnAttribute(context, attrName, "mandatory", selectedTemplateType);

		if(isPropertyExists == true)
		{
			labelClass = "labelRequired";
			sMandatoryAttributes.append(attrName).append("|");
		} 

        String strHtml = displayField(context, util, valueMap, "edit", session, "", "createForm", acceptLanguage);
		
		if(strHtml != null && !strHtml.equals(""))
		{
%>
	  <tr>
                <!--XSSOK-->
		<td class="<%= labelClass %>" width="40%"><%=getI18NString(integSessionData, "FieldName", attrName)%></td>
		<td class="inputField">
                <!--XSSOK CAUSED REG-->
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
		<td class="inputField"><input type="text" size="20" readonly="readonly" name="folder" value="<%=folderPath%>" />
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

		<input type="hidden" name="mandatoryAttributes" value="<%= XSSUtil.encodeForHTML(context,sMandatoryAttributes.toString()) %>">
		<input type="hidden" name="cadType" value="<xss:encodeForHTMLAttribute><%= cadType %></xss:encodeForHTMLAttribute>">
		<input type="hidden" name="selectedTemplateType" value="">
		<input type="hidden" name="selectedPolicy" value="">
		<input type="hidden" name="selectedVault" value="">
		<input type="hidden" name="name" value="">
		<input type="hidden" name="autoName" value="">
		<input type="hidden" name="autoNameList" value="">
		<input type="hidden" name="folderId" value="<xss:encodeForHTMLAttribute><%=folderId%></xss:encodeForHTMLAttribute>">
		<!--XSSOK-->
		<input type="hidden" name="applyToChild" value="<%=applyToChild%>">
		<input type="hidden" name="templateFileWithPath" value="">

		
	 </tr>
	</table>
	</form>
</body>
</html>

