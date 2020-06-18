<%--  emxUIJPCharUtil.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxUIJPCharUtil.jsp.rca 1.16 Wed Oct 22 16:09:20 2008 przemek Experimental przemek $
--%>

<%@ page import="com.matrixone.apps.framework.ui.*" %>
<%@ page contentType="text/html; charset=MS932"%>
<script language="javascript" src="common/scripts/emxUIConstants.js"></script>
<script language="javascript" >
var DIR_STYLES = "common/styles/";
</script>

<html>
<head>
<%@include file = "emxStyleDefaultInclude.inc"%> 
<%@include file = "emxStyleListInclude.inc"%> 
<%@include file = "emxStyleDialogInclude.inc"%> 


<script language="javascript" >

  function launchCheckin(url,directory){
    emxShowModalDialog(url,570, 520);
  }

  function launchCheckout(url,width,height){
    emxShowModalDialog(url,width,height);
  }

</script>

<script language="javascript" src="common/scripts/emxUIModal.js"></script>
<script language="javascript" src="emxUIFilterUtility.js"></script>
<script language="javascript" src="emxUIPageUtility.js"></script>

</head>
<body>
</body>
</html>
