<%--
  emxMEPSetPrefferenceOption.jsp

  Copyright Dassault Systemes, 2007. All rights reserved
  This program is proprietary property of Dassault Systemes and its subsidiaries.
  This documentation shall be treated as confidential information and may only be used by employees or contractors
  with the Customer in accordance with the applicable Software License Agreement
  static const char RCSID[] = $Id: /ENOManufacturerEquivalentPart/CNext/webroot/manufactuerequivalentpart/emxMEPSetPrefferenceOption.jsp 1.1.2.1.1.1 Wed Oct 29 22:14:50 2008 GMT przemek Experimental$
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc" %>
<%@include file = "../emxJSValidation.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="matrix.util.StringList"%>
<script language="javascript" src="../components/emxComponentsJSFunctions.js"></script>
<%
   String preference       = emxGetParameter(request,"preference");
   String[] sCheckBoxArray = emxGetParameterValues(request, "emxTableRowId");
   String attrLocPref = PropertyUtil.getSchemaProperty(context,"attribute_LocationPreference");
   StringList selectedObject=new StringList(2);
   for (int i=0;i<sCheckBoxArray.length;i++)
    {
     selectedObject=FrameworkUtil.split(sCheckBoxArray[i],"|");
     if("true".equals(preference)){
     new com.matrixone.apps.domain.DomainRelationship().setAttributeValue(context,(String)selectedObject.elementAt(0),attrLocPref,"Preferred");
    }
   }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript">
     parent.location.href=parent.location.href;
</script>

