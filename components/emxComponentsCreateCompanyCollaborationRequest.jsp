<%-- emxComponentsCreateCompanyCollaborationRequest.jsp - Process page to add Collaboration Request

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
   static const char RCSID[] = $Id: emxComponentsCreateCompanyCollaborationRequest.jsp.rca 1.6 Wed Oct 22 16:18:50 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  String objectId     = emxGetParameter(request, "objectId");
  // ids of the organization selected in the company results page
  String selectedIds  = emxGetParameter(request,"selectedIds");
  StringTokenizer stringTokenizer = new StringTokenizer(selectedIds,",");
  int tokenNumber     = 0;
  String tokenValue   = "";
  Organization org    = new Organization(objectId);
  while(stringTokenizer.hasMoreTokens()) 
  {
      tokenValue=stringTokenizer.nextToken();
      // get the Share Types checked checkbox values.
      String selectedShareTypes[] = emxGetParameterValues(request, tokenValue);
      ContextUtil.pushContext(context);
      try
      {
        ContextUtil.startTransaction(context, true);
        
        DomainRelationship relationship = org.addToObjects(context,
                                                        Organization.RELATIONSHIP_COLLABORATION_REQUEST,
                                                        new DomainObject(tokenValue)
                                                        );      
        if(selectedShareTypes!=null)
        {

            if (selectedShareTypes != null && selectedShareTypes.length > 0)
            {
                relationship.setAttributeValue(context,
                                               Organization.ATTRIBUTE_SHARE_TYPES,
                                               FrameworkUtil.join(selectedShareTypes, ","));
            }
        }
        ContextUtil.commitTransaction(context);
      }
      catch (Exception e)
      {
          //abort transaction
          ContextUtil.abortTransaction(context);
          ContextUtil.popContext(context);
          throw (new FrameworkException(e));
      }
        ContextUtil.popContext(context);
  }
%>

<script language="javascript">
   var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "pagecontent"); 
   if(frameContent == null) {
        frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "formViewDisplay");
   }
   if(frameContent != null && frameContent.modalDialog)
   {
     frameContent.modalDialog.releaseMouse();
   }   
   //frameContent.document.location.href=frameContent.document.location.href; 
   window.closeWindow();
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
