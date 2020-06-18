<%-- emxComponentsEditShareTypesProcess.jsp - Process page to edit Share Type attribute values.

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsEditShareTypesDialogProcess.jsp.rca 1.6 Wed Oct 22 16:17:59 2008 przemek Experimental przemek $
--%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String relId              = emxGetParameter(request, "relId");
  String selectedShareTypes = emxGetParameter(request, "selectedShareTypes");
  String attrShareTypes = DomainConstants.ATTRIBUTE_SHARE_TYPES;
  
  // updating the DomainRelationship object with the share types values
  DomainRelationship.setAttributeValue(context,relId,attrShareTypes,selectedShareTypes);
%>

  <script>
      getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
      if(getTopWindow().getWindowOpener().getTopWindow().modalDialog)
      {
        getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
      }
      window.closeWindow();
  </script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>   
