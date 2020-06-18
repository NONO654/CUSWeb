<%--  emxComponentUnlockDocument.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxAppRouteContentDisconnect.jsp.rca 1.1.7.5 Wed Oct 22 16:18:06 2008 przemek Experimental przemek $
--%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  Route boRoute = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  String[] sRouteIds   = ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
  String inboxTask = PropertyUtil.getSchemaProperty(context, "type_InboxTask");
  String objectId = emxGetParameter(request,"objectId");
  BusinessObject bo = new BusinessObject(objectId);
  bo.open(context);
  boolean contextPushed = false;
  String routeId = null;
  String strRouteIds="";
   if(sRouteIds!=null){
    for (int i=0;i<sRouteIds.length;i++){
      strRouteIds+=sRouteIds[i]+"~";
    }
  }
  
  StringTokenizer stToken   = new StringTokenizer(strRouteIds,"~");
  RelationshipType relType = new RelationshipType();
  RelationshipTypeList relTypeList = relType.getRelationshipTypes(context);
  RelationshipType newRelType = new RelationshipType();

  if(inboxTask!=null && !"".equals(inboxTask) && !"null".equalsIgnoreCase(inboxTask) && inboxTask.equals(bo.getTypeName()))
  {
	  newRelType = relTypeList.find(DomainConstants.RELATIONSHIP_TASK_SUBROUTE);
  }
  else
  {
	  newRelType = relTypeList.find(DomainConstants.RELATIONSHIP_OBJECT_ROUTE);
  }

  while (stToken.hasMoreTokens()){
     try {
       String strToken  = stToken.nextToken();
       if(strToken.indexOf('|')>0){
         routeId        =strToken.substring(strToken.indexOf('|')+1,strToken.length());
          }else{
         routeId        =strToken;
             }
     boRoute.setId(routeId);
     

     try {
           ContextUtil.pushContext(context);
           contextPushed = true;
           boRoute.disconnect(context, newRelType, false, bo);
        }
        catch (Exception exp)
        {
           throw new FrameworkException(exp);
        }
     finally
         {
            if( contextPushed)
            ContextUtil.popContext(context);
         }


       } catch(Exception ex) { }
     }
	bo.close(context);
  %>

<html>
<body>
<head>
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

    if (frameContent != null )
    {
    parent.location.href = parent.location.href;

    } else {

      getTopWindow().document.location.href = getTopWindow().document.location.href;
    }
  }
</script>
</head>
</body>
</html>
