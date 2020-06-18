<%--  emxComponentsAddExistingBusinessUnitProcess.jsp   -   Add existing Business Unit Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsAddExistingBusinessUnitProcess.jsp.rca 1.7 Wed Oct 22 16:18:56 2008 przemek Experimental przemek $
--%>

<%@ page import="com.matrixone.apps.framework.ui.*" %>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@ page import ="com.matrixone.apps.domain.util.*" %>
<%@ page import ="com.matrixone.apps.domain.*" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>		
<%
String objectId = emxGetParameter(request,"objectId");
String[] newId = emxGetParameterValues(request,"newId");
try {  
  Region.addExistingObjects(context,objectId ,newId,false,DomainConstants.RELATIONSHIP_ORGANIZATION_REGION);
}catch(Exception Ex){
  session.putValue("error.message", Ex.toString());
}
%>
<script language="javascript">
  getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
  getTopWindow().closeWindow();   
</script>
