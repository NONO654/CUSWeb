<%--  emxDocumentCentralGenericDocumentCreateWizardActionsDialog.jsp

    Copyright (c) 1992-2016 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,
    Inc.  Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program

    Description : Content Page for Actions page of Doc Create Wizard

    Parameters : Standard Matrix Parameters

    Author     : Anil KJ
    Date       : 01/11/2003
    History    :


    static const char RCSID[] = $Id: emxDocumentCentralGenericDocumentCreateWizardActionsDialog.jsp.rca 1.23 Wed Oct 22 16:02:29 2008 przemek Experimental przemek $;
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxDocumentCentralCommonTopInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>

<!--   Start - Code added By Library Central Team
               For refreshing Structured Browser
-->
<%@ include file = "../common/emxTreeUtilInclude.inc"%>

<jsp:useBean id="person" class="com.matrixone.apps.common.Person" scope="page" />

<%
    // Getting values previously entered, if any , which are stored in formBean
    String notify                   = null;
    String message                  = null;
    String folder                   = null;
    String displayFolder            = null;
    String name                     = null;
    String revision                 = null;
    String NotifyDisplayName        = "";
    String type                     = null;
    String owner                    = null;
    String ROLE_REVIEWER            = PropertyUtil.getSchemaProperty(context, "role_Reviewer" );

    String objectId = emxGetParameter(request, "objectId");
    String parentId = emxGetParameter(request, "parentId");

    String newTreeLabel = UITreeUtil.getUpdatedTreeLabel(application,session,request,context,parentId,(String)null,appDirectory,sLanguage);

    // Getting Object Information through DomainObject
    DomainObject boDocClf  = new DomainObject(objectId);

    StringList selectList  = new StringList();
    selectList.add(DomainObject.SELECT_NAME);
    selectList.add(DomainObject.SELECT_TYPE);
    selectList.add(DomainObject.SELECT_REVISION);
    selectList.add(DomainObject.SELECT_OWNER);

    Map objectDetailsMap  = boDocClf.getInfo(context,selectList);
    name = (String)objectDetailsMap.get(DomainObject.SELECT_NAME);
    type = (String)objectDetailsMap.get(DomainObject.SELECT_TYPE);
    revision = (String)objectDetailsMap.get(DomainObject.SELECT_REVISION);
    owner = (String)objectDetailsMap.get(DomainObject.SELECT_OWNER);

    // Get Message from properties file for Mail notification
    String acceptLanguage = request.getHeader("Accept-Language");
    message  =
    	EnoviaResourceBundle.getProperty(context,"emxDocumentCentralStringResource",new Locale(acceptLanguage),
           "emxDocumentCentral.DocumentCentralCommon.NotificationMessage");

    String [] keys = new String[] {"type","name","revision","user","type"};

    String tmpName =
          (name == null || name.length() == 0)
                    ?
            EnoviaResourceBundle.getProperty(context,"emxDocumentCentralStringResource",new Locale(acceptLanguage),
               "emxDocumentCentral.DocumentCentralCommonWizard.AutoName") : name;
    type = i18nNow.getTypeI18NString(type,acceptLanguage);
    String [] values = new String[] {type,tmpName,revision,owner,type };

    message = StringResource.format(message, keys, values);

    DomainObject doParent = DomainObject.newInstance(context,parentId);
    String parentName     = doParent.getName(context);
%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="frmMain" method="post" target="_parent" onsubmit="submitForm(); return false;">
  <input type="hidden" name="objectId" id="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="parentId" id="parentId" value="<xss:encodeForHTMLAttribute><%=parentId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="Approver"  id="Approver" value=""/>
  <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <tr>
      <td width="150" class="labelRequired">
          <emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Approver</emxUtil:i18n>
      </td>
      <td class="inputField" width="380">
        <input type="text" size="20" name="ApproverDisplay" id="ApproverDisplay" value="" readonly="readonly" />
        <!-- XSSOK - encoded using Framework.encodeURL -->
        <input type="button" value="..." name="btn" id="btn" onclick="showPersonChooser('<%=Framework.encodeURL(response, "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE=role_Reviewer&suiteKey=LibraryCentral&showInitialResults=true&type=PERSON_CHOOSER&fieldNameDisplay=ApproverDisplay&fieldNameActual=Approver&selection=single&form=AEFSearchPersonForm&submitURL=AEFSearchUtil.jsp&table=AEFPersonChooserDetails")%>')"/>
        <a class = "dialogClear"
           href = "javascript:;" onclick = "document.frmMain.ApproverDisplay.value = '';document.frmMain.Approver.value = ''; document.frmMain.ApproverOID.value = ''"> <emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Clear</emxUtil:i18n></a>
        <input type="hidden" name="ApproverOID"  id="ApproverOID" value=""/>
      </td>
    </tr>
    <tr>
      <td width ="150" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Notify</emxUtil:i18n></td>
      <td class="inputField">
        <input type="text" size="20" name="NotifyDisplay"  id= "NotifyDisplay"  value=""  readonly="readonly" />
        <!-- XSSOK - encoded using Framework.encodeURL -->
        <input type="button" value="..." name="btn" id="btn" onclick="showPersonChooser('<%=Framework.encodeURL(response, "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&suiteKey=LibraryCentral&showInitialResults=true&type=PERSON_CHOOSER&fieldNameDisplay=NotifyDisplay&fieldNameActual=Notify&selection=multiple&form=AEFSearchPersonForm&submitURL=AEFSearchUtil.jsp&table=AEFPersonChooserDetails")%>')"/>
        <a class="dialogClear" href="javascript:;" onclick="document.frmMain.NotifyDisplay.value='';document.frmMain.Notify.value='';document.frmMain.NotifyOID.value=''" ><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Clear</emxUtil:i18n></a>
        <input type="hidden" name="Notify" id ="Notify" value=""/>
        <input type="hidden" name="NotifyOID" id ="NotifyOID" value=""/>
      </td>
    </tr>
    <tr>
      <td width ="150" class="label"><b><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Message</emxUtil:i18n></b>
        </label>
      </td>
      <td class="field">
        <textarea name="<%=DocumentCentralConstants.JPO_SPEC_NOTIFY_MESSAGE%>" id="<%=DocumentCentralConstants.JPO_SPEC_NOTIFY_MESSAGE%>" rows="5" cols="25" wrap="soft"><xss:encodeForHTML><%=message%></xss:encodeForHTML></textarea>
      </td>
    </tr>
    <tr>
      <td width ="150" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.AddToFolder </emxUtil:i18n></td>
      <td class="inputField">
        <input type="text" size="20" name="FolderDisplay" id="FolderDisplay" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=displayFolder==null?"":displayFolder%></xss:encodeForHTMLAttribute>" />
        <!-- XSSOK - encoded using Framework.encodeURL -->
        <input type="button" value="..." name="btn" id="btn" onclick='showFolderChooser("<%=Framework.encodeURL(response, "../common/emxFullSearch.jsp?field=TYPES=type_ProjectVault&suiteKey=LibraryCentral&showInitialResults=true&includeOIDprogram=emxLibraryCentralCommon:getFolders&table=LBCFoldersSearchResults&fieldNameDisplay=FolderDisplay&fieldNameActual=Folder&selection=multiple&showInitialResults=true&submitURL=AEFSearchUtil.jsp")%>")' />
        <a class="dialogClear" href="javascript:;" onclick="document.frmMain.FolderDisplay.value='';document.frmMain.Folder.value='';document.frmMain.FolderOID.value=''" ><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Clear</emxUtil:i18n></a>
        <input type="hidden" name="Folder" id="Folder" value="<xss:encodeForHTMLAttribute><%=folder==null?"":folder%></xss:encodeForHTMLAttribute>"/>
        <input type="hidden" name="FolderOID"  id="FolderOID" value=""/>
      </td>
    </tr>
    <tr>
      <td width ="150" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.CreateIn</emxUtil:i18n></td>
      <td class="inputField">
        <input type="text" size="20" name="CreateInDisplay" id="CreateInDisplay" value="" readonly="readonly" />
        <!-- XSSOK - encoded using Framework.encodeURL -->
        <input type="button" value="..." name="btn" id="btn" onclick='showFolderChooser("<%=Framework.encodeURL(response, "../common/emxFullSearch.jsp?field=TYPES=type_Book,type_GeneralClass&excludeOID="+parentId+"&excludeOIDprogram=emxLibraryCentralCommon:getCreateInExcludeOIDs&suiteKey=LibraryCentral&showInitialResults=true&table=AEFGeneralSearchResults&fieldNameDisplay=CreateInDisplay&fieldNameActual=CreateIn&selection=multiple&showWarning=true&submitURL=AEFSearchUtil.jsp&targetLocation=popup")%>")' />
        <a class="dialogClear" href="javascript:;" onclick="document.frmMain.CreateInDisplay.value='';document.frmMain.CreateIn.value='';document.frmMain.CreateInOID.value=''" ><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Clear</emxUtil:i18n></a>
        <input type="hidden" name="CreateIn"  id="CreateIn" value=""/>
        <input type="hidden" name="CreateInOID"  id="CreateInOID" value=""/>
      </td>
    </tr>
  </table>
  <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" style="-moz-user-focus: none" />
</form>

<script language="javascript" type="text/javascript" src="emxDocumentUtilities.js"></script>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language="javascript" type="text/javaScript">

    //Cancel button
    function closeWindow()
    {
        var vAppDirectory   = "<%=appDirectory%>";
        updateCountAndRefreshTree(vAppDirectory, getTopWindow().getWindowOpener().getTopWindow());
        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
        getTopWindow().closeWindow();
    }


    //Done button
    function submitForm()
    {
        var errorMessage = "";
        if((jsTrim(document.frmMain.ApproverDisplay.value)) == "")
        {
             errorMessage += " - <emxUtil:i18nScript localize="i18nId">emxDocumentCentral.Message.ChooseAApprover</emxUtil:i18nScript>";
        }
        if (errorMessage != "")
        {
            errorMessage = "<emxUtil:i18nScript localize="i18nId">emxDocumentCentral.ErrorMsg.ErrorHasOccured</emxUtil:i18nScript>\n" + errorMessage + "\n\n<emxUtil:i18nScript localize="i18nId">emxDocumentCentral.CreateDocument.ReEnter</emxUtil:i18nScript>";
            alert(errorMessage);
        }
        else
        {
           document.frmMain.<%=DocumentCentralConstants.JPO_SPEC_NOTIFY_MESSAGE%>.value=jsTrim(document.frmMain.<%=DocumentCentralConstants.JPO_SPEC_NOTIFY_MESSAGE%>.value);
           document.frmMain.action =  "emxDocumentCentralGenericDocumentCreateWizardSetContextProcess.jsp";
           startProgressBar(true);
           if(jsDblClick())
           {
             document.frmMain.submit();
           }
           return ;
        }
    }
</script>

<%@include file = "emxDocumentCentralCommonBottomInclude.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
