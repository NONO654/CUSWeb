<%-- supplierDocumentCheckinDialogCode.inc - used for Checkin of file into Document Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsCheckinDialogCode.inc.rca 1.36 Wed Oct 22 16:18:58 2008 przemek Experimental przemek $"
--%>
<%@include file = "emxComponentsCheckin.inc"%>

<%
    Document document = (Document)DomainObject.newInstance(context, DomainConstants.TYPE_DOCUMENT);
//  Define variables for request parameters and some global
//  required variables.
    StringList usedParamList = new StringList();
    StringList policies = new StringList(5);
    StringList formats = new StringList(5);
    MapList policyList = new MapList();
    String defaultPolicy = document.POLICY_DOCUMENT;
    String defaultFormat = document.FORMAT_GENERIC;
    FormatList formatList = new FormatList();
    String format = document.FORMAT_GENERIC;;

    String defaultTitle = "";
    String strDescription = "";

//  Reading request parameters and storing into variables
    String parentId = emxGetParameter(request, "parentId");
    String objectId = emxGetParameter(request, "objectId");

    String showDescription = emxGetParameter(request, "showDescription");
    String showType = emxGetParameter(request, "showType");
    String defaultAliasType = emxGetParameter(request, "defaultAliasType");
    String defaultAliasPolicy = emxGetParameter(request, "defaultAliasPolicy");
    String defaultType = emxGetParameter(request, "defaultType");
    String showFormat = emxGetParameter(request, "showFormat");
    String showAction = emxGetParameter(request, "showAction");
    String showPolicy = emxGetParameter(request, "showPolicy");
    String showReason = emxGetParameter(request, "showReason");
    String showTitle = emxGetParameter(request, "showTitle");
    String showName = emxGetParameter(request, "showName");
    String showAccessType = emxGetParameter(request, "showAccessType");
    String objectAction = emxGetParameter(request, "objectAction");
    String parentRelName = emxGetParameter(request, "parentRelName");
    String appName = emxGetParameter(request, "appName");
    String appDir = emxGetParameter(request, "appDir");
    String unlock = emxGetParameter(request, "unlock");
    String allowFileNameChange = emxGetParameter(request, "allowFileNameChange");

    String oldFileName = emxGetParameter(request, "oldFileName");
    String oldFormat = emxGetParameter(request, "format");
    String defaultObjectAction = emxGetParameter(request, "append");


    String showFolder = emxGetParameter(request, "showFolder");
    String folderURL = emxGetParameter(request, "folderURL");
    String strFolderName = "";
    String strFolderId = "";

    String store = emxGetParameter(request, "store");
    int noOfFiles = 1;
    String targetPage = "/"+ appDirectory +"/emxComponentsCheckinSuccess.jsp";
    String errorPage = "/"+ appDirectory +"/emxComponentsError.jsp";
    String processPage = "/"+ appDirectory +"/emxComponentsCheckinProcess.jsp";

//  Validating the request parameter values and setting to defaults
//  if not defined in request
    if ( oldFileName == null || "null".equals(oldFileName) )
    {
        oldFileName = "";
    } else if ( UINavigatorUtil.isNS(context, request) ) {
        oldFileName = ServletUtil.decodeURL(emxGetParameter(request, "oldFileName"));
    }
    boolean isFormatSupplied = false;

    if ( oldFormat == null || "".equals(oldFormat) || "null".equals(oldFormat) )
    {
        oldFormat = format;
    } else {
        isFormatSupplied = true;
    }
    if ( defaultObjectAction == null || "".equals(defaultObjectAction) || "null".equals(defaultObjectAction) )
    {
        defaultObjectAction = "false";
    }
    if ( allowFileNameChange == null || "".equals(allowFileNameChange) || "null".equals(allowFileNameChange) )
    {
        allowFileNameChange = "false";
    }
    if ( store == null || store.equals("") )
    {
        store = com.matrixone.apps.common.Person.getPerson(context).getInfo(context, DomainConstants.SELECT_COMPANY_STORE);
    }

    if (unlock == null || unlock.equals("") )
    {
        unlock = "true";
    }
    if (showDescription == null || showDescription.equals("") )
    {
        showDescription = "false";
    }
    if ( showType == null || showType.equals("") )
    {
        showType = "false";
    }
    if ( showName == null || showName.equals("") )
    {
        showName = "false";
    }
    if ( defaultAliasType == null || defaultAliasType.equals("") )
    {
        defaultAliasType = "type_Document";
    }
    if (defaultAliasPolicy != null && !"".equals(defaultAliasPolicy))
    {
       defaultPolicy = PropertyUtil.getSchemaProperty(context,defaultAliasPolicy);
    }
    if ( defaultType == null || defaultType.equals("") )
    {
        defaultType = PropertyUtil.getSchemaProperty(context,defaultAliasType);
    }
    if (showFormat == null || showFormat.equals("") )
    {
        showFormat = "generic";
    }
    if (showAction == null || showAction.equals("") || "null".equals(showAction))
    {
        showAction = "false";
    }
    if (showFolder == null || showFolder.equals("") )
    {
        showFolder = "false";
    }

    if ( showPolicy == null || showPolicy.equals("") )
    {
        showPolicy = "false";
    }
    if ( showReason == null )
    {
        showReason = "false";
    }
    if (showTitle == null || showTitle.equals("") )
    {
        showTitle = "false";
    }
    if (appName == null )
    {
        appName = "";
    }

    if (objectAction == null )
    {
        objectAction = "";
    }

    String fileName = "";
    String policyStore = "";
// Get object details if object id is passed in..
// if not get details of formats and polices from type
    if ( objectId != null && !objectId.equals("") )
    {
        document.setId(objectId);

        SelectList selectList = new SelectList();
        selectList.add(document.SELECT_DESCRIPTION);
        selectList.add(document.SELECT_TYPE);
        selectList.add(document.SELECT_TITLE);
        selectList.add(document.SELECT_POLICY);
        selectList.add(document.SELECT_FILE_NAME);

        selectList.add(document.SELECT_FOLDER_NAME);
        selectList.add(document.SELECT_FOLDER_ID);
        Map mapDocumentInfo = document.getInfo(context,selectList);
        strDescription = (String)mapDocumentInfo.get(document.SELECT_DESCRIPTION);
        defaultTitle = (String)mapDocumentInfo.get(document.SELECT_TITLE);
        defaultType = (String)mapDocumentInfo.get(document.SELECT_TYPE);

        defaultPolicy = (String)mapDocumentInfo.get(document.SELECT_POLICY);
        String command = "print Policy '"+ defaultPolicy + "' select store dump |;";
        policyStore = MqlUtil.mqlCommand(context,command);

        StringList strFolderNameList = (StringList)mapDocumentInfo.get(document.SELECT_FOLDER_NAME);
        if (strFolderNameList != null && strFolderNameList.size() > 0 )
        {
            strFolderName = (String)strFolderNameList.get(0);
        }

        StringList strFolderIdList   = (StringList)mapDocumentInfo.get(document.SELECT_FOLDER_ID);
        if (strFolderIdList != null && strFolderIdList.size() > 0 )
        {
            strFolderId = (String)strFolderIdList.get(0);
        }

        defaultFormat = document.getDefaultFormat(context);
        formatList = document.getFormats(context);
        StringList fileNames = (StringList)mapDocumentInfo.get(document.SELECT_FILE_NAME);
        if (fileNames != null && fileNames.size() > 0 )
        {
            fileName = (String)fileNames.get(0);
        }
    } else {
        objectId = "";
        policyList = mxType.getPolicies(context,defaultType,true);
        Iterator itr = policyList.iterator();
        while( itr.hasNext() )
        {
            Map m = (Map)itr.next();
            if (policyStore!= null && policyStore.equals("") )
            {
                policyStore = (String)m.get("store");
            }
            policies.addElement((String)m.get("name"));
            StringItr formatItr = new StringItr((StringList) m.get("formats"));
            while( formatItr.next() )
            {
                format = formatItr.obj();
                if ( !formats.contains(format) )
                {
                    formats.addElement(format);
                }
            }
        }
    }

    if ( "updateVersion".equals(objectAction) )
    {
        defaultTitle = oldFileName;
    }
    if ( store != null && (!(store.trim()).equals("")) )
    {
        store = PropertyUtil.getSchemaProperty(context,store);
    } else if (policyStore == null || (policyStore.trim().equals("")) ) {
        store = PropertyUtil.getSchemaProperty(context,"store_STORE");
    } else {
        store = policyStore;
    }
    Map checkinURLMap = DocumentUtil.getFCSURLInfo(context,store.trim(),noOfFiles,processPage,targetPage,errorPage,request,response);
    String checkinURL = (String)checkinURLMap.get("action");
    String ticketStr = (String)checkinURLMap.get("ticket");
    String jobTicket = (String)checkinURLMap.get("jobTicket");
    String failurePageName = (String)checkinURLMap.get("failurePageName");
    String failurePageValue = (String)checkinURLMap.get("failurePageValue");

  String error = (String)session.getValue("error.message");
  if (error != null) {
%>
      &nbsp;
      <table width="90%" border="0"  cellspacing="0" cellpadding="3"  class="formBG" align="center" >
        <tr >
          <td class="errorHeader"><%=i18nNow.getI18nString("emxFramework.Error.Header","emxUIFrameworkStringResource",request.getHeader("Accept-Language"))%></td>
        </tr>
        <tr align="center">
          <!-- //XSSOK -->
          <td class="errorMessage" align="center"><%=error%></td>
        </tr>
      </table>
<%
    session.removeValue("error.message");
  }
%>
<script language="javascript">
  function  folderlist() {
    emxShowModalDialog('<%=XSSUtil.encodeURLwithParsing(context, folderURL)%>',575,575);
  }

  function startProgressBar() {
    document.progress.src = "../common/images/utilProgressBlue.gif";
  }

  function stopProgressBar(status, message) {
    document.progress.src = "../common/images/utilSpacer.gif";

    if(status == "true") {
      alert(message);
      window.closeWindow();
      parent.window.getWindowOpener().parent.location.reload();
    } else {
      alert(message);
    }
  }

  function checkinFile() {

    var field=document.checkinForm.title;
  	badChars=checkForNameBadChars(field,true);

<%
    if ( showTitle.equalsIgnoreCase("required") )
    {
%>
    if ( document.checkinForm.title.value == "" ) {
      document.checkinForm.title.focus();
      alert ("<emxUtil:i18nScript localize='i18nId'>emxComponents.Common.TitleError</emxUtil:i18nScript>");
      return;
    }
<%
    }
%>
<%
    if ( showDescription.equalsIgnoreCase("required") )
    {
%>
    if ( document.checkinForm.description.value == "" ) {
      document.checkinForm.description.focus();
      alert ("<emxUtil:i18nScript localize='i18nId'>emxComponents.Common.FillDescription</emxUtil:i18nScript>");
      return;
    }
<%
    }
%>
  	if ((badChars).length != 0)	{
  		msg ="<emxUtil:i18nScript localize='i18nId'>emxComponents.Alert.InvalidChars</emxUtil:i18nScript>";
  		msg += badChars;
  		//msg += "<emxUtil:i18nScript localize='i18nId'>emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript>";
  		//msg +=document.checkinForm.title.name;
  		//msg += " "+"<emxUtil:i18nScript localize='i18nId'>emxComponents.Alert.Field</emxUtil:i18nScript>";
  		alert(msg);
  		return;
  	}

  	var maxLength= <%=FrameworkProperties.getProperty(context,"emxComponents.MAX_FIELD_LENGTH")%>;
  		if (!isValidLength(field.value,0,maxLength)){
  		var msg = "<emxUtil:i18nScript localize='i18nId'>emxComponents.Alert.checkLength</emxUtil:i18nScript>";
  		msg += ' ' + maxLength + ' ';
  		field.focus();
  		alert(msg);
  		return ;
  	}

	var field=document.checkinForm.description;
	badChars=checkForBadChars(field);

  	if ((badChars).length != 0)	{
		msg ="<emxUtil:i18nScript localize='i18nId'>emxComponents.Alert.InvalidChars</emxUtil:i18nScript>";
		msg += badChars;
		//msg += "<emxUtil:i18nScript localize='i18nId'>emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript>";
		//msg +=document.checkinForm.title.name;
		//msg += " "+"<emxUtil:i18nScript localize='i18nId'>emxComponents.Alert.Field</emxUtil:i18nScript>";
		alert(msg);
		return;
	}

    var title = document.checkinForm.title.value;
    var fileName = document.checkinForm.fileName.value;

    tempFileName = document.checkinForm.file.value;

    var fileSep = "\\";

    if (isUnix || isMac) {
        fileSep = "/";
    }

    // In Mac, Netscape 7.0 and less, file separator is :
    // In Mac, Netscape 7.1 and above, file separator is /
    // basically in Mac / Netscape look for :, if not found look for /
    if ( isMac && isMinMoz1)
    {
      fileSep = ":"
      slIndex = tempFileName.lastIndexOf(fileSep);
      if(slIndex == -1)
      {
        fileSep = "/"
      }
    }
    slIndex = tempFileName.lastIndexOf(fileSep);
    tempFileName = tempFileName.substring(slIndex+1,tempFileName.length);

    // File Name can not have special characters
    var apostrophePosition = tempFileName.indexOf("'");
    var hashPosition = tempFileName.indexOf("#");
    var dollarPosition = tempFileName.indexOf("$");
    var atPosition = tempFileName.indexOf("@");
    var andPosition = tempFileName.indexOf("&");
    var percentPosition = tempFileName.indexOf("%");

    if ( apostrophePosition != -1 || hashPosition != -1 || dollarPosition != -1 || atPosition != -1 || andPosition != -1  || percentPosition != -1){
      alert ("<emxUtil:i18nScript localize='i18nId'>emxComponents.Common.InvalidFileName</emxUtil:i18nScript>");
      document.checkinForm.file.focus();
      return;
    }

    if(document.checkinForm.file.value == "") {
      document.checkinForm.file.focus();
      alert ("<emxUtil:i18nScript localize='i18nId'>emxComponents.Common.SelectFile</emxUtil:i18nScript>");
      return;
    }
    else{
	    <% 
            if(objectAction.equals("Image")) { 
        %>
	       var imgFileName = document.checkinForm.file.value;
	       var imgFileType = imgFileName.substring(imgFileName.lastIndexOf(".")+1);
	       var imgAllowedFormats = "<%=FrameworkProperties.getProperty( context, "emxComponents.ImageManager.2DImageFormats" )%>";
	       if ((imgAllowedFormats.indexOf(imgFileType)) == -1){
	           alert ("<emxUtil:i18nScript localize='i18nId'>emxComponents.Image.NotSupportedFormat</emxUtil:i18nScript>" + imgAllowedFormats);
	           return;
	       }
       <% 
           } 
       %>
    }
<%
    if ( showType.equalsIgnoreCase("required") )
    {
%>
    if ( document.checkinForm.type.value == "" ) {
      document.checkinForm.type.focus();
      alert ("<emxUtil:i18nScript localize='i18nId'>emxComponents.Common.TypeError</emxUtil:i18nScript>");
      return;
    }
<%
    }
%>
<%
    if ( showAction.equalsIgnoreCase("true") )
    {
%>
      if ( document.checkinForm.append[1].checked && !confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.ConfirmReplace</emxUtil:i18nScript>")) {
        return;
      }
<%
    }
%>
<%
    if ( showName.equalsIgnoreCase("required") )
    {
%>
    if ( document.checkinForm.name.value == "" ) {
      document.checkinForm.name.focus();
      alert ("<emxUtil:i18nScript localize='i18nId'>emxComponents.Common.NameError</emxUtil:i18nScript>");
      return;
    }
<%
    }
%>

<%
    if ( showFolder.equalsIgnoreCase("true") )
    {
%>
    if ( document.checkinForm.txtWSFolder.value == "" ) {
      document.checkinForm.txtWSFolder.focus();
      alert ("<emxUtil:i18nScript localize='i18nId'>emxComponents.Checkin.SelectFolder</emxUtil:i18nScript>");
      return;
    }
<%
    }
%>
<%
    if ( !objectId.equals("") && (objectAction.equals("revise") || "updateVersion".equals(objectAction)) )
    {
      if ( "true".equalsIgnoreCase(allowFileNameChange) )
      {
%>
        if (fileName != "" && tempFileName != fileName && !confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.ConfirmChangeOfFileName</emxUtil:i18nScript>")) {
          document.checkinForm.file.focus();
          return;
        }
<%
      } else {
%>
        if (title != "" && tempFileName != title ) {
          document.checkinForm.file.focus();
          alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.Common.FileDifferent</emxUtil:i18nScript>");
          return;
        }
<%
      }
      if ( showReason.equalsIgnoreCase("required") )
      {
%>
        if ( document.checkinForm.reason.value == "" ) {
          document.checkinForm.reason.focus();
          alert ("<emxUtil:i18nScript localize='i18nId'>emxComponents.Checkin.FillReasonForCheckin</emxUtil:i18nScript>");
          return;
        }
<%
      }

    }
%>

    document.checkinForm.parentId.value = '<%=XSSUtil.encodeForJavaScript(context,parentId)%>';
    document.checkinForm.objectId.value = '<%=XSSUtil.encodeForJavaScript(context,objectId)%>';
    document.checkinForm.fileName.value = tempFileName;

    parent.turnOnProgress();

    // prevent the multliple submit actions
    if (jsDblClick()) {
      document.checkinForm.submit();
    }
  }

  function closeWindow(){
    window.closeWindow();
  }

  function showTypeSelector() {
    var strFeatures = "width=300,height=350,resizable=yes";
    var strURL="../common/emxTypeChooser.jsp?fieldNameActual=type&fieldNameDisplay=realType&formName=checkinForm&ShowIcons=true&InclusionList=<%=XSSUtil.encodeForURL(context,defaultAliasType)%>&ObserveHidden=false&SelectType=singleselect";
    var win = window.open(strURL, "TypeSelector", strFeatures);
  }
/* Added the method for Bug No :301083 */
function browseWithButton()
{
alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.Common.BrowseWithButton</emxUtil:i18nScript>");
}

</script>
<%
  String requiredText = i18nNow.getI18nString("emxFramework.Commom.RequiredText","emxFrameworkStringResource",request.getHeader("Accept-Language"));
  int interval = session.getMaxInactiveInterval();
  int maxInterval = Integer.parseInt((String)FrameworkProperties.getProperty(context,"emxFramework.ServerTimeOutInSec"));
  if ( interval != maxInterval )
  {
    session.setMaxInactiveInterval(maxInterval);
    session.setAttribute("InactiveInterval", new Integer(interval));
  }

%>
<table width="100%" border="0" cellpadding="5" class="lightBack" cellspacing="0">
  <tr>
    <td class="requiredNotice" align="center" nowrap >
      <img src="../common/images/utilSpacer.gif"  height="10" width="1" /><br/>
      <%=requiredText%>
     </td>
   </tr>
<table>

<form name = "checkinForm" method = "post" enctype = "multipart/form-data" action="<%=checkinURL%>">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
      <table border="0" class="lightBack" width="100%" align="center" cellpadding="3" >
      <tr>
        <td>
          <input type="hidden" name="parentId" value="<%=XSSUtil.encodeForHTMLAttribute(context,parentId)%>" />
          <input type="hidden" name="objectId" value="<%=XSSUtil.encodeForHTMLAttribute(context,objectId)%>" />
          <input type="hidden" name="fileName" value="<%=XSSUtil.encodeForHTMLAttribute(context,fileName)%>" />
          <input type="hidden" name="unlock" value="<%=XSSUtil.encodeForHTMLAttribute(context,unlock)%>" />
          <input type="hidden" name="folderId" value="" />
          <input type="hidden" name="store" value="<%=XSSUtil.encodeForHTMLAttribute(context,store)%>" />
<%
          if ( DocumentUtil.isFCSEnable(context, store) )
          {
%>
            <input type="hidden" name="<%=jobTicket%>" value="<%=ticketStr%>" />
            <input type="hidden" name="<%=failurePageName%>" value="<%=failurePageValue%>" />
<%
          }
          usedParamList.addElement("parentId");
          usedParamList.addElement("objectId");
          usedParamList.addElement("folderId");
          usedParamList.addElement("store");
          usedParamList.addElement("append");
%>
        </td>
      </tr>
<%
// Start of display of Type depending on the parametes passed in
// If showType parameter came as required it will display with labelrequired
// if Object id is passed in they can't change the object type policy
// So this field is just text only
// If showType parameter came as nothing or false type will be sent as hidden
// with default type name.
    String txtLable = "label";
    if ( showType.equalsIgnoreCase("true") || showType.equalsIgnoreCase("required"))
    {
        if ( showType.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
        <tr>
          <td width="150" class="<%=txtLable%>"><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n> &nbsp;</td>
          <td class="inputField">
<%
        if ( objectId.equals("") )
        {
%>
          <input type="text" name="type" value="<%=XSSUtil.encodeForHTMLAttribute(context,defaultType)%>" size="20" onClick="showTypeSelector()" />
          <input type="button" name="FieldButton" value=".." size="5" onClick="showTypeSelector()" />
          <input type="hidden" name="realType" />
<%
        } else {
          String i18nType = i18nNow.getTypeI18NString(defaultType, sLanguage);
%>
          <input type="text" READONLY name="displayType" size="30" value="<%=i18nType%>" onFocus="this.blur();" />
          <input type="hidden" name="type" READONLY value="<%=XSSUtil.encodeForHTMLAttribute(context,defaultType)%>" />
<%
        }
%>
          </td>
        </tr>
<%
    } else {
%>
        <input type="hidden" name="type" value="<%=XSSUtil.encodeForHTMLAttribute(context,defaultType)%>" />
<%
    }
// Start of display of Title depending on the parametes passed in
// If showTitle parameter came as required it will display with labelrequired
// if Object id is passed in they can't change the object type policy
// So this field is just text only
// If showTitle parameter came as nothing or false type will be sent as hidden
// with default type name.
    txtLable = "label";
    if ( showName.equalsIgnoreCase("true") || showName.equalsIgnoreCase("required") )
    {
        if ( showName.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
        <tr>
          <td width=150 class="<%=txtLable%>"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n>&nbsp;</td>
          <td class="inputField" align="left">
          <input type="text" name="name" value="" size="25" /></td>
        </tr>
<%

    } else {
%>
        <input type="hidden" name="name" value="" />
<%
    }
// Start of display of Policy depending on the parametes passed in
// If showPolicy parameter came as required it will display with labelrequired
// if Object id is passed in they can't change the object type policy
// So this field is just text only
// If showPolicy parameter came as nothing or false type will be sent as hidden
// with default type name.
    txtLable = "label";
    if ( showPolicy.equalsIgnoreCase("true") || showPolicy.equalsIgnoreCase("required") )
    {
        if ( showPolicy.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
        <tr>
            <td width=150 class="<%=txtLable%>"><emxUtil:i18n localize="i18nId">emxComponents.Common.Policy</emxUtil:i18n>&nbsp;</td>
            <td class="inputField" align="left">
<%
        if ( objectId.equals("") )
        {
%>
          <select name="policy" size="1">
<%
          StringItr policyItr = new StringItr(policies);

          while (policyItr.next() )
          {
              String policy = policyItr.obj();
%>
              <option value="<%= policy %>" <%=policy%>><%=policy%></option>
<%
          }
%>
          </select>
<%
        } else {
%>
          <input name="policy" value="<%=defaultPolicy%>" />
<%
        }
%>
            </td>
        </tr>
<%
    } else {
%>
        <input type="hidden" name="policy" value="<%=defaultPolicy%>" />
<%
    }

    // Check if ShowAccessType
    txtLable = "label";
    String accessTypeStr = i18nNow.getI18nString("emxFramework.Attribute.Access_Type", "emxFrameworkStringResource", sLanguage);
    String defaultAccess = i18nNow.getI18nString("emxFramework.Range.Access_Type.Inherited","emxFrameworkStringResource", sLanguage);
    if("true".equalsIgnoreCase( showAccessType ) || "required".equalsIgnoreCase( showAccessType) )
    {
      if ( showAccessType.equalsIgnoreCase("required") )
      {
         txtLable = "labelRequired";
      }
%>
      <tr>
        <td width=150 class="<%=txtLable%>"><%=accessTypeStr%>&nbsp;</td>
        <td class="inputField" align="left">

        <select name="accessType" size="1">
<%
      String        accessAttrStr       = PropertyUtil.getSchemaProperty(context, "attribute_AccessType");
      AttributeType accessAttrType      = new AttributeType(accessAttrStr);
      StringList    accessAttributes    = null;
      StringItr     accessAttributesItr = null;

      accessAttrType.open(context);
      accessAttributes = accessAttrType.getChoices();
      accessAttrType.close(context);
      accessAttributesItr = new StringItr(accessAttributes);

      MapList ml = AttributeUtil.sortAttributeRanges(context, accessAttrStr, accessAttributes, sLanguage);
      Iterator mlItr = ml.iterator();
      while (mlItr.hasNext())
      {
         Map choiceMap = (Map) mlItr.next();
         String choice = (String) choiceMap.get("choice");
         String translation = (String) choiceMap.get("translation");
%>
        <option value="<%= choice %>" <%=(defaultAccess.equals(choice)? "selected" : "")%>><%= translation %></option>
<%
      }
%>
        </select>
        </td>
      </tr>
<%
  }

// Start of display of Title depending on the parametes passed in
// If showTitle parameter came as required it will display with labelrequired
// if Object id is passed in they can't change the object type policy
// So this field is just text only
// If showTitle parameter came as nothing or false type will be sent as hidden
// with default type name.
    txtLable = "label";
    if ( showTitle.equalsIgnoreCase("true") || showTitle.equalsIgnoreCase("required") )
    {
        if ( showTitle.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
        <tr>
          <td width=150 class="<%=txtLable%>"><emxUtil:i18n localize="i18nId">emxComponents.Common.Title</emxUtil:i18n>&nbsp;</td>
          <td class="inputField" align="left">
          <input type="text" name="title" value="<%=defaultTitle%>" size="25" /></td>
        </tr>
<%

    } else {
%>
        <input type="hidden" name="title" value="<%=defaultTitle%>" />
<%
    }

// Start of display of Description depending on the parametes passed in
// If showDescription parameter came as required it will display with labelrequired
// if Object id is passed in they can't change the object type policy
// So this field is just text only
// If showDescription parameter came as nothing or false type will be sent as hidden
// with default type name.
    txtLable = "label";
    if ( showDescription.equalsIgnoreCase("true") || showDescription.equalsIgnoreCase("required") )
    {

        if ( showDescription.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
        <tr>
          <td width=150 class="<%=txtLable%>"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n> &nbsp;</td>
          <td class="inputField"><textarea rows="4" name="description" cols="33" wrap><%=strDescription%></textarea></td>
        </tr>

<%
    } else {
%>
        <input type="hidden" name="description" value="<%=strDescription%>" />
<%
    }

%>
      <tr>
        <td width=150 class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.Common.File</emxUtil:i18n>&nbsp;</td>

<td class="inputField"><input type="file" name="file" size="30" value="" onpaste="return false;" onKeyDown="browseWithButton();" />

<%
    if ( !objectId.equals("") && (objectAction.equals("revise") || "updateVersion".equals(objectAction)) )
    {
%>
       <br/> <%=defaultTitle%>
<%
    }
%>

        </td>
      </tr>

<%
// Start of display of Format depending on the parametes passed in
// If showFormat parameter came as required it will display with labelrequired
// if Object id is passed in then all this object formats will be listed
// If showFormat parameter came as nothing or false type will be sent as hidden
// with default format name.

    txtLable = "label";

    if ( showFormat.equalsIgnoreCase("true") || showFormat.equalsIgnoreCase("required") || showFormat.equalsIgnoreCase("readonly"))
    {
        if ( showFormat.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }

%>
        <tr>
            <td width=150 class="<%=txtLable%>"><emxUtil:i18n localize="i18nId">emxComponents.Common.Format</emxUtil:i18n>&nbsp;</td>
            <td class="inputField" align="left">
<%
        if ( showFormat.equalsIgnoreCase("readonly") ) {
%>
            <input type="text" READONLY name="format" value="<%=XSSUtil.encodeForHTMLAttribute(context,oldFormat)%>" onFocus="this.blur();" />
<%
        } else {
%>
          <select name="format" size="1">
<%
          if ( objectId.equals("") )
          {
            StringItr formatItr = new StringItr(formats);

            while (formatItr.next() )
            {
                format = formatItr.obj();
%>
                <option value="<%=format%>" ><%=format%></option>
<%
            }
          } else {
            FormatItr fItr = new FormatItr(formatList);
            while (fItr.next() )
            {

                format = fItr.obj().getName();
%>
                <option value="<%= format %>" ><%=format%></option>
<%
            }
          }
%>
          </select>
<%
        }
%>
          </td>
        </tr>
<%
    } else if ( isFormatSupplied ) {
%>
        <input type="hidden" name="format" value="<%=XSSUtil.encodeForHTMLAttribute(context,oldFormat)%>" />
<%
    } else {
%>
        <input type="hidden" name="format" value="<%=DomainConstants.FORMAT_GENERIC%>" />
<%
    }

    if ( showFolder.equalsIgnoreCase("true") )
    {
%>
      <tr>
        <td nowrap  class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.Common.WorkspaceFolder</emxUtil:i18n></label></td>
        <td class="Field">
<%
        if ( objectId != null && !objectId.equals("") )
        {
%>
          <%=strFolderName%>&nbsp;
          <input type="hidden" name="txtWSFolder" value="<%=strFolderName%>" />
            <script language="javascript">
              document.checkinForm.folderId.value = "<%=strFolderId%>";
            </script>
<%      }
        else
        {
%>        <input type="text" name="txtWSFolder" value="" size="20" onFocus="blur()" />
          <input type="button" name="folder" value="..." onclick="folderlist()" />
<%
        }
%>
        </td>
      </tr>
<%
    }

    // Start of display of Action depending on the parametes passed in
    // If showAction parameter came as true then it is required field
    // If showAction parameter came as nothing or false append 'false' will be sent as hidden

    if ( showAction.equalsIgnoreCase("true") )
    {
%>
        <tr>
          <td width=150 class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.Common.Action</emxUtil:i18n>&nbsp;</td>
          <td class="inputField" align="left">
          <input type="radio" name="append" value="true" size="5" checked /> <emxUtil:i18n localize="i18nId">emxComponents.Common.Append</emxUtil:i18n>&nbsp;
          <input type="radio" name="append" value="false" size="5" /> <emxUtil:i18n localize="i18nId">emxComponents.Common.Replace</emxUtil:i18n>&nbsp;
          </td>
        </tr>
<%
    } else {
%>
        <input type="hidden" name="append" value="<%=XSSUtil.encodeForHTMLAttribute(context,defaultObjectAction)%>" />
<%
    }

// Start of display of Reason depending on the parametes passed in
// If showReason parameter came as true then it is required field
// If showReason parameter came as nothing or false append 'false' will be sent as hidden

    txtLable = "label";
    if ( !objectId.equals("") && (showReason.equalsIgnoreCase("true") || showReason.equalsIgnoreCase("required")) )
    {
        if ( showReason.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
        <tr>
          <td width=150 class="<%=txtLable%>"><emxUtil:i18n localize="i18nId">emxComponents.Common.ReasonForChange</emxUtil:i18n>&nbsp;</td>
          <td class="inputField" align="left">
          <textarea rows="4" name="reason" cols="33" wrap></textarea></td>
        </tr>
<%
    } else {
%>
        <input type="hidden" name="reason" value="" />
<%
    }

    // Check if ShowLangaugeForFileCheckin
    String showLangauge = FrameworkProperties.getProperty(context,"emxFramework.ShowLangaugeForFileCheckin");
    if("true".equalsIgnoreCase( showLangauge ))
    {
%>
      <tr>
        <td width=150 class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.Common.Language</emxUtil:i18n>&nbsp;</td>
        <td class="inputField" align="left">

        <select name="language" size="1">
<%
      String        languageAttrStr       = PropertyUtil.getSchemaProperty(context, "attribute_Language");
      AttributeType languageAttrType      = new AttributeType(languageAttrStr);
      StringList    languageAttributes    = null;
      StringItr     languageAttributesItr = null;

      languageAttrType.open(context);
      languageAttributes = languageAttrType.getChoices();
      languageAttrType.close(context);
      languageAttributesItr = new StringItr(languageAttributes);

      MapList ml = AttributeUtil.sortAttributeRanges(context, languageAttrStr, languageAttributes, request.getHeader("Accept-Language"));
      Iterator mlItr = ml.iterator();
      while (mlItr.hasNext())
      {
         Map choiceMap = (Map) mlItr.next();
         String choice = (String) choiceMap.get("choice");
         String translation = (String) choiceMap.get("translation");
%>
//added fix for bug no 318773
        <option value="<%= choice %>" <%=("english".equalsIgnoreCase(choice)? "selected" : "")%>><%= translation %></option>
//end fix for bug no 318773
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
      <td>
<%
  Enumeration enumParam = request.getParameterNames();
  while ( enumParam.hasMoreElements())
  {
      String paramName =  (String)enumParam.nextElement();
      String paramValue = emxGetParameter(request,paramName);
      if ( paramName.indexOf("show") != 0 && !usedParamList.contains(paramName) )
      {
%>
        <input type="hidden" name="<%=XSSUtil.encodeForHTMLAttribute(context,paramName)%>" value="<%=XSSUtil.encodeForHTMLAttribute(context,paramValue)%>" />
<%
      }
  }
%>
    </td></tr>
</table>

<!-- end -->
</form>


<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

<!-- content ends here  -->
