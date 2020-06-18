<%--  emxTeamAttachDocuments.jsp  --  Comnnecting Contents to Discussion/Meeting

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamAttachDocuments.jsp.rca 1.9 Wed Oct 22 16:06:30 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String sObjectId                = emxGetParameter(request, "objectId");
  String ContentID[]              = emxGetParameterValues(request,"chkItem");
  String sProjectId               = emxGetParameter(request,"projectId");
  String sParentId                = emxGetParameter(request, "routeId");
  String sTemplateId              = emxGetParameter(request,"templateId");
  String sTemplateName            = emxGetParameter(request,"template");
  String sContent                 = emxGetParameter(request,"content");
  String sContentId               = emxGetParameter(request,"contentId");
  //DomainObject parentObj          = DomainObject.newInstance(context);
  DomainObject parentObj          = new DomainObject();
  if(sContent == null){
    sContent = "";
  }  

  if(ContentID == null){
      ContentID = emxGetParameterValues(request,"emxTableRowId");
    }
  
  try {
  String sRelationship = "";
    if (ContentID != null) {
	 if (sParentId == null || "".equals(sParentId) ||sParentId.equals("") ){
       parentObj.setId(sObjectId);
     }else{
       parentObj.setId(sParentId);
	 }


     if(parentObj.getInfo(context, parentObj.SELECT_TYPE).equals(parentObj.TYPE_MEETING)) {
        sRelationship = parentObj.RELATIONSHIP_MEETING_ATTACHMENTS;
    } else {
        sRelationship = parentObj.RELATIONSHIP_MESSAGE_ATTACHMENTS;
    }
    for(int i = 0; i<ContentID.length;i++)
        parentObj.connect(context,sRelationship,new DomainObject(ContentID[i]),false);

    }
} catch(Exception e ) {session.setAttribute("error.message", e.getMessage()); }
 %>
 <script language="Javascript">
  parent.window.getWindowOpener().location.href=parent.window.getWindowOpener().location.href;
  parent.window.closeWindow();


</script>
</body>
</html>


