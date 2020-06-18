<%--
=================================================================
 CriteriaCreateFormValidation.jsp

 Copyright (c) 1992-2018 Dassault Systemes.
 All Rights Reserved.
 This program contains proprietary and trade secret information of MatrixOne,Inc.
 Copyright notice is precautionary only
 and does not evidence any actual or intended publication of such program
=================================================================
 This file is used to add any validations to the webform if the page opened using emxCreate.jsp
-----------------------------------------------------------------
--%>

<%@page import="com.dassault_systemes.enovia.criteria.util.CriteriaUtil"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%
out.clear();
response.setContentType("text/javascript");
%>
//XSSOK
var INVALID_INPUT_MSG = "<%=CriteriaUtil.getProperty(context, "Criteria.Common.InvalidInputMsg") %>";
//XSSOK
var INVALID_NUMERIC_VALUE = "<%=CriteriaUtil.getProperty(context, "Criteria.Alert.BadNumberic") %>";
//XSSOK
var INVALID_INTEGER_VALUE = "<%=CriteriaUtil.getProperty(context, "Criteria.Alert.BadInteger") %>";

<%@include file="scripts/CriteriaFormValidation.js"%>

