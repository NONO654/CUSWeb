<%--  emxCommonDocumentEditDialog.jsp   - Dialog page to take input for editing a Document.

   Copyright (c) 2003-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDocumentEditDialog.jsp.rca 1.23.2.1 Tue Dec 23 05:43:53 2008 ds-hkarthikeyan Experimental $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<script language = "javascript" type = "text/javascript" src = "../common/scripts/emxUIFormUtil.js"></script>

<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  Document document = (Document)DomainObject.newInstance(context, DomainConstants.TYPE_DOCUMENT);
  String strLanguage = request.getHeader("Accept-Language");
  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String suiteKey    = emxGetParameter(request,"suiteKey");
  String documentId  = emxGetParameter(request,"objectId");
  String timeZone       = (String)session.getValue("timeZone");

  String ATTRIBUTE_IS_VERSION_OBJECT = PropertyUtil.getSchemaProperty(context,"attribute_IsVersionObject");
  String RELATIONSHIP_TASK_DELIVERABLE = PropertyUtil.getSchemaProperty(context,"relationship_TaskDeliverable");
  StringBuffer SELECT_COMPLETION_STATE = new StringBuffer(64);
  SELECT_COMPLETION_STATE.append("relationship[");
  SELECT_COMPLETION_STATE.append(RELATIONSHIP_TASK_DELIVERABLE);
  SELECT_COMPLETION_STATE.append("].attribute[");
  SELECT_COMPLETION_STATE.append(DomainConstants.ATTRIBUTE_COMPLETION_STATE);
  SELECT_COMPLETION_STATE.append("]");
  
  StringBuffer SELECT_REL_TASK_DELIVERABLE_ID = new StringBuffer(64);
  SELECT_REL_TASK_DELIVERABLE_ID.append("relationship[");
  SELECT_REL_TASK_DELIVERABLE_ID.append(RELATIONSHIP_TASK_DELIVERABLE);
  SELECT_REL_TASK_DELIVERABLE_ID.append("].id");

    
  String store = PropertyUtil.getSchemaProperty(context,"store_STORE");
    
  document.setId(documentId);

  SelectList selectList = new SelectList(30);
  
  selectList.add("attribute[" + ATTRIBUTE_IS_VERSION_OBJECT + "]");
  selectList.add("attribute["+DomainConstants.ATTRIBUTE_ACCESS_TYPE+"]");
  selectList.add(SELECT_COMPLETION_STATE.toString());
  selectList.add(SELECT_REL_TASK_DELIVERABLE_ID.toString());
  selectList.add(document.SELECT_NAME);
  selectList.add(document.SELECT_REVISION);
  selectList.add(document.SELECT_TYPE);
  selectList.add(document.SELECT_TITLE);
  selectList.add(document.SELECT_DESCRIPTION);
  selectList.add(document.SELECT_OWNER);
  selectList.add(document.SELECT_CURRENT);
  selectList.add(DomainConstants.SELECT_ORIGINATED);
  selectList.add(DomainConstants.SELECT_ORIGINATOR);
  selectList.add(DomainConstants.SELECT_POLICY);
  selectList.add(DomainConstants.SELECT_MODIFIED);
  selectList.add(document.SELECT_CHECKIN_REASON);
  selectList.add("current.access[changetype]");
  selectList.add("current.access[changepolicy]");
  selectList.add("id");
  selectList.add("vcfile");
  selectList.add("vcfolder");
  selectList.add("vcfile.store");
  selectList.add("vcfolder.store");
  selectList.add("vcfolder.path");
  selectList.add("vcfile.path");
  selectList.add("vcfile.specifier");
  selectList.add("vcfolder.config");
  selectList.add("vcfile.vcname");
  selectList.add("vcfile.exists");
  selectList.add("vcfile.locked");
  selectList.add("vcfolder.vcfile.author");
  selectList.add("vcfile.comment");
  selectList.add("vcfolder.comment");
  selectList.add("vcfile.checkinstatus");
  selectList.add("vcfolder.checkinstatus");
  selectList.add("vcmodule");
  selectList.add("vcmodule.store");
  selectList.add("vcmodule.path");
  selectList.add("vcmodule.config");
  selectList.add("vcmodule.comment");
  selectList.add("vcmodule.checkinstatus");
  selectList.add("vcmodule.checkinerrormessage");
  selectList.add("vcmodule.specifier");
  
  Map mapDocumentInfo = document.getInfo(context,selectList);
  
  String server = "";
  String path = "";
  String selector="";
  String vcfilename="";
  String author="";
  String versionid="";
  String locked = "";
  String vcExists = "";
  String vcComment = "";
  String vcCheckinStatus ="";
  String vcfile = (String)mapDocumentInfo.get("vcfile");
  String vcfolder = (String)mapDocumentInfo.get("vcfolder");
  String vcmodule = (String)mapDocumentInfo.get("vcmodule");
  String vcmoduleconfig = (String)mapDocumentInfo.get("vcmodule[1].config");
  boolean hasSyncIdentifierValue = false;
  
  String strRelTaskDeliverableId = (String)mapDocumentInfo.get(SELECT_REL_TASK_DELIVERABLE_ID.toString());
  if ((strRelTaskDeliverableId == null) || ("".equals(strRelTaskDeliverableId)) || ("null".equals(strRelTaskDeliverableId)))
    strRelTaskDeliverableId = "";
    
  String strCompletionState = (String)mapDocumentInfo.get(SELECT_COMPLETION_STATE.toString());
  if ((strCompletionState == null) || ("".equals(strCompletionState)) || ("null".equals(strCompletionState)))
    strCompletionState = "";

  // Using getInfo due to a problem with IC Folders not returning Sync Identifier in map list.
  String strSyncIdentifier = document.getInfo(context,"attribute[" + com.matrixone.apps.domain.DomainConstants.ATTRIBUTE_SYNC_IDENTIFIER + "]");
  if ((strSyncIdentifier == null) || ("".equals(strSyncIdentifier)) || ("null".equals(strSyncIdentifier)))
    strSyncIdentifier = "";
    
  // This means we are State sensitive
  if (!"".equals(strSyncIdentifier))
    hasSyncIdentifierValue = true;
    
  if( "true".equalsIgnoreCase(vcfile) )
  {
      server = (String)mapDocumentInfo.get("vcfile[1].store");
      String tmpPath = (String)mapDocumentInfo.get("vcfile[1].path");
      int index = tmpPath.lastIndexOf('/');
      if (index < 0)
        path = java.io.File.separator;
      else
        path = tmpPath.substring(0, index);
      vcfilename = tmpPath.substring(index + 1);
      selector=(String)mapDocumentInfo.get("vcfile[1].specifier");
      if (path.equals(vcfilename))
        path = java.io.File.separator;
      locked = (String)mapDocumentInfo.get("vcfile[1].locked");
      if (locked == null)
        locked = "";
      vcExists=(String)mapDocumentInfo.get("vcfile[1].exists");
      vcComment=(String)mapDocumentInfo.get("vcfile[1].comment");
      vcCheckinStatus =(String)mapDocumentInfo.get("vcfile[1].checkinstatus");  

      if( "true".equalsIgnoreCase(vcExists) ){
       SelectList innerSelectList = new SelectList();
       innerSelectList.add("vcfile.author");
       innerSelectList.add("vcfile.versionid");
       Map mapFileInfo = document.getInfo(context,innerSelectList);
       author=(String)mapFileInfo.get("vcfile[1].author");
       versionid=(String)mapFileInfo.get("vcfile[1].versionid");
     }
  }
  else if( "true".equalsIgnoreCase(vcfolder) )
  {
      server = (String)mapDocumentInfo.get("vcfolder[1].store");
      path = (String)mapDocumentInfo.get("vcfolder[1].path");
      selector=(String)mapDocumentInfo.get("vcfolder[1].config");
      author=(String)mapDocumentInfo.get("vcfolder[1].vcfile.author");
      vcComment=(String)mapDocumentInfo.get("vcfolder[1].comment");
      vcCheckinStatus =(String)mapDocumentInfo.get("vcfolder[1].checkinstatus");  
  }
  else if( "true".equalsIgnoreCase(vcmodule) )
  {
  
      server = (String)mapDocumentInfo.get("vcmodule[1].store");
      path = (String)mapDocumentInfo.get("vcmodule[1].path");
   
      vcmoduleconfig=(String)mapDocumentInfo.get("vcmodule[1].config");
      if(vcmoduleconfig == null || "".equals(vcmoduleconfig) || "null".equals(vcmoduleconfig))
      {
          selector = (String)mapDocumentInfo.get("vcmodule[1].specifier");
          
      }
      else
      {
          selector = vcmoduleconfig;
      }
   
      vcComment=(String)mapDocumentInfo.get("vcmodule[1].comment");
      vcCheckinStatus =(String)mapDocumentInfo.get("vcmodule[1].checkinstatus");
  }
   
  if ((server == null) || (server.equals(store)))
    server = "";
    
  if ((vcComment == null) || ("null".equals(vcComment)))
    vcComment = "";
  if(vcCheckinStatus == null || "null".equals(vcCheckinStatus)) {
      vcCheckinStatus = "";
  }
    
  String documentName = (String)mapDocumentInfo.get(DomainConstants.SELECT_NAME);
  String documentRevision = (String)mapDocumentInfo.get(document.SELECT_REVISION);
  String documentType = (String)mapDocumentInfo.get(document.SELECT_TYPE);
  String documentDescription = (String)mapDocumentInfo.get(document.SELECT_DESCRIPTION);
  String documentTitle = (String)mapDocumentInfo.get(document.SELECT_TITLE);
  documentTitle = UINavigatorUtil.htmlEncode(documentTitle);

  String documentOwner = (String)mapDocumentInfo.get(document.SELECT_OWNER);
  String documentState = (String)mapDocumentInfo.get(document.SELECT_CURRENT);
  String documentOriginated = (String)mapDocumentInfo.get(DomainConstants.SELECT_ORIGINATED);
  String documentOriginator = (String)mapDocumentInfo.get(DomainConstants.SELECT_ORIGINATOR);
  String documentPolicy = (String)mapDocumentInfo.get(DomainConstants.SELECT_POLICY);
  String documentModified = (String)mapDocumentInfo.get(DomainConstants.SELECT_MODIFIED);
  String documentAccessType = (String)mapDocumentInfo.get("attribute["+DomainConstants.ATTRIBUTE_ACCESS_TYPE+"]");
  String documentReason = (String)mapDocumentInfo.get(document.SELECT_CHECKIN_REASON);
  String isVersionObject =(String)mapDocumentInfo.get("attribute[" + ATTRIBUTE_IS_VERSION_OBJECT + "]");
  String emxSelectorBadChars = EnoviaResourceBundle.getProperty(context,"emxComponents.VCFileFolder.SelectorBadChars");

  boolean bChangeTypeAccess   = "TRUE".equalsIgnoreCase((String)mapDocumentInfo.get("current.access[changetype]"));
  boolean bChangePolicyAccess = "TRUE".equalsIgnoreCase((String)mapDocumentInfo.get("current.access[changepolicy]"));

  String sPageReload  = emxGetParameter(request,"pageReload");
  boolean bReloaded = false;
  if(sPageReload  !=null && "true".equals(sPageReload))
  {
    documentType  = emxGetParameter(request,"realType");
    documentPolicy = emxGetParameter(request,"policy");
    server = emxGetParameter(request,"server");
    path = emxGetParameter(request,"path");
    selector = emxGetParameter(request,"selector");
    bReloaded = true;
  }

  String fileFormat = null;
  String fileSize   = null;

  if("True".equalsIgnoreCase(isVersionObject)){

    String relVersion          = PropertyUtil.getSchemaProperty(context, DomainObject.SYMBOLIC_relationship_ActiveVersion);
    String relPattern         = relVersion;
      String latestId = document.getInfo(context, "last.id");
      document.setId(latestId);

    StringList versionSelectList = new StringList(4);
    versionSelectList.add(DomainConstants.SELECT_ID);
    versionSelectList.add(DomainConstants.SELECT_FILE_NAME);
    versionSelectList.add(DomainConstants.SELECT_FILE_FORMAT);
    versionSelectList.add(DomainConstants.SELECT_FILE_SIZE);

    MapList versionList = document.getRelatedObjects(context,
                         relPattern,
                         "*",
                         versionSelectList,
                         null,
                         true,
                         false,
                         (short)1,
                         null,
                         null);
    Iterator mapListItr = versionList.iterator();
    Map versionListMap = (Map) mapListItr.next();
      StringList fileNameList = new StringList();
      StringList fileFormatList = new StringList();
      StringList fileSizeList   = new StringList();
      try
      {
          fileNameList   = (StringList) versionListMap.get(DomainConstants.SELECT_FILE_NAME);
          fileFormatList = (StringList) versionListMap.get(DomainConstants.SELECT_FILE_FORMAT);
          fileSizeList   = (StringList) versionListMap.get(DomainConstants.SELECT_FILE_SIZE);
      }
      catch (ClassCastException cex )
      {
          fileNameList.add((String)versionListMap.get(DomainConstants.SELECT_FILE_NAME));
          fileFormatList.add((String)versionListMap.get(DomainConstants.SELECT_FILE_FORMAT));
          fileSizeList.add((String)versionListMap.get(DomainConstants.SELECT_FILE_SIZE));
      }

    Iterator fileItr  = fileNameList.iterator();
    MapList fileMapList = new MapList();
    mapListItr = versionList.iterator();
    while(mapListItr.hasNext())
      {
        Map fileVersionMap     = (Map)mapListItr.next();
        fileFormat = "";
        fileSize   = "";
        // get the file corresponding to this Version by filtering the above fileList
        int index = fileNameList.indexOf(documentTitle);

        // get the File Format
        if (index != -1 && fileFormatList != null && fileFormatList.size() >= index )
        {
           fileFormat = (String)fileFormatList.get(index);
        }

        // get the File Size
        if (index != -1 && fileSizeList != null && fileSizeList.size() >= index )
        {
           fileSize = (String)fileSizeList.get(index);
        }


        fileVersionMap.put(DomainConstants.SELECT_FILE_FORMAT, fileFormat);
        fileVersionMap.put(DomainConstants.SELECT_FILE_SIZE, fileSize);

        fileMapList.add(fileVersionMap);


      }

  }

  // dynamic attribute display for custom sub-types of DOCUMENTS
  // get the list of Attribute names, filter out the attributes defined
  // by the property
  String excludeAttributes = EnoviaResourceBundle.getProperty(context,"emxComponents.CreateDocument.ExcludeAttributeList");
  StringList excludeAttrList = new StringList();

  if(excludeAttributes != null)
  {
    StringTokenizer excludeAttrTokenizer = new StringTokenizer(excludeAttributes,",");
    while (excludeAttrTokenizer.hasMoreTokens())
    {
      excludeAttrList.add(PropertyUtil.getSchemaProperty(context,excludeAttrTokenizer.nextToken().trim()));
    }
  }

  Map attrMap              = document.getAttributeMap(context);

  //
  // URL for Person Chooser
  //
  String personChooserURL = Framework.encodeURL( response,
        "emxComponentsFindMemberDialogFS.jsp?getValue=name");

  // Type chooser requires the symbolic name
  String symbolicDocumentType = FrameworkUtil.getAliasForAdmin(context, "type", PropertyUtil.getSchemaProperty(context, "type_DOCUMENTS"), true);

  String sAllowChangePolicy   = EnoviaResourceBundle.getProperty(context,"emxComponents.AllowChangePolicy");
  boolean bAllowChangePolicy  = true;
  if(sAllowChangePolicy != null && "false".equalsIgnoreCase(sAllowChangePolicy))
  {
    bAllowChangePolicy = false;
  }


  // Current object policy is th default policy
  String defaultDocumentPolicyName = documentPolicy;
  String states = MqlUtil.mqlCommand(context, "print policy $1 select $2 dump $3", defaultDocumentPolicyName, "state","|" );
  StringList stateList = FrameworkUtil.split(states, "|");

  MapList documentPolicies = new MapList();

  // Get the policy list if user has change policy access
  if(bChangePolicyAccess)
  {
    Map defaultDocumentPolicyMap = null;
    if(bAllowChangePolicy)
    {
      Map documentPolicyMap = new HashMap();
      String policyName = null;
      documentPolicies = mxType.getPolicies( context, documentType, false);
      if(bReloaded)
      {
          Iterator itr = documentPolicies.iterator();
          while(itr.hasNext())
          {
            documentPolicyMap = (Map)itr.next();
            policyName = (String)documentPolicyMap.get("name");
            if (policyName.equals(documentPolicy))
            {
              defaultDocumentPolicyMap = documentPolicyMap;
            }
          }

          if(defaultDocumentPolicyMap == null)
          {
            defaultDocumentPolicyMap = (Map) documentPolicies.get(0);
          }
          documentRevision = (String)defaultDocumentPolicyMap.get("revision");
      }
    }
    else
    {
      // Get the default policy among the policy list of selected type
      if(bReloaded)
      {
        defaultDocumentPolicyMap = mxType.getDefaultPolicy( context, documentType, false);
        defaultDocumentPolicyName = (String)defaultDocumentPolicyMap.get("name");
        documentRevision = (String)defaultDocumentPolicyMap.get("revision");
        states = MqlUtil.mqlCommand(context, "print policy $1 select state dump $2",defaultDocumentPolicyName,"|" );
        stateList = FrameworkUtil.split(states, "|");
      }
    }
  }
%>

<form name="editDataForm" method="post" action="emxCommonDocumentEditDialogProcess.jsp">

<table>
<script language="Javascript" >


  function closeWindow() {
      window.closeWindow();
      return;
  }
  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }
  function submitForm()
  {

<%
    if ( "False".equalsIgnoreCase(isVersionObject))
    {
%>
      //IR-053866V6R2011x Modification
      //var namebadCharName = checkForNameBadCharsList(document.editDataForm.txtDocumentName);
      //if (namebadCharName.length != 0)
      var namebadCharName = checkForUnifiedNameBadChars(document.editDataForm.txtDocumentName,true);
      if (namebadCharName.length != 0)      
      {
        var nameAllBadCharName = getAllNameBadChars(document.editDataForm.txtDocumentName);
      	//IR-053866V6R2011x Modification
      	//alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
      	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInvalidInput</emxUtil:i18nScript>"+nameAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");        
        document.editDataForm.txtDocumentName.focus();
        return;
      }

      var name = trim(document.editDataForm.txtDocumentName.value);
      document.editDataForm.txtDocumentName.value = name;
      if (name.length == 0 )
      {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.NameError</emxUtil:i18nScript>");
          document.editDataForm.txtDocumentName.focus();
          return;
      }
<%
      if(!excludeAttrList.contains(DomainConstants.ATTRIBUTE_TITLE)){
%>
        var title = trim(document.editDataForm.txtDocumentTitle.value);
        document.editDataForm.txtDocumentTitle.value = title;

        //IR-053866V6R2011x Modification
        //var titleBadCharName = checkForNameBadCharsList(document.editDataForm.txtDocumentTitle);
        var titleBadCharName = checkForNameBadChars(document.editDataForm.txtDocumentTitle,true);
        if (titleBadCharName.length != 0)
        {
          //IR-053866V6R2011x Modification
          //alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+titleBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+titleBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInvalidInput</emxUtil:i18nScript>"+nameBadChars+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
          document.editDataForm.txtDocumentTitle.focus();
          return;
        }
        if ( title.length == 0 )
        {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.TitleError</emxUtil:i18nScript>");
        document.editDataForm.txtDocumentTitle.focus();
        return;
      }
<%
      }
%>
      var descriptionBadCharName = checkForBadChars(document.editDataForm.txtDocumentdescription);
      if (descriptionBadCharName.length != 0)
      {
        //IR-053866V6R2011x Modification
        var descriptionAllBadCharName = getAllBadChars(document.editDataForm.txtDocumentdescription);
        //alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+descriptionBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+descriptionBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInvalidInput</emxUtil:i18nScript>"+descriptionAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
        document.editDataForm.txtDocumentdescription.focus();
        return;
      }
<%
    } else if(!excludeAttrList.contains(document.SELECT_CHECKIN_REASON)) {
%>
        var commentsBadCharName = checkForBadChars(document.editDataForm.txtDocumentReason);
        if (commentsBadCharName.length != 0)
        {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+commentsBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
          document.editDataForm.txtDocumentReason.focus();
          return;
        }
<%
    }
%>
      
      if (document.editDataForm.selector)
      { 
          var selector = document.editDataForm.selector.value;
          if(selector.length <= 0)
          {
             alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.SelectorEmpty</emxUtil:i18nScript>");
             return;        
          }
          var STR_SELECTOR_BAD_CHARS = "<%= emxSelectorBadChars.trim() %>";
          var ARR_SELECTOR_BAD_CHARS = "";
          if (STR_SELECTOR_BAD_CHARS != "") 
          {
            ARR_SELECTOR_BAD_CHARS = STR_SELECTOR_BAD_CHARS.split(" ");   
          }
          var strSelectorResult = checkFieldForChars(document.editDataForm.selector,ARR_SELECTOR_BAD_CHARS,false);
          if (strSelectorResult.length > 0) {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.InvalidChars</emxUtil:i18nScript>\n"
                  + STR_SELECTOR_BAD_CHARS + "\n<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript>\n"
                  +document.editDataForm.selector.name);
           document.editDataForm.selector.focus();
           return;
         }
      }
      
      document.editDataForm.submit();
      return;
  }
</script>
<%
  if( "False".equalsIgnoreCase(isVersionObject)){
%>
  <tr>
    <td class="labelRequired" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></td>
     <!-- //XSSOK -->
	 <td class="inputField"><input type="text" name="txtDocumentName" size="25" value="<%=documentName%>" onFocus="this.select()" />
    </td>
  </tr>
  <tr>
      <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Basic.Revision</emxUtil:i18n></td>
       <!-- //XSSOK -->
	   <td class="field"><%=documentRevision%>&nbsp;</td>
  </tr>
  <tr>
      <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Basic.Type</emxUtil:i18n></td>
<%
    if((bChangeTypeAccess) && (!hasSyncIdentifierValue))
    {
%>
      <td class="inputField" >
        <input type="text" size="20" name="txtDocumentType" value="<%=i18nNow.getTypeI18NString(documentType,strLanguage)%>" readonly="readonly" />
        <input type="button" value="..." name="btn" onclick="showTypeSelector();" />
         <!-- //XSSOK -->
		 <input type="hidden" name="realType" value="<%=documentType%>" />
      </td>
<%
    }
    else
    {
%>
      <td class="field"><%=i18nNow.getTypeI18NString(documentType,strLanguage)%>&nbsp;</td>
       <!-- //XSSOK -->
	   <input type="hidden" name="realType" value="<%=documentType%>" />
<%
    }
%>
  </tr>
  <%
     if(!excludeAttrList.contains(DomainConstants.ATTRIBUTE_TITLE))
     {

  %>
  <tr>
      <td class="labelRequired" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Title</emxUtil:i18n></td>
       <!-- //XSSOK -->
	   <td class="inputField"><input type="text" name="txtDocumentTitle" size="25" value="<%=documentTitle%>" onFocus="this.select()" />
  </tr>
  <%
     }
  %>
  <tr>
      <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Basic.Description</emxUtil:i18n></td>
   <td class="field" align="left">
      <!-- //XSSOK -->
	  <textarea name="txtDocumentdescription" rows="3" cols="30" wrap="wrap"><%=documentDescription%></textarea>
   </td>

  </tr>
  <tr>
      <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Common.State</emxUtil:i18n></td>
      <!-- Begin of Modify Mayukh, Infosys Bug # 294762 Date 03/10/2005 -->
      <td class="field"><%=i18nNow.getStateI18NString(documentPolicy,documentState,strLanguage)%>&nbsp;</td>
      <!-- End of Modify Mayukh, Infosys Bug # 294762 Date 03/10/2005 -->
  </tr>

  <tr>
      <td class="labelRequired" > <emxUtil:i18n localize="i18nId">emxComponents.Common.Owner</emxUtil:i18n></td>
      <%
      if(context.getUser().equalsIgnoreCase(documentOwner) || documentOwner==null || "".equals(documentOwner))
    {
      %>
      <td class="inputField" >
        <input type="text" size="20" name="person" value="<%=documentOwner==null?context.getUser():documentOwner%>" readonly="readonly"  />
         <!-- //XSSOK -->
		 <input type="button" value="..." name="btn" onclick="javascript:showModalDialog('<%=personChooserURL%>',575,575);")' />
      </td>
      <%
    }
    else{
        %>
         <!-- //XSSOK -->
		 <td class="inputField"><%=documentOwner%></td>
        <%}
        %>
  </tr>
  <%
     if(!excludeAttrList.contains(DomainConstants.SELECT_ORIGINATED))
     {

  %>
  <tr>
      <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Originated</emxUtil:i18n></td>
       <!-- //XSSOK -->
	   <td class="field"><emxUtil:lzDate displaydate="true" displaytime="true" localize="i18nId" tz='<%=timeZone%>' format='<%=DateFrm %>' ><%=documentOriginated%></emxUtil:lzDate>&nbsp;</td>
  </tr>
  <%
     }

    if(!excludeAttrList.contains(DomainConstants.ATTRIBUTE_ORIGINATOR))
    {
  %>
  <tr>
      <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Originator</emxUtil:i18n></td>
       <!-- //XSSOK -->
	   <td class="field"><%=documentOriginator%>&nbsp;</td>
  </tr>
  <%
    }

    if(!excludeAttrList.contains(DomainConstants.SELECT_MODIFIED))
    {
  %>
  <tr>
      <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Modified</emxUtil:i18n></td>
       <!-- //XSSOK -->
	   <td class="field"><emxUtil:lzDate displaydate="true" displaytime="true" localize="i18nId" tz='<%=timeZone%>' format='<%=DateFrm %>' ><%=documentModified%></emxUtil:lzDate>&nbsp;</td>
  </tr>
  <%
    }

  //Check if the user has the access to change the Policy
  if((bChangePolicyAccess) && (!hasSyncIdentifierValue))
  {
    if(bAllowChangePolicy)
    {
%>
    <tr>
      <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Policy</emxUtil:i18n></td>
      <td class="inputField" >
        <select name = "policy" onChange=reload()>
<%
      if(documentPolicies != null && !documentPolicies.isEmpty())
      {
        Iterator policyItr = documentPolicies.iterator();
        String policy = "";
        String i18nPolicy = "";
        while( policyItr.hasNext())
        {
          Map docPolicyMap = (Map)policyItr.next();
          policy = (String)docPolicyMap.get("name");
          i18nPolicy  = i18nNow.getMXI18NString(policy,"",strLanguage,"Policy");
%>
           <!-- //XSSOK -->
		   <option value="<%=policy%>" <%=policy.equals(defaultDocumentPolicyName)?"selected":""%> ><%=i18nPolicy%></option>
<%
        }
      }
%>
        </select>
      </td>
     </tr>
<%
    }
    else
    {
%>
      <!-- //XSSOK -->
	  <input type="hidden" name="policy"  value="<%=defaultDocumentPolicyName%>" />
<%
    }
  }
  else
  {
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Policy</emxUtil:i18n></td>
       <!-- //XSSOK -->
	   <td class="inputField"><%=defaultDocumentPolicyName%></td>
       <!-- //XSSOK -->
	   <input type="hidden" name="policy"  value="<%=defaultDocumentPolicyName%>" />
     </tr>
<%
     if(hasSyncIdentifierValue)
     {
%>
      <tr>
       <td class="labelRequired">
         <emxUtil:i18n localize="i18nId">emxComponents.Common.CompletionState</emxUtil:i18n>
       </td>
       <td class="inputField" >
           <select name = "state" >
<%
           Iterator stateItr = stateList.iterator();
           String state = "";
           String i18nState= "";
           while( stateItr.hasNext())
           {
             state = (String)stateItr.next();
             i18nState = i18nNow.getMXI18NString(state, defaultDocumentPolicyName, context.getSession().getLanguage(), "State");
%>
              <!-- //XSSOK -->
			  <option value="<%=state%>" <%=(i18nState.equals(strCompletionState)? "selected" : "")%>><%=i18nState%></option>
<%
           }
%>
        </select>
      </td>
    </tr>
<%
     }
  }
  // Check if ShowAccessType
  // String defaultAccess = i18nNow.getI18nString("emxFramework.Range.Access_Type.Inherited","emxFrameworkStringResource", strLanguage);
  String defaultAccess = (String)attrMap.get(DomainConstants.ATTRIBUTE_ACCESS_TYPE);
  if(!excludeAttrList.contains(DomainConstants.ATTRIBUTE_ACCESS_TYPE))
  {
%>
        <tr>
          <td class="Label" >
          <%= i18nNow.getAttributeI18NString(DomainConstants.ATTRIBUTE_ACCESS_TYPE,strLanguage)%>
          </td>
          <td class="inputField" align="left">

          <select name="AccessType" size="1">
<%
    String        accessAttrStr       = PropertyUtil.getSchemaProperty(context, "attribute_AccessType");
    AttributeType accessAttrType      = new AttributeType(accessAttrStr);
    StringList    accessAttributes    = null;
    StringItr     accessAttributesItr = null;

    accessAttrType.open(context);
    accessAttributes = accessAttrType.getChoices();
    accessAttrType.close(context);
    accessAttributesItr = new StringItr(accessAttributes);

    MapList ml = AttributeUtil.sortAttributeRanges(context, accessAttrStr, accessAttributes, strLanguage);
    Iterator mlItr = ml.iterator();
    while (mlItr.hasNext())
    {
      Map choiceMap = (Map) mlItr.next();
      String choice = (String) choiceMap.get("choice");
      String translation = (String) choiceMap.get("translation");
%>
           <!-- //XSSOK -->
		   <option value="<%= choice %>" <%=(defaultAccess.equals(choice)? "selected" : "")%>><%= translation %></option>
<%
     }
%>
          </select>
          </td>
        </tr>

<%
     }
   }
   else
   {

%>
  <tr>
    <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Common.File</emxUtil:i18n></td>
     <!-- //XSSOK -->
	 <td class="field"><%=documentTitle%>&nbsp;</td>
  </tr>
  <tr>
    <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Formats.Version</emxUtil:i18n></td>
     <!-- //XSSOK -->
	 <td class="field"><%=documentRevision%>&nbsp;</td>
  </tr>
  <tr>
    <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Format</emxUtil:i18n></td>
     <!-- //XSSOK -->
	 <td class="field"><%=fileFormat%>&nbsp;</td>
  </tr>
  <tr>
    <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Common.FileSize</emxUtil:i18n></td>
     <!-- //XSSOK -->
	 <td class="field"><%=fileSize%>&nbsp;</td>
  </tr>
  <tr>
    <td class="label" > <emxUtil:i18n localize="i18nId">emxComponents.Common.Owner</emxUtil:i18n></td>
     <!-- //XSSOK -->
	 <td class="inputField" ><%=documentOwner%></td>
  </tr>
<%
    if(!excludeAttrList.contains(DomainConstants.SELECT_ORIGINATED))
    {

%>
  <tr>
    <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Originated</emxUtil:i18n></td>
     <!-- //XSSOK -->
	 <td class="field"><emxUtil:lzDate displaydate="true" displaytime="true" localize="i18nId" tz='<%=timeZone%>' format='<%=DateFrm %>' ><%=documentOriginated%></emxUtil:lzDate>&nbsp;</td>
  </tr>
<%
    }
    if(!excludeAttrList.contains(DomainConstants.SELECT_MODIFIED))
    {

%>
  <tr>
    <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Modified</emxUtil:i18n></td>
     <!-- //XSSOK -->
	 <td class="field"><emxUtil:lzDate displaydate="true" displaytime="true" localize="i18nId" tz='<%=timeZone%>' format='<%=DateFrm %>' ><%=documentModified%></emxUtil:lzDate>&nbsp;</td>
  </tr>
<%
    }
    if(!excludeAttrList.contains(document.SELECT_CHECKIN_REASON))
    {

%>
  <tr>
    <td class="label" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Comments</emxUtil:i18n></td>
  <td class="field" align="left">
          <!-- //XSSOK -->
		  <textarea name="txtDocumentReason" rows="3" cols="30" wrap="wrap"><%=documentReason%></textarea>
    </td>
  </tr>
<%
    }
  }

    if( !excludeAttrList.contains("attribute_Title"))
    {
      excludeAttrList.add(PropertyUtil.getSchemaProperty(context,"attribute_Title"));
    }
    if( !excludeAttrList.contains("attribute_AccessType"))
    {
      excludeAttrList.add(PropertyUtil.getSchemaProperty(context,"attribute_AccessType"));
    }
    if( !excludeAttrList.contains("attribute_CheckinReason"))
    {
      excludeAttrList.add(PropertyUtil.getSchemaProperty(context,"attribute_CheckinReason"));
    }


    MapList attributeMapList = mxType.getAttributes( context, documentType);

    Iterator i = attributeMapList.iterator();
    String attributeName = null;
    String attributeValue = "";

    while(i.hasNext())
    {
      Map attributeMap = (Map)i.next();
      attributeName  = (String)attributeMap.get("name");
      attributeValue = (String)attrMap.get(attributeName);

      if(attributeValue == null)
      {
         attributeValue = "";
      }
      attributeMap.put("value", attributeValue);

      if(!excludeAttrList.contains(attributeName))
      {
%>
    <tr>
      <td class="label" >
        <%= i18nNow.getAttributeI18NString(attributeName,strLanguage)%>
      </td>
      <!-- //XSSOK -->
	  <td class="inputField"><%=UIUtil.displayField(context,attributeMap,"edit",strLanguage,"editDataForm",session,request.getLocale())%>&nbsp;</td>
    </tr>
<%
      }
    }
	//Modified for the bug no:344439 
	boolean isLCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionLibraryCentral",false,null,null);
	if(isLCInstalled && ("False".equalsIgnoreCase(isVersionObject)))
	{
%>
		<!-- //XSSOK -->
		<jsp:include page="../documentcentral/emxLibraryCentralClassificationPaths.jsp"><jsp:param name="objectId" value="<%=documentId%>"/><jsp:param name="label" value="emxLibraryCentral.Properties.ClassificationPath"/><jsp:param name="stringResource" value="emxLibraryCentralStringResource"/></jsp:include>
		<!-- //XSSOK -->
		<jsp:include page="../documentcentral/emxMultipleClassificationClassificationAttributes.jsp"><jsp:param name="objectId" value="<%=documentId%>"/><jsp:param name="mode" value="edit"/><jsp:param name="Editable" value="true"/><jsp:param name="manualedit" value="false"/></jsp:include>
<%
	}
    if( "true".equalsIgnoreCase(vcfile) || "true".equalsIgnoreCase(vcfolder)|| "true".equalsIgnoreCase(vcmodule))
    {
     if (hasSyncIdentifierValue)
     {
%>
      <tr>
      <td width="10%" class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Selector</emxUtil:i18n>&nbsp;
       <!-- //XSSOK -->
      <td class="inputField"><input type="text" name="selector" size="25" value="<%=selector%>" readonly />

<%    	     
         String noStore = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.VCDocument.RelativePath"); 
         String stores = MqlUtil.mqlCommand(context, "list store" );
         StringList storeList = FrameworkUtil.split(stores, "\n");
         Iterator storeItr = storeList.iterator();
         StringList servers = new StringList(1);
         String storeType;
         String storeName;
         while(storeItr.hasNext())
         {
            storeName = (String) storeItr.next();
            storeType = MqlUtil.mqlCommand(context, "print store $1 select $2 dump;",storeName, "type");
            if( "designsync".equalsIgnoreCase(storeType) )
            {
              servers.add(storeName);
            }
         }
         servers.add(noStore);
         if ( server == null || "".equals(server) || "null".equals(server) )
         {
           server = noStore;
         }
 %>
    <tr>
    <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Server</emxUtil:i18n>&nbsp;</td>
    <td colspan="1" class="inputField">
          <select id="server" name="server">&nbsp;
<%
          Iterator serverItr = servers.iterator();
          while(serverItr.hasNext())
          {
            String serverName = (String)serverItr.next();
            if (serverName.equals(noStore))
            {
%>
             <!-- //XSSOK -->
			 </option><option value="None" <%=server.equals(noStore)?"selected":""%> ><%=noStore%>&nbsp;</option>
<%
            }
            else
            {
%>
			 <!-- //XSSOK -->
            </option><option value="<%=serverName%>" <%=serverName.equals(server)?"selected":""%> ><%=serverName%>&nbsp;</option>
<%
            }
          }
%>
        </select>
     </td>
     </tr>
     <tr>
       <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Path</emxUtil:i18n>&nbsp;</td>
        <!-- //XSSOK -->
		<td class="inputField"><input type="text" name="path" size="25" value="<%=XSSUtil.encodeForHTMLAttribute(context,path)%>" />
     </tr>
<%
     }
     else
     {
%>
      <tr>
      <td width="10%" class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Selector</emxUtil:i18n>&nbsp;
       <!-- //XSSOK -->
	   <td class="inputField"><input type="text" name="selector" size="25" value="<%=selector%>" />
       <tr>
         <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Server</emxUtil:i18n>&nbsp;</td>
          <!-- //XSSOK -->
		  <td colspan="1" class="field"><%=server%></td>
          <!-- //XSSOK -->
		  <input type="hidden" name="server" value ="<%=server%>" />
       </tr>

       <tr>
         <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Path</emxUtil:i18n>&nbsp;</td>
          <!-- //XSSOK -->
		  <td colspan="1" class="field"><%=path%></td>
          <!-- //XSSOK -->
		  <input type="hidden" name="path" value = "<%=path%>" />
       </tr>
<%
     }
%>
 <%
    if( "true".equalsIgnoreCase(vcfile))
    {
      if (hasSyncIdentifierValue)
      {
%>
        <tr>
        <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.VCfileName</emxUtil:i18n>&nbsp;
         <!-- //XSSOK -->
		 <td class="inputField"><input type="text" name="vcfilename" size="25" value="<%=vcfilename%>" />
        <tr>
<%
      }
      else
      {
%>
       <tr>
         <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.VCfileName</emxUtil:i18n>&nbsp;</td>
		  <!-- //XSSOK -->
         <td colspan="1" class="field"><%=vcfilename%></td>
		  <!-- //XSSOK -->
         <input type="hidden" name="vcfilename" value = "<%=vcfilename%>" />
       </tr>
<%
      }
%>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.VersionId</emxUtil:i18n>&nbsp;
          </td>
			<!-- //XSSOK -->
		   <td colspan="1" class="field"><%=versionid%> </td></tr>
      <tr>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Locked</emxUtil:i18n>&nbsp;
          </td> 
			<!-- //XSSOK -->
			<td colspan="1" class="field"><%=locked%></td></tr>
          <tr>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Comments</emxUtil:i18n>&nbsp;
          </td>
			 <!-- //XSSOK -->
			<td colspan="1" class="field"><%=vcComment%> </td></tr>
      <tr>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Author</emxUtil:i18n>&nbsp;
          </td>
			 <!-- //XSSOK -->
			<td colspan="1" class="field"><%=author%></td></tr>
<%
  }
     if( "true".equalsIgnoreCase(vcfolder) || "true".equalsIgnoreCase(vcmodule))
    {
%>
      <td width="10%" class="label"><emxUtil:i18n localize="i18nId">emxComponents.VCDocument.CheckinStatus</emxUtil:i18n>&nbsp;
          </td> 
			<!-- //XSSOK -->
			<td colspan="1" class="field"><%=vcCheckinStatus%>
         </td></tr>
         
<%  }

}
%>
 </table>
 <!-- //XSSOK -->
<input type="hidden" name="objectId" value="<%=XSSUtil.encodeForHTMLAttribute(context,documentId)%>" />
 <!-- //XSSOK -->
<input type="hidden" name="relTaskDelId" value="<%=strRelTaskDeliverableId%>" />
 <!-- //XSSOK -->
<input type="hidden" name="OldCompleteState" value="<%=strCompletionState%>" />
 <!-- //XSSOK -->
<input type="hidden" name="versionObject" value="<%=isVersionObject%>" />
 <!-- //XSSOK -->
<input type="hidden" name="revision" value="<%=documentRevision%>" />
</form>

<script language="Javascript">
  function showTypeSelector()
  {
	//XSSOK
    var strURL="../common/emxTypeChooser.jsp?fieldNameActual=realType&fieldNameDisplay=txtDocumentType&formName=editDataForm&ShowIcons=true&InclusionList=<%=symbolicDocumentType%>&ObserveHidden=false&SelectType=singleselect&ReloadOpener=true&ReloadOpener=true";
    var win = showModalDialog(strURL, 450, 500, true);
  }

  function reload()
  {
    document.editDataForm.target="";
    document.editDataForm.action="../components/emxCommonDocumentEditDialog.jsp?pageReload=true&contentPageIsDialog=true";
    document.editDataForm.submit();
  }
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
