<%--   emxComponentsCompanyDialogClose.jsp -- This is the page which clears the formBean data of company dialog.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsCompanyDialogClose.jsp.rca 1.5 Wed Oct 22 16:18:24 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  String keyCompany = emxGetParameter(request,"keyCompany");
  if(keyCompany == null)
  {
     keyCompany = formBean.newFormKey(session);
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
  session.removeAttribute(keyCompany);
//------------------------------------
  
%>
<script language = javascript>
getTopWindow().closeWindow();
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
