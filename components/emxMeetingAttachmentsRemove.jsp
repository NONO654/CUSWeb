<%--  emxMeetingAttachmentsRemove.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMeetingAttachmentsRemove.jsp
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  String[] oids = emxGetParameterValues(request, "emxTableRowId");
try
{
  //get document Id
  String action = emxGetParameter(request, "action");
  String objectId = emxGetParameter(request, "objectId");
  DomainObject dObj = DomainObject.newInstance(context,objectId);
  String sObjId ="";

  if ("disconnect".equals(action))
  {
      if(oids != null)
      {
              for(int i=0;i<oids.length;i++)
              {
				  boolean hasToDisconnectAccess = false;
                  boolean hasToConnectAccess = false;
                  StringTokenizer token = new StringTokenizer(oids[i], "|", false);
                  String sRelId = token.nextToken().trim();
                  sObjId = token.nextToken().trim();
                  
                  DomainObject docObj = DomainObject.newInstance(context,sObjId);
                  String strDocOwner =(String)docObj.getInfo(context,DomainConstants.SELECT_OWNER);
                  String strCtxUser = context.getUser();
				  hasToDisconnectAccess = docObj.checkAccess(context, (short)AccessConstants.cToDisconnect);
                  hasToConnectAccess = docObj.checkAccess(context, (short)AccessConstants.cToConnect);				  
                  if(strCtxUser.equalsIgnoreCase(strDocOwner) || (hasToDisconnectAccess && hasToConnectAccess))
                  {   
                     DomainRelationship.disconnect(context, sRelId);
                  }
                  else{
                          %>
                          <script language="javascript">
                          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Meeting.RemoveAttachments</emxUtil:i18nScript>");
                          </script>
                          <% 
              }
              }
             
          

      }
        
  }
} catch (Exception ex)
{
    session.setAttribute("error.message" , ex.toString());
}
%>
<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" >
  var frameContent = findFrame(getTopWindow(),"detailsDisplay");
  var contTree = getTopWindow().objStructureTree;
  if(contTree == null) {
      if (frameContent != null )
      {
        frameContent.document.location.href = frameContent.document.location.href;
      } else {
        getTopWindow().document.location.href = getTopWindow().document.location.href;
      }
  } else {
<%
      for (int i=0;i<oids.length;i++){
        String objId = oids[i];
%>
          contTree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, objId)%>", false);
<%
        }
%>
    if (frameContent != null )
    {
    parent.location.href = parent.location.href;
    } else {
      getTopWindow().document.location.href = getTopWindow().document.location.href;
    }
  }
</script>

</body>
</html>
