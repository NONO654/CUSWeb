<%--
  emxComponentsPotentialCustomersAddExistingProcess.jsp --

  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsPotentialCustomersAddExistingProcess.jsp.rca 1.5 Wed Oct 22 16:18:42 2008 przemek Experimental przemek $";
--%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%

  String myOrgId = emxGetParameter(request,"objectId");
  Organization myOrg  = new Organization(myOrgId );
  String customerIds[] = emxGetParameterValues(request, "customerID");
  String customerId = "";
  DomainRelationship relationship = null;

  if( customerIds != null )
  {
    for (int i = 0; i < customerIds.length; i++) 
    {
      customerId = customerIds[i];
      relationship = myOrg.addFromObjects(context,
                                        Organization.RELATIONSHIP_SUPPLIER,
                                        new DomainObject(customerId)
                                       );            
    }
  }
%>

<script>
    var framePageContent = findFrame(getWindowOpener().getTopWindow(), "content");
    if(framePageContent.modalDialog)
    {
      framePageContent.modalDialog.releaseMouse();
    }
    framePageContent.document.location.href=framePageContent.document.location.href;
    window.closeWindow();
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>   
