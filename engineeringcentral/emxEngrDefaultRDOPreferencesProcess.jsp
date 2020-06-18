<%--  emxEngrDefaultRDOPreferencesProcess.jsp -
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
  String RDOId = emxGetParameter(request,"RDOId");
  String RDO   = emxGetParameter(request,"RDO");
  String selectedOption   = emxGetParameter(request,"RDOOption");

  if(selectedOption==null || selectedOption.equals("null")){
    selectedOption ="";
  }

  if(null != RDOId && !"null".equals(RDOId)) {

    String sRdoTNR ="";

    if(!RDOId.equals("")){
      DomainObject objRDO = DomainObject.newInstance(context,RDOId);
      defaultRDOName = objRDO.getName(context);
      defaultRDOId = RDOId;
      // construct the rdoTNR string
      sRdoTNR = "{"+objRDO.getType(context)+"}{"+defaultRDOName+"}{"+objRDO.getRevision(context)+"}";
    } else {
      defaultRDOId = "";
      defaultRDOName ="";
    }

    if(selectedOption.equals("CURRENT")){
      // Set RDO Preference in session
      session.setAttribute("rdoTNR",sRdoTNR);
    }else if(selectedOption.equals("ALL")){
      // if change has been submitted then process the change
      try
      {
        // Set RDO Preference
        com.matrixone.apps.common.Person.setDesignResponsibility(context, sRdoTNR);
      }
      catch (Exception ex) {
       throw ex;
      }
      // Set RDO Preference in session
      // do not set preference in the session if its being set for all sessions.
      // session.setAttribute("rdoTNR",sRdoTNR);
    }
  }

%>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "emxEngrVisiblePageButtomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
