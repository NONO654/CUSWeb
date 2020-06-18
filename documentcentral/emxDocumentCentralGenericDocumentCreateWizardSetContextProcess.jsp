<%--  emxDocumentCentralGenericDocumentCreateWizardSetContextProcess.jsp

   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   Description: Process Page for Doc Create Wizard. User can come to this page
                by pressing cancel button on any of wizard content pages, or
                done button on add content page, or when the user abruptly
                closes any of Wizard pages

   Parameters : nonFrmBeanAction - Tells, Whether the user is coming to this
                                page by pressing cancel button or done button

   static const char RCSID[] = $Id: emxDocumentCentralGenericDocumentCreateWizardSetContextProcess.jsp.rca 1.8 Wed Oct 22 16:02:47 2008 przemek Experimental przemek $;
--%>

<%@ include file = "../emxUICommonAppInclude.inc" %>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "emxLibraryCentralUtils.inc" %>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%
    String objectId         = emxGetParameter(request, "objectId");
    String approverOid      = emxGetParameter(request, "ApproverOID");
    String notifyToUser     = emxGetParameter(request, "Notify");
    String folderId         = emxGetParameter(request, "FolderOID");
    String CreateInId       = emxGetParameter(request, "CreateInOID");
    String notificationMsg  = emxGetParameter(request, LibraryCentralConstants.JPO_SPEC_NOTIFY_MESSAGE);
    String languagestr      = request.getHeader("Accept-Language");
    DomainObject doObj      = DomainObject.newInstance(context, objectId);
    try
    {
        // set the Approver attribute
        String attrName     = PropertyUtil.getSchemaProperty (context, "attribute_Approver");

        // Set The Attributes On The obj
        String cmd          = "print bus $1 select name dump";
        String approverName = MqlUtil.mqlCommand(context, cmd, approverOid);
        doObj.setAttributeValue(context, attrName, approverName);

        HashMap programMap = new HashMap();

        HashMap paramMap   = new HashMap();
        paramMap.put(LibraryCentralConstants.OBJECT_ID,objectId);

        paramMap.put(LibraryCentralConstants.JPO_ARGS_NEW_VALUE,notifyToUser);
        paramMap.put(LibraryCentralConstants.JPO_ARGS_LANGUAGESTR,languagestr);
        paramMap.put(LibraryCentralConstants.JPO_ARGS_NEW_OID,folderId);
        programMap.put("paramMap",paramMap);

        HashMap requestMap = new HashMap();
        String[] Message   = {notificationMsg};
        requestMap.put("Message",Message);
        programMap.put("requestMap",requestMap);

        String[] args        = JPO.packArgs (programMap);
        String[] constructor = {null};
        // update Notify Field
        if (!UIUtil.isNullOrEmpty(notifyToUser)) {
            JPO.invoke (context,
                        "emxLibraryCentralCommon",
                        constructor,
                        "updateNotifyField",
                        args,
                        String.class);
        }

        // update 'Add to Folder' Field
        if (!UIUtil.isNullOrEmpty(folderId)) {
            JPO.invoke (context,
                        "emxLibraryCentralCommon",
                        constructor,
                        "updateFolderField",
                        args,
                        String.class);
        }

        // update 'Create In' field
        paramMap.put(LibraryCentralConstants.JPO_ARGS_NEW_OID,CreateInId);
        args        = JPO.packArgs (programMap);
        if (!UIUtil.isNullOrEmpty(CreateInId))
        {
            JPO.invoke (context,
                    "emxLibraryCentralCommon",
                    constructor,
                    "updateCreateInFieldForGenericDocument",
                    args,
                    String.class);
         }
    }catch(Exception e) {

    }


%>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language="javascript" type="text/javaScript">
      var vAppDirectory   = "<%=appDirectory%>";
      updateCountAndRefreshTree(vAppDirectory, getTopWindow().getWindowOpener().getTopWindow());
      getTopWindow().closeWindow();
</script>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

