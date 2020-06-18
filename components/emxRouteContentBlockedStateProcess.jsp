<%--  displays result of search
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
  String routeId        = emxGetParameter(request, "objectId");
  String sAllRotableIds = emxGetParameter(request, "routableIds");
  StringTokenizer stok = new StringTokenizer(sAllRotableIds, "|");

  String sPolicyAndValue="";
  String sRelId ="";
  String sOldState = "";

  Route routeBean = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);

  while(stok.hasMoreTokens()) {

    String sRouteBasePolicyName ="";
    String sRouteBaseStateName="";

    sRelId = stok.nextToken().trim();
    sPolicyAndValue = emxGetParameter(request, sRelId);
    sOldState = emxGetParameter(request, sRelId+"State");

    if(!("".equals(sPolicyAndValue)) ) {
      sRouteBasePolicyName = sPolicyAndValue.substring(0,sPolicyAndValue.indexOf('#'));
      sRouteBaseStateName = sPolicyAndValue.substring(sPolicyAndValue.indexOf('#')+1,sPolicyAndValue.length());
      routeBean.setId(routeId);
      if(!sRouteBaseStateName.equals(sOldState)){
        //update the attributes "Route Base Policy" and "Route Base State" in the Rel "Object Route"
        routeBean.updateObjectRouteRelAttributes(context, sRelId, sRouteBasePolicyName, sRouteBaseStateName);
      }
    }
  }
%>
<script language="javascript">
  //parent.window.getWindowOpener().document.location.reload();
  getTopWindow().getWindowOpener().document.location.href=getTopWindow().getWindowOpener().document.location.href;
  getTopWindow().closeWindow();
</script>
