<%--  Revise.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRevise.jsp.rca 1.1 Mon Nov 24 10:42:51 2008 ds-bcasto Experimental $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../components/emxComponentsUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<SCRIPT language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></SCRIPT>
<%
  String objectId = emxGetParameter(request, "objectId");

  if( objectId != null)
  {
    try
    {
			DomainObject domObj = DomainObject.newInstance(context,objectId);

      BusinessObject lastRev = domObj.getLastRevision(context);
      BusinessObject newbo = lastRev.revise(context,lastRev.getNextSequence(context),lastRev.getVault());

    } catch (Exception ex)
    {
        session.setAttribute("error.message" , ex.toString());
    }
  }
%>

<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" > 
  var frameContent = findFrame(getTopWindow(),"detailsDisplay");
  var contTree = getTopWindow().objStructureTree;
  if(contTree == null) {
    frameContent.document.location.href = frameContent.document.location.href;
  } else {
  	  	if(contTree.getSelectedNode())
  	{
    var node = contTree.getSelectedNode().parent;
    }    
    
    var contentFrame = findFrame(getTopWindow(), "content");
    if ( contentFrame != null && node != null && this.name != "listHidden")
    {
        if (getTopWindow().addContextTreeNode)
        {
          getTopWindow().addContextTreeNode('<%=XSSUtil.encodeForJavaScript(context, objectId)%>', node.nodeID, '<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>');
        } else {
          contentFrame.addContextTreeNode('<%=XSSUtil.encodeForJavaScript(context, objectId)%>', node.nodeID, '<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>');
        }
    } else {
        frameContent.document.location.href = frameContent.document.location.href;
    }
  }
</script>
</body>
</html>

