<%--  emxCommonDocumentLock.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDocumentLock.jsp.rca 1.6 Wed Oct 22 16:18:16 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  //get document Id
  String[] oids = request.getParameterValues("emxTableRowId");
  String uiType = request.getParameter("uiType");
  
  
  String parentId = emxGetParameter(request, "parentId");
  String appProcessPage = emxGetParameter(request, "appProcessPage");
  String appDir = emxGetParameter(request, "appDir");

  
  if(oids == null || "".equals(oids) || "null".equals(oids) ){
    //In case the user is coming from Tree details page get the objectId
    oids = new String[1];
    oids[0] = (String)emxGetParameter(request,"objectId");
  }else{
    Map objectMap = UIUtil.parseRelAndObjectIds(context, oids,false);
    oids = (String[])objectMap.get("objectIds");
  }
  if (oids != null) {
    try
    {
      Document documentVC = (Document)DomainObject.newInstance(context, DomainConstants.TYPE_DOCUMENT);
      documentVC.setId(oids[0]);
      String vcfileStr = documentVC.getInfo(context, "vcfile");

      if("true".equalsIgnoreCase(vcfileStr)) {
          MqlUtil.mqlCommand(context, "mod bus $1 vcconnection lock", oids[0]);
      }else {
          for (int i=0; i<oids.length; i++ )
          {
              //build business object/open/unlock/close
              String oid = oids[i];
              BusinessObject document = new BusinessObject(oid);
              document.open(context);
              if (!document.isLocked(context)){
                //lock it if locked
                document.lock(context);
              }
              document.close(context);
          }
      }
    } catch (Exception ex)
    {
        session.setAttribute("error.message" , ex.toString());
    }

    if (!com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(appProcessPage))
    {
        appProcessPage = "../" + XSSUtil.encodeForHTML(context, appDir) + "/" + XSSUtil.encodeForHTML(context, appProcessPage);
  %>
        <jsp:forward page="<%=appProcessPage%>" >
        <jsp:param name ="objectId" value  ="<%=XSSUtil.encodeForHTML(context, oids[0])%>" />
        <jsp:param name ="parentId" value ="<%=XSSUtil.encodeForHTML(context, parentId)%>" />
        <jsp:param name ="actionMode" value ="documentLock" />
        </jsp:forward>
  <%
    } else {
 
%>
<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
</head>
<body>
<script language="Javascript" >
  var frameContent = findFrame(getTopWindow(), "detailsDisplay");
  frameContent = frameContent == null ? findFrame(getTopWindow(), "listDisplay"): frameContent;
  frameContent = frameContent == null ? findFrame(getTopWindow(), "content"): frameContent;
  if (frameContent != null ){
  	frameContent.location.href = frameContent.location.href;
  } else {
    getTopWindow().location.href = getTopWindow().location.href;
  }

</script>

</body>
</html>
<%
  } 
  }//check if doc Id is null
%>
