<%--  MCADRename.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--    Shows the server preferences for MCAD Integrations.//IR-578862

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.MCADIntegration.utils.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Set" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<script language="JavaScript">
function onSelectAutoRename(checked)
{

   if(checked != null && checked != 'undefined'
      && checked)
   {
      document.forms['rename'].newName.disabled = true;
      document.forms['rename'].newName.value = '';
   }
   else
   {
      document.forms['rename'].newName.disabled = false;
   }
}
</script>

<%
    MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
    Context context                             = integSessionData.getClonedContext(session);
    MCADMxUtil _util                            = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
String sRefreshFrame		=Request.getParameter(request,"refreshFrame");
    String sError                               = "";
    String sDesign                              = "";
    String sName                                = "";
    String sRev                                 = "";
    String sRevision                            = "";

    String sFamilyName                          = "";
    String sOriginalName                        = "";
    String sObjId                               = emxGetParameter(request, "busId");
    String integrationName                      = emxGetParameter(request, "integrationName");
    String sInstanceName                        = emxGetParameter(request, "instanceName");
    String objectLocker                         = "";
    String lockedStreamRevision                 = "";
    int priorityCounter                         = 1;
    Hashtable objectTypeTable                       = null;
    boolean isConnectedToBaseline               = false;

	String sTitle								= "";

    MCADLocalConfigObject localConfigObject     = integSessionData.getLocalConfigObject();
    MCADGlobalConfigObject _globalConfig        = integSessionData.getGlobalConfigObject(integrationName,context);
    MCADServerGeneralUtil _generalUtil          = new MCADServerGeneralUtil(context,integSessionData, integrationName);
    boolean isBatchProcessorForRenameEnabled    = _globalConfig.isBatchProcessorForRenameEnabled();

    boolean isObjectAndFileNameDifferent		= _globalConfig.isObjectAndFileNameDifferent();
    boolean renameFiles							= true;

    boolean bEnableAppletFreeUI = MCADMxUtil.IsAppletFreeUI(context);
    
    String unsupportedChars = _globalConfig.getNonSupportedCharacters();
    try
    {
        BusinessObject busObj = new BusinessObject(sObjId);
        busObj.open(context);
        String busType          = busObj.getTypeName();
        sName                   = busObj.getName();
        sRev                    = busObj.getRevision();
        String cadType          = _util.getCADTypeForBO(context,busObj);
        String objectTypeName   = _util.getSymbolicName(context, "type", "CAD Model");

        if(unsupportedChars == null || unsupportedChars.equals(""))
        {
			if(isObjectAndFileNameDifferent)
			{
				String entityType	= MCADNameValidationUtil.getTitleEntityTypeFromCadType(cadType, _globalConfig);
				unsupportedChars 	= MCADNameValidationUtil.getInvalidCharactersForEntityType(entityType, _globalConfig);
			}
			else
            unsupportedChars = MCADNameValidationUtil.getInvalidCharactersForCADType(cadType, _globalConfig);
        }

        if(_globalConfig.isTypeOfClass(cadType, MCADAppletServletProtocol.TYPE_INSTANCE_LIKE))
        {
			String formatName = _generalUtil.getFormatsForType(context, busType, cadType);
			FileList fileList = busObj.getFiles(context, formatName);
			if(fileList.isEmpty())
				renameFiles = false;
        }


        BusinessObjectList busList = null;

        //[NDM] start  OP6
        BusinessObject majorObj = null;
        String sMajorObjID = ""; 
        if(!_util.isMajorObject(context, sObjId))//_globalConfig.isMajorType(busType)) [NDM]
        {
            majorObj = _util.getMajorObject(context, busObj);

            majorObj.open(context);

            busList = majorObj.getRevisions(context);

           
            sRevision       = majorObj.getRevision();
            sMajorObjID     = majorObj.getObjectId();
            String localeLanguage = integSessionData.getLanguageName();
            sDesign          =   MCADMxUtil.getNLSName(context, "Type", majorObj.getTypeName(), "", "", localeLanguage);

            majorObj.close(context);
        }
        else
        {
        	majorObj = busObj;
            sRevision       = busObj.getRevision();
            sMajorObjID     = busObj.getObjectId();
	    	String localeLanguage = integSessionData.getLanguageName();
            sDesign          =   MCADMxUtil.getNLSName(context, "Type", busObj.getTypeName(), "", "", localeLanguage);

            busList = busObj.getRevisions(context);
        }
      //[NDM] End
        String [] objectId      = new String[busList.size()];

        for(int i =0 ; i < busList.size() ; i++)
        {
            BusinessObject allObj =  (BusinessObject)busList.get(i);
            objectId[i]             = allObj.getObjectId(context);
        }

        isConnectedToBaseline   = _util.isObjectConnectedToBaseline(context,objectId);

        if(cadType.equalsIgnoreCase("drawing"))
            objectTypeName      = _util.getSymbolicName(context, "type", "CAD Drawing");

        String objectGeneratorType  = _util.getActualNameForAEFData(context,"type_eServiceObjectGenerator");

        Vector typeList = new Vector();
        typeList.add(objectTypeName);
        typeList.add("");

        String [] packedTypes       = JPO.packArgs(typeList);
        String[] arguments          = new String[4];

        arguments[0]                = packedTypes[0];
        arguments[1]                = packedTypes[1];
        arguments[2]                = objectGeneratorType;

	String language = integSessionData.getResourceBundle().getLanguageName();
	arguments[3]				= language;

        Hashtable objectTypeListTable = (Hashtable)_util.executeJPO(context, "IEFGetAutoNameSeries", "getTypeNameAutoNameSeriesTable", arguments, Hashtable.class);

        objectTypeTable  =  (Hashtable) objectTypeListTable.get(objectTypeName);

        if(_globalConfig.isTypeOfClass(cadType, MCADAppletServletProtocol.TYPE_INSTANCE_LIKE))
        {
            
            BusinessObject familyObj= _generalUtil.getFamilyObjectForInstance(context, busObj);
            if(familyObj == null)
            {
                if(_util.isMajorObject(context, sObjId))//_globalConfig.isMajorType(busType)) [NDM] OP6
                {
                    BusinessObject instMinor = _util.getActiveMinor(context,busObj);
                    familyObj                = _generalUtil.getFamilyObjectForInstance(context, instMinor);
                }
                else
                {
                    BusinessObject instMajor = _util.getMajorObject(context,busObj);
                    familyObj                = _generalUtil.getFamilyObjectForInstance(context, instMajor);
                }
            }
            String attrTitle		= MCADMxUtil.getActualNameForAEFData(context, "attribute_Title");
            String sFamilyTitle = familyObj.getAttributeValues(context,attrTitle).getValue();
            if(null!=sFamilyTitle  && false==sFamilyTitle .trim().isEmpty()&& sFamilyTitle.contains(".")) {
            	sFamilyTitle = sFamilyTitle.substring(0,sFamilyTitle.lastIndexOf("."));
    		}
            sFamilyName     = familyObj.getName();
            sInstanceName   = (String)_generalUtil.getIndivisualInstanceName(sName,"",sFamilyName,sFamilyTitle).get(0);//IR-578862
            
        }

        //[NDM] start  OP6
       /* String sMajorObjID = "";      
        BusinessObject majorBusObject = _util.getMajorObject(context,busObj);
        if(majorBusObject == null)
        {
            majorBusObject = busObj;
            sRevision       = busObj.getRevision();
            sMajorObjID     = busObj.getObjectId();
	    	String localeLanguage = integSessionData.getLanguageName();
            sDesign          =   MCADMxUtil.getNLSName(context, "Type", busObj.getTypeName(), "", "", localeLanguage);
        }
        else
        {
            majorBusObject.open(context);
            sRevision       = majorBusObject.getRevision();
            sMajorObjID     = majorBusObject.getObjectId();
            String localeLanguage = integSessionData.getLanguageName();
            sDesign          =   MCADMxUtil.getNLSName(context, "Type", majorBusObject.getTypeName(), "", "", localeLanguage);
          
            majorBusObject.close(context);

        }*/
       // {NDM] End OP6
        sTitle			= _util.getAttributeValue(context, majorObj, MCADMxUtil.getActualNameForAEFData(context,"attribute_Title"));
        busObj.close(context);

        String [] args  = new String [2];
        args[0]         = sMajorObjID;
        args[1]         = request.getHeader("Accept-Language");

        String [] renameAccessInfo = (String[])_util.executeJPO(context, "IEFRenameAccess", "getRenameAccessInfo", args, String[].class);

        if(renameAccessInfo != null && renameAccessInfo[0].equalsIgnoreCase("false"))
            sError          = renameAccessInfo[1];
      }
    catch(Exception e)
    {
      sError = e.toString();
    }

    if(sInstanceName == null || sInstanceName.trim().length() == 0)
    {
        sInstanceName = "";
        sOriginalName = sName;
    }


    //Flag indicating whether the system is cas-sensitive or not
    boolean isSystemCaseSensitive = integSessionData.isSystemCaseSensitive();
%>

<html>
<head>
<title> Rename </title>

<link rel="stylesheet" href="./styles/emxIEFMiscUI.css" type="text/css">
<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript">

    var integrationName             = "<%=XSSUtil.encodeForJavaScript(context,integrationName)  %>";
	//XSSOK
    var isSystemCaseSensitive       = "<%= isSystemCaseSensitive %>";
    //XSSOK
    var unitSeparator               = "<%=MCADAppletServletProtocol.UNIT_SEPERATOR%>";
    //XSSOK
    var recordSeparator             = "<%=MCADAppletServletProtocol.RECORD_SEPERATOR%>";

<%
    if(sError != null && !sError.equals(""))
    {
%>
        alert("<%= XSSUtil.encodeForJavaScript(context, sError) %>");
        top.close();
<%
    }
%>

  function doneMethod()
  {
    /*Validate first; if validated then go ahead and send
    Rules:
        1. Should not be part of any baseline.
        2. Name cannot be the null.
        3. Name cannot be the same as the original one
        4. Name should not contain unsupported characters
    */
    <%
    if(isConnectedToBaseline)
    {
    %>
        //XSSOK
        alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CanntRenameBaselinedObject")%>");
        return;
    <%
    }
    %>

    var busId           = "<%=XSSUtil.encodeForJavaScript(context,sObjId)%>";
	var instanceName = "<%=XSSUtil.encodeForHTML(context,sInstanceName)%>";

    var origName   = document.rename.originalName.value;
    var newName    = document.rename.newName.value;
<%
    if(isBatchProcessorForRenameEnabled)
    {
%>
        var priority   = document.rename.priorityValue.options[document.rename.priorityValue.selectedIndex].value;
<%
    }
%>

    var isAutoName = document.rename.autoName.checked;
    var seriesName = "";
<%
    if(objectTypeTable.size() > 0)
    {
%>
        seriesName = document.rename.AutoNameList.options[document.rename.AutoNameList.selectedIndex].value;
<%
    }
%>
    if(!isAutoName)
    {
        newName = newName.replace( /^\s*/, "" );
        newName = newName.replace( /\s*$/, "" );

        //check 1
        if(newName.length==0)
        {
          //XSSOK
          alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.NameFieldCanNotBeBlank")%>");
          document.rename.newName.focus();
          return;
        }
        //check2
        if(isSystemCaseSensitive == "true" || isSystemCaseSensitive == "TRUE")
        {
            if(newName == origName)
            {
                //XSSOK
                alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.NameNotUnique")%>");
                document.rename.newName.focus();
                return;
            }
        }
        else
        {
            if(newName.toLowerCase(newName.toUpperCase()) == origName.toLowerCase(origName.toUpperCase()))
            {
                //XSSOK
                alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.NameNotUnique")%>");
                document.rename.newName.focus();
                return;
            }
        }

        //check3
	//XSSOK
        var badChars = "<%= unsupportedChars %>";

        var isNameValidForObject   = validateForBadChars(badChars, document.rename.newName.value);

        if (!isNameValidForObject)
        {
          //XSSOK
          alert("<%= integSessionData.getStringResource("mcadIntegration.Server.Message.AlertInValidChars") %>" + badChars + "<%= integSessionData.getStringResource("mcadIntegration.Server.Message.AlertRemoveInValidChars")%>");

          document.rename.newName.focus();
          return;
        }
    }
    else if(seriesName == "")
    {
        //XSSOK
        alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.AutoSeriesNameCannotBeBlank")%>");
        document.rename.newName.focus();
    }

    //Passed both the checks.
    //Build url and send it to the next jsp.
    var integrationFrame = getIntegrationFrame(this);

    //cannot go ahead if unable to locate integration frame.
    if( integrationFrame != null )
    {
        var parametersArray = new Array;
        parametersArray["busId"]            = busId;
        parametersArray["instanceName"]     = instanceName;
        parametersArray["Command"]          = "executeBrowserCommand";
	//XSSOK
        parametersArray["Action"]           = "<%=MCADGlobalConfigObject.FEATURE_RENAME%>";
        parametersArray["newName"]          = newName;
<%
        if(isBatchProcessorForRenameEnabled)
        {
%>
            parametersArray["priority"]         = priority;
<%
        }
%>

        parametersArray["IntegrationName"]  = integrationName;
        parametersArray["isAutoName"]       = "false";
        parametersArray["seriesName"]       = "";

        if(isAutoName)
        {
            parametersArray["isAutoName"]   = "true";
            parametersArray["seriesName"]   = seriesName;
        }

        var queryString     = getQueryString(parametersArray, unitSeparator, recordSeparator);

        if('<%=bEnableAppletFreeUI%>' == "true")
        	{
        	var renameDetails = "integrationName="+'<%=integrationName%>' + "&isAutoName=" + isAutoName + "&seriesName="+ seriesName+"&busId="+ busId+"&newName="+newName+"&instanceName="+instanceName;
    		var url = "../integrations/MCADRenameAppletFreePost.jsp";
    		url += "?" + renameDetails;
    		var http = emxUICore.createHttpRequest();
    		
    		http.onreadystatechange=function()
    		 {
    			if (http.readyState < 4)
    			 {
					document.forms['rename'].progress.src = "../common/images/utilProgressGraySmall.gif";
    			}
    			if (http.readyState == 4) 
    			{   
    				var response1 = http.responseText;
					document.forms['rename'].progress.src = "./images/utilSpace.gif";
    				alert(response1.trim());
					refreshParentFrame();
    				parent.window.close();
    			}
    		}
    		http.open("POST", url, true);
    		http.send();
    		}
        else
        	{
        var response        = integrationFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, "sendRequestToServerForBrowserCommands", queryString);

        response =  replaceAll(response, "~", " ");
        response =  replaceAll(response, "\n", "");
        response =  replaceAll(response,"&nbsp;"," ");
		var encodedString	= hexEncode(integrationName,response);
        document.UpdatePage.details.value=encodedString;
        document.UpdatePage.submit();

        var searchHiddenForm    = null;
        var searchForm          = null;

        if(null != top.opener.top && typeof top.opener.top != "undefined")
        {
            searchHiddenForm    = top.opener.top.document.forms['full_search_hidden'];
            searchForm          = top.opener.top.document.forms['full_search'];
        }

        var detailsDisplayFrame      = top.opener.top.findFrame(top.opener.top, "detailsDisplay");
        var structureBrowserFrame    = top.opener.top.findFrame(top.opener.top, "structure_browser");
        var appletReturnHiddenFrame  = top.opener.top.findFrame(top.opener.top, "appletReturnHiddenFrame");

        if(searchContentFrame)
            searchContentFrame.refreshSearchResultPage();
        else if(detailsDisplayFrame)
            refreshIndentedTable("detailsDisplay");
        else if(structureBrowserFrame)
            refreshIndentedTable("structure_browser");
        else if(appletReturnHiddenFrame)
            top.opener.parent.location.href = top.opener.parent.location.href;
    }
    }
    else
    {
        //XSSOK
        alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.IntegrationFrameNotFound")%>");
    }
  }

  function unloadModal()
  {
      if(top.opener && top.opener.top.modalDialog)
        top.opener.top.modalDialog = null;
  }

  function checkForUpperCase()
  {
      //If the object is of ProE type, convert string to upper case
      if(integrationName == "MxPRO" || integrationName == "MxCATIAV4")
      {
        var inputString = document.rename.newName.value;
        document.rename.newName.value = inputString.toUpperCase();
      }
  }
  function refreshParentFrame()
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
		
		if(refreshFrame.name == "content")
		{
			refreshFrame.location.href = refreshFrameURL;
							
		}
	}	
}
</script>
</head>

<body>
<table border="0" width="100%">
    <tr>
        <td>
                <form name="rename" action="javascript:parent.frames['contentPage'].doneMethod()" target="_top" method="post">

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
                <input type="hidden" name="originalName" value="<xss:encodeForHTMLAttribute><%=sOriginalName%></xss:encodeForHTMLAttribute>">
               <table border="0" width="100%">
                    <tr>
						<!--XSSOK-->
						<td nowrap></td>
						<td nowrap></td>
						<td><td nowrap align="right"><img src="./images/utilSpace.gif" name="progress"></p></td></td>
					</tr>
                    <tr>
                        <td>
                            <table border="0" width="100%">
	       		      <!--XSSOK-->
                              <tr><th width="100%"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.ObjectDetails")%></th></tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table border="0" width="70%">
                                <tr>
                                    <!--XSSOK-->
                                    <td width="30%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Design")%></b></td>
									<td width="70%"><%=XSSUtil.encodeForHTML(context,sDesign)%></td>
                                </tr>
                                <%
                                    if(!sInstanceName.equals(""))
                                    {
                                %>
                                <tr>
                                    <!--XSSOK-->
                                    <td width="30%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.InstanceName")%></b></td>
                                    <td width="70%"><%=XSSUtil.encodeForHTML(context,sInstanceName)%></td>
                                </tr>
                                <tr>
				    <!--XSSOK-->
                                    <td width="30%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.FamilyName")%></b></td>
                                    <td width="70%"><%=XSSUtil.encodeForHTML(context,sFamilyName)%></td>
                                </tr>
                                <%
                                    }
                                    else
                                    {
                                %>
                                <tr>
                                    <!--XSSOK-->
                                    <td width="30%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Name")%></b></td>
                                    <td width="70%"><%=XSSUtil.encodeForHTML(context,sName)%></td>
                                </tr>
                                <%
                                    }
                                %>
                                <tr>
                                    <!--XSSOK-->
                                    <td width="30%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Revision")%></b></td>
                                    <td width="70%"><%=XSSUtil.encodeForHTML(context,sRevision)%></td>
                                </tr>
      							<tr>
                                    <!--XSSOK-->
                                    <td width="30%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Title")%></b></td>
                                    <td width="70%"><%=XSSUtil.encodeForHTML(context,sTitle)%></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table border="0" width="100%">
			      <!--XSSOK-->
                              <tr><th width="100%"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.Rename")%></th></tr>
                            </table>

                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table border="0" width="100%">
							  <%
                              if(isObjectAndFileNameDifferent && renameFiles)
                              {
                              %>
                              <tr>
                              <td></td>
								<td align="left" style="font-size:10px;font-style:italic;color:#D00;">
							                <!--XSSOK-->
									<%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Message.EnterFileNameWithoutExtension")%>
								</td>
							  </tr>
							  <tr>
							        <!--XSSOK-->
								<td width="20%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.RenameFile")%></b></td>
							  <%
                              }
                              else
                              {
                              %>
                              <tr>
                                <!--XSSOK-->
                                <td width="20%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.RenameTo")%></b></td>
                              <%
                              }
                              %>
                                <td width="60%"><input type="text" name="newName" id="newName"onmouseout="javascript:checkForUpperCase()" onchange="javascript:checkForUpperCase()" onkeyup="javascript:checkForUpperCase()"></td>

                                <td width="1%"> <input type="checkbox" name="autoName" id="autoName" onClick="onSelectAutoRename(document.forms['rename'].autoName.checked); return true;"></td>
                                <!--XSSOK-->
                                <td width="15%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.AutoName")%></b></td>
                              </tr>
                              <%
                              if(isBatchProcessorForRenameEnabled)
                              {
                              %>
                              <tr>
			        <!--XSSOK-->
                                <td width="20%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Priority")%></b></td>
                                <td class = "checkPriority">
                                <select name="priorityValue" id ="priorityValue">
                                <%
                                    for(;priorityCounter<10; priorityCounter++)
                                    {
                                %>
                                    <option value= <xss:encodeForHTMLAttribute><%=priorityCounter%></xss:encodeForHTMLAttribute>><xss:encodeForHTML><%=priorityCounter%></xss:encodeForHTML></option>
                                <%
                                    }
                                %>
                                </select>
                                </td>
                            </tr>
                            <%
                              }
                            %>
                              <tr>
                                <!--XSSOK-->
                                <td width="20%"><b><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.AutonameSeries")%></b></td>
                                <td class="inputField">
                                    <select name="AutoNameList">
                            <%
									Set objectTypeValues = objectTypeTable.keySet();
									ArrayList objectTypeValuesList = new ArrayList(objectTypeValues);
									Collections.sort(objectTypeValuesList);

                                    for(int i=0; i<objectTypeValuesList.size(); i++)
                                    {
                                       String objectTypeListActualValue = (String)objectTypeValuesList.get(i);
										String objectTypeListDisplayValue = (String)objectTypeTable.get(objectTypeListActualValue);
                            %>
                                        <option value="<xss:encodeForHTMLAttribute><%=objectTypeListActualValue%></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%=objectTypeListDisplayValue%></xss:encodeForHTML></option>
                            <%
                                    }
                            %>
                                    </select>
                                </td>
                              </tr>
                              <tr><td>&nbsp;</td></tr>
                            </table>
                      </td>
                   </tr>
                </table>
            </form>
        </td>
      </tr>
      <tr>
        <td>
            <form name="UpdatePage" method="post" action="MCADUpdateWithMessage.jsp" target="_top" >

<%
boolean csrfEnabled1 = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
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

                <input type="hidden" name="busId" value="<%=XSSUtil.encodeForHTMLAttribute(context,sObjId)%>">
                <input type="hidden" name="instanceName" value="<%=XSSUtil.encodeForHTMLAttribute(context,sInstanceName)%>">
                <input type="hidden" name="refresh" value="true">
                <input type="hidden" name="instanceRefresh" value="true">
                <input type="hidden" name="details" value="">
                <input type="hidden" name="refreshmode" value="replace">
            </form>
        </td>
    </tr>
</table>
</body>
</html>

