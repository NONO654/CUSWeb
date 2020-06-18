<%--  emxCommonDocumentCancelProcess.jsp  - Removes the Locations.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDocumentCancelProcess.jsp.rca 1.3.7.5 Wed Oct 22 16:18:39 2008 przemek Experimental przemek $
--%>


<%@include file = "emxComponentsCheckin.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String strObjectId = emxGetParameter(request,"objectId");
  Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");
  String objectAction        = (String) emxCommonDocumentCheckinData.get("objectAction");
  if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) 
        || objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ)){
  String []objectIds = new String[1];
  objectIds[0] = strObjectId;
  DomainObject.deleteObjects(context,objectIds);
  }
  else if (objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER)){
     String fileORfolder = (String) emxCommonDocumentCheckinData.get("vcDocumentType");
     StringBuffer strBuff = new StringBuffer();
     strBuff.append("disconnect bus ");
     strBuff.append(strObjectId);
     if(fileORfolder.equalsIgnoreCase("Folder"))
        strBuff.append(" vcfolder ");
     else
        strBuff.append(" vcfile ");
     MqlUtil.mqlCommand(context, strBuff.toString());
     StringBuffer strDisConnect = new StringBuffer();
     strDisConnect.append("modify bus ");
     strDisConnect.append(strObjectId);
     strDisConnect.append(" remove interface '");
     strDisConnect.append(CommonDocument.INTERFACE_VC_DOCUMENT);
     strDisConnect.append("'");
     MqlUtil.mqlCommand(context,strDisConnect.toString(),true);
  }
%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="javascript">
  getTopWindow().closeWindow();
</script>
