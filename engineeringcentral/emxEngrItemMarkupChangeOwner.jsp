<%--  emxEngrItemMarkupChangeOwner.jsp  -  Hidden Page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@ include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%

  String selectIds = (String) session.getAttribute("selectIds");
  String[] selectIdsArray = selectIds.split(",");
  int size = selectIdsArray.length;
  String selPartParentOId = emxGetParameter(request,"objectId");
  String selectedItem = emxGetParameter(request, "emxTableRowId");
  StringTokenizer strTokens = new StringTokenizer(selectedItem,"|");
  String personId = strTokens.nextToken();
  DomainObject personobj = new DomainObject(personId);
  String ownername = personobj.getInfo(context,DomainConstants.SELECT_NAME);
  for(int i=0;i<size;i++) {
	  try {
	      String selPartObjectId = selectIdsArray[i];
	      DomainObject domobj = new DomainObject(selPartObjectId);
	      domobj.setOwner(context,ownername);
	  } catch (FrameworkException e) {		  
		  session.setAttribute("error.message",e.toString());		  
	  }
  }  
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script language="javascript" type="text/javaScript">//<![CDATA[
getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
getTopWindow().closeWindow();
</script>
