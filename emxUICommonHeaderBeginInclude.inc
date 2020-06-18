<%--  emxUICommonHeaderBeginInclude.inc   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxUICommonHeaderBeginInclude.inc.rca 1.32 Wed Oct 22 16:09:34 2008 przemek Experimental przemek $
--%>
<%@ page import="com.matrixone.apps.framework.ui.*" %>
<!DOCTYPE html>
<html>
<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<%
  //Use only if Not a Dialog Page
  String isDialogPage = emxGetParameter(request,"contentPageIsDialog");
  if (!"true".equalsIgnoreCase(isDialogPage)){
      
%>
	<%@include file = "emxStylePropertiesInclude.inc"%> 
<%
  }
%>
<script type="text/javascript" language="javascript">
<%
  String showPFPage = emxGetParameter(request,"PrinterFriendly");
  if ("true".equals(showPFPage)){
%>
			addStyleSheet("emxUIDefaultPF");
			addStyleSheet("emxUIListPF");
			addStyleSheet("emxUIPropertiesPF");
<%
  } else {
%>
			addStyleSheet("emxUIDefault");
			addStyleSheet("emxUIList");
			addStyleSheet("emxUIForm");			
<%
  }
%>

	addStyleSheet("emxUIMenu");
</script>

<script type="text/javascript" language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" language="javascript" src="../emxUIFilterUtility.js"></script>
<script type="text/javascript" language="javascript" src="../emxUIPageUtility.js"></script>


<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICommonHeaderBeginJavaScriptInclude.js"></script>



