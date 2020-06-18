<%--  emxEngrDefaultVaultPreferencesProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String sVault = emxGetParameter(request,"vault");
  String selectedOption   = emxGetParameter(request,"RDOOption");
  if(selectedOption==null || selectedOption.equals("null")){
    selectedOption ="";
  }
  if(null != sVault && !"null".equals(sVault)) {

    // if change has been submitted then process the change
    if(selectedOption.equals("CURRENT")){
      // Set RDO Preference in session
      session.setAttribute("ENCDefaultVault",sVault);
    } else if(selectedOption.equals("ALL")){

      try
      {
        // Set RDO Preference
        PropertyUtil.setAdminProperty(context, personAdminType, context.getUser(), PREFERENCE_ENC_DEFAULT_VAULT, sVault);
      }
      catch (Exception ex) {
        throw ex;
      }
      // Set RDO Preference in session
      session.setAttribute("ENCDefaultVault",sVault);
    }
  }
%>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "emxEngrVisiblePageButtomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

