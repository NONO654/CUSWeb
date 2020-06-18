<%-- emxComponentsCheckinTop.inc - used for Checkin of file into Document Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckinTopCode.inc.rca 1.11 Wed Oct 22 16:17:43 2008 przemek Experimental przemek $"
--%>
<%
  request.setAttribute("contentPageIsDialog", "true");
%>
<%@include file = "emxComponentsCheckin.inc"%>
  <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
<%
    String sHelpMarker = "emxhelpfileuploadnoapplet";

    // Getting the display name for the page.
    Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");

    String heading = (String) emxCommonDocumentCheckinData.get("header");
    if ( heading == null || "".equals(heading) || "null".equals(heading) )
    {
        String objectAction = (String)emxCommonDocumentCheckinData.get("objectAction");
        if (objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
            objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
            objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ) ||
	        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CHECKIN_VC_FILE) ||
	        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CHECKIN_VC_FOLDER))
        {
          sHelpMarker = "emxhelpdsfacheckinpage";
        }

        if ( CommonDocument.OBJECT_ACTION_CREATE_MASTER.equalsIgnoreCase(objectAction) )
        {
            heading = "emxComponents.CommonDocument.Step2UploadFiles";
        } else if ( CommonDocument.OBJECT_ACTION_UPDATE_MASTER.equalsIgnoreCase(objectAction) ) {
            heading = "emxComponents.CommonDocument.UpdateFiles";
            sHelpMarker = "emxhelpfileupdate";
        } else if ( CommonDocument.OBJECT_ACTION_CREATE_MASTER_PER_FILE.equalsIgnoreCase(objectAction) ) {
            heading = "emxComponents.CommonDocument.UploadFilesToIndividualDocuments";
        } else if ( CommonDocument.OBJECT_ACTION_CHECKIN_WITH_VERSION.equalsIgnoreCase(objectAction) ) {
            heading = "emxComponents.CommonDocument.CheckinFiles";
        } else if (CommonDocument.OBJECT_ACTION_UPDATE_HOLDER.equalsIgnoreCase(objectAction) ) {
            heading = "emxComponents.Common.UpdateDocuments";
            sHelpMarker = "emxhelpfileupdate";
        } else if ("image".equalsIgnoreCase(objectAction) ) {
            heading = "emxComponents.ImageManager.UploadImages";
            sHelpMarker = "emxhelpfileupdate";
        } else {
            heading = "emxComponents.Common.CheckinDocuments";
        }
    }


    String PageHeading = FrameworkUtil.i18nStringNow(heading,request.getHeader("Accept-Language"));
%>
<table border="0" cellspacing="0" cellpadding="0" width="100%" >
  <tr>
    <td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1" /></td>
  </tr>
</table>
<table border="0" cellpadding="4" cellspacing="2" width="100%">
    <tr>
      <!-- //XSSOK -->
      <td class="pageHeader" width="1%" nowrap="nowrap"><%=PageHeading%></td>
      <td ><img src="../common/images/utilSpacer.gif" width="34" height="28" name="progress" /></td>
      <td width="1%">&nbsp;</td>
    </tr>
</table>
<%
String suiteKey = "Components";
%>
<!-- //XSSOK -->
<jsp:include page = "../common/emxToolbar.jsp" flush="true"><jsp:param name="toolbar" value=""/><jsp:param name="suiteKey" value="<%=suiteKey%>"/><jsp:param name="PrinterFriendly" value="false"/><jsp:param name="helpMarker" value="<%=sHelpMarker%>"/><jsp:param name="export" value="false"/></jsp:include>


