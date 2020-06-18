<%-- emxServiceManagementCreateFormValidation.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
   static const char RCSID[] = $Id: emxServiceManagementCreateFormValidation.jsp.rca 1.1 Tue May 18 12:32:15 2010 mvr Experimental $

 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxServiceManagementAppInclude.inc"%>
 <%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil" %> 

<%
  String expirationDateIsInPastAlert = UINavigatorUtil.getI18nString("emxWSManagement.Alert.ExpirationDateIsInPast", "emxWSManagementStringResource", request.getHeader("Accept-Language"));

%>
  //XSSOK
  var expirationDateIsInPastAlert = "<%=expirationDateIsInPastAlert%>";

  function checkPastDate()
  {
    var strExpirationDate = document.forms[0].ExpirationDate.value;
    var expirationDateMod = Date.parse(new Date(strExpirationDate));
    var currentDate = new Date();
    var currentDateMod = Date.parse(currentDate);

    if (expirationDateMod < currentDateMod) {
        alert(expirationDateIsInPastAlert);
        return false;
    }

    return true;
  }
