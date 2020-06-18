<%--   emxComponentsCreatePeopleDialogClose.jsp -- This is the process page which edits the Route Template Object.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsCreatePeopleDialogClose.jsp.rca 1.5 Wed Oct 22 16:17:46 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  String keyPerson = emxGetParameter(request,"keyPerson");
  if(keyPerson == null)
  {
     keyPerson = formBean.newFormKey(session);
  }
  
// Following code is to remove the values from formBean
  Iterator test = formBean.getElementNames();
  String name = "";
  while(test.hasNext())
  {
    name = (String) test.next();
    formBean.setElementValue(name,"");
  }  
  formBean.removeFormInstance(session,request);
  session.removeAttribute(keyPerson);
//------------------------------------
  
%>
<script language = javascript>
getTopWindow().closeWindow();
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
