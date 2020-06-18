<%--  emxRouteEditContentProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteEditContentProcess.jsp.rca 1.7 Wed Oct 22 16:18:23 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%
 DomainRelationship  routeObjectRel = null;
 String sAllRotableIds = emxGetParameter(request, "routableIds");
 StringTokenizer stok = new StringTokenizer(sAllRotableIds, "|");
 String sPolicyAndValue="";
 String sRouteBasePolicyName ="";
 String sRouteBaseStateName="";
 String sRelId ="";
 String sRouteBasePolicy = "attribute_RouteBasePolicy";
 String sRouteBaseState = "attribute_RouteBaseState";
 String sObjectRoute="relationship_ObjectRoute";
 String sAttRouteBasePolicy = Framework.getPropertyValue( session, sRouteBasePolicy);
 String sAttRouteBaseState = Framework.getPropertyValue( session, sRouteBaseState);
 String sRelObjectRoute = Framework.getPropertyValue( session, sObjectRoute);

 while(stok.hasMoreTokens()) {

   sRelId = stok.nextToken().trim();
   sPolicyAndValue = emxGetParameter(request, sRelId);
   sRouteBasePolicyName = sPolicyAndValue.substring(0,sPolicyAndValue.indexOf('#'));
   sRouteBaseStateName = sPolicyAndValue.substring(sPolicyAndValue.indexOf('#')+1,sPolicyAndValue.length());
   routeObjectRel = DomainRelationship.newInstance(context,sRelId);
   routeObjectRel.setAttributeValue(context,sAttRouteBasePolicy,sRouteBasePolicyName );
   routeObjectRel.setAttributeValue(context,sAttRouteBaseState,sRouteBaseStateName );

 }

%>

<script language="javascript">
  parent.location.reload();
</script>
