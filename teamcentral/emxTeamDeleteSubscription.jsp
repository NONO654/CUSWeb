<%--  emxTeamDeleteSubscription.jsp   -
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamDeleteSubscription.jsp.rca 1.16 Wed Oct 22 16:05:59 2008 przemek Experimental przemek $
--%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@ include file = "emxTeamUtil.inc"%>
<%@ include file = "emxTeamProfileUtil.inc" %>
<%@ include file = "emxTeamStartUpdateTransaction.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<html>
<body>
<%
  /*10-7-0-0 Conversion Start*/
  String sUnsubEvtIds[]         = ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
  


  String sProjectId             = emxGetParameter(request, "objectId");
  //Preload lookup strings
  String strLoginPersonId      = "";
  boolean bDisconnect      = false;

  BusinessObject boEvent  = null;
  Pattern relPattern      = null;
  Pattern typePattern     = null;
  relPattern              = new Pattern(DomainConstants.RELATIONSHIP_SUBSCRIBED_PERSON);
  typePattern             = new Pattern(DomainConstants.TYPE_PERSON);
  HashMap requestMap = new HashMap();
  requestMap.put("objectId",sProjectId);
  requestMap.put("objId",sUnsubEvtIds);


  try{
	  JPO.invoke(context, "emxWorkspaceSubscription", new String[0], "deleteSubscriptions",JPO.packArgs(requestMap), null);
  }catch(Exception e){
	  e.printStackTrace();
  }
 

%>

  <%@ include file = "emxTeamCommitTransaction.inc" %>

  <form name = detailsForm target = _parent>
    <input type = "hidden" name = "objectId" value = "<xss:encodeForHTMLAttribute><%=sProjectId%></xss:encodeForHTMLAttribute>"/>
  </form>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
  <script language = javascript>
    getTopWindow().refreshTablePage();
  </script>
</body>
</html>
