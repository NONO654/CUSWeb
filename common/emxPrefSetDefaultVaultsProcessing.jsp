<%-- emxPrefSetDefaultVaultsProcessing.jsp -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   code to promote given object set in request within main page

   static const char RCSID[] = "$Id: emxPrefSetDefaultVaultsProcessing.jsp.rca 1.4 Wed Oct 22 15:48:32 2008 przemek Experimental przemek $"
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%  
  String searchSelection = emxGetParameter(request,"searchSelection");
  String requestVaults = emxGetParameter(request,"vaults");
  String seleactedVaults = searchSelection;
  if ( seleactedVaults != null && searchSelection.equals(PersonUtil.SEARCH_SELECTED_VAULTS) )
  {
      seleactedVaults = requestVaults;
  }
  if ( seleactedVaults != null && !"".equals(seleactedVaults) || !"null".equals(seleactedVaults))
  {
      PersonUtil.setSearchDefaultVaults(context, seleactedVaults);
  }
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
