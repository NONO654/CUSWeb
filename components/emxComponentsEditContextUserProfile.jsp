<%--  emxComponentsEditUserProfile.jsp -- This page redirects to emxTable.jsp to display potential suppliers summary

  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsEditContextUserProfile.jsp.rca 1.5 Wed Oct 22 16:18:57 2008 przemek Experimental przemek $;
--%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>

<%
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String objectId  = com.matrixone.apps.common.Person.getPerson(context).getId();
  
    
%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form action="emxComponentsEditPeopleDialogFS.jsp" name="EditUserProfile" method="post">

      <input type= hidden  name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
      <input type= hidden  name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
      <input type= hidden  name="contextusereditprofile" value="true"/>
      
</form>

<script language="JavaScript">
    document.EditUserProfile.submit();
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
