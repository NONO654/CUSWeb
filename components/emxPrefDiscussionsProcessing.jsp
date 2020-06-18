<%-- emxPrefDiscussionsProcessing.jsp -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   code to promote given object set in request within main page

   static const char RCSID[] = "$Id: emxPrefDiscussionsProcessing.jsp.rca 1.3.2.5 Wed Oct 22 16:18:23 2008 przemek Experimental przemek $"
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%  
  String sView = emxGetParameter(request,"view");
  String sSort = emxGetParameter(request,"sort");

  if ( sView != null && !"".equals(sView) || !"null".equals(sView))
  {
      PersonUtil.setDiscussionView(context, sView);
  }
  if ( sSort != null && !"".equals(sSort) || !"null".equals(sSort))
  {
      PersonUtil.setDiscussionSort(context, sSort);
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

